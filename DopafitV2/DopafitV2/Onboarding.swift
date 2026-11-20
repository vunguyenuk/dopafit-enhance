import SwiftUI
import UserNotifications

/// Thiết lập ban đầu: kết hợp câu hỏi & lời văn của app cũ với luồng theo tâm lý người dùng.
/// Nguyên tắc: câu dễ trước, câu nhạy cảm sau; mỗi câu trả lời đều được app dùng và nói lại cho người dùng thấy;
/// kết thúc bằng màn plan cụ thể; không đếm ngược giả, không hỏi lặp.
struct OnboardingFlow: View {
    @EnvironmentObject var state: AppState
    @State private var reassureSeen = false
    @State private var index = ProcessInfo.processInfo.arguments.contains("--skip-welcome") ? 1 : 0
    @State private var p = Profile()
    @State private var obstacles: [String] = []
    @State private var promised = false
    @State private var holding = false
    @State private var showAccountNote = false
    @State private var showLoginNote = false
    @State private var lastAdvance = Date.distantPast

    enum Step: Hashable {
        case welcome, goal, echo, level, recent, reassure, obstacles, story(String), core, place, schedule, about, building, reveal, promise, reminder, save
        var phase: String {
            switch self {
            case .welcome, .goal, .echo, .level, .recent, .reassure: return "Về bạn"
            case .obstacles, .story, .core, .place, .schedule, .about: return "Tập luyện"
            default: return "Kế hoạch"
            }
        }
    }

    private var steps: [Step] {
        var s: [Step] = [.welcome, .goal, .echo, .level, .recent, .reassure, .obstacles]
        s += obstacles.prefix(2).map { Step.story($0) }
        s += [.core, .place, .schedule, .about, .building, .reveal, .promise, .reminder, .save]
        return s
    }
    private var step: Step { steps[min(index, steps.count - 1)] }

    var body: some View {
        VStack(spacing: 0) {
            if step != .welcome && step != .building { header }
            Group {
                switch step {
                case .welcome: welcome
                case .goal: goal
                case .echo: echo
                case .level: level
                case .recent: recent
                case .reassure: reassure
                case .obstacles: obstacleQuestion
                case .story(let o): story(o)
                case .core: core
                case .place: place
                case .schedule: schedule
                case .about: about
                case .building: BuildingPlanView(lines: buildingLines) { next() }
                case .reveal: reveal
                case .promise: promise
                case .reminder: reminder
                case .save: save
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .transition(.push(from: .trailing))
            .id(index)
        }
        .screenBackground()
        .safeAreaInset(edge: .bottom) { footer }
        .animation(.snappy, value: index)
        // màn trấn an: chạy hết các dòng rồi tự sang màn sau (chỉ lần đầu)
        .task(id: index) {
            guard step == .reassure, !reassureSeen else { return }
            try? await Task.sleep(nanoseconds: AutoFixList.duration(3))
            guard !Task.isCancelled, step == .reassure else { return }
            reassureSeen = true
            lastAdvance = Date()
            index += 1
        }
        .alert("Bản demo chưa kết nối tài khoản", isPresented: $showAccountNote) {
            Button("Tiếp tục") { finish() }
        } message: { Text("Plan của bạn được lưu trên máy này. Khi có tài khoản thật, plan sẽ được đồng bộ.") }
        .alert("Bản demo chưa có đăng nhập", isPresented: $showLoginNote) {
            Button("Đã hiểu", role: .cancel) {}
        } message: { Text("Bấm “Bắt đầu thiết lập” để tạo plan, hoặc xem bản demo có sẵn dữ liệu.") }
    }

    private func next() {
        // Chặn bấm đúp: nút "Tiếp tục" của màn sau xuất hiện đúng chỗ ngón tay vừa bấm.
        guard Date().timeIntervalSince(lastAdvance) > 0.45 else { return }
        lastAdvance = Date()
        if step == .about {
            p.obstacles = obstacles
            state.data.profile = p
        }
        if index < steps.count - 1 { index += 1 } else { finish() }
    }

    private func finish() {
        p.obstacles = obstacles
        state.data.profile = p
        state.data.onboarded = true
    }

    // MARK: Đầu & cuối

    /// Thanh tiến độ 3 chặng như app cũ, nhưng nhích nhanh ở đầu để người dùng thấy mình đi được xa.
    private var header: some View {
        let total = Double(max(1, steps.count - 1))
        let shown = pow(Double(index) / total, 0.7)
        return HStack(spacing: 14) {
            IconButton(icon: "chevron.left", label: "Quay lại") { index = max(0, index - 1) }
            VStack(alignment: .leading, spacing: 8) {
                Text(step.phase).font(T.font(14, .semibold)).foregroundStyle(T.sub)
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(T.raised)
                        Capsule().fill(T.lime).frame(width: g.size.width * shown)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.horizontal, T.pad).padding(.top, 8).padding(.bottom, 4)
    }

    @ViewBuilder private var footer: some View {
        switch step {
        case .welcome, .building, .goal, .level, .recent, .place:
            EmptyView() // chọn là tự đi tiếp
        case .reassure:
            // lần đầu tự chạy; quay lại xem thì có nút để đi tiếp
            if reassureSeen { BottomBar { PrimaryButton(title: "Tiếp tục") { next() } } } else { EmptyView() }
        case .obstacles:
            BottomBar { PrimaryButton(title: obstacles.isEmpty ? "Bỏ qua" : "Tiếp tục") { next() } }
        case .reveal:
            BottomBar { PrimaryButton(title: "Tôi sẵn sàng rồi") { next() } }
        case .promise:
            BottomBar { holdButton }
        case .reminder:
            BottomBar {
                PrimaryButton(title: p.reminderHour.map { "Nhắc tôi lúc \($0):00" } ?? "Không cần nhắc") {
                    if let h = p.reminderHour { scheduleReminder(hour: h) }
                    next()
                }
            }
        case .save:
            BottomBar {
                PrimaryButton(title: "Tạo tài khoản") { showAccountNote = true }
                Button("Để sau, lưu trên máy này") { finish() }
                    .font(T.font(15, .medium)).foregroundStyle(T.sub).frame(height: 40)
            }
        default:
            BottomBar { PrimaryButton(title: "Tiếp tục") { next() } }
        }
    }

    // MARK: 1. Màn chào

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer()
            HStack(spacing: 8) {
                DopafitMark().fill(T.lime).frame(width: 34, height: 20)
                Text("Dopafit").font(T.font(17, .bold)).foregroundStyle(T.text)
            }
            Headline("Thấy mình mạnh lên.", size: 34).foregroundStyle(.white).oneLineTitle()
            Text("Dopafit lên plan, ghi lại từng set và cho bạn thấy rõ mình tiến bộ bằng con số.")
                .font(T.font(16)).foregroundStyle(T.sub).bodyLines(16)
            PrimaryButton(title: "Bắt đầu thiết lập · 2 phút") { next() }
            HStack(spacing: 4) {
                Text("Đã có tài khoản?").foregroundStyle(T.sub)
                Button("Đăng nhập") { showLoginNote = true }.foregroundStyle(T.text).underline()
            }
            .font(T.font(15)).frame(maxWidth: .infinity)
            Button("Xem bản demo có sẵn dữ liệu") { state.loadDemo() }
                .font(T.font(14)).foregroundStyle(T.faint).frame(maxWidth: .infinity).frame(height: 36)
        }
        .padding(.horizontal, T.pad).padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background {
            Color.clear
                .overlay(alignment: .top) { BWPhoto(name: "photo-curl") }
                .clipped()
                .overlay(LinearGradient(colors: [.clear, T.bg.opacity(0.75), T.bg], startPoint: .init(x: 0.5, y: 0.25), endPoint: .init(x: 0.5, y: 0.72)))
                .ignoresSafeArea()
        }
    }

    // MARK: 2. Mục tiêu (câu dễ, chọn là đi tiếp)

    private var goal: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                QuestionTitle(title: "Bạn muốn đạt điều gì?", subtitle: "Chọn một. App dùng câu này để chọn số rep và cách tăng tạ.")
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(Profile.Goal.allCases, id: \.self) { g in
                        Button { p.goal = g; next() } label: {
                            VStack(alignment: .leading, spacing: 0) {
                                Image(systemName: g.icon).font(T.font(26, .semibold)).foregroundStyle(p.goal == g ? T.lime : T.text)
                                Spacer()
                                Text(g.name).font(T.font(17, .semibold)).foregroundStyle(T.text).multilineTextAlignment(.leading)
                            }
                            .padding(16).frame(maxWidth: .infinity, alignment: .leading).frame(height: 132)
                            .background(T.surface)
                            .clipShape(RoundedRectangle(cornerRadius: T.radius, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: T.radius, style: .continuous).stroke(p.goal == g ? T.lime.opacity(0.6) : T.line))
                        }.buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, T.pad)
        }
    }

    // MARK: 3. Đáp lại theo mục tiêu (thấy mình được hiểu)

    private func echoText() -> (String, String, String, String) {
        switch p.goal {
        case .muscle: return ("photo-press", "Tạ tăng đều, cơ tăng theo.", "Dopafit ghi từng set và báo đúng lúc nên tăng tạ.", "+2,5 kg")
        case .strength: return ("photo-deadlift", "Mỗi tuần mạnh hơn chút.", "Sau mỗi buổi, bạn thấy mức tạ ước tính nâng được của từng bài.", "+5 kg")
        case .lean: return ("photo-plank", "Tập tạ đều, giữ được cơ.", "Dopafit giữ nhịp tuần cho bạn, kể cả khi bận hay mệt.", "3 buổi")
        case .health: return ("photo-calm", "Vừa sức nhưng đều đặn.", "Plan vừa sức để bạn không bỏ giữa chừng.", "4 tuần")
        }
    }

    /// Bài và số bánh 2 kg mỗi đầu lắp được sau 4 tuần (tổng tạ lắp tối đa khoảng 24 kg, chưa tính đòn).
    private func goalLift() -> (title: String, slices: Int) {
        switch p.goal {
        case .muscle: return ("Squat", 5)      // 20 kg tạ
        case .strength: return ("Squat", 6)    // 24 kg tạ
        case .lean: return ("Deadlift", 5)     // 20 kg tạ
        case .health: return ("Đẩy ngực", 3)   // 12 kg tạ
        }
    }

    /// Ảnh ở trên, câu tiêu đề, rồi cảnh lắp tạ chiếm phần lớn màn hình.
    private var echo: some View {
        let t = echoText()
        let g = goalLift()
        return GeometryReader { geo in
            VStack(alignment: .leading, spacing: 16) {
                // ảnh lớn, chỉ phủ tối phần đáy để chữ nổi mà ảnh vẫn rõ
                PhotoBox(name: t.0, height: max(150, geo.size.height - 400), focus: .top)
                    .overlay(LinearGradient(stops: [.init(color: .clear, location: 0.65), .init(color: T.bg, location: 1)],
                                            startPoint: .top, endPoint: .bottom))
                    .padding(.horizontal, -T.pad)
                    .padding(.bottom, -28)
                Headline(t.1).foregroundStyle(T.text).oneLineTitle()
                PlateLoaderCard(title: g.title, slices: g.slices)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, T.pad)
        }
    }

    // MARK: 4–5. Kinh nghiệm & dạo này tập thế nào (câu của app cũ)

    private var level: some View {
        ChoiceList(title: "Bạn đã tập tạ bao lâu?", subtitle: "Để chọn mức tạ khởi điểm. Bạn sửa được ngay ở set đầu tiên.",
                   items: Profile.Level.allCases.map { ($0.name, $0.detail, nil) },
                   selected: Profile.Level.allCases.firstIndex(of: p.level)) { i in p.level = Profile.Level.allCases[i]; next() }
    }

    private var recent: some View {
        ChoiceList(title: "Dạo này bạn tập thế nào?", subtitle: "Không có câu trả lời đúng hay sai.",
                   items: Profile.Recent.allCases.map { ($0.name, nil, $0.icon) },
                   selected: p.recent.flatMap { Profile.Recent.allCases.firstIndex(of: $0) }) { i in p.recent = Profile.Recent.allCases[i]; next() }
    }

    // MARK: 6. Trấn an theo nhóm (bớt lo cho người mới, tôn trọng người đã tập)

    private var reassure: some View {
        let isNew = p.level == .new
        let back = p.recent == .returning
        let photo = isNew ? "photo-glutes" : (back ? "photo-row" : "photo-press")
        let title = isNew ? "Mới tập vẫn bắt đầu được." : (back ? "Quay lại, không từ số 0." : "Không phải tập lại từ đầu.")
        let detail = isNew ? "Khoảng một nửa người mới cài app tập tạ cũng chưa từng tập, như bạn." : "Dopafit tính tới việc bạn đã có nền tảng."
        let items: [String] = isNew
            ? ["Mỗi bài có video động tác", "Hướng dẫn chỉnh máy, chỉnh ghế trước khi tập", "Tạ khởi điểm nhẹ, tăng dần khi bạn làm đủ rep"]
            : (back
               ? ["Tuần đầu tạ nhẹ hơn khoảng 15%", "Tăng lại dần khi bạn làm đủ rep", "Có chỗ đau thì app đổi bài tránh chỗ đó"]
               : ["Tạ khởi điểm theo kinh nghiệm của bạn", "Sửa ở set đầu, các set sau tự cập nhật", "Máy đang có người? Đổi bài trong một chạm"])
        return FullBleedStory(photo: photo, eyebrow: isNew ? "Cho người mới" : (back ? "Cho người quay lại" : "Cho người đã tập"), title: title, detail: detail) {
            // Các dòng tự chạy lần lượt rồi tự sang màn sau, không cần bấm.
            AutoFixList(items: items, instant: reassureSeen)
        }
    }

    // MARK: 7. Điều hay làm bạn bỏ tập (gộp câu rào cản + tự đánh giá của app cũ)

    static let obstacleList: [(String, String)] = [
        ("Không có thời gian", "clock"), ("Không biết nên tập gì", "questionmark.circle"), ("Thiếu động lực", "battery.25"),
        ("Đau mỏi hoặc chấn thương", "bandage"), ("Không đủ dụng cụ", "dumbbell"), ("Không thấy mình tiến bộ", "chart.line.flattrend.xyaxis")
    ]

    private var obstacleQuestion: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                QuestionTitle(title: "Điều gì hay làm bạn bỏ tập?", subtitle: "Chọn tối đa 3. Dopafit sẽ cho bạn thấy cách xử lý từng điều.")
                ForEach(Array(Self.obstacleList.enumerated()), id: \.offset) { _, o in
                    let on = obstacles.contains(o.0)
                    Button {
                        if on { obstacles.removeAll { $0 == o.0 } } else if obstacles.count < 3 { obstacles.append(o.0) }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: o.1).font(T.font(18, .semibold)).foregroundStyle(on ? T.lime : T.sub).frame(width: 28)
                            Text(o.0).font(T.font(16, .medium)).foregroundStyle(T.text)
                            Spacer()
                            Image(systemName: on ? "checkmark.square.fill" : "square").font(T.font(20)).foregroundStyle(on ? T.lime : T.faint)
                        }
                        .padding(16).background(T.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(on ? T.lime.opacity(0.6) : T.line))
                    }.buttonStyle(.plain)
                }
                Text("\(obstacles.count)/3").font(T.num(13, .semibold)).foregroundStyle(T.faint).frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, T.pad)
        }
    }

    // MARK: 8. Kể chuyện theo đúng câu trả lời (lời văn từ app cũ)

    /// (ảnh, tiêu đề, mô tả, cách Dopafit xử lý, biểu tượng)
    private func storyData(_ o: String) -> (String, String, String, String, String) {
        switch o {
        case "Không có thời gian":
            return ("photo-pushup", "Lúc nào cũng có lý do nghỉ.", "Lý do để nghỉ lúc nào cũng có, và mỗi buổi bỏ lỡ lại khiến bắt đầu khó hơn.", "Chỉ có 20 phút? Bấm “Ít thời gian”, buổi tập tự gói lại cho vừa.", "timer")
        case "Không biết nên tập gì":
            return ("photo-pullup", "Có plan của riêng bạn.", "Plan trên mạng không biết bạn tập ở đâu, mạnh tới đâu, hôm nay có mệt không.", "Mỗi ngày Dopafit cho bạn biết hôm nay tập gì, bao nhiêu set, tạ bao nhiêu.", "list.bullet.clipboard")
        case "Thiếu động lực":
            return ("photo-bench", "Cố mãi chưa thấy thay đổi?", "Gương không đổi, cân cũng không. Cố mãi mà chẳng thấy gì, bỏ cuộc là chuyện dễ nhất.", "Con số không nói dối: mỗi buổi bạn thấy tạ, rep và kỷ lục của mình tăng lên.", "trophy")
        case "Đau mỏi hoặc chấn thương":
            return ("photo-back", "Đau một chỗ, không nghỉ hết.", "Nhiều người bỏ tập cả tháng chỉ vì một chỗ đau nhỏ.", "Bấm “Đang đau”, chọn chỗ đau, app đổi hoặc giảm những bài dồn lực vào đó.", "bandage")
        case "Không đủ dụng cụ":
            return ("photo-crunch", "Thiếu máy vẫn tập được.", "Thiếu máy không phải lý do để dừng.", "Chọn “Ở nhà” hoặc “Phòng gym nhỏ”, app chỉ xếp bài làm được với dụng cụ bạn có.", "house")
        default:
            return ("photo-deadlift", "Nặng hơn chưa chắc là tiến bộ.", "Bạn không biết hôm nay mình có nâng nặng hơn tháng trước không. Cảm giác thì hay đánh lừa.", "Dopafit ghi từng set và vẽ đường sức mạnh của từng bài.", "chart.line.uptrend.xyaxis")
        }
    }

    private func story(_ o: String) -> some View {
        let d = storyData(o)
        return FullBleedStory(photo: d.0, eyebrow: o, title: d.1, detail: d.2) { FixLine(text: d.3) }
    }

    private var core: some View {
        FullBleedStory(photo: "photo-legpress", eyebrow: "Điều Dopafit làm khác", title: "Bạn chỉ thiếu một hệ thống.",
                       detail: "Tập theo cảm giác thì khó biết mình có tiến bộ hay không.") {
            FixLine(text: "Hết đoán mò mức tạ. Dopafit báo lúc nên tăng, lúc nên giữ và giải thích vì sao.")
        }
    }

    // MARK: 9–11. Nơi tập, lịch, về bạn

    private var place: some View {
        ChoiceList(title: "Bạn thường tập ở đâu?", subtitle: "App chỉ xếp những bài làm được với dụng cụ ở đó. Đổi lúc nào cũng được.",
                   items: Profile.Place.allCases.map { ($0.name, $0.detail, $0.icon) },
                   selected: Profile.Place.allCases.firstIndex(of: p.place)) { i in p.place = Profile.Place.allCases[i]; next() }
    }

    private var schedule: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                QuestionTitle(title: "Mỗi tuần bạn tập mấy buổi?", subtitle: "Chọn mức giữ được cả khi bận. Ít mà đều tốt hơn nhiều mà bỏ.")
                VStack(spacing: 4) {
                    Text("\(p.daysPerWeek)").font(T.num(76)).foregroundStyle(T.text)
                    Text("buổi mỗi tuần").font(T.font(14, .semibold)).foregroundStyle(T.sub)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 8)
                HStack(spacing: 8) {
                    ForEach(2...6, id: \.self) { d in
                        pill("\(d)", selected: p.daysPerWeek == d) { p.daysPerWeek = d }
                    }
                }
                Text(splitText).font(T.font(14)).foregroundStyle(T.sub)
                Text("Mỗi buổi khoảng").font(T.font(17, .semibold)).foregroundStyle(T.text).padding(.top, 6)
                HStack(spacing: 8) {
                    ForEach([30, 45, 60, 75], id: \.self) { m in
                        pill("\(m) phút", selected: p.minutes == m) { p.minutes = m }
                    }
                }
            }
            .padding(.horizontal, T.pad)
        }
    }

    private func pill(_ t: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(t).font(T.num(17, .bold))
                .frame(maxWidth: .infinity).frame(height: 54)
                .foregroundStyle(selected ? Color.black : T.text)
                .background(selected ? T.lime : T.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }.buttonStyle(.plain)
    }

    private var splitText: String {
        switch p.daysPerWeek {
        case 2: return "2 buổi toàn thân, luân phiên A và B."
        case 3: return "3 buổi: đẩy, kéo, chân."
        case 4: return "4 buổi: thân trên và thân dưới, mỗi kiểu 2 lần."
        default: return "\(p.daysPerWeek) buổi: đẩy, kéo, chân, thân trên, thân dưới."
        }
    }

    private var about: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                QuestionTitle(title: "Gần xong rồi. Về bạn", subtitle: "Chỉ dùng để tính tạ khởi điểm. Dữ liệu nằm trên máy của bạn.")
                Card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tên gọi (không bắt buộc)").font(T.font(14, .semibold)).foregroundStyle(T.sub)
                        TextField("Ví dụ: Minh", text: $p.name).font(T.font(18, .semibold)).textInputAutocapitalization(.words)
                    }
                }
                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Giới tính").font(T.font(14, .semibold)).foregroundStyle(T.sub)
                        HStack(spacing: 8) {
                            ForEach(Profile.Sex.allCases, id: \.self) { s in
                                Button { p.sex = s } label: {
                                    Text(s.name).font(T.font(15, .semibold))
                                        .frame(maxWidth: .infinity).frame(height: 44)
                                        .foregroundStyle(p.sex == s ? Color.black : T.text)
                                        .background(p.sex == s ? Color.white : T.raised)
                                        .clipShape(Capsule())
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                }
                Card {
                    StepperRow(title: "Tuổi", value: "\(p.age)", unit: "tuổi",
                               minus: { p.age = max(14, p.age - 1) }, plus: { p.age = min(90, p.age + 1) })
                }
                Card {
                    VStack(spacing: 14) {
                        StepperRow(title: "Cân nặng", value: Fmt.n(p.unit.fromKg(p.bodyKg), digits: 0), unit: p.unit.label,
                                   minus: { p.bodyKg = max(35, p.bodyKg - p.unit.toKg(1)) }, plus: { p.bodyKg = min(200, p.bodyKg + p.unit.toKg(1)) })
                        Divider().overlay(T.line)
                        HStack {
                            Text("Đơn vị tạ").font(T.font(15, .semibold)).foregroundStyle(T.sub)
                            Spacer()
                            Picker("Đơn vị", selection: $p.unit) {
                                Text("kg").tag(WeightUnit.kg)
                                Text("lb").tag(WeightUnit.lb)
                            }.pickerStyle(.segmented).frame(width: 140)
                        }
                    }
                }
            }
            .padding(.horizontal, T.pad).padding(.bottom, 12)
        }
    }

    // MARK: 12. Đang lên plan

    private var buildingLines: [String] {
        var l = ["Mục tiêu: " + p.goal.name.lowercased(), "Chọn bài cho " + p.place.name.lowercased(),
                 "Tạ khởi điểm cho người tập " + p.level.name.lowercased()]
        if p.recent == .returning { l.append("Tuần đầu nhẹ hơn vì bạn đang quay lại") }
        for o in obstacles.prefix(2) { l.append("Cách xử lý khi “" + o.lowercased() + "”") }
        l.append("Lịch \(p.daysPerWeek) buổi, \(p.minutes) phút mỗi buổi")
        return l
    }

    // MARK: 13. Hiện plan: khoảnh khắc đẹp nhất

    private var reveal: some View {
        let plan = state.buildPlan()
        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PhotoBox(name: coverPhoto(for: plan.name), height: 170)
                    .overlay(LinearGradient(colors: [.clear, T.bg], startPoint: .center, endPoint: .bottom))
                    .clipShape(RoundedRectangle(cornerRadius: T.radius, style: .continuous))
                Eyebrow(text: "Plan đã xong", color: T.lime)
                Headline(p.name.isEmpty ? "Ngày đầu là hôm nay." : "\(p.name), bắt đầu hôm nay.")
                    .foregroundStyle(T.text).oneLineTitle()
                Text("Bạn chỉ cần có mặt, plan lo phần còn lại.").font(T.font(16)).foregroundStyle(T.sub)
                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Buổi 1").font(T.font(14, .semibold)).foregroundStyle(T.sub)
                            Spacer()
                            Text("~\(plan.minutes) phút").font(T.num(14, .semibold)).foregroundStyle(T.sub)
                        }
                        Text(plan.name).font(T.font(24, .bold)).foregroundStyle(T.text)
                        ForEach(plan.items) { it in
                            HStack(spacing: 12) {
                                ExerciseTile(exercise: it.exercise, size: 44)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(it.exercise.name).font(T.font(15, .semibold)).foregroundStyle(T.text).lineLimit(1)
                                    Text("\(it.sets.count) × \(it.targetReps)" + (it.exercise.bodyweightOnly ? "" : " · " + Fmt.w(it.sets.first?.weightKg ?? 0, p.unit)))
                                        .font(T.num(13, .semibold)).foregroundStyle(T.sub)
                                }
                            }
                        }
                    }
                }
                HStack(spacing: 24) {
                    BigStat(value: "\(p.daysPerWeek)", unit: "buổi", label: "mỗi tuần", accent: true, size: 30)
                    BigStat(value: "\(state.templates.count)", unit: "kiểu buổi", label: "luân phiên", size: 30)
                }
            }
            .padding(.horizontal, T.pad).padding(.bottom, 12)
        }
    }

    // MARK: 14. Lời hứa nhỏ, tự chọn

    private var promiseDays: [Date] {
        (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: Calendar.current.startOfDay(for: Date())) }
    }

    private var promise: some View {
        let chosen = p.firstDay ?? promiseDays[0]
        return ScrollView {
            VStack(spacing: 18) {
                Text("Lời hứa với chính mình").font(T.font(14, .semibold)).foregroundStyle(T.sub).padding(.top, 12)
                Text("Buổi đầu tiên, tôi sẽ tập vào").font(T.font(20, .medium)).foregroundStyle(T.sub)
                Text(dayName(chosen)).font(T.num(34)).foregroundStyle(T.text).multilineTextAlignment(.center)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                    ForEach(promiseDays, id: \.self) { d in
                        let on = Calendar.current.isDate(d, inSameDayAs: chosen)
                        Button { p.firstDay = d } label: {
                            VStack(spacing: 4) {
                                Text(shortWeekday(d)).font(T.font(12, .semibold))
                                Text("\(Calendar.current.component(.day, from: d))").font(T.num(17, .bold))
                            }
                            .frame(maxWidth: .infinity).frame(height: 60)
                            .foregroundStyle(on ? Color.black : T.text)
                            .background(on ? Color.white : T.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }.buttonStyle(.plain)
                    }
                }
                Text("Chỉ cần đừng bỏ giữa chừng.").font(T.font(20, .semibold)).foregroundStyle(T.text).oneLineTitle(bottom: 4)
                    .multilineTextAlignment(.center).padding(.top, 8)
                Text("\(p.daysPerWeek) buổi mỗi tuần · \(p.minutes) phút mỗi buổi").font(T.font(15)).foregroundStyle(T.sub)
            }
            .padding(.horizontal, T.pad)
        }
        .onAppear { if p.firstDay == nil { p.firstDay = promiseDays[0] } }
    }

    /// Giữ để hứa: hành động có chủ ý giúp người dùng nhớ lời hứa. Không dùng biểu tượng vân tay.
    private var holdButton: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().stroke(T.raised, lineWidth: 5)
                Circle().trim(from: 0, to: holding || promised ? 1 : 0)
                    .stroke(T.lime, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(holding ? .linear(duration: 1.2) : .easeOut(duration: 0.2), value: holding)
                Image(systemName: promised ? "checkmark" : "hand.raised.fill")
                    .font(T.font(30, .bold)).foregroundStyle(promised ? Color.black : T.text)
                    .frame(width: 76, height: 76)
                    .background(Circle().fill(promised ? T.lime : T.surface))
            }
            .frame(width: 92, height: 92)
            .contentShape(Circle())
            .onLongPressGesture(minimumDuration: 1.2, maximumDistance: 60, perform: {
                promised = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { next() }
            }, onPressingChanged: { holding = $0 })
            .accessibilityElement()
            .accessibilityLabel("Giữ để hứa")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { promised = true; next() }
            Text(promised ? "Đã hứa" : "Giữ để hứa").font(T.font(16, .bold)).foregroundStyle(T.text)
            Text("Nhấn giữ khoảng 1 giây").font(T.font(13)).foregroundStyle(T.sub)
        }
        .frame(maxWidth: .infinity)
    }

    private func dayName(_ d: Date) -> String {
        if Calendar.current.isDateInToday(d) { return "Hôm nay" }
        if Calendar.current.isDateInTomorrow(d) { return "Ngày mai" }
        return Fmt.day(d)
    }
    private func shortWeekday(_ d: Date) -> String {
        let w = Calendar.current.component(.weekday, from: d)
        return w == 1 ? "CN" : "T\(w)"
    }

    // MARK: 15. Nhắc giờ: hỏi đúng lúc, có lý do

    private static let reminderHours: [(Int, String)] = [(6, "Sáng sớm"), (12, "Buổi trưa"), (18, "Sau giờ làm"), (20, "Buổi tối")]

    private var reminder: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                QuestionTitle(title: "Nhắc bạn lúc mấy giờ?", subtitle: "Dopafit nhắc vào " + dayName(p.firstDay ?? Date()).lowercased() + " và các ngày tập sau. Đổi hoặc tắt trong Cài đặt.")
                ForEach(Array(Self.reminderHours.enumerated()), id: \.offset) { _, h in
                    let on = p.reminderHour == h.0
                    Button { p.reminderHour = on ? nil : h.0 } label: {
                        HStack {
                            Text("\(h.0):00").font(T.num(22)).foregroundStyle(T.text).frame(width: 84, alignment: .leading)
                            Text(h.1).font(T.font(16)).foregroundStyle(T.sub)
                            Spacer()
                            Image(systemName: on ? "checkmark.circle.fill" : "circle").font(T.font(22)).foregroundStyle(on ? T.lime : T.faint)
                        }
                        .padding(16).background(T.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(on ? T.lime.opacity(0.6) : T.line))
                    }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, T.pad)
        }
    }

    private func scheduleReminder(hour: Int) {
        let center = UNUserNotificationCenter.current()
        let day = p.firstDay ?? Date()
        let name = state.buildPlan().name
        center.requestAuthorization(options: [.alert, .sound]) { ok, _ in
            guard ok else { return }
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: day)
            comps.hour = hour
            let content = UNMutableNotificationContent()
            content.title = "Buổi đầu của bạn: \(name)"
            content.body = "Chỉ cần có mặt, plan lo phần còn lại."
            let req = UNNotificationRequest(identifier: "first-workout", content: content, trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false))
            center.add(req)
        }
    }

    // MARK: 16. Lưu plan

    private var save: some View {
        let planName = state.buildPlan().name
        return VStack(alignment: .leading, spacing: 18) {
            QuestionTitle(title: "Lưu plan của bạn", subtitle: "Tạo tài khoản để không mất plan và lịch sử tập khi đổi máy.")
            Card {
                VStack(alignment: .leading, spacing: 12) {
                    InfoLine(icon: "checkmark", text: "Buổi 1 “\(planName)” và \(state.templates.count - 1) kiểu buổi còn lại", color: T.text)
                    InfoLine(icon: "checkmark", text: "Lịch \(p.daysPerWeek) buổi mỗi tuần, buổi đầu " + dayName(p.firstDay ?? Date()).lowercased(), color: T.text)
                    InfoLine(icon: "checkmark", text: "Mọi set bạn ghi từ hôm nay", color: T.text)
                }
            }
            Text("Khi tiếp tục, bạn đồng ý với Điều khoản và Chính sách riêng tư.").font(T.font(12)).foregroundStyle(T.faint)
        }
        .padding(.horizontal, T.pad)
    }
}

// MARK: - Thành phần dùng chung trong thiết lập

struct QuestionTitle: View {
    var title: String
    var subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(T.font(26, .bold)).foregroundStyle(T.text).oneLineTitle(bottom: 2)
            Text(subtitle).font(T.font(15)).foregroundStyle(T.sub).bodyLines(15).fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 16).padding(.bottom, 16)
    }
}

/// Danh sách một lựa chọn: chọn là tự đi tiếp (bớt một lần bấm "Tiếp tục").
struct ChoiceList: View {
    var title: String
    var subtitle: String
    var items: [(String, String?, String?)]
    var selected: Int?
    var pick: (Int) -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                QuestionTitle(title: title, subtitle: subtitle)
                ForEach(items.indices, id: \.self) { i in
                    Button { pick(i) } label: {
                        HStack(spacing: 14) {
                            if let icon = items[i].2 {
                                Image(systemName: icon).font(T.font(18, .semibold)).frame(width: 28)
                                    .foregroundStyle(i == selected ? T.lime : T.sub)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(items[i].0).font(T.font(17, .semibold)).foregroundStyle(T.text)
                                if let d = items[i].1 { Text(d).font(T.font(14)).foregroundStyle(T.sub) }
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(T.font(14, .bold)).foregroundStyle(i == selected ? T.lime : T.faint)
                        }
                        .padding(16)
                        .background(T.surface)
                        .clipShape(RoundedRectangle(cornerRadius: T.radius, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: T.radius, style: .continuous).stroke(i == selected ? T.lime.opacity(0.6) : T.line, lineWidth: i == selected ? 1.5 : 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, T.pad)
        }
    }
}

/// "Đang lên plan": hiện từng dòng lấy từ câu trả lời, để người dùng thấy công sức của mình được dùng.
struct BuildingPlanView: View {
    var lines: [String]
    var done: () -> Void
    @State private var shown = 0
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer()
            Text("Đang lên plan cho bạn…").font(T.font(26, .bold)).foregroundStyle(T.text).oneLineTitle()
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(lines.enumerated()), id: \.offset) { i, l in
                    HStack(spacing: 12) {
                        Image(systemName: i < shown ? "checkmark.circle.fill" : "circle.dotted")
                            .font(T.font(18)).foregroundStyle(i < shown ? T.lime : T.faint)
                        Text(l).font(T.font(16)).foregroundStyle(i < shown ? T.text : T.faint)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, T.pad)
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            for i in 1...max(1, lines.count) {
                try? await Task.sleep(nanoseconds: 450_000_000)
                withAnimation(.snappy) { shown = i }
            }
            try? await Task.sleep(nanoseconds: 500_000_000)
            done()
        }
    }
}

struct StepperRow: View {
    var title: String
    var value: String
    var unit: String
    var minus: () -> Void
    var plus: () -> Void
    var body: some View {
        HStack {
            Text(title).font(T.font(15, .semibold)).foregroundStyle(T.sub)
            Spacer()
            RoundStep(icon: "minus", label: "Giảm " + title.lowercased(), action: minus)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value).font(T.num(26))
                Text(unit).font(T.font(13, .semibold)).foregroundStyle(T.sub)
            }
            .frame(minWidth: 92)
            RoundStep(icon: "plus", label: "Tăng " + title.lowercased(), action: plus)
        }
    }
}

struct RoundStep: View {
    var icon: String
    var label: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon).font(T.font(16, .bold)).foregroundStyle(T.text)
                .frame(width: 44, height: 44).background(T.raised).clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .buttonRepeatBehavior(.enabled)
    }
}


/// Danh sách điểm cộng tự chạy: vạch xanh từng dòng đầy dần như thanh tải, chữ sáng lên theo,
/// `instant` = đã xem rồi, hiện đủ ngay.
struct AutoFixList: View {
    var items: [String]
    var instant = false
    @State private var progress: [CGFloat] = []

    /// Tổng thời gian chạy hết n dòng (để màn cha biết lúc nào tự đi tiếp).
    static func duration(_ n: Int) -> UInt64 { UInt64(350 + n * 950 + 900) * 1_000_000 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, it in
                let p = i < progress.count ? progress[i] : 0
                HStack(alignment: .top, spacing: 12) {
                    Rectangle().fill(T.raised).frame(width: 2)
                        .overlay(alignment: .top) {
                            GeometryReader { g in
                                Rectangle().fill(T.lime).frame(height: g.size.height * p)
                            }
                        }
                    Text(it).font(T.font(16, .medium)).foregroundStyle(T.text).bodyLines(16)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(0.3 + 0.7 * p)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
            }
        }
        .accessibilityElement(children: .combine)
        .task {
            progress = Array(repeating: instant ? 1 : 0, count: items.count)
            guard !instant else { return }
            try? await Task.sleep(nanoseconds: 350_000_000)
            for i in items.indices {
                withAnimation(.easeInOut(duration: 0.7)) { progress[i] = 1 }
                try? await Task.sleep(nanoseconds: 950_000_000)
                if Task.isCancelled { return }
            }
        }
    }
}
