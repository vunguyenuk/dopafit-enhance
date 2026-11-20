import SwiftUI

struct LogTab: View {
    @EnvironmentObject var state: AppState
    @State private var month = Date()
    @State private var selectedDay: Date? = nil
    @State private var detail: Session? = nil

    var body: some View {
        let sessions = state.sortedHistory.filter { s in
            if let d = selectedDay { return Calendar.current.isDate(s.started, inSameDayAs: d) }
            return Calendar.vn.isDate(s.started, equalTo: month, toGranularity: .month)
        }
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Nhật ký").font(T.font(28, .bold)).foregroundStyle(T.text).padding(.top, 8).oneLineTitle()
                Card { MonthCalendar(month: $month, selected: $selectedDay) }
                HStack {
                    Text(selectedDay.map { Fmt.day($0) } ?? "Các buổi trong tháng").font(T.font(20, .bold)).foregroundStyle(T.text)
                    Spacer()
                    if selectedDay != nil {
                        Button("Cả tháng") { selectedDay = nil }.font(T.font(15, .medium)).foregroundStyle(T.sub)
                    }
                }
                if sessions.isEmpty {
                    Card { EmptyState(icon: "calendar", title: "Chưa có buổi tập", message: selectedDay == nil ? "Các buổi bạn lưu sẽ hiện ở đây, theo từng ngày." : "Ngày này bạn chưa tập.") }
                }
                ForEach(sessions) { s in
                    Button { detail = s } label: { SessionRow(session: s) }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, T.pad).padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .screenBackground()
        .statusBarScrim()
        .sheet(item: $detail) { s in SessionDetail(session: s).environmentObject(state) }
    }
}

struct SessionRow: View {
    @EnvironmentObject var state: AppState
    var session: Session
    var body: some View {
        Card(padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(Fmt.day(session.started)).font(T.font(13, .medium)).foregroundStyle(T.sub)
                    Spacer()
                    Text(Fmt.minutes(session.seconds)).font(T.font(13, .medium)).foregroundStyle(T.sub)
                }
                Text(session.name).font(T.font(18, .bold)).foregroundStyle(T.text)
                HStack(spacing: 22) {
                    BigStat(value: "\(session.setCount)", label: "set", size: 20)
                    BigStat(value: Fmt.n(state.unit.fromKg(session.volumeKg), digits: 0), unit: state.unit.label, label: "tổng khối lượng", size: 20)
                }
                Text(session.items.map(\.exercise.name).joined(separator: " · ")).font(T.font(13)).foregroundStyle(T.faint).lineLimit(2)
            }
        }
    }
}

struct MonthCalendar: View {
    @EnvironmentObject var state: AppState
    @Binding var month: Date
    @Binding var selected: Date?

    var body: some View {
        let cal = Calendar.vn
        let interval = cal.dateInterval(of: .month, for: month)!
        let firstWeekday = (cal.component(.weekday, from: interval.start) + 5) % 7 // thứ Hai = 0
        let count = cal.range(of: .day, in: .month, for: month)?.count ?? 30
        let cells: [Date?] = Array(repeating: nil, count: firstWeekday) + (0..<count).map { cal.date(byAdding: .day, value: $0, to: interval.start) }
        let trainedCount = state.data.history.filter { cal.isDate($0.started, equalTo: month, toGranularity: .month) }.count
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Fmt.monthFormatter.string(from: month)).font(T.font(17, .semibold)).foregroundStyle(T.text)
                    Text("\(trainedCount) buổi").font(T.num(13, .semibold)).foregroundStyle(T.sub)
                }
                Spacer()
                IconButton(icon: "chevron.left", label: "Tháng trước") { shift(-1) }
                IconButton(icon: "chevron.right", label: "Tháng sau") { shift(1) }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(["T2", "T3", "T4", "T5", "T6", "T7", "CN"], id: \.self) { d in
                    Text(d).font(T.font(12, .medium)).foregroundStyle(T.faint)
                }
                ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        let trained = state.trained(on: day)
                        let isSel = selected.map { cal.isDate($0, inSameDayAs: day) } ?? false
                        Button { selected = isSel ? nil : day } label: {
                            Text("\(cal.component(.day, from: day))")
                                .font(T.num(15, trained ? .bold : .regular))
                                .foregroundStyle(trained ? Color.black : (cal.isDateInToday(day) ? T.text : T.sub))
                                .frame(width: 38, height: 38)
                                .background(Circle().fill(trained ? T.lime : Color.clear))
                                .overlay(Circle().stroke(isSel ? Color.white : (cal.isDateInToday(day) ? T.faint : Color.clear), lineWidth: isSel ? 2 : 1))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Fmt.day(day) + (trained ? ", đã tập" : ""))
                    } else {
                        Color.clear.frame(height: 38)
                    }
                }
            }
        }
    }
    private func shift(_ n: Int) {
        if let d = Calendar.vn.date(byAdding: .month, value: n, to: month) { month = d; selected = nil }
    }
}

struct SessionDetail: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var session: Session
    @State private var confirmDelete = false

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: session.name, subtitle: Fmt.day(session.started) + " · " + Fmt.minutes(session.seconds)) { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Card {
                        HStack(spacing: 26) {
                            BigStat(value: "\(session.setCount)", label: "set", size: 28)
                            BigStat(value: Fmt.n(state.unit.fromKg(session.volumeKg), digits: 0), unit: state.unit.label, label: "tổng khối lượng", accent: true, size: 28)
                        }
                    }
                    ForEach(session.items) { it in
                        Card(padding: 14) {
                            HStack(alignment: .top, spacing: 12) {
                                ExerciseTile(exercise: it.exercise, size: 48)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(it.exercise.name).font(T.font(15, .semibold)).foregroundStyle(T.text)
                                    ForEach(Array(it.sets.filter(\.done).enumerated()), id: \.offset) { i, s in
                                        HStack {
                                            Text("Set \(i + 1)").font(T.font(13)).foregroundStyle(T.faint).frame(width: 52, alignment: .leading)
                                            Text(it.exercise.bodyweightOnly ? "\(s.reps) rep" : "\(Fmt.w(s.weightKg, state.unit)) × \(s.reps)")
                                                .font(T.num(14, .semibold)).foregroundStyle(T.text)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Button(role: .destructive) { confirmDelete = true } label: {
                        Text("Xóa buổi tập này").font(T.font(15, .semibold)).foregroundStyle(T.warn).frame(maxWidth: .infinity).frame(height: 48)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, T.pad).padding(.bottom, 24)
            }
        }
        .background(T.bg.ignoresSafeArea())
        .alert("Xóa buổi tập này?", isPresented: $confirmDelete) {
            Button("Xóa", role: .destructive) {
                state.data.history.removeAll { $0.id == session.id }
                dismiss()
            }
            Button("Giữ lại", role: .cancel) {}
        } message: { Text("Số liệu sức mạnh và hồi phục sẽ tính lại. Không hoàn tác được.") }
    }
}
