import SwiftUI

/// A presentation of the actual first prescription, not an interactive scale or strength test.
struct StartingLoadCard: View {
    var item: WorkoutItem
    var unit: WeightUnit
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var reveal: CGFloat = 0
    private var key: String { item.exerciseID + unit.rawValue + "\(item.sets.first?.weightKg ?? 0)-\(scenePhase == .active)-\(reduceMotion)" }

    var body: some View {
        VStack(spacing: 19) {
            Text("Mức khởi điểm đề xuất").font(T.font(14, .medium)).foregroundStyle(T.sub)
            if item.exercise.bodyweightOnly {
                Text("Không tạ").font(T.num(42)).foregroundStyle(T.lime)
            } else {
                StartingWeightCount(weightKg: item.sets.first?.weightKg ?? 0, unit: unit,
                                    progress: reduceMotion ? 1 : Double(reveal))
                    .font(T.num(54)).foregroundStyle(T.lime)
                    .lineLimit(1).minimumScaleFactor(0.7)
            }
            if item.exercise.bodyweightOnly {
                Text("\(item.sets.count) set × \(item.targetReps) rep")
                    .font(T.num(18, .medium)).foregroundStyle(T.text).frame(height: 40)
            } else {
                ZStack {
                    HStack(alignment: .bottom, spacing: 9) {
                        ForEach(-10...10, id: \.self) { i in
                            Capsule().fill(T.sub.opacity(i == 0 ? 0 : 0.65))
                                .frame(width: 2, height: i.isMultiple(of: 5) ? 27 : 14)
                        }
                    }
                    .offset(x: (1 - reveal) * 24)
                    .mask(LinearGradient(colors: [.clear, .white, .white, .clear], startPoint: .leading, endPoint: .trailing))
                    Capsule().fill(T.lime).frame(width: 3, height: 40)
                        .shadow(color: T.lime.opacity(0.4 * reveal), radius: 7)
                }.frame(height: 44).accessibilityHidden(true)
            }
            Text(item.exercise.name).font(T.font(17, .semibold)).foregroundStyle(T.text)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            Text("Chỉnh được ở set đầu").font(T.font(12)).foregroundStyle(T.sub)
        }
        .frame(maxWidth: .infinity).padding(.horizontal, 22).padding(.vertical, 24)
        .background {
            GeometryReader { geometry in
                ZStack {
                    T.surface
                    RadialGradient(colors: [T.lime.opacity(0.12), .clear], center: .topLeading, startRadius: 0, endRadius: geometry.size.width * 0.8)
                    LoadCardWave().fill(LinearGradient(colors: [T.lime.opacity(0.14), T.lime.opacity(0.01)], startPoint: .topTrailing, endPoint: .bottomLeading))
                        .offset(x: (1 - reveal) * 28, y: (1 - reveal) * 12).opacity(0.4 + 0.6 * reveal)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(LinearGradient(colors: [T.lime.opacity(0.3), T.text.opacity(0.1), T.line], startPoint: .topLeading, endPoint: .bottomTrailing)))
        .accessibilityElement(children: .combine)
        .task(id: key) {
            var transaction = Transaction(animation: nil); transaction.disablesAnimations = true
            withTransaction(transaction) { reveal = reduceMotion || scenePhase != .active ? 1 : 0 }
            guard !reduceMotion, scenePhase == .active else { return }
            do {
                // Let the page transition finish so the first visible value is zero.
                try await Task.sleep(for: .milliseconds(300))
                try Task.checkCancellation()
                withAnimation(.timingCurve(0.22, 0.7, 0.3, 1, duration: 1.25)) { reveal = 1 }
            } catch { }
        }
    }
}

/// Animate presentation only. The prescription and accessibility value stay final.
/// Count in whole displayed units, then retain the exact fractional destination.
private struct StartingWeightCount: View, Animatable {
    var weightKg: Double
    var unit: WeightUnit
    var progress: Double
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    var body: some View {
        let destination = unit.fromKg(weightKg)
        let shown = progress >= 1 ? destination : floor(destination * min(1, max(0, progress)))
        Text(Fmt.n(shown) + " " + unit.label)
            .accessibilityLabel(Fmt.w(weightKg, unit))
            .accessibilityIdentifier("onboarding.starting-load.value")
    }
}

private struct LoadCardWave: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: 0, y: rect.height * 0.7))
            p.addCurve(to: CGPoint(x: rect.width, y: rect.height * 0.35), control1: CGPoint(x: rect.width * 0.28, y: rect.height * 0.23), control2: CGPoint(x: rect.width * 0.55, y: rect.height * 0.9))
            p.addLine(to: CGPoint(x: rect.width, y: rect.height))
            p.addLine(to: CGPoint(x: 0, y: rect.height)); p.closeSubpath()
        }
    }
}
