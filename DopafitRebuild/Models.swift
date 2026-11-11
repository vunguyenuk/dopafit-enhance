import Foundation
import Combine

enum AppTab: Int, CaseIterable { case workout, body, goals, journal }
struct LoggedSet: Identifiable, Codable, Equatable {
    var id = UUID()
    var reps: Int = 6
    var weight: Double = 42.5
    var completed = false
    var warmup = false
    var seconds: Int = 0
    var volume: Double { completed && !warmup ? Double(reps) * weight : 0 }
    var estimatedMax: Double {
        guard completed, !warmup, reps > 0, weight > 0 else { return 0 }
        if reps == 1 { return weight }
        return (weight * (1 + Double(min(reps,30)) / 30) * 2).rounded() / 2
    }
}
struct Exercise: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var english: String
    var equipment: String
    var muscles: [String]
    var secondary: [String]
    var image: String
    var imageRect: [Double]
    var instructions: [String]
    var defaultSets: Int = 3
    var defaultReps: Int = 6
    var defaultWeight: Double = 20
    var convention: String = ""
    var timed: Bool = false
    var volumeMultiplier: Double? = nil
    var repsConvention: String? = nil
}
struct WorkoutExercise: Identifiable, Codable, Equatable {
    var id = UUID()
    var exercise: Exercise
    var sets: [LoggedSet]
    var rir: Int? = nil
    var restSeconds: Int = 0
    var warmupRestSeconds: Int? = nil
    var notes = ""
    var supersetID: UUID? = nil
    var doneCount: Int { sets.filter(\.completed).count }
    var volume: Double { exercise.timed ? 0:sets.reduce(0) { $0 + $1.volume } * (exercise.volumeMultiplier ?? 1) }
    init(_ exercise: Exercise) {
        self.exercise = exercise
        self.sets = (0..<exercise.defaultSets).map { _ in LoggedSet(reps: exercise.defaultReps, weight: exercise.defaultWeight) }
    }
}
struct WorkoutSession: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var started: Date = Date()
    var finished: Date? = nil
    var duration: TimeInterval = 0
    var hasStarted = false
    var plannedMinutes: Int = 60
    var exercises: [WorkoutExercise]
    /// Số ngày nghỉ trước buổi này nếu app đã hạ tạ vì nghỉ lâu (≥14 ngày).
    var returnBreakDays: Int? = nil
    /// 1 hoặc 2 khi đang trong 2 tuần tăng dần sau nghỉ dài.
    var returnWeek: Int? = nil
    var volume: Double { exercises.reduce(0) { $0 + $1.volume } }
    var completedSets: Int { exercises.reduce(0) { $0 + $1.doneCount } }
    var completedExercises: [WorkoutExercise] { exercises.filter { $0.doneCount > 0 } }
    var calories: Int { Int(duration / 60 * 6) }
    var elapsed: TimeInterval { finished == nil ? Date().timeIntervalSince(started) : duration }
}
struct GymProfile: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var locationType: String? = nil
    var equipment: [String] = Catalog.equipment
    var dumbbells: [Double] = [2.5,5,7.5,10,12.5,15,17.5,20,22.5,25,27.5,30,32.5,35,40,45,50]
    var plates: [Double] = [1.25,2.5,5,10,15,20,25]
    var barWeight: Double = 20
}
struct PlanSettings: Codable {
    var goal = "Khỏe hơn"
    var experience = "Trung bình"
    var days = 3
    var minutes = 60
    var split = "Thân trên / Thân dưới"
    var variability = "Cân bằng"
    var focus: [String] = []
    var unit = "kg"
    var language = "Theo ngôn ngữ của máy"
    var warmup = false
    var supersets = false
    var timedTraining = false
    /// Chế độ nhẹ nhàng (lớn tuổi, ít sức, mới ốm dậy): ít bài, 2 set, ưu tiên máy/tạ đơn, nghỉ lâu hơn. Optional để snapshot cũ đọc được.
    var gentle: Bool? = nil
    /// "Vừa" / "Lớn" / "Rất lớn" — cỡ chữ toàn app. Optional để snapshot cũ đọc được.
    var textSize: String? = nil
    var sound = true
    var gender = "Nam"
    var height: Double = 169
    var bodyWeight: Double = 70
    var birthDate: Date? = nil
    var ageGroup: String? = nil
    var trainingDays: [Int]? = nil
    var equipmentPreference: String? = nil
    var otherActivity: String? = nil
    var notificationDays: [Int] = []
    var reminderHour = 18
}
struct SavedWorkout: Identifiable, Codable {
    var id = UUID()
    var name: String
    var exercises: [WorkoutExercise]
}
struct RecoveryAdjustment:Codable {
    var date:Date
    var values:[String:Double]
}
struct AppSnapshot: Codable {
    var schema = 1
    var onboarded = false
    var plan = PlanSettings()
    var gyms = [GymProfile(name: "Phòng gym")]
    var gymID: UUID? = nil
    var history: [WorkoutSession] = []
    var draft: WorkoutSession? = nil
    var saved: [SavedWorkout] = []
    var preferences: [String:Int] = [:]
    var lowerNext = false
    var onboardingAnswers: [String:[String]]? = nil
    var dismissedTips: [String]? = nil
    var recoveryAdjustment:RecoveryAdjustment? = nil
    var challenges:[ChallengeEnrollment]? = nil
    var challengePractices:[ChallengePractice]? = nil
    var checkin:DailyCheckin? = nil
    /// Ngày bắt đầu quay lại sau nghỉ dài; tạ tăng dần trong 2 tuần kể từ đây.
    var returnStart:Date? = nil
}
@MainActor final class AppStore: ObservableObject {
    @Published var data: AppSnapshot
    @Published var tab: AppTab = .workout
    @Published var showingActive = false
    @Published var timerEnd: Date? = nil
    @Published var pausedRest: Int? = nil
    @Published var timerExercise: UUID? = nil
    @Published var lastSaved: WorkoutSession? = nil
    @Published var toast: String? = nil
    let storageURL: URL
    init(storageURL: URL? = nil) {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("DopafitRebuild")
        self.storageURL = storageURL ?? dir.appendingPathComponent("state.json")
        if let content = try? Data(contentsOf: self.storageURL), let saved = try? JSONDecoder().decode(AppSnapshot.self, from: content) {
            data = saved
        } else { data = AppSnapshot() }
        func current(_ ex:WorkoutExercise)->WorkoutExercise {
            var result=ex
            if let definition=Catalog.all.first(where:{$0.id==ex.exercise.id}){result.exercise=definition}
            return result
        }
        if data.draft != nil{data.draft!.exercises=data.draft!.exercises.map(current)}
        for i in data.history.indices{data.history[i].exercises=data.history[i].exercises.map(current)}
        for i in data.saved.indices{data.saved[i].exercises=data.saved[i].exercises.map(current)}
        if ProcessInfo.processInfo.arguments.contains("--demo") { data.onboarded = true }
        if ProcessInfo.processInfo.arguments.contains("--audit-setup") || ProcessInfo.processInfo.arguments.contains("--audit-post-setup") { data.onboarded = false }
        if data.draft == nil { makeDraft() }
    }
    var english: Bool { data.plan.language == "English" }
    func t(_ vi: String, _ en: String) -> String { english ? en : vi }
    var unit: String { data.plan.unit }
    func displayWeight(_ kg: Double) -> Double { unit == "lb" ? kg * 2.2046226218 : kg }
    func kilograms(_ value: Double) -> Double { unit == "lb" ? value / 2.2046226218 : value }
    func weight(_ kg: Double) -> String { Self.number(displayWeight(kg)) }
    static func number(_ value: Double) -> String {
        if value.rounded() == value { return String(Int(value)) }
        return String(format: "%.1f", value)
    }
    var currentGym: GymProfile { data.gyms.first { $0.id == data.gymID } ?? data.gyms[0] }
    func persist() {
        do {
            try FileManager.default.createDirectory(at: storageURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let payload = try JSONEncoder().encode(data)
            try payload.write(to: storageURL, options: .atomic)
        } catch { toast = "Không thể lưu dữ liệu: \(error.localizedDescription)" }
    }
    func changePlan(_ change: (inout PlanSettings)->Void) { change(&data.plan); persist() }
    func makeDraft(lower: Bool? = nil) {
        let lower = lower ?? data.lowerNext
        data.lowerNext=lower
        let profile=currentGym
        let allowed:Set<String>=Set(profile.equipment)
        var definitions=lower ? Catalog.lower:(data.plan.experience=="Mới bắt đầu" ? Catalog.beginnerUpper:Catalog.upper)
        if data.plan.split=="Toàn thân" {definitions=[Catalog.lower[1],Catalog.upper[1],Catalog.upper[0],Catalog.lower[2],Catalog.upper[4],Catalog.upper[5]]}
        definitions=definitions.filter{data.preferences[$0.id] != -2}
        definitions=definitions.filter{!$0.muscles.contains{manualRecovery($0)==0}}
        // Bài thiếu dụng cụ ở nơi tập hoặc không có video: thay bằng bài cùng cơ chính dùng được, không có thì bỏ.
        let gentle=data.plan.gentle==true
        let heavyGear:Set<String>=["Tạ đòn","Trap Bar","T-Bar Row"]
        let usable:(Exercise)->Bool={CheckinLogic.hasVideo($0) && allowed.contains($0.equipment) && !(gentle && heavyGear.contains($0.equipment))}
        var usedIDs=Set(definitions.filter(usable).map(\.id))
        definitions=definitions.compactMap{definition in
            if usable(definition) {return definition}
            let primary=definition.muscles.first ?? ""
            guard let pick=Catalog.all.first(where:{ex in !usedIDs.contains(ex.id) && ex.muscles.first==primary && usable(ex) && data.preferences[ex.id] != -2}) else{return nil}
            usedIDs.insert(pick.id);return pick
        }
        if data.recoveryAdjustment.map({Calendar.current.isDateInToday($0.date)}) == true {
            definitions=definitions.enumerated().sorted {a,b in
                let ar=a.element.muscles.compactMap{manualRecovery($0)}.min() ?? 100
                let br=b.element.muscles.compactMap{manualRecovery($0)}.min() ?? 100
                return ar==br ? a.offset<b.offset:ar>br
            }.map(\.element)
        }
        if !data.plan.focus.isEmpty {
            definitions=definitions.enumerated().sorted{a,b in
                let af=a.element.muscles.contains{data.plan.focus.contains($0)}
                let bf=b.element.muscles.contains{data.plan.focus.contains($0)}
                return af==bf ? a.offset<b.offset:af
            }.map(\.element)
        }
        let limit=gentle ? min(5,max(2,data.plan.minutes/10)):min(7,max(2,data.plan.minutes/8))
        definitions=Array(definitions.prefix(limit))
        let planned=definitions.map{definition -> WorkoutExercise in
            var ex=WorkoutExercise(definition)
            guard let previous=exerciseHistory(definition.id).first?.1 else{return ex}
            let work=previous.sets.filter{!$0.warmup && $0.completed}
            guard let last=work.last else{return ex}
            var load=last.weight
            var reps=last.reps
            // Local, inspectable replacement rule; it is not the proprietary Dopafit algorithm.
            if work.count>=definition.defaultSets && work.allSatisfy({$0.reps>=definition.defaultReps}) && (previous.rir ?? 2)>=2 {
                if definition.equipment=="Cặp tạ đơn" {
                    if let next=profile.dumbbells.sorted().first(where:{$0>load+0.01}){load=next;reps=definition.defaultReps}
                    else{reps+=1}
                } else if ["Tạ đòn","Trap Bar","T-Bar Row"].contains(definition.equipment) {
                    load += (profile.plates.min() ?? 1.25)*2;reps=definition.defaultReps
                } else if load>0{load+=2.5;reps=definition.defaultReps}
            }
            for i in ex.sets.indices{ex.sets[i].weight=load;ex.sets[i].reps=reps}
            ex.restSeconds=previous.restSeconds
            return ex
        }
        // Nghỉ từ 14 ngày: hạ còn khoảng 75% thay vì tăng tạ (luật cục bộ, xem DailyCheckinModels.swift).
        let breakDays=CheckinLogic.breakDays(history:data.history)
        var eased=breakDays==nil ? planned:planned.map{CheckinLogic.scaled($0,factor:CheckinLogic.breakFactor,profile:profile)}
        var returnWeek:Int?=nil
        if breakDays != nil {data.returnStart=Date();returnWeek=1}
        else if let start=data.returnStart {
            let days=Calendar.current.dateComponents([.day],from:Calendar.current.startOfDay(for:start),to:Calendar.current.startOfDay(for:Date())).day ?? 99
            if days>=14 {data.returnStart=nil}
            else {
                // Tuần 1 sau khi quay lại giữ ít nhất ~75%, tuần 2 ~85% mức trước khi nghỉ; không vượt mức cũ. Tuần 3 theo luật tăng tạ thường.
                let factor=days<7 ? 0.75:0.85
                returnWeek=days<7 ? 1:2
                eased=planned.map{item in
                    let peak=exerciseHistory(item.exercise.id).first{$0.0.started<start}?.1.sets.filter{!$0.warmup && $0.completed}.map(\.weight).max() ?? 0
                    return CheckinLogic.ramped(item,peak:peak,factor:factor,profile:profile)
                }
            }
        }
        if gentle {
            eased=eased.map{item in
                var item=item
                let working=item.sets.indices.filter{!item.sets[$0].warmup}
                if working.count>2 {item.sets.removeSubrange(working[2]...(working.last ?? working[2]))}
                item.restSeconds=max(item.restSeconds,120)
                return item
            }
        }
        data.draft=WorkoutSession(name:lower ? "Ngày thân dưới":"Ngày thân trên",exercises:eased)
        data.draft?.returnBreakDays=breakDays
        data.draft?.returnWeek=returnWeek
        data.draft?.plannedMinutes = data.plan.minutes
        if data.plan.warmup {
            for i in data.draft!.exercises.indices {
                let first = data.draft!.exercises[i].sets[0]
                data.draft!.exercises[i].sets.insert(LoggedSet(reps:10,weight:(first.weight*0.5*2).rounded()/2,warmup:true),at:0)
            }
        }
        persist()
    }
    func start() {
        if data.draft == nil { makeDraft() }
        if data.draft?.hasStarted == false { data.draft?.started = Date(); data.draft?.hasStarted = true }
        persist(); showingActive = true
    }
    /// Explicit discard affects only the unsaved draft. Original post-discard
    /// plan generation remains unobserved; this uses the local plan generator.
    func discardWorkout() {
        timerEnd=nil;pausedRest=nil;timerExercise=nil;showingActive=false
        data.draft=nil;makeDraft();persist()
    }
    func mutateExercise(_ id: UUID, _ change: (inout WorkoutExercise)->Void) {
        guard let i = data.draft?.exercises.firstIndex(where: {$0.id == id}) else { return }
        change(&data.draft!.exercises[i]); persist()
    }
    func logSet(exercise id: UUID, set setID: UUID, toggle: Bool = false) {
        mutateExercise(id) { ex in
            guard let i = ex.sets.firstIndex(where: {$0.id == setID}) else { return }
            guard ex.exercise.canLog(ex.sets[i]) else{return}
            ex.sets[i].completed = toggle ? !ex.sets[i].completed : true
            let rest=ex.sets[i].warmup ? (ex.warmupRestSeconds ?? ex.restSeconds):ex.restSeconds
            if ex.sets[i].completed && rest > 0 {
                timerEnd = Date().addingTimeInterval(Double(rest)); pausedRest = nil; timerExercise = id
            }
        }
    }
    func logAll(_ id: UUID) {
        mutateExercise(id) { ex in
            for i in ex.sets.indices where ex.exercise.canLog(ex.sets[i]) { ex.sets[i].completed = true }
        }
    }
    func swap(_ id: UUID, for replacement: Exercise) {
        mutateExercise(id) { ex in ex = WorkoutExercise(replacement) }
    }
    func removeExercise(_ id: UUID) {
        guard var draft=data.draft else{return}
        draft.exercises.removeAll{$0.id==id}
        let counts=Dictionary(grouping:draft.exercises.compactMap(\.supersetID),by:{$0}).mapValues(\.count)
        for i in draft.exercises.indices{if let group=draft.exercises[i].supersetID,counts[group,default:0]<2{draft.exercises[i].supersetID=nil}}
        data.draft=draft;persist()
    }
    func addExercise(_ ex: Exercise) { data.draft?.exercises.append(WorkoutExercise(ex)); persist() }
    /// Session-only grouping. R77 groups nonadjacent items1/3 as the first pair.
    /// Anchor other selections at their earliest slot (local rule until audited);
    /// never change the global plan toggle. Circuit execution remains separate.
    @discardableResult func groupDraftExercises(_ selected:Set<UUID>)->Bool {
        guard var draft=data.draft else{return false}
        let available=Set(draft.exercises.map(\.id))
        guard selected.count>=2,selected.isSubset(of:available) else{return false}
        let group=UUID()
        for i in draft.exercises.indices where selected.contains(draft.exercises[i].id){draft.exercises[i].supersetID=group}
        let counts=Dictionary(grouping:draft.exercises.compactMap(\.supersetID),by:{$0}).mapValues(\.count)
        for i in draft.exercises.indices {
            if let id=draft.exercises[i].supersetID,counts[id,default:0]<2{draft.exercises[i].supersetID=nil}
        }
        let first=draft.exercises.firstIndex{selected.contains($0.id)}!
        let members=draft.exercises.filter{selected.contains($0.id)}
        var remaining=draft.exercises.filter{!selected.contains($0.id)}
        remaining.insert(contentsOf:members,at:first)
        draft.exercises=remaining
        data.draft=draft;persist();return true
    }
    @discardableResult func detachDraftGroup(_ group:UUID)->Bool {
        guard var draft=data.draft,draft.exercises.contains(where:{$0.supersetID==group}) else{return false}
        for i in draft.exercises.indices where draft.exercises[i].supersetID==group{draft.exercises[i].supersetID=nil}
        data.draft=draft;persist();return true
    }
    /// R78 exposes duplicate-group; reset new identifiers/completion while
    /// preserving prescription. Placement/reset semantics remain local until
    /// the original duplicate action has been audited.
    @discardableResult func duplicateDraftGroup(_ group:UUID)->UUID? {
        guard var draft=data.draft,let last=draft.exercises.lastIndex(where:{$0.supersetID==group}) else{return nil}
        let members=draft.exercises.filter{$0.supersetID==group};guard members.count>=2 else{return nil}
        let newGroup=UUID()
        let copies=members.map{item in
            var copy=item;copy.id=UUID();copy.supersetID=newGroup;copy.rir=nil
            copy.sets=copy.sets.map{set in var s=set;s.id=UUID();s.completed=false;return s};return copy
        }
        draft.exercises.insert(contentsOf:copies,at:last+1);data.draft=draft;persist();return newGroup
    }
    @discardableResult func logDraftGroup(_ group:UUID)->Bool {
        let members=data.draft?.exercises.filter{$0.supersetID==group} ?? []
        guard members.count>=2 else{return false}
        for item in members{logAll(item.id)}
        return true
    }
    func finish() -> WorkoutSession? {
        guard var s = data.draft, s.completedSets > 0 else { return nil }
        s.finished = Date(); s.duration = max(1,Date().timeIntervalSince(s.started))
        s.exercises = s.completedExercises.map { ex in var copy = ex; copy.sets = ex.sets.filter(\.completed); return copy }
        if !data.history.contains(where: {$0.id == s.id}) { data.history.insert(s, at: 0) }
        lastSaved = s
        data.lowerNext.toggle(); timerEnd = nil; pausedRest = nil; timerExercise = nil
        showingActive = false; makeDraft(); tab = .journal; persist()
        return s
    }
    func exerciseHistory(_ id: String) -> [(WorkoutSession, WorkoutExercise)] {
        data.history.flatMap { s in s.exercises.filter { $0.exercise.id == id }.map { (s,$0) } }
    }
    var weekHistory: [WorkoutSession] {
        data.history.filter { Calendar.current.isDate($0.started, equalTo: Date(), toGranularity: .weekOfYear) }
    }
    var weekDays: Int { Set(weekHistory.map { Calendar.current.startOfDay(for: $0.started) }).count }
    func muscleSets(_ muscle: String, recentOnly: Bool = true) -> Double {
        (recentOnly ? weekHistory : data.history).flatMap(\.exercises).reduce(0) { total, ex in
            let count = Double(ex.sets.filter { $0.completed && !$0.warmup }.count)
            return total + (ex.exercise.muscles.contains(muscle) ? count : 0) + (ex.exercise.secondary.contains(muscle) ? count * 0.5 : 0)
        }
    }
    func muscleRecovery(_ muscle: String) -> Double {
        if let manual=manualRecovery(muscle){return manual}
        let sessions = data.history.filter { Date().timeIntervalSince($0.started) < 72*3600 }
        let fatigue = sessions.reduce(0.0) { total, session in
            let age = max(0,Date().timeIntervalSince(session.started))
            let recovery = max(0,1-age/(72*3600))
            return total + session.exercises.reduce(0.0) { value, ex in
                let factor = ex.exercise.muscles.contains(muscle) ? 1.0 : (ex.exercise.secondary.contains(muscle) ? 0.5 : 0)
                return value + Double(ex.doneCount)*factor*12*recovery
            }
        }
        return max(0,100-fatigue)
    }
    func manualRecovery(_ muscle:String)->Double? {
        guard let adjustment=data.recoveryAdjustment,Calendar.current.isDateInToday(adjustment.date) else{return nil}
        return adjustment.values[muscle]
    }
    func adjustRecovery(_ values:[String:Double]) {
        let valid=values.filter{$0.value.isFinite}.mapValues{min(100,max(0,$0))}
        data.recoveryAdjustment=RecoveryAdjustment(date:Date(),values:valid);persist()
        if data.draft?.hasStarted != true && (data.draft?.completedSets ?? 0)==0{makeDraft()}
    }
    @discardableResult func updateSavedDuration(sessionID:UUID,hours:Int,minutes:Int)->Bool {
        guard hours>=0,hours<=23,minutes>=0,minutes<60,hours*60+minutes>0,
              let index=data.history.firstIndex(where:{$0.id==sessionID}) else{return false}
        data.history[index].duration=Double(hours*3600+minutes*60);persist();return true
    }
    func setPreference(_ id: String, _ value: Int) { data.preferences[id] = value; persist() }
    func renameGym(_ id:UUID,to name:String) {
        let trimmed=name.trimmingCharacters(in:.whitespacesAndNewlines)
        guard !trimmed.isEmpty,let index=data.gyms.firstIndex(where:{$0.id==id}) else{return}
        data.gyms[index].name=trimmed;persist()
    }
    @discardableResult func removeGym(_ id:UUID)->Bool {
        guard data.gyms.count>1,data.gyms.contains(where:{$0.id==id}) else{return false}
        data.gyms.removeAll{$0.id==id}
        if data.gymID==id {data.gymID=data.gyms.first?.id}
        persist();return true
    }
    func updateSavedRIR(sessionID:UUID,exerciseID:UUID,value:Int?) {
        guard let session=data.history.firstIndex(where:{$0.id==sessionID}),let exercise=data.history[session].exercises.firstIndex(where:{$0.id==exerciseID}) else{return}
        data.history[session].exercises[exercise].rir=value.map{min(4,max(0,$0))}
        persist()
    }
    func saveTemplate(name: String? = nil) {
        guard let draft = data.draft else { return }
        data.saved.append(SavedWorkout(name: name ?? draft.name, exercises: draft.exercises)); persist()
    }
    func loadTemplate(_ id:UUID) {
        guard let saved=data.saved.first(where:{$0.id==id}) else{return}
        var groups:[UUID:UUID]=[:]
        let exercises=saved.exercises.map { source -> WorkoutExercise in
            var ex=source;ex.id=UUID();ex.rir=nil
            ex.sets=source.sets.map{source in var set=source;set.id=UUID();set.completed=false;return set}
            if let group=source.supersetID {if groups[group]==nil{groups[group]=UUID()};ex.supersetID=groups[group]}
            return ex
        }
        data.draft=WorkoutSession(name:saved.name,plannedMinutes:data.plan.minutes,exercises:exercises)
        timerEnd=nil;pausedRest=nil;timerExercise=nil;persist()
    }
    @discardableResult func saveHistoryExercise(sessionID:UUID,item:WorkoutExercise)->Bool {
        guard let i=data.history.firstIndex(where:{$0.id==sessionID}),!item.sets.isEmpty,
              item.sets.allSatisfy({item.exercise.canLog($0)}) else{return false}
        var copy=item
        for index in copy.sets.indices {copy.sets[index].completed=true}
        if let j=data.history[i].exercises.firstIndex(where:{$0.id==item.id}) {data.history[i].exercises[j]=copy}
        else {data.history[i].exercises.append(copy)}
        persist();return true
    }
    func removeHistoryExercise(sessionID:UUID,exerciseID:UUID) {
        guard let i=data.history.firstIndex(where:{$0.id==sessionID}) else{return}
        data.history[i].exercises.removeAll{$0.id==exerciseID};persist()
    }
    func dismissTip(_ id:String) {if data.dismissedTips?.contains(id) != true{data.dismissedTips=(data.dismissedTips ?? [])+[id];persist()}}
    func exercises(query:String="",gear:String="Tất cả",sort:String="Hợp nhất",replacing:Exercise?=nil)->[Exercise] {
        // Bài chưa có video đúng động tác thì ẩn khỏi danh sách chọn (theo yêu cầu user 11/11). Lịch sử và buổi đang có không bị ảnh hưởng.
        let list=Catalog.all.filter { ex in
            CheckinLogic.hasVideo(ex) && (query.isEmpty || ex.name.localizedCaseInsensitiveContains(query) || ex.english.localizedCaseInsensitiveContains(query)) && (gear=="Tất cả" || ex.equipment==gear)
        }
        func count(_ ex:Exercise)->Int {exerciseHistory(ex.id).reduce(0){$0+$1.1.doneCount}}
        func score(_ ex:Exercise)->Int {
            let preference=(data.preferences[ex.id] ?? 0)*20
            let muscle=replacing.map{Set($0.muscles).intersection(ex.muscles).count*10} ?? 0
            return preference+muscle+(currentGym.equipment.contains(ex.equipment) ? 5:0)
        }
        if sort=="Chưa tập" {return list.filter{count($0)==0}}
        return list.sorted { a,b in
            switch sort {
            case "Tên bài tập":return a.name.localizedStandardCompare(b.name) == .orderedAscending
            case "Tập nhiều nhất":if count(a) != count(b){return count(a)>count(b)}
            case "Tập ít nhất":if count(a) != count(b){return count(a)<count(b)}
            default:if score(a) != score(b){return score(a)>score(b)}
            }
            return a.name.localizedStandardCompare(b.name) == .orderedAscending
        }
    }
    func csvData() -> String {
        let formatter=ISO8601DateFormatter()
        func esc(_ s:String)->String { "\"" + s.replacingOccurrences(of:"\"",with:"\"\"") + "\"" }
        var lines=["session_id,date,workout,exercise,set,reps,weight_kg,warmup,rir,volume_multiplier,volume_kg,duration_seconds"]
        for s in data.history {
            for ex in s.exercises {
                for (i,set) in ex.sets.enumerated() {
                    lines.append([s.id.uuidString,formatter.string(from:s.started),esc(s.name),esc(ex.exercise.name),String(i+1),String(set.reps),String(set.weight),String(set.warmup),ex.rir.map(String.init) ?? "",String(ex.exercise.volumeMultiplier ?? 1),String(ex.exercise.timed ? 0:set.volume*(ex.exercise.volumeMultiplier ?? 1)),String(set.seconds)].joined(separator:","))
                }
            }
        }
        return lines.joined(separator:"\n")
    }
}
enum Catalog {
    static let equipment = ["Tạ đòn","Bánh tạ","Cặp tạ đơn","Ghế tập","Ghế dốc","Cáp","Máy tập","Dây kháng lực","Xà đơn","Tạ chuông","Trap Bar","T-Bar Row","Trọng lượng cơ thể"]
    static let muscleNames=["Ngực","Vai","Tay sau","Lưng","Tay trước","Bụng","Đùi trước","Đùi sau","Mông","Bắp chân"]
    static let recoveryMuscles=["Bụng","Mông","Đùi sau","Đùi trước","Lưng dưới","Ngực","Tay sau","Tay trước","Vai","Lưng"]
    static let recoverySecondaryMuscles=["Bắp chân","Cơ thang","Cơ dạng hông","Cơ khép hông","Cẳng tay","Cổ"]
    static func ex(_ id:String,_ name:String,_ en:String,_ gear:String,_ muscles:[String],_ secondary:[String],_ image:String,_ rect:[Double],_ sets:Int,_ reps:Int,_ weight:Double,_ convention:String="") -> Exercise {
        Exercise(id:id,name:name,english:en,equipment:gear,muscles:muscles,secondary:secondary,image:image,imageRect:rect,instructions:["Chuẩn bị tư thế vững chắc và điều chỉnh dụng cụ phù hợp.","Thực hiện động tác chậm, có kiểm soát theo hướng dẫn minh họa.","Giữ thân người ổn định, thở đều và trở về vị trí bắt đầu."],defaultSets:sets,defaultReps:reps,defaultWeight:weight,convention:convention)
    }
    static let upper:[Exercise] = [
        ex("tbar","Kéo lưng với thanh chữ T","T-Bar Row","T-Bar Row",["Lưng"],["Tay trước"],"reference-upper",[47,330,174,155],3,6,42.5),
        ex("incline","Đẩy ngực với tạ đòn trên ghế dốc lên","Incline Barbell Bench Press","Tạ đòn",["Ngực"],["Vai","Tay sau"],"reference-upper",[47,508,174,155],3,6,42.5,"Gồm thanh đòn"),
        ex("facepull","Kéo cáp về mặt","Cable Face Pull","Cáp",["Vai"],["Lưng"],"reference-upper",[47,687,174,155],3,6,20),
        ex("closebench","Đẩy ngực tay hẹp","Close Grip Bench Press","Tạ đòn",["Tay sau"],["Ngực","Vai"],"reference-upper",[47,865,174,155],3,15,15,"Gồm thanh đòn"),
        ex("tricep","Duỗi tay sau với dây thừng cáp","Rope Triceps Pushdown","Cáp",["Tay sau"],[],"reference-upper",[47,1043,174,155],3,6,20),
        ex("hammer","Cuốn tay kiểu búa với dây thừng cáp","Rope Hammer Curl","Cáp",["Tay trước"],[],"reference-upper",[47,1222,174,155],3,6,17.5),
        ex("shrug","Nhún vai với thanh trap bar","Trap Bar Shrug","Trap Bar",["Lưng"],[],"reference-upper",[47,1400,174,155],3,15,27.5,"Gồm thanh đòn")
    ]
    static let lower:[Exercise] = [
        ex("thruster","Squat kết hợp đẩy tạ qua đầu","Barbell Thruster","Tạ đòn",["Đùi trước","Mông"],["Vai"],"reference-lower",[47,608,155,155],3,6,42.5,"Gồm thanh đòn"),
        ex("squat","Squat tạ sau","Barbell Back Squat","Tạ đòn",["Đùi trước"],["Mông"],"reference-lower",[47,779,155,155],4,15,32.5,"Gồm thanh đòn"),
        ex("rdl","Deadlift kiểu Romania","Romanian Deadlift","Tạ đòn",["Đùi sau"],["Mông","Lưng"],"reference-lower",[47,949,155,155],3,6,40,"Gồm thanh đòn"),
        ex("goodmorning","Good morning – gập hông với tạ","Barbell Good Morning","Tạ đòn",["Đùi sau"],["Mông","Lưng"],"reference-lower",[47,1119,174,155],4,15,32.5,"Gồm thanh đòn"),
        ex("kneelsquat","Squat quỳ gối","Kneeling Squat","Tạ đòn",["Mông"],["Đùi trước"],"reference-lower",[47,1291,155,155],3,6,27.5,"Gồm thanh đòn"),
        ex("adductor","Khép hông với máy","Machine Hip Adduction","Máy tập",["Đùi trước"],[],"reference-lower",[47,1460,174,148],3,15,37.5),
        ex("calf","Nhón bắp chân đứng","Standing Calf Raise","Máy tập",["Bắp chân"],[],"reference-lower",[47,1222,174,155],3,15,30)
    ]
    static let alternatives:[Exercise] = [
        ex("bandpress","Đẩy vai với dây có tay cầm","Resistance Band Shoulder Press","Dây kháng lực",["Vai"],["Tay sau"],"reference-upper",[47,687,174,155],3,8,10),
        ex("arnold","Đẩy vai Arnold với tạ đơn","Arnold Dumbbell Press","Cặp tạ đơn",["Vai"],["Tay sau"],"reference-upper",[47,687,174,155],3,8,10,"Mỗi quả tạ"),
        ex("reversefly","Dang vai sau một tay","Single Arm Reverse Fly","Cáp",["Vai"],["Lưng"],"reference-upper",[47,687,174,155],3,8,10),
        ex("machinefly","Dang vai sau với máy","Reverse Pec Deck","Máy tập",["Vai"],["Lưng"],"reference-upper",[47,687,174,155],3,8,20),
        ex("bandface","Kéo dây kháng lực về mặt","Band Face Pull","Dây kháng lực",["Vai"],["Lưng"],"reference-upper",[47,687,174,155],3,8,0),
        ex("frontraise","Nâng vai trước với cáp","Cable Front Raise","Cáp",["Vai"],[],"reference-upper",[47,687,174,155],3,8,10)
    ]
    static let beginnerUpper:[Exercise] = {
        var row=ex("dumbbell-row","Kéo lưng với tạ đơn","Dumbbell Row","Cặp tạ đơn",["Lưng"],["Tay trước"],"reference-beginner-upper",[47,330,174,155],3,12,30,"Mỗi tay")
        row.volumeMultiplier=2;row.repsConvention="Mỗi bên"
        return [row,
            ex("smith-bench","Đẩy ngực trên ghế với máy Smith","Smith Machine Bench Press","Máy tập",["Ngực"],["Vai","Tay sau"],"reference-beginner-upper",[47,508,174,155],3,12,30),
            ex("dumbbell-back-fly","Ép vai sau với tạ đơn","Dumbbell Back Fly","Cặp tạ đơn",["Vai"],["Lưng"],"reference-beginner-upper",[47,687,174,155],3,12,15),
            ex("dumbbell-skullcrusher","Duỗi tay sau với tạ đơn khi nằm","Dumbbell Skullcrusher","Cặp tạ đơn",["Tay sau"],[],"reference-beginner-upper",[47,865,174,155],3,12,12.5),
            ex("ez-curl","Cuốn tay với thanh EZ","EZ-Bar Curl","Tạ đòn",["Tay trước"],[],"reference-beginner-upper",[47,1043,174,155],3,12,12.5,"Gồm thanh đòn"),
            ex("dumbbell-curl","Cuốn tay trước với tạ đơn","Dumbbell Bicep Curl","Cặp tạ đơn",["Tay trước"],[],"reference-beginner-upper",[47,1222,174,155],3,15,12.5),
            ex("dumbbell-shrug","Nhún vai với tạ đơn","Dumbbell Shrug","Cặp tạ đơn",["Lưng"],[],"reference-beginner-upper",[47,1400,174,155],3,15,22.5)]
    }()
    // Form supplies these exact variations. Keep unilateral Row and Arnold distinct.
    // Defaults/cues are local catalog additions, not measurements of original engine.
    static let formAdditions:[Exercise] = [
        ex("incline-dumbbell-curl","Cuốn tay với tạ đơn trên ghế dốc","Incline Dumbbell Curl","Cặp tạ đơn",["Tay trước"],[],"reference-upper",[47,1222,174,155],3,12,10,"Mỗi quả tạ"),
        ex("dumbbell-lateral-raise","Nâng tạ đơn sang hai bên","Dumbbell Lateral Raise","Cặp tạ đơn",["Vai"],[],"reference-upper",[47,687,174,155],3,12,5,"Mỗi quả tạ"),
        ex("dumbbell-shoulder-press","Đẩy vai với tạ đơn","Dumbbell Shoulder Press","Cặp tạ đơn",["Vai"],["Tay sau"],"reference-upper",[47,687,174,155],2,12,15,"Mỗi quả tạ"),
        ex("goblet-squat","Squat ôm tạ đơn trước ngực","Goblet Squat","Cặp tạ đơn",["Đùi trước","Mông"],["Bụng"],"reference-lower",[47,779,155,155],3,12,15),
        ex("bent-over-dumbbell-row","Kéo hai tạ đơn khi gập người","Bent-Over Dumbbell Row","Cặp tạ đơn",["Lưng"],["Tay trước"],"reference-upper",[47,330,174,155],3,12,10,"Mỗi quả tạ")
    ]
    static let all = upper + lower + alternatives + beginnerUpper + formAdditions
}

extension Exercise {
    func canLog(_ set:LoggedSet)->Bool {
        (timed ? set.seconds>0:set.reps>0) && set.weight.isFinite && set.weight>=0 && (set.weight>0 || ["Trọng lượng cơ thể","Dây kháng lực"].contains(equipment))
    }
}
