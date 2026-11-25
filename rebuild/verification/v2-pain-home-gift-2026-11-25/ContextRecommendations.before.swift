import SwiftUI

/// An honest preview of eligible strength exercises, not a rehabilitation diagnosis.
struct ContextRecommendations: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var profile: Profile
    var plan: PlannedWorkout
    var pain: Bool
    @State private var guide: Exercise?
    @State private var appeared = false
    private var joints: [Joint] { profile.injuries ?? [] }
    private var exercises: [Exercise] {
        pain ? state.onboardingSuggestions(profile: profile) : Array(plan.items.prefix(3).map(\.exercise))
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                QuestionTitle(title: pain ? "Tập vừa sức, [đúng vùng]." : "Bắt đầu bằng [một buổi].",
                              subtitle: pain ? "Gợi ý theo vùng bạn muốn tránh dồn lực." : "Không cần làm thật nhiều. Bắt đầu với những bài này.")
                if pain {
                    if joints.isEmpty {
                        Label("Chưa chọn vùng đau", systemImage: "figure.stand")
                            .font(T.font(16, .medium)).foregroundStyle(T.sub)
                    } else {
                        // All selected regions, never a fallback shoulder or the first joint only.
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(joints) { joint in
                                    HStack(spacing: 12) {
                                        JointGlyph(joint: joint, selected: true)
                                        Text(joint.name).font(T.font(16, .semibold)).foregroundStyle(T.text)
                                    }.padding(14).background(T.surface, in: RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }.scrollIndicators(.hidden)
                    }
                    if joints.contains(.lowerBack) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Vận động nhẹ trước").font(T.font(19, .semibold)).foregroundStyle(T.text)
                            Label("Đi bộ nhẹ trong khả năng", systemImage: "figure.walk")
                            Label("Nghiêng chậu nhẹ khi nằm", systemImage: "figure.cooldown")
                            Text("Thử chậm trong tầm thoải mái. Dừng nếu đau tăng hoặc xuất hiện đau mới.")
                                .font(T.font(13)).foregroundStyle(T.sub)
                        }.font(T.font(15)).foregroundStyle(T.text)
                    }
                } else {
                    HStack {
                        Text(plan.name).font(T.font(22, .bold)).foregroundStyle(T.text)
                        Spacer()
                        Label("~\(plan.minutes) phút", systemImage: "clock").font(T.font(14)).foregroundStyle(T.sub)
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text(pain ? "Bài sức mạnh có thể cân nhắc" : "Xem trước bài tập")
                        .font(T.font(18, .semibold)).foregroundStyle(T.text)
                    if exercises.isEmpty {
                        Text("Chưa có bài khớp với dụng cụ và vùng đã chọn. Bạn có thể đổi vùng hoặc nơi tập ở bước xem lại.")
                            .font(T.font(15)).foregroundStyle(T.sub)
                    }
                    ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                        Button { guide = exercise } label: {
                            HStack(spacing: 14) {
                                if let file = Media.thumb(exercise, female: profile.sex == .female) {
                                    BWLoopVideo(file: file, gravity: .resizeAspect, playing: !reduceMotion)
                                        .frame(width: 78, height: 78).background(T.bg)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .allowsHitTesting(false).accessibilityHidden(true)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(exercise.name).font(T.font(16, .semibold)).foregroundStyle(T.text)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(exercise.primary.name + " · " + exercise.gear.name)
                                        .font(T.font(13)).foregroundStyle(T.sub)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right").font(T.font(13, .semibold)).foregroundStyle(T.sub)
                            }.padding(14).frame(maxWidth: .infinity, alignment: .leading)
                                .background(T.surface, in: RoundedRectangle(cornerRadius: 20))
                                .contentShape(RoundedRectangle(cornerRadius: 20))
                        }.buttonStyle(.plain)
                            .accessibilityIdentifier("onboarding.suggestion.\(exercise.id)")
                            .opacity(appeared || reduceMotion ? 1 : 0)
                            .offset(y: appeared || reduceMotion ? 0 : 12)
                            .animation(reduceMotion ? nil : .easeOut(duration: 0.35).delay(Double(index) * 0.09), value: appeared)
                    }
                }
                if pain {
                    Text("Đây là gợi ý tập sức mạnh, không phải liệu trình giảm đau. Đang chấn thương? Hỏi chuyên viên trước khi tập.")
                        .font(T.font(13)).foregroundStyle(T.sub)
                    if joints.contains(.lowerBack) {
                        Link("Hướng dẫn vận động lưng · NHS", destination: URL(string: "https://www.nhsinform.scot/illnesses-and-conditions/muscle-bone-and-joints/neck-and-back-problems-and-conditions/exercises-for-back-pain/")!)
                            .font(T.font(13, .medium)).foregroundStyle(T.lime)
                    }
                } else {
                    Text("Ghi set đầu tiên để bắt đầu theo dõi tiến bộ.").font(T.font(14)).foregroundStyle(T.sub)
                }
            }.padding(.horizontal, T.pad).padding(.top, 16).padding(.bottom, 24)
        }.scrollIndicators(.hidden).onAppear { appeared = true }
            .sheet(item: $guide) { exercise in GuideSheet(exercise: exercise, femaleOverride: profile.sex == .female) }
    }
}
