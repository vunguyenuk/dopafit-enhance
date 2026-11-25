import Foundation

@main struct V2OnboardingChecks {
    @MainActor static func main() throws {
        var count = 0
        func check(_ condition: @autoclosure () -> Bool, _ name: String) {
            guard condition() else { fatalError("FAIL: " + name) }
            count += 1
            print("PASS: " + name)
        }
        let decoder = JSONDecoder(), encoder = JSONEncoder()
        let baselineURL = URL(fileURLWithPath: "rebuild/verification/v2-comparison-flow-2026-11-24/main-state-before.json")
        let bytes = try Data(contentsOf: baselineURL)
        let legacy = try decoder.decode(AppData.self, from: bytes)
        let encoded = try encoder.encode(legacy)
        let before = try JSONSerialization.jsonObject(with: bytes) as! NSDictionary
        let after = try JSONSerialization.jsonObject(with: encoded) as! NSDictionary
        check(before == after, "legacy main JSON roundtrip retains all values")
        check(legacy.profile.currentShape == nil && legacy.profile.intensity == nil, "old profiles decode without new answers")
        check(legacy.offerExpiresAt == nil && legacy.demoProPlan == nil, "legacy state has no invented offer or selected subscription")
        var offerState = legacy
        offerState.offerExpiresAt = Date(timeIntervalSince1970: 1_800_000_000)
        offerState.demoProPlan = "year-offer"
        let offerRoundtrip = try decoder.decode(AppData.self, from: encoder.encode(offerState))
        check(offerRoundtrip.offerExpiresAt == offerState.offerExpiresAt, "offer deadline persists without resetting")
        check(offerRoundtrip.demoProPlan == "year-offer", "demo plan selection persists")
        var p = Profile(); p.sex = .other
        check(p.age == nil && p.heightCm == nil, "fresh setup invents no age or height")
        for recent: Profile.Recent? in [nil, .regular, .onOff, .returning] {
            p.recent = recent
            let route = Route.makeSteps(profile: p, obstacles: [])
            check(route.contains(.breakDuration) == (recent == .returning), "break question conditional for \(String(describing: recent))")
            if recent == .returning {
                check(route.firstIndex(of: .breakDuration) == route.firstIndex(of: .recent)! + 1, "duration follows return answer")
            }
            check(route.firstIndex(of: .activity) == route.firstIndex(of: .transformation)! + 1, "activity follows comparison")
            check(route.firstIndex(of: .weight)! < route.firstIndex(of: .targetWeight)!, "current weight precedes goal")
        }
        let route = Route.makeSteps(profile: p, obstacles: ["a", "b", "c"])
        check(route.firstIndex(of: .recent) == route.firstIndex(of: .level)! + 1, "experience leads directly to training history without intensity question")
        check(route.contains(.echo), "plate-loading screen retained")
        check(route.firstIndex(of: .reveal) == route.firstIndex(of: .forecast)! + 1, "weight direction leads directly to plan overview without repeated body pair")
        check(route[0] == .welcome && route[1] == .sex && route[2] == .desire, "sex is first setup question after welcome")
        check(route.filter { $0 == .currentShape }.count == 1, "one current physique question in new setup")
        check(BodyIllustration.currentPhoto(shape: .round, belly: nil) == "comparison-round", "current round physique directly supplies comparison")
        for shape in Profile.BodyShape.allCases {
            check(BodyIllustration.currentPhoto(shape: shape, belly: .round) == "comparison-round", "round belly overrides previous body shape \(shape)")
            check(BodyIllustration.currentPhoto(shape: shape, belly: .skip) == shape.photo, "skip respects body shape \(shape)")
        }
        check(BodyIllustration.currentPhoto(shape: .muscular, belly: .soft) == "comparison-baseline", "soft belly controls current comparison")
        check(BodyIllustration.currentPhoto(shape: .soft, belly: .flat) == "comparison-average", "flat belly controls current comparison")
        for shape in Profile.BodyShape.allCases {
            for target in Profile.BodyGoal.allCases {
                for goal in Profile.Goal.allCases {
                    let before = BodyIllustration.currentPhoto(shape: shape, belly: nil)
                    let after = BodyIllustration.targetPhoto(shape: shape, target: target, goal: goal)
                    check(BodyIllustration.showsComparison(shape: shape, target: target, goal: goal) == (BodyIllustration.cell(before) != BodyIllustration.cell(after)), "comparison uses actual cells \(shape)/\(target)/\(goal)")
                    if target == .maintain { check(before == after, "maintain keeps current image \(shape)/\(goal)") }
                }
            }
        }
        check(!BodyIllustration.showsComparison(shape: .average, target: .balanced, goal: .muscle), "average and healthy alias never make a duplicate before/after")
        check(!BodyIllustration.showsComparison(shape: .muscular, target: .balanced, goal: .health), "balanced target never depicts loss of an existing trained physique")
        check(BodyIllustration.cell(BodyIllustration.targetPhoto(shape: .round, target: .balanced, goal: .lean)) == 0, "round to balanced resolves to healthy body")
        check(BodyIllustration.bodySheet(.female) != BodyIllustration.bodySheet(.male), "body images follow selected sex")
        check(BodyIllustration.hero(.female) != BodyIllustration.hero(.male), "known female hero does not use male portrait")
        check(route.contains(.story("a")) && route.contains(.story("b")) && !route.contains(.story("c")), "at most two follow-up stories")
        for step: Route.Step in [.focus, .currentShape, .targetShape, .targetWeight, .potential, .reward, .schedule, .building, .forecast, .reveal, .reminder] {
            check(route.contains(step), "required requested surface \(step)")
        }
        for duration in Profile.TrainingBreak.allCases {
            p.trainingBreak = duration
            let decoded = try decoder.decode(Profile.self, from: encoder.encode(p))
            check(decoded.trainingBreak == duration, "duration roundtrip \(duration)")
        }
        p.currentShape = .soft; p.targetShape = .muscular; p.targetKg = 67; p.bellyShape = .round
        p.intensity = .easy; p.focusAreas = [.chest, .arms]; p.reward = .travel
        let decoded = try decoder.decode(Profile.self, from: encoder.encode(p))
        check(decoded == p, "all new choices persist together")
        check(abs(WeightUnit.lb.toKg(WeightUnit.lb.fromKg(67)) - 67) < 0.0001, "weight unit roundtrip")
        let folder = URL(fileURLWithPath: ".build/v2-onboarding-tests/fixture", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let state = AppState(storageURL: folder.appendingPathComponent("state.json"))
        state.data = AppData()
        p.recent = nil; p.level = .some; p.focusAreas = []; p.daysPerWeek = 3; p.minutes = 45
        p.place = .fullGym
        for intensity in Profile.Intensity.allCases {
            p.intensity = intensity
            let plan = state.buildPlan(profile: p)
            check(!plan.items.isEmpty, "plan exists for \(intensity)")
            if intensity == .easy { check(plan.items.allSatisfy { $0.sets.count <= 2 }, "easy caps sets at two") }
            if intensity == .steady { check(plan.items.allSatisfy { $0.sets.count <= 3 }, "steady caps sets at three") }
            check(Set(plan.items.map(\.exerciseID)).count == plan.items.count, "no duplicate exercise \(intensity)")
        }
        p.focusAreas = [.arms]
        let focused = state.buildPlan(profile: p)
        check(focused.items.first?.exercise.primary == .triceps, "arm priority reorders within push day")
        check(focused.items.contains { $0.exercise.primary == .chest }, "focus preserves chest in split")
        for sex in [Profile.Sex.male, .female] {
            p.sex = sex
            let plan = state.buildPlan(profile: p)
            check(!plan.items.isEmpty && plan.items.allSatisfy { $0.sets.count > 0 }, "valid plan for \(sex)")
            check(plan.items.contains { $0.exercise.primary == .chest }, "balanced program preserves chest for \(sex)")
            let saved = try decoder.decode(Profile.self, from: encoder.encode(p))
            check(saved.sex == sex, "sex answer persists \(sex)")
        }
        p.place = .home
        let home = state.buildPlan(profile: p)
        check(home.items.allSatisfy { p.place.gear.contains($0.exercise.gear) }, "preview respects selected place without state mutation")
        check(state.data.profile == Profile(), "preview did not save local answers")
        state.data.profile = p
        let savedBytes = try Data(contentsOf: folder.appendingPathComponent("state.json"))
        let savedData = try decoder.decode(AppData.self, from: savedBytes)
        check(savedData.profile == p, "real AppState persistence stores answers")
        check(Catalog.all.filter { $0.primary.group == .legs }.allSatisfy { $0.constrainedJoints.contains(.ankle) }, "conservative ankle filter covers leg exercises")
        for sex in [Profile.Sex.male, .female] {
            for place in Profile.Place.allCases {
                for joint in Joint.allCases {
                    var selected = Profile(); selected.sex = sex; selected.place = place
                    selected.injuries = [joint]; selected.focusAreas = [.back]
                    let plan = state.buildPlan(profile: selected)
                    check(plan.items.allSatisfy { $0.exercise.constrainedJoints.isDisjoint(with: [joint]) }, "plan excludes selected joint \(sex)/\(place)/\(joint)")
                    let suggestions = state.onboardingSuggestions(profile: selected)
                    check(suggestions.allSatisfy { $0.constrainedJoints.isDisjoint(with: [joint]) && place.gear.contains($0.gear) }, "suggestions respect joint and equipment \(sex)/\(place)/\(joint)")
                    let route = Route.makeSteps(profile: selected, obstacles: ["Thiếu động lực", "Đau mỏi hoặc chấn thương"])
                    let stories = route.filter { if case .story = $0 { return true }; return false }
                    check(stories.first == .story("Đau mỏi hoặc chấn thương") && stories.count == 2, "pain first and never duplicate \(sex)/\(place)/\(joint)")
                }
            }
        }
        var backProfile = Profile(); backProfile.focusAreas = [.back]
        check(state.onboardingSuggestions(profile: backProfile).first?.primary == .back, "back focus starts recommendations with back instead of push illustration")
        check(!state.buildPlan(profile: backProfile).reasons.contains("ưu tiên nhóm cơ bạn chọn trong lịch hôm nay"), "push-day explanation does not claim back priority when no back exercise is present")
        backProfile.injuries = Joint.allCases
        check(state.onboardingSuggestions(profile: backProfile).isEmpty, "all conflicting regions produce honest empty recommendations")
        state.data.checkIn = .pain([.shoulder])
        var draft = Profile(); draft.place = .home; draft.injuries = [.lowerBack]
        let draftPlan = state.buildPlan(profile: draft)
        check(draftPlan.items.allSatisfy { draft.place.gear.contains($0.exercise.gear) && !$0.exercise.constrainedJoints.contains(.lowerBack) }, "daily check-in replacements honor draft place and saved injury together")
        state.data.checkIn = .fine
        let timeBase = state.buildPlan(profile: Profile())
        let dataBeforeTimePreview = try encoder.encode(state.data)
        let baseIDs = timeBase.items.map(\.id)
        let baseSetCounts = timeBase.items.map { $0.sets.count }
        for budget in [15, 20, 30, 60] {
            let preview = timeBase.shortened(to: budget)
            check(preview.items.map(\.id) == Array(baseIDs.prefix(preview.items.count)), "short preview keeps actual exercise order \(budget)")
            check(preview.items.allSatisfy { $0.sets.count >= 2 }, "short preview retains minimum sets \(budget)")
            check(preview.minutes <= timeBase.minutes, "short preview never increases estimated duration \(budget)")
            state.data.checkIn = .short(budget)
            var actual = timeBase; state.applyCheckIn(&actual)
            check(actual.items.map(\.exerciseID) == preview.items.map(\.exerciseID) && actual.items.map { $0.sets.count } == preview.items.map { $0.sets.count }, "onboarding preview matches real daily short adjustment \(budget)")
        }
        state.data.checkIn = .fine
        check(timeBase.items.map { $0.sets.count } == baseSetCounts, "short preview preserves original plan value")
        let timeDataBefore = try JSONSerialization.jsonObject(with: dataBeforeTimePreview) as! NSDictionary
        let timeDataAfter = try JSONSerialization.jsonObject(with: encoder.encode(state.data)) as! NSDictionary
        check(timeDataBefore == timeDataAfter, "budget previews do not save profile/history/check-in changes")
        let emptyTime = PlannedWorkout(name: "Empty", focus: "", reasons: [], items: []).shortened(to: 20)
        check(emptyTime.items.isEmpty, "empty plan preview invents no exercises")
        print("\(count) V2 onboarding checks passed. Not UI or original rebuild parity evidence.")
    }
}
