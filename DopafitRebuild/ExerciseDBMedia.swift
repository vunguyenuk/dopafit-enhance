import SwiftUI
import UIKit
import ImageIO
import CryptoKit

/// Pinned exercise identity. A fuzzy search result must never choose a motion at runtime.
enum ExerciseDBMedia {
    struct Record:Decodable {
        var exerciseId:String
        var name:String
        var gifUrl:String
        var instructions:[String]?
        var equipments:[String]?
    }
    static let records:[String:Record] = {
        guard let url=Bundle.main.url(forResource:"exercisedb-mapping",withExtension:"json",subdirectory:"ExerciseMedia"),let data=try? Data(contentsOf:url),let rows=try? JSONDecoder().decode([String:Record].self,from:data) else{return [:]}
        return rows
    }()
    static func record(for exercise:Exercise)->Record?{records[exercise.id]}
    static func gif(for exercise:Exercise) async->Data? {
        guard let record=record(for:exercise) else{return nil}
        return await ExerciseGIFCache.shared.data(for:record)
    }
}
actor ExerciseGIFCache {
    static let shared=ExerciseGIFCache()
    private var pending:[String:Task<Data?,Never>]=[:]
    private let session:URLSession = {
        let config=URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest=15;config.timeoutIntervalForResource=20
        return URLSession(configuration:config)
    }()
    private var folder:URL {FileManager.default.urls(for:.cachesDirectory,in:.userDomainMask)[0].appendingPathComponent("exercisedb",isDirectory:true)}
    static func valid(_ data:Data)->Bool {
        guard data.count>6,data.count<12_000_000,String(data:data.prefix(3),encoding:.ascii)=="GIF",let source=CGImageSourceCreateWithData(data as CFData,nil) else{return false}
        return CGImageSourceGetCount(source)>1
    }
    func data(for record:ExerciseDBMedia.Record) async->Data? {
        let id=record.exerciseId,file=folder.appendingPathComponent(id+".gif")
        if let url=Bundle.main.url(forResource:id,withExtension:"gif",subdirectory:"ExerciseMedia/gifs"),let data=try? Data(contentsOf:url),Self.valid(data){return data}
        if let data=try? Data(contentsOf:file),Self.valid(data){return data}
        if let task=pending[id]{return await task.value}
        guard let url=URL(string:record.gifUrl),url.scheme=="https",url.host=="static.exercisedb.dev",url.path=="/media/"+id+".gif" else{return nil}
        let session=self.session
        let task=Task<Data?,Never>{
            guard let (data,response)=try? await session.data(from:url),(response as? HTTPURLResponse)?.statusCode==200,Self.valid(data) else{return nil}
            return data
        }
        pending[id]=task
        let data=await task.value;pending[id]=nil
        if let data {try? FileManager.default.createDirectory(at:folder,withIntermediateDirectories:true);try? data.write(to:file,options:.atomic)}
        return data
    }
}

struct AnimatedGIF:UIViewRepresentable {
    var data:Data
    var speed:Float=1
    var maxPixel=420
    final class Coordinator {var key=""}
    func makeCoordinator()->Coordinator {Coordinator()}
    func makeUIView(context:Context)->UIImageView {
        let view=UIImageView();view.contentMode = .scaleAspectFit;view.backgroundColor = .white;view.clipsToBounds=true
        view.setContentCompressionResistancePriority(.defaultLow,for:.horizontal);view.setContentCompressionResistancePriority(.defaultLow,for:.vertical)
        view.setContentHuggingPriority(.defaultLow,for:.horizontal);view.setContentHuggingPriority(.defaultLow,for:.vertical)
        return view
    }
    func updateUIView(_ view:UIImageView,context:Context) {
        let key=SHA256.hash(data:data).description+"-\(speed)-\(maxPixel)"
        guard context.coordinator.key != key else{return};context.coordinator.key=key
        let frames=GIFFrames.load(data,maxPixel:maxPixel)
        view.stopAnimating();view.animationImages=nil;view.image=frames?.frames.first
        if speed>0,let frames,frames.frames.count>1 {
            view.animationImages=frames.frames;view.animationDuration=frames.duration/Double(speed);view.animationRepeatCount=0;view.startAnimating()
        }
        view.accessibilityLabel="Minh họa động tác";view.accessibilityValue=speed>0 ? "Đang phát":"Tạm dừng"
    }
    static func dismantleUIView(_ view:UIImageView,coordinator:Coordinator){view.stopAnimating();view.animationImages=nil;view.image=nil}
}
private final class GIFFrames:NSObject {
    let frames:[UIImage],duration:Double
    init(_ frames:[UIImage],_ duration:Double){self.frames=frames;self.duration=duration}
    static let cache:NSCache<NSString,GIFFrames> = {let c=NSCache<NSString,GIFFrames>();c.totalCostLimit=64*1024*1024;c.countLimit=24;return c}()
    static func load(_ data:Data,maxPixel:Int)->GIFFrames? {
        let key=(SHA256.hash(data:data).description+"-\(maxPixel)") as NSString
        if let existing=cache.object(forKey:key){return existing}
        guard let source=CGImageSourceCreateWithData(data as CFData,nil) else{return nil}
        var images:[UIImage]=[],delays:[Int]=[]
        for i in 0..<min(240,CGImageSourceGetCount(source)) {
            let options:[CFString:Any]=[kCGImageSourceCreateThumbnailFromImageAlways:true,kCGImageSourceThumbnailMaxPixelSize:maxPixel,kCGImageSourceCreateThumbnailWithTransform:true]
            guard let frame=CGImageSourceCreateThumbnailAtIndex(source,i,options as CFDictionary) else{continue}
            images.append(UIImage(cgImage:frame))
            let props=CGImageSourceCopyPropertiesAtIndex(source,i,nil) as? [CFString:Any]
            let gif=props?[kCGImagePropertyGIFDictionary] as? [CFString:Any]
            let delay=(gif?[kCGImagePropertyGIFUnclampedDelayTime] as? Double) ?? (gif?[kCGImagePropertyGIFDelayTime] as? Double) ?? 0.1
            delays.append(max(2,Int((delay*100).rounded())))
        }
        guard !images.isEmpty else{return nil}
        func gcd(_ a:Int,_ b:Int)->Int {var x=a,y=b;while y != 0{let r=x%y;x=y;y=r};return x}
        let step=delays.reduce(delays[0],gcd)
        let weighted=zip(images,delays).flatMap{image,delay in Array(repeating:image,count:min(100,delay/step))}
        let result=GIFFrames(weighted,Double(delays.reduce(0,+))/100)
        let cost=images.reduce(0){$0+($1.cgImage.map{$0.bytesPerRow*$0.height} ?? 0)}
        cache.setObject(result,forKey:key,cost:cost);return result
    }
}

/// Actual bundled exercise motion only. Callers omit the image slot when unavailable.
struct ExerciseMotionThumbnail:View {
    @EnvironmentObject private var store:AppStore
    @Environment(\.scenePhase) private var phase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var exercise:Exercise
    @State private var visible=false
    @State private var ownerTab:AppTab?=nil
    var body:some View {
        Group {
            if let url=ExerciseDBMedia.videoURL(for:exercise){ExerciseLoopVideo(url:url,speed:visible && phase == .active && ownerTab==store.tab && !reduceMotion ? 1:0)}
        }
            .onAppear{visible=true;ownerTab=store.tab}.onDisappear{visible=false}
            .accessibilityHidden(true)
    }
}
