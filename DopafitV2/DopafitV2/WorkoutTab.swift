import SwiftUI

struct WorkoutTab: View {
    @EnvironmentObject var state: AppState
    @State private var showCheckIn = false
    @State private var showSettings = false
    @State private var showAdd = false
    @State private var guide: Exercise? = nil
    @State private var swapFor: Exercise? = nil

    var body: some View {
        let plan = state.plan
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                Card { hero(plan) }
                Card(padding: 14) { WeekStrip() }
                if let d = state.daysSinceLast, (3...13).contains(d), state.data.checkIn == .fine {
                    comeback(d)
                }
                if state.data.checkIn != .fine { adjustedBanner(plan) }
                SectionTitle(title: "Bài tập", trailing: "Thêm bài") { showAdd = true }
                LazyVStack(spacing: 10) {
                    ForEach(plan.items) { item in
                        ExerciseRow(item: item, unit: state.unit,
                                    onGuide: { guide = item.exercise },
                                    onSwap: { swapFor = item.exercise },
                                    onRemove: { remove(item.exercise) })
                    }
                }
                if plan.items.isEmpty {
                    Card { EmptyState(icon: "dumbbell", title: "Chưa có bài nào", message: "Bấm “Thêm bài” để tự chọn, hoặc đổi nơi tập trong Cài đặt.") }
                }
            }
            .padding(.horizontal, T.pad)
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
        .screenBackground()
        .statusBarScrim()
        .safeAreaInset(edge: .bottom) {
            BottomBar {
                PrimaryButton(title: "Bắt đầu buổi tập", icon: "play.fill", enabled: !plan.items.isEmpty) { state.start(plan) }
            }
        }
        .sheet(isPresented: $showCheckIn) { CheckInSheet().environmentObject(state).presentationDetents([.medium, .large]) }
        .sheet(isPresented: $showSettings) { SettingsView().environmentObject(state) }
        .sheet(isPresented: $showAdd) { AddExerciseSheet().environmentObject(state) }
        .sheet(item: $guide) { ex in GuideSheet(exercise: ex).environmentObject(state) }
        .sheet(item: $swapFor) { ex in SwapSheet(exercise: ex).environmentObject(state).presentationDetents([.medium, .large]) }
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                DopafitMark().fill(T.lime).frame(width: 28, height: 18)
                Text("Dopafit").font(T.font(23, .bold)).foregroundStyle(T.text)
            }
            Spacer()
            IconButton(icon: "gearshape", label: "Cài đặt") { showSettings = true }
        }
        .padding(.top, 8)
    }

    private func hero(_ plan: PlannedWorkout) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(state.data.profile.name.isEmpty ? "Hôm nay" : "Hôm nay của \(state.data.profile.name)")
                        .font(T.font(13, .medium)).foregroundStyle(T.sub)
                    Text(plan.name).font(T.font(28, .bold)).foregroundStyle(T.text)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(plan.focus).font(T.font(13)).foregroundStyle(T.sub)
                    Text((plan.items.isEmpty ? "" : "~\(plan.minutes) phút · ") + "\(plan.items.count) bài · \(plan.items.reduce(0) { $0 + $1.sets.count }) set")
                        .font(T.font(14, .medium)).foregroundStyle(T.sub)
                        .fixedSize(horizontal: false, vertical: true)
                }.frame(maxWidth: .infinity, alignment: .leading)
                if let exercise = Media.heroExercise(plan, female: state.data.profile.sex == .female) {
                    HomeMotionPreview(exercise: exercise, female: state.data.profile.sex == .female)
                }
            }
            if let exercise = Media.heroExercise(plan, female: state.data.profile.sex == .female) {
                Text((plan.items.contains { $0.exerciseID == exercise.id } ? "Video · " : "Minh họa · ") + exercise.name)
                    .font(T.font(13)).foregroundStyle(T.sub)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    Button { showCheckIn = true } label: {
                        Chip(icon: state.data.checkIn.icon, title: state.data.checkIn.title, highlighted: state.data.checkIn != .fine)
                            .frame(minHeight: 44).contentShape(Rectangle())
                    }.buttonStyle(.plain).accessibilityLabel("Hôm nay thế nào? " + state.data.checkIn.title)
                    Menu {
                        ForEach([30, 45, 60, 75], id: \.self) { m in
                            Button("\(m) phút") { state.data.profile.minutes = m }
                        }
                    } label: { Chip(icon: "clock", title: "\(state.data.profile.minutes) phút").frame(minHeight: 44).contentShape(Rectangle()) }
                    Menu {
                        ForEach(Profile.Place.allCases, id: \.self) { p in
                            Button(p.name) { state.data.profile.place = p }
                        }
                    } label: { Chip(icon: state.data.profile.place.icon, title: placeLabel).frame(minHeight: 44).contentShape(Rectangle()) }
                }
            }.scrollIndicators(.hidden)
            if state.data.checkIn == .fine && !plan.items.isEmpty {
                Rectangle().fill(T.line).frame(height: 1)
                Text(shortReasons(plan)).font(T.font(13)).foregroundStyle(T.sub)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// Copy-only shortening; preserve the plan's actual reasons and numeric values.
    private func shortReasons(_ plan: PlannedWorkout) -> String {
        plan.reasons.map { reason in
            if reason == "tạ khởi điểm theo kinh nghiệm của bạn" { return "Tạ theo kinh nghiệm" }
            if reason == "ưu tiên nhóm cơ bạn chọn trong lịch hôm nay" {
                let muscles = Set(plan.items.map { $0.exercise.primary })
                let names = (state.data.profile.focusAreas ?? []).filter { !muscles.isDisjoint(with: $0.muscles) }.map { $0.name.lowercased() }
                return names.isEmpty ? "Theo vùng cơ ưu tiên" : "Ưu tiên " + names.joined(separator: ", ")
            }
            return reason.capitalizedFirst
        }.joined(separator: " · ")
    }

    private var placeLabel: String {
        switch state.data.profile.place {
        case .fullGym: "Gym đầy đủ"
        case .smallGym: "Gym nhỏ"
        case .home: "Ở nhà"
        }
    }

    private func comeback(_ d: Int) -> some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(d) ngày rồi chưa tập").font(T.font(17, .semibold)).foregroundStyle(T.text)
                Text("Không sao. Làm bản 20 phút hôm nay để lấy lại nhịp, hoặc tập đủ như kế hoạch.").font(T.font(14)).foregroundStyle(T.sub)
                HStack(spacing: 10) {
                    Button { state.setCheckIn(.short(20)) } label: {
                        Text("Làm bản 20 phút").font(T.font(15, .semibold)).foregroundStyle(.black)
                            .padding(.horizontal, 16).frame(height: 40).background(T.lime).clipShape(Capsule())
                    }.buttonStyle(.plain)
                }
            }
        }
    }

    private func adjustedBanner(_ plan: PlannedWorkout) -> some View {
        HStack(spacing: 10) {
            Image(systemName: state.data.checkIn.icon).foregroundStyle(T.lime)
            Text(shortReasons(plan))
                .font(T.font(14)).foregroundStyle(T.text)
            Spacer(minLength: 4)
            Button("Hoàn tác") { withAnimation { state.setCheckIn(.fine) } }
                .font(T.font(14, .semibold)).foregroundStyle(T.lime)
        }
        .padding(14)
        .background(T.lime.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func remove(_ ex: Exercise) {
        if let i = state.data.added.firstIndex(of: ex.id) { state.data.added.remove(at: i) }
        else { state.data.removed.append(ex.id) }
        state.touchPlan()
    }
}

/// A Home-only compact preview; the full-width overview and exercise guides stay unchanged.
private struct HomeMotionPreview: View {
    var exercise: Exercise
    var female: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        if let file = Media.guide(exercise, female: female) {
            BWLoopVideo(file: file, gravity: .resizeAspect, playing: !reduceMotion)
                .frame(width: 128, height: 86).background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Hàng bài tập

struct ExerciseRow: View {
    var item: WorkoutItem
    var unit: WeightUnit
    var onGuide: () -> Void
    var onSwap: () -> Void
    var onRemove: () -> Void

    var body: some View {
        let ex = item.exercise
        HStack(spacing: 14) {
            if Media.thumb(ex) != nil {
                Button(action: onGuide) { ExerciseTile(exercise: ex, size: 64) }
                    .buttonStyle(.plain).accessibilityLabel("Hướng dẫn " + ex.name)
            }
            VStack(alignment: .leading, spacing: 4) {
                Button(action: onGuide) {
                    Text(ex.name).font(T.font(16, .semibold)).foregroundStyle(T.text)
                        .multilineTextAlignment(.leading).lineLimit(2)
                }.buttonStyle(.plain)
                Text(prescription).font(T.num(14, .semibold)).foregroundStyle(T.sub)
                if let c = item.change {
                    Text(c).font(T.font(13, .medium)).foregroundStyle(T.lime).lineLimit(2)
                }
            }
            Spacer(minLength: 0)
            Menu {
                Button { onGuide() } label: { Label("Hướng dẫn & lịch sử", systemImage: "play.rectangle") }
                Button { onSwap() } label: { Label("Máy đang có người – đổi bài", systemImage: "arrow.triangle.2.circlepath") }
                Button(role: .destructive) { onRemove() } label: { Label("Bỏ khỏi buổi hôm nay", systemImage: "minus.circle") }
            } label: {
                Image(systemName: "ellipsis").font(T.font(16, .bold)).foregroundStyle(T.sub)
                    .frame(width: 44, height: 44).contentShape(Rectangle())
            }
            .accessibilityLabel("Tùy chọn bài " + ex.name)
        }
        .padding(14)
        .background(T.surface, in: RoundedRectangle(cornerRadius: T.radius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: T.radius, style: .continuous).stroke(T.line, lineWidth: 1))

    }

    private var prescription: String {
        let ex = item.exercise
        let s = item.sets.first
        var t = "\(item.sets.count) set × \(item.targetReps) rep"
        if let s, !ex.bodyweightOnly { t += " · " + Fmt.w(s.weightKg, unit) }
        if ex.perSide && !ex.bodyweightOnly { t += " mỗi tay" }
        return t
    }
}

// MARK: - Lịch tuần

struct WeekStrip: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        let cal = Calendar.vn
        let start = cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let days = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
        let done = state.sessions(inWeekOf: Date()).count
        let goal = state.data.profile.daysPerWeek
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(done)").font(T.num(20, .semibold)).foregroundStyle(done >= goal ? T.lime : T.text)
                Text("/ \(goal) buổi tuần này").font(T.font(14, .medium)).foregroundStyle(T.sub)
            }
            HStack(spacing: 4) {
                ForEach(days, id: \.self) { d in
                    let trained = state.trained(on: d)
                    let today = cal.isDateInToday(d)
                    VStack(spacing: 6) {
                        Text(weekday(d)).font(T.font(12, .medium)).foregroundStyle(today ? T.text : T.sub)
                        ZStack {
                            Circle().fill(trained ? T.lime : .clear)
                            if trained {
                                Image(systemName: "checkmark").font(T.font(13, .bold)).foregroundStyle(.black)
                            } else {
                                Text("\(cal.component(.day, from: d))").font(T.num(14, .semibold)).foregroundStyle(today ? T.text : T.sub)
                            }
                        }
                        .frame(width: 38, height: 38)
                        .overlay(Circle().stroke(today ? Color.white : Color.clear, lineWidth: 1.5))
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Fmt.day(d) + (trained ? ", đã tập" : ""))
                }
            }
        }
    }
    private func weekday(_ d: Date) -> String {
        let w = Calendar.vn.component(.weekday, from: d)
        return w == 1 ? "CN" : "T\(w)"
    }
}

// MARK: - Hôm nay thế nào?

struct CheckInSheet: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var mode = 0
    @State private var joints: Set<Joint> = []
    @State private var minutes = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SheetHeader(title: "Hôm nay thế nào?", subtitle: "App chỉnh buổi tập hôm nay. Hoàn tác được bất cứ lúc nào.") { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    option(0, "face.smiling", "Khỏe", "Tập đúng kế hoạch")
                    option(1, "battery.25", "Hơi mệt", "Bớt 1 set mỗi bài, giảm 10% tạ")
                    option(2, "bandage", "Đang đau một chỗ", "Đổi hoặc giảm những bài dồn lực vào chỗ đó")
                    if mode == 2 {
                        FlowChips(items: Joint.allCases.map { ($0.id, $0.name) }, selected: Set(joints.map(\.id))) { id in
                            if let j = Joint(rawValue: id) { if joints.contains(j) { joints.remove(j) } else { joints.insert(j) } }
                        }
                        .padding(.vertical, 4)
                        InfoLine(icon: "exclamationmark.triangle", text: "Đau nhói, tê hoặc sưng thì dừng tập và đi khám. App chỉ đổi bài, không thay lời khuyên y tế.", color: T.warn)
                    }
                    option(3, "timer", "Ít thời gian", "Gói buổi tập cho vừa")
                    if mode == 3 {
                        HStack(spacing: 8) {
                            ForEach([15, 20, 30, 45], id: \.self) { m in
                                Button { minutes = m } label: {
                                    Text("\(m) phút").font(T.font(15, .semibold))
                                        .frame(maxWidth: .infinity).frame(height: 44)
                                        .foregroundStyle(minutes == m ? Color.black : T.text)
                                        .background(minutes == m ? Color.white : T.raised).clipShape(Capsule())
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, T.pad)
                .padding(.bottom, 12)
            }
            BottomBar {
                PrimaryButton(title: "Áp dụng", enabled: mode != 2 || !joints.isEmpty) {
                    switch mode {
                    case 1: state.setCheckIn(.tired)
                    case 2: state.setCheckIn(.pain(Joint.allCases.filter { joints.contains($0) }))
                    case 3: state.setCheckIn(.short(minutes))
                    default: state.setCheckIn(.fine)
                    }
                    dismiss()
                }
            }
        }
        .background(T.bg.ignoresSafeArea())
        .onAppear {
            switch state.data.checkIn {
            case .fine: mode = 0
            case .tired: mode = 1
            case .pain(let j): mode = 2; joints = Set(j)
            case .short(let m): mode = 3; minutes = m
            }
        }
    }

    private func option(_ i: Int, _ icon: String, _ title: String, _ detail: String) -> some View {
        Button { withAnimation(.snappy) { mode = i } } label: {
            HStack(spacing: 14) {
                Image(systemName: icon).font(T.font(18, .semibold)).foregroundStyle(mode == i ? T.lime : T.sub).frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(T.font(16, .semibold)).foregroundStyle(T.text)
                    Text(detail).font(T.font(13)).foregroundStyle(T.sub)
                }
                Spacer()
                Image(systemName: mode == i ? "checkmark.circle.fill" : "circle").font(T.font(20)).foregroundStyle(mode == i ? T.lime : T.faint)
            }
            .padding(14)
            .background(T.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(mode == i ? T.lime.opacity(0.6) : T.line))
        }
        .buttonStyle(.plain)
    }
}

struct FlowChips: View {
    var items: [(String, String)]
    var selected: Set<String>
    var toggle: (String) -> Void
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
            ForEach(items, id: \.0) { item in
                Button { toggle(item.0) } label: {
                    Text(item.1).font(T.font(15, .semibold))
                        .frame(maxWidth: .infinity).frame(height: 42)
                        .foregroundStyle(selected.contains(item.0) ? Color.black : T.text)
                        .background(selected.contains(item.0) ? Color.white : T.raised)
                        .clipShape(Capsule())
                }.buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Đổi bài

struct SwapSheet: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var exercise: Exercise
    var body: some View {
        let alts = state.alternatives(for: exercise)
        VStack(alignment: .leading, spacing: 0) {
            SheetHeader(title: "Đổi bài", subtitle: "Cùng tập \(exercise.primary.name.lowercased()), ưu tiên dụng cụ khác \(exercise.gear.name.lowercased()).") { dismiss() }
            ScrollView {
                VStack(spacing: 10) {
                    if alts.isEmpty {
                        EmptyState(icon: "arrow.triangle.2.circlepath", title: "Chưa có bài thay", message: "Với dụng cụ ở \(state.data.profile.place.name.lowercased()), chưa có bài nào khác cho nhóm cơ này.")
                    }
                    ForEach(alts) { alt in
                        Button {
                            if let i = state.data.added.firstIndex(of: exercise.id) { state.data.added[i] = alt.id }
                            else { state.data.swaps[exercise.id] = alt.id }
                            state.touchPlan()
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                ExerciseTile(exercise: alt, size: 56)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(alt.name).font(T.font(16, .semibold)).foregroundStyle(T.text)
                                    Text(alt.gear.name).font(T.font(13)).foregroundStyle(T.sub)
                                }
                                Spacer()
                                Image(systemName: "arrow.right.circle").font(T.font(20)).foregroundStyle(T.sub)
                            }
                            .padding(12).background(T.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, T.pad).padding(.bottom, 20)
            }
        }
        .background(T.bg.ignoresSafeArea())
    }
}

// MARK: - Thêm bài

struct AddExerciseSheet: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var muscle: Muscle? = nil

    var body: some View {
        let list = Catalog.all.filter { ex in
            state.availableGear.contains(ex.gear)
            && (muscle == nil || ex.primary == muscle)
            && (query.isEmpty || ex.name.localizedCaseInsensitiveContains(query) || ex.english.localizedCaseInsensitiveContains(query))
        }
        VStack(alignment: .leading, spacing: 0) {
            SheetHeader(title: "Thêm bài", subtitle: "Chỉ hiện bài làm được ở \(state.data.profile.place.name.lowercased()).") { dismiss() }
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(T.sub)
                TextField("Tìm bài (tiếng Việt hoặc tiếng Anh)", text: $query).font(T.font(16))
            }
            .padding(.horizontal, 14).frame(height: 46).background(T.surface).clipShape(Capsule())
            .padding(.horizontal, T.pad).padding(.bottom, 10)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    filterChip(nil, "Tất cả")
                    ForEach(Muscle.allCases.filter { m in Catalog.all.contains { $0.primary == m } }) { m in filterChip(m, m.name) }
                }.padding(.horizontal, T.pad)
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 10)
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(list) { ex in
                        Button {
                            if !state.data.added.contains(ex.id) { state.data.added.append(ex.id) }
                            state.data.removed.removeAll { $0 == ex.id }
                            state.touchPlan()
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                ExerciseTile(exercise: ex, size: 56)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(ex.name).font(T.font(16, .semibold)).foregroundStyle(T.text)
                                    Text(ex.primary.name + " · " + ex.gear.name).font(T.font(13)).foregroundStyle(T.sub)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill").font(T.font(22)).foregroundStyle(T.lime)
                            }
                            .padding(12).background(T.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }.buttonStyle(.plain)
                    }
                    if list.isEmpty {
                        EmptyState(icon: "magnifyingglass", title: "Không tìm thấy", message: "Thử từ khóa khác hoặc chọn “Tất cả”.")
                    }
                }
                .padding(.horizontal, T.pad).padding(.bottom, 20)
            }
        }
        .background(T.bg.ignoresSafeArea())
    }

    private func filterChip(_ m: Muscle?, _ title: String) -> some View {
        Button { muscle = m } label: {
            Text(title).font(T.font(14, .semibold)).padding(.horizontal, 14).frame(height: 36)
                .foregroundStyle(muscle == m ? T.lime : T.text)
                .background(muscle == m ? T.raised : T.surface).clipShape(Capsule())
        }.buttonStyle(.plain)
    }
}

// MARK: - Hướng dẫn & lịch sử

struct GuideSheet: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var exercise: Exercise
    var femaleOverride: Bool? = nil

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: exercise.name, subtitle: exercise.english) { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let g = Media.guide(exercise, female: femaleOverride ?? (state.data.profile.sex == .female)) {
                        BWLoopVideo(file: g, gravity: .resizeAspect)
                            .aspectRatio(1, contentMode: .fit)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: T.radius, style: .continuous))
                    }
                    HStack(spacing: 8) {
                        tag(exercise.primary.name, strong: true)
                        ForEach(exercise.secondary, id: \.self) { tag($0.name) }
                        tag(exercise.gear.name)
                    }
                    if !exercise.setup.isEmpty {
                        GuideList(title: "Chuẩn bị trước khi tập", items: exercise.setup, icon: "wrench.and.screwdriver")
                    }
                    if !exercise.mistakes.isEmpty {
                        GuideList(title: "Lỗi hay gặp", items: exercise.mistakes, icon: "exclamationmark.circle")
                    }
                    history
                }
                .padding(.horizontal, T.pad).padding(.bottom, 24)
            }
        }
        .background(T.bg.ignoresSafeArea())
    }

    private func tag(_ t: String, strong: Bool = false) -> some View {
        Text(t).font(T.font(13, .semibold)).padding(.horizontal, 10).frame(height: 28)
            .foregroundStyle(strong ? Color.black : T.text)
            .background(strong ? Color.white : T.raised).clipShape(Capsule())
    }

    private var history: some View {
        let rows = state.sortedHistory.compactMap { s -> (Session, WorkoutItem)? in
            guard let it = s.items.first(where: { $0.exerciseID == exercise.id && $0.sets.contains(where: \.done) }) else { return nil }
            return (s, it)
        }
        let best = state.bestE1RM(exercise.id)
        return VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Lịch sử")
            if !exercise.bodyweightOnly && best > 0 {
                Card {
                    BigStat(value: Fmt.wValue(best, state.unit), unit: state.unit.label, label: "Ước tính nâng được 1 lần (tính từ set tốt nhất)", accent: true)
                }
            }
            if rows.isEmpty {
                Card { EmptyState(icon: "clock.arrow.circlepath", title: "Chưa có lần tập nào", message: "Ghi lại bài này trong một buổi tập, kết quả sẽ hiện ở đây.") }
            }
            ForEach(Array(rows.prefix(6).enumerated()), id: \.offset) { _, row in
                Card(padding: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Fmt.day(row.0.started)).font(T.font(13, .medium)).foregroundStyle(T.sub)
                        Text(row.1.sets.filter(\.done).map { exercise.bodyweightOnly ? "\($0.reps) rep" : "\(Fmt.wValue($0.weightKg, state.unit)) × \($0.reps)" }.joined(separator: "   "))
                            .font(T.num(15, .semibold)).foregroundStyle(T.text)
                    }
                }
            }
        }
    }
}

struct GuideList: View {
    var title: String
    var items: [String]
    var icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon).font(T.font(16, .semibold)).foregroundStyle(T.text)
            ForEach(Array(items.enumerated()), id: \.offset) { i, t in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(i + 1)").font(T.num(13, .bold)).foregroundStyle(.black).frame(width: 22, height: 22).background(Color.white).clipShape(Circle())
                    Text(t).font(T.font(15)).foregroundStyle(T.sub).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
