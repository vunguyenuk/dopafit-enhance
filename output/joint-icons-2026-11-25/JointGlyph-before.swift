import SwiftUI

/// Small region-specific outline diagrams. The marker locates the named joint;
/// they do not represent an exercise or a diagnosis.
struct JointGlyph: View {
    var joint: Joint
    var selected: Bool
    private var anchor: CGPoint {
        switch joint {
        case .neck: CGPoint(x: 16, y: 17)
        case .shoulder: CGPoint(x: 22, y: 13)
        case .elbow: CGPoint(x: 14, y: 19)
        case .wrist: CGPoint(x: 15, y: 25)
        case .lowerBack: CGPoint(x: 16, y: 21)
        case .knee: CGPoint(x: 20, y: 16)
        case .ankle: CGPoint(x: 13, y: 22)
        }
    }
    var body: some View {
        GeometryReader { g in
            JointContour(joint: joint)
                .stroke(T.sub, style: StrokeStyle(lineWidth: 1.7, lineCap: .round, lineJoin: .round))
            JointPainMarker()
                .position(x: anchor.x / 32 * g.size.width, y: anchor.y / 32 * g.size.height)
        }.frame(width: 32, height: 32).accessibilityHidden(true)
    }
}

/// Two soft expanding waves locate the joint without flashing the whole icon.
/// Paused off-screen/inactive; Reduce Motion keeps the same static red marker.
private struct JointPainMarker: View {
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
                            let radius = 3.5 + 9 * eased
                            let opacity = 0.55 * pow(1 - phase, 2)
                            let circle = Path(ellipseIn: CGRect(x: size.width / 2 - radius, y: size.height / 2 - radius, width: radius * 2, height: radius * 2))
                            var glow = context
                            glow.addFilter(.blur(radius: 1.5))
                            glow.stroke(circle, with: .color(red.opacity(opacity * 0.7)), lineWidth: 2.5)
                            context.stroke(circle, with: .color(red.opacity(opacity)), lineWidth: 1)
                        }
                    }
                }
            }
            Circle().fill(T.surface)
                .overlay(Circle().stroke(red, lineWidth: 1.6)
                    .shadow(color: red.opacity(0.8), radius: 3)
                    .shadow(color: red.opacity(0.3), radius: 6))
                .frame(width: 7, height: 7)
        }.frame(width: 28, height: 28)
            .onAppear { visible = true }.onDisappear { visible = false }
            .allowsHitTesting(false).accessibilityHidden(true)
    }
}

private struct JointContour: Shape {
    var joint: Joint
    func path(in rect: CGRect) -> Path {
        var p = Path()
        func line(_ points: [(CGFloat, CGFloat)]) {
            guard let first = points.first else { return }
            p.move(to: CGPoint(x: first.0, y: first.1))
            for point in points.dropFirst() { p.addLine(to: CGPoint(x: point.0, y: point.1)) }
        }
        switch joint {
        case .neck:
            p.addEllipse(in: CGRect(x: 10, y: 1, width: 12, height: 13))
            line([(12,14),(12,20),(4,25),(2,30)])
            line([(20,14),(20,20),(28,25),(30,30)])
            line([(9,23),(16,26),(23,23)])
        case .shoulder:
            line([(4,2),(8,3),(8,9),(17,10)])
            p.move(to: CGPoint(x: 17,y: 10)); p.addQuadCurve(to: CGPoint(x: 27,y: 18), control: CGPoint(x: 27,y: 7))
            line([(27,18),(29,29)]); line([(20,18),(22,30)]); line([(15,13),(14,30)])
            line([(3,16),(12,17),(18,13)])
        case .elbow:
            line([(7,2),(11,3),(14,15),(27,9),(30,11)])
            line([(30,17),(17,24),(11,24),(4,5)])
            line([(26,10),(27,17)])
        case .wrist:
            line([(9,31),(10,22),(5,15),(5,11),(7,10),(11,16),(11,5),(13,3),(15,5),(15,13)])
            line([(15,5),(17,2),(19,4),(19,13)])
            line([(19,6),(21,5),(23,7),(23,15)])
            line([(23,11),(25,10),(27,12),(26,21),(22,26),(22,31)])
            line([(10,24),(22,26)])
        case .lowerBack:
            p.move(to: CGPoint(x: 6,y: 2));p.addCurve(to: CGPoint(x: 5,y: 30), control1: CGPoint(x: 12,y: 14), control2: CGPoint(x: 2,y: 21))
            p.move(to: CGPoint(x: 26,y: 2));p.addCurve(to: CGPoint(x: 27,y: 30), control1: CGPoint(x: 20,y: 14), control2: CGPoint(x: 30,y: 21))
            line([(16,3),(16,28)])
            line([(8,25),(16,29),(24,25)])
            line([(13,10),(19,10)]);line([(13,14),(19,14)]);line([(13,18),(19,18)])
        case .knee:
            line([(9,1),(17,10),(23,12),(25,17),(18,23),(12,31)])
            line([(2,7),(10,17),(14,20),(5,28)])
            line([(20,13),(22,17),(18,20)])
        case .ankle:
            line([(10,1),(10,16),(7,23),(8,29),(25,29),(30,27),(29,24),(23,23),(18,19),(18,1)])
            line([(8,26),(15,26),(18,23)])
        }
        return p.applying(CGAffineTransform(scaleX: rect.width / 32, y: rect.height / 32))
    }
}
