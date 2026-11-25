import SwiftUI
import Charts

struct BodyCompositionSection: View {
    @EnvironmentObject var state: AppState
    @State private var category: Bool?
    @State private var profile = false
    @State private var health = false
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Thành phần cơ thể")
            if state.data.dismissedHealthTip != true {
                Card(padding: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Apple Health", systemImage: "heart").font(T.font(17, .semibold)).foregroundStyle(T.text)
                            Spacer()
                            Button { state.data.dismissedHealthTip = true } label: {
                                Image(systemName: "xmark").foregroundStyle(T.sub).frame(width: 44, height: 44)
                            }.accessibilityLabel("Ẩn gợi ý Apple Health")
                        }
                        Text("Chưa kết nối. Bạn có thể nhập số đo để theo dõi thay đổi.").font(T.font(14)).foregroundStyle(T.sub)
                        Button { health = true } label: {
                            Label("Tìm hiểu về kết nối", systemImage: "heart.fill")
                                .font(T.font(15, .semibold)).foregroundStyle(T.lime).frame(maxWidth: .infinity, minHeight: 44)
                                .background(T.raised, in: Capsule())
                        }.buttonStyle(.plain)
                    }
                }
            }
            HStack(spacing: 12) {
                metricCategory("Chỉ số cơ thể", icon: "scalemass", composition: true)
                metricCategory("Số đo cơ thể", icon: "ruler", composition: false)
            }
            Button { profile = true } label: {
                InsightRow(title: "Hồ sơ sức khỏe", detail: "Giới tính, ngày sinh, chiều cao", icon: "person.crop.circle")
            }.buttonStyle(.plain)
        }
        .sheet(isPresented: Binding(get: { category != nil }, set: { if !$0 { category = nil } })) {
            if let category { MeasurementListScreen(composition: category) }
        }
        .sheet(isPresented: $profile) { HealthProfileScreen() }
        .sheet(isPresented: $health) { HealthConnectionScreen() }
    }
    private func metricCategory(_ name: String, icon: String, composition: Bool) -> some View {
        let metrics = BodyMetric.allCases.filter { $0.composition == composition }
        let recorded = metrics.filter { !state.measurements($0).isEmpty }.count
        return Button { category = composition } label: {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Image(systemName: icon).font(T.font(21)).foregroundStyle(T.sub)
                    Spacer()
                    Text("\(recorded)/\(metrics.count)").font(T.num(13, .medium)).foregroundStyle(T.sub)
                    Image(systemName: "chevron.right").font(T.font(11)).foregroundStyle(T.faint)
                }
                Text(name).font(T.font(17, .semibold)).foregroundStyle(T.text)
            }.frame(maxWidth: .infinity, minHeight: 92, alignment: .leading).padding(16)
                .background(T.surface, in: RoundedRectangle(cornerRadius: 20))
        }.buttonStyle(.plain).accessibilityLabel("\(name), đã có \(recorded) trong \(metrics.count) chỉ số")
    }
}

struct MeasurementListScreen: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var composition: Bool
    @State private var metric: BodyMetric?
    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: composition ? "Chỉ số cơ thể" : "Số đo cơ thể", subtitle: "Nhập từ cân hoặc thước đo của bạn") { dismiss() }
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(BodyMetric.allCases.filter { $0.composition == composition }) { item in
                        Button { metric = item } label: {
                            InsightRow(title: item.name, detail: state.measurements(item).last.map { Fmt.n(item.display($0.value, unit: state.unit)) + " " + item.unit(state.unit) } ?? "Thêm số đo", icon: item.icon)
                        }.buttonStyle(.plain)
                    }
                }.padding(T.pad)
            }
        }.background(T.bg.ignoresSafeArea())
            .sheet(item: $metric) { MeasurementHistoryScreen(metric: $0) }
    }
}

struct MeasurementHistoryScreen: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var metric: BodyMetric
    @State private var editing: BodyMeasurement?
    @State private var adding = false
    var body: some View {
        let entries = state.measurements(metric)
        VStack(spacing: 0) {
            SheetHeader(title: metric.name, subtitle: metric.unit(state.unit)) { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let last = entries.last {
                        BigStat(value: Fmt.n(metric.display(last.value, unit: state.unit)), unit: metric.unit(state.unit), label: Fmt.day(last.date), accent: true, size: 42)
                        if entries.count > 1 {
                            Chart(entries) { record in
                                LineMark(x: .value("Ngày", record.date), y: .value(metric.name, metric.display(record.value, unit: state.unit)))
                                    .foregroundStyle(T.lime).interpolationMethod(.linear)
                                PointMark(x: .value("Ngày", record.date), y: .value(metric.name, metric.display(record.value, unit: state.unit))).foregroundStyle(T.lime)
                            }
                                .chartPlotStyle { plot in
                                    plot.modifier(ChartReveal(key: metric.rawValue + state.unit.rawValue + entries.map { "\($0.date.timeIntervalSinceReferenceDate):\($0.value)" }.joined(separator: ",")))
                                }
                                .chartXScale(range: .plotDimension(padding: 20))
                                .chartYScale(domain: .automatic(includesZero: false))
                                .chartXAxis(.hidden)
                                .chartYAxis { AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                                    AxisGridLine(); AxisValueLabel { if let n = value.as(Double.self) { Text(Fmt.n(n)) } }
                                } }
                                .frame(height: 180).padding(.top, 12)
                            // Separate endpoint labels cannot be suppressed by chart collision
                            // resolution at narrow widths. They remain still during mark reveal.
                            HStack {
                                Text(Fmt.shortDay.string(from: entries.first!.date))
                                Spacer()
                                if !Calendar.vn.isDate(entries.first!.date, inSameDayAs: last.date) {
                                    Text(Fmt.shortDay.string(from: last.date))
                                }
                            }.font(T.font(12)).foregroundStyle(T.sub).accessibilityHidden(true)
                        }
                        ForEach(entries.reversed()) { record in
                            Button { editing = record } label: {
                                HStack {
                                    Text(Fmt.day(record.date)).foregroundStyle(T.sub)
                                    Spacer()
                                    Text(Fmt.n(metric.display(record.value, unit: state.unit)) + " " + metric.unit(state.unit)).foregroundStyle(T.text)
                                    Image(systemName: "pencil").foregroundStyle(T.faint)
                                }.font(T.font(15)).padding(16).background(T.surface, in: RoundedRectangle(cornerRadius: 16))
                            }.buttonStyle(.plain)
                        }
                    } else {
                        EmptyState(icon: metric.icon, title: "Chưa có số đo", message: "Thêm số đo đầu tiên để bắt đầu theo dõi.")
                    }
                }.padding(T.pad)
            }
        }.background(T.bg.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "Thêm số đo", icon: "plus") { adding = true }
                    .padding(T.pad).background(T.bg)
            }
            .sheet(isPresented: $adding) { MeasurementEditor(metric: metric) }
            .sheet(item: $editing) { MeasurementEditor(metric: metric, existing: $0) }
    }
}

struct MeasurementEditor: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    var metric: BodyMetric
    var existing: BodyMeasurement? = nil
    @State private var value = ""
    @State private var date = Date()
    @State private var invalid = false
    private var canonical: Double? {
        guard let number = Double(value.replacingOccurrences(of: ",", with: ".")) else { return nil }
        let result = metric.canonical(number, unit: state.unit)
        return result.isFinite && metric.validRange.contains(result) ? result : nil
    }
    var body: some View {
        VStack(spacing: 22) {
            SheetHeader(title: existing == nil ? "Thêm \(metric.name.lowercased())" : "Sửa số đo") { dismiss() }
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                TextField("Giá trị", text: $value).keyboardType(.decimalPad).font(T.num(40)).multilineTextAlignment(.trailing)
                    .accessibilityIdentifier("body.measurement.value")
                Text(metric.unit(state.unit)).font(T.font(20)).foregroundStyle(T.sub)
            }.padding(22).background(T.surface, in: RoundedRectangle(cornerRadius: 20)).padding(.horizontal, T.pad)
            DatePicker("Ngày đo", selection: $date, in: ...Date(), displayedComponents: .date).datePickerStyle(.compact).padding(.horizontal, T.pad)
            Text("Nhập kết quả bạn đã đo. App không tự ước tính chỉ số này.").font(T.font(14)).foregroundStyle(T.sub).padding(.horizontal, T.pad)
            if invalid { Text("Kiểm tra lại giá trị và ngày đo.").font(T.font(14)).foregroundStyle(T.warn) }
            Spacer(minLength: 0)
            PrimaryButton(title: "Lưu số đo", enabled: canonical != nil) {
                guard let canonical else { return }
                let record = BodyMeasurement(id: existing?.id ?? UUID(), metric: metric, date: date, value: canonical)
                if state.saveMeasurement(record) { dismiss() } else { invalid = true }
            }.padding(T.pad)
        }.background(T.bg.ignoresSafeArea()).onAppear {
            if let existing { value = Fmt.n(metric.display(existing.value, unit: state.unit)); date = existing.date }
        }
    }
}

struct HealthProfileScreen: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var draft = Profile()
    @State private var birthday = Date(timeIntervalSince1970: 946684800)
    @State private var hasBirthday = false
    @State private var height = ""
    @State private var health = false
    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Hồ sơ sức khỏe", subtitle: "Không bắt buộc. Bạn có thể sửa bất cứ lúc nào.") { dismiss() }
            Form {
                Section {
                    Button { health = true } label: { Label("Apple Health · Chưa kết nối", systemImage: "heart") }
                }
                Section("Nhập tay") {
                    TextField("Tên của bạn", text: $draft.name)
                    Picker("Giới tính", selection: $draft.sex) { ForEach(Profile.Sex.allCases, id: \.self) { Text($0.name).tag($0) } }
                    Toggle("Thêm ngày sinh", isOn: $hasBirthday)
                    if hasBirthday { DatePicker("Ngày sinh", selection: $birthday, in: ...Date(), displayedComponents: .date) }
                    HStack { Text("Chiều cao"); Spacer(); TextField("Chưa nhập", text: $height).keyboardType(.decimalPad).multilineTextAlignment(.trailing); Text("cm").foregroundStyle(T.sub) }
                    HStack { Text("Cân nặng hồ sơ"); Spacer(); Text(Fmt.w(draft.bodyKg, draft.unit)).foregroundStyle(T.sub) }
                }
                Section { Text("Cân nặng được cập nhật khi bạn lưu số đo mới trong Chỉ số cơ thể.").foregroundStyle(T.sub) }
            }.scrollContentBackground(.hidden)
            PrimaryButton(title: "Lưu hồ sơ", enabled: height.isEmpty || (Int(height).map { (80...250).contains($0) } ?? false)) {
                // Commit only edited fields; a cancelled sheet never changes the profile.
                state.data.profile.name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
                state.data.profile.sex = draft.sex
                state.data.profile.heightCm = Int(height)
                state.data.profile.birthDate = hasBirthday ? birthday : nil
                if hasBirthday { state.data.profile.age = Calendar.vn.dateComponents([.year], from: birthday, to: Date()).year }
                else if draft.birthDate != nil { state.data.profile.age = nil }
                dismiss()
            }.padding(T.pad)
        }.background(T.bg.ignoresSafeArea()).onAppear {
            draft = state.data.profile; height = draft.heightCm.map(String.init) ?? ""
            hasBirthday = draft.birthDate != nil; birthday = draft.birthDate ?? birthday
        }.sheet(isPresented: $health) { HealthConnectionScreen() }
    }
}

/// Honest local-only connection surface. No authorization requests or Health writes.
struct HealthConnectionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var manual = false
    var body: some View {
        VStack(spacing: 24) {
            SheetHeader(title: "Apple Health") { dismiss() }
            Image(systemName: "heart.fill").font(.system(size: 64)).foregroundStyle(T.lime).padding(.top, 32).accessibilityHidden(true)
            Text("Số đo nằm trong tay bạn.").font(T.font(27, .bold)).foregroundStyle(T.text).multilineTextAlignment(.center)
            Text("Apple Health chưa được kết nối trong bản demo. Bạn vẫn có thể nhập và theo dõi số đo ngay trên thiết bị.")
                .font(T.font(16)).foregroundStyle(T.sub).multilineTextAlignment(.center)
            Label("Chưa đọc hoặc ghi dữ liệu Apple Health", systemImage: "lock").font(T.font(13)).foregroundStyle(T.sub)
            Spacer()
            PrimaryButton(title: "Nhập số đo thủ công") { manual = true }
        }.padding(.horizontal, T.pad).padding(.bottom, T.pad).background(T.bg.ignoresSafeArea())
            .sheet(isPresented: $manual) { MeasurementListScreen(composition: true) }
    }
}
