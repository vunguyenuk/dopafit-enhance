import SwiftUI
import UIKit

/// Nền graphite, SF và lime Dopafit. Ảnh giữ màu nguồn.
/// Mỗi màu chỉ mang MỘT nghĩa:
///  - lime    = hành động chính, con số quan trọng, "đã xong / sẵn sàng"
///  - lavender = đang hồi phục / cần nghỉ
///  - amber   = cảnh báo (đau, số bất thường)
///  - còn lại là trắng – xám – đen.
enum T {
    static let bg = Color(red: 0.043, green: 0.043, blue: 0.047)
    static let surface = Color(red: 0.086, green: 0.086, blue: 0.094)
    static let raised = Color(red: 0.13, green: 0.13, blue: 0.14)
    static let line = Color.white.opacity(0.08)
    static let text = Color.white
    static let sub = Color(red: 0.69, green: 0.69, blue: 0.71)
    static let faint = Color(red: 0.51, green: 0.51, blue: 0.54)
    static let lime = Color(red: 0.71, green: 0.96, blue: 0.24)
    static let rest = Color(red: 0.62, green: 0.56, blue: 1.0)
    static let warn = Color(red: 0.96, green: 0.73, blue: 0.30)
    static let radius: CGFloat = 18
    static let pad: CGFloat = 20

    /// Hệ số cỡ chữ (Cài đặt > Cỡ chữ). Cập nhật ở RootView mỗi lần vẽ.
    static var scale: CGFloat = 1

    static func font(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size * scale, weight: weight)
    }
    /// Số kiểu bảng ghi phòng gym: đậm, rộng đều chữ số.
    static func num(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .system(size: size * scale, weight: weight).monospacedDigit()
    }
}

// MARK: - Định dạng số (một kiểu duy nhất: dấu phẩy thập phân, dấu chấm hàng nghìn)

enum Fmt {
    private static let nf: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.numberStyle = .decimal
        f.maximumFractionDigits = 1
        f.minimumFractionDigits = 0
        return f
    }()
    static func n(_ v: Double, digits: Int = 1) -> String {
        nf.maximumFractionDigits = digits
        return nf.string(from: NSNumber(value: v)) ?? "\(v)"
    }
    static func n(_ v: Int) -> String { n(Double(v), digits: 0) }

    /// Khối lượng lưu bằng kg, hiển thị theo đơn vị người dùng chọn.
    static func w(_ kg: Double, _ unit: WeightUnit) -> String {
        n(unit.fromKg(kg)) + " " + unit.label
    }
    static func wValue(_ kg: Double, _ unit: WeightUnit) -> String { n(unit.fromKg(kg)) }

    static func duration(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        if m >= 60 { return "\(m / 60) giờ \(m % 60) phút" }
        return String(format: "%d:%02d", m, s)
    }
    static func minutes(_ seconds: Int) -> String { "\(max(1, Int((Double(seconds) / 60).rounded()))) phút" }

    static let dayFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "vi_VN"); f.dateFormat = "EEEE, d 'tháng' M"; return f
    }()
    static let shortDay: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "vi_VN"); f.dateFormat = "d/M"; return f
    }()
    static let monthFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "vi_VN"); f.dateFormat = "'Tháng' M, yyyy"; return f
    }()
    static func day(_ d: Date) -> String { dayFormatter.string(from: d).capitalizedFirst }
}

extension String {
    var capitalizedFirst: String { prefix(1).uppercased() + dropFirst() }
}

// MARK: - Thành phần dùng chung

struct PrimaryButton: View {
    var title: String
    var icon: String? = nil
    var enabled = true
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon).font(T.font(17, .semibold)) }
                Text(title).font(T.font(17, .semibold))
            }
            .frame(maxWidth: .infinity).frame(height: 56)
            .foregroundStyle(enabled ? Color.black : T.sub)
            .background(enabled ? T.lime : T.raised)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

/// Nút phụ: viền trắng mờ. Không bao giờ dùng màu lime cho nút phụ hoặc nút dừng.
struct SecondaryButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title)
            }
            .font(T.font(16, .semibold))
            .frame(maxWidth: .infinity).frame(height: 52)
            .foregroundStyle(T.text)
            .background(T.surface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct IconButton: View {
    var icon: String
    var label: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(T.font(16, .semibold))
                .foregroundStyle(T.text)
                .frame(width: 44, height: 44)
                .background(T.raised)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

struct Card<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(T.surface)
            .clipShape(RoundedRectangle(cornerRadius: T.radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: T.radius, style: .continuous).stroke(T.line))
    }
}

struct SectionTitle: View {
    var title: String
    var trailing: String? = nil
    var action: (() -> Void)? = nil
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(T.font(20, .bold)).foregroundStyle(T.text)
            Spacer()
            if let trailing, let action {
                Button(trailing, action: action).font(T.font(15, .medium)).foregroundStyle(T.sub)
            }
        }
    }
}

struct Chip: View {
    var icon: String
    var title: String
    var highlighted = false
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(T.font(13, .semibold))
            Text(title).font(T.font(13, .medium)).lineLimit(1)
            Image(systemName: "chevron.down").font(T.font(10, .bold)).foregroundStyle(T.faint)
        }
        .foregroundStyle(highlighted ? T.lime : T.text)
        .padding(.horizontal, 10).frame(height: 36)
        .background(T.raised)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(highlighted ? T.lime.opacity(0.5) : Color.clear))
    }
}

/// Một con số lớn + nhãn nhỏ phía dưới (kiểu bảng ghi).
struct BigStat: View {
    var value: String
    var unit: String? = nil
    var label: String
    var accent = false
    var size: CGFloat = 34
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value).font(T.num(size)).foregroundStyle(accent ? T.lime : T.text)
                    .lineLimit(1).minimumScaleFactor(0.6)
                if let unit { Text(unit).font(T.font(size * 0.42, .bold)).foregroundStyle(T.sub) }
            }
            Text(label).font(T.font(13)).foregroundStyle(T.sub).lineLimit(2)
        }
    }
}

struct SegmentedPills: View {
    var titles: [String]
    @Binding var selection: Int
    var body: some View {
        HStack(spacing: 4) {
            ForEach(titles.indices, id: \.self) { i in
                Button { withAnimation(.snappy) { selection = i } } label: {
                    Text(titles[i]).font(T.font(14, .semibold))
                        .frame(maxWidth: .infinity).frame(height: 36)
                        .foregroundStyle(selection == i ? Color.black : T.sub)
                        .background(selection == i ? Color.white : Color.clear)
                        .clipShape(Capsule())
                }.buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(T.surface)
        .clipShape(Capsule())
    }
}

/// Thanh nút cố định ở đáy: có nền chuyển mờ, luôn đẩy nội dung lên chứ không đè.
struct BottomBar<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 10) { content }
            .padding(.horizontal, T.pad)
            .padding(.top, 14)
            .padding(.bottom, 8)
            .background(
                LinearGradient(colors: [T.bg.opacity(0), T.bg.opacity(0.92), T.bg], startPoint: .top, endPoint: .init(x: 0.5, y: 0.35))
                    .ignoresSafeArea(edges: .bottom)
            )
    }
}

/// Nền che vùng giờ/pin khi cuộn (lỗi #052 bản chính).
struct StatusBarScrim: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            Color.clear.frame(height: 0)
                .background(T.bg.opacity(0.96).ignoresSafeArea(edges: .top))
                .allowsHitTesting(false)
        }
    }
}
extension View {
    func statusBarScrim() -> some View { modifier(StatusBarScrim()) }
    func screenBackground() -> some View { background(T.bg.ignoresSafeArea()) }
}

/// Giữ tên component để tương thích callsite; ảnh thật giữ màu tự nhiên.
struct BWPhoto: View {
    var name: String
    var body: some View {
        Image(decorative: name).resizable().scaledToFill()
            .accessibilityHidden(true).allowsHitTesting(false)
    }
}

/// Khung ảnh có chiều cao cố định, ảnh không bao giờ tràn ra ngoài làm vỡ bố cục.
struct PhotoBox: View {
    var name: String
    var height: CGFloat
    var focus: Alignment = .center   // ảnh dọc: dùng .top để không mất đầu người
    var body: some View {
        GeometryReader { geometry in
            BWPhoto(name: name)
                .frame(width: geometry.size.width, height: height, alignment: focus)
                .clipped()
        }
        .frame(height: height)
    }
}

/// Ảnh bìa theo loại buổi tập.
func coverPhoto(for workoutName: String) -> String {
    let n = workoutName.lowercased()
    if n.contains("đẩy") { return "photo-press" }
    if n.contains("kéo") { return "photo-pullup" }
    if n.contains("chân") || n.contains("dưới") { return "photo-legpress" }
    if n.contains("trên") { return "photo-bench" }
    return "photo-deadlift"
}

struct InfoLine: View {
    var icon: String
    var text: String
    var color: Color = T.sub
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon).font(T.font(13, .semibold)).foregroundStyle(color).frame(width: 16)
            Text(text).font(T.font(14)).foregroundStyle(color).bodyLines(14).fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct EmptyState: View {
    var icon: String
    var title: String
    var message: String
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(T.font(28, .semibold)).foregroundStyle(T.faint)
            Text(title).font(T.font(17, .semibold)).foregroundStyle(T.text)
            Text(message).font(T.font(14)).foregroundStyle(T.sub).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 28).padding(.horizontal, 12)
    }
}

/// Đầu bảng trượt: tiêu đề + nút X tròn bên phải (một kiểu cho mọi bảng).
struct SheetHeader: View {
    var title: String
    var subtitle: String? = nil
    var close: () -> Void
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(T.font(22, .bold)).foregroundStyle(T.text)
                if let subtitle { Text(subtitle).font(T.font(14)).foregroundStyle(T.sub).bodyLines(14) }
            }
            Spacer()
            IconButton(icon: "xmark", label: "Đóng", action: close)
        }
        .padding(.horizontal, T.pad).padding(.top, 20).padding(.bottom, 8)
    }
}

/// Tiêu đề nhiều dòng: một kiểu chữ duy nhất (đậm), không in nghiêng.
func Headline(_ s: String, size: CGFloat = 26) -> Text {
    Text(s).font(T.font(size, .bold))
}

extension View {
    /// Tiêu đề một dòng: không xuống hàng, chữ tự thu nhỏ một chút nếu máy hẹp; chừa khoảng thở bên dưới.
    func oneLineTitle(bottom: CGFloat = 8) -> some View {
        lineLimit(1).minimumScaleFactor(0.75).padding(.bottom, bottom)
    }
}

/// Khoảng cách dòng cho tiếng Việt: dấu chồng (ấ, ộ, ữ…) cần thêm chỗ, nhất là ở tiêu đề lớn.
/// Tiêu đề: thêm ~22% cỡ chữ. Chữ thường: thêm ~25% cỡ chữ.
extension View {
    func titleLines(_ size: CGFloat) -> some View { lineSpacing(size * 0.22 * T.scale) }
    func bodyLines(_ size: CGFloat) -> some View { lineSpacing(size * 0.25 * T.scale) }
}

/// Nhãn nhỏ phía trên tiêu đề: chữ thường, màu xám, cùng họ chữ SF với phần còn lại.
struct Eyebrow: View {
    var text: String
    var color: Color = T.sub
    var body: some View {
        Text(text).font(T.font(14, .semibold)).foregroundStyle(color)
    }
}

/// Màn ảnh tràn viền: ảnh chiếm nửa trên, mờ dần vào nền đen, chữ đè lên phần tối.
struct FullBleedStory<Footer: View>: View {
    var photo: String
    var eyebrow: String
    var title: String
    var detail: String
    @ViewBuilder var footer: Footer
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .bottomLeading) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: g.size.height * 0.62)
                        .overlay { PhotoBox(name: photo, height: g.size.height * 0.62, focus: photo.hasPrefix("vn-") ? .trailing : .center) }
                        .clipped()
                        .overlay(LinearGradient(colors: [.clear, .clear, T.bg], startPoint: .top, endPoint: .bottom))
                    Spacer(minLength: 0)
                }
                VStack(alignment: .leading, spacing: 14) {
                    Eyebrow(text: eyebrow)
                    Headline(title).foregroundStyle(T.text).oneLineTitle()
                    Text(detail).font(T.font(16)).foregroundStyle(T.sub).bodyLines(16).fixedSize(horizontal: false, vertical: true)
                    footer
                }
                .padding(.horizontal, T.pad).padding(.bottom, 12)
            }
        }
    }
}

/// Thẻ "Dopafit xử lý": biểu tượng tròn xanh và câu trả lời, cùng kiểu với danh sách trấn an.
struct FixLine: View {
    var text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark").font(T.font(11, .heavy)).foregroundStyle(.black)
                .frame(width: 24, height: 24).background(Circle().fill(T.lime))
            Text(text).font(T.font(15, .medium)).foregroundStyle(T.text).bodyLines(15)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(T.surface.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(T.line))
        .padding(.top, 4)
    }
}

/// Thẻ kiểu "cái cân": tiêu đề, con số lớn + đơn vị xám, dải vạch dọc lấp đầy dần như kim cân, hàng chỉ số nhỏ bên dưới.
struct ScaleCard: View {
    var title: String
    var trailing: String
    var value: String
    var unit: String
    var progress: Double          // 0...1
    var stats: [(String, String)]
    var ticks = 26
    @State private var shown: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title).font(T.font(16, .semibold)).foregroundStyle(T.text)
                Spacer()
                Text(trailing).font(T.font(14)).foregroundStyle(T.sub)
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(value).font(T.num(40, .bold)).foregroundStyle(T.text)
                Text(unit).font(T.font(16)).foregroundStyle(T.sub)
            }
            HStack(spacing: 0) {
                ForEach(0..<ticks, id: \.self) { i in
                    let on = Double(i) < shown * Double(ticks)
                    Capsule()
                        .fill(on ? T.lime : Color.white.opacity(0.12))
                        .frame(width: 4, height: 40)
                        .frame(maxWidth: .infinity)
                        .animation(.easeOut(duration: 0.12).delay(Double(i) * 0.035), value: shown)
                }
            }
            .frame(height: 40)
            .accessibilityElement()
            .accessibilityLabel("\(Int(progress * 100)) phần trăm")
            HStack(spacing: 22) {
                ForEach(Array(stats.enumerated()), id: \.offset) { _, st in
                    HStack(spacing: 5) {
                        Text(st.0).font(T.font(14)).foregroundStyle(T.sub)
                        Text(st.1).font(T.num(14, .semibold)).foregroundStyle(T.text)
                    }
                }
            }
        }
        .padding(18)
        .background(T.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(T.line))
        .task {
            // Lấp dần từng vạch như kim cân đang nhích lên
            shown = 0
            try? await Task.sleep(nanoseconds: 250_000_000)
            shown = progress
        }
    }
}
