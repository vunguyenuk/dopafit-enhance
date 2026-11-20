import SwiftUI
import SceneKit
import UIKit
import CoreImage

/// Mô hình 3D "bản đồ cơ" cho màn Hồi phục, style giáp kim loại giống ảnh trên landing page:
/// thân xám kim loại bóng có rãnh panel giữa các nhóm cơ, đầu trứng không mặt, cơ cần nghỉ phát sáng cam.
/// Thân: MakeHuman CC0. Ranh giới nhóm cơ: react-native-body-highlighter (MIT), dựng sẵn thành
/// muscle-id.png (mã nhóm cơ), muscle-seam.png (rãnh), muscle-normal.png (độ lõm rãnh)
/// bằng scripts/build-muscle-body.py và scripts/build-muscle-textures.py.
enum MuscleBody {
    struct Meta {let vertexCount:Int;let indexCount:Int;let height:Float;let texture:Int;let ids:[String]}
    struct Data {let meta:Meta;let geometry:SCNGeometry;let ids:[UInt8];let seam:[UInt8];let normal:UIImage}

    static let shared:Data? = {
        func url(_ n:String,_ e:String)->URL? {Bundle.main.url(forResource:n,withExtension:e,subdirectory:"BodyShapes")}
        guard let mu=url("muscle-body","json"),let bu=url("muscle-body","bin"),
              let mj=(try? JSONSerialization.jsonObject(with:Foundation.Data(contentsOf:mu))) as? [String:Any],
              let bin=try? Foundation.Data(contentsOf:bu),
              let nu=url("muscle-normal","png"),let normal=UIImage(contentsOfFile:nu.path) else {return nil}
        func num(_ k:String)->Int {(mj[k] as? NSNumber)?.intValue ?? 0}
        let meta=Meta(vertexCount:num("vertexCount"),indexCount:num("indexCount"),height:(mj["height"] as? NSNumber)?.floatValue ?? 1.8,
                      texture:num("texture"),ids:mj["ids"] as? [String] ?? [])
        let v=meta.vertexCount,T=meta.texture
        guard v>0,T>0,bin.count==v*32+meta.indexCount*4,
              let ids=gray(url("muscle-id","png"),T),let seam=gray(url("muscle-seam","png"),T) else {return nil}
        let pos=SCNGeometrySource(data:bin.subdata(in:0..<v*12),semantic:.vertex,vectorCount:v,usesFloatComponents:true,componentsPerVector:3,bytesPerComponent:4,dataOffset:0,dataStride:12)
        let nor=SCNGeometrySource(data:bin.subdata(in:v*12..<v*24),semantic:.normal,vectorCount:v,usesFloatComponents:true,componentsPerVector:3,bytesPerComponent:4,dataOffset:0,dataStride:12)
        let uv=SCNGeometrySource(data:bin.subdata(in:v*24..<v*32),semantic:.texcoord,vectorCount:v,usesFloatComponents:true,componentsPerVector:2,bytesPerComponent:4,dataOffset:0,dataStride:8)
        let el=SCNGeometryElement(data:bin.subdata(in:v*32..<bin.count),primitiveType:.triangles,primitiveCount:meta.indexCount/3,bytesPerIndex:4)
        return Data(meta:meta,geometry:SCNGeometry(sources:[pos,nor,uv],elements:[el]),ids:ids,seam:seam,normal:normal)
    }()
    /// Đọc ảnh xám 8-bit thành mảng byte T×T.
    private static func gray(_ u:URL?,_ T:Int)->[UInt8]? {
        guard let u,let img=UIImage(contentsOfFile:u.path)?.cgImage else {return nil}
        var out=[UInt8](repeating:0,count:T*T)
        let ok=out.withUnsafeMutableBytes{buf->Bool in
            guard let ctx=CGContext(data:buf.baseAddress,width:T,height:T,bitsPerComponent:8,bytesPerRow:T,space:CGColorSpaceCreateDeviceGray(),bitmapInfo:CGImageAlphaInfo.none.rawValue) else {return false}
            ctx.interpolationQuality = .none;ctx.draw(img,in:CGRect(x:0,y:0,width:T,height:T));return true
        }
        return ok ? out:nil
    }

    /// Tên nhóm cơ trong app -> vùng trong hình.
    static let slugs:[String:[String]]=[
        "Ngực":["chest"],"Vai":["deltoids"],"Tay trước":["biceps"],"Tay sau":["triceps"],"Cẳng tay":["forearm"],
        "Bụng":["abs","obliques"],"Lưng":["upper-back"],"Lưng dưới":["lower-back"],"Cơ thang":["trapezius"],
        "Mông":["gluteal"],"Đùi trước":["quadriceps"],"Đùi sau":["hamstring"],"Bắp chân":["calves","tibialis"],
        "Cơ khép hông":["adductors"],"Cổ":["neck"]]
    /// Cần nghỉ: lớp sáng xanh lime (màu chính của app). Đang hồi: lớp sáng nhạt hơn. Đã hồi phục: không phủ.
    static func color(heat:Double)->UIColor? {
        if heat>=0.75 {return UIColor(red:0.71,green:0.96,blue:0.24,alpha:1)}
        if heat>=0.3 {return UIColor(red:0.71,green:0.96,blue:0.24,alpha:0.45)}
        return nil
    }
    /// Độ mạnh lớp phủ sáng theo mức hồi phục.
    private static func overlay(heat:Double)->Float? {heat>=0.75 ? 0.5 : heat>=0.3 ? 0.22 : nil}
    private static let ciContext=CIContext(options:[.useSoftwareRenderer:false])

    /// Ảnh màu (diffuse): kim loại xám, rãnh tối, giữ nguyên dù cơ mệt hay không.
    /// Ảnh phát sáng (emission): lớp phủ lime mờ, viền tan dần, nằm trên các nhóm cơ cần nghỉ/đang hồi.
    static func textures(heat:[String:Double])->(color:UIImage,glow:UIImage)? {
        guard let d=shared else {return nil}
        let T=d.meta.texture,n=T*T
        var pal=[Float](repeating:0,count:256)
        for (muscle,value) in heat {
            guard let k=overlay(heat:value) else {continue}
            for s in slugs[muscle] ?? [] {if let i=d.meta.ids.firstIndex(of:s) {pal[i+1]=max(pal[i+1],k)}}
        }
        let body:(Float,Float,Float)=(96,101,108),seamC:(Float,Float,Float)=(22,24,27),lime:(Float,Float,Float)=(181,245,61)
        var col=[UInt8](repeating:255,count:n*4),emi=[UInt8](repeating:255,count:n*4)
        d.ids.withUnsafeBufferPointer{ids in d.seam.withUnsafeBufferPointer{se in
            col.withUnsafeMutableBufferPointer{c in emi.withUnsafeMutableBufferPointer{e in
                for i in 0..<n {
                    let s=Float(se[i])/255,k=pal[Int(ids[i])]
                    c[i*4]=UInt8(body.0*(1-s)+seamC.0*s);c[i*4+1]=UInt8(body.1*(1-s)+seamC.1*s);c[i*4+2]=UInt8(body.2*(1-s)+seamC.2*s)
                    e[i*4]=UInt8(lime.0*k);e[i*4+1]=UInt8(lime.1*k);e[i*4+2]=UInt8(lime.2*k)
                }
            }}
        }}
        func cgImage(_ px:[UInt8])->CGImage? {
            guard let prov=CGDataProvider(data:Foundation.Data(px) as CFData) else {return nil}
            return CGImage(width:T,height:T,bitsPerComponent:8,bitsPerPixel:32,bytesPerRow:T*4,space:CGColorSpace(name:CGColorSpace.sRGB)!,
                           bitmapInfo:CGBitmapInfo(rawValue:CGImageAlphaInfo.noneSkipLast.rawValue),provider:prov,decode:nil,shouldInterpolate:true,intent:.defaultIntent)
        }
        guard let cc=cgImage(col),let ce=cgImage(emi) else {return nil}
        // làm mờ viền lớp phủ để nó trông như ánh sáng phủ lên cơ, không như mảng sơn
        let rect=CGRect(x:0,y:0,width:T,height:T)
        let blurred=CIImage(cgImage:ce).clampedToExtent().applyingGaussianBlur(sigma:22).cropped(to:rect)
        let glow=ciContext.createCGImage(blurred,from:rect,format:.RGBA8,colorSpace:CGColorSpace(name:CGColorSpace.sRGB)) ?? ce
        return (UIImage(cgImage:cc),UIImage(cgImage:glow))
    }

    /// Ảnh môi trường cho phản chiếu kim loại: nền tối, một softbox trắng phía trước-trên, viền xanh lạnh phía sau.
    static let environment:UIImage = {
        let W=512,H=256
        let f=UIGraphicsImageRendererFormat();f.scale=1;f.opaque=true;f.preferredRange = .standard
        return UIGraphicsImageRenderer(size:CGSize(width:W,height:H),format:f).image{ctx in
            let g=ctx.cgContext,cs=CGColorSpaceCreateDeviceRGB()
            let sky=CGGradient(colorsSpace:cs,colors:[UIColor(white:0.30,alpha:1).cgColor,UIColor(white:0.10,alpha:1).cgColor,UIColor(white:0.03,alpha:1).cgColor] as CFArray,locations:[0,0.5,1])!
            g.drawLinearGradient(sky,start:.zero,end:CGPoint(x:0,y:H),options:[])
            func box(_ r:CGRect,_ c:UIColor) {g.setFillColor(c.cgColor);g.fill(r)}
            // equirect: giữa ảnh (x=W/2) là hướng -z (phía camera nhìn tới); x=0 / W là phía sau camera.
            box(CGRect(x:W/2-150,y:40,width:110,height:70),UIColor(white:1,alpha:1))          // softbox chính
            box(CGRect(x:W/2+60,y:60,width:60,height:110),UIColor(white:0.75,alpha:1))         // softbox phụ
            box(CGRect(x:0,y:70,width:40,height:120),UIColor(red:0.55,green:0.75,blue:1,alpha:1)) // viền lạnh phía sau
            box(CGRect(x:W-40,y:70,width:40,height:120),UIColor(red:0.55,green:0.75,blue:1,alpha:1))
            box(CGRect(x:0,y:H-46,width:W,height:46),UIColor(white:0.02,alpha:1))
        }
    }()

    static func scene(heat:[String:Double])->SCNScene? {
        guard let d=shared,let tex=textures(heat:heat) else {return nil}
        let h=d.meta.height
        let geo=d.geometry.copy() as! SCNGeometry
        let mat=SCNMaterial();mat.lightingModel = .physicallyBased
        mat.diffuse.contents=tex.color;mat.metalness.contents=0.45;mat.roughness.contents=0.3
        mat.normal.contents=d.normal;mat.normal.intensity=1
        mat.emission.contents=tex.glow;mat.emission.intensity=0.7
        for p in [mat.diffuse,mat.normal,mat.emission] {p.mipFilter = .none;p.wrapS = .clamp;p.wrapT = .clamp}
        geo.materials=[mat]
        let scene=SCNScene();scene.background.contents=UIColor.clear
        scene.lightingEnvironment.contents=environment;scene.lightingEnvironment.intensity=0.9
        let tilt=SCNNode();tilt.name="tilt";tilt.position=SCNVector3(0,h/2,0)
        let spin=SCNNode();spin.name="spin";tilt.addChildNode(spin)
        let body=SCNNode(geometry:geo);body.name="body";body.position=SCNVector3(0,-h/2,0);spin.addChildNode(body)
        scene.rootNode.addChildNode(tilt)
        let camera=SCNNode();camera.name="camera";camera.camera=SCNCamera();camera.camera?.usesOrthographicProjection=true
        camera.camera?.orthographicScale=Double(h)*0.54;camera.position=SCNVector3(0,h/2,4);camera.camera?.zNear=0.1;camera.camera?.zFar=10
        scene.rootNode.addChildNode(camera)
        let key=SCNNode();key.light=SCNLight();key.light?.type = .directional;key.light?.intensity=1500;key.eulerAngles=SCNVector3(-0.95,0.75,0);camera.addChildNode(key)
        let rim=SCNNode();rim.light=SCNLight();rim.light?.type = .directional;rim.light?.intensity=900
        rim.light?.color=UIColor(red:0.62,green:0.82,blue:1,alpha:1);rim.eulerAngles=SCNVector3(-0.25,-2.5,0);camera.addChildNode(rim)
        return scene
    }
}

/// Kéo ngang xoay quanh thân, kéo dọc nghiêng lên/xuống, chạm hai lần về vị trí đầu.
struct MuscleBody3DView:UIViewRepresentable {
    var heat:[String:Double]=[:]
    var rear=false
    static let restYaw:Float=0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    final class Coordinator:NSObject,UIGestureRecognizerDelegate {
        var key="";var pulseKey="-";var pulsing=false;var yaw:Float=0;var pitch:Float=0;var rear=false
        weak var view:SCNView?
        var link:CADisplayLink?;var start:CFTimeInterval=0
        /// Vùng cơ đang tô màu sáng lên rồi dịu xuống, chu kỳ 1,6 giây.
        func setPulse(_ on:Bool) {
            link?.invalidate();link=nil
            view?.scene?.rootNode.childNode(withName:"body",recursively:true)?.geometry?.firstMaterial?.emission.intensity=0.7
            guard on else {return}
            start=CACurrentMediaTime()
            let l=CADisplayLink(target:self,selector:#selector(tick));l.preferredFrameRateRange=CAFrameRateRange(minimum:20,maximum:30,preferred:30)
            l.add(to:.main,forMode:.common);link=l
        }
        @objc func tick() {
            guard view?.window != nil,let m=view?.scene?.rootNode.childNode(withName:"body",recursively:true)?.geometry?.firstMaterial else {return}
            let t=(CACurrentMediaTime()-start)/1.6
            m.emission.intensity=CGFloat(0.45+0.55*(0.5-0.5*cos(t*2*Double.pi)))
        }
        deinit {link?.invalidate()}
        func apply(animated:Bool) {
            guard let root=view?.scene?.rootNode else{return}
            SCNTransaction.begin();SCNTransaction.animationDuration=animated ? 0.45:0
            SCNTransaction.animationTimingFunction=CAMediaTimingFunction(name:.easeInEaseOut)
            root.childNode(withName:"spin",recursively:true)?.eulerAngles=SCNVector3(0,yaw,0)
            root.childNode(withName:"tilt",recursively:true)?.eulerAngles=SCNVector3(pitch,0,0)
            SCNTransaction.commit()
        }
        @objc func pan(_ g:UIPanGestureRecognizer) {
            guard let view else{return}
            let t=g.translation(in:view);g.setTranslation(.zero,in:view)
            yaw+=Float(t.x)*0.011;pitch=max(-1.25,min(1.25,pitch+Float(t.y)*0.011));apply(animated:false)
        }
        @objc func reset(_ g:UITapGestureRecognizer) {yaw=rear ? .pi:0;pitch=0;apply(animated:true)}
        func gestureRecognizer(_ g:UIGestureRecognizer,shouldBeRequiredToFailBy other:UIGestureRecognizer)->Bool {
            g is UIPanGestureRecognizer && other is UIPanGestureRecognizer && other.view !== g.view
        }
    }
    func makeCoordinator()->Coordinator{Coordinator()}
    func makeUIView(context:Context)->SCNView {
        let view=SCNView();view.backgroundColor = .clear;view.antialiasingMode = .multisampling4X;view.autoenablesDefaultLighting=false
        context.coordinator.view=view
        let pan=UIPanGestureRecognizer(target:context.coordinator,action:#selector(Coordinator.pan(_:)));pan.delegate=context.coordinator;view.addGestureRecognizer(pan)
        let tap=UITapGestureRecognizer(target:context.coordinator,action:#selector(Coordinator.reset(_:)));tap.numberOfTapsRequired=2;view.addGestureRecognizer(tap)
        view.accessibilityHint="Kéo ngang hoặc dọc để xoay, chạm hai lần để về mặt trước"
        return view
    }
    func updateUIView(_ view:SCNView,context:Context) {
        let c=context.coordinator
        let key=heat.keys.sorted().map{"\($0):\(Int((heat[$0] ?? 0)*100))"}.joined()
        if c.key != key {
            c.key=key
            if let scene=view.scene,let mat=scene.rootNode.childNode(withName:"body",recursively:true)?.geometry?.firstMaterial {
                if let t=MuscleBody.textures(heat:heat) {mat.diffuse.contents=t.color;mat.emission.contents=t.glow}   // chỉ vẽ lại ảnh, giữ góc xoay
            } else {
                view.scene=MuscleBody.scene(heat:heat);view.pointOfView=view.scene?.rootNode.childNode(withName:"camera",recursively:false);c.apply(animated:false)
            }
        }
        if c.rear != rear {c.rear=rear;c.yaw=rear ? .pi:0;c.pitch=0;c.apply(animated:!reduceMotion)}
        let pulsing = !reduceMotion && heat.values.contains{MuscleBody.color(heat:$0) != nil}
        if pulsing != c.pulsing || c.key != c.pulseKey {c.pulsing=pulsing;c.pulseKey=c.key;c.setPulse(pulsing)}
        view.rendersContinuously=pulsing
        view.accessibilityLabel="Mô hình cơ thể 3D"
        view.accessibilityValue=heat.keys.filter{MuscleBody.color(heat:heat[$0] ?? 0) != nil}.sorted().joined(separator:", ")
    }
}
