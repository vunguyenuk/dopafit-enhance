import SwiftUI
import UIKit

/// Native interaction over an offline Blender equipment render. Each increment adds one 2 kg plate per side.
struct PlateLoaderCard: View {
    var title: String
    var slices: Int
    @State private var loaded = 0
    @State private var dragBase: Int?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var total: Double { 4 * Double(loaded) }
    private var full: Bool { loaded >= slices }
    private let sceneHeight: CGFloat = 380

    var body: some View {
        VStack(spacing: 0) {
            scene
                .frame(height: sceneHeight)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        let base = dragBase ?? loaded
                        dragBase = base
                        set(min(slices, max(0, base + Int((value.translation.width / 34).rounded()))))
                    }
                    .onEnded { _ in dragBase = nil })
                .onTapGesture { set(full ? 0 : loaded + 1) }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(title): đã lắp \(Fmt.n(total)) ki lô gam tạ thêm, chưa tính thanh đòn")
                .accessibilityValue("\(loaded) trong \(slices) bánh mỗi bên")
                .accessibilityHint("Vuốt sang phải để lắp tạ, sang trái để tháo. Chạm để thêm một bánh mỗi bên.")
                .accessibilityIdentifier("onboarding.plates.scene")
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: set(min(slices, loaded + 1))
                    case .decrement: set(max(0, loaded - 1))
                    default: break
                    }
                }
            instruction
                .padding(.horizontal, 10).padding(.bottom, 10)
        }
        .background(LinearGradient(colors: [T.raised.opacity(0.64), T.surface, T.bg], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(LinearGradient(colors: [Color.white.opacity(0.28), T.line, T.lime.opacity(0.24)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        .shadow(color: T.lime.opacity(loaded > 0 ? 0.07 : 0.02), radius: 16, y: 6)
    }

    private var instruction: some View {
        HStack(spacing: 8) {
            Image(systemName: full ? "checkmark.circle.fill" : "chevron.right.2")
                .font(T.font(15, .semibold)).foregroundStyle(T.lime)
            Text(full ? "Đã lắp đủ \(Fmt.n(total)) kg" : "Vuốt sang phải để lắp tạ")
                .font(T.font(14, .medium)).foregroundStyle(T.text)
                .lineLimit(2).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 4)
            HStack(spacing: 4) {
                ForEach(0..<slices, id: \.self) { index in
                    Capsule().fill(index < loaded ? T.lime : Color.white.opacity(0.13))
                        .frame(width: 11, height: 4)
                }
            }
            .accessibilityHidden(true)
        }
        .padding(.horizontal, 14).frame(minHeight: 46)
        .background(Color.white.opacity(0.035), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.07), lineWidth: 1))
        .allowsHitTesting(false)
    }

    private func set(_ count: Int) {
        guard count != loaded else { return }
        let adding = count > loaded
        withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.84)) { loaded = count }
        if count == slices && adding {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            UIImpactFeedbackGenerator(style: adding ? .rigid : .soft).impactOccurred()
        }
    }

    private var readout: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: title == "Squat" ? "figure.strengthtraining.traditional" : "dumbbell.fill")
                .font(T.font(25, .medium)).foregroundStyle(T.lime)
                .frame(width: 44, height: 44)
                .background(T.lime.opacity(0.07), in: RoundedRectangle(cornerRadius: 13))
                .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.white.opacity(0.1), lineWidth: 1))
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("+" + Fmt.n(total)).font(T.num(40, .bold))
                        .foregroundStyle(loaded == 0 ? T.text : T.lime)
                        .contentTransition(.numericText(value: total))
                    Text("kg").font(T.font(17, .semibold)).foregroundStyle(T.sub)
                }
                Text(title + " · tạ thêm").font(T.font(13, .medium)).foregroundStyle(T.sub)
            }
        }
    }

    /// Blender Cycles renders share one camera, scale, sleeve and plate geometry.
    /// Only loaded/ghost visibility changes; native gestures and weight math stay live.
    private var scene: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Image("blender-plates-\(slices)-\(loaded)")
                    .resizable().interpolation(.high)
                    .frame(width: geometry.size.width, height: geometry.size.width / 1.35)
                    .offset(y: 80)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
                if !full {
                    Path { path in
                        let width = geometry.size.width
                        path.move(to: CGPoint(x: width * 0.47, y: 126))
                        path.addQuadCurve(to: CGPoint(x: width * 0.69, y: 113), control: CGPoint(x: width * 0.56, y: 100))
                        path.move(to: CGPoint(x: width * 0.665, y: 105))
                        path.addLine(to: CGPoint(x: width * 0.69, y: 113))
                        path.addLine(to: CGPoint(x: width * 0.655, y: 118))
                    }.stroke(T.lime.opacity(0.85), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .allowsHitTesting(false).accessibilityHidden(true)
                }
                readout.offset(x: 18, y: 17)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            .clipped()
        }
    }
}
