import SwiftUI

/// Region icons from icon libraries (Hugeicons MIT: shoulder, elbow, wrist,
/// lower back, knee; Health Icons MIT/CC0: neck, ankle). Template PDF assets
/// `joint-<region>`; sources in output/joint-icons-2026-11-25/SOURCES.json.
/// The red marker locates the named joint; icons do not represent an exercise
/// or a diagnosis.
struct JointGlyph: View {
    var joint: Joint
    var selected: Bool
    var size: CGFloat = 44
    /// Marker centre as a fraction of the icon box.
    private var anchor: CGPoint {
        switch joint {
        case .neck: CGPoint(x: 0.45, y: 0.7)
        case .shoulder: CGPoint(x: 0.33, y: 0.38)
        case .elbow: CGPoint(x: 0.84, y: 0.76)
        case .wrist: CGPoint(x: 0.5, y: 0.84)
        case .lowerBack: CGPoint(x: 0.5, y: 0.8)
        case .knee: CGPoint(x: 0.83, y: 0.43)
        case .ankle: CGPoint(x: 0.7, y: 0.52)
        }
    }
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("joint-\(joint.rawValue)")
                .resizable().renderingMode(.template).scaledToFit()
                .foregroundStyle(T.sub)
                .frame(width: size, height: size)
            JointPainMarker(scale: size / 44)
                .position(x: anchor.x * size, y: anchor.y * size)
        }.frame(width: size, height: size).accessibilityHidden(true)
    }
}

/// Two soft expanding waves locate the joint without flashing the whole icon.
/// Paused off-screen/inactive; Reduce Motion keeps the same static red marker.
private struct JointPainMarker: View {
    var scale: CGFloat = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var visible = false
    private let red = Color(red: 1.0, green: 0.29, blue: 0.32)
    var body: some View {
        ZStack {
            if !reduceMotion {
                TimelineView(.animation(minimumInterval: 1 / 30, paused: !visible || scenePhase != .active)) { timeline in
                    Canvas { context, size in
                        let time = timeline.date.timeIntervalSinceReferenceDate / 1.8
                        for wave in 0..<2 {
                            let phase = (time + Double(wave) * 0.5).truncatingRemainder(dividingBy: 1)
                            let eased = 1 - pow(1 - phase, 2)
                            let radius = (4.5 + 12 * eased) * scale
                            let opacity = 0.55 * pow(1 - phase, 2)
                            let circle = Path(ellipseIn: CGRect(x: size.width / 2 - radius, y: size.height / 2 - radius, width: radius * 2, height: radius * 2))
                            var glow = context
                            glow.addFilter(.blur(radius: 1.5 * scale))
                            glow.stroke(circle, with: .color(red.opacity(opacity * 0.7)), lineWidth: 2.5 * scale)
                            context.stroke(circle, with: .color(red.opacity(opacity)), lineWidth: 1.2 * scale)
                        }
                    }
                }
            }
            Circle().fill(T.surface)
                .overlay(Circle().stroke(red, lineWidth: 2 * scale)
                    .shadow(color: red.opacity(0.8), radius: 3 * scale)
                    .shadow(color: red.opacity(0.3), radius: 6 * scale))
                .frame(width: 9 * scale, height: 9 * scale)
        }.frame(width: 36 * scale, height: 36 * scale)
            .onAppear { visible = true }.onDisappear { visible = false }
            .allowsHitTesting(false).accessibilityHidden(true)
    }
}
