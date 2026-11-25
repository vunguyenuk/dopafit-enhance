import SwiftUI
import Charts

struct InsightRow: View {
    var title: String
    var detail: String
    var icon: String
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(T.font(21)).foregroundStyle(T.sub).frame(width: 28).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(T.font(16, .semibold)).foregroundStyle(T.text)
                Text(detail).font(T.font(13)).foregroundStyle(T.sub)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right").font(T.font(12, .semibold)).foregroundStyle(T.faint).accessibilityHidden(true)
        }.frame(maxWidth: .infinity, minHeight: 42, alignment: .leading).padding(16)
            .background(T.surface, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct GoalRing: View {
    var value: Double
    var size: CGFloat = 32
    var color: Color = T.lime
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    var body: some View {
        ZStack {
            Circle().stroke(T.raised, lineWidth: size > 100 ? 12 : 4)
            Circle().trim(from: 0, to: appeared || reduceMotion ? max(0, min(1, value)) : 0)
                .stroke(color, style: StrokeStyle(lineWidth: size > 100 ? 12 : 4, lineCap: .round)).rotationEffect(.degrees(-90))
        }.frame(width: size, height: size).accessibilityHidden(true)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.65), value: appeared)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.5), value: value)
            .onAppear { appeared = true }
            .onDisappear { appeared = false }
    }
}

struct WeeklyGoalsScreen: View {
    @EnvironmentObject var state: AppState
    @State private var week = Date()
    @State private var expanded: Set<MuscleGroup> = []
    @State private var help = false
    private var interval: DateInterval { Calendar.vn.dateInterval(of: .weekOfYear, for: week)! }
    var body: some View {
        let groups = MuscleGroup.allCases.map { state.groupGoal($0, weekOf: week) }
        let total = groups.reduce(0) { $0 + min($1.done, $1.target) }
        let target = groups.reduce(0) { $0 + $1.target }
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Text("Mục tiêu").font(T.font(28, .bold)).foregroundStyle(T.text)
                    Spacer()
                    IconButton(icon: "info.circle", label: "Cách tính mục tiêu set") { help = true }
                }.padding(.top, 8)
                HStack {
                    Button { week = Date() } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Calendar.vn.isDate(week, equalTo: Date(), toGranularity: .weekOfYear) ? "Tuần này" : "Tuần đã chọn").font(T.font(17, .semibold)).foregroundStyle(T.text)
                            Text(intervalLabel).font(T.font(13)).foregroundStyle(T.sub)
                        }
                    }.buttonStyle(.plain).accessibilityLabel("\(intervalLabel). Trở về tuần này")
                    Spacer()
                    IconButton(icon: "chevron.left", label: "Mục tiêu tuần trước") { shift(-1) }
                    IconButton(icon: "chevron.right", label: "Mục tiêu tuần sau") { shift(1) }
                }
                HStack(spacing: 26) {
                    ZStack {
                        GoalRing(value: state.weeklyGoalProgress(weekOf: week), size: 132)
                        VStack(spacing: 2) {
                            Text("\(Int(state.weeklyGoalProgress(weekOf: week) * 100))%").font(T.num(31)).foregroundStyle(T.text)
                            Text("mục tiêu set").font(T.font(12)).foregroundStyle(T.sub)
                        }
                    }
                    VStack(alignment: .leading, spacing: 14) {
                        Text(Fmt.n(total) + " / " + Fmt.n(target) + " set").font(T.font(18, .semibold)).foregroundStyle(T.text)
                        Text("đạt mục tiêu nhóm").font(T.font(12)).foregroundStyle(T.sub)
                        Text("\(state.trainedDays(inWeekOf: week))/\(state.data.profile.daysPerWeek) ngày tập").font(T.font(15)).foregroundStyle(T.sub)
                    }
                    Spacer(minLength: 0)
                }.padding(.vertical, 12)
                ForEach(MuscleGroup.allCases, id: \.self) { group in goalGroup(group) }
                SectionTitle(title: "4 tuần trước")
                HStack(alignment: .top, spacing: 8) {
                    ForEach((1...4).reversed(), id: \.self) { offset in
                        let date = Calendar.vn.date(byAdding: .weekOfYear, value: -offset, to: interval.start)!
                        let progress = state.weeklyGoalProgress(weekOf: date)
                        Button { week = date } label: {
                            VStack(spacing: 10) {
                                ZStack {
                                    GoalRing(value: progress, size: 52)
                                    Text("\(Int(progress * 100))%").font(T.num(12)).foregroundStyle(T.text)
                                }
                                Text(Fmt.shortDay.string(from: date)).font(T.font(12)).foregroundStyle(T.sub)
                            }.frame(maxWidth: .infinity).frame(minHeight: 88)
                        }.buttonStyle(.plain).accessibilityLabel("Tuần bắt đầu \(Fmt.day(date)), \(Int(progress * 100)) phần trăm")
                    }
                }
                Text("Lịch sử được đối chiếu với mục tiêu hiện tại.").font(T.font(12)).foregroundStyle(T.sub)
            }.padding(.horizontal, T.pad).padding(.bottom, 100)
        }.scrollIndicators(.hidden).screenBackground().statusBarScrim()
            .alert("Mục tiêu set tuần", isPresented: $help) {
                Button("Đã hiểu", role: .cancel) {}
            } message: { Text("Cơ chính = 1 set, cơ phụ = 0,5 set. Chỉ tính set đã hoàn thành. Phần trăm không cộng vượt mục tiêu của từng nhóm. Mục tiêu trong V2 dựa trên số buổi và kinh nghiệm bạn chọn. Bạn có thể đổi kế hoạch trong Cài đặt.") }
    }
    private var intervalLabel: String { Fmt.shortDay.string(from: interval.start) + " – " + Fmt.shortDay.string(from: interval.end.addingTimeInterval(-1)) }
    private func shift(_ by: Int) { week = Calendar.vn.date(byAdding: .weekOfYear, value: by, to: week) ?? week }
    private func goalGroup(_ group: MuscleGroup) -> some View {
        let value = state.groupGoal(group, weekOf: week)
        let open = expanded.contains(group)
        return VStack(spacing: 16) {
            Button {
                if open { expanded.remove(group) } else { expanded.insert(group) }
            } label: {
                HStack(spacing: 14) {
                    GoalRing(value: value.done / max(1, value.target))
                    VStack(alignment: .leading, spacing: 5) {
                        Text(group.name).font(T.font(17, .semibold)).foregroundStyle(T.text)
                        Text("\(Fmt.n(value.done)) / \(Fmt.n(value.target)) set").font(T.font(13)).foregroundStyle(T.sub)
                    }
                    Spacer()
                    Text("\(Fmt.n(max(0, value.target - value.done))) còn lại").font(T.font(13)).foregroundStyle(T.sub)
                    Image(systemName: open ? "chevron.up" : "chevron.down").font(T.font(12)).foregroundStyle(T.sub)
                }.frame(minHeight: 44).contentShape(Rectangle())
            }.buttonStyle(.plain).accessibilityValue(open ? "Đã mở rộng" : "Đã thu gọn")
            if open {
                ForEach(Muscle.allCases.filter { $0.group == group }) { muscle in
                    let done = state.effectiveSets(muscle, weekOf: week)
                    let target = state.muscleTarget(muscle)
                    HStack(spacing: 12) {
                        GoalRing(value: done / target, size: 25)
                        Text(muscle.name).font(T.font(15)).foregroundStyle(T.text)
                        Spacer()
                        Text("\(Fmt.n(done)) / \(Fmt.n(target))").font(T.num(14, .medium)).foregroundStyle(T.sub)
                    }.padding(.vertical, 5)
                }
                Text("Cơ chính 1 set · Cơ phụ 0,5 set").font(T.font(12)).foregroundStyle(T.sub).frame(maxWidth: .infinity, alignment: .leading)
            }
        }.padding(16).background(T.surface, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct WorkoutReportScreen: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var range = 1
    @State private var custom = false
    @State private var start = Calendar.vn.date(byAdding: .day, value: -6, to: Date())!
    @State private var end = Date()
    private var interval: DateInterval {
        let last = Calendar.vn.startOfDay(for: end)
        let from = custom ? Calendar.vn.startOfDay(for: min(start, end)) : Calendar.vn.date(byAdding: .day, value: -([7, 30, 180, 365][range] - 1), to: Calendar.vn.startOfDay(for: Date()))!
        return DateInterval(start: from, end: Calendar.vn.date(byAdding: .day, value: 1, to: custom ? last : Calendar.vn.startOfDay(for: Date()))!)
    }
    var body: some View {
        let sessions = state.reportSessions(in: interval)
        let strength = state.weeklyStrength(in: interval)
        VStack(spacing: 0) {
            SheetHeader(title: "Báo cáo tập luyện", subtitle: Fmt.shortDay.string(from: interval.start) + " – " + Fmt.shortDay.string(from: interval.end.addingTimeInterval(-1))) { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SegmentedPills(titles: ["7 ngày", "Tháng", "6 tháng", "Năm"], selection: $range).onChange(of: range) { _, _ in custom = false }
                    Button(custom ? "Đổi khoảng ngày" : "Chọn khoảng ngày") { custom.toggle() }.font(T.font(14, .medium)).foregroundStyle(T.lime).frame(minHeight: 44)
                    if custom {
                        DatePicker("Từ ngày", selection: $start, in: ...end, displayedComponents: .date)
                        DatePicker("Đến ngày", selection: $end, in: start...Date(), displayedComponents: .date)
                    }
                    if sessions.isEmpty {
                        EmptyState(icon: "calendar", title: "Chưa có buổi tập trong khoảng này", message: "Chọn khoảng khác để xem những buổi bạn đã lưu.")
                    } else {
                        HStack(spacing: 24) {
                            BigStat(value: "\(sessions.count)", label: "buổi đã lưu", accent: true, size: 32)
                            BigStat(value: "\(sessions.reduce(0) { $0 + $1.setCount })", label: "set hoàn thành", size: 32)
                        }
                    }
                    SectionTitle(title: "Sức mạnh cơ bắp")
                    if strength.isEmpty {
                        Card { EmptyState(icon: "chart.line.uptrend.xyaxis", title: "Chưa có số liệu sức mạnh", message: "Set có tạ đã hoàn thành sẽ hiện ở đây.") }
                    } else {
                        Card {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("1RM cao nhất mỗi tuần").font(T.font(16, .semibold)).foregroundStyle(T.text)
                                Text("\(Fmt.w(strength.last?.value ?? 0, state.unit))").font(T.num(30)).foregroundStyle(T.lime)
                                seriesChart(strength, bars: false).frame(height: 170)
                                Text("Từ các set có tạ đã ghi; mỗi điểm là giá trị cao nhất trong tuần đó.").font(T.font(12)).foregroundStyle(T.sub)
                            }
                        }
                    }
                    SectionTitle(title: "Khối lượng theo nhóm cơ")
                    ForEach(MuscleGroup.allCases, id: \.self) { group in
                        let points = state.volumeSeries(group, in: interval)
                        if !points.isEmpty {
                            Card {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text(group.name).font(T.font(17, .semibold)).foregroundStyle(T.text)
                                    Text(Fmt.w(points.reduce(0) { $0 + $1.value }, state.unit)).font(T.num(27)).foregroundStyle(T.text)
                                    seriesChart(points, bars: true).frame(height: 140)
                                }
                            }
                        }
                    }
                    if !sessions.isEmpty { Text("Khối lượng = tạ × rep của set hoàn thành, nhân đôi khi ghi tạ mỗi tay. Phân nhóm theo cơ chính.").font(T.font(12)).foregroundStyle(T.sub) }
                }.padding(T.pad)
            }
        }.background(T.bg.ignoresSafeArea()).environment(\.locale, Locale(identifier: "vi_VN"))
    }
    private func seriesChart(_ points: [AnalyticsPoint], bars: Bool) -> some View {
        Chart(points) { point in
            if bars {
                BarMark(x: .value("Ngày", point.date, unit: .day), y: .value(state.unit.label, state.unit.fromKg(point.value))).foregroundStyle(T.lime)
            } else {
                LineMark(x: .value("Tuần", point.date), y: .value(state.unit.label, state.unit.fromKg(point.value))).foregroundStyle(T.lime)
                PointMark(x: .value("Tuần", point.date), y: .value(state.unit.label, state.unit.fromKg(point.value))).foregroundStyle(T.lime)
            }
        }
        .chartPlotStyle { plot in
            plot.modifier(ChartReveal(key: "\(bars)-\(interval.start.timeIntervalSinceReferenceDate)-\(interval.end.timeIntervalSinceReferenceDate)-" + state.unit.rawValue + points.map { "\($0.date.timeIntervalSinceReferenceDate):\($0.value)" }.joined(separator: ","), vertical: bars))
        }.chartXAxis { AxisMarks(values: .automatic(desiredCount: 3)) { _ in AxisValueLabel(format: .dateTime.day().month()); AxisGridLine() } }
            .chartYAxis { AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in AxisGridLine(); AxisValueLabel { if let n = value.as(Double.self) { Text(Fmt.n(n, digits: 0)) } } } }
    }
}

struct MilestoneBadgeView: View {
    var milestone: TrainingMilestone
    var size: CGFloat = 48
    var body: some View {
        ZStack {
            Path { path in
                for i in 0..<6 {
                    let a = Double(i) * .pi / 3 - .pi / 2
                    let point = CGPoint(x: size / 2 + cos(a) * size * 0.47, y: size / 2 + sin(a) * size * 0.47)
                    if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
                }
                path.closeSubpath()
            }.fill(milestone.level == 0 ? T.raised : T.lime.opacity(0.16))
            Image(systemName: milestone.icon).font(T.font(size * 0.39, .semibold)).foregroundStyle(milestone.level == 0 ? T.sub : T.lime)
        }.frame(width: size, height: size).accessibilityHidden(true)
    }
}

struct MilestonesScreen: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Cột mốc", subtitle: "Từ những buổi tập bạn đã lưu") { dismiss() }
            ScrollView {
                VStack(spacing: 22) {
                    ForEach(state.milestones()) { milestone in
                        HStack(alignment: .top, spacing: 18) {
                            VStack(spacing: 7) {
                                MilestoneBadgeView(milestone: milestone, size: 56)
                                Text(milestone.level == 0 ? "Chưa đạt" : "Cấp \(milestone.level)").font(T.font(11)).foregroundStyle(T.sub)
                            }
                            VStack(alignment: .leading, spacing: 12) {
                                Text(milestone.title).font(T.font(18, .semibold)).foregroundStyle(T.text)
                                if let raw = milestone.value {
                                    let value = milestone.id == "volume" ? state.unit.fromKg(raw) : raw
                                    let target = milestone.id == "volume" ? state.unit.fromKg(milestone.next) : milestone.next
                                    Text(Fmt.n(value, digits: 0) + " / " + Fmt.n(target, digits: 0) + " " + milestone.unit).font(T.font(14)).foregroundStyle(T.sub)
                                    ProgressView(value: milestone.progress).tint(T.lime)
                                    if milestone.completed { Text("Đã hoàn tất các mốc").font(T.font(12)).foregroundStyle(T.lime) }
                                } else {
                                    Text("Chưa có dữ liệu calo được ghi nhận.").font(T.font(14)).foregroundStyle(T.sub)
                                }
                            }.padding(.top, 4)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(18)
                            .background(T.surface, in: RoundedRectangle(cornerRadius: 20))
                    }
                    Text("Cột mốc khối lượng và số buổi tính từ set đã hoàn thành. Calo chỉ cộng khi có dữ liệu được ghi nhận.").font(T.font(13)).foregroundStyle(T.sub)
                }.padding(T.pad)
            }
        }.background(T.bg.ignoresSafeArea())
    }
}
