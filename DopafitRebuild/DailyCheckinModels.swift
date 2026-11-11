import Foundation

// Ô "Hôm nay bạn thế nào?" trên Home và luật hạ tạ khi nghỉ lâu (Claude, 10/11/2026, theo yêu cầu người dùng).
// Đây là luật CỤC BỘ, đọc được, không phải thuật toán Dopafit gốc. Nhãn khớp chịu lực là ước lượng, cần người có chuyên môn rà lại.

enum CheckinFeeling:String,Codable,CaseIterable,Identifiable {
    case good,tired,pain,short
    var id:String {rawValue}
    var title:String {
        switch self {
        case .good:return "Khỏe"
        case .tired:return "Hơi mệt"
        case .pain:return "Đang đau"
        case .short:return "Ít thời gian"
        }
    }
    var symbol:String {
        switch self {
        case .good:return "checkmark.circle"
        case .tired:return "battery.25"
        case .pain:return "bandage"
        case .short:return "clock"
        }
    }
}

struct DailyCheckin:Codable,Equatable {
    var date:Date
    var feeling:CheckinFeeling
    var painAreas:[String]=[]
    var minutes:Int?=nil
    var draftID:UUID
    var original:[WorkoutExercise]
    var originalMinutes:Int
    /// WorkoutExercise.id.uuidString -> ghi chú hiện dưới bài trên Home.
    var notes:[String:String]=[:]
    var removed:[String]=[]
    /// Optional để snapshot cũ (chưa có trường này) vẫn đọc được.
    var lightened:Int?=nil
}

enum JointLoad {
    static let areas=["Cổ","Vai","Khuỷu tay","Cổ tay","Lưng dưới","Gối"]
    static let map:[String:Set<String>]=[
        "incline":["Vai","Cổ tay","Khuỷu tay"],"closebench":["Khuỷu tay","Cổ tay","Vai"],"smith-bench":["Vai"],
        "discovery-pushup":["Vai","Cổ tay"],"arnold":["Vai"],"bandpress":["Vai"],"dumbbell-shoulder-press":["Vai"],
        "frontraise":["Vai"],"dumbbell-lateral-raise":["Vai"],"discovery-plank":["Vai"],
        "tbar":["Lưng dưới"],"bent-over-dumbbell-row":["Lưng dưới"],"shrug":["Cổ"],"dumbbell-shrug":["Cổ"],
        "tricep":["Khuỷu tay"],"dumbbell-skullcrusher":["Khuỷu tay"],"hammer":["Khuỷu tay"],"dumbbell-curl":["Khuỷu tay"],
        "ez-curl":["Khuỷu tay","Cổ tay"],"incline-dumbbell-curl":["Khuỷu tay"],
        "thruster":["Vai","Gối","Lưng dưới"],"squat":["Gối","Lưng dưới"],"rdl":["Lưng dưới"],"goodmorning":["Lưng dưới","Cổ"],
        "kneelsquat":["Gối","Lưng dưới"],"goblet-squat":["Gối"],"discovery-bodysquat":["Gối"],"discovery-crunch":["Cổ"],
        "discovery-wristcurl":["Cổ tay"],"discovery-reversewristcurl":["Cổ tay"],"discovery-farmercarry":["Cổ tay"],
        "dumbbell-back-fly":["Vai","Lưng dưới"],"reversefly":["Vai"],"machinefly":["Vai"],"facepull":["Vai"],"bandface":["Vai"]
    ]
    static func joints(_ ex:Exercise)->Set<String> {map[ex.id] ?? []}
    /// Vùng cơ thể vẫn phải làm việc ít nhiều khi tập bài này (cơ chính + cơ phụ). Dùng để giảm tạ bài không bị đổi.
    static let regionMuscles:[String:Set<String>]=[
        "Vai":["Vai","Ngực"],"Khuỷu tay":["Tay trước","Tay sau"],"Cổ tay":["Tay trước"],
        "Lưng dưới":["Lưng","Đùi sau","Mông"],"Gối":["Đùi trước","Mông","Bắp chân"],"Cổ":["Vai"]
    ]
    /// Cổ chỉ xét cơ chính (bài vai dùng cơ cầu vai); không giảm bài ngực/lưng chỉ vì có Vai là cơ phụ.
    static func touches(_ ex:Exercise,_ area:String)->Bool {
        let muscles=area=="Cổ" ? ex.muscles:ex.muscles+ex.secondary
        return !Set(muscles).isDisjoint(with:regionMuscles[area] ?? [])
    }
}

enum CheckinLogic {
    static let breakThreshold=14
    static let breakFactor=0.75
    /// Bài thay thế chỉ lấy bài có video hướng dẫn. App gắn hàm thật lúc khởi động; test giữ mặc định.
    static var hasVideo:(Exercise)->Bool={_ in true}
    /// Số ngày từ buổi gần nhất tới hôm nay nếu ≥14, ngược lại nil.
    static func breakDays(history:[WorkoutSession],now:Date=Date(),calendar:Calendar = .current)->Int? {
        guard let last=history.filter({$0.completedSets>0}).map(\.started).max() else{return nil}
        let days=calendar.dateComponents([.day],from:calendar.startOfDay(for:last),to:calendar.startOfDay(for:now)).day ?? 0
        return days>=breakThreshold ? days:nil
    }
    /// Làm tròn XUỐNG theo dụng cụ thật trong phòng tập, để không bao giờ nặng hơn mức đã tính.
    static func roundDown(_ weight:Double,equipment:String,profile:GymProfile)->Double {
        guard weight>0 else{return 0}
        if equipment=="Cặp tạ đơn" {
            let options=profile.dumbbells.sorted()
            return options.last{$0<=weight+0.01} ?? options.first ?? weight
        }
        if ["Tạ đòn","Trap Bar","T-Bar Row"].contains(equipment) {
            let step=(profile.plates.min() ?? 1.25)*2
            return max(profile.barWeight,(weight/step).rounded(.down)*step)
        }
        return max(2.5,(weight/2.5).rounded(.down)*2.5)
    }
    /// Nấc tạ có thật gần mức mục tiêu nhất, nhưng không vượt mức cũ.
    static func nearest(_ target:Double,cap:Double,equipment:String,profile:GymProfile)->Double {
        if equipment=="Cặp tạ đơn" {
            let options=profile.dumbbells.filter{$0<=cap+0.01}
            return options.min{abs($0-target)<abs($1-target)} ?? cap
        }
        let barbell=["Tạ đòn","Trap Bar","T-Bar Row"].contains(equipment)
        let step=barbell ? (profile.plates.min() ?? 1.25)*2:2.5
        let floor=barbell ? profile.barWeight:step
        return min(cap,max(floor,(target/step).rounded()*step))
    }
    /// Sau nghỉ dài: không thấp hơn peak×factor, không cao hơn peak (mức trước khi nghỉ).
    static func ramped(_ item:WorkoutExercise,peak:Double,factor:Double,profile:GymProfile)->WorkoutExercise {
        guard peak>0 else{return item}
        var item=item
        let floor=nearest(peak*factor,cap:peak,equipment:item.exercise.equipment,profile:profile)
        for i in item.sets.indices where !item.sets[i].warmup {item.sets[i].weight=min(peak,max(item.sets[i].weight,floor))}
        return item
    }
    static func scaled(_ item:WorkoutExercise,factor:Double,profile:GymProfile)->WorkoutExercise {
        var item=item
        for i in item.sets.indices where item.sets[i].weight>0 {
            let old=item.sets[i].weight
            item.sets[i].weight=nearest(old*factor,cap:old,equipment:item.exercise.equipment,profile:profile)
        }
        return item
    }
}

extension AppStore {
    var todayCheckin:DailyCheckin? {
        guard let checkin=data.checkin,Calendar.current.isDateInToday(checkin.date),checkin.draftID==data.draft?.id else{return nil}
        return checkin
    }
    /// Chỉ chỉnh khi buổi hôm nay chưa bắt đầu và chưa ghi set nào.
    var checkinEditable:Bool {data.draft.map{!$0.hasStarted && $0.completedSets==0} ?? false}
    func checkinNote(_ item:WorkoutExercise)->String? {todayCheckin?.notes[item.id.uuidString]}
    /// Bài này khác bản gốc (đổi bài, đổi tạ hoặc số set) do lựa chọn thể trạng hôm nay.
    func checkinChanged(_ item:WorkoutExercise)->Bool {
        guard let checkin=todayCheckin,checkin.feeling != .good else{return false}
        if checkin.notes[item.id.uuidString] != nil {return true}
        guard let source=checkin.original.first(where:{$0.id==item.id}) else{return true}
        return source.sets.count != item.sets.count || zip(source.sets,item.sets).contains{abs($0.weight-$1.weight)>0.01}
    }

    @discardableResult func applyCheckin(_ feeling:CheckinFeeling,pain:[String]=[],minutes:Int?=nil,now:Date=Date())->Bool {
        guard var draft=data.draft,checkinEditable else{return false}
        if let previous=data.checkin,previous.draftID==draft.id {draft.exercises=previous.original;draft.plannedMinutes=previous.originalMinutes}
        var record=DailyCheckin(date:now,feeling:feeling,painAreas:pain,minutes:minutes,draftID:draft.id,original:draft.exercises,originalMinutes:draft.plannedMinutes)
        let profile=currentGym
        switch feeling {
        case .good:
            break
        case .tired:
            draft.exercises=draft.exercises.map{source in
                var item=CheckinLogic.scaled(source,factor:0.9,profile:profile)
                let working=item.sets.indices.filter{!item.sets[$0].warmup}
                if working.count>2, let last=working.last {item.sets.remove(at:last)}
                return item
            }
        case .pain:
            let painful=Set(pain)
            var used=Set(draft.exercises.map(\.exercise.id))
            var result:[WorkoutExercise]=[]
            for source in draft.exercises {
                let hit=JointLoad.joints(source.exercise).intersection(painful)
                if hit.isEmpty {
                    let near=painful.filter{JointLoad.touches(source.exercise,$0)}
                    if near.isEmpty {result.append(source);continue}
                    var item=CheckinLogic.scaled(source,factor:0.8,profile:profile)
                    if item.sets.filter({!$0.warmup}).count>2, let last=item.sets.indices.last(where:{!item.sets[$0].warmup}) {item.sets.remove(at:last)}
                    record.notes[item.id.uuidString]="Nhẹ hơn cho "+near.sorted().joined(separator:", ").lowercased()
                    record.lightened=(record.lightened ?? 0)+1
                    result.append(item);continue
                }
                let primary=source.exercise.muscles.first ?? ""
                let candidates=Catalog.all.filter{ex in
                    !used.contains(ex.id) && ex.muscles.contains(primary) && JointLoad.joints(ex).isDisjoint(with:painful)
                        && profile.equipment.contains(ex.equipment) && data.preferences[ex.id] != -2 && CheckinLogic.hasVideo(ex)
                }.sorted{ExerciseMeta.level($0)<ExerciseMeta.level($1)}
                if let pick=candidates.first {
                    used.insert(pick.id)
                    var item=WorkoutExercise(pick)
                    let sets=max(2,source.sets.filter{!$0.warmup}.count)
                    item.sets=(0..<sets).map{_ in LoggedSet(reps:pick.defaultReps,weight:pick.defaultWeight)}
                    item.restSeconds=source.restSeconds
                    record.notes[item.id.uuidString]="Thay cho "+source.exercise.name.lowercasedFirst+" · tránh "+hit.sorted().joined(separator:", ").lowercased()
                    result.append(item)
                } else {
                    record.removed.append(source.exercise.name)
                }
            }
            draft.exercises=result
        case .short:
            let chosen=minutes ?? 20
            let keep=max(2,chosen/8)
            if draft.exercises.count>keep {
                record.removed=draft.exercises.suffix(from:keep).map(\.exercise.name)
                draft.exercises=Array(draft.exercises.prefix(keep))
            }
            draft.plannedMinutes=chosen
        }
        data.draft=draft;data.checkin=record;persist();return true
    }
    var loggedSessions:Int {data.history.filter{$0.completedSets>0}.count}
    /// Ngày tập theo kế hoạch gần nhất (trong 3 ngày qua) mà không có buổi nào, và từ đó tới giờ cũng chưa tập. Nil nếu không lỡ hoặc đã ẩn.
    func missedPlannedDay(now:Date=Date())->Date? {
        guard let planned=data.plan.trainingDays,!planned.isEmpty,!data.history.isEmpty else{return nil}
        let cal=Calendar.current,today=cal.startOfDay(for:now)
        guard data.draft.map({!$0.hasStarted && $0.completedSets==0}) ?? false else{return nil}
        for back in 1...3 {
            let day=cal.date(byAdding:.day,value:-back,to:today)!
            guard planned.contains(cal.component(.weekday,from:day)) else{continue}
            let trainedSince=data.history.contains{$0.completedSets>0 && $0.started>=day}
            let beforeFirst=data.history.map(\.started).min().map{cal.startOfDay(for:$0)>day} ?? true
            if trainedSince || beforeFirst {return nil}
            return data.dismissedTips?.contains(Self.missedKey(day)) == true ? nil:day
        }
        return nil
    }
    static func missedKey(_ day:Date)->String {"missed-"+ISO8601DateFormatter().string(from:day).prefix(10)}
    /// Máy bận: bài cùng cơ chính, ưu tiên dụng cụ khác (máy kia đang có người), có video, có trong phòng tập, chưa có trong buổi.
    func busySwapCandidate(for item:WorkoutExercise)->Exercise? {
        let primary=item.exercise.muscles.first ?? ""
        let inDraft=Set((data.draft?.exercises ?? []).map(\.exercise.id))
        let allowed=Set(currentGym.equipment)
        return Catalog.all.filter{ex in ex.id != item.exercise.id && !inDraft.contains(ex.id) && ex.muscles.first==primary
            && allowed.contains(ex.equipment) && data.preferences[ex.id] != -2 && CheckinLogic.hasVideo(ex)}
            .sorted{a,b in
                let ad=a.equipment != item.exercise.equipment, bd=b.equipment != item.exercise.equipment
                return ad != bd ? ad:ExerciseMeta.level(a)<ExerciseMeta.level(b)
            }.first
    }
    /// Đổi ngay, giữ số set và thời gian nghỉ của bài cũ.
    @discardableResult func busySwap(_ id:UUID)->Exercise? {
        guard let item=data.draft?.exercises.first(where:{$0.id==id}),let pick=busySwapCandidate(for:item) else{return nil}
        let sets=max(1,item.sets.filter{!$0.warmup}.count)
        mutateExercise(id){ex in
            var next=WorkoutExercise(pick)
            next.sets=(0..<sets).map{_ in LoggedSet(reps:pick.defaultReps,weight:pick.defaultWeight)}
            next.restSeconds=item.restSeconds;next.supersetID=item.supersetID
            ex=next
        }
        return pick
    }
    /// Check-in của ngày trước hết hiệu lực: nếu buổi chưa bắt đầu thì trả buổi về bản gốc, rồi xóa check-in.
    func expireCheckinIfNeeded(now:Date=Date()) {
        guard let checkin=data.checkin,!Calendar.current.isDate(checkin.date,inSameDayAs:now) else{return}
        if checkin.draftID==data.draft?.id && checkinEditable {
            data.draft?.exercises=checkin.original
            data.draft?.plannedMinutes=checkin.originalMinutes
        }
        data.checkin=nil;persist()
    }
    func clearCheckin() {
        guard let checkin=todayCheckin,checkinEditable else{data.checkin=nil;persist();return}
        data.draft?.exercises=checkin.original
        data.draft?.plannedMinutes=checkin.originalMinutes
        data.checkin=nil;persist()
    }
    /// Một câu giải thích vì sao buổi hôm nay như vậy. Nil khi chưa có gì để nói.
    func todayReason()->String? {
        guard let draft=data.draft else{return nil}
        if let days=draft.returnBreakDays {return "Quay lại sau nghỉ \(days) ngày · tạ giảm 25%, tăng dần trong 2 tuần"}
        if let week=draft.returnWeek, todayCheckin==nil {return "Tuần \(week) sau khi quay lại · tạ khoảng \(week==1 ? 75:85)% mức cũ"}
        if let checkin=todayCheckin {
            switch checkin.feeling {
            case .tired:return "Hơi mệt · bớt 1 set, tạ giảm 10% ở mọi bài"
            case .pain:
                let areas=checkin.painAreas.joined(separator:", ").lowercased()
                let changed=checkin.notes.count
                let lightened=checkin.lightened ?? 0
                let swapped=changed-lightened
                var parts:[String]=[]
                if swapped>0 {parts.append("Đổi \(swapped) bài")}
                if lightened>0 {parts.append("giảm tạ \(lightened) bài")}
                if !checkin.removed.isEmpty {parts.append("bỏ \(checkin.removed.count) bài")}
                return parts.isEmpty ? "Không bài nào dùng tới \(areas)" : parts.joined(separator:", ").capitalizedFirst+" để đỡ cho \(areas)"
            case .short:return "Rút gọn còn \(draft.exercises.count) bài · khoảng \(draft.plannedMinutes) phút"
            case .good:break
            }
        }
        guard !data.history.isEmpty else{return nil}
        var raised=0
        for item in draft.exercises {
            guard let previous=exerciseHistory(item.exercise.id).first?.1.sets.filter({!$0.warmup && $0.completed}).last,
                  let current=item.sets.first(where:{!$0.warmup}) else{continue}
            if current.weight>previous.weight+0.01 {raised+=1}
        }
        var seen=Set<String>()
        let muscles=draft.exercises.compactMap{$0.exercise.muscles.first}.filter{seen.insert($0).inserted}
        let ready=muscles.filter{muscleRecovery($0)>=80}.prefix(2)
        var parts:[String]=[]
        if !ready.isEmpty {parts.append(ready.enumerated().map{$0.offset==0 ? $0.element:$0.element.lowercased()}.joined(separator:", ")+" đã hồi phục")}
        parts.append(raised>0 ? "tăng tạ \(raised) bài" : "giữ mức tạ")
        return parts.joined(separator:" · ").capitalizedFirst
    }
}

extension String {
    var lowercasedFirst:String {prefix(1).lowercased()+dropFirst()}
    var capitalizedFirst:String {prefix(1).uppercased()+dropFirst()}
}
