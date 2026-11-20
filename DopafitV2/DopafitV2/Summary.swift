import SwiftUI

/// Tổng kết sau buổi tập: con số to, kỷ lục ghi rõ bằng kg, không pháo giấy đè chữ.
struct SummaryView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var session: Session

    var body: some View {
        let records = state.records(in: session)
        VStack(spacing: 0) {
            SheetHeader(title: "Xong buổi tập", subtitle: session.name + " · " + Fmt.day(session.started)) { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Card {
                        VStack(alignment: .leading, spacing: 18) {
                            BigStat(value: Fmt.n(state.unit.fromKg(session.volumeKg), digits: 0), unit: state.unit.label, label: "Tổng khối lượng đã nâng (tạ × rep)", accent: true, size: 44)
                            HStack(spacing: 26) {
                                BigStat(value: "\(session.setCount)", label: "set", size: 28)
                                BigStat(value: "\(session.items.count)", label: "bài", size: 28)
                                BigStat(value: Fmt.minutes(session.seconds).replacingOccurrences(of: " phút", with: ""), label: "phút", size: 28)
                            }
                        }
                    }
                    if !records.isEmpty {
                        SectionTitle(title: "Kỷ lục mới")
                        ForEach(Array(records.enumerated()), id: \.offset) { _, r in
                            Card(padding: 14) {
                                HStack(spacing: 12) {
                                    Image(systemName: "trophy.fill").foregroundStyle(T.lime).font(T.font(18))
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(r.0.name).font(T.font(16, .semibold)).foregroundStyle(T.text)
                                        Text("Ước tính nâng được \(Fmt.w(r.1, state.unit)) × 1 lần (trước đây \(Fmt.w(r.2, state.unit)))")
                                            .font(T.font(14)).foregroundStyle(T.sub)
                                    }
                                }
                            }
                        }
                    }
                    SectionTitle(title: "Chi tiết")
                    ForEach(session.items) { it in
                        Card(padding: 14) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(it.exercise.name).font(T.font(15, .semibold)).foregroundStyle(T.text)
                                Text(it.sets.filter(\.done).map { it.exercise.bodyweightOnly ? "\($0.reps) rep" : "\(Fmt.wValue($0.weightKg, state.unit)) × \($0.reps)" }.joined(separator: "   "))
                                    .font(T.num(14, .semibold)).foregroundStyle(T.sub)
                            }
                        }
                    }
                }
                .padding(.horizontal, T.pad).padding(.bottom, 20)
            }
            BottomBar { PrimaryButton(title: "Xong") { dismiss() } }
        }
        .background(T.bg.ignoresSafeArea())
    }
}
