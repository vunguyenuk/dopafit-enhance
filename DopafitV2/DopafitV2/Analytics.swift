import Foundation

enum BodyMetric: String, Codable, CaseIterable, Identifiable {
    case weight, bodyFat, muscleMass, leanMass, water, chest, waist, hips, arm, thigh, calf, neck
    var id: String { rawValue }
    var name: String {
        switch self {
        case .weight: "Cân nặng"; case .bodyFat: "Mỡ cơ thể"; case .muscleMass: "Khối lượng cơ"
        case .leanMass: "Khối lượng không mỡ"; case .water: "Nước cơ thể"
        case .chest: "Vòng ngực"; case .waist: "Vòng eo"; case .hips: "Vòng hông"
        case .arm: "Bắp tay"; case .thigh: "Đùi"; case .calf: "Bắp chân"; case .neck: "Vòng cổ"
        }
    }
    var composition: Bool { [.weight, .bodyFat, .muscleMass, .leanMass, .water].contains(self) }
    var mass: Bool { [.weight, .muscleMass, .leanMass].contains(self) }
    var percent: Bool { self == .bodyFat || self == .water }
    var icon: String { mass ? "scalemass" : (percent ? "drop" : "ruler") }
    var validRange: ClosedRange<Double> { mass ? 1...500 : (percent ? 0.1...100 : 1...300) }
    func unit(_ preference: WeightUnit) -> String { mass ? preference.label : (percent ? "%" : "cm") }
    func display(_ value: Double, unit: WeightUnit) -> Double { mass ? unit.fromKg(value) : value }
    func canonical(_ value: Double, unit: WeightUnit) -> Double { mass ? unit.toKg(value) : value }
}

struct BodyMeasurement: Codable, Identifiable, Equatable {
    var id = UUID()
    var metric: BodyMetric
    var date: Date
    /// Canonical kg, cm, or percentage. Never infer a measurement from a profile default.
    var value: Double
}

struct AnalyticsPoint: Identifiable {
    var date: Date
    var value: Double
    var id: Date { date }
}

struct TrainingMilestone: Identifiable {
    var id: String
    var title: String
    var value: Double?
    var tiers: [Double]
    var unit: String
    var icon: String
    var level: Int { guard let value else { return 0 }; return tiers.filter { value >= $0 }.count }
    var next: Double { tiers.first { (value ?? 0) < $0 } ?? tiers.last ?? 1 }
    var completed: Bool { level == tiers.count && !tiers.isEmpty }
    var progress: Double { min(1, max(0, (value ?? 0) / max(1, next))) }
}

@MainActor extension AppState {
    @discardableResult func updateSessionDuration(_ id: UUID, seconds: Int) -> Bool {
        guard (1...86_400).contains(seconds), let index = data.history.firstIndex(where: { $0.id == id }) else { return false }
        data.history[index].seconds = seconds
        return true
    }
    func completedSessions(now: Date = Date()) -> [Session] {
        data.history.filter { $0.started <= now && $0.setCount > 0 }.sorted { $0.started < $1.started }
    }
    func trainedDays(inWeekOf date: Date, now: Date = Date()) -> Int {
        guard let interval = Calendar.vn.dateInterval(of: .weekOfYear, for: date) else { return 0 }
        return Set(completedSessions(now: now).filter { $0.started >= interval.start && $0.started < interval.end }
            .map { Calendar.vn.startOfDay(for: $0.started) }).count
    }
    /// An incomplete current week does not erase a run of completed previous weeks.
    func weeklyStreak(now: Date = Date()) -> Int {
        let cal = Calendar.vn
        guard var week = cal.dateInterval(of: .weekOfYear, for: now)?.start else { return 0 }
        if trainedDays(inWeekOf: week, now: now) < data.profile.daysPerWeek {
            week = cal.date(byAdding: .weekOfYear, value: -1, to: week)!
        }
        var count = 0
        while count < 520 && trainedDays(inWeekOf: week, now: now) >= data.profile.daysPerWeek {
            count += 1; week = cal.date(byAdding: .weekOfYear, value: -1, to: week)!
        }
        return count
    }
    func effectiveSets(_ muscle: Muscle, weekOf date: Date, now: Date = Date()) -> Double {
        guard let interval = Calendar.vn.dateInterval(of: .weekOfYear, for: date) else { return 0 }
        return completedSessions(now: now).filter { $0.started >= interval.start && $0.started < interval.end }.reduce(0) { sum, session in
            sum + session.items.reduce(0) { subtotal, item in
                let factor: Double = item.exercise.primary == muscle ? 1 : (item.exercise.secondary.contains(muscle) ? 0.5 : 0)
                return subtotal + Double(item.sets.filter(\.done).count) * factor
            }
        }
    }
    /// V2 allocation of its existing group target. This is not the private original target algorithm.
    func muscleTarget(_ muscle: Muscle) -> Double {
        let group = Muscle.allCases.filter { $0.group == muscle.group }
        return max(1, (Double(weeklyTarget(muscle.group)) / Double(group.count) * 2).rounded() / 2)
    }
    func groupGoal(_ group: MuscleGroup, weekOf date: Date, now: Date = Date()) -> (done: Double, target: Double) {
        let muscles = Muscle.allCases.filter { $0.group == group }
        return (muscles.reduce(0) { $0 + effectiveSets($1, weekOf: date, now: now) }, muscles.reduce(0) { $0 + muscleTarget($1) })
    }
    func weeklyGoalProgress(weekOf date: Date, now: Date = Date()) -> Double {
        let values = MuscleGroup.allCases.map { groupGoal($0, weekOf: date, now: now) }
        return min(1, values.reduce(0) { $0 + min($1.done, $1.target) } / max(1, values.reduce(0) { $0 + $1.target }))
    }
    func reportSessions(in interval: DateInterval, now: Date = Date()) -> [Session] {
        completedSessions(now: now).filter { $0.started >= interval.start && $0.started < interval.end }
    }
    func weeklyStrength(in interval: DateInterval, now: Date = Date()) -> [AnalyticsPoint] {
        var buckets: [Date: Double] = [:]
        for session in reportSessions(in: interval, now: now) {
            let best = session.items.filter { !$0.exercise.bodyweightOnly }.flatMap(\.sets)
                .filter { $0.done && $0.weightKg.isFinite && $0.weightKg > 0 && $0.reps > 0 }
                .map { Self.e1rm($0.weightKg, $0.reps) }.max()
            if let best, let week = Calendar.vn.dateInterval(of: .weekOfYear, for: session.started)?.start {
                buckets[week] = max(buckets[week] ?? 0, best)
            }
        }
        return buckets.map { AnalyticsPoint(date: $0.key, value: $0.value) }.sorted { $0.date < $1.date }
    }
    func volumeSeries(_ group: MuscleGroup, in interval: DateInterval, now: Date = Date()) -> [AnalyticsPoint] {
        var buckets: [Date: Double] = [:]
        for session in reportSessions(in: interval, now: now) {
            let value = session.items.filter { $0.exercise.primary.group == group }.reduce(0.0) { sum, item in
                sum + item.sets.filter { $0.done && $0.reps > 0 && $0.weightKg.isFinite && $0.weightKg > 0 }
                    .reduce(0) { $0 + $1.weightKg * Double($1.reps) * (item.exercise.perSide ? 2 : 1) }
            }
            guard value > 0 else { continue }
            let date = Calendar.vn.startOfDay(for: session.started)
            buckets[date, default: 0] += value
        }
        return buckets.map { AnalyticsPoint(date: $0.key, value: $0.value) }.sorted { $0.date < $1.date }
    }
    func milestones(now: Date = Date()) -> [TrainingMilestone] {
        let sessions = completedSessions(now: now)
        let calories = sessions.compactMap(\.caloriesKcal).filter { $0.isFinite && $0 >= 0 }
        return [
            TrainingMilestone(id: "volume", title: "Khối lượng", value: sessions.reduce(0) { $0 + $1.volumeKg }, tiers: [10_000, 25_000, 50_000, 100_000, 250_000, 500_000], unit: unit.label, icon: "dumbbell"),
            TrainingMilestone(id: "sessions", title: "Số buổi tập", value: Double(sessions.count), tiers: [3, 10, 25, 50, 100, 250, 500], unit: "buổi", icon: "calendar"),
            TrainingMilestone(id: "calories", title: "Calo", value: calories.isEmpty ? nil : calories.reduce(0, +), tiers: [1_000, 5_000, 10_000, 25_000, 50_000, 100_000], unit: "kcal", icon: "flame")
        ]
    }
    func measurements(_ metric: BodyMetric) -> [BodyMeasurement] {
        (data.bodyMeasurements ?? []).filter { $0.metric == metric }.sorted { $0.date < $1.date }
    }
    @discardableResult func saveMeasurement(_ record: BodyMeasurement, now: Date = Date()) -> Bool {
        guard record.value.isFinite, record.metric.validRange.contains(record.value), record.date <= now else { return false }
        var records = data.bodyMeasurements ?? []
        if let i = records.firstIndex(where: { $0.id == record.id }) { records[i] = record }
        else { records.append(record) }
        data.bodyMeasurements = records
        if record.metric == .weight, let latest = measurements(.weight).last { data.profile.bodyKg = latest.value }
        return true
    }
}
