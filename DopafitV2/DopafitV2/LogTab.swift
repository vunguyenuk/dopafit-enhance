import SwiftUI

struct LogTab: View {
    @EnvironmentObject var state: AppState
    @State private var month = Date()
    @State private var selectedDay: Date? = nil
    @State private var detail: Session? = nil
    @State private var expandedCalendar = false
    @State private var report = false
    @State private var milestones = false
    @State private var profile = false
    @State private var adding = false

    var body: some View {
        let sessions = state.sortedHistory.filter { s in
            if let d = selectedDay { return Calendar.current.isDate(s.started, inSameDayAs: d) }
            return Calendar.vn.isDate(s.started, equalTo: month, toGranularity: expandedCalendar ? .month : .weekOfYear)
        }
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Nhật ký").font(T.font(28, .bold)).foregroundStyle(T.text)
                    Spacer()
                    IconButton(icon: "chart.bar.xaxis", label: "Báo cáo tập luyện") { report = true }
                    IconButton(icon: "person.crop.circle", label: "Hồ sơ sức khỏe") { profile = true }
                }.padding(.top, 8)
                HStack(alignment: .top, spacing: 20) {
                    BigStat(value: "\(state.completedSessions().count)", label: "buổi đã lưu", size: 28)
                    Spacer()
                    Button { milestones = true } label: {
                        VStack(alignment: .leading, spacing: 9) {
                            Text("Cột mốc").font(T.font(13)).foregroundStyle(T.sub)
                            HStack(spacing: 6) { ForEach(state.milestones()) { MilestoneBadgeView(milestone: $0, size: 30) } }
                        }
                    }.buttonStyle(.plain).accessibilityLabel("Xem cột mốc tập luyện")
                }
                HStack(spacing: 28) {
                    Label("\(state.trainedDays(inWeekOf: Date()))/\(state.data.profile.daysPerWeek) ngày tuần này", systemImage: "calendar")
                    Label("\(state.weeklyStreak()) tuần liên tiếp", systemImage: "flame")
                }.font(T.font(13)).foregroundStyle(T.sub)
                Card(padding: 14) { MonthCalendar(month: $month, selected: $selectedDay, expanded: $expandedCalendar) }
                HStack {
                    Text(selectedDay.map { Fmt.day($0) } ?? (expandedCalendar ? "Các buổi trong tháng" : "Các buổi trong tuần")).font(T.font(20, .bold)).foregroundStyle(T.text)
                    Spacer()
                    if selectedDay != nil {
                        Button("Xem hết") { selectedDay = nil }.font(T.font(14, .medium)).foregroundStyle(T.sub)
                    }
                    IconButton(icon: "plus", label: "Ghi buổi tập mới") { adding = true }
                }
                if sessions.isEmpty {
                    Card { EmptyState(icon: "calendar", title: "Chưa có buổi tập", message: selectedDay == nil ? "Các buổi bạn lưu sẽ hiện ở đây, theo từng ngày." : "Ngày này bạn chưa tập.") }
                }
                ForEach(sessions) { s in
                    Button { detail = s } label: { SessionRow(session: s) }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, T.pad).padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .screenBackground()
        .statusBarScrim()
        .sheet(item: $detail) { s in SessionDetail(session: s).environmentObject(state) }
        .sheet(isPresented: $report) { WorkoutReportScreen() }
        .sheet(isPresented: $milestones) { MilestonesScreen() }
        .sheet(isPresented: $profile) { HealthProfileScreen() }
        .sheet(isPresented: $adding) {
            VStack(alignment: .leading, spacing: 22) {
                SheetHeader(title: "Ghi buổi tập mới") { adding = false }
                Text("Bắt đầu buổi tập theo kế hoạch hiện tại. Các set chỉ được thêm vào nhật ký khi bạn hoàn thành và lưu.").font(T.font(16)).foregroundStyle(T.sub).padding(.horizontal, T.pad)
                Spacer()
                PrimaryButton(title: "Bắt đầu ghi buổi tập", enabled: state.active == nil && !state.plan.items.isEmpty) {
                    adding = false; state.start(state.plan)
                }.padding(T.pad)
            }.background(T.bg.ignoresSafeArea()).presentationDetents([.medium])
        }
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
                    Text(Fmt.duration(session.seconds)).font(T.font(13, .medium)).foregroundStyle(T.sub)
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
    @Binding var expanded: Bool

    var body: some View {
        let cal = Calendar.vn
        let interval = cal.dateInterval(of: .month, for: month)!
        let firstWeekday = (cal.component(.weekday, from: interval.start) + 5) % 7 // thứ Hai = 0
        let count = cal.range(of: .day, in: .month, for: month)?.count ?? 30
        let weekStart = cal.dateInterval(of: .weekOfYear, for: month)!.start
        let cells: [Date?] = expanded ? Array(repeating: nil, count: firstWeekday) + (0..<count).map { cal.date(byAdding: .day, value: $0, to: interval.start) } : (0..<7).map { cal.date(byAdding: .day, value: $0, to: weekStart) }
        let trainedCount = state.completedSessions().filter { cal.isDate($0.started, equalTo: month, toGranularity: expanded ? .month : .weekOfYear) }.count
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Button { expanded.toggle(); selected = nil } label: {
                        HStack(spacing: 5) {
                            Text(Fmt.monthFormatter.string(from: month))
                            Image(systemName: expanded ? "chevron.up" : "chevron.down").font(T.font(11))
                        }.font(T.font(17, .semibold)).foregroundStyle(T.text).frame(minHeight: 44)
                    }.buttonStyle(.plain).accessibilityLabel(expanded ? "Thu gọn lịch tháng" : "Mở rộng lịch tháng")
                    Text("\(trainedCount) buổi").font(T.num(13, .semibold)).foregroundStyle(T.sub)
                }
                Spacer()
                IconButton(icon: "chevron.left", label: expanded ? "Tháng trước" : "Nhật ký tuần trước") { shift(-1) }
                IconButton(icon: "chevron.right", label: expanded ? "Tháng sau" : "Nhật ký tuần sau") { shift(1) }
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
        if let d = Calendar.vn.date(byAdding: expanded ? .month : .weekOfYear, value: n, to: month) { month = d; selected = nil }
    }
}

struct SessionDetail: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var session: Session
    @State private var confirmDelete = false
    @State private var editDuration = false

    var body: some View {
        let session = state.data.history.first { $0.id == self.session.id } ?? self.session
        VStack(spacing: 0) {
            SheetHeader(title: session.name, subtitle: Fmt.day(session.started) + " · " + Fmt.duration(session.seconds)) { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Card {
                        HStack(spacing: 26) {
                            BigStat(value: "\(session.setCount)", label: "set", size: 28)
                            BigStat(value: Fmt.n(state.unit.fromKg(session.volumeKg), digits: 0), unit: state.unit.label, label: "tổng khối lượng", accent: true, size: 28)
                        }
                    }
                    Button { editDuration = true } label: {
                        InsightRow(title: "Thời lượng buổi tập", detail: Fmt.duration(session.seconds), icon: "clock")
                    }.buttonStyle(.plain)
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
        .sheet(isPresented: $editDuration) { SavedSessionDurationEditor(sessionID: session.id) }
        .alert("Xóa buổi tập này?", isPresented: $confirmDelete) {
            Button("Xóa", role: .destructive) {
                state.data.history.removeAll { $0.id == session.id }
                dismiss()
            }
            Button("Giữ lại", role: .cancel) {}
        } message: { Text("Số liệu sức mạnh và hồi phục sẽ tính lại. Không hoàn tác được.") }
    }
}

struct SavedSessionDurationEditor: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var sessionID: UUID
    @State private var minutes = ""
    @State private var seconds = ""
    private var total: Int? {
        guard let m = Int(minutes), let s = Int(seconds), m >= 0, (0...59).contains(s), (1...86_400).contains(m * 60 + s) else { return nil }
        return m * 60 + s
    }
    var body: some View {
        VStack(spacing: 24) {
            SheetHeader(title: "Sửa thời lượng") { dismiss() }
            HStack(spacing: 20) {
                VStack { TextField("0", text: $minutes).accessibilityLabel("Số phút"); Text("phút").font(T.font(14)).foregroundStyle(T.sub) }
                Text(":")
                VStack { TextField("0", text: $seconds).accessibilityLabel("Số giây"); Text("giây").font(T.font(14)).foregroundStyle(T.sub) }
            }.font(T.num(38)).keyboardType(.numberPad).multilineTextAlignment(.center).padding(T.pad)
            Spacer()
            PrimaryButton(title: "Lưu thời lượng", enabled: total != nil) {
                if let total, state.updateSessionDuration(sessionID, seconds: total) { dismiss() }
            }.padding(T.pad)
        }.background(T.bg.ignoresSafeArea()).onAppear {
            let duration = state.data.history.first { $0.id == sessionID }?.seconds ?? 0
            minutes = String(duration / 60); seconds = String(duration % 60)
        }
    }
}
