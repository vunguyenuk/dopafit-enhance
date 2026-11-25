import SwiftUI

/// Review the answers actually collected by this flow. Editing stays in a draft
/// until Apply; it never jumps through stories or restarts the commitment gesture.
struct SetupReviewStep: View {
    var profile: Profile
    var desires: [String]
    var obstacles: [String]
    var injuries: [Joint]
    var plan: PlannedWorkout
    var edit: (OnboardingFlow.Step) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                QuestionTitle(title: "Plan theo [lựa chọn của bạn].", subtitle: "Kiểm tra một lượt. Chạm vào mục cần sửa.")
                    .padding(.bottom, -12)
                HStack(spacing: 14) {
                    Image(systemName: "checkmark").font(T.font(20, .semibold)).foregroundStyle(T.lime)
                        .frame(width: 48, height: 48).background(T.raised, in: RoundedRectangle(cornerRadius: 14))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(plan.name).font(T.font(21, .bold)).foregroundStyle(T.text)
                        Text("\(plan.items.count) bài · ~\(plan.minutes) phút").font(T.font(14)).foregroundStyle(T.sub)
                    }
                    Spacer(minLength: 0)
                }
                reviewGroup("Mục tiêu & cơ thể") {
                    row("Giới tính", profile.sex.name, "person", .sex)
                    row("Mục tiêu chính", profile.goal.name, "scope", .goal)
                    row("Điều bạn mong muốn", desireNames, "sparkles", .desire)
                    row("Vùng cơ ưu tiên", joined(profile.focusAreas?.map(\.name) ?? [], empty: "Toàn thân"), "figure.stand", .focus)
                    row("Vóc dáng hiện tại", profile.currentShape?.name ?? "Chưa chọn", "person.crop.rectangle", .currentShape)
                    row("Vóc dáng hướng tới", profile.targetShape?.name ?? "Cân đối, khỏe khoắn", "figure.strengthtraining.traditional", .targetShape)
                    row("Cân nặng hiện tại", Fmt.w(profile.bodyKg, profile.unit), "scalemass", .weight)
                    row("Cân nặng mục tiêu", profile.targetKg.map { Fmt.w($0, profile.unit) } ?? "Chưa chọn", "flag", .targetWeight, last: true)
                }
                reviewGroup("Cách bạn tập") {
                    row("Mức vận động", profile.activity?.name ?? "Chưa chọn", "figure.walk", .activity)
                    row("Kinh nghiệm", profile.level.name, "calendar", .level)
                    row("Nhịp tập gần đây", recentDetail, "arrow.clockwise", .recent)
                    row("Chỗ cần lưu ý", joined(injuries.map(\.name), empty: "Không đau chỗ nào"), "bandage", .injuries)
                    row("Điều hay cản trở", joined(obstacles, empty: "Đã bỏ qua"), "questionmark.circle", .obstacles)
                    row("Tự thưởng", profile.reward?.name ?? "Đã bỏ qua", "gift", .reward, last: true)
                }
                reviewGroup("Lịch tập của bạn") {
                    row("Nơi tập", profile.place.name, profile.place.icon, .place)
                    row("Nhịp & thời lượng", "\(profile.daysPerWeek) buổi/tuần · \(profile.minutes) phút", "calendar.badge.clock", .schedule)
                    row("Buổi đầu", profile.firstDay.map(Fmt.day) ?? "Hôm nay", "calendar.badge.checkmark", .promise)
                    row("Giờ nhắc buổi đầu", profile.reminderHour.map { String(format: "%02d:00", $0) } ?? "Không nhắc", "bell", .reminder, last: true)
                }
                Label("Lưu trên máy này. Đồng bộ tài khoản chưa kết nối.", systemImage: "iphone")
                    .font(T.font(13)).foregroundStyle(T.sub).fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 8)
            }.padding(.horizontal, T.pad).padding(.bottom, 20)
        }.scrollIndicators(.hidden)
    }

    private var desireNames: String {
        joined(desires.map { key in OnboardingFlow.desireList.first { $0.0 == key }?.1.replacingOccurrences(of: "\n", with: " ") ?? key }, empty: "Chưa chọn")
    }
    private var recentDetail: String {
        let name = profile.recent?.name ?? "Chưa tập đều bao giờ"
        guard profile.recent == .returning, let duration = profile.trainingBreak else { return name }
        return name + " · " + duration.name
    }
    private func joined(_ values: [String], empty: String) -> String { values.isEmpty ? empty : values.joined(separator: ", ") }

    private func reviewGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(T.font(17, .semibold)).foregroundStyle(T.text)
            VStack(spacing: 0, content: content)
                .background(T.surface, in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(T.line))
        }
    }
    private func row(_ title: String, _ value: String, _ icon: String, _ target: OnboardingFlow.Step, last: Bool = false) -> some View {
        VStack(spacing: 0) {
            Button { edit(target) } label: {
                HStack(alignment: .center, spacing: 14) {
                    Image(systemName: icon).font(T.font(19, .medium)).foregroundStyle(T.sub)
                        .frame(width: 24).accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).font(T.font(12, .medium)).foregroundStyle(T.sub)
                        Text(value).font(T.font(15, .semibold)).foregroundStyle(T.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "pencil").font(T.font(14)).foregroundStyle(T.sub).accessibilityHidden(true)
                }.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .padding(.horizontal, 16).padding(.vertical, 12).contentShape(Rectangle())
            }.buttonStyle(.plain).accessibilityElement(children: .ignore)
                .accessibilityLabel("Sửa \(title): \(value)")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("onboarding.review.\(String(describing: target))")
            if !last { Divider().overlay(T.line).padding(.leading, 54) }
        }
    }
}
