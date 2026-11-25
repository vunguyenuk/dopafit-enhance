import SwiftUI
import UIKit

/// Blender poses reproduce squash, tremor, tilt and thrust from the audited 24fps
/// reference. Only the explicit Open action plays the one-shot lid flight.
struct ProGiftVisual: View {
    var opening: Bool
    var size: CGFloat = 300
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var landed = false
    var body: some View {
        ZStack {
            if !opening {
                Ellipse().fill(T.lime.opacity(0.18)).frame(width: 180, height: 10)
                    .blur(radius: 12).offset(y: 100)
            }
            GiftFramePlayer(opening: opening, landed: landed, playing: !reduceMotion && scenePhase == .active, onLanding: { landed = true })
                .frame(width: 300, height: 300).clipped()
        }.frame(width: 300, height: 300).scaleEffect(size / 300).frame(width: size, height: size).accessibilityHidden(true).allowsHitTesting(false)
            .onAppear { if reduceMotion { landed = true } }
            .onChange(of: reduceMotion) { _, value in if value { landed = true } }
    }
}

/// The box stays in its layout slot. Only the opening light escapes across
/// the entire paywall, including the safe areas and footer; it never takes taps.
struct GiftLightSourceKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

struct GiftScreenLight: View {
    var opening: Bool
    var source: CGRect
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var began = Date()
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !opening || reduceMotion || scenePhase != .active)) { timeline in
            let time = timeline.date.timeIntervalSince(began)
            // Starts with lid separation, frame5 replayed at14fps; spreads beyond the asset bounds.
            let spread = min(1, max(0, (time - 0.32) / 0.72))
            let energy = min(1, max(0, (time - 0.32) / 0.28))
            Canvas { context, size in
                guard opening, !reduceMotion, spread > 0 else { return }
                let origin = CGPoint(x: source.midX, y: source.minY + source.height * 0.33)
                let reach = max(size.width, size.height) * (0.3 + spread * 1.1)
                let full = Path(CGRect(origin: .zero, size: size))
                context.fill(full, with: .radialGradient(Gradient(stops: [
                    .init(color: .white.opacity(0.58 * energy), location: 0),
                    .init(color: T.lime.opacity(0.30 * energy), location: 0.25),
                    .init(color: T.lime.opacity(0.12 * energy), location: 0.62),
                    .init(color: .clear, location: 1)
                ]), center: origin, startRadius: 0, endRadius: reach))
                context.addFilter(.blur(radius: 20))
                for ray in 0..<7 {
                    let angle = -Double.pi + Double(ray) * Double.pi / 6
                    let tip = CGPoint(x: origin.x + cos(angle) * reach, y: origin.y + sin(angle) * reach)
                    let width = reach * (ray.isMultiple(of: 2) ? 0.10 : 0.055)
                    let dx = -sin(angle) * width, dy = cos(angle) * width
                    var path = Path(); path.move(to: origin)
                    path.addLine(to: CGPoint(x: tip.x + dx, y: tip.y + dy))
                    path.addLine(to: CGPoint(x: tip.x - dx, y: tip.y - dy)); path.closeSubpath()
                    context.fill(path, with: .linearGradient(Gradient(colors: [
                        .white.opacity(0.74 * energy), T.lime.opacity(0.22 * energy), .clear
                    ]), startPoint: origin, endPoint: tip))
                }
            }
        }.blendMode(.screen).allowsHitTesting(false).accessibilityHidden(true)
            .onChange(of: opening) { _, value in if value { began = Date() } }
    }
}

private struct GiftFramePlayer: UIViewRepresentable {
    var opening: Bool
    var landed: Bool
    var playing: Bool
    var onLanding: () -> Void
    final class Player: UIImageView {
        var sequence = ""
        var frames: [UIImage] = []
        var running = false
        var finished = false
        var link: CADisplayLink?
        var began: CFTimeInterval?
        var proxy: TickProxy?
        var onLanding: (() -> Void)?
        override var intrinsicContentSize: CGSize { .zero }
        func startFrames() {
            stopFrames()
            guard !frames.isEmpty else { return }
            running = true; began = nil; image = frames.first
            let target = TickProxy(); target.player = self; proxy = target
            let display = CADisplayLink(target: target, selector: #selector(TickProxy.tick(_:)))
            link = display; display.add(to: .main, forMode: .common)
        }
        func stopFrames() {
            link?.invalidate(); link = nil; proxy = nil; running = false; began = nil
        }
        func advance(_ display: CADisplayLink) {
            guard !frames.isEmpty else { return }
            if began == nil { began = display.timestamp }
            let index = Int((display.timestamp - (began ?? display.timestamp)) * (sequence == "open" ? 14 : 24))
            if sequence != "idle" && index >= frames.count {
                image = frames.last; finished = true; stopFrames()
                if sequence == "drop" { onLanding?() }
            } else {
                image = frames[index % frames.count]
            }
        }
        deinit { link?.invalidate() }
    }
    final class TickProxy: NSObject {
        weak var player: Player?
        @objc func tick(_ display: CADisplayLink) { player?.advance(display) }
    }
    func makeUIView(context: Context) -> Player {
        let v = Player(); v.contentMode = .scaleAspectFit; v.backgroundColor = .clear
        v.isAccessibilityElement = false
        return v
    }
    func updateUIView(_ v: Player, context: Context) {
        v.onLanding = onLanding
        let key = opening ? "open" : (landed ? "idle" : "drop")
        if v.sequence != key {
            v.stopFrames(); v.sequence = key; v.finished = false; v.frames = []
            let count = opening ? 21 : (landed ? 48 : 24)
            // imageWithContents avoids the global named-image cache retaining both sequences.
            v.frames = (0..<count).compactMap { i in
                guard let url = Bundle.main.url(forResource: String(format: "gift-%@-%02d", key, i), withExtension: "png") else { return nil }
                guard let image = UIImage(contentsOfFile: url.path) else { return nil }
                return image.preparingForDisplay() ?? image
            }
            v.image = v.frames.first
        }
        if playing && !v.running && !v.finished {
            v.startFrames()
        } else if !playing {
            v.stopFrames()
            v.image = key == "idle" ? v.frames.first : v.frames.last
        }
    }
    static func dismantleUIView(_ v: Player, coordinator: ()) {
        v.stopFrames(); v.frames = []; v.image = nil; v.onLanding = nil
    }
}
