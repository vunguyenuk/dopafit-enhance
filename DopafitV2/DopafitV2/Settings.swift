import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showPro = false
    @State private var confirmReset = false
    @State private var remindTraining = true
    @State private var remindTrial = true
    @State private var healthProfile = false
    @State private var workoutReport = false
    @State private var healthConnection = false

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Cài đặt") { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    group("Hồ sơ và báo cáo") {
                        Button { healthProfile = true } label: { row("Hồ sơ sức khỏe", nil, chevron: true) }.buttonStyle(.plain)
                        Button { workoutReport = true } label: { row("Báo cáo tập luyện", nil, chevron: true) }.buttonStyle(.plain)
                        Button { healthConnection = true } label: { row("Apple Health", "Chưa kết nối", chevron: true) }.buttonStyle(.plain)
                    }
                    group("Kế hoạch") {
                        menuRow("Mục tiêu", state.data.profile.goal.name, Profile.Goal.allCases.map { g -> (String, () -> Void) in (g.name, { state.data.profile.goal = g }) })
                        menuRow("Kinh nghiệm", state.data.profile.level.name, Profile.Level.allCases.map { g -> (String, () -> Void) in (g.name, { state.data.profile.level = g }) })
                        menuRow("Nơi tập", state.data.profile.place.name, Profile.Place.allCases.map { g -> (String, () -> Void) in (g.name, { state.data.profile.place = g }) })
                        menuRow("Số buổi mỗi tuần", "\(state.data.profile.daysPerWeek) buổi", (2...6).map { d -> (String, () -> Void) in ("\(d) buổi", { state.data.profile.daysPerWeek = d }) })
                        menuRow("Thời lượng", "\(state.data.profile.minutes) phút", [30, 45, 60, 75].map { m -> (String, () -> Void) in ("\(m) phút", { state.data.profile.minutes = m }) })
                        menuRow("Mức tập", state.data.profile.intensity?.name ?? "Theo bài tập", Profile.Intensity.allCases.map { value -> (String, () -> Void) in (value.name, { state.data.profile.intensity = value }) })
                        toggleRow("Chế độ nhẹ nhàng", "Tối đa 5 bài, 2 set mỗi bài, không dùng tạ đòn.", $state.data.gentle)
                    }
                    group("Hồ sơ") {
                        if state.data.profile.recent == .returning {
                            menuRow("Thời gian nghỉ tập", state.data.profile.trainingBreak?.name ?? "Chưa chọn", Profile.TrainingBreak.allCases.map { value -> (String, () -> Void) in (value.name, { state.data.profile.trainingBreak = value }) })
                        }
                        menuRow("Mức độ vận động", state.data.profile.activity?.name ?? "Chưa chọn", Profile.Activity.allCases.map { a -> (String, () -> Void) in (a.name, { state.data.profile.activity = a }) })
                        menuRow("Giới tính", state.data.profile.sex.name, Profile.Sex.allCases.map { g -> (String, () -> Void) in (g.name, { state.data.profile.sex = g }) })
                        menuRow("Tuổi", state.data.profile.age.map { "\($0)" } ?? "Chưa cung cấp", stride(from: 16, through: 80, by: 1).map { (a: Int) -> (String, () -> Void) in ("\(a)", { state.data.profile.age = a }) })
                        menuRow("Cân nặng", Fmt.w(state.data.profile.bodyKg, state.unit), stride(from: 40, through: 150, by: 1).map { k -> (String, () -> Void) in (Fmt.w(Double(k), state.unit), { state.data.profile.bodyKg = Double(k) }) })
                    }
                    if state.data.profile.currentShape != nil || state.data.profile.targetKg != nil {
                        group("Mục tiêu của bạn") {
                            menuRow("Vóc dáng hiện tại", state.data.profile.currentShape?.name ?? "Chưa chọn", Profile.BodyShape.allCases.map { value -> (String, () -> Void) in (value.name, { state.data.profile.currentShape = value }) })
                            menuRow("Vóc dáng hướng tới", state.data.profile.targetShape?.name ?? "Chưa chọn", Profile.BodyGoal.allCases.map { value -> (String, () -> Void) in (value.name, { state.data.profile.targetShape = value }) })
                            menuRow("Cân nặng mục tiêu", state.data.profile.targetKg.map { Fmt.w($0, state.unit) } ?? "Chưa chọn", (35...180).map { value -> (String, () -> Void) in (Fmt.w(Double(value), state.unit), { state.data.profile.targetKg = Double(value) }) })
                            menuRow("Tự thưởng", state.data.profile.reward?.name ?? "Chưa chọn", Profile.Reward.allCases.map { value -> (String, () -> Void) in (value.name, { state.data.profile.reward = value }) })
                            Menu {
                                Button("Toàn thân") { state.data.profile.focusAreas = [] }
                                ForEach(Profile.FocusArea.allCases, id: \.self) { area in
                                    Button((state.data.profile.focusAreas?.contains(area) == true ? "✓ " : "") + area.name) {
                                        var values = state.data.profile.focusAreas ?? []
                                        if values.contains(area) { values.removeAll { $0 == area } }
                                        else if values.count < 3 { values.append(area) }
                                        state.data.profile.focusAreas = values
                                    }
                                }
                            } label: { row("Vùng ưu tiên", (state.data.profile.focusAreas?.isEmpty == false ? state.data.profile.focusAreas?.map(\.name).joined(separator: ", ") : "Toàn thân"), chevron: true) }
                        }
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
                            row("Dopafit Pro", state.data.isPro ? "Pro demo đã bật" : "Xem gói", chevron: true)
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
        .sheet(isPresented: $healthProfile) { HealthProfileScreen() }
        .sheet(isPresented: $workoutReport) { WorkoutReportScreen() }
        .sheet(isPresented: $healthConnection) { HealthConnectionScreen() }
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
