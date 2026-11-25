import DistortionWavesKit
import SwiftUI
import UserNotifications

/// Thiết lập ban đầu: kết hợp câu hỏi & lời văn của app cũ với luồng theo tâm lý người dùng.
/// Nguyên tắc: câu dễ trước, câu nhạy cảm sau; mỗi câu trả lời đều được app dùng và nói lại cho người dùng thấy;
/// kết thúc bằng màn plan cụ thể; không đếm ngược giả, không hỏi lặp.
struct OnboardingFlow: View {
    @EnvironmentObject var state: AppState
    @State private var reassureSeen = false
    @State private var generatedPlan: PlannedWorkout? = nil
    @State private var index = ProcessInfo.processInfo.arguments.contains("--skip-welcome") ? 1 : 0
    @State private var p = Profile()
    @State private var initializedSex = false
    @State private var obstacles: [String] = []
    @State private var desires: [String] = []
    @State private var injured: [Joint] = []
    @State private var journeyPicked: Int? = nil
    @State private var promised = false
    @State private var holdFrame: CGRect = .zero     // nút "Giữ để hứa", toạ độ màn hình
    @State private var waveFrame: CGRect = .zero     // vùng sóng, toạ độ màn hình
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showAccountNote = false
    @State private var showLoginNote = false
    @State private var lastAdvance = Date.distantPast
    @State private var editingAnswer: Step?
    @State private var answerSnapshot: AnswerSnapshot?

    private struct AnswerSnapshot {
        var profile: Profile
        var desires: [String]
        var obstacles: [String]
        var injuries: [Joint]
        var journey: Int?
    }

    init() {
        var profile = Profile()
        profile.sex = .other
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if Bundle.main.bundleIdentifier?.hasSuffix(".designqa") == true,
           let flag = args.firstIndex(of: "--preview-step"), args.indices.contains(flag + 1) {
            let preview = args[flag + 1]
            if args.contains("--preview-female") { profile.sex = .female }
            if args.contains("--preview-round") { profile.currentShape = .round; profile.targetShape = .balanced }
            if args.contains("--preview-strength") { profile.goal = .strength }
            if let goalFlag = args.firstIndex(of: "--preview-goal"), args.indices.contains(goalFlag + 1),
               let goal = Profile.Goal(rawValue: args[goalFlag + 1]) { profile.goal = goal }
            if let flag = args.firstIndex(of: "--preview-target-kg"), args.indices.contains(flag + 1),
               let kg = Double(args[flag + 1]), (35...180).contains(kg) { profile.targetKg = kg }
            if preview == "break" || args.contains("--preview-returning") { profile.recent = .returning }
            let targets: [String: Step] = ["welcome": .welcome, "sex": .sex, "desire": .desire, "goal": .goal,
                "echo": .echo, "transformation": .transformation, "activity": .activity,
                "weight": .weight, "level": .level, "recent": .recent, "break": .breakDuration,
                "promise": .promise, "reminder": .reminder, "focus": .focus, "current-shape": .currentShape,
                "target-shape": .targetShape, "target-weight": .targetWeight,
                "obstacles": .obstacles, "potential": .potential, "reward": .reward,
                "reassure": .reassure, "place": .place, "schedule": .schedule, "building": .building, "forecast": .forecast, "overview": .reveal, "injuries": .injuries, "review": .save]
            if let flag = args.firstIndex(of: "--preview-target-shape"), args.indices.contains(flag + 1),
               let shape = Profile.BodyGoal(rawValue: args[flag + 1]) { profile.targetShape = shape }
            if let flag = args.firstIndex(of: "--preview-current-shape"), args.indices.contains(flag + 1),
               let shape = Profile.BodyShape(rawValue: args[flag + 1]) { profile.currentShape = shape }
            var previewObstacles: [String] = []
            if let flag = args.firstIndex(of: "--preview-story"), args.indices.contains(flag + 1) {
                let name = args[flag + 1]
                if Self.obstacleList.contains(where: { $0.0 == name }) { previewObstacles = [name] }
            }
            _obstacles = State(initialValue: previewObstacles)
            if let flag = args.firstIndex(of: "--preview-injury"), args.indices.contains(flag + 1),
               let joint = Joint(rawValue: args[flag + 1]) { profile.injuries = [joint]; _injured = State(initialValue: [joint]) }
            if args.contains("--preview-back-focus") { profile.focusAreas = [.back] }
            let ordered = Self.makeSteps(profile: profile, obstacles: previewObstacles)
            if preview == "story", let name = previewObstacles.first {
                _index = State(initialValue: ordered.firstIndex(of: .story(name)) ?? 0)
            } else {
            _index = State(initialValue: ordered.firstIndex(of: targets[preview] ?? .welcome) ?? 0)
            }
        }
        #endif
        _p = State(initialValue: profile)
    }

    enum Step: Hashable {
        case welcome, sex, desire, goal, echo, focus, currentShape, targetShape, targetWeight, transformation, activity, weight, level, recent, breakDuration, reassure, statement, injuries, obstacles, story(String), potential, reward, core, place, schedule, building, forecast, reveal, promise, reminder, save
        var phase: String {
            switch self {
            case .welcome, .sex, .desire, .goal, .echo: return "Mục tiêu"
            case .focus, .currentShape, .targetShape, .targetWeight, .transformation, .activity, .weight: return "Cơ thể"
            case .level, .recent, .breakDuration, .reassure, .statement, .injuries, .obstacles, .story, .potential, .reward, .core, .place, .schedule: return "Tập luyện"
            default: return "Kế hoạch"
            }
        }
    }

    private static func makeSteps(profile: Profile, obstacles: [String]) -> [Step] {
        var steps: [Step] = [.welcome, .sex, .desire, .goal, .echo, .focus, .currentShape, .targetShape,
                             .weight, .targetWeight, .transformation, .activity, .level, .recent]
        if profile.recent == .returning { steps.append(.breakDuration) }
        steps += [.reassure, .injuries, .obstacles]
        var followups = obstacles
        if !(profile.injuries ?? []).isEmpty {
            followups.removeAll { $0 == "Đau mỏi hoặc chấn thương" }
            followups.insert("Đau mỏi hoặc chấn thương", at: 0)
        }
        steps += followups.prefix(2).map { Step.story($0) }
        steps += [.potential, .reward, .place, .schedule, .building, .forecast, .reveal, .promise, .reminder, .save]
        return steps
    }
    private var contextProfile: Profile {
        var profile = p
        profile.injuries = injured
        profile.desires = desires
        profile.obstacles = obstacles
        return profile
    }
    private var steps: [Step] { Self.makeSteps(profile: contextProfile, obstacles: obstacles) }
    private var step: Step {
        // Conditional stories can change the route's length while editing. Keep
        // the review behind the sheet until Apply or Cancel resolves the draft.
        editingAnswer != nil ? .save : steps[min(index, steps.count - 1)]
    }

    var body: some View {
        Group {
            if step == .promise {
                GeometryReader { geometry in
                    DistortionWave(isRevealed: promised,
                                   source: holdFrame.offsetBy(dx: -waveFrame.minX, dy: -waveFrame.minY),
                                   style: promiseWaveStyle,
                                   onFinish: { advanceAfterPromise() }) {
                        promiseStage(top: geometry.safeAreaInsets.top, bottom: geometry.safeAreaInsets.bottom)
                    } revealed: {
                        promiseStage(top: geometry.safeAreaInsets.top, bottom: geometry.safeAreaInsets.bottom)
                    }
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { waveFrame = $0 }
                    .overlay(alignment: .bottom) { holdButton.padding(.bottom, geometry.safeAreaInsets.bottom + 20) }
                    .ignoresSafeArea()
                }
            } else {
        VStack(spacing: 0) {
            if step != .welcome && step != .building { header }
            Group {
                switch step {
                case .welcome: welcome
                case .sex: SexSetupStep(selection: $p.sex)
                case .desire: desire
                case .goal: goal
                case .echo: echo
                case .focus: BodyFocusStep(selection: $p.focusAreas, sex: p.sex)
                case .currentShape: CurrentShapeStep(selection: $p.currentShape, sex: p.sex)
                case .targetShape: TargetShapeStep(selection: $p.targetShape, current: p.currentShape, sex: p.sex, goal: p.goal)
                case .targetWeight: WeightGoalStep(profile: $p)
                case .potential: PotentialStep(plan: previewPlan, unit: p.unit)
                case .reward: RewardStep(selection: $p.reward, sex: p.sex)
                case .transformation: TransformationStep(goal: p.goal, current: p.currentShape, target: p.targetShape, belly: nil, sex: p.sex)
                case .activity: ActivityLevelStep(selection: $p.activity, sex: p.sex)
                case .weight: weightStep
                case .injuries: injuriesStep
                case .statement: statement
                case .level: level
                case .recent: recent
                case .breakDuration: TrainingBreakStep(selection: $p.trainingBreak)
                case .reassure: reassure
                case .obstacles: obstacleQuestion
                case .story(let o): story(o)
                case .core: core
                case .place: place
                case .schedule: schedule
                case .building: BuildingPlanView(profile: p) { next() }
                case .forecast: WeightDirectionStep(profile: p)
                case .reveal: reveal
                case .promise: EmptyView() // Rendered by the full-screen wave stage.
                case .reminder: reminder
                case .save: save
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .transition(.push(from: .trailing))
            .id(index)
        }
            }
        }
        .screenBackground()
        .onAppear {
            guard !initializedSex else { return }
            #if DEBUG
            if Bundle.main.bundleIdentifier?.hasSuffix(".designqa") == true,
               ProcessInfo.processInfo.arguments.contains("--preview-saved-answers") {
                p = state.data.profile
                desires = p.desires ?? []; obstacles = p.obstacles ?? []; injured = p.injuries ?? []
                journeyPicked = p.recent.map { [.regular, .onOff, .returning].firstIndex(of: $0) ?? 3 } ?? 3
                index = steps.firstIndex(of: .save) ?? index
            }
            #endif
            // Keep a known profile preference when rerunning setup; never infer it from a stock model.
            if state.data.profile != Profile(), !ProcessInfo.processInfo.arguments.contains("--preview-female") { p.sex = state.data.profile.sex }
            // Removed questions keep known profile values; no new age/height is invented.
            p.age = state.data.profile.age
            p.heightCm = state.data.profile.heightCm
            p.intensity = state.data.profile.intensity
            initializedSex = true
        }
        // The wave stage owns its live source overlay; ordinary pages keep their footer.
        .safeAreaInset(edge: .bottom) { footer.background(T.bg) }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.24), value: index)
        .onChange(of: contextProfile) { _, _ in generatedPlan = nil }
        .onChange(of: index) { _, _ in
            // A return to the commitment step starts a fresh gesture and wave.
            if step == .promise { promised = false }
        }
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
        .sheet(isPresented: Binding(get: { editingAnswer != nil }, set: { if !$0 { cancelAnswerEdit() } })) {
            answerEditor
                .interactiveDismissDisabled()
        }
    }

    private func next() {
        // Auto-advance choices become ordinary selections in the review editor.
        guard editingAnswer == nil else { return }
        // Chặn bấm đúp: nút "Tiếp tục" của màn sau xuất hiện đúng chỗ ngón tay vừa bấm.
        guard Date().timeIntervalSince(lastAdvance) > 0.45 else { return }
        lastAdvance = Date()
        if step == .schedule { saveAnswers(); generatedPlan = state.buildPlan(profile: p) }
        if index < steps.count - 1 { index += 1 } else { finish() }
    }

    private func saveAnswers() {
        p.obstacles = obstacles
        p.desires = desires
        p.injuries = injured
    }

    private func finish() {
        saveAnswers()
        state.data.profile = p
        // Request only after the reviewed choices are committed, never on a draft edit.
        if let hour = p.reminderHour { scheduleReminder(hour: hour) }
        state.data.onboarded = true
    }

    // MARK: Đầu & cuối

    /// Thanh tiến độ 3 chặng như app cũ, nhưng nhích nhanh ở đầu để người dùng thấy mình đi được xa.
    private static let phases = ["Mục tiêu", "Cơ thể", "Tập luyện", "Kế hoạch"]

    private var header: some View {
        let cur = Self.phases.firstIndex(of: step.phase) ?? 0
        let idx = steps.indices.filter { steps[$0].phase == step.phase }
        let within = idx.isEmpty ? 0 : CGFloat((idx.firstIndex(of: min(index, steps.count - 1)) ?? 0) + 1) / CGFloat(idx.count)
        return HStack(spacing: 14) {
            Button { index = max(0, index - 1) } label: {
                Image(systemName: "chevron.left").font(T.font(18, .medium))
                    .foregroundStyle(T.text).frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }.buttonStyle(.plain).accessibilityLabel("Quay lại").disabled(promised && step == .promise)
            if step == .desire {
                PhaseProgress(phases: Self.phases, current: cur, within: within)
                    .padding(.leading, 24).padding(.trailing, 52)
                    .accessibilityLabel("Thiết lập mục tiêu, chặng \(cur + 1) trong 4")
            } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(step.phase).font(T.font(14, .medium)).foregroundStyle(T.sub)
                    Spacer()
                    Text("\(cur + 1) / 4").font(T.num(12, .medium)).foregroundStyle(T.faint)
                }
                PhaseProgress(phases: Self.phases, current: cur, within: within)
            }
            }
        }
        .padding(.leading, 8).padding(.trailing, T.pad).padding(.top, 8).padding(.bottom, 8)
    }

    @ViewBuilder private var footer: some View {
        switch step {
        case .welcome, .building, .recent, .place, .statement:
            EmptyView() // chọn là tự đi tiếp
        case .goal, .transformation, .activity, .focus, .targetShape, .targetWeight, .potential:
            BottomBar { PrimaryButton(title: "Tiếp theo") { next() } }
        case .sex:
            BottomBar { PrimaryButton(title: "Tiếp theo", enabled: p.sex != .other) { next() } }
        case .level:
            BottomBar { PrimaryButton(title: "Tiếp theo") { next() } }
        case .currentShape:
            BottomBar { PrimaryButton(title: "Tiếp theo", enabled: p.currentShape != nil) { next() } }
        case .reward:
            BottomBar { PrimaryButton(title: p.reward == nil ? "Bỏ qua" : "Tiếp theo") { next() } }
        case .breakDuration:
            BottomBar { PrimaryButton(title: "Tiếp theo", enabled: p.trainingBreak != nil) { next() } }
        case .desire:
            BottomBar { PrimaryButton(title: "Tiếp theo", enabled: !desires.isEmpty) { next() } }
        case .injuries:
            BottomBar { PrimaryButton(title: injured.isEmpty ? "Không đau chỗ nào" : "Tiếp tục") { next() } }
        case .forecast:
            BottomBar { PrimaryButton(title: "Tiếp theo") { next() } }
        case .reassure:
            // lần đầu tự chạy; quay lại xem thì có nút để đi tiếp
            if reassureSeen { BottomBar { PrimaryButton(title: "Tiếp tục") { next() } } } else { EmptyView() }
        case .obstacles:
            BottomBar { PrimaryButton(title: obstacles.isEmpty ? "Bỏ qua" : "Tiếp tục") { next() } }
        case .reveal:
            BottomBar { PrimaryButton(title: "Chọn ngày bắt đầu") { next() } }
        case .promise:
            EmptyView() // The source control lives inside the wave's coordinate space.
        case .reminder:
            BottomBar {
                PrimaryButton(title: p.reminderHour.map { "Nhắc tôi lúc \($0):00" } ?? "Không cần nhắc", enabled: reminderIsFuture) {
                    next()
                }
            }
        case .save:
            BottomBar {
                PrimaryButton(title: "Lưu plan trên máy", icon: "checkmark") { finish() }
                Button("Tạo tài khoản") { showAccountNote = true }
                    .font(T.font(15, .medium)).foregroundStyle(T.sub).frame(height: 40)
            }
        default:
            BottomBar { PrimaryButton(title: "Tiếp tục") { next() } }
        }
    }

    // MARK: 1. Màn chào

    private var welcome: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                PhotoBox(name: BodyIllustration.hero(p.sex), height: geo.size.height * 0.76, focus: .top)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .overlay(LinearGradient(stops: [
                        .init(color: .clear, location: 0.25),
                        .init(color: T.bg.opacity(0.3), location: 0.43),
                        .init(color: T.bg, location: 0.72)
                    ], startPoint: .top, endPoint: .bottom))
                    .overlay(alignment: .top) {
                        LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .top, endPoint: .bottom)
                            .frame(height: 150).ignoresSafeArea(edges: .top)
                    }
                    .ignoresSafeArea(edges: .top)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        DopafitMark().fill(T.lime).frame(width: 32, height: 20)
                        Text("Dopafit").font(T.font(21, .bold)).foregroundStyle(T.text)
                    }
                    .padding(.top, 16)
                    Spacer(minLength: 20)
                    Text("Mạnh hơn.").foregroundStyle(T.text)
                        .font(T.font(38, .bold))
                    Text("Từng buổi một.").foregroundStyle(T.lime)
                        .font(T.font(38, .bold)).padding(.bottom, 16)
                    Text("Một kế hoạch vừa sức. Ghi lại từng set.\nThấy rõ mình tiến bộ.")
                        .font(T.font(16)).foregroundStyle(T.sub)
                        .fixedSize(horizontal: false, vertical: true).padding(.bottom, 28)
                    PrimaryButton(title: "Bắt đầu thiết lập", icon: "arrow.right") { next() }
                    HStack(spacing: 5) {
                        Text("Đã có tài khoản?").foregroundStyle(T.sub)
                        Button("Đăng nhập") { showLoginNote = true }.foregroundStyle(T.text)
                    }
                    .font(T.font(14)).frame(maxWidth: .infinity).padding(.top, 18)
                    Button("Xem bản demo") { state.loadDemo() }
                        .font(T.font(13)).foregroundStyle(T.sub)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .padding(.horizontal, 24).padding(.bottom, 8)
            }
        }
    }

    // MARK: 2. Mục tiêu (câu dễ, chọn là đi tiếp)

    private var goal: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                QuestionTitle(title: "Mục tiêu [chính] của bạn?", subtitle: "Chọn một. App dùng câu này để chọn số rep và cách tăng tạ.")
                ForEach(Profile.Goal.allCases, id: \.self) { g in
                    GoalPortraitRow(photo: goalPhoto(g), title: g.name, detail: goalDetail(g), selected: p.goal == g, sheetIndex: Profile.Goal.allCases.firstIndex(of: g), sex: p.sex) { p.goal = g }
                }
            }
            .padding(.horizontal, T.pad).padding(.bottom, 12)
        }
    }

    private func goalPhoto(_ g: Profile.Goal) -> String {
        switch g { case .muscle: "vn-person-muscle"; case .strength: "vn-person-lift"; case .lean: "vn-person-confident"; case .health: "vn-person-attractive" }
    }
    private func goalDetail(_ g: Profile.Goal) -> String {
        switch g { case .muscle: "Cơ to và rõ nét hơn"; case .strength: "Nâng nặng hơn mỗi tuần"; case .lean: "Bớt mỡ, giữ cơ"; case .health: "Khỏe, dẻo dai, tập đều" }
    }

    // MARK: 1b. Điều mong muốn nhất (cảm xúc trước, con số sau)

    // Keep the stored answer keys; the visible captions follow the user's reference.
    static let desireList: [(String, String)] = [
        ("Trông gọn và săn hơn", "Trông hấp dẫn hơn"),
        ("Tự tin, nhiều năng lượng", "Tăng sự tự tin &\nsức sống"),
        ("Bớt đau lưng vì ngồi lâu", "Giảm đau do ngồi\nlâu"),
        ("Ngủ ngon, đầu óc nhẹ", "Ngủ ngon hơn")
    ]

    private var desire: some View {
        GeometryReader { geometry in
            let cardHeight = max(216, min(260, (geometry.size.height - 162) / 2))
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Điều bạn mong\nmuốn nhất là gì?")
                        .font(T.font(32, .bold)).foregroundStyle(T.text)
                        .lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 20).padding(.bottom, 60)
                        .accessibilityHint("Chọn tối đa hai điều mong muốn")
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(Array(Self.desireList.enumerated()), id: \.offset) { i, desire in
                            let selected = desires.contains(desire.0)
                            DesireIllustrationCard(index: i, title: desire.1, selected: selected, height: cardHeight, sex: p.sex) {
                                if selected { desires.removeAll { $0 == desire.0 } }
                                else {
                                    if desires.count >= 2 { desires.removeFirst() }
                                    desires.append(desire.0)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: 3. Đáp lại theo mục tiêu (thấy mình được hiểu)

    private func echoText() -> (String, String, String, String) {
        switch p.goal {
        case .muscle: return ("photo-curl", "Tạ tăng đều, cơ tăng theo.", "Dopafit ghi từng set và báo đúng lúc nên tăng tạ.", "+2,5 kg")
        case .strength: return ("photo-deadlift", "Mỗi tuần mạnh hơn chút.", "Sau mỗi buổi, bạn thấy mức tạ ước tính nâng được của từng bài.", "+5 kg")
        case .lean: return ("photo-row", "Tập tạ đều, giữ được cơ.", "Dopafit giữ nhịp tuần cho bạn, kể cả khi bận hay mệt.", "3 buổi")
        case .health: return ("photo-pushup", "Vừa sức nhưng đều đặn.", "Plan vừa sức để bạn không bỏ giữa chừng.", "4 tuần")
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

    /// Equipment illustration and the live plate-loading interaction share one dark stage.
    private var echo: some View {
        let g = goalLift()
        return GeometryReader { geometry in
            let heroHeight = max(160, min(210, geometry.size.height * 0.28))
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ZStack(alignment: .bottomLeading) {
                        PhotoBox(name: "onboarding-plate-hero", height: heroHeight, focus: .trailing)
                        LinearGradient(stops: [
                            .init(color: .clear, location: 0.55),
                            .init(color: T.bg.opacity(0.55), location: 0.82),
                            .init(color: T.bg, location: 1)
                        ], startPoint: .top, endPoint: .bottom)
                        echoHeadline
                            .font(T.font(32, .bold)).lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 24).padding(.bottom, 12)
                    }
                    .frame(height: heroHeight)
                    .padding(.horizontal, -T.pad)
                    PlateLoaderCard(title: g.title, slices: g.slices)
                }
                .padding(.horizontal, T.pad).padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var echoHeadline: Text {
        switch p.goal {
        case .strength:
            Text("Mỗi tuần\n").foregroundColor(T.text) + Text("mạnh hơn").foregroundColor(T.lime) + Text(" chút.").foregroundColor(T.text)
        case .muscle:
            Text("Tạ tăng đều,\n").foregroundColor(T.text) + Text("cơ tăng").foregroundColor(T.lime) + Text(" theo.").foregroundColor(T.text)
        case .lean:
            Text("Tập tạ đều,\n").foregroundColor(T.text) + Text("giữ được cơ.").foregroundColor(T.lime)
        case .health:
            Text("Vừa sức,\n").foregroundColor(T.text) + Text("nhưng đều đặn.").foregroundColor(T.lime)
        }
    }

    // MARK: 4–5. Kinh nghiệm & dạo này tập thế nào (câu của app cũ)

    private var level: some View { ExperienceStep(selection: $p.level) }

    private var recent: some View {
        let items: [(JourneyCurve.Kind, String, String, Profile.Recent?)] = [
            (.up, "😄", "Đang tiến bộ đều", .regular), (.bump, "😅", "Lên được rồi lại bỏ", .onOff),
            (.down, "😮‍💨", "Từng khỏe, giờ đang nghỉ", .returning), (.flat, "😐", "Chưa tập đều bao giờ", nil)
        ]
        return ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                QuestionTitle(title: "Hành trình tập [trước đây]?", subtitle: "Chọn đường giống bạn nhất. Không có câu trả lời sai.")
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(items.indices, id: \.self) { i in
                        let it = items[i]
                        JourneyCard(kind: it.0, face: it.1, title: it.2, selected: journeyPicked == i) {
                            journeyPicked = i
                            p.recent = it.3
                            if it.3 != .returning { p.trainingBreak = nil }
                            next()
                        }
                    }
                }
            }
            .padding(.horizontal, T.pad).padding(.bottom, 12)
        }
    }

    // MARK: Câu nói Đúng/Không: người dùng tự nhận mình trong câu nói

    private static let statementLine = "Tôi thấy khó chọn bài tập phù hợp với mình."
    private static let statementObstacle = "Không biết nên tập gì"

    private var statement: some View {
        VStack(alignment: .leading, spacing: 0) {
            QuestionTitle(title: "Câu này có [giống bạn] không?", subtitle: "Trả lời thật lòng. Nếu đúng, Dopafit chỉ bạn cách xử lý ngay sau đây.")
            Spacer(minLength: 24)
            QuoteBubble(text: Self.statementLine)
            Spacer(minLength: 24)
            HStack(spacing: 12) {
                AnswerTile(icon: "xmark", title: "Không", tint: Color(red: 1, green: 0.42, blue: 0.38)) {
                    obstacles.removeAll { $0 == Self.statementObstacle }
                    next()
                }
                AnswerTile(icon: "checkmark", title: "Đúng vậy", tint: T.lime) {
                    if !obstacles.contains(Self.statementObstacle) { obstacles.insert(Self.statementObstacle, at: 0) }
                    next()
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, T.pad)
    }

    // MARK: 6. Trấn an theo nhóm (bớt lo cho người mới, tôn trọng người đã tập)

    private var reassure: some View {
        let isNew = p.level == .new
        let back = p.recent == .returning
        let title = isNew ? "Mới tập vẫn bắt đầu được." : (back ? "Quay lại, không từ số 0." : "Không phải tập lại từ đầu.")
        let detail = back ? p.trainingBreak.map { "Bạn đã nghỉ \($0.sentence). Bắt đầu lại từng buổi một." } ?? "Bắt đầu lại từng buổi một." : (isNew ? "Mỗi bài có hướng dẫn để bạn bắt đầu từng bước." : "Dopafit tính tới việc bạn đã có nền tảng.")
        let items: [String] = isNew
            ? ["Mỗi bài có video động tác", "Hướng dẫn chỉnh máy, chỉnh ghế trước khi tập", "Tạ khởi điểm nhẹ, tăng dần khi bạn làm đủ rep"]
            : (back
               ? ["Tuần đầu tạ nhẹ hơn khoảng 15%", "Tăng lại dần khi bạn làm đủ rep", "Có chỗ đau thì app đổi bài tránh chỗ đó"]
               : ["Tạ khởi điểm theo kinh nghiệm của bạn", "Chỉnh ở set đầu, các set sau tự cập nhật"])
        return ContextStoryPage(eyebrow: isNew ? "Cho người mới" : (back ? "Cho người quay lại" : "Cho người đã tập"), title: title, detail: detail) {
            ContextStoryVisual(kind: "experience", profile: p, plan: previewPlan)
        } footer: {
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
                QuestionTitle(title: "Điều gì hay làm bạn [bỏ tập]?", subtitle: "Chọn tối đa 3. Cùng tìm cách giữ nhịp tập.")
                ForEach(Array(Self.obstacleList.enumerated()), id: \.offset) { _, o in
                    let on = obstacles.contains(o.0)
                    CheckRow(icon: o.1, title: o.0, on: on) {
                        if on { obstacles.removeAll { $0 == o.0 } } else if obstacles.count < 3 { obstacles.append(o.0) }
                    }
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
            return ("photo-pushup", "Ít thời gian vẫn tập được.", "Gói buổi tập theo khoảng thời gian bạn có.", "Chỉ có 20 phút? Bấm “Ít thời gian”, buổi tập tự gói lại cho vừa.", "timer")
        case "Không biết nên tập gì":
            return ("photo-pullup", "Có plan của riêng bạn.", "Plan trên mạng không biết bạn tập ở đâu, mạnh tới đâu, hôm nay có mệt không.", "Mỗi ngày Dopafit cho bạn biết hôm nay tập gì, bao nhiêu set, tạ bao nhiêu.", "list.bullet.clipboard")
        case "Thiếu động lực":
            return ("photo-bench", "Một buổi trước đã.", "Bắt đầu vừa sức để dễ quay lại buổi sau.", "Ghi từng set để thấy mình đã làm được gì.", "trophy")
        case "Đau mỏi hoặc chấn thương":
            return ("photo-back", "Tập có điều chỉnh.", "Cho app biết vùng cần tránh dồn lực.", "Bấm “Đang đau”, chọn chỗ đau, app đổi hoặc giảm những bài dồn lực vào đó.", "bandage")
        case "Không đủ dụng cụ":
            return ("photo-crunch", "Thiếu máy vẫn tập được.", "Thiếu máy không phải lý do để dừng.", "Chọn “Ở nhà” hoặc “Phòng gym nhỏ”, app chỉ xếp bài làm được với dụng cụ bạn có.", "house")
        default:
            return ("photo-deadlift", "Nặng hơn chưa chắc là tiến bộ.", "Bạn không biết hôm nay mình có nâng nặng hơn tháng trước không. Cảm giác thì hay đánh lừa.", "Dopafit ghi từng set và vẽ đường sức mạnh của từng bài.", "chart.line.uptrend.xyaxis")
        }
    }

    @ViewBuilder private func story(_ o: String) -> some View {
        let d = storyData(o)
        if o == "Đau mỏi hoặc chấn thương" {
            ContextRecommendations(profile: contextProfile, plan: previewPlan, pain: true)
        } else if o == "Thiếu động lực" {
            ContextRecommendations(profile: contextProfile, plan: previewPlan, pain: false)
        } else if o == "Không biết nên tập gì" && !legacyStoryPreview {
            PersonalPlanStory(profile: contextProfile, plan: previewPlan)
        } else if o == "Không có thời gian" {
            TimeAdaptationStory(plan: previewPlan)
        } else {
            ContextStoryPage(eyebrow: o, title: d.1, detail: d.2) {
                ContextStoryVisual(kind: o, profile: contextProfile, plan: previewPlan)
            } footer: { FixLine(text: d.3) }
        }
    }

    private var legacyStoryPreview: Bool {
        #if DEBUG
        Bundle.main.bundleIdentifier?.hasSuffix(".designqa") == true && ProcessInfo.processInfo.arguments.contains("--preview-legacy-story")
        #else
        false
        #endif
    }

    private var core: some View {
        ContextStoryPage(eyebrow: "Điều Dopafit làm khác", title: "Mỗi buổi có hướng đi.", detail: "Biết bài cần tập và ghi lại từng set.") {
            ContextStoryVisual(kind: "plan", profile: p, plan: previewPlan)
        } footer: { FixLine(text: "Điều chỉnh bài và mức tạ khi cần.") }
    }

    // MARK: 9–11. Nơi tập, lịch, về bạn

    private var place: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                QuestionTitle(title: "Bạn thường tập [ở đâu]?", subtitle: "App chỉ xếp những bài làm được với dụng cụ ở đó. Đổi lúc nào cũng được.")
                ForEach(Profile.Place.allCases, id: \.self) { pl in
                    PhotoRow(photo: placePhoto(pl), title: pl.name, detail: pl.detail, selected: p.place == pl) { p.place = pl; next() }
                }
            }
            .padding(.horizontal, T.pad).padding(.bottom, 12)
        }
    }

    private func placePhoto(_ pl: Profile.Place) -> String {
        switch pl { case .fullGym: trainingPhoto("full-gym"); case .smallGym: trainingPhoto("small-gym"); case .home: trainingPhoto("home") }
    }

    private func trainingPhoto(_ scene: String) -> String { "vn-" + (p.sex == .female ? "female" : "male") + "-" + scene }

    private var schedule: some View {
        ScrollView {
            VStack(spacing: 18) {
                QuestionTitle(title: "Mỗi tuần tập [mấy buổi]?", subtitle: "Chọn mức giữ được cả khi bận. Ít mà đều tốt hơn nhiều mà bỏ.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                CalendarTile(number: p.daysPerWeek).padding(.top, 6)
                VStack(spacing: 6) {
                    Text("\(p.daysPerWeek) buổi/tuần").font(T.font(22, .bold)).foregroundStyle(T.text)
                    Text(splitText).font(T.font(15)).foregroundStyle(T.sub).multilineTextAlignment(.center)
                }
                DotSlider(value: $p.daysPerWeek, range: 2...6, left: "Ít hơn", right: "Nhiều hơn")
                    .padding(.horizontal, 4)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Khung thời gian mỗi buổi").font(T.font(17, .semibold)).foregroundStyle(T.text)
                    HStack(spacing: 8) {
                        ForEach([30, 45, 60, 75], id: \.self) { m in
                            pill("\(m) phút", selected: p.minutes == m) { p.minutes = m }
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, T.pad).padding(.bottom, 12)
        }
    }

    private func pill(_ t: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(t).font(T.num(17, .bold))
                .frame(maxWidth: .infinity).frame(height: 54)
                .foregroundStyle(selected ? Color.black : T.text)
                .background(selected ? T.lime : T.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }.buttonStyle(.plain).accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var splitText: String {
        switch p.daysPerWeek {
        case 2: return "2 buổi toàn thân, luân phiên A và B."
        case 3: return "3 buổi: đẩy, kéo, chân."
        case 4: return "4 buổi: thân trên và thân dưới, mỗi kiểu 2 lần."
        default: return "\(p.daysPerWeek) buổi: đẩy, kéo, chân, thân trên, thân dưới."
        }
    }

    // MARK: Cơ thể: câu dễ trả lời, mỗi màn một câu, kéo thước thay vì bấm +/-

    private func measure<C: View>(_ title: String, _ subtitle: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            QuestionTitle(title: title, subtitle: subtitle)
            Spacer(minLength: 12)
            content()
            Spacer(minLength: 12)
            Spacer(minLength: 12)
        }
        .padding(.horizontal, T.pad)
        .frame(maxHeight: .infinity)
    }

    private var weightStep: some View {
        let kg = Binding(get: { Int(p.bodyKg.rounded()) }, set: { p.bodyKg = Double($0) })
        return measure("[Cân nặng] hiện tại?", "Lưu vào hồ sơ để theo dõi thay đổi của cơ thể.") {
            VStack(spacing: 28) {
                Picker("Đơn vị", selection: $p.unit) {
                    Text("kg").tag(WeightUnit.kg)
                    Text("lb").tag(WeightUnit.lb)
                }
                .pickerStyle(.segmented).frame(width: 160)
                BigValue(value: Fmt.n(p.unit.fromKg(p.bodyKg), digits: 0), unit: p.unit.label)
                RulerPicker(value: kg, range: 35...180) { Fmt.n(p.unit.fromKg(Double($0)), digits: 0) }
                Text("Đơn vị này cũng dùng cho mức tạ trong app.").font(T.font(14)).foregroundStyle(T.faint)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: Chỗ đau: hỏi sau phần trấn an, để người dùng thấy an toàn khi trả lời

    private var injuriesStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                QuestionTitle(title: "Gần đây bạn [đau] chỗ nào?", subtitle: "Plan sẽ ưu tiên bài không dồn lực vào chỗ đó. Không đau thì bấm nút bên dưới.")
                CheckRow(icon: "checkmark.shield", title: "Không có", on: injured.isEmpty) { injured = [] }
                ForEach(Joint.allCases) { j in
                    let on = injured.contains(j)
                    CheckRow(icon: "", title: j.name, on: on, joint: j) {
                        if on { injured.removeAll { $0 == j } } else { injured.append(j) }
                    }
                }
            }
            .padding(.horizontal, T.pad).padding(.bottom, 12)
        }
    }

    // MARK: Dự đoán: cho thấy tương lai cụ thể, nói rõ là ước tính

    // MARK: 12. Đang lên plan

    // MARK: 13. Hiện plan: khoảnh khắc đẹp nhất

    private var previewPlan: PlannedWorkout {
        generatedPlan ?? state.buildPlan(profile: contextProfile)
    }

    private var reveal: some View {
        let plan = previewPlan
        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PlanMotionHero(plan: plan, female: p.sex == .female)
                VStack(alignment: .leading, spacing: 6) {
                    Headline("Tuần đầu của bạn.").foregroundStyle(T.text).oneLineTitle()
                    Text("\(p.goal.name) · \(p.place.name)").font(T.font(14)).foregroundStyle(T.sub)
                }.padding(.top, 4)
                HStack(spacing: 8) {
                    overviewMetric("\(p.daysPerWeek)", "buổi / tuần")
                    overviewMetric("~\(plan.minutes)", "phút / buổi")
                    overviewMetric("\(plan.items.count)", "bài / buổi")
                }
                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Buổi 1").font(T.font(14, .semibold)).foregroundStyle(T.sub)
                            Spacer()
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

            }
            .padding(.horizontal, T.pad).padding(.top, 8).padding(.bottom, 12)
        }.lineSpacing(1 * T.scale)
    }

    private func overviewMetric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value).font(T.num(23, .bold)).foregroundStyle(T.text)
            Text(label).font(T.font(12)).foregroundStyle(T.sub)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(14)
            .background(T.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: 14. Lời hứa nhỏ, tự chọn

    private var promiseDays: [Date] {
        (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: Calendar.current.startOfDay(for: Date())) }
    }

    private var promise: some View {
        let chosen = p.firstDay ?? promiseDays[0]
        return ViewThatFits(in: .vertical) {
            promiseContent(chosen: chosen, compact: false)
            promiseContent(chosen: chosen, compact: true)
        }
        .padding(.bottom, 190)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear { if p.firstDay == nil { p.firstDay = promiseDays[0] } }
    }

    private func promiseContent(chosen: Date, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: compact ? 18 : 28) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Bắt đầu từ một lời hứa.")
                    .font(T.font(compact ? 29 : 34, .bold)).foregroundStyle(T.text)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Với chính mình.")
                    .font(T.font(compact ? 29 : 34, .bold)).foregroundStyle(T.lime)
                Text("Không cần hoàn hảo. Chỉ cần bắt đầu.")
                    .font(T.font(16)).foregroundStyle(T.sub).padding(.top, 2)
            }
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Buổi đầu tiên của bạn").font(T.font(14, .medium)).foregroundStyle(T.sub)
                    Spacer()
                    Image(systemName: "calendar").font(T.font(16)).foregroundStyle(T.sub)
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(dayName(chosen)).font(T.font(compact ? 25 : 28, .semibold))
                        .foregroundStyle(T.text).lineLimit(2)
                    if Calendar.current.isDateInToday(chosen) || Calendar.current.isDateInTomorrow(chosen) {
                        Text(Fmt.shortDay.string(from: chosen)).font(T.num(15, .medium)).foregroundStyle(T.sub)
                    }
                }
                HStack(spacing: 4) {
                    ForEach(promiseDays, id: \.self) { d in
                        let on = Calendar.current.isDate(d, inSameDayAs: chosen)
                        Button { p.firstDay = d } label: {
                            VStack(spacing: 10) {
                                Text(shortWeekday(d)).font(T.font(12, .medium)).foregroundStyle(T.sub)
                                Text("\(Calendar.current.component(.day, from: d))")
                                    .font(T.num(17, .semibold))
                                    .foregroundStyle(on ? T.lime : T.text)
                                    .frame(maxWidth: .infinity).frame(height: 40)
                                    .background(on ? T.raised : .clear, in: RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(on ? T.lime : .clear, lineWidth: 1))
                            }
                            .frame(maxWidth: .infinity).contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(promised)
                        .accessibilityLabel(Fmt.day(d))
                        .accessibilityAddTraits(on ? .isSelected : [])
                    }
                }
                Rectangle().fill(T.line).frame(height: 1)
                Label("\(p.daysPerWeek) buổi / tuần · \(p.minutes) phút / buổi", systemImage: "dumbbell")
                    .font(T.font(14)).foregroundStyle(T.sub)
            }
            .padding(20).background(T.surface, in: RoundedRectangle(cornerRadius: 22))
        }
        .padding(.horizontal, 24).padding(.top, compact ? 12 : 28)
    }

    private var promiseWaveStyle: DistortionWaveStyle {
        var style = DistortionWaveStyle.vertical
        style.palette = .green // Official palette; all motion/shader defaults stay intact.
        return style
    }

    /// Native SwiftUI only: both shader sides are opaque. The live hold control
    /// stays above the shader, exactly as the kit integration recommends.
    private func promiseStage(top: CGFloat, bottom: CGFloat) -> some View {
        VStack(spacing: 0) {
            header
            promise
        }.padding(.top, top).padding(.bottom, bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity).background(T.bg)
    }

    private func makePromise() {
        guard step == .promise, !promised else { return }
        promised = true
    }

    private func advanceAfterPromise() {
        guard step == .promise, promised else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { lastAdvance = Date(); index += 1 }
    }

    private var holdButton: some View {
        PromiseHoldControl(confirmed: promised, action: makePromise, onFrame: { holdFrame = $0 })
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

    private var reminder: some View {
        ReminderPreviewStep(hour: $p.reminderHour, day: p.firstDay ?? Date(), minutes: previewPlan.minutes)
    }

    private var reminderIsFuture: Bool {
        guard let hour = p.reminderHour else { return true }
        return Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: p.firstDay ?? Date()).map { $0 > Date() } ?? false
    }

    private func scheduleReminder(hour: Int) {
        guard Bundle.main.bundleIdentifier?.hasSuffix(".designqa") != true else { return }
        let center = UNUserNotificationCenter.current()
        let day = p.firstDay ?? Date()
        let name = state.buildPlan(profile: p).name
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
        SetupReviewStep(profile: p, desires: desires, obstacles: obstacles, injuries: injured, plan: previewPlan) { answer in
            answerSnapshot = AnswerSnapshot(profile: p, desires: desires, obstacles: obstacles, injuries: injured, journey: journeyPicked)
            editingAnswer = answer
        }
    }

    private func cancelAnswerEdit() {
        if let old = answerSnapshot {
            p = old.profile; desires = old.desires; obstacles = old.obstacles
            injured = old.injuries; journeyPicked = old.journey
        }
        editingAnswer = nil; answerSnapshot = nil
        index = steps.firstIndex(of: .save) ?? index
    }

    private func applyAnswerEdit() {
        saveAnswers()
        journeyPicked = p.recent.map { [.regular, .onOff, .returning].firstIndex(of: $0) ?? 3 } ?? 3
        generatedPlan = state.buildPlan(profile: p)
        editingAnswer = nil; answerSnapshot = nil
        // Branch-changing answers must return to review, not an old integer index.
        index = steps.firstIndex(of: .save) ?? index
    }

    private var editedAnswerIsValid: Bool {
        switch editingAnswer {
        case .sex: p.sex != .other
        case .desire: !desires.isEmpty
        case .currentShape: p.currentShape != nil
        case .recent: p.recent != .returning || p.trainingBreak != nil
        case .reminder, .promise: reminderIsFuture
        default: true
        }
    }

    private var answerEditor: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Sửa lựa chọn") { cancelAnswerEdit() }
            Group {
                switch editingAnswer {
                case .sex: SexSetupStep(selection: $p.sex)
                case .desire: desire
                case .goal: goal
                case .focus: BodyFocusStep(selection: $p.focusAreas, sex: p.sex)
                case .currentShape: CurrentShapeStep(selection: $p.currentShape, sex: p.sex)
                case .targetShape: TargetShapeStep(selection: $p.targetShape, current: p.currentShape, sex: p.sex, goal: p.goal)
                case .weight: weightStep
                case .targetWeight: WeightGoalStep(profile: $p)
                case .activity: ActivityLevelStep(selection: $p.activity, sex: p.sex)
                case .level: level
                case .recent:
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            QuestionTitle(title: "Nhịp tập [gần đây]", subtitle: "Mức tạ khởi điểm sẽ theo lựa chọn này.")
                            CheckRow(icon: "leaf", title: "Chưa tập đều bao giờ", on: p.recent == nil) { p.recent = nil; p.trainingBreak = nil }
                            ForEach(Profile.Recent.allCases, id: \.self) { answer in
                                CheckRow(icon: answer.icon, title: answer.name, on: p.recent == answer) {
                                    p.recent = answer
                                    if answer != .returning { p.trainingBreak = nil }
                                }
                            }
                            if p.recent == .returning {
                                Text("Bạn đã nghỉ bao lâu?").font(T.font(17, .semibold)).foregroundStyle(T.text).padding(.top, 12)
                                ForEach(Profile.TrainingBreak.allCases, id: \.self) { answer in
                                    CheckRow(icon: "calendar", title: answer.name, on: p.trainingBreak == answer) { p.trainingBreak = answer }
                                }
                            }
                        }.padding(.horizontal, T.pad).padding(.bottom, 20)
                    }
                case .injuries: injuriesStep
                case .obstacles: obstacleQuestion
                case .reward: RewardStep(selection: $p.reward, sex: p.sex)
                case .place: place
                case .schedule: schedule
                case .promise:
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            QuestionTitle(title: "Buổi đầu [khi nào]?", subtitle: "Đổi ngày bắt đầu, giữ nguyên lời cam kết của bạn.")
                            ForEach(0..<7, id: \.self) { offset in
                                let day = Calendar.vn.date(byAdding: .day, value: offset, to: Calendar.vn.startOfDay(for: Date()))!
                                CheckRow(icon: "calendar", title: offset == 0 ? "Hôm nay · " + Fmt.shortDay.string(from: day) : Fmt.day(day), on: Calendar.vn.isDate(p.firstDay ?? Date(), inSameDayAs: day)) { p.firstDay = day }
                            }
                            if !reminderIsFuture { Text("Giờ nhắc đã qua. Chọn ngày khác hoặc sửa giờ nhắc.").font(T.font(14)).foregroundStyle(T.warn) }
                        }.padding(.horizontal, T.pad)
                    }
                case .reminder: reminder
                default: EmptyView()
                }
            }.frame(maxHeight: .infinity, alignment: .top)
        }
        .background(T.bg.ignoresSafeArea()).environment(\.locale, Locale(identifier: "vi_VN"))
        .safeAreaInset(edge: .bottom) {
            BottomBar { PrimaryButton(title: "Cập nhật lựa chọn", enabled: editedAnswerIsValid) { applyAnswerEdit() } }.background(T.bg)
        }
    }
}

// MARK: - Thành phần dùng chung trong thiết lập

struct QuestionTitle: View {
    var title: String
    var subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HighlightTitle(title, size: 30)
                .fixedSize(horizontal: false, vertical: true).padding(.bottom, 4)
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

/// Local plan generation is synchronous. Review real choices without a fake processing timer.
struct BuildingPlanView: View {
    var profile: Profile
    var done: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var completed = 0
    private var ready: Bool { completed == 4 }
    private var captions: [String] {
        ["Đang chọn hướng tập…", "Đang chọn bài theo dụng cụ…", "Đang đặt mức khởi điểm…", "Đang xếp nhịp tập…"]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                ZStack {
                    Circle().stroke(T.raised, lineWidth: 5)
                    Circle().trim(from: 0, to: Double(completed) / 4)
                        .stroke(T.lime, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    if ready {
                        Image(systemName: "checkmark").font(T.font(37, .semibold)).foregroundStyle(T.lime)
                            .transition(.opacity)
                    } else {
                        Text("\(completed * 25)%").font(T.num(27, .semibold)).foregroundStyle(T.text)
                            .contentTransition(.numericText())
                    }
                }.frame(width: 102, height: 102)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(ready ? "Plan đã sẵn sàng" : "Đang xếp plan")
                    .accessibilityValue("\(completed * 25) phần trăm")
                    .padding(.top, 56)
                VStack(spacing: 10) {
                    Text(ready ? "Plan đã sẵn sàng." : "Đang xếp plan cho bạn.")
                        .font(T.font(29, .bold)).foregroundStyle(T.text)
                    Text(ready ? "Được xếp theo lựa chọn của bạn." : captions[min(completed, 3)])
                        .font(T.font(15)).foregroundStyle(T.sub)
                }.multilineTextAlignment(.center)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    choice(0, "Mục tiêu", profile.goal.name, "scope")
                    choice(1, "Nơi tập", profile.place.name, "dumbbell")
                    choice(2, "Kinh nghiệm", profile.level.name, "calendar")
                    choice(3, "Nhịp tập", "\(profile.daysPerWeek) buổi · \(profile.minutes) phút", "clock")
                }.accessibilityElement(children: .contain)
                if let injuries = profile.injuries, !injuries.isEmpty {
                    Label("Có điều chỉnh cho " + injuries.map { $0.name.lowercased() }.joined(separator: ", "), systemImage: "bandage")
                        .font(T.font(14)).foregroundStyle(T.sub).frame(maxWidth: .infinity, alignment: .leading)
                }
            }.padding(.horizontal, T.pad).padding(.bottom, 24)
        }.scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: ready ? "Xem kế hoạch" : "Đang xếp plan…", enabled: ready, action: done)
                    .accessibilityIdentifier("onboarding.review-plan")
                    .padding(.horizontal, T.pad).padding(.vertical, 16).background(T.bg)
            }
            // The plan is built locally before this screen. This is a short preparation
            // reveal of its four inputs, not a network request or measured server progress.
            // SwiftUI cancels the sequence on navigation/background; it resumes at its last step.
            .task(id: scenePhase) {
                guard scenePhase == .active, !ready else { return }
                do {
                    while completed < 4 {
                        try await Task.sleep(for: .milliseconds(850))
                        try Task.checkCancellation()
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.35)) { completed += 1 }
                    }
                } catch { /* Navigation or backgrounding cancels the reveal. */ }
            }
    }
    private func choice(_ index: Int, _ label: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Image(systemName: icon).font(T.font(22, .medium)).foregroundStyle(completed >= index ? T.lime : T.faint)
                Spacer()
                if index < completed {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(T.lime).font(T.font(17))
                } else if index == completed {
                    if reduceMotion {
                        Circle().fill(T.lime).frame(width: 7, height: 7)
                    } else {
                        ProgressView().controlSize(.small).tint(T.lime)
                    }
                }
            }.accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text(label).font(T.font(12)).foregroundStyle(T.sub)
                Text(value).font(T.font(16, .semibold)).foregroundStyle(T.text).fixedSize(horizontal: false, vertical: true)
            }
        }.frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading).padding(18)
            .background(T.surface, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(index == completed ? T.lime.opacity(0.45) : T.line, lineWidth: 1))
            .accessibilityElement(children: .combine)
            .accessibilityValue(index < completed ? "Đã xong" : (index == completed ? "Đang xếp" : "Chờ"))
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


/// Danh sách điểm cộng tự chạy: từng thẻ hiện lần lượt, vòng tròn chuyển thành dấu tích.
/// `instant` = đã xem rồi, hiện đủ ngay.
struct AutoFixList: View {
    var items: [String]
    var instant = false
    @State private var shown = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Tổng thời gian chạy hết n dòng (để màn cha biết lúc nào tự đi tiếp).
    static func duration(_ n: Int) -> UInt64 { UInt64(350 + n * 950 + 900) * 1_000_000 }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, it in
                let on = i < shown
                HStack(spacing: 12) {
                    ZStack {
                        Circle().stroke(T.line, lineWidth: 1.5)
                        Circle().fill(T.lime).scaleEffect(on ? 1 : 0.2).opacity(on ? 1 : 0)
                        Image(systemName: "checkmark").font(T.font(11, .heavy)).foregroundStyle(.black)
                            .opacity(on ? 1 : 0)
                    }
                    .frame(width: 22, height: 22)
                    Text(it).font(T.font(15, .medium)).foregroundStyle(T.text)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14).padding(.vertical, 13)
                .background(T.surface.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(T.line))
                .opacity(on ? 1 : 0.35)
                .offset(y: on || reduceMotion ? 0 : 6)
            }
        }
        .sensoryFeedback(.selection, trigger: shown)
        .accessibilityElement(children: .combine)
        .task {
            if instant { shown = items.count; return }
            try? await Task.sleep(nanoseconds: 350_000_000)
            for i in items.indices {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.35)) { shown = i + 1 }
                try? await Task.sleep(nanoseconds: 950_000_000)
                if Task.isCancelled { return }
            }
        }
    }
}
