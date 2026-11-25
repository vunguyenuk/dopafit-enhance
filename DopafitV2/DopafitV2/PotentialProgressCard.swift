import SwiftUI
import Charts

/// An explicitly labelled example of logged loads, never a four-session prediction.
struct PotentialProgressCard: View {
    var item: WorkoutItem
    var unit: WeightUnit
    private var isLoad: Bool { !item.exercise.bodyweightOnly && (item.sets.first?.weightKg ?? 0) > 0 }
    private var start: Double { isLoad ? unit.fromKg(item.sets.first?.weightKg ?? 0) : Double(item.targetReps) }
    private var increase: Double { isLoad ? unit.step : 2 }
    private var end: Double { start + increase }
    private var suffix: String { isLoad ? unit.label : "rep" }
    private var values: [Double] { [start, start + increase * 0.25, start + increase * 0.65, end] }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(T.font(22, .semibold)).foregroundStyle(T.lime)
                    .frame(width: 42, height: 42).background(T.raised, in: Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text("Ví dụ minh họa").font(T.font(12, .medium)).foregroundStyle(T.sub)
                    Text(item.exercise.name).font(T.font(18, .semibold)).foregroundStyle(T.text)
                }
                Spacer(minLength: 0)
            }
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(Fmt.n(end)).font(T.num(45)).foregroundStyle(T.text)
                Text(suffix).font(T.font(23, .semibold)).foregroundStyle(T.sub)
                Spacer()
                Text("↗ +" + Fmt.n(increase) + " " + suffix)
                    .font(T.font(13, .semibold)).foregroundStyle(T.lime)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(T.lime.opacity(0.08), in: Capsule())
                    .overlay(Capsule().stroke(T.lime.opacity(0.35)))
            }
            Chart {
                ForEach(0..<4) { i in
                    RuleMark(y: .value("Mốc", start + increase * Double(i) / 3))
                        .foregroundStyle(T.line).lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
                ForEach(0..<4) { i in
                    AreaMark(x: .value("Buổi", i + 1), yStart: .value("Nền", start - increase * 0.22), yEnd: .value("Giá trị", values[i]))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(LinearGradient(colors: [T.lime.opacity(0.35), T.lime.opacity(0.03)], startPoint: .top, endPoint: .bottom))
                    LineMark(x: .value("Buổi", i + 1), y: .value("Giá trị", values[i]))
                        .interpolationMethod(.monotone).lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round)).foregroundStyle(T.lime)
                    PointMark(x: .value("Buổi", i + 1), y: .value("Giá trị", values[i]))
                        .foregroundStyle(T.lime)
                        .symbol {
                            Circle().fill(T.lime).frame(width: i == 3 ? 13 : 9, height: i == 3 ? 13 : 9)
                                .overlay(Circle().stroke(Color.white, lineWidth: 1.2))
                                .shadow(color: T.lime.opacity(i == 3 ? 0.65 : 0), radius: 8)
                        }
                        .annotation(position: .top, alignment: i == 0 ? .leading : .trailing, spacing: 10) {
                            if i == 0 { Text(Fmt.n(start) + " " + suffix).font(T.font(12, .semibold)).foregroundStyle(T.text) }
                        }
                }
            }
            .chartPlotStyle { plot in
                plot.modifier(ChartReveal(key: "potential-\(item.exerciseID)-\(start)-\(end)-\(unit.rawValue)"))
            }
            .chartXScale(domain: 0.85...4.15)
            .chartYScale(domain: (start - increase * 0.22)...(end + increase * 0.45))
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
            .frame(height: 135)
            .accessibilityLabel("Ví dụ minh họa bốn buổi: từ \(Fmt.n(start)) đến \(Fmt.n(end)) \(suffix). Không phải dữ liệu đã ghi.")
            HStack {
                ForEach(1...4, id: \.self) { i in
                    if i > 1 { Spacer(minLength: 0) }
                    Text("Buổi \(i)").font(T.font(12)).foregroundStyle(T.sub)
                }
            }.padding(.horizontal, 5)
        }.padding(20).background(T.surface, in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(T.line))
    }
}
