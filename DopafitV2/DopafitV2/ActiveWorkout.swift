import SwiftUI

struct ActiveWorkoutView: View {
    @EnvironmentObject var state: AppState
    @State private var confirmDiscard = false
    @State private var confirmFinish = false
    @State private var editing: EditTarget? = nil
    @State private var showPlates = false
    @State private var showTips = true

    struct EditTarget: Identifiable {
        var id: String { "\(item)-\(set)-\(isWeight)" }
        var item: Int
        var set: Int
        var isWeight: Bool
    }

    var body: some View {
        if let a = state.active, a.items.indices.contains(a.current) {
            content(a)
        } else {
            T.bg.ignoresSafeArea()
        }
    }

    private func content(_ a: ActiveWorkout) -> some View {
        let item = a.items[a.current]
        let ex = item.exercise
        return VStack(spacing: 0) {
            topBar(a)
            pager(a)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let g = Media.guide(ex) {
                        BWLoopVideo(file: g, gravity: .resizeAspect)
                            .frame(height: 230).frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: T.radius, style: .continuous))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bài \(a.current + 1)/\(a.items.count)").font(T.font(14, .semibold)).foregroundStyle(T.sub)
                        Text(ex.name).font(T.font(24, .bold)).foregroundStyle(T.text)
                        HStack(spacing: 6) {
                            Text("\(item.targetReps) rep mỗi set")
                            if let note = ex.weightNote { Text("· tạ " + note) }
                        }
                        .font(T.font(14)).foregroundStyle(T.sub)
                    }
                    if showSetupTips(ex) { setupTips(ex) }
                    VStack(spacing: 8) {
                        HStack {
                            Text("SET").frame(width: 40, alignment: .leading)
                            if !ex.bodyweightOnly { Text("TẠ (\(state.unit.label.uppercased()))").frame(maxWidth: .infinity) }
                            Text("REP").frame(maxWidth: .infinity)
                            Color.clear.frame(width: 52, height: 1)
                        }
                        .font(T.font(11, .bold)).foregroundStyle(T.faint)
                        ForEach(item.sets.indices, id: \.self) { j in
                            setRow(a.current, j, item.sets[j], ex)
                        }
                    }
                    if let warn = sanityWarning(item, ex) {
                        InfoLine(icon: "exclamationmark.triangle", text: warn, color: T.warn)
                    }
                    HStack(spacing: 10) {
                        smallButton("Thêm set", "plus") { addSet() }
                        if ex.gear == .barbell { smallButton("Tính bánh tạ", "circle.grid.2x1") { showPlates = true } }
                    }
                    if let last = state.lastItem(for: ex.id) {
                        InfoLine(icon: "clock.arrow.circlepath", text: "Lần trước: " + last.sets.filter(\.done).map { ex.bodyweightOnly ? "\($0.reps)" : "\(Fmt.wValue($0.weightKg, state.unit))×\($0.reps)" }.joined(separator: ", "))
                    }
                }
                .padding(.horizontal, T.pad).padding(.top, 12).padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .screenBackground()
        .safeAreaInset(edge: .bottom) { bottom(a) }
        .alert("Bỏ buổi tập này?", isPresented: $confirmDiscard) {
            Button("Bỏ buổi tập", role: .destructive) { state.active = nil }
            Button("Tập tiếp", role: .cancel) {}
        } message: { Text("Các set đã ghi trong buổi này sẽ không được lưu.") }
        .alert("Kết thúc buổi tập?", isPresented: $confirmFinish) {
            if doneCount(a) > 0 {
                Button("Lưu buổi tập") { finish() }
            } else {
                Button("Thoát không lưu", role: .destructive) { state.active = nil }
            }
            Button("Tập tiếp", role: .cancel) {}
        } message: {
            Text(doneCount(a) > 0 ? "Đã ghi \(doneCount(a)) set. Các set chưa đánh dấu sẽ không được lưu." : "Chưa có set nào được đánh dấu xong nên không có gì để lưu.")
        }
        .sheet(item: $editing) { t in
            NumberEditSheet(target: t, unit: state.unit).environmentObject(state).presentationDetents([.height(320)])
        }
        .sheet(isPresented: $showPlates) {
            PlateSheet(totalKg: item.sets.first(where: { !$0.done })?.weightKg ?? item.sets.last?.weightKg ?? 20, unit: state.unit)
                .presentationDetents([.medium])
        }
    }

    // MARK: Thanh trên

    private func topBar(_ a: ActiveWorkout) -> some View {
        HStack {
            IconButton(icon: "xmark", label: "Bỏ buổi tập") { confirmDiscard = true }
            Spacer()
            VStack(spacing: 0) {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text(Fmt.duration(Int(Date().timeIntervalSince(a.started)))).font(T.num(20, .bold)).foregroundStyle(T.text)
                }
                Text(a.name).font(T.font(12)).foregroundStyle(T.sub)
            }
            Spacer()
            Button { confirmFinish = true } label: {
                Text("Kết thúc").font(T.font(15, .semibold)).foregroundStyle(T.text)
                    .padding(.horizontal, 16).frame(height: 40)
                    .overlay(Capsule().stroke(Color.white.opacity(0.3)))
            }.buttonStyle(.plain)
        }
        .padding(.horizontal, T.pad).padding(.vertical, 8)
    }

    private func pager(_ a: ActiveWorkout) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(a.items.indices, id: \.self) { i in
                        let it = a.items[i]
                        let complete = it.sets.allSatisfy(\.done)
                        Button { state.active?.current = i } label: {
                            ZStack(alignment: .bottomTrailing) {
                                ExerciseTile(exercise: it.exercise, size: 52)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(i == a.current ? Color.white : Color.clear, lineWidth: 2))
                                if complete {
                                    Image(systemName: "checkmark.circle.fill").font(T.font(16)).foregroundStyle(T.lime)
                                        .background(Circle().fill(Color.black)).offset(x: 4, y: 4)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .id(i)
                        .accessibilityLabel("Bài \(i + 1): \(it.exercise.name)" + (complete ? ", xong" : ""))
                    }
                }
                .padding(.horizontal, T.pad).padding(.vertical, 6)
            }
            .scrollIndicators(.hidden)
            .onChange(of: a.current) { _, c in withAnimation { proxy.scrollTo(c, anchor: .center) } }
        }
    }

    // MARK: Hàng set

    private func setRow(_ i: Int, _ j: Int, _ s: LoggedSet, _ ex: Exercise) -> some View {
        HStack(spacing: 8) {
            Text("\(j + 1)").font(T.num(17, .bold)).foregroundStyle(s.done ? T.lime : T.sub).frame(width: 40, alignment: .leading)
            if !ex.bodyweightOnly {
                ValueStepper(value: Fmt.wValue(s.weightKg, state.unit), dimmed: s.done,
                             minus: { change(i, j) { $0.weightKg = max(ex.gear == .barbell ? 20 : 0, $0.weightKg - state.unit.toKg(state.unit.step)) } },
                             plus: { change(i, j) { $0.weightKg = min(400, $0.weightKg + state.unit.toKg(state.unit.step)) } },
                             tap: { editing = EditTarget(item: i, set: j, isWeight: true) })
            }
            ValueStepper(value: "\(s.reps)", dimmed: s.done,
                         minus: { change(i, j) { $0.reps = max(1, $0.reps - 1) } },
                         plus: { change(i, j) { $0.reps = min(100, $0.reps + 1) } },
                         tap: { editing = EditTarget(item: i, set: j, isWeight: false) })
            Button { toggleDone(i, j) } label: {
                Image(systemName: "checkmark").font(T.font(18, .bold))
                    .foregroundStyle(s.done ? Color.black : T.sub)
                    .frame(width: 52, height: 52)
                    .background(s.done ? T.lime : T.raised)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(s.done ? "Bỏ đánh dấu set \(j + 1)" : "Xong set \(j + 1)")
        }
        .padding(8)
        .background(T.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func change(_ i: Int, _ j: Int, _ f: (inout LoggedSet) -> Void) {
        guard var a = state.active else { return }
        f(&a.items[i].sets[j])
        a.items[i].sets[j].edited = true
        state.active = a
    }

    private func toggleDone(_ i: Int, _ j: Int) {
        guard var a = state.active else { return }
        a.items[i].sets[j].done.toggle()
        if a.items[i].sets[j].done {
            let s = a.items[i].sets[j]
            // Tự điền tạ & rep sang các set sau chưa sửa (giữ từ bản chính, #070)
            for k in a.items[i].sets.indices where k > j && !a.items[i].sets[k].done && !a.items[i].sets[k].edited {
                a.items[i].sets[k].weightKg = s.weightKg
                a.items[i].sets[k].reps = s.reps
            }
            let rest = a.items[i].exercise.restSeconds
            a.restTotal = rest
            a.restEnds = Date().addingTimeInterval(TimeInterval(rest))
            if a.items[i].sets.allSatisfy(\.done), let next = a.items.indices.first(where: { $0 > i && !a.items[$0].sets.allSatisfy(\.done) }) {
                a.current = next
            }
        }
        state.active = a
    }

    private func addSet() {
        guard var a = state.active else { return }
        let base = a.items[a.current].sets.last ?? LoggedSet(weightKg: 0, reps: a.items[a.current].targetReps)
        a.items[a.current].sets.append(LoggedSet(weightKg: base.weightKg, reps: base.reps))
        state.active = a
    }

    private func doneCount(_ a: ActiveWorkout) -> Int { a.items.reduce(0) { $0 + $1.sets.filter(\.done).count } }

    private func finish() {
        if let s = state.finish() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { state.lastFinished = s }
        }
    }

    /// Chặn số vô lý (lỗi #089/#091 của bản chính): cảnh báo khi tạ cao bất thường so với lần trước.
    private func sanityWarning(_ item: WorkoutItem, _ ex: Exercise) -> String? {
        guard !ex.bodyweightOnly else { return nil }
        let maxW = item.sets.map(\.weightKg).max() ?? 0
        if let last = state.lastItem(for: ex.id), let lastTop = last.sets.filter(\.done).map(\.weightKg).max(), lastTop > 0, maxW > lastTop * 1.5 {
            return "Mức \(Fmt.w(maxW, state.unit)) cao hơn nhiều so với lần trước (\(Fmt.w(lastTop, state.unit))). Kiểm tra lại số trước khi lưu."
        }
        if maxW >= 300 { return "Mức tạ này rất cao. Kiểm tra lại số trước khi lưu." }
        return nil
    }

    // MARK: Hướng dẫn chuẩn bị cho người mới

    private func showSetupTips(_ ex: Exercise) -> Bool {
        !ex.setup.isEmpty && (state.data.profile.level == .new || state.lastItem(for: ex.id) == nil)
    }

    private func setupTips(_ ex: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button { withAnimation(.snappy) { showTips.toggle() } } label: {
                HStack {
                    Label("Lần đầu tập bài này? Chuẩn bị nhanh", systemImage: "wrench.and.screwdriver").font(T.font(15, .semibold)).foregroundStyle(T.text)
                    Spacer()
                    Image(systemName: showTips ? "chevron.up" : "chevron.down").foregroundStyle(T.sub)
                }
            }.buttonStyle(.plain)
            if showTips {
                ForEach(Array(ex.setup.enumerated()), id: \.offset) { _, t in
                    InfoLine(icon: "checkmark", text: t)
                }
            }
        }
        .padding(14)
        .background(T.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func smallButton(_ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon).font(T.font(14, .semibold)).foregroundStyle(T.text)
                .padding(.horizontal, 14).frame(height: 40).background(T.raised).clipShape(Capsule())
        }.buttonStyle(.plain)
    }

    // MARK: Thanh dưới: đồng hồ nghỉ hoặc bài kế tiếp

    private func bottom(_ a: ActiveWorkout) -> some View {
        BottomBar {
            if let ends = a.restEnds, ends > Date() {
                TimelineView(.periodic(from: .now, by: 0.5)) { _ in
                    let left = max(0, Int(ends.timeIntervalSinceNow.rounded(.up)))
                    VStack(spacing: 10) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Nghỉ").font(T.font(15, .semibold)).foregroundStyle(T.sub)
                            Text(Fmt.duration(left)).font(T.num(32)).foregroundStyle(T.text)
                            Spacer()
                            restButton("−15") { shiftRest(-15) }
                            restButton("+15") { shiftRest(15) }
                            restButton("Bỏ qua") { state.active?.restEnds = nil }
                        }
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule().fill(T.raised)
                                Capsule().fill(Color.white).frame(width: g.size.width * CGFloat(left) / CGFloat(max(1, a.restTotal)))
                            }
                        }
                        .frame(height: 4)
                    }
                    .padding(14)
                    .background(T.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .onChange(of: left) { _, l in if l == 0 { state.active?.restEnds = nil } }
                }
            } else if let next = a.items.indices.first(where: { $0 != a.current && !a.items[$0].sets.allSatisfy(\.done) }) {
                SecondaryButton(title: "Bài tiếp: " + a.items[next].exercise.name, icon: "arrow.right") { state.active?.current = next }
            } else {
                PrimaryButton(title: "Xong hết! Lưu buổi tập", icon: "checkmark") { finish() }
            }
        }
    }

    private func restButton(_ t: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(t).font(T.font(14, .semibold)).foregroundStyle(T.text)
                .padding(.horizontal, 12).frame(height: 36).background(T.raised).clipShape(Capsule())
        }.buttonStyle(.plain)
    }

    private func shiftRest(_ s: Int) {
        guard let e = state.active?.restEnds else { return }
        state.active?.restEnds = e.addingTimeInterval(TimeInterval(s))
        state.active?.restTotal = max(15, (state.active?.restTotal ?? 90) + s)
    }
}

struct ValueStepper: View {
    var value: String
    var dimmed: Bool
    var minus: () -> Void
    var plus: () -> Void
    var tap: () -> Void
    var body: some View {
        HStack(spacing: 0) {
            Button(action: minus) { Image(systemName: "minus").frame(width: 34, height: 52) }
                .buttonStyle(.plain).accessibilityLabel("Giảm")
            Button(action: tap) {
                Text(value).font(T.num(20, .bold)).lineLimit(1).minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }.buttonStyle(.plain).accessibilityLabel("Sửa số, đang là \(value)")
            Button(action: plus) { Image(systemName: "plus").frame(width: 34, height: 52) }
                .buttonStyle(.plain).accessibilityLabel("Tăng")
        }
        .font(T.font(14, .bold))
        .foregroundStyle(dimmed ? T.sub : T.text)
        .background(T.raised)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .frame(maxWidth: .infinity)
    }
}

/// Gõ số trực tiếp, có giới hạn hợp lý.
struct NumberEditSheet: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var target: ActiveWorkoutView.EditTarget
    var unit: WeightUnit
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SheetHeader(title: target.isWeight ? "Mức tạ (\(unit.label))" : "Số rep", subtitle: target.isWeight ? "Từ 0 đến \(Fmt.n(unit.fromKg(400), digits: 0)) \(unit.label)" : "Từ 1 đến 100") { dismiss() }
            TextField("", text: $text)
                .keyboardType(target.isWeight ? .decimalPad : .numberPad)
                .font(T.num(40)).multilineTextAlignment(.center)
                .focused($focused)
                .frame(height: 72).background(T.surface).clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, T.pad)
            PrimaryButton(title: "Lưu", enabled: parsed != nil) { save() }.padding(.horizontal, T.pad)
            Spacer()
        }
        .background(T.bg.ignoresSafeArea())
        .onAppear {
            if let s = state.active?.items[target.item].sets[target.set] {
                text = target.isWeight ? Fmt.wValue(s.weightKg, unit) : "\(s.reps)"
            }
            focused = true
        }
    }

    private var parsed: Double? {
        let v = Double(text.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: ""))
        guard let v, v.isFinite else { return nil }
        if target.isWeight { return (0...unit.fromKg(400)).contains(v) ? v : nil }
        return (1...100).contains(v) && v.rounded() == v ? v : nil
    }

    private func save() {
        guard let v = parsed, var a = state.active else { return }
        if target.isWeight { a.items[target.item].sets[target.set].weightKg = unit.toKg(v) }
        else { a.items[target.item].sets[target.set].reps = Int(v) }
        a.items[target.item].sets[target.set].edited = true
        state.active = a
        dismiss()
    }
}

/// Tính bánh tạ mỗi bên (giữ từ bản chính, #071).
struct PlateSheet: View {
    @Environment(\.dismiss) private var dismiss
    var totalKg: Double
    var unit: WeightUnit
    var body: some View {
        let bar = unit == .kg ? 20.0 : 45.0
        let total = unit.fromKg(totalKg)
        let plates: [Double] = unit == .kg ? [25, 20, 15, 10, 5, 2.5, 1.25] : [45, 35, 25, 10, 5, 2.5]
        var left = max(0, (total - bar) / 2)
        var each: [Double] = []
        for p in plates { while left >= p - 0.001 { each.append(p); left -= p } }
        return VStack(alignment: .leading, spacing: 16) {
            SheetHeader(title: "Bánh tạ mỗi bên", subtitle: "Tổng \(Fmt.n(total)) \(unit.label), thanh đòn \(Fmt.n(bar, digits: 0)) \(unit.label)") { dismiss() }
            if each.isEmpty {
                Text("Chỉ cần thanh đòn.").font(T.font(16)).foregroundStyle(T.sub).padding(.horizontal, T.pad)
            } else {
                HStack(alignment: .center, spacing: 4) {
                    Rectangle().fill(T.faint).frame(width: 40, height: 10)
                    ForEach(Array(each.enumerated()), id: \.offset) { _, p in
                        RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.35 + 0.65 * p / plates[0]))
                            .frame(width: 18, height: 50 + 80 * p / plates[0])
                    }
                }
                .padding(.horizontal, T.pad)
                Text(each.map { Fmt.n($0) }.joined(separator: " + ") + " \(unit.label)")
                    .font(T.num(22)).foregroundStyle(T.lime).padding(.horizontal, T.pad)
                if left > 0.01 {
                    Text("Còn lẻ \(Fmt.n(left * 2)) \(unit.label) không chia được bằng bánh tạ thường.").font(T.font(14)).foregroundStyle(T.warn).padding(.horizontal, T.pad)
                }
            }
            Spacer()
        }
        .background(T.bg.ignoresSafeArea())
    }
}
