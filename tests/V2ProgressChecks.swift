import Foundation

@main struct V2ProgressChecks {
    @MainActor static func main() throws {
        var count = 0
        func check(_ condition: @autoclosure () -> Bool, _ message: String) {
            guard condition() else { fatalError("FAIL: " + message) }
            count += 1; print("PASS: " + message)
        }
        let cal = Calendar.vn
        let now = cal.date(from: DateComponents(year: 2026, month: 11, day: 25, hour: 12))!
        let monday = cal.dateInterval(of: .weekOfYear, for: now)!.start
        func day(_ offset: Int, from base: Date? = nil) -> Date { cal.date(byAdding: .day, value: offset, to: base ?? monday)! }
        let folder = URL(fileURLWithPath: ".build/v2-progress-tests/fixture")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("state.json")
        let state = AppState(storageURL: url); state.data = AppData(); state.data.profile.daysPerWeek = 2
        let lift = Catalog.all.first { $0.primary == .shoulders && $0.gear == .dumbbell && $0.perSide }!
        let item = WorkoutItem(exerciseID: lift.id, sets: [LoggedSet(weightKg: 10, reps: 10, done: true), LoggedSet(weightKg: 99, reps: 10, done: false)], targetReps: 10)
        func session(_ date: Date, items: [WorkoutItem] = [item]) -> Session { Session(name: "Test", started: date, seconds: 60, items: items) }
        state.data.history = [session(day(0)), session(day(0).addingTimeInterval(3600)), session(day(1)), session(day(5)), session(day(2), items: [])]
        check(state.completedSessions(now: now).count == 3, "exclude future and zero-set sessions")
        check(state.trainedDays(inWeekOf: now, now: now) == 2, "multiple sessions on one date count as one training day")
        check(abs(state.effectiveSets(.shoulders, weekOf: now, now: now) - 3) < 0.001, "only completed primary sets counted")
        if let secondary = lift.secondary.first {
            check(abs(state.effectiveSets(secondary, weekOf: now, now: now) - 1.5) < 0.001, "secondary sets contribute one half")
        }
        check(state.effectiveSets(.shoulders, weekOf: day(-7), now: now) == 0, "week start and end do not bleed across weeks")
        let interval = DateInterval(start: monday, end: day(3))
        let volume = state.volumeSeries(.push, in: interval, now: now)
        check(volume.count == 2, "report aggregates sessions by actual date without invented empty days")
        check(abs(volume.reduce(0) { $0 + $1.value } - 600) < 0.001, "per-hand volume doubled once and incomplete sets excluded")
        let strength = state.weeklyStrength(in: interval, now: now)
        check(strength.count == 1 && abs(strength[0].value - (10 * (1 + 10.0 / 30))) < 0.001, "weekly strength uses best valid weighted set")
        check(state.reportSessions(in: DateInterval(start: day(1), end: day(2)), now: now).count == 1, "report interval has exclusive end")
        check(state.weeklyStreak(now: now) == 1, "completed current week begins a real streak")
        state.data.history += [session(day(-7)), session(day(-6)), session(day(-21)), session(day(-20))]
        check(state.weeklyStreak(now: now) == 2, "streak stops at missing week")
        state.data.history.removeAll { $0.started >= monday }
        check(state.weeklyStreak(now: now) == 1, "incomplete current week retains completed previous week")
        state.data.history = []
        check(state.weeklyStreak(now: now) == 0, "no fabricated streak for empty history")
        check(state.milestones(now: now).allSatisfy { $0.level == 0 }, "no unearned badges in empty state")
        check(state.milestones(now: now).first { $0.id == "calories" }!.value == nil, "missing calories are unknown rather than estimated")
        var calorieSession = session(day(0)); calorieSession.caloriesKcal = 100
        state.data.history = [calorieSession, session(day(1)), session(day(1).addingTimeInterval(3600))]
        check(state.milestones(now: now).first { $0.id == "sessions" }!.level == 1, "exactly three completed sessions earns first session badge")
        check(state.milestones(now: now).first { $0.id == "calories" }!.value == 100, "only explicitly recorded calories summed")
        let capped = TrainingMilestone(id: "t", title: "t", value: 1000, tiers: [3, 10], unit: "", icon: "")
        check(capped.completed && capped.level == 2 && capped.progress == 1, "milestone beyond final tier remains complete")
        for group in MuscleGroup.allCases {
            let goals = state.groupGoal(group, weekOf: now, now: now)
            check(goals.target == Muscle.allCases.filter { $0.group == group }.reduce(0) { $0 + state.muscleTarget($1) }, "group and muscle targets reconcile \(group)")
        }
        let savedHistory = state.data.history
        state.data.history = (0..<30).map { _ in session(day(0)) }
        let goals = MuscleGroup.allCases.map { state.groupGoal($0, weekOf: now, now: now) }
        let cappedTotal = goals.reduce(0) { $0 + min($1.done, $1.target) }
        let allTargets = goals.reduce(0) { $0 + $1.target }
        check(abs(state.weeklyGoalProgress(weekOf: now, now: now) - cappedTotal / allTargets) < 0.0001, "goal percentage reconciles capped group numerator")
        check(state.weeklyGoalProgress(weekOf: now, now: now) < 1, "overtraining one group cannot complete all group goals")
        state.data.history = savedHistory
        check(state.measurements(.weight).isEmpty, "default profile weight is not fabricated measurement history")
        let first = BodyMeasurement(metric: .weight, date: day(0), value: 70)
        check(state.saveMeasurement(first, now: now), "valid weight record saved")
        let latest = BodyMeasurement(metric: .weight, date: day(1), value: 68)
        check(state.saveMeasurement(latest, now: now) && state.data.profile.bodyKg == 68, "latest weight updates profile")
        var edit = first; edit.value = 72
        check(state.saveMeasurement(edit, now: now) && state.measurements(.weight).count == 2 && state.data.profile.bodyKg == 68, "editing older weight does not overwrite latest or duplicate ID")
        check(!state.saveMeasurement(BodyMeasurement(metric: .bodyFat, date: now, value: 101), now: now), "reject invalid percentage")
        check(!state.saveMeasurement(BodyMeasurement(metric: .weight, date: now, value: .infinity), now: now), "reject nonfinite measurements")
        check(!state.saveMeasurement(BodyMeasurement(metric: .waist, date: day(5), value: 90), now: now), "reject future measurements")
        check(abs(BodyMetric.weight.canonical(BodyMetric.weight.display(70, unit: .lb), unit: .lb) - 70) < 0.0001, "measurement kg/lb roundtrip")
        check(BodyMetric.waist.unit(.lb) == "cm", "body circumference not converted to weight units")
        let id = state.data.history[0].id
        let oldVolume = state.data.history[0].volumeKg
        check(!state.updateSessionDuration(id, seconds: 0), "reject zero saved duration")
        check(state.updateSessionDuration(id, seconds: 40) && state.data.history[0].volumeKg == oldVolume, "duration edit preserves sets and volume")
        let decoded = AppState(storageURL: url)
        check(decoded.measurements(.weight).count == 2 && decoded.data.history[0].seconds == 40, "measurements and duration persist through real AppState")
        let old = try Data(contentsOf: URL(fileURLWithPath: "rebuild/verification/v2-progress-journal-2026-11-25/main-turnstart.json"))
        let legacy = try JSONDecoder().decode(AppData.self, from: old)
        check(legacy.bodyMeasurements == nil && legacy.profile.birthDate == nil, "old saved schema decodes without new fields")
        // One fresh onboarding profile → workout → save → analytics, no demo history.
        let journeyURL = folder.appendingPathComponent("journey.json")
        let journey = AppState(storageURL: journeyURL)
        journey.data = AppData()
        var chosen = Profile(); chosen.sex = .female; chosen.place = .home
        chosen.level = .new; chosen.daysPerWeek = 2; chosen.minutes = 30
        chosen.focusAreas = [.back]; chosen.injuries = [.lowerBack]
        journey.data.profile = chosen; journey.data.onboarded = true; journey.data.sawPro = true
        let preview = journey.buildPlan(profile: chosen)
        let homePlan = journey.plan
        check(preview.name == homePlan.name && preview.items.map(\.exerciseID) == homePlan.items.map(\.exerciseID), "saved onboarding answers and Home plan agree")
        check(homePlan.items.allSatisfy { !$0.exercise.constrainedJoints.contains(.lowerBack) && chosen.place.gear.contains($0.exercise.gear) }, "Home retains injury and place constraints after onboarding")
        journey.start(homePlan)
        check(journey.data.history.isEmpty && journey.active != nil, "starting workout does not fabricate history")
        journey.active!.items[0].sets[0].done = true
        let saved = journey.finish()!
        let observedNow = Date().addingTimeInterval(1)
        check(journey.active == nil && journey.data.history.count == 1, "finishing one logged workout writes exactly one session")
        check(saved.items.count == 1 && saved.items[0].sets.filter(\.done).count == 1, "unfinished exercises do not become statistics")
        check(journey.trainedDays(inWeekOf: observedNow, now: observedNow) == 1, "saved workout becomes one trained calendar day")
        let muscle = saved.items[0].exercise.primary
        check(journey.effectiveSets(muscle, weekOf: observedNow, now: observedNow) == 1, "statistics count the actual completed primary set")
        let reload = AppState(storageURL: journeyURL)
        check(reload.data.profile == chosen && reload.data.history.count == 1, "profile and first saved workout survive relaunch")
        print("\(count) V2 progress model checks passed. Not live UI parity evidence.")
    }
}
