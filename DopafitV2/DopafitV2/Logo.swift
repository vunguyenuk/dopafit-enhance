import SwiftUI

/// Logo Dopafit: chữ D nghiêng, đầu trên vát như mũi tên, bên trái có 2 vạch tốc độ.
/// Vẽ lại theo màn khởi động của app chính (dựng bằng mắt, chưa phải file logo gốc).
struct DopafitMark: Shape {
    /// Chỉ phần chữ D (không gồm vạch tốc độ).
    var part: Part = .all
    enum Part { case all, letter, bars }

    func path(in rect: CGRect) -> Path {
        // Thiết kế trên khung 120 × 64 (dựng đứng), rồi nghiêng chữ sang phải.
        var p = Path()
        if part != .bars {
            // Thân chữ D
            p.move(to: CGPoint(x: 30, y: 0))
            p.addLine(to: CGPoint(x: 80, y: 0))
            p.addArc(center: CGPoint(x: 80, y: 32), radius: 32, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)
            p.addLine(to: CGPoint(x: 36, y: 64))
            p.addLine(to: CGPoint(x: 46, y: 47))
            p.addLine(to: CGPoint(x: 80, y: 47))
            p.addArc(center: CGPoint(x: 80, y: 32), radius: 15, startAngle: .degrees(90), endAngle: .degrees(-90), clockwise: true)
            p.addLine(to: CGPoint(x: 44, y: 17))
            p.closeSubpath()
        }
        if part != .letter {
            // Vạch tốc độ lớn
            p.addRoundedRect(in: CGRect(x: 16, y: 26, width: 13, height: 38), cornerSize: CGSize(width: 2.5, height: 2.5))
            // Vạch tốc độ nhỏ
            p.addRoundedRect(in: CGRect(x: 1, y: 36, width: 9, height: 28), cornerSize: CGSize(width: 2, height: 2))
        }
        // Nghiêng chữ (đỉnh lệch sang phải) và co vừa khung
        let shear = CGAffineTransform(a: 1, b: 0, c: -0.3, d: 1, tx: 0.3 * 64, ty: 0)
        let sheared = p.applying(shear)
        let b = sheared.boundingRect
        let s = min(rect.width / b.width, rect.height / b.height)
        let t = CGAffineTransform(translationX: -b.minX, y: -b.minY)
            .concatenating(CGAffineTransform(scaleX: s, y: s))
            .concatenating(CGAffineTransform(translationX: rect.minX + (rect.width - b.width * s) / 2, y: rect.minY + (rect.height - b.height * s) / 2))
        return sheared.applying(t)
    }
}

/// Màn khởi động: logo xám hiện ra → vệt xanh chanh quét từ trái sang → logo sáng, có vòng tròn mờ → mờ dần vào app.
struct LaunchSplash: View {
    var done: () -> Void
    @State private var appear = false
    @State private var sweep: CGFloat = 0
    @State private var glow = false
    @State private var leave = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            // Vòng tròn và 2 đường kẻ mảnh xuất hiện khi logo sáng
            Circle()
                .stroke(T.lime.opacity(0.35), lineWidth: 1)
                .background(Circle().fill(RadialGradient(colors: [T.lime.opacity(0.16), .clear], center: .center, startRadius: 10, endRadius: 140)))
                .frame(width: 250, height: 250)
                .scaleEffect(glow ? 1 : 0.85)
                .opacity(glow ? 1 : 0)
            VStack(spacing: 168) {
                Rectangle().fill(T.lime.opacity(0.25)).frame(width: 150, height: 1).offset(x: 40)
                Rectangle().fill(T.lime.opacity(0.25)).frame(width: 150, height: 1).offset(x: -40)
            }
            .opacity(glow ? 1 : 0)

            ZStack {
                DopafitMark().fill(Color(white: 0.24))
                DopafitMark()
                    .fill(glow ? Color(red: 0.86, green: 1, blue: 0.62) : T.lime)
                    .mask(alignment: .leading) {
                        GeometryReader { g in
                            Rectangle().frame(width: g.size.width * sweep)
                                .blur(radius: sweep < 1 ? 6 : 0)
                        }
                    }
                    .shadow(color: T.lime.opacity(glow ? 0.9 : 0.4), radius: glow ? 18 : 6)
            }
            .frame(width: 118, height: 70)
            .scaleEffect(appear ? (leave ? 1.15 : 1) : 0.92)
            .opacity(appear ? 1 : 0)
        }
        .opacity(leave ? 0 : 1)
        .accessibilityElement()
        .accessibilityLabel("Dopafit")
        .task {
            withAnimation(.easeOut(duration: 0.35)) { appear = true }
            try? await Task.sleep(nanoseconds: 450_000_000)
            withAnimation(.easeInOut(duration: 0.45)) { sweep = 1 }
            try? await Task.sleep(nanoseconds: 450_000_000)
            withAnimation(.easeOut(duration: 0.4)) { glow = true }
            try? await Task.sleep(nanoseconds: 650_000_000)
            withAnimation(.easeIn(duration: 0.35)) { leave = true }
            try? await Task.sleep(nanoseconds: 350_000_000)
            done()
        }
    }
}
