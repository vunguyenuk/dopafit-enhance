import Foundation
import SwiftUI

// MARK: - Danh mục cơ bản

enum WeightUnit: String, Codable, CaseIterable {
    case kg, lb
    var label: String { rawValue }
    func fromKg(_ kg: Double) -> Double { self == .kg ? kg : kg * 2.20462 }
    func toKg(_ v: Double) -> Double { self == .kg ? v : v / 2.20462 }
    /// Bước tăng/giảm khi bấm +/−.
    var step: Double { self == .kg ? 2.5 : 5 }
}

enum Muscle: String, Codable, CaseIterable, Identifiable {
    case chest, shoulders, triceps, back, lowerBack, biceps, forearm, abs, quads, hamstrings, glutes, calves, adductors
    var id: String { rawValue }
    var name: String {
        switch self {
        case .chest: "Ngực"
        case .shoulders: "Vai"
        case .triceps: "Tay sau"
        case .back: "Lưng"
        case .lowerBack: "Lưng dưới"
        case .biceps: "Tay trước"
        case .forearm: "Cẳng tay"
        case .abs: "Bụng"
        case .quads: "Đùi trước"
        case .hamstrings: "Đùi sau"
        case .glutes: "Mông"
        case .calves: "Bắp chân"
        case .adductors: "Đùi trong"
        }
    }
    /// Tên vùng trong sơ đồ cơ thể 2D.
    var bodySlugs: [String] {
        switch self {
        case .chest: ["chest"]
        case .shoulders: ["deltoids"]
        case .triceps: ["triceps"]
        case .back: ["upper-back", "trapezius"]
        case .lowerBack: ["lower-back"]
        case .biceps: ["biceps"]
        case .forearm: ["forearm"]
        case .abs: ["abs", "obliques"]
        case .quads: ["quadriceps"]
        case .hamstrings: ["hamstring"]
        case .glutes: ["gluteal"]
        case .calves: ["calves", "tibialis"]
        case .adductors: ["adductors"]
        }
    }
    var group: MuscleGroup {
        switch self {
        case .chest, .shoulders, .triceps: .push
        case .back, .lowerBack, .biceps, .forearm: .pull
        case .quads, .hamstrings, .glutes, .calves, .adductors: .legs
        case .abs: .core
        }
    }
}

enum MuscleGroup: String, CaseIterable {
    case push, pull, legs, core
    var name: String {
        switch self { case .push: "Nhóm đẩy"; case .pull: "Nhóm kéo"; case .legs: "Chân"; case .core: "Bụng" }
    }
    var detail: String {
        switch self {
        case .push: "Ngực, vai, tay sau"
        case .pull: "Lưng, tay trước, cẳng tay"
        case .legs: "Đùi, mông, bắp chân"
        case .core: "Cơ bụng"
        }
    }
}

enum Gear: String, Codable, CaseIterable {
    case barbell, dumbbell, cable, machine, smith, band, bodyweight, tbar
    var name: String {
        switch self {
        case .barbell: "Tạ đòn"
        case .dumbbell: "Tạ đơn"
        case .cable: "Cáp"
        case .machine: "Máy tập"
        case .smith: "Máy Smith"
        case .band: "Dây kháng lực"
        case .bodyweight: "Không cần dụng cụ"
        case .tbar: "Máy kéo chữ T"
        }
    }
}

enum Joint: String, Codable, CaseIterable, Identifiable {
    case neck, shoulder, elbow, wrist, lowerBack, knee
    var id: String { rawValue }
    var name: String {
        switch self {
        case .neck: "Cổ"; case .shoulder: "Vai"; case .elbow: "Khuỷu tay"
        case .wrist: "Cổ tay"; case .lowerBack: "Lưng dưới"; case .knee: "Đầu gối"
        }
    }
}

struct Exercise: Identifiable, Hashable {
    var id: String
    var name: String
    var english: String
    var gear: Gear
    var primary: Muscle
    var secondary: [Muscle]
    var media: String?           // tên file video trong bundle (không đuôi)
    var sets: Int
    var reps: Int
    var weightKg: Double         // tạ khởi điểm cho người tập trung bình
    var perSide = false          // tạ ghi cho mỗi tay
    var loads: [Joint] = []
    var compound = false
    var setup: [String] = []
    var mistakes: [String] = []

    var isBarbell: Bool { gear == .barbell || gear == .smith }
    var bodyweightOnly: Bool { gear == .bodyweight || gear == .band }
    var restSeconds: Int { compound ? 120 : 75 }
    var weightNote: String? {
        if perSide { return "mỗi tay" }
        if gear == .barbell { return "gồm thanh đòn 20 kg" }
        return nil
    }
}

// MARK: - Dữ liệu buổi tập

struct LoggedSet: Codable, Hashable, Identifiable {
    var id = UUID()
    var weightKg: Double
    var reps: Int
    var done = false
    var edited = false
}

struct WorkoutItem: Codable, Hashable, Identifiable {
    var id = UUID()
    var exerciseID: String
    var sets: [LoggedSet]
    var targetReps: Int
    /// Ghi chú khi bài bị đổi do check-in ("−1 set", "đổi vì đau gối"...).
    var change: String? = nil
    var exercise: Exercise { Catalog.byID[exerciseID] ?? Catalog.all[0] }
}

struct Session: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var started: Date
    var seconds: Int
    var items: [WorkoutItem]
    var doneSets: [(WorkoutItem, LoggedSet)] {
        items.flatMap { item in item.sets.filter(\.done).map { (item, $0) } }
    }
    var setCount: Int { items.reduce(0) { $0 + $1.sets.filter(\.done).count } }
    var volumeKg: Double {
        items.reduce(0) { acc, item in
            acc + item.sets.filter(\.done).reduce(0) { $0 + $1.weightKg * Double($1.reps) * (item.exercise.perSide ? 2 : 1) }
        }
    }
    static func == (a: Session, b: Session) -> Bool { a.id == b.id }
    func hash(into h: inout Hasher) { h.combine(id) }
}

struct Profile: Codable, Equatable {
    enum Goal: String, Codable, CaseIterable { case muscle, strength, lean, health
        var name: String { switch self { case .muscle: "Tăng cơ"; case .strength: "Khỏe hơn"; case .lean: "Giảm mỡ, săn chắc"; case .health: "Khỏe mạnh, đều đặn" } }
        var icon: String { switch self { case .muscle: "figure.strengthtraining.traditional"; case .strength: "scalemass"; case .lean: "flame"; case .health: "heart" } }
    }
    enum Level: String, Codable, CaseIterable { case new, some, experienced
        var name: String { switch self { case .new: "Mới bắt đầu"; case .some: "6 tháng – 2 năm"; case .experienced: "Trên 2 năm" } }
        var detail: String { switch self { case .new: "Chưa tập hoặc tập dưới 6 tháng"; case .some: "Đã quen các bài cơ bản"; case .experienced: "Tập đều, biết mức tạ của mình" } }
        var factor: Double { switch self { case .new: 0.6; case .some: 0.85; case .experienced: 1.05 } }
    }
    enum Place: String, Codable, CaseIterable { case fullGym, smallGym, home
        var name: String { switch self { case .fullGym: "Phòng gym đầy đủ"; case .smallGym: "Phòng gym nhỏ"; case .home: "Ở nhà" } }
        var detail: String { switch self { case .fullGym: "Tạ đòn, máy, cáp, tạ đơn"; case .smallGym: "Tạ đơn, ghế, vài máy cơ bản"; case .home: "Tạ đơn đến 20 kg, dây kháng lực" } }
        var icon: String { switch self { case .fullGym: "building.2"; case .smallGym: "dumbbell"; case .home: "house" } }
        var gear: Set<Gear> {
            switch self {
            case .fullGym: Set(Gear.allCases)
            case .smallGym: [.dumbbell, .machine, .cable, .bodyweight, .band]
            case .home: [.dumbbell, .band, .bodyweight]
            }
        }
    }
    enum Sex: String, Codable, CaseIterable { case male, female, other
        var name: String { switch self { case .male: "Nam"; case .female: "Nữ"; case .other: "Khác" } }
    }
    var name = ""
    var goal: Goal = .muscle
    var level: Level = .some
    var place: Place = .fullGym
    var daysPerWeek = 3
    var minutes = 45
    var sex: Sex = .male
    var age = 28
    var bodyKg: Double = 70
    var unit: WeightUnit = .kg
    // Thêm ở bản thiết lập mới (để Optional cho dữ liệu cũ vẫn đọc được)
    var recent: Recent? = nil
    var obstacles: [String]? = nil
    var reminderHour: Int? = nil
    var firstDay: Date? = nil

    enum Recent: String, Codable, CaseIterable { case regular, onOff, returning
        var name: String { switch self { case .regular: "Đang tập đều"; case .onOff: "Lúc tập lúc nghỉ"; case .returning: "Đang nghỉ, muốn tập lại" } }
        var icon: String { switch self { case .regular: "checkmark.seal"; case .onOff: "waveform.path"; case .returning: "arrow.uturn.backward" } }
    }
}

enum CheckIn: Codable, Equatable {
    case fine
    case tired
    case pain([Joint])
    case short(Int)
    var title: String {
        switch self {
        case .fine: "Khỏe"
        case .tired: "Hơi mệt"
        case .pain(let j): j.isEmpty ? "Đang đau" : "Đau " + j.map { $0.name.lowercased() }.joined(separator: ", ")
        case .short(let m): "Chỉ có \(m) phút"
        }
    }
    var icon: String {
        switch self { case .fine: "face.smiling"; case .tired: "battery.25"; case .pain: "bandage"; case .short: "timer" }
    }
}

struct AppData: Codable {
    var onboarded = false
    var sawPro = false
    var isPro = false
    var profile = Profile()
    var history: [Session] = []
    var checkIn: CheckIn = .fine
    var checkInDate: Date? = nil
    var gentle = false
    var textScale: Double = 1
    var swaps: [String: String] = [:]     // bài gốc -> bài thay (do người dùng chọn)
    var removed: [String] = []            // bài người dùng bỏ khỏi buổi hôm nay
    var added: [String] = []              // bài người dùng thêm
    var planDate: Date? = nil
    var sawOffer: Bool? = nil
}

struct PlannedWorkout {
    var name: String
    var focus: String
    var reasons: [String]
    var items: [WorkoutItem]
    var minutes: Int { items.reduce(0) { $0 + $1.sets.count * ($1.exercise.restSeconds + 45) } / 60 + 4 }
}

struct ActiveWorkout {
    var name: String
    var started = Date()
    var items: [WorkoutItem]
    var current = 0
    var restEnds: Date? = nil
    var restTotal = 90
}

// MARK: - Trạng thái ứng dụng

@MainActor
final class AppState: ObservableObject {
    @Published var data = AppData() { didSet { save() } }
    @Published var active: ActiveWorkout? = nil
    @Published var lastFinished: Session? = nil

    private let url: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("DopafitV2", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("state.json")
    }()

    init() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--reset") {
            try? FileManager.default.removeItem(at: url)
        }
        if let d = try? Data(contentsOf: url), let decoded = try? JSONDecoder().decode(AppData.self, from: d) {
            data = decoded
        }
        if args.contains("--demo") && data.history.isEmpty { loadDemo() }
        resetDailyIfNeeded()
        save()
    }

    private func save() {
        if let d = try? JSONEncoder().encode(data) { try? d.write(to: url, options: .atomic) }
    }

    var unit: WeightUnit { data.profile.unit }

    /// Check-in và các chỉnh sửa trong ngày chỉ áp dụng cho hôm nay.
    func resetDailyIfNeeded() {
        let cal = Calendar.current
        if let d = data.checkInDate, !cal.isDateInToday(d) { data.checkIn = .fine; data.checkInDate = nil }
        if let d = data.planDate, !cal.isDateInToday(d) { data.swaps = [:]; data.removed = []; data.added = []; data.planDate = nil }
    }

    func setCheckIn(_ c: CheckIn) { data.checkIn = c; data.checkInDate = Date() }
    func touchPlan() { data.planDate = Date() }

    // MARK: Lịch sử & thống kê

    var sortedHistory: [Session] { data.history.sorted { $0.started > $1.started } }
    var lastSession: Session? { sortedHistory.first }
    var daysSinceLast: Int? {
        guard let last = lastSession else { return nil }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: last.started), to: Calendar.current.startOfDay(for: Date())).day
    }
    func sessions(inWeekOf date: Date) -> [Session] {
        let cal = Calendar.vn
        guard let week = cal.dateInterval(of: .weekOfYear, for: date) else { return [] }
        return data.history.filter { week.contains($0.started) }
    }
    func trained(on day: Date) -> Bool { data.history.contains { Calendar.current.isDate($0.started, inSameDayAs: day) } }

    /// Lần gần nhất tập bài này.
    func lastItem(for exerciseID: String, before: Date = .distantFuture) -> WorkoutItem? {
        for s in sortedHistory where s.started < before {
            if let it = s.items.first(where: { $0.exerciseID == exerciseID && $0.sets.contains(where: \.done) }) { return it }
        }
        return nil
    }

    /// 1RM ước tính (công thức Epley), giới hạn 1–12 rep để tránh số vô lý.
    static func e1rm(_ w: Double, _ reps: Int) -> Double {
        guard w > 0, reps > 0 else { return 0 }
        let r = Double(min(reps, 12))
        return reps == 1 ? w : w * (1 + r / 30)
    }
    func bestE1RM(_ exerciseID: String, before: Date = .distantFuture) -> Double {
        var best = 0.0
        for s in data.history where s.started < before {
            for it in s.items where it.exerciseID == exerciseID {
                for set in it.sets where set.done { best = max(best, Self.e1rm(set.weightKg, set.reps)) }
            }
        }
        return best
    }
    func e1rmSeries(_ exerciseID: String) -> [(Date, Double)] {
        data.history.sorted { $0.started < $1.started }.compactMap { s in
            let v = s.items.filter { $0.exerciseID == exerciseID }.flatMap(\.sets).filter(\.done).map { Self.e1rm($0.weightKg, $0.reps) }.max()
            return v.map { (s.started, $0) }
        }
    }
    var trackedLifts: [Exercise] {
        var counts: [String: Int] = [:]
        for s in data.history { for it in s.items where it.exercise.gear != .bodyweight && it.sets.contains(where: \.done) { counts[it.exerciseID, default: 0] += 1 } }
        return counts.filter { $0.value >= 1 }.sorted { $0.value > $1.value }.prefix(6).compactMap { Catalog.byID[$0.key] }
    }

    // MARK: Hồi phục

    /// 0 = vừa tập rất nặng, 1 = sẵn sàng. Mỗi set chính tính 1, set phụ tính 0,5; hồi trong 72 giờ.
    func readiness(_ m: Muscle, now: Date = Date()) -> Double {
        var load = 0.0
        for s in data.history {
            let hours = now.timeIntervalSince(s.started) / 3600
            guard hours >= 0, hours < 72 else { continue }
            let decay = 1 - hours / 72
            for it in s.items {
                let n = Double(it.sets.filter(\.done).count)
                if it.exercise.primary == m { load += n * decay }
                else if it.exercise.secondary.contains(m) { load += n * 0.5 * decay }
            }
        }
        return max(0, min(1, 1 - load / 10))
    }
    func hoursUntilReady(_ m: Muscle) -> Int {
        var h = 0
        while h < 72 && readiness(m, now: Date().addingTimeInterval(Double(h) * 3600)) < 0.8 { h += 4 }
        return h
    }

    func weeklySets(_ g: MuscleGroup, weekOf date: Date = Date()) -> Int {
        sessions(inWeekOf: date).reduce(0) { acc, s in
            acc + s.items.filter { $0.exercise.primary.group == g }.reduce(0) { $0 + $1.sets.filter(\.done).count }
        }
    }
    func weeklyTarget(_ g: MuscleGroup) -> Int {
        let base: Int = data.profile.level == .new ? 8 : (data.profile.level == .some ? 10 : 12)
        let scaled = Int((Double(base) * Double(data.profile.daysPerWeek) / 3).rounded())
        return g == .core ? max(4, scaled / 2) : max(6, scaled)
    }

    // MARK: Lên buổi tập hôm nay

    var templates: [(String, String, [Muscle])] {
        switch data.profile.daysPerWeek {
        case ...2: return [("Toàn thân A", "Toàn thân", [.quads, .chest, .back, .shoulders, .hamstrings, .biceps, .abs]),
                           ("Toàn thân B", "Toàn thân", [.hamstrings, .back, .chest, .glutes, .shoulders, .triceps, .abs])]
        case 3: return [("Ngày đẩy", "Ngực · vai · tay sau", [.chest, .chest, .shoulders, .shoulders, .triceps, .triceps, .abs]),
                        ("Ngày kéo", "Lưng · tay trước", [.back, .back, .shoulders, .biceps, .biceps, .back, .forearm]),
                        ("Ngày chân", "Đùi · mông · bắp chân", [.quads, .hamstrings, .quads, .glutes, .adductors, .calves, .abs])]
        case 4: return [("Thân trên A", "Ngực · lưng · vai · tay", [.chest, .back, .shoulders, .back, .triceps, .biceps, .shoulders]),
                        ("Thân dưới A", "Đùi · mông · bụng", [.quads, .hamstrings, .glutes, .adductors, .calves, .abs, .quads]),
                        ("Thân trên B", "Lưng · ngực · vai · tay", [.back, .chest, .shoulders, .biceps, .triceps, .chest, .back]),
                        ("Thân dưới B", "Đùi sau · đùi trước · bụng", [.hamstrings, .quads, .glutes, .calves, .abs, .adductors, .hamstrings])]
        default: return [("Ngày đẩy", "Ngực · vai · tay sau", [.chest, .chest, .shoulders, .shoulders, .triceps, .triceps, .abs]),
                         ("Ngày kéo", "Lưng · tay trước", [.back, .back, .shoulders, .biceps, .biceps, .back, .forearm]),
                         ("Ngày chân", "Đùi · mông · bắp chân", [.quads, .hamstrings, .quads, .glutes, .adductors, .calves, .abs]),
                         ("Thân trên", "Ngực · lưng · vai", [.chest, .back, .shoulders, .back, .triceps, .biceps, .chest]),
                         ("Thân dưới", "Đùi · mông · bụng", [.hamstrings, .quads, .glutes, .calves, .abs, .adductors, .quads])]
        }
    }

    var availableGear: Set<Gear> {
        var g = data.profile.place.gear
        if data.gentle { g.remove(.barbell); g.remove(.smith); g.remove(.tbar) }
        return g
    }

    func alternatives(for ex: Exercise, avoiding joints: [Joint] = []) -> [Exercise] {
        Catalog.all.filter { $0.id != ex.id && $0.primary == ex.primary && availableGear.contains($0.gear) && Set($0.loads).isDisjoint(with: joints) }
            .sorted { ($0.gear != ex.gear ? 0 : 1, $0.name) < ($1.gear != ex.gear ? 0 : 1, $1.name) }
    }

    func startingWeight(_ ex: Exercise) -> Double {
        if ex.bodyweightOnly { return 0 }
        var w = ex.weightKg * data.profile.level.factor
        if data.profile.sex == .female { w *= 0.7 }
        if data.profile.place == .home && ex.gear == .dumbbell { w = min(w, 20) }
        return Self.round(w, ex)
    }
    static func round(_ w: Double, _ ex: Exercise) -> Double {
        let step = ex.gear == .dumbbell ? 1.0 : 2.5
        let minW = ex.gear == .barbell ? 20.0 : 0
        return max(minW, (w / step).rounded() * step)
    }

    var plan: PlannedWorkout { buildPlan() }

    func buildPlan(now: Date = Date()) -> PlannedWorkout {
        let p = data.profile
        let t = templates[data.history.count % templates.count]
        var reasons: [String] = []
        let maxCount: Int = {
            var n = p.minutes <= 30 ? 4 : (p.minutes <= 45 ? 5 : (p.minutes <= 60 ? 6 : 7))
            if data.gentle { n = min(n, 5) }
            return n
        }()
        var used = Set<String>()
        var items: [WorkoutItem] = []
        for m in t.2 where items.count < maxCount {
            let candidates = Catalog.all.filter { $0.primary == m && availableGear.contains($0.gear) && !used.contains($0.id) }
            // người mới ưu tiên máy/tạ đơn; người có kinh nghiệm ưu tiên bài nhiều khớp
            let sorted = candidates.sorted { a, b in
                func score(_ e: Exercise) -> Int {
                    var s = e.compound ? 2 : 0
                    if ["goodmorning", "kneelsquat", "thruster", "frontraise", "wristcurl"].contains(e.id) { s -= 3 }
                    if p.place != .home && e.bodyweightOnly { s -= 4 }
                    if p.level == .new && (e.gear == .machine || e.gear == .dumbbell || e.gear == .smith) { s += 3 }
                    if p.level != .new && e.gear == .barbell { s += 2 }
                    return s
                }
                return score(a) == score(b) ? a.id < b.id : score(a) > score(b)
            }
            guard var ex = sorted.first else { continue }
            var hops = 0
            while hops < 5, let swapID = data.swaps[ex.id], let s = Catalog.byID[swapID] { ex = s; hops += 1 }
            if data.removed.contains(ex.id) { used.insert(ex.id); continue }
            used.insert(ex.id)
            items.append(makeItem(ex))
        }
        for id in data.added where !used.contains(id) {
            if let ex = Catalog.byID[id] { items.append(makeItem(ex)); used.insert(id) }
        }

        // lý do một dòng
        let progressed = items.filter { $0.change == "Tăng tạ" }.count
        let readyMuscles = Set(t.2).filter { readiness($0, now: now) >= 0.8 }.map(\.name)
        if !readyMuscles.isEmpty && !data.history.isEmpty { reasons.append(readyMuscles.prefix(2).joined(separator: ", ") + " đã hồi phục") }
        if progressed > 0 { reasons.append("tăng tạ \(progressed) bài vì lần trước đủ rep") }
        else if !data.history.isEmpty { reasons.append("giữ mức tạ") }
        else if p.recent == .returning { reasons.append("bạn đang quay lại nên tạ bắt đầu nhẹ hơn 15%") }
        else { reasons.append("tạ khởi điểm theo kinh nghiệm của bạn") }

        // Quay lại sau thời gian nghỉ
        let since = data.history.filter { $0.started < now }.map(\.started).max().flatMap {
            Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: $0), to: Calendar.current.startOfDay(for: now)).day
        }
        if let d = since, d >= 14 {
            for i in items.indices { scale(&items[i], 0.8) }
            reasons = ["Bạn nghỉ \(d) ngày: tạ giảm 20%, sẽ tăng dần lại"]
        }
        if data.gentle { reasons.append("chế độ nhẹ nhàng") }

        // Check-in hôm nay
        var result = PlannedWorkout(name: t.0, focus: t.1, reasons: reasons, items: items)
        applyCheckIn(&result)
        return result
    }

    private func makeItem(_ ex: Exercise) -> WorkoutItem {
        let p = data.profile
        var reps = ex.reps
        if p.level == .new { reps = max(reps, 10) }
        if p.goal == .strength && ex.compound { reps = min(reps, 6) }
        var sets = data.gentle ? 2 : ex.sets
        if p.level == .new { sets = min(sets, 3) }
        var w = startingWeight(ex)
        var change: String? = nil
        if let last = lastItem(for: ex.id) {
            let done = last.sets.filter(\.done)
            let top = done.map(\.weightKg).max() ?? w
            let hitAll = !done.isEmpty && done.allSatisfy { $0.reps >= last.targetReps }
            w = top
            if hitAll && !ex.bodyweightOnly {
                w = top + (ex.gear == .dumbbell ? 1 : 2.5)
                change = "Tăng tạ"
            }
            reps = last.targetReps
        }
        if data.gentle && ex.isBarbell { w = AppState.round(w * 0.8, ex) }
        if data.history.isEmpty && p.recent == .returning && !ex.bodyweightOnly { w = AppState.round(w * 0.85, ex) }
        let set = LoggedSet(weightKg: w, reps: reps)
        return WorkoutItem(exerciseID: ex.id, sets: Array(repeating: set, count: sets).map { var s = $0; s.id = UUID(); return s }, targetReps: reps, change: change)
    }

    private func scale(_ item: inout WorkoutItem, _ f: Double) {
        let ex = item.exercise
        guard !ex.bodyweightOnly else { return }
        for j in item.sets.indices { item.sets[j].weightKg = AppState.round(item.sets[j].weightKg * f, ex) }
    }

    func applyCheckIn(_ w: inout PlannedWorkout) {
        switch data.checkIn {
        case .fine: break
        case .tired:
            for i in w.items.indices {
                if w.items[i].sets.count > 2 { w.items[i].sets.removeLast() }
                scale(&w.items[i], 0.9)
                w.items[i].change = "Bớt 1 set, giảm 10% tạ"
            }
            w.reasons = ["Hơi mệt: bớt 1 set mỗi bài, tạ giảm 10%"]
        case .pain(let joints):
            var swapped = 0
            for i in w.items.indices {
                let ex = w.items[i].exercise
                guard !Set(ex.loads).isDisjoint(with: joints) else { continue }
                if let alt = alternatives(for: ex, avoiding: joints).first {
                    var item = makeItem(alt)
                    item.change = "Đổi từ \(ex.name.lowercased()) để tránh \(joints.map { $0.name.lowercased() }.joined(separator: ", "))"
                    w.items[i] = item
                } else {
                    scale(&w.items[i], 0.7)
                    w.items[i].change = "Giảm 30% tạ, dừng nếu đau tăng"
                }
                swapped += 1
            }
            w.reasons = [swapped == 0 ? "Không bài nào dồn lực vào chỗ đau" : "Đã đổi hoặc giảm \(swapped) bài để tránh chỗ đau"]
        case .short(let minutes):
            var trimmed = 0
            while w.minutes > minutes && w.items.count > 2 { w.items.removeLast(); trimmed += 1 }
            while w.minutes > minutes, let i = w.items.firstIndex(where: { $0.sets.count > 2 }) {
                w.items[i].sets.removeLast(); w.items[i].change = "Bớt 1 set"
            }
            w.reasons = ["Gói gọn trong \(minutes) phút" + (trimmed > 0 ? ", bỏ \(trimmed) bài cuối" : "")]
        }
    }

    // MARK: Buổi tập đang diễn ra

    func start(_ p: PlannedWorkout) {
        active = ActiveWorkout(name: p.name, items: p.items)
    }

    func finish() -> Session? {
        guard let a = active else { return nil }
        var items = a.items
        for i in items.indices { items[i].change = nil }
        items = items.filter { $0.sets.contains(where: \.done) }
        guard !items.isEmpty else { active = nil; return nil }
        let s = Session(name: a.name, started: a.started, seconds: Int(Date().timeIntervalSince(a.started)), items: items)
        data.history.append(s)
        data.checkIn = .fine; data.checkInDate = nil
        data.swaps = [:]; data.removed = []; data.added = []
        active = nil
        return s
    }

    /// Kỷ lục mới trong buổi so với trước buổi.
    func records(in s: Session) -> [(Exercise, Double, Double)] {
        s.items.compactMap { it in
            let ex = it.exercise
            guard !ex.bodyweightOnly else { return nil }
            let now = it.sets.filter(\.done).map { AppState.e1rm($0.weightKg, $0.reps) }.max() ?? 0
            let before = bestE1RM(it.exerciseID, before: s.started)
            return now > before && before > 0 ? (ex, now, before) : nil
        }
    }

    // MARK: Dữ liệu mẫu

    func loadDemo() {
        var p = data.profile
        p.name = p.name.isEmpty ? "Minh" : p.name
        data.profile = p
        data.onboarded = true
        data.sawPro = true
        data.history = []
        let cal = Calendar.current
        let offsets = [26, 24, 21, 19, 17, 14, 12, 10, 7, 5, 3, 1]
        for (n, off) in offsets.enumerated() {
            guard let day = cal.date(byAdding: .day, value: -off, to: Date()),
                  let start = cal.date(bySettingHour: 18, minute: 10 + n, second: 0, of: day) else { continue }
            var plan = buildPlan(now: start)
            plan.items = plan.items.map { item in
                var it = item
                for j in it.sets.indices { it.sets[j].done = true; it.sets[j].change(reps: n % 3 == 2 ? -1 : 0) }
                it.change = nil
                return it
            }
            data.history.append(Session(name: plan.name, started: start, seconds: 2700 + n * 37, items: plan.items))
        }
    }
}

private extension LoggedSet {
    mutating func change(reps delta: Int) { reps = max(1, reps + delta) }
}

extension Calendar {
    /// Tuần bắt đầu từ thứ Hai.
    static var vn: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "vi_VN")
        c.firstWeekday = 2
        return c
    }
}
