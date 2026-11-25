import SwiftUI

/// Local demonstration only. Choosing a budget never changes the profile or check-in.
struct TimeAdaptationStory: View {
    var plan: PlannedWorkout
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var budget: Int? = 20
    @State private var showAdjustment = false
    private var adjusted: PlannedWorkout { showAdjustment && budget != nil ? plan.shortened(to: budget!) : plan }
    private var removed: Int { plan.items.count - adjusted.items.count }
    private var fewerSets: Int {
        adjusted.items.reduce(0) { total, item in
            total + max(0, (plan.items.first { $0.id == item.id }?.sets.count ?? 0) - item.sets.count)
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                QuestionTitle(title: "Bận vẫn có [buổi tập vừa sức].", subtitle: "Buổi tập gọn lại theo thời gian bạn có.")
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hôm nay bạn có bao lâu?").font(T.font(15, .medium)).foregroundStyle(T.sub)
                    HStack(spacing: 8) {
                        choice(20, label: "20 phút")
                        choice(30, label: "30 phút")
                        choice(nil, label: "Đầy đủ")
                    }
                }
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Xem thử buổi đầu").font(T.font(12, .medium)).foregroundStyle(T.sub)
                            Text(plan.name).font(T.font(23, .bold)).foregroundStyle(T.text)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "slider.horizontal.3").font(T.font(20)).foregroundStyle(T.lime).padding(.top, 5).accessibilityHidden(true)
                    }
                    HStack(spacing: 16) {
                        if adjusted.minutes != plan.minutes {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("~\(plan.minutes) phút").font(T.num(20, .semibold)).strikethrough()
                                Text("\(plan.items.count) bài").font(T.font(13))
                            }.foregroundStyle(T.faint)
                            Image(systemName: "arrow.right").font(T.font(17)).foregroundStyle(T.sub).accessibilityHidden(true)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("~\(adjusted.minutes) phút").font(T.num(28, .bold)).foregroundStyle(T.lime).contentTransition(.numericText())
                            Text("\(adjusted.items.count) bài · \(adjusted.items.reduce(0) { $0 + $1.sets.count }) set").font(T.font(13)).foregroundStyle(T.sub)
                        }
                        Spacer(minLength: 0)
                    }.accessibilityElement(children: .combine)
                    HStack(spacing: 5) {
                        ForEach(plan.items) { item in
                            let kept = adjusted.items.contains { $0.id == item.id }
                            Capsule().fill(kept ? T.lime : T.raised).frame(height: 6)
                        }
                    }.accessibilityHidden(true)
                    Divider().overlay(T.line)
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(adjusted.items.enumerated()), id: \.element.id) { index, item in
                            HStack(alignment: .top, spacing: 12) {
                                Text(String(format: "%02d", index + 1)).font(T.num(13, .medium)).foregroundStyle(T.faint).frame(width: 22).padding(.top, 2)
                                Text(item.exercise.name).font(T.font(15, .medium)).foregroundStyle(T.text).fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: 4)
                                Text("\(item.sets.count) set").font(T.font(13)).foregroundStyle(T.sub).fixedSize()
                            }.padding(.vertical, 11)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    if removed > 0 || fewerSets > 0 {
                        Label(adjustmentLabel, systemImage: "arrow.down.right")
                            .font(T.font(13, .medium)).foregroundStyle(T.lime)
                    } else {
                        Text(budget == nil ? "Buổi đầy đủ theo lựa chọn hiện tại." : "Buổi này đã vừa khoảng thời gian bạn có.").font(T.font(13)).foregroundStyle(T.sub)
                    }
                    if let budget, adjusted.minutes > budget {
                        Text("Ước tính còn hơn \(budget) phút. Bạn có thể đổi bài hoặc chỉnh set trước khi tập.")
                            .font(T.font(13)).foregroundStyle(T.sub)
                    }
                }.padding(20).background(T.surface, in: RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(T.line))
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "clock.arrow.2.circlepath").foregroundStyle(T.lime)
                    Text("Mỗi buổi đều có thể chọn lại thời gian.\nĐây là bản xem thử, chưa đổi lịch của bạn.").foregroundStyle(T.sub)
                }.font(T.font(13)).lineSpacing(4)
            }.padding(.horizontal, T.pad).padding(.vertical, 20)
        }.scrollIndicators(.hidden)
            .task {
                guard !reduceMotion else { showAdjustment = true; return }
                do { try await Task.sleep(for: .milliseconds(350)); try Task.checkCancellation() } catch { return }
                withAnimation(.easeInOut(duration: 0.45)) { showAdjustment = true }
            }
    }
    private var adjustmentLabel: String {
        [removed > 0 ? "Lược bớt \(removed) bài" : nil, fewerSets > 0 ? "giảm \(fewerSets) set" : nil].compactMap { $0 }.joined(separator: " · ")
    }
    private func choice(_ minutes: Int?, label: String) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) { budget = minutes; showAdjustment = true }
        } label: {
            Text(label).font(T.font(15, .semibold)).foregroundStyle(budget == minutes ? T.lime : T.text)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(budget == minutes ? T.raised : T.surface, in: Capsule())
                .overlay(Capsule().stroke(budget == minutes ? T.lime.opacity(0.65) : T.line))
        }.buttonStyle(.plain).accessibilityAddTraits(budget == minutes ? .isSelected : [])
            .accessibilityIdentifier("time-preview.\(minutes.map(String.init) ?? "full")")
    }
}
