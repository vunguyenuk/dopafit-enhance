import SwiftUI

struct StrengthOverview: View {
    @EnvironmentObject var state: AppState
    @State private var help = false
    @State private var group: MuscleGroup?
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Sức mạnh tổng").font(T.font(20, .bold)).foregroundStyle(T.text)
                Spacer()
                IconButton(icon: "info.circle", label: "Về điểm sức mạnh") { help = true }
            }
            HStack(spacing: 6) {
                Text("—").font(T.num(40)).foregroundStyle(T.sub).padding(.trailing, 6)
                ForEach(0..<10, id: \.self) { _ in ScoreSlice().fill(T.raised).frame(height: 29) }
            }.accessibilityElement(children: .ignore).accessibilityLabel("Chưa có điểm sức mạnh tổng")
            Text("Theo dõi sức mạnh từng bài bên dưới.").font(T.font(13)).foregroundStyle(T.sub)
            HStack(spacing: 10) {
                ForEach([MuscleGroup.push, .pull, .legs], id: \.self) { item in
                    let lifts = state.trackedLifts.filter { $0.primary.group == item }
                    Button { group = item } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(item.name).font(T.font(14, .semibold)).foregroundStyle(T.text)
                            Text("\(lifts.count) bài").font(T.num(20)).foregroundStyle(lifts.isEmpty ? T.sub : T.lime)
                            Image(systemName: "chevron.right").font(T.font(11)).foregroundStyle(T.faint)
                        }.frame(maxWidth: .infinity, minHeight: 84, alignment: .leading).padding(14)
                            .background(T.surface, in: RoundedRectangle(cornerRadius: 18))
                    }.buttonStyle(.plain).accessibilityLabel("\(item.name), \(lifts.count) bài có dữ liệu sức mạnh")
                }
            }
        }.sheet(isPresented: $help) {
            VStack(alignment: .leading, spacing: 20) {
                SheetHeader(title: "Sức mạnh tổng") { help = false }
                Text("Điểm Dopafit chưa khả dụng trong bản demo. Các biểu đồ 1RM bên dưới dùng set thực tế bạn đã ghi, không cần thử nâng tối đa.").font(T.font(16)).foregroundStyle(T.sub).padding(.horizontal, T.pad)
                Spacer()
            }.background(T.bg.ignoresSafeArea()).presentationDetents([.medium])
        }.sheet(isPresented: Binding(get: { group != nil }, set: { if !$0 { group = nil } })) {
            if let group { StrengthGroupScreen(group: group) }
        }
    }
}

private struct ScoreSlice: Shape {
    func path(in r: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: r.width * 0.35, y: 0)); p.addLine(to: CGPoint(x: r.width, y: 0))
            p.addLine(to: CGPoint(x: r.width * 0.65, y: r.height)); p.addLine(to: CGPoint(x: 0, y: r.height)); p.closeSubpath()
        }
    }
}

struct StrengthGroupScreen: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var group: MuscleGroup
    var body: some View {
        let exercises = state.trackedLifts.filter { $0.primary.group == group }
        VStack(spacing: 0) {
            SheetHeader(title: group.name, subtitle: "1RM ước tính từ các set đã hoàn thành") { dismiss() }
            ScrollView {
                VStack(spacing: 14) {
                    if exercises.isEmpty { EmptyState(icon: "dumbbell", title: "Chưa có số liệu", message: "Ghi một set có tạ cho nhóm này để bắt đầu theo dõi.") }
                    ForEach(exercises) { exercise in LiftCard(exercise: exercise) }
                }.padding(T.pad)
            }
        }.background(T.bg.ignoresSafeArea())
    }
}

struct RecoveryMuscleListScreen: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selected: Muscle?
    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Hồi phục nhóm cơ", subtitle: "Ước tính từ những set bạn đã hoàn thành") { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(MuscleGroup.allCases, id: \.self) { group in
                        SectionTitle(title: group.name)
                        ForEach(Muscle.allCases.filter { $0.group == group }) { muscle in
                            Button { selected = muscle } label: {
                                HStack(spacing: 14) {
                                    MuscleMiniMap(muscle: muscle, tint: state.readiness(muscle) < 0.8 ? T.rest : T.sub).frame(width: 30, height: 52)
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(muscle.name).font(T.font(16, .semibold)).foregroundStyle(T.text)
                                            Spacer()
                                            Text("\(Int(state.readiness(muscle) * 100))%").font(T.num(14, .semibold)).foregroundStyle(T.sub)
                                        }
                                        ProgressView(value: state.readiness(muscle)).tint(state.readiness(muscle) < 0.8 ? T.rest : T.lime)
                                    }
                                    Image(systemName: "chevron.right").font(T.font(11)).foregroundStyle(T.faint)
                                }.padding(14).background(T.surface, in: RoundedRectangle(cornerRadius: 18))
                            }.buttonStyle(.plain).accessibilityLabel(muscle.name)
                                .accessibilityValue("\(Int(state.readiness(muscle) * 100))%")
                        }
                    }
                }.padding(T.pad)
            }
        }.background(T.bg.ignoresSafeArea()).sheet(item: $selected) { RecoveryMuscleScreen(muscle: $0) }
    }
}

struct RecoveryMuscleScreen: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var muscle: Muscle
    var body: some View {
        let recent = state.completedSessions().filter { Date().timeIntervalSince($0.started) < 72 * 3600 && $0.items.contains { ($0.exercise.primary == muscle || $0.exercise.secondary.contains(muscle)) && $0.sets.contains(where: \.done) } }
        VStack(spacing: 0) {
            SheetHeader(title: muscle.name, subtitle: "Hồi phục ước tính") { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 28) {
                        MuscleMiniMap(muscle: muscle, tint: T.rest).frame(width: 76, height: 134)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(Int(state.readiness(muscle) * 100))%").font(T.num(43)).foregroundStyle(T.text)
                            Text(state.readiness(muscle) < 0.8 ? "Khoảng \(state.hoursUntilReady(muscle)) giờ để sẵn sàng" : "Sẵn sàng tập").font(T.font(14)).foregroundStyle(T.sub)
                        }
                    }
                    Text("Các buổi trong 72 giờ qua").font(T.font(18, .semibold)).foregroundStyle(T.text)
                    if recent.isEmpty { Text("Chưa có set gần đây cho nhóm cơ này.").font(T.font(15)).foregroundStyle(T.sub) }
                    ForEach(recent) { session in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(session.name).font(T.font(16, .semibold)).foregroundStyle(T.text)
                            Text(Fmt.day(session.started)).font(T.font(13)).foregroundStyle(T.sub)
                            ForEach(session.items.filter { $0.exercise.primary == muscle || $0.exercise.secondary.contains(muscle) }) { item in
                                Text("\(item.exercise.name) · \(item.sets.filter(\.done).count) set").font(T.font(14)).foregroundStyle(T.sub)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(T.surface, in: RoundedRectangle(cornerRadius: 18))
                    }
                    Text("Mức hồi phục chỉ để tham khảo, tính từ số set và thời gian đã qua.").font(T.font(13)).foregroundStyle(T.sub)
                }.padding(T.pad)
            }
        }.background(T.bg.ignoresSafeArea())
    }
}
