import SwiftUI

/// Fictional Vietnamese AI cutouts arranged like the user's reference.
struct DesireIllustrationCard: View {
    var index: Int
    var title: String
    var selected: Bool
    var height: CGFloat
    var sex: Profile.Sex = .male
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(selected ? T.raised : T.surface)
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(selected ? T.lime : .clear, lineWidth: 1.5))
                    .padding(.top, 34)
                VStack(spacing: 0) {
                    illustration
                        .frame(height: height - 68)
                    Text(title)
                        .font(T.font(17, .semibold))
                        .foregroundStyle(selected ? T.lime : T.text)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .padding(.horizontal, 8)
                }
                if selected {
                    Image(systemName: "checkmark")
                        .font(T.font(11, .bold)).foregroundStyle(Color.black)
                        .frame(width: 22, height: 22).background(T.lime, in: Circle())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 44).padding(.trailing, 10)
                }
            }
            .frame(height: height)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selected)
        .accessibilityLabel(title.replacingOccurrences(of: "\n", with: " "))
        .accessibilityHint("Chọn tối đa hai điều. Chạm lần nữa để bỏ chọn.")
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityIdentifier("onboarding.desire.\(index)")
    }

    private var illustration: some View {
        let photos = ["vn-person-attractive", "vn-person-confident", "vn-person-back", "vn-person-sleep"]
        return GeometryReader { geometry in
            if sex == .female {
                SheetPortrait(asset: "female-desire-sheet", index: min(index, 3), columns: 2, rows: 2, cellInset: 2)
            } else if index == 3 {
                Image(photos[index]).resizable().scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                    .clipped()
            } else {
                Image(photos[min(index, photos.count - 1)]).resizable().scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
            }
        }
        .accessibilityHidden(true)
    }
}

/// A deliberate hold, with reversible progress and an equivalent VoiceOver action.
struct PromiseHoldControl: View {
    var confirmed: Bool
    var action: () -> Void
    var onFrame: (CGRect) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pressing = false

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(T.surface)
                Circle().stroke(Color.white.opacity(0.16), lineWidth: 1)
                Circle().trim(from: 0, to: pressing || confirmed ? 1 : 0)
                    .stroke(T.lime, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(reduceMotion ? nil : (pressing ? .linear(duration: 1.2) : .easeOut(duration: 0.18)), value: pressing)
                if confirmed {
                    Image(systemName: "checkmark").font(T.font(30, .semibold)).foregroundStyle(T.lime)
                } else {
                    DopafitMark().fill(pressing ? T.lime : T.text).frame(width: 44, height: 27)
                }
            }
            .frame(width: 104, height: 104)
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { onFrame($0) }
            .scaleEffect(pressing && !reduceMotion ? 0.96 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: pressing)
            .contentShape(Circle())
            .onLongPressGesture(minimumDuration: 1.2, maximumDistance: 28, perform: {
                guard !confirmed else { return }
                action()
            }, onPressingChanged: { pressing = $0 })
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(confirmed ? "Đã hứa" : "Giữ để hứa")
            .accessibilityHint("Chạm hai lần để xác nhận ngày bắt đầu")
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier("onboarding.promise.hold")
            .accessibilityAction { if !confirmed { action() } }
            Text(confirmed ? "Đã hứa với chính mình" : "Giữ để hứa")
                .font(T.font(16, .semibold)).foregroundStyle(T.text)
            Text(confirmed ? "Bắt đầu từ buổi đầu tiên." : "Giữ 1 giây để xác nhận ngày bắt đầu")
                .font(T.font(13)).foregroundStyle(T.sub)
        }
        .sensoryFeedback(.success, trigger: confirmed)
    }
}

// MARK: - Thành phần cho luồng thiết lập mới (ảnh người, thước kéo, biểu đồ dự đoán)

/// Thẻ ảnh người dạng ô vuông đứng: ảnh phủ kín, chữ trắng ở đáy, chọn thì có viền và dấu tích.
struct PhotoChoiceCard: View {
    var photo: String
    var title: String
    var selected: Bool
    var height: CGFloat = 210
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                PhotoBox(name: photo, height: height, focus: .top)
                LinearGradient(colors: [.clear, .black.opacity(0.88)], startPoint: .init(x: 0.5, y: 0.45), endPoint: .bottom)
                Text(title).font(T.font(16, .semibold)).foregroundStyle(.white)
                    .multilineTextAlignment(.leading).lineLimit(2).padding(14)
            }
            .frame(height: height)
            .overlay(alignment: .topTrailing) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(T.font(22, .semibold))
                    .foregroundStyle(selected ? T.lime : Color.white.opacity(0.75))
                    .background(Circle().fill(Color.black.opacity(0.35)))
                    .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(selected ? T.lime : T.line, lineWidth: selected ? 2.5 : 1))
            .scaleEffect(selected ? 0.98 : 1)
            .animation(.snappy(duration: 0.2), value: selected)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selected)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// Hàng lựa chọn có ảnh người bên phải (chữ trái, ảnh phải mờ dần vào nền thẻ).
struct PhotoRow: View {
    var photo: String
    var title: String
    var detail: String? = nil
    var selected: Bool
    var height: CGFloat = 124
    var focus: Alignment = .center
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(T.font(18, .semibold)).foregroundStyle(T.text)
                    if let detail { Text(detail).font(T.font(14)).foregroundStyle(T.sub).lineLimit(2) }
                }
                .padding(.leading, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                PhotoBox(name: photo, height: height, focus: focus)
                    .frame(width: 168)
                    .overlay(LinearGradient(colors: [T.surface, T.surface.opacity(0)], startPoint: .leading, endPoint: .init(x: 0.35, y: 0.5)))
            }
            .frame(height: height)
            .background(T.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(selected ? T.lime : .clear, lineWidth: 1))
            .overlay(alignment: .trailing) {
                Image(systemName: selected ? "checkmark.circle.fill" : "chevron.right")
                    .font(T.font(selected ? 20 : 12, .semibold))
                    .foregroundStyle(selected ? T.lime : T.sub).padding(.trailing, 14)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selected)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// Hàng chọn nhiều: biểu tượng, chữ, ô tích bên phải.
struct CheckRow: View {
    var icon: String
    var title: String
    var on: Bool
    var joint: Joint? = nil
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                if let joint { JointGlyph(joint: joint, selected: on).frame(width: 32) }
                else { Image(systemName: icon).font(T.font(19, .medium)).foregroundStyle(on ? T.lime : T.sub).frame(width: 32) }
                Text(title).font(T.font(16, .medium)).foregroundStyle(T.text)
                Spacer()
                Image(systemName: on ? "checkmark.circle.fill" : "circle").font(T.font(22)).foregroundStyle(on ? T.lime : T.faint)
            }
            .padding(.horizontal, 16).frame(height: 60)
            .background(T.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(on ? T.lime.opacity(0.7) : T.line))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: on)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

/// Con số lớn ở giữa màn (dùng cho thước kéo).
struct BigValue: View {
    var value: String
    var unit: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(value).font(T.num(76)).foregroundStyle(T.text)
                .contentTransition(.numericText()).monospacedDigit()
            Text(unit).font(T.font(18, .semibold)).foregroundStyle(T.sub)
        }
        .frame(maxWidth: .infinity)
        .animation(.snappy(duration: 0.15), value: value)
    }
}

/// Thước kéo ngang: vuốt để chọn số, vạch giữa màu xanh, rung nhẹ mỗi nấc.
struct RulerPicker: View {
    @Binding var value: Int
    var range: ClosedRange<Int>
    var label: (Int) -> String = { "\($0)" }
    @State private var pos: Int?
    private let tick: CGFloat = 12

    var body: some View {
        GeometryReader { g in
          ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(range, id: \.self) { v in
                        VStack(spacing: 8) {
                            Rectangle()
                                .fill(v % 10 == 0 ? T.text : (v % 5 == 0 ? T.sub : T.faint))
                                .frame(width: v % 5 == 0 ? 2 : 1, height: v % 10 == 0 ? 34 : (v % 5 == 0 ? 24 : 14))
                                .frame(height: 34, alignment: .bottom)
                            Text(v % 10 == 0 ? label(v) : " ")
                                .font(T.num(13, .semibold)).foregroundStyle(T.sub).fixedSize()
                        }
                        .frame(width: tick)
                        .id(v)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, max(0, g.size.width / 2 - tick / 2), for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $pos, anchor: .center)
            .mask(LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .black, location: 0.2),
                                         .init(color: .black, location: 0.8), .init(color: .clear, location: 1)],
                                 startPoint: .leading, endPoint: .trailing))
            .overlay(alignment: .top) {
                Capsule().fill(T.lime).frame(width: 4, height: 46).offset(y: -6).allowsHitTesting(false)
            }
            // đặt thước đúng giá trị đang có, kể cả khi màn vừa trượt vào chưa kịp dựng xong
            .task {
                for _ in 0..<3 {
                    proxy.scrollTo(value, anchor: .center)
                    pos = value
                    try? await Task.sleep(nanoseconds: 120_000_000)
                }
            }
          }
        }
        .frame(height: 66)
        .onChange(of: pos) { _, n in if let n, n != value { value = n } }
        .sensoryFeedback(.selection, trigger: value)
        .accessibilityElement()
        .accessibilityValue(label(value))
        .accessibilityAdjustableAction { d in
            switch d {
            case .increment: value = min(range.upperBound, value + 1)
            case .decrement: value = max(range.lowerBound, value - 1)
            default: break
            }
            pos = value
        }
    }
}

/// Đường cong dự đoán: đi lên chậm lúc đầu rồi nhanh dần (giống đường tăng tạ của người tập đều).
struct ForecastCurve: Shape {
    var closed = false
    func path(in r: CGRect) -> Path {
        var p = Path()
        let a = CGPoint(x: r.minX, y: r.maxY - r.height * 0.1)
        let b = CGPoint(x: r.maxX, y: r.minY + r.height * 0.12)
        p.move(to: a)
        p.addCurve(to: b, control1: CGPoint(x: r.minX + r.width * 0.45, y: r.maxY - r.height * 0.12),
                   control2: CGPoint(x: r.minX + r.width * 0.65, y: r.minY + r.height * 0.2))
        if closed {
            p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
            p.closeSubpath()
        }
        return p
    }
}

/// Thẻ dự đoán: con số tăng tạ ước tính, đường cong vẽ dần, mốc Hôm nay → ngày đạt.
struct ForecastCard: View {
    var lift: String
    var gainKg: Int
    var endLabel: String
    var pin: String = ""
    @State private var drawn: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("+\(gainKg)").font(T.num(48)).foregroundStyle(T.lime)
                Text("kg \(lift)").font(T.font(17, .semibold)).foregroundStyle(T.sub)
            }
            GeometryReader { g in
                let w = g.size.width, h = g.size.height
                ZStack(alignment: .topLeading) {
                    ForEach(0..<3, id: \.self) { i in
                        Rectangle().fill(T.line).frame(height: 1).offset(y: h * CGFloat(i) / 2)
                    }
                    ForecastCurve(closed: true)
                        .fill(LinearGradient(colors: [T.lime.opacity(0.22), T.lime.opacity(0)], startPoint: .top, endPoint: .bottom))
                        .opacity(drawn)
                    ForecastCurve()
                        .trim(from: 0, to: drawn)
                        .stroke(T.lime, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    Circle().fill(T.text).frame(width: 10, height: 10)
                        .position(x: 0, y: h * 0.9)
                    Circle().fill(T.lime).frame(width: 14, height: 14)
                        .overlay(Circle().stroke(T.bg, lineWidth: 3))
                        .position(x: w, y: h * 0.12)
                        .opacity(drawn)
                    if !pin.isEmpty {
                        Text(pin).font(T.num(14, .bold)).foregroundStyle(Color.black)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Capsule().fill(T.lime))
                            .position(x: w - 24, y: h * 0.12 - 30)
                            .opacity(drawn)
                    }
                    Text("Hôm nay").font(T.font(12, .semibold)).foregroundStyle(T.text)
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .background(Capsule().fill(T.raised))
                        .position(x: 34, y: h * 0.9 - 26)
                }
            }
            .frame(height: 150)
            .padding(.horizontal, 6)
            Text("Dự kiến đạt vào " + endLabel.lowercased())
                .font(T.font(14, .semibold)).foregroundStyle(T.sub)
        }
        .padding(20)
        .background(T.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(T.line))
        .onAppear { withAnimation(.easeOut(duration: 1.3).delay(0.25)) { drawn = 1 } }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Ước tính tăng \(gainKg) ki lô gam \(lift) vào \(endLabel)")
    }
}

// MARK: - Cách trình bày lấy từ sườn Figma (giữ nền tối)

/// Tiêu đề có từ khóa nổi màu: viết từ khóa trong ngoặc vuông, ví dụ "Mục tiêu [chính] của bạn?".
func HighlightTitle(_ s: String, size: CGFloat = 28, accent: Color = T.lime) -> Text {
    var out = Text("")
    var rest = Substring(s)
    while let a = rest.firstIndex(of: "["), let b = rest[a...].firstIndex(of: "]") {
        out = out + Text(String(rest[..<a])).foregroundColor(T.text)
        out = out + Text(String(rest[rest.index(after: a)..<b])).foregroundColor(accent)
        rest = rest[rest.index(after: b)...]
    }
    out = out + Text(String(rest)).foregroundColor(T.text)
    return out.font(T.font(size, .bold))
}

/// Thanh tiến độ chia theo chặng (mỗi chặng một vạch), như sườn Figma.
struct PhaseProgress: View {
    var phases: [String]
    var current: Int
    var within: CGFloat
    var body: some View {
        HStack(spacing: 6) {
            ForEach(phases.indices, id: \.self) { i in
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(T.raised)
                        Capsule().fill(T.lime)
                            .frame(width: g.size.width * (i < current ? 1 : (i == current ? max(0.08, within) : 0)))
                    }
                }
                .frame(height: 4)
            }
        }
        .animation(.snappy, value: within)
        .animation(.snappy, value: current)
    }
}

/// Đường cong nhỏ mô tả hành trình tập (lên đều, lên rồi bỏ, đi xuống, đi ngang).
struct JourneyCurve: Shape {
    enum Kind { case up, bump, down, flat }
    var kind: Kind
    var closed = false
    func path(in r: CGRect) -> Path {
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: r.minX + r.width * x, y: r.minY + r.height * y) }
        var p = Path()
        switch kind {
        case .up:
            p.move(to: pt(0, 0.82)); p.addCurve(to: pt(1, 0.12), control1: pt(0.45, 0.85), control2: pt(0.6, 0.2))
        case .bump:
            p.move(to: pt(0, 0.85)); p.addCurve(to: pt(0.45, 0.15), control1: pt(0.15, 0.85), control2: pt(0.3, 0.12))
            p.addCurve(to: pt(1, 0.8), control1: pt(0.6, 0.18), control2: pt(0.75, 0.8))
        case .down:
            p.move(to: pt(0, 0.2)); p.addCurve(to: pt(1, 0.85), control1: pt(0.4, 0.18), control2: pt(0.6, 0.85))
        case .flat:
            p.move(to: pt(0, 0.6)); p.addCurve(to: pt(1, 0.58), control1: pt(0.35, 0.52), control2: pt(0.65, 0.66))
        }
        if closed {
            p.addLine(to: pt(1, 1)); p.addLine(to: pt(0, 1)); p.closeSubpath()
        }
        return p
    }
    /// Điểm cuối (để đặt biểu tượng gương mặt).
    var end: CGPoint {
        switch kind { case .up: CGPoint(x: 1, y: 0.12); case .bump: CGPoint(x: 1, y: 0.8); case .down: CGPoint(x: 1, y: 0.85); case .flat: CGPoint(x: 1, y: 0.58) }
    }
}

/// Thẻ hành trình: đường cong + gương mặt ở cuối đường + nhãn bên dưới.
struct JourneyCard: View {
    var kind: JourneyCurve.Kind
    var face: String
    var title: String
    var selected: Bool
    var action: () -> Void
    private var tint: Color {
        switch kind { case .up: T.lime; case .bump: Color(red: 0.98, green: 0.78, blue: 0.3); case .down: Color(red: 1, green: 0.47, blue: 0.4); case .flat: T.sub }
    }
    var body: some View {
        Button(action: action) {
            VStack(spacing: 14) {
                GeometryReader { g in
                    let c = JourneyCurve(kind: kind)
                    ZStack(alignment: .topLeading) {
                        JourneyCurve(kind: kind, closed: true)
                            .fill(LinearGradient(colors: [tint.opacity(0.28), tint.opacity(0)], startPoint: .top, endPoint: .bottom))
                        c.stroke(LinearGradient(colors: [tint.opacity(0.35), tint], startPoint: .leading, endPoint: .trailing),
                                 style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                        Text(face).font(.system(size: 20))
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(T.raised))
                            .overlay(Circle().stroke(T.line))
                            .position(x: g.size.width * c.end.x - 6, y: g.size.height * c.end.y - 18)
                    }
                }
                .frame(height: 84)
                .padding(.top, 18)
                Text(title).font(T.font(15, .semibold)).foregroundStyle(T.text)
                    .multilineTextAlignment(.center).lineLimit(2).frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 14).padding(.bottom, 16)
            .frame(height: 178)
            .background(T.surface)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(selected ? T.lime : T.line, lineWidth: selected ? 2 : 1))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selected)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// Bong bóng câu nói lớn (kiểu "Bạn có thấy câu này giống mình?").
struct QuoteBubble: View {
    var text: String
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text("“").font(.system(size: 120, weight: .black)).foregroundStyle(T.lime.opacity(0.25))
                .offset(x: -6, y: -54)
            Text(text).font(T.font(23, .bold)).foregroundStyle(Color.black)
                .multilineTextAlignment(.center).lineSpacing(5)
                .padding(.horizontal, 26).padding(.vertical, 34)
                .frame(maxWidth: .infinity)
                .background(
                    BubbleShape().fill(T.lime)
                        .shadow(color: T.lime.opacity(0.25), radius: 24, y: 10)
                )
                .padding(.top, 20)
        }
    }
}

struct BubbleShape: Shape {
    func path(in r: CGRect) -> Path {
        let body = CGRect(x: r.minX, y: r.minY, width: r.width, height: r.height - 18)
        var p = Path(roundedRect: body, cornerRadius: 30, style: .continuous)
        p.move(to: CGPoint(x: body.maxX - 86, y: body.maxY - 2))
        p.addQuadCurve(to: CGPoint(x: body.maxX - 44, y: r.maxY), control: CGPoint(x: body.maxX - 60, y: body.maxY + 6))
        p.addQuadCurve(to: CGPoint(x: body.maxX - 52, y: body.maxY - 2), control: CGPoint(x: body.maxX - 46, y: body.maxY + 4))
        p.closeSubpath()
        return p
    }
}

/// Nút trả lời to, vuông (Không / Đúng).
struct AnswerTile: View {
    var icon: String
    var title: String
    var tint: Color
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon).font(T.font(26, .bold)).foregroundStyle(tint)
                Text(title).font(T.font(18, .semibold)).foregroundStyle(T.text)
            }
            .frame(maxWidth: .infinity).frame(height: 112)
            .background(T.surface)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(T.line))
        }
        .buttonStyle(.plain)
    }
}

/// Tờ lịch to hiện số buổi mỗi tuần.
struct CalendarTile: View {
    var number: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayed = 3
    @State private var target = 3
    @State private var frameName: String? = nil
    @State private var flipTask: Task<Void, Never>? = nil

    var body: some View {
        Image(frameName ?? "onboarding-calendar-\(displayed)")
            .resizable().scaledToFit()
            .frame(width: 230, height: 230)
            .shadow(color: T.lime.opacity(0.12), radius: 24, y: 14)
            .accessibilityHidden(true)
            .onAppear { displayed = number; target = number }
            .onChange(of: number) { _, value in
                target = value
                if reduceMotion { settle() } else { turnTowardTarget() }
            }
            .onChange(of: reduceMotion) { _, _ in settle() }
            .onDisappear { settle() }
    }

    /// Finish each physical leaf, then read the newest slider target. Rapid drags
    /// do not queue stale tasks or block selection; reverse uses the same frames.
    private func turnTowardTarget() {
        guard flipTask == nil, displayed != target else { return }
        flipTask = Task { @MainActor in
            while displayed != target, !Task.isCancelled {
                let next = displayed + (target > displayed ? 1 : -1)
                let low = min(displayed, next)
                let frames = next > displayed ? Array(0..<16) : Array((0..<16).reversed())
                for frame in frames {
                    guard !Task.isCancelled else { return }
                    frameName = String(format: "calendar-flip-%d-%02d", low, frame)
                    do { try await Task.sleep(for: .milliseconds(18)) }
                    catch { return }
                }
                displayed = next
            }
            frameName = nil
            flipTask = nil
        }
    }

    private func settle() {
        flipTask?.cancel()
        flipTask = nil
        displayed = number
        target = number
        frameName = nil
    }
}

/// Thanh trượt có nấc (chấm), nút tròn xanh; chạm hoặc kéo để chọn.
struct DotSlider: View {
    @Binding var value: Int
    var range: ClosedRange<Int>
    var left: String
    var right: String
    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { g in
                let n = range.count - 1
                let step = (g.size.width - 28) / CGFloat(max(1, n))
                let x = 14 + step * CGFloat(value - range.lowerBound)
                ZStack(alignment: .leading) {
                    Capsule().fill(T.raised).frame(height: 8).padding(.horizontal, 6)
                    Capsule().fill(T.lime.opacity(0.5)).frame(width: max(0, x), height: 8)
                    ForEach(0...n, id: \.self) { i in
                        Circle().fill(T.faint).frame(width: 6, height: 6).position(x: 14 + step * CGFloat(i), y: 14)
                    }
                    Circle().fill(T.lime).frame(width: 28, height: 28)
                        .overlay(Circle().stroke(Color.black.opacity(0.4), lineWidth: 4).padding(4))
                        .shadow(color: T.lime.opacity(0.4), radius: 8)
                        .position(x: x, y: 14)
                }
                .frame(height: 28)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                    let i = Int(((v.location.x - 14) / step).rounded())
                    value = min(range.upperBound, max(range.lowerBound, range.lowerBound + i))
                })
            }
            .frame(height: 28)
            HStack {
                Text(left)
                Spacer()
                Text(right)
            }
            .font(T.font(14, .medium)).foregroundStyle(T.sub)
        }
        .animation(.snappy(duration: 0.2), value: value)
        .sensoryFeedback(.selection, trigger: value)
        .accessibilityElement()
        .accessibilityValue("\(value)")
        .accessibilityAdjustableAction { d in
            if d == .increment { value = min(range.upperBound, value + 1) }
            if d == .decrement { value = max(range.lowerBound, value - 1) }
        }
    }
}
