import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showPro = false
    @State private var confirmReset = false
    @State private var remindTraining = true
    @State private var remindTrial = true

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Cài đặt") { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    group("Kế hoạch") {
                        menuRow("Mục tiêu", state.data.profile.goal.name, Profile.Goal.allCases.map { g -> (String, () -> Void) in (g.name, { state.data.profile.goal = g }) })
                        menuRow("Kinh nghiệm", state.data.profile.level.name, Profile.Level.allCases.map { g -> (String, () -> Void) in (g.name, { state.data.profile.level = g }) })
                        menuRow("Nơi tập", state.data.profile.place.name, Profile.Place.allCases.map { g -> (String, () -> Void) in (g.name, { state.data.profile.place = g }) })
                        menuRow("Số buổi mỗi tuần", "\(state.data.profile.daysPerWeek) buổi", (2...6).map { d -> (String, () -> Void) in ("\(d) buổi", { state.data.profile.daysPerWeek = d }) })
                        menuRow("Thời lượng", "\(state.data.profile.minutes) phút", [30, 45, 60, 75].map { m -> (String, () -> Void) in ("\(m) phút", { state.data.profile.minutes = m }) })
                        toggleRow("Chế độ nhẹ nhàng", "Tối đa 5 bài, 2 set mỗi bài, không dùng tạ đòn.", $state.data.gentle)
                    }
                    group("Hồ sơ") {
                        menuRow("Giới tính", state.data.profile.sex.name, Profile.Sex.allCases.map { g -> (String, () -> Void) in (g.name, { state.data.profile.sex = g }) })
                        menuRow("Tuổi", "\(state.data.profile.age)", stride(from: 16, through: 80, by: 1).map { a -> (String, () -> Void) in ("\(a)", { state.data.profile.age = a }) })
                        menuRow("Cân nặng", Fmt.w(state.data.profile.bodyKg, state.unit), stride(from: 40, through: 150, by: 1).map { k -> (String, () -> Void) in (Fmt.w(Double(k), state.unit), { state.data.profile.bodyKg = Double(k) }) })
                    }
                    group("Hiển thị") {
                        menuRow("Đơn vị tạ", state.unit.label, WeightUnit.allCases.map { u -> (String, () -> Void) in (u.label, { state.data.profile.unit = u }) })
                        menuRow("Cỡ chữ", scaleName(state.data.textScale), [(1.0, "Vừa"), (1.15, "Lớn"), (1.3, "Rất lớn")].map { v -> (String, () -> Void) in (v.1, { state.data.textScale = v.0 }) })
                    }
                    group("Thông báo") {
                        toggleRow("Nhắc ngày tập", "Lúc 18:00 vào những ngày bạn có buổi tập.", $remindTraining)
                        toggleRow("Nhắc trước khi hết dùng thử", "Một ngày trước khi tính phí gói Pro.", $remindTrial)
                    }
                    group("Gói") {
                        Button { showPro = true } label: {
                            row("Dopafit Pro", state.data.isPro ? "Đang dùng thử" : "Xem gói", chevron: true)
                        }.buttonStyle(.plain)
                    }
                    group("Dữ liệu") {
                        Button { state.loadDemo() } label: { row("Nạp dữ liệu mẫu", "12 buổi", chevron: false) }.buttonStyle(.plain)
                        Button { state.data.onboarded = false; dismiss() } label: { row("Làm lại phần thiết lập", nil, chevron: true) }.buttonStyle(.plain)
                        Button { confirmReset = true } label: {
                            Text("Xóa toàn bộ dữ liệu trên máy").font(T.font(16, .medium)).foregroundStyle(T.warn)
                                .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 14)
                        }.buttonStyle(.plain)
                    }
                    Text("Dopafit V2 · bản demo. Video động tác chưa có bản quyền thương mại, chỉ dùng thử nghiệm.")
                        .font(T.font(12)).foregroundStyle(T.faint)
                }
                .padding(.horizontal, T.pad).padding(.bottom, 30)
            }
        }
        .background(T.bg.ignoresSafeArea())
        .sheet(isPresented: $showPro) { ProPaywall(firstTime: false).environmentObject(state) }
        .alert("Xóa toàn bộ dữ liệu?", isPresented: $confirmReset) {
            Button("Xóa vĩnh viễn", role: .destructive) { state.data = AppData(); dismiss() }
            Button("Hủy", role: .cancel) {}
        } message: { Text("Lịch sử tập, hồ sơ và cài đặt sẽ bị xóa khỏi máy này. Không hoàn tác được.") }
    }

    private func scaleName(_ v: Double) -> String { v >= 1.3 ? "Rất lớn" : (v >= 1.15 ? "Lớn" : "Vừa") }

    private func group<C: View>(_ title: String, @ViewBuilder _ content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(T.font(14, .semibold)).foregroundStyle(T.sub)
            VStack(spacing: 0) { content() }
                .padding(.horizontal, 16)
                .background(T.surface)
                .clipShape(RoundedRectangle(cornerRadius: T.radius, style: .continuous))
        }
    }

    private func row(_ title: String, _ value: String?, chevron: Bool) -> some View {
        HStack {
            Text(title).font(T.font(16)).foregroundStyle(T.text)
            Spacer()
            if let value { Text(value).font(T.font(15)).foregroundStyle(T.sub) }
            if chevron { Image(systemName: "chevron.right").font(T.font(12, .bold)).foregroundStyle(T.faint) }
        }
        .frame(minHeight: 50)
        .contentShape(Rectangle())
    }

    private func menuRow(_ title: String, _ value: String, _ options: [(String, () -> Void)]) -> some View {
        Menu {
            ForEach(Array(options.enumerated()), id: \.offset) { _, o in Button(o.0, action: o.1) }
        } label: {
            HStack {
                Text(title).font(T.font(16)).foregroundStyle(T.text)
                Spacer()
                Text(value).font(T.font(15)).foregroundStyle(T.sub)
                Image(systemName: "chevron.up.chevron.down").font(T.font(11, .bold)).foregroundStyle(T.faint)
            }
            .frame(minHeight: 50)
            .contentShape(Rectangle())
        }
    }

    private func toggleRow(_ title: String, _ detail: String, _ binding: Binding<Bool>) -> some View {
        Toggle(isOn: binding) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(T.font(16)).foregroundStyle(T.text)
                Text(detail).font(T.font(13)).foregroundStyle(T.sub)
            }
        }
        .tint(T.lime)
        .padding(.vertical, 10)
    }
}

/// Màn Pro: nút đóng hiện ngay, cả hai gói đều thấy, không có màn ưu đãi thứ hai hay đồng hồ đếm ngược.
struct ProPaywall: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var firstTime: Bool
    @State private var yearly = true
    @State private var showOffer = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    PhotoBox(name: "photo-curl", height: 300, focus: .top)
                        .overlay(LinearGradient(colors: [.clear, T.bg], startPoint: .center, endPoint: .bottom))
                    VStack(alignment: .leading, spacing: 18) {
                        Eyebrow(text: "Dopafit Pro")
                        Text("Plan mạnh nhất khi có Pro.").font(T.font(26, .bold)).foregroundStyle(T.text).oneLineTitle()
                        VStack(alignment: .leading, spacing: 12) {
                            InfoLine(icon: "checkmark", text: "Tự tăng tạ khi bạn đủ rep, tự giảm khi bạn mệt hoặc đau.", color: T.text)
                            InfoLine(icon: "checkmark", text: "Sức mạnh từng bài và hồi phục từng nhóm cơ.", color: T.text)
                            InfoLine(icon: "checkmark", text: "Đổi bài trong một chạm khi máy đang có người.", color: T.text)
                        }
                        plan(title: "Gói năm", price: "79,99 US$ / năm", note: "Khoảng 6,67 US$ mỗi tháng", selected: yearly) { yearly = true }
                        plan(title: "Gói tháng", price: "9,99 US$ / tháng", note: "Hủy lúc nào cũng được", selected: !yearly) { yearly = false }
                        Text("Dùng thử miễn phí 3 ngày. App nhắc bạn 1 ngày trước khi tính phí. Hủy trong Cài đặt của iPhone trước khi hết dùng thử thì không mất tiền.")
                            .font(T.font(13)).foregroundStyle(T.sub)
                    }
                    .padding(.horizontal, T.pad)
                }
                .padding(.bottom, 20)
            }
            .ignoresSafeArea(edges: .top)
            IconButton(icon: "xmark", label: "Đóng") { close() }
                .padding(.trailing, T.pad).padding(.top, 8)
        }
        .screenBackground()
        .sheet(isPresented: $showOffer, onDismiss: { if firstTime { state.data.sawPro = true } }) {
            OneTimeOffer().environmentObject(state).presentationDetents([.medium])
        }
        .safeAreaInset(edge: .bottom) {
            BottomBar {
                PrimaryButton(title: "Dùng thử 3 ngày") {
                    state.data.isPro = true
                    close()
                }
                Text("Bản demo: chưa kết nối thanh toán, không trừ tiền.").font(T.font(12)).foregroundStyle(T.faint)
            }
        }
    }

    private func close() {
        if firstTime && state.data.sawOffer != true {
            state.data.sawOffer = true
            showOffer = true
        } else if firstTime {
            state.data.sawPro = true
        } else {
            dismiss()
        }
    }

    private func plan(title: String, price: String, note: String, selected: Bool, pick: @escaping () -> Void) -> some View {
        Button(action: pick) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(T.font(16, .semibold)).foregroundStyle(T.text)
                    Text(note).font(T.font(13)).foregroundStyle(T.sub)
                }
                Spacer()
                Text(price).font(T.num(16, .bold)).foregroundStyle(T.text)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle").font(T.font(22)).foregroundStyle(selected ? T.lime : T.faint)
            }
            .padding(16)
            .background(T.surface)
            .clipShape(RoundedRectangle(cornerRadius: T.radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: T.radius, style: .continuous).stroke(selected ? T.lime.opacity(0.7) : T.line, lineWidth: selected ? 1.5 : 1))
        }
        .buttonStyle(.plain)
    }
}

/// Ưu đãi cho người mới: chỉ hiện MỘT lần khi đóng màn Pro, không đếm ngược.
struct OneTimeOffer: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SheetHeader(title: "Ưu đãi cho người mới", subtitle: "Chỉ hiện một lần. Gói thường vẫn mua được bất cứ lúc nào.") { dismiss() }
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("39,99 US$").font(T.num(40)).foregroundStyle(T.lime)
                Text("/ năm").font(T.font(16, .semibold)).foregroundStyle(T.sub)
                Text("79,99").font(T.num(16, .semibold)).strikethrough().foregroundStyle(T.faint)
            }
            .padding(.horizontal, T.pad)
            Text("Vẫn dùng thử 3 ngày trước. Gia hạn các năm sau vẫn giữ giá này.").font(T.font(14)).foregroundStyle(T.sub).padding(.horizontal, T.pad)
            Spacer()
            BottomBar {
                PrimaryButton(title: "Dùng thử với giá ưu đãi") { state.data.isPro = true; dismiss() }
                Button("Để sau") { dismiss() }.font(T.font(15, .medium)).foregroundStyle(T.sub).frame(height: 40)
            }
        }
        .background(T.bg.ignoresSafeArea())
    }
}
