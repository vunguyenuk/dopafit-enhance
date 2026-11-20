import SwiftUI
import Charts

struct ProgressTab: View {
    @EnvironmentObject var state: AppState
    @State private var segment = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Tiến bộ").font(T.font(28, .bold)).foregroundStyle(T.text).padding(.top, 8).oneLineTitle()
                SegmentedPills(titles: ["Hồi phục", "Sức mạnh", "Tuần này"], selection: $segment)
                switch segment {
                case 0: RecoveryView()
                case 1: StrengthView()
                default: WeekGoalsView()
                }
            }
            .padding(.horizontal, T.pad)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .screenBackground()
        .statusBarScrim()
    }
}

// MARK: - Hồi phục

struct RecoveryView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        let muscles = Muscle.allCases.sorted { state.readiness($0) < state.readiness($1) }
        let resting = muscles.filter { state.readiness($0) < 0.8 }
        VStack(alignment: .leading, spacing: 16) {
            Card {
                VStack(alignment: .leading, spacing: 14) {
                    Text(resting.isEmpty ? "Mọi nhóm cơ đã sẵn sàng" : "\(resting.count) nhóm cơ đang hồi phục")
                        .font(T.font(18, .semibold)).foregroundStyle(T.text)
                    BodyMapView(female: state.data.profile.sex == .female) { slug in
                        if ["head", "hair", "hands", "feet", "ankles", "knees", "neck"].contains(slug) { return Color.white.opacity(0.08) }
                        guard let m = Muscle.allCases.first(where: { $0.bodySlugs.contains(slug) }) else { return Color.white.opacity(0.12) }
                        return state.readiness(m) < 0.8 ? T.rest : Color.white.opacity(0.72)
                    }
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    HStack(spacing: 18) {
                        legend(Color.white.opacity(0.72), "Sẵn sàng tập")
                        legend(T.rest, "Đang hồi phục")
                    }
                    Text("Tính từ số set bạn đã tập cho mỗi nhóm cơ trong 3 ngày gần nhất.").font(T.font(13)).foregroundStyle(T.faint)
                }
            }
            if !resting.isEmpty {
                SectionTitle(title: "Cần nghỉ thêm")
                ForEach(resting) { m in
                    Card(padding: 14) {
                        HStack(spacing: 14) {
                            MuscleMiniMap(muscle: m, tint: T.rest).frame(width: 30, height: 56)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(m.name).font(T.font(16, .semibold)).foregroundStyle(T.text)
                                Text("Nên nghỉ thêm khoảng \(max(4, state.hoursUntilReady(m))) giờ").font(T.font(14)).foregroundStyle(T.sub)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    private func legend(_ c: Color, _ t: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(c).frame(width: 10, height: 10)
            Text(t).font(T.font(13, .medium)).foregroundStyle(T.sub)
        }
    }
}

// MARK: - Sức mạnh

struct StrengthView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        let lifts = state.trackedLifts
        VStack(alignment: .leading, spacing: 14) {
            InfoLine(icon: "info.circle", text: "Con số chính là mức tạ ước tính bạn nâng được 1 lần, tính từ set tốt nhất của mỗi buổi. Không cần thử tạ tối đa.")
            if lifts.isEmpty {
                Card { EmptyState(icon: "chart.line.uptrend.xyaxis", title: "Chưa có số liệu", message: "Sau buổi tập đầu tiên, sức mạnh của từng bài sẽ hiện ở đây.") }
            }
            ForEach(lifts) { ex in LiftCard(exercise: ex) }
        }
    }
}

struct LiftCard: View {
    @EnvironmentObject var state: AppState
    var exercise: Exercise
    var body: some View {
        let series = state.e1rmSeries(exercise.id)
        let unit = state.unit
        let current = series.last?.1 ?? 0
        let first = series.first?.1 ?? current
        let delta = current - first
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.name).font(T.font(16, .semibold)).foregroundStyle(T.text)
                        Text("\(series.count) buổi").font(T.font(13)).foregroundStyle(T.faint)
                    }
                    Spacer()
                    if delta > 0.05 {
                        Text("+" + Fmt.w(delta, unit)).font(T.num(14, .bold)).foregroundStyle(.black)
                            .padding(.horizontal, 10).frame(height: 26).background(T.lime).clipShape(Capsule())
                    }
                }
                BigStat(value: Fmt.wValue(current, unit), unit: unit.label, label: "ước tính nâng được 1 lần", accent: true, size: 38)
                if series.count >= 2 {
                    Chart {
                        ForEach(Array(series.enumerated()), id: \.offset) { _, p in
                            LineMark(x: .value("Ngày", p.0), y: .value("Tạ", unit.fromKg(p.1)))
                                .foregroundStyle(Color.white)
                                .interpolationMethod(.monotone)
                            PointMark(x: .value("Ngày", p.0), y: .value("Tạ", unit.fromKg(p.1)))
                                .foregroundStyle(Color.white).symbolSize(18)
                        }
                    }
                    .chartYScale(domain: yDomain(series.map { unit.fromKg($0.1) }))
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { v in
                            AxisGridLine().foregroundStyle(T.line)
                            AxisValueLabel { if let d = v.as(Double.self) { Text(Fmt.n(d, digits: 0)).font(T.font(11)).foregroundStyle(T.faint) } }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 4)) { v in
                            AxisValueLabel { if let d = v.as(Date.self) { Text(Fmt.shortDay.string(from: d)).font(T.font(11)).foregroundStyle(T.faint) } }
                        }
                    }
                    .frame(height: 120)
                }
            }
        }
    }
    /// Trục y bám sát dữ liệu (không bắt đầu từ 0, không ký hiệu khoa học kiểu "2,0E7").
    private func yDomain(_ v: [Double]) -> ClosedRange<Double> {
        let lo = v.min() ?? 0, hi = v.max() ?? 1
        let pad = max(2.5, (hi - lo) * 0.25)
        return max(0, lo - pad)...(hi + pad)
    }
}

// MARK: - Mục tiêu tuần

struct WeekGoalsView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        let done = state.sessions(inWeekOf: Date()).count
        let goal = state.data.profile.daysPerWeek
        VStack(alignment: .leading, spacing: 14) {
            Card {
                HStack(spacing: 28) {
                    BigStat(value: "\(done)/\(goal)", label: "buổi tuần này", accent: done >= goal, size: 36)
                    BigStat(value: "\(MuscleGroup.allCases.reduce(0) { $0 + state.weeklySets($1) })", label: "set đã tập", size: 36)
                }
            }
            InfoLine(icon: "info.circle", text: "Số set nên tập mỗi tuần cho từng nhóm cơ, tính theo kinh nghiệm và số buổi bạn chọn.")
            ForEach(MuscleGroup.allCases, id: \.self) { g in
                let n = state.weeklySets(g)
                let target = state.weeklyTarget(g)
                Card(padding: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(g.name).font(T.font(16, .semibold)).foregroundStyle(T.text)
                                Text(g.detail).font(T.font(13)).foregroundStyle(T.faint)
                            }
                            Spacer()
                            Text("\(n)").font(T.num(24)).foregroundStyle(n >= target ? T.lime : T.text)
                            Text("/ \(target) set").font(T.font(14)).foregroundStyle(T.sub)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(T.raised)
                                Capsule().fill(n >= target ? T.lime : Color.white)
                                    .frame(width: geo.size.width * min(1, CGFloat(n) / CGFloat(max(1, target))))
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
    }
}
