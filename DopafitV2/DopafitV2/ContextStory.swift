import SwiftUI

/// The hero names the filmed exercise; an unplanned same-muscle example is explicitly labelled.
struct PlanMotionHero: View {
    var plan: PlannedWorkout
    var female: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var preview: (file: String, caption: String)? {
        if let item = plan.items.first(where: { Media.userFootage[$0.exerciseID] != nil }),
           let file = Media.guide(item.exercise, female: female) {
            return (file, item.exercise.name)
        }
        // A filmed chest example fits a push workout with dumbbells. It is only
        // a labelled illustration, never a replacement for the prescribed push-up.
        if plan.items.contains(where: { $0.exercise.primary == .chest }),
           plan.items.contains(where: { $0.exercise.gear == .dumbbell }),
           Media.has("plan-dumbbell-bench") {
            return ("plan-dumbbell-bench", "Minh họa · Đẩy ngực với tạ đơn")
        }
        guard let exercise = Media.heroExercise(plan, female: female),
              let file = Media.guide(exercise, female: female) else { return nil }
        return (file, (plan.items.contains { $0.exerciseID == exercise.id } ? "" : "Minh họa · ") + exercise.name)
    }
    var body: some View {
        if let preview {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "video").foregroundStyle(T.lime)
                    Text(preview.caption).foregroundStyle(T.sub)
                }.font(T.font(13, .medium)).lineSpacing(0)
                BWLoopVideo(file: preview.file, gravity: .resizeAspect, playing: !reduceMotion)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}

/// A preview, not a completed workout. All rows come from the current answers.
struct PersonalPlanStory: View {
    var profile: Profile
    var plan: PlannedWorkout
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                QuestionTitle(title: "Biết rõ hôm nay [tập gì].", subtitle: "Bài tập, số set và mức tạ theo lựa chọn của bạn.")
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 9) {
                        Text("Xem trước buổi đầu").font(T.font(13, .medium)).foregroundStyle(T.sub)
                        Text(plan.name).font(T.font(25, .bold)).foregroundStyle(T.text)
                        HStack(spacing: 18) {
                            Label("\(plan.items.count) bài", systemImage: "dumbbell")
                            Label("~\(plan.minutes) phút", systemImage: "clock")
                        }.font(T.font(14, .medium)).foregroundStyle(T.sub)
                    }.padding(20)
                    Divider().overlay(T.line)
                    ForEach(Array(plan.items.prefix(3).enumerated()), id: \.element.id) { i, item in
                        HStack(spacing: 14) {
                            if let file = Media.thumb(item.exercise, female: profile.sex == .female) {
                                BWLoopVideo(file: file, gravity: .resizeAspect, playing: !reduceMotion)
                                    .frame(width: 72, height: 72)
                                    .background(T.bg).clipShape(RoundedRectangle(cornerRadius: 13))
                                    .accessibilityHidden(true).allowsHitTesting(false)
                            }
                            VStack(alignment: .leading, spacing: 7) {
                                Text(item.exercise.name).font(T.font(16, .semibold)).foregroundStyle(T.text).fixedSize(horizontal: false, vertical: true)
                                Text("\(item.sets.count) set · \(item.targetReps) rep")
                                    .font(T.font(14)).foregroundStyle(T.sub)
                            }
                            Spacer(minLength: 0)
                        }.padding(.horizontal, 18).padding(.vertical, 15)
                        if i < min(2, plan.items.count - 1) { Divider().overlay(T.line).padding(.leading, 18) }
                    }
                    if plan.items.count > 3 {
                        Text("+ \(plan.items.count - 3) bài trong buổi tập")
                            .font(T.font(13, .medium)).foregroundStyle(T.sub).padding(.horizontal, 20).padding(.bottom, 18)
                    }
                }.background(T.surface, in: RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(T.line, lineWidth: 1))
                Label("Có thể đổi bài khi cần.", systemImage: "arrow.triangle.2.circlepath")
                    .font(T.font(14)).foregroundStyle(T.sub)
            }.padding(.horizontal, T.pad).padding(.vertical, 20)
        }.scrollIndicators(.hidden)
    }
}

struct ContextStoryPage<Visual: View, Footer: View>: View {
    var eyebrow: String
    var title: String
    var detail: String
    @ViewBuilder var visual: Visual
    @ViewBuilder var footer: Footer
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Eyebrow(text: eyebrow, color: T.sub)
                visual.padding(.vertical, 16)
                Text(title).font(T.font(30, .bold)).foregroundStyle(T.text).fixedSize(horizontal: false, vertical: true)
                Text(detail).font(T.font(16)).foregroundStyle(T.sub)
                footer
            }.padding(.horizontal, T.pad).padding(.vertical, 20)
        }.scrollIndicators(.hidden)
    }
}

/// Product previews are derived from the current answers, not invented performance results.
struct ContextStoryVisual: View {
    var kind: String
    var profile: Profile
    var plan: PlannedWorkout
    var body: some View {
        Group {
            switch kind {
            case "experience": startingLoad
            case "Đau mỏi hoặc chấn thương": pain
            case "Không đủ dụng cụ": equipment
            case "Thiếu động lực": firstSession
            case "Không thấy mình tiến bộ": log
            default: planPreview
            }
        }.frame(maxWidth: .infinity, minHeight: 240)
    }
    private var first: WorkoutItem? { plan.items.first }
    @ViewBuilder private var startingLoad: some View {
        if let first { StartingLoadCard(item: first, unit: profile.unit) }
        else { Text("Chọn bài phù hợp trước khi đặt mức khởi điểm.").font(T.font(16)).foregroundStyle(T.sub) }
    }
    private var planPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(plan.name).font(T.font(22, .bold)).foregroundStyle(T.text)
            ForEach(Array(plan.items.prefix(3).enumerated()), id: \.element.id) { i, item in
                HStack(spacing: 14) {
                    Text(String(format: "%02d", i + 1)).font(T.num(17)).foregroundStyle(T.lime)
                    Text(item.exercise.name).font(T.font(15, .medium)).foregroundStyle(T.text).lineLimit(2)
                    Spacer(minLength: 0)
                    Text("\(item.sets.count) × \(item.targetReps)").font(T.num(14)).foregroundStyle(T.sub)
                }
                if i < min(2, plan.items.count - 1) { Divider().overlay(T.line) }
            }
        }.padding(20).background(T.surface, in: RoundedRectangle(cornerRadius: 22))
    }
    private var pain: some View {
        VStack(spacing: 25) {
            JointGlyph(joint: profile.injuries?.first ?? .shoulder, selected: true).scaleEffect(3).frame(height: 100)
            Text(profile.injuries?.first?.name ?? "Chọn vùng cần tránh dồn lực")
                .font(T.font(20, .semibold)).foregroundStyle(T.text)
            Text("Có thể đổi bài hoặc giảm tải").font(T.font(14)).foregroundStyle(T.sub)
        }
    }
    private var equipment: some View {
        VStack(spacing: 24) {
            HStack(spacing: 24) {
                Image(systemName: "dumbbell").font(.system(size: 62, weight: .light))
                Image(systemName: "house").font(.system(size: 45, weight: .light))
            }.foregroundStyle(T.lime).accessibilityHidden(true)
            Text("Dụng cụ ít. Bài tập vừa đủ.").font(T.font(22, .bold)).foregroundStyle(T.text)
            Text("Chọn nơi tập để lọc bài phù hợp").font(T.font(14)).foregroundStyle(T.sub)
        }
    }
    private var firstSession: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Bắt đầu bằng một buổi").font(T.font(15)).foregroundStyle(T.sub)
            Text(plan.name).font(T.font(28, .bold)).foregroundStyle(T.text)
            HStack(spacing: 24) {
                Label("\(plan.items.count) bài", systemImage: "dumbbell")
                Label("~\(plan.minutes) phút", systemImage: "clock")
            }.font(T.font(16)).foregroundStyle(T.sub)
            HStack { Image(systemName: "play.fill"); Text("Bắt đầu khi bạn sẵn sàng") }
                .font(T.font(15, .semibold)).foregroundStyle(T.lime)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(24)
            .background(T.surface, in: RoundedRectangle(cornerRadius: 24))
    }
    private var log: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(first?.exercise.name ?? plan.name).font(T.font(20, .bold)).foregroundStyle(T.text)
            HStack {
                ForEach(["Set", "Tạ", "Rep"], id: \.self) { label in
                    VStack(spacing: 18) {
                        Text(label).font(T.font(13)).foregroundStyle(T.sub)
                        Text("—").font(T.num(32)).foregroundStyle(T.lime)
                    }.frame(maxWidth: .infinity)
                }
            }
            Divider().overlay(T.line)
            Text("Ghi set đầu để bắt đầu theo dõi").font(T.font(14)).foregroundStyle(T.sub)
        }.padding(24).background(T.surface, in: RoundedRectangle(cornerRadius: 24))
    }
}
