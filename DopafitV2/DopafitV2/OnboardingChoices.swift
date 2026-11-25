import SwiftUI

extension Profile {
    enum BodyShape: String, Codable, CaseIterable {
        case average, soft, round, slim, muscular
        var name: String { switch self { case .average: "Trung bình"; case .soft: "Mềm quanh eo"; case .round: "Bụng tròn hơn"; case .slim: "Mảnh người"; case .muscular: "Có nền tảng cơ" } }
        var photo: String { switch self { case .average: "comparison-average"; case .soft: "comparison-baseline"; case .round: "comparison-round"; case .slim: "comparison-slim"; case .muscular: "comparison-muscle" } }
    }
    enum BodyGoal: String, Codable, CaseIterable {
        case balanced, lean, muscular, maintain
        var name: String { switch self { case .balanced: "Cân đối, khỏe khoắn"; case .lean: "Gọn và săn chắc"; case .muscular: "Khỏe và rõ nét hơn"; case .maintain: "Giữ vóc dáng hiện tại" } }
        var detail: String { switch self {
        case .balanced: "Xây nền tảng sức mạnh và một thói quen bền vững."
        case .lean: "Tập tạ để giữ cơ, theo dõi sự thay đổi từng tuần."
        case .muscular: "Ưu tiên tập đều, đủ rep và tăng tạ từng bước."
        case .maintain: "Giữ điều đang có, tiếp tục vận động và khỏe hơn."
        } }
        var photo: String { switch self { case .balanced: "comparison-health"; case .lean: "comparison-lean"; case .muscular: "comparison-muscle"; case .maintain: "comparison-average" } }
    }
    enum BellyShape: String, Codable, CaseIterable {
        case flat, soft, round, skip
        var name: String { switch self { case .flat: "Bụng khá phẳng"; case .soft: "Mềm quanh eo"; case .round: "Bụng tròn hơn"; case .skip: "Không muốn chọn" } }
        var detail: String { switch self { case .flat: "Ít thay đổi quanh vòng eo"; case .soft: "Muốn vòng eo săn chắc hơn"; case .round: "Muốn theo dõi vùng bụng"; case .skip: "Tiếp tục với mục tiêu đã chọn" } }
    }
    enum Intensity: String, Codable, CaseIterable {
        case easy, steady, challenging
        var name: String { switch self { case .easy: "Dễ bắt đầu"; case .steady: "Vừa sức, có thử thách"; case .challenging: "Muốn thử sức hơn" } }
        var detail: String { switch self { case .easy: "Tối đa 2 set mỗi bài"; case .steady: "Tối đa 3 set mỗi bài"; case .challenging: "Giữ số set theo bài và kinh nghiệm" } }
        var icon: String { switch self { case .easy: "leaf"; case .steady: "drop"; case .challenging: "bolt" } }
        var planNote: String { "mức tập " + name.lowercased() }
    }
    enum FocusArea: String, Codable, CaseIterable {
        case arms, shoulders, chest, back, abs, legs
        var name: String { switch self { case .arms: "Cánh tay"; case .shoulders: "Vai"; case .chest: "Ngực"; case .back: "Lưng"; case .abs: "Bụng"; case .legs: "Chân" } }
        var muscles: [Muscle] { switch self { case .arms: [.biceps, .triceps]; case .shoulders: [.shoulders]; case .chest: [.chest]; case .back: [.back]; case .abs: [.abs]; case .legs: [.quads, .hamstrings, .glutes] } }
    }
    enum Reward: String, Codable, CaseIterable {
        case outfit, gift, travel, share, recovery, personal
        var name: String { switch self { case .outfit: "Thử đồ mới"; case .gift: "Món quà mong đợi"; case .travel: "Một chuyến đi"; case .share: "Chia sẻ thành quả"; case .recovery: "Một ngày thư giãn"; case .personal: "Tự hào về bản thân" } }
        var icon: String { switch self { case .outfit: "tshirt"; case .gift: "gift"; case .travel: "mountain.2"; case .share: "camera"; case .recovery: "sun.horizon"; case .personal: "sparkles" } }
        var photo: String { switch self { case .outfit: "vn-person-attractive"; case .gift, .share, .personal: "vn-person-confident"; case .travel: "vn-person-walk"; case .recovery: "vn-person-sleep" } }
    }
}

/// One source of truth for belly choice and the following comparison.
enum BodyIllustration {
    static func currentPhoto(shape: Profile.BodyShape?, belly: Profile.BellyShape?) -> String {
        switch belly {
        case .flat: return "comparison-average"
        case .soft: return "comparison-baseline"
        case .round: return "comparison-round"
        case .skip, nil: return shape?.photo ?? "comparison-average"
        }
    }
    static func targetPhoto(shape: Profile.BodyShape?, target: Profile.BodyGoal?, goal: Profile.Goal, belly: Profile.BellyShape? = nil) -> String {
        let before = currentPhoto(shape: shape, belly: belly)
        let resolved = target ?? (goal == .lean ? .lean : .balanced)
        if resolved == .maintain { return before }
        // Balanced is already met by an average or trained illustration. Do not
        // depict a trained body losing muscle, or invent a visible transformation.
        if resolved == .balanced && [0, 3, 4].contains(cell(before)) { return before }
        return resolved.photo
    }
    static func showsComparison(shape: Profile.BodyShape?, target: Profile.BodyGoal?, goal: Profile.Goal, belly: Profile.BellyShape? = nil) -> Bool {
        cell(currentPhoto(shape: shape, belly: belly)) != cell(targetPhoto(shape: shape, target: target, goal: goal, belly: belly))
    }
    static func bodySheet(_ sex: Profile.Sex) -> String { sex == .female ? "female-body-realistic" : "male-body-realistic" }
    static func hero(_ sex: Profile.Sex) -> String { sex == .female ? "vn-female-full-gym" : "vn-onboarding-hero" }
    static func cell(_ photo: String) -> Int {
        switch photo {
        case "comparison-baseline": 1
        case "comparison-slim": 2
        case "comparison-muscle": 3
        case "comparison-lean": 4
        case "comparison-round": 5
        default: 0
        }
    }
}

struct OnboardingPage<Content: View>: View {
    var title: String
    var subtitle: String
    @ViewBuilder var content: Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                QuestionTitle(title: title, subtitle: subtitle)
                content
            }.padding(.horizontal, 24).padding(.bottom, 24)
        }.scrollIndicators(.hidden)
    }
}

struct ChoiceRadio: View {
    var selected: Bool
    var body: some View {
        ZStack {
            Circle().stroke(selected ? T.lime : T.faint, lineWidth: 1.5)
            if selected {
                Circle().fill(T.lime)
                Image(systemName: "checkmark").font(T.font(11, .bold)).foregroundStyle(T.bg)
            }
        }.frame(width: 23, height: 23).accessibilityHidden(true)
    }
}

struct CurrentShapeStep: View {
    @Binding var selection: Profile.BodyShape?
    var sex: Profile.Sex = .male
    var body: some View {
        OnboardingPage(title: "Vóc dáng [hiện tại] của bạn?", subtitle: "Chọn hình gần nhất với bạn, chỉ để minh họa mục tiêu.") {
            VStack(spacing: 12) {
            ForEach(Profile.BodyShape.allCases, id: \.self) { item in
                GoalPortraitRow(photo: item.photo, title: item.name, detail: "", selected: selection == item, bodyPortrait: true, sex: sex, rowHeight: 104) { selection = item }
                    .accessibilityIdentifier("onboarding.current-shape.\(item.rawValue)")
            }
            }
            Text("Nhân vật AI minh họa. Không dùng ảnh để tính tỷ lệ mỡ.")
                .font(T.font(12)).foregroundStyle(T.faint)
        }
    }
}

struct TargetShapeStep: View {
    @Binding var selection: Profile.BodyGoal?
    var current: Profile.BodyShape?
    var sex: Profile.Sex = .male
    var goal: Profile.Goal = .muscle
    private var preferred: Profile.BodyGoal { switch goal { case .muscle, .strength, .health: .balanced; case .lean: .lean } }
    private var selected: Profile.BodyGoal { selection ?? preferred }
    private var position: Binding<Int> { Binding(get: { Profile.BodyGoal.allCases.firstIndex(of: selected) ?? 0 }, set: { selection = Profile.BodyGoal.allCases[$0] }) }
    var body: some View {
        OnboardingPage(title: "Bạn muốn hướng tới [vóc dáng nào]?", subtitle: "Một hướng đi cho riêng bạn. Không cần giống hệt hình minh họa.") {
            AlignedBodyPortrait(photo: BodyIllustration.targetPhoto(shape: current, target: selected, goal: goal), sex: sex).frame(maxWidth: .infinity).frame(height: 290).accessibilityHidden(true)
            VStack(spacing: 8) {
                Text(selected.name).font(T.font(23, .bold)).foregroundStyle(T.lime)
                Text(selected.detail).font(T.font(15)).foregroundStyle(T.sub).multilineTextAlignment(.center)
            }.frame(maxWidth: .infinity, minHeight: 86)
            DotSlider(value: position, range: 0...3, left: "Cân đối", right: "Giữ vóc dáng")
                .accessibilityLabel("Vóc dáng mục tiêu").accessibilityValue(selected.name)
            HStack(spacing: 10) {
                Image(systemName: "scope").font(T.font(22)).foregroundStyle(T.lime)
                Text("Tiến bộ còn là tập đều hơn, khỏe hơn và thấy thoải mái hơn trong cơ thể mình.")
                    .font(T.font(14)).foregroundStyle(T.sub)
            }.padding(18).background(T.surface, in: RoundedRectangle(cornerRadius: 18))
        }.onAppear { if selection == nil { selection = preferred } }
    }
}

struct BodyFocusStep: View {
    @Binding var selection: [Profile.FocusArea]?
    var sex: Profile.Sex = .male
    private var selected: Set<Profile.FocusArea> { Set(selection ?? []) }
    var body: some View {
        OnboardingPage(title: "Bạn muốn ưu tiên [vùng nào]?", subtitle: "Chọn tối đa 3. Lịch vẫn cân bằng toàn thân, nhóm bạn chọn được xếp trước khi đến ngày tập phù hợp.") {
            BodyMapView(female: sex == .female) { slug in
                let areas = selected.isEmpty ? Profile.FocusArea.allCases : Array(selected)
                let slugs = Set(areas.flatMap(\.muscles).flatMap(\.bodySlugs))
                return slugs.contains(slug) ? T.lime : Color.white.opacity(0.14)
            }.frame(height: 260).padding(.horizontal, 45).accessibilityHidden(true)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(Profile.FocusArea.allCases, id: \.self) { area in
                    let on = selected.contains(area)
                    Button {
                        var values = selection ?? []
                        if on { values.removeAll { $0 == area } } else if values.count < 3 { values.append(area) }
                        selection = values
                    } label: {
                        HStack(spacing: 8) { MuscleMiniMap(muscle: area.muscles[0], tint: on ? T.lime : T.sub).frame(width: 25, height: 42).accessibilityHidden(true); Text(area.name).font(T.font(16, .semibold)); Spacer(minLength: 0); ChoiceRadio(selected: on) }
                            .foregroundStyle(on ? T.lime : T.text).padding(16)
                            .background(T.surface, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(on ? T.lime : T.line, lineWidth: 1))
                    }.buttonStyle(.plain).accessibilityAddTraits(on ? .isSelected : [])
                }
            }
            Button { selection = [] } label: {
                HStack { Image(systemName: "figure.stand"); Text("Toàn thân"); Spacer(); ChoiceRadio(selected: selected.isEmpty) }
                    .font(T.font(17, .semibold)).foregroundStyle(selected.isEmpty ? T.lime : T.text).padding(18)
                    .background(T.surface, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(selected.isEmpty ? T.lime : T.line, lineWidth: 1))
            }.buttonStyle(.plain).accessibilityAddTraits(selected.isEmpty ? .isSelected : [])
        }
    }
}

struct PotentialStep: View {
    var plan: PlannedWorkout
    var unit: WeightUnit
    var body: some View {
        OnboardingPage(title: "Mạnh hơn qua [từng buổi tập].", subtitle: "Không cần hoàn hảo. Chỉ cần tốt hơn chính mình hôm qua.") {
            if let item = plan.items.first(where: { !$0.exercise.bodyweightOnly }) ?? plan.items.first {
                PotentialProgressCard(item: item, unit: unit)
            }
            VStack(spacing: 18) {
                habit("calendar.badge.checkmark", "Duy trì", "Tạo thói quen tập đều đặn.")
                habit("list.clipboard", "Theo dõi", "Ghi lại từng set và rep.")
                habit("chart.bar.fill", "Tiến bộ", "Tăng tạ khi bạn sẵn sàng.")
            }
        }
    }
    private func habit(_ icon: String, _ title: String, _ detail: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(T.font(24, .semibold)).foregroundStyle(T.lime)
                .frame(width: 52, height: 52).background(T.surface, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(T.line))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(T.font(20, .semibold)).foregroundStyle(T.text)
                Text(detail).font(T.font(14)).foregroundStyle(T.sub)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct RewardStep: View {
    @Binding var selection: Profile.Reward?
    var sex: Profile.Sex = .male
    var body: some View {
        OnboardingPage(title: "Đạt mục tiêu rồi, bạn sẽ [tự thưởng gì]?", subtitle: "Một điều đáng mong chờ. Chọn cho mình, hoặc bỏ qua.") {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(Profile.Reward.allCases, id: \.self) { reward in
                    let on = selection == reward
                    Button { selection = on ? nil : reward } label: {
                        VStack(spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                SheetPortrait(asset: sex == .female ? "female-lifestyle-sheet" : "onboarding-reward-sheet", index: Profile.Reward.allCases.firstIndex(of: reward) ?? 0).frame(height: 145).frame(maxWidth: .infinity)
                            }.accessibilityHidden(true).allowsHitTesting(false)
                            Text(reward.name).font(T.font(16, .semibold)).foregroundStyle(on ? T.lime : T.text)
                                .multilineTextAlignment(.center).frame(maxWidth: .infinity, minHeight: 66).padding(.horizontal, 8)
                        }.background(on ? T.raised : T.surface, in: RoundedRectangle(cornerRadius: 21))
                            .contentShape(RoundedRectangle(cornerRadius: 21))
                            .overlay(RoundedRectangle(cornerRadius: 21).stroke(on ? T.lime : T.line, lineWidth: 1))
                            .overlay(alignment: .topTrailing) { if on { Image(systemName: "checkmark.circle.fill").foregroundStyle(T.lime).padding(10).allowsHitTesting(false) } }
                    }.buttonStyle(.plain).accessibilityAddTraits(on ? .isSelected : [])
                        .accessibilityLabel(reward.name)
                        .accessibilityIdentifier("onboarding.reward.\(reward.rawValue)")
                }
            }
        }
    }
}

struct WeightGoalStep: View {
    @Binding var profile: Profile
    private var value: Binding<Int> { Binding(get: { Int((profile.targetKg ?? profile.bodyKg).rounded()) }, set: { profile.targetKg = Double($0) }) }
    var body: some View {
        OnboardingPage(title: "Cân nặng [mục tiêu] của bạn?", subtitle: "Một mốc để theo dõi. Bạn có thể giữ cân nặng hiện tại hoặc thay đổi sau.") {
            Picker("Đơn vị", selection: $profile.unit) { Text("kg").tag(WeightUnit.kg); Text("lb").tag(WeightUnit.lb) }
                .pickerStyle(.segmented).frame(width: 160).frame(maxWidth: .infinity).padding(.top, 25)
            BigValue(value: Fmt.n(profile.unit.fromKg(profile.targetKg ?? profile.bodyKg)), unit: profile.unit.label)
                .frame(maxWidth: .infinity).padding(.top, 35)
            Text("Hiện tại  " + Fmt.w(profile.bodyKg, profile.unit)).font(T.font(15)).foregroundStyle(T.sub).frame(maxWidth: .infinity)
            RulerPicker(value: value, range: 35...180) { Fmt.n(profile.unit.fromKg(Double($0)), digits: 0) }
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "flag.checkered").foregroundStyle(T.lime)
                VStack(alignment: .leading, spacing: 7) {
                    Text(deltaText).font(T.font(18, .semibold)).foregroundStyle(T.text)
                    Text("Cân nặng không nói hết về sức mạnh hay vóc dáng. App lưu mốc này để bạn theo dõi, không tự kê chế độ giảm cân.")
                        .font(T.font(15)).foregroundStyle(T.sub)
                }
            }.padding(20).background(T.surface, in: RoundedRectangle(cornerRadius: 20)).padding(.top, 20)
        }.onAppear { if profile.targetKg == nil { profile.targetKg = profile.bodyKg } }
    }
    private var deltaText: String {
        let delta = (profile.targetKg ?? profile.bodyKg) - profile.bodyKg
        return abs(delta) < 0.5 ? "Giữ cân, cải thiện thể lực" : (delta > 0 ? "Tăng " : "Giảm ") + Fmt.w(abs(delta), profile.unit) + " so với hiện tại"
    }
}

struct WeightDirectionStep: View {
    var profile: Profile
    private var target: Double { profile.targetKg ?? profile.bodyKg }
    private var maintaining: Bool { abs(target - profile.bodyKg) < 0.5 }
    var body: some View {
        OnboardingPage(title: maintaining ? "Giữ cân, [khỏe hơn]." : "Mục tiêu [của bạn].", subtitle: maintaining ? "Giữ nhịp tập bạn đã chọn." : "Từng bước tới mốc cân nặng bạn chọn.") {
            if maintaining {
                VStack(spacing: 10) {
                    Text(Fmt.w(target, profile.unit)).font(T.num(64)).foregroundStyle(T.lime)
                    Text("Cân nặng muốn giữ").font(T.font(15)).foregroundStyle(T.sub)
                }.frame(maxWidth: .infinity).padding(.vertical, 60)
            } else {
                WeightGoalChart(current: profile.bodyKg, target: target, unit: profile.unit)
                Text("Đường minh họa, không dự đoán ngày đạt mục tiêu.").font(T.font(13)).foregroundStyle(T.sub)
            }
            HStack(spacing: 20) {
                Label("\(profile.daysPerWeek) buổi/tuần", systemImage: "calendar")
                Label("\(profile.minutes) phút/buổi", systemImage: "clock")
            }.font(T.font(15, .semibold)).foregroundStyle(T.text)
                .frame(maxWidth: .infinity).padding(.vertical, 20)
                .background(T.surface, in: RoundedRectangle(cornerRadius: 20))
        }
    }
}


/// Two selected values, not measured intermediate weights or a dated forecast.
private struct WeightGoalChart: View {
    var current: Double
    var target: Double
    var unit: WeightUnit
    private var increasing: Bool { target > current }
    private var kind: JourneyCurve.Kind { increasing ? .up : .down }
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Hướng thay đổi").font(T.font(13, .medium)).foregroundStyle(T.sub)
                    Text((increasing ? "Tăng " : "Giảm ") + Fmt.w(abs(target - current), unit))
                        .font(T.num(28)).foregroundStyle(T.text)
                }
                Spacer()
                Image(systemName: increasing ? "arrow.up.right" : "arrow.down.right")
                    .font(T.font(22, .semibold)).foregroundStyle(T.lime)
                    .frame(width: 46, height: 46).background(T.raised, in: Circle())
                    .accessibilityHidden(true)
            }
            GeometryReader { geo in
                let inset: CGFloat = 16
                let width = max(1, geo.size.width - inset * 2)
                let height: CGFloat = 156
                let top: CGFloat = 38
                let startY = top + height * (increasing ? 0.82 : 0.2)
                let endY = top + height * (increasing ? 0.12 : 0.85)
                ZStack(alignment: .topLeading) {
                    Path { p in
                        for fraction in [0.2, 0.55, 0.85] {
                            let y = top + height * fraction
                            p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: geo.size.width, y: y))
                        }
                    }.stroke(T.line, style: StrokeStyle(lineWidth: 1, dash: [3, 5]))
                    JourneyCurve(kind: kind, closed: true)
                        .fill(LinearGradient(colors: [T.lime.opacity(0.19), T.lime.opacity(0.01)], startPoint: .top, endPoint: .bottom))
                        .frame(width: width, height: height).offset(x: inset, y: top)
                    JourneyCurve(kind: kind)
                        .stroke(T.lime, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: width, height: height).offset(x: inset, y: top)
                    Circle().fill(T.surface).overlay(Circle().stroke(T.text, lineWidth: 2))
                        .frame(width: 11, height: 11).position(x: inset, y: startY)
                    Circle().stroke(T.lime.opacity(0.18), lineWidth: 8)
                        .frame(width: 20, height: 20).position(x: inset + width, y: endY)
                    Circle().fill(T.lime).overlay(Circle().stroke(T.bg, lineWidth: 2))
                        .frame(width: 13, height: 13).position(x: inset + width, y: endY)
                    Text(Fmt.w(current, unit)).font(T.num(17, .semibold)).foregroundStyle(T.text)
                        .position(x: 42, y: startY - 25)
                    Text(Fmt.w(target, unit)).font(T.num(17, .semibold)).foregroundStyle(T.lime)
                        .position(x: geo.size.width - 42, y: endY - 27)
                }
            }.frame(height: 205)
                .modifier(ChartReveal(key: "weight-\(current)-\(target)-\(unit.rawValue)"))
                .accessibilityHidden(true)
            HStack {
                Text("Hôm nay")
                Spacer()
                Label("Mục tiêu", systemImage: "flag.checkered")
            }.font(T.font(13, .medium)).foregroundStyle(T.sub)
        }.padding(22)
            .background(T.surface, in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(T.line, lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Cân nặng hiện tại \(Fmt.w(current, unit)), mục tiêu \(Fmt.w(target, unit)). Đường minh họa, không dự đoán ngày đạt mục tiêu.")
    }
}
