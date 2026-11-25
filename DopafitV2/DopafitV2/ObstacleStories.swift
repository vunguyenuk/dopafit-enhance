import SwiftUI

// Obstacle follow-up stories that still used the old eyebrow + visual + FixLine page.
// Same language as TimeAdaptationStory / PersonalPlanStory: highlighted title,
// one card built from the user's actual preview plan, one quiet footnote.
// Nothing here invents results or changes saved answers.

/// "Không thấy mình tiến bộ": shows the real first prescription and how the
/// app turns logged sets into a comparison and a strength line. No fake history.
struct ProgressTrackingStory: View {
    var profile: Profile
    var plan: PlannedWorkout
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false
    private var item: WorkoutItem? { plan.items.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                QuestionTitle(title: "Thấy rõ mình [mạnh lên].",
                              subtitle: "Cảm giác hay đánh lừa. Dopafit ghi từng set và so với lần trước.")
                if let item { firstSessionCard(item) }
                VStack(alignment: .leading, spacing: 0) {
                    step(1, icon: "square.and.pencil", title: "Ghi tạ và rep sau mỗi set", detail: "Một chạm là xong, không cần sổ.")
                    Divider().overlay(T.line).padding(.leading, 56)
                    step(2, icon: "arrow.up.right", title: "So với lần trước ngay khi tập", detail: "Biết hôm nay nặng hơn hay nhiều rep hơn.")
                    Divider().overlay(T.line).padding(.leading, 56)
                    step(3, icon: "chart.line.uptrend.xyaxis", title: "Đường sức mạnh của từng bài", detail: "Xem mình tiến lên qua từng tuần.")
                }.background(T.surface, in: RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(T.line))
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "info.circle").foregroundStyle(T.lime)
                    Text("Số trên là mức khởi điểm theo lựa chọn của bạn, chưa phải kết quả.").foregroundStyle(T.sub)
                }.font(T.font(13)).lineSpacing(4)
            }.padding(.horizontal, T.pad).padding(.vertical, 20)
        }.scrollIndicators(.hidden)
            .onAppear {
                if reduceMotion { shown = true } else { withAnimation(.easeOut(duration: 0.45).delay(0.15)) { shown = true } }
            }
    }

    private func firstSessionCard(_ item: WorkoutItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                if let file = Media.thumb(item.exercise, female: profile.sex == .female) {
                    BWLoopVideo(file: file, gravity: .resizeAspect, playing: !reduceMotion)
                        .frame(width: 60, height: 60)
                        .background(T.bg).clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityHidden(true).allowsHitTesting(false)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Buổi đầu · \(plan.name)").font(T.font(12, .medium)).foregroundStyle(T.sub)
                    Text(item.exercise.name).font(T.font(17, .semibold)).foregroundStyle(T.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            VStack(spacing: 0) {
                HStack {
                    Text("Set").frame(width: 44, alignment: .leading)
                    Text("Mức tạ").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Rep").frame(width: 56, alignment: .trailing)
                }.font(T.font(12, .medium)).foregroundStyle(T.faint).padding(.bottom, 8)
                ForEach(Array(item.sets.enumerated()), id: \.element.id) { index, entry in
                    setRow(index: index, entry: entry, item: item)
                }
            }
            Label("Lần sau, app so với các set này", systemImage: "arrow.up.right")
                .font(T.font(13, .medium)).foregroundStyle(T.lime)
        }.padding(20).background(T.surface, in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(T.line))
    }

    private func setRow(index: Int, entry: LoggedSet, item: WorkoutItem) -> some View {
        let weight: String = item.exercise.bodyweightOnly ? "Không tạ" : Fmt.w(entry.weightKg, profile.unit)
        let delay: Double = 0.15 + Double(index) * 0.08
        return HStack {
            Text(verbatim: "\(index + 1)").font(T.num(15, .medium)).foregroundStyle(T.sub)
                .frame(width: 44, alignment: .leading)
            Text(verbatim: weight).font(T.num(17, .semibold)).foregroundStyle(T.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(verbatim: "\(item.targetReps)").font(T.num(17, .semibold)).foregroundStyle(T.text)
                .frame(width: 56, alignment: .trailing)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .top) { Divider().overlay(T.line) }
        .opacity(shown ? 1 : 0).offset(y: shown ? 0 : 6)
        .animation(reduceMotion ? nil : Animation.easeOut(duration: 0.35).delay(delay), value: shown)
        .accessibilityElement(children: .combine)
    }

    private func step(_ n: Int, icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon).font(.system(size: 17, weight: .semibold)).foregroundStyle(T.lime)
                .frame(width: 26, height: 26).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(T.font(15, .semibold)).foregroundStyle(T.text)
                Text(detail).font(T.font(13)).foregroundStyle(T.sub)
            }.fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }.padding(.horizontal, 16).padding(.vertical, 14).accessibilityElement(children: .combine)
    }
}

/// "Không đủ dụng cụ": pick a place and see the actual preview plan rebuilt for
/// that equipment. Local preview only; the place question comes later.
struct EquipmentAdaptationStory: View {
    var profile: Profile
    var planFor: (Profile.Place) -> PlannedWorkout
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var place: Profile.Place = .home
    @State private var cached: PlannedWorkout?
    private var plan: PlannedWorkout { cached ?? planFor(place) }

    var body: some View {
        let plan = plan
        let gear = Array(Set(plan.items.map(\.exercise.gear))).sorted { $0.rawValue < $1.rawValue }
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                QuestionTitle(title: "Có gì tập nấy, [vẫn đủ bài].",
                              subtitle: "Chọn nơi tập, app chỉ xếp bài làm được với dụng cụ ở đó.")
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bạn thường tập ở đâu?").font(T.font(15, .medium)).foregroundStyle(T.sub)
                    HStack(spacing: 8) {
                        choice(.fullGym, label: "Gym đầy đủ")
                        choice(.smallGym, label: "Gym nhỏ")
                        choice(.home, label: "Ở nhà")
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Xem thử buổi đầu · \(place.name)").font(T.font(12, .medium)).foregroundStyle(T.sub)
                        Text(plan.name).font(T.font(23, .bold)).foregroundStyle(T.text)
                        GearChips(items: gear.map(\.name))
                    }.padding(20)
                    Divider().overlay(T.line)
                    ForEach(Array(plan.items.prefix(3).enumerated()), id: \.element.id) { i, item in
                        HStack(spacing: 14) {
                            if let file = Media.thumb(item.exercise, female: profile.sex == .female) {
                                BWLoopVideo(file: file, gravity: .resizeAspect, playing: !reduceMotion)
                                    .frame(width: 60, height: 60)
                                    .background(T.bg).clipShape(RoundedRectangle(cornerRadius: 12))
                                    .accessibilityHidden(true).allowsHitTesting(false)
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Text(item.exercise.name).font(T.font(15, .semibold)).foregroundStyle(T.text)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(item.exercise.gear.name).font(T.font(13)).foregroundStyle(T.sub)
                            }
                            Spacer(minLength: 0)
                        }.padding(.horizontal, 18).padding(.vertical, 13)
                            .accessibilityElement(children: .combine)
                        if i < min(2, plan.items.count - 1) { Divider().overlay(T.line).padding(.leading, 18) }
                    }
                    if plan.items.count > 3 {
                        Text("+ \(plan.items.count - 3) bài trong buổi tập")
                            .font(T.font(13, .medium)).foregroundStyle(T.sub).padding(.horizontal, 20).padding(.bottom, 18)
                    }
                }.id(place)
                    .transition(.opacity)
                    .background(T.surface, in: RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(T.line))
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "house").foregroundStyle(T.lime)
                    Text("Bản xem thử. Bạn sẽ chọn nơi tập ở bước sau, đổi lúc nào cũng được.").foregroundStyle(T.sub)
                }.font(T.font(13)).lineSpacing(4)
            }.padding(.horizontal, T.pad).padding(.vertical, 20)
        }.scrollIndicators(.hidden)
            .onAppear { if cached == nil { place = profile.place; cached = planFor(profile.place) } }
    }

    private func choice(_ value: Profile.Place, label: String) -> some View {
        Button {
            guard value != place else { return }
            let next = planFor(value)
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) { place = value; cached = next }
        } label: {
            Text(label).font(T.font(15, .semibold)).foregroundStyle(place == value ? T.lime : T.text)
                .lineLimit(1).minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(place == value ? T.raised : T.surface, in: Capsule())
                .overlay(Capsule().stroke(place == value ? T.lime.opacity(0.65) : T.line))
        }.buttonStyle(.plain).accessibilityAddTraits(place == value ? .isSelected : [])
            .accessibilityIdentifier("equipment-preview.\(value.rawValue)")
    }
}

/// Small wrapping row of equipment chips.
private struct GearChips: View {
    var items: [String]
    var body: some View {
        GearChipFlow(spacing: 6) {
            ForEach(items, id: \.self) { name in
                Text(name).font(T.font(12, .medium)).foregroundStyle(T.text)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(T.raised, in: Capsule())
            }
        }
    }
}

private struct GearChipFlow: Layout {
    var spacing: CGFloat
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, row: CGFloat = 0, widest: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width { x = 0; y += row + spacing; row = 0 }
            x += size.width + spacing; row = max(row, size.height); widest = max(widest, x - spacing)
        }
        return CGSize(width: min(widest, width), height: y + row)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, row: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX { x = bounds.minX; y += row + spacing; row = 0 }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing; row = max(row, size.height)
        }
    }
}
