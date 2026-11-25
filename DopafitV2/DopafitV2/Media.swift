import SwiftUI
import AVFoundation

/// Local exercise footage retains its natural colors and loops without sound.
struct BWLoopVideo: UIViewRepresentable {
    var file: String
    var gravity: AVLayerVideoGravity = .resizeAspectFill
    var playing = true
    @Environment(\.scenePhase) private var scenePhase

    final class PlayerView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
        var file = ""
        var shouldPlay = true
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
        v.shouldPlay = playing && scenePhase == .active
        if v.shouldPlay { v.playerLayer.player?.play() } else { v.playerLayer.player?.pause() }
    }

    static func dismantleUIView(_ v: PlayerView, coordinator: ()) {
        v.playerLayer.player?.pause()
        v.playerLayer.player = nil
        if let observer = v.observer { NotificationCenter.default.removeObserver(observer); v.observer = nil }
    }

    private func load(_ v: PlayerView) {
        v.file = file
        if let observer = v.observer { NotificationCenter.default.removeObserver(observer); v.observer = nil }
        guard let url = Res.url(file, "mp4") else { v.playerLayer.player = nil; return }
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        player.isMuted = true
        player.actionAtItemEnd = .none
        v.observer = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { [weak v] _ in
            v?.playerLayer.player?.seek(to: .zero)
            if v?.shouldPlay == true { v?.playerLayer.player?.play() }
        }
        v.playerLayer.player = player
        v.shouldPlay = playing && scenePhase == .active
        if v.shouldPlay { player.play() }
    }
}

enum Media {
    // Reviewed exact variants from the user’s Excercises folder; never fuzzy-match filenames.
    static let userFootage: [String: String] = [
        "incline": "user-incline-guide",
        "machinefly": "user-rear-delt-guide",
        "shrug": "user-shrug-guide"
    ]
    static func heroExercise(_ plan: PlannedWorkout, female: Bool) -> Exercise? {
        if let filmed = plan.items.first(where: { Media.userFootage[$0.exerciseID] != nil && Media.guide($0.exercise, female: female) != nil }) { return filmed.exercise }
        // A representative hero may show a library exercise in the same primary muscle group.
        // It is labelled as an illustration, never added to the plan or used as another exercise’s guide.
        let muscles = Set(plan.items.map { $0.exercise.primary })
        let gear = Set(plan.items.map { $0.exercise.gear })
        if let filmed = Catalog.all.first(where: { muscles.contains($0.primary) && gear.contains($0.gear) && Media.userFootage[$0.id] != nil && Media.guide($0, female: female) != nil }) { return filmed }
        return plan.items.first(where: { Media.guide($0.exercise, female: female) != nil })?.exercise
    }

    static func has(_ name: String?) -> Bool {
        guard let name else { return false }
        return Res.url(name, "mp4") != nil
    }
    static func thumb(_ ex: Exercise, female: Bool = false) -> String? {
        guard let m = preferredGuide(ex, female: female) else { return nil }
        let t = m.replacingOccurrences(of: "-guide", with: "-thumb")
        return has(t) ? t : (has(m) ? m : nil)
    }
    static func preferredGuide(_ ex: Exercise, female: Bool) -> String? {
        if let filmed = userFootage[ex.id], has(filmed) { return filmed }
        guard let base = ex.media else { return nil }
        let variant = base.replacingOccurrences(of: "-guide", with: "-f-guide")
        // Only explicitly reviewed sibling files are bundled. Missing female variants retain the exact base exercise.
        return female && variant != base && has(variant) ? variant : base
    }
    static func guide(_ ex: Exercise, female: Bool = false) -> String? {
        let name = preferredGuide(ex, female: female)
        return has(name) ? name : nil
    }
}

/// Ô vuông hình bài tập. Có video thì chạy video gốc, không thì dùng sơ đồ cơ (một kiểu duy nhất).
struct ExerciseTile: View {
    @EnvironmentObject var state: AppState
    var exercise: Exercise
    var size: CGFloat = 64
    var body: some View {
        ZStack {
            if let t = Media.thumb(exercise, female: state.data.profile.sex == .female) {
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
