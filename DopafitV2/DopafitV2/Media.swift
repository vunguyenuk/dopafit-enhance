import SwiftUI
import AVFoundation
import CoreImage

/// Video động tác luôn chạy đen trắng (hướng B) và lặp lại không tiếng.
struct BWLoopVideo: UIViewRepresentable {
    var file: String
    var gravity: AVLayerVideoGravity = .resizeAspectFill

    final class PlayerView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
        var file = ""
        var observer: NSObjectProtocol?
        deinit { if let observer { NotificationCenter.default.removeObserver(observer) } }
    }

    func makeUIView(context: Context) -> PlayerView {
        let v = PlayerView()
        v.backgroundColor = .black
        v.playerLayer.videoGravity = gravity
        load(v)
        return v
    }

    func updateUIView(_ v: PlayerView, context: Context) {
        v.playerLayer.videoGravity = gravity
        if v.file != file { load(v) }
    }

    private func load(_ v: PlayerView) {
        v.file = file
        if let observer = v.observer { NotificationCenter.default.removeObserver(observer); v.observer = nil }
        guard let url = Res.url(file, "mp4") else { v.playerLayer.player = nil; return }
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        item.videoComposition = AVVideoComposition(asset: asset) { request in
            let mono = request.sourceImage
                .applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0, kCIInputContrastKey: 1.12])
            request.finish(with: mono, context: nil)
        }
        let player = AVPlayer(playerItem: item)
        player.isMuted = true
        player.actionAtItemEnd = .none
        v.observer = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
        v.playerLayer.player = player
        player.play()
    }
}

enum Media {
    static func has(_ name: String?) -> Bool {
        guard let name else { return false }
        return Res.url(name, "mp4") != nil
    }
    static func thumb(_ ex: Exercise) -> String? {
        guard let m = ex.media else { return nil }
        let t = m.replacingOccurrences(of: "-guide", with: "-thumb")
        return has(t) ? t : (has(m) ? m : nil)
    }
    static func guide(_ ex: Exercise) -> String? { has(ex.media) ? ex.media : nil }
}

/// Ô vuông hình bài tập. Có video thì chạy video đen trắng, không thì dùng sơ đồ cơ (một kiểu duy nhất).
struct ExerciseTile: View {
    var exercise: Exercise
    var size: CGFloat = 64
    var body: some View {
        ZStack {
            if let t = Media.thumb(exercise) {
                BWLoopVideo(file: t)
            } else {
                T.raised
                MuscleMiniMap(muscle: exercise.primary).padding(6)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(T.line))
        .accessibilityHidden(true)
    }
}

/// Tìm tài nguyên ở gốc bundle hoặc trong thư mục Media (tùy cách Xcode chép).
enum Res {
    static func url(_ name: String, _ ext: String) -> URL? {
        Bundle.main.url(forResource: name, withExtension: ext)
            ?? Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Media")
    }
}
