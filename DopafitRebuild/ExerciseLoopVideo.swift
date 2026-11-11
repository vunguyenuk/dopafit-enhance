import SwiftUI
import AVFoundation

/// Hardware-decoded looping preview. No controls overlay; SwiftUI owns interaction.
struct ExerciseLoopVideo:UIViewRepresentable {
    var url:URL
    var speed:Float=1
    final class PlayerView:UIView {
        override class var layerClass:AnyClass {AVPlayerLayer.self}
        var playerLayer:AVPlayerLayer {layer as! AVPlayerLayer}
    }
    final class Coordinator {
        var url:URL?
        var player:AVQueuePlayer?
        var looper:AVPlayerLooper?
        func clear(){player?.pause();looper?.disableLooping();player?.removeAllItems();looper=nil;player=nil;url=nil}
    }
    func makeCoordinator()->Coordinator{Coordinator()}
    func makeUIView(context:Context)->PlayerView {
        let view=PlayerView();view.backgroundColor = .white;view.playerLayer.videoGravity = .resizeAspect
        view.isUserInteractionEnabled=false;return view
    }
    func updateUIView(_ view:PlayerView,context:Context){
        let c=context.coordinator
        if c.url != url {
            c.clear();c.url=url
            let player=AVQueuePlayer();player.isMuted=true;player.preventsDisplaySleepDuringVideoPlayback=false
            let item=AVPlayerItem(url:url);c.looper=AVPlayerLooper(player:player,templateItem:item);c.player=player;view.playerLayer.player=player
        }
        if speed>0 {c.player?.playImmediately(atRate:speed)}else{c.player?.pause()}
    }
    static func dismantleUIView(_ view:PlayerView,coordinator:Coordinator){coordinator.clear();view.playerLayer.player=nil}
}
extension ExerciseDBMedia {
    /// List rows reserve an image slot only for an actual bundled motion clip.
    static func hasMotionThumbnail(for exercise:Exercise)->Bool {videoURL(for:exercise) != nil}
    /// Supplemental footage is separately attributed; it is not an ExerciseDB pin.
    static func hasSupplementalMotion(for exercise:Exercise)->Bool {exercise.id=="discovery-plank"}
    /// Clip demo 3D (nguồn free-exercise-db-with-videos, CHƯA có license — chỉ dùng demo). Ưu tiên hơn clip ExerciseDB 180px.
    /// Người tập chọn giới tính Nữ thì ưu tiên clip người mẫu nữ khi có. RootView cập nhật theo kế hoạch.
    nonisolated(unsafe) static var preferFemale=false
    static func zenithURL(for exercise:Exercise,_ kind:String)->URL? {
        if preferFemale, let url=Bundle.main.url(forResource:exercise.id+"-f-"+kind,withExtension:"mp4",subdirectory:"ExerciseMedia/zenith") {return url}
        return Bundle.main.url(forResource:exercise.id+"-"+kind,withExtension:"mp4",subdirectory:"ExerciseMedia/zenith")
    }
    static func guideVideoURL(for exercise:Exercise)->URL? {
        if hasSupplementalMotion(for:exercise){return Bundle.main.url(forResource:"plank-guide",withExtension:"mp4",subdirectory:"ExerciseMedia/supplemental")}
        if let url=zenithURL(for:exercise,"guide"){return url}
        guard let id=record(for:exercise)?.exerciseId else{return nil}
        return Bundle.main.url(forResource:id,withExtension:"mp4",subdirectory:"ExerciseMedia/guide-previews") ?? videoURL(for:exercise)
    }
    static func videoURL(for exercise:Exercise)->URL? {
        if hasSupplementalMotion(for:exercise){return Bundle.main.url(forResource:"plank-thumb",withExtension:"mp4",subdirectory:"ExerciseMedia/supplemental")}
        if let url=zenithURL(for:exercise,"thumb"){return url}
        guard let id=record(for:exercise)?.exerciseId else{return nil}
        return Bundle.main.url(forResource:id,withExtension:"mp4",subdirectory:"ExerciseMedia/videos")
    }
}
