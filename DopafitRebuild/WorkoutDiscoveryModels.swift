import Foundation

struct WorkoutChallenge:Identifiable {
    let id:String,title:String,subtitle:String,days:Int,targetDays:Int,muscles:[String],symbol:String
    static let all:[WorkoutChallenge]=[
        .init(id:"consistent-14",title:"Xây nhịp tập",subtitle:"6 ngày vận động trong 2 tuần",days:14,targetDays:6,muscles:[],symbol:"flame"),
        .init(id:"upper-28",title:"Vững thân trên",subtitle:"8 ngày tập thân trên trong 4 tuần",days:28,targetDays:8,muscles:["Ngực","Vai","Lưng","Tay trước","Tay sau"],symbol:"figure.strengthtraining.traditional"),
        .init(id:"lower-28",title:"Vững đôi chân",subtitle:"8 ngày tập thân dưới trong 4 tuần",days:28,targetDays:8,muscles:["Đùi trước","Đùi sau","Mông","Bắp chân"],symbol:"figure.walk"),
        .init(id:"physique-28",title:"Xây nền sức mạnh",subtitle:"8 ngày tập thân trên trong 4 tuần",days:28,targetDays:8,muscles:["Ngực","Vai","Lưng"],symbol:"dumbbell"),
        .init(id:"fullbody-28",title:"Toàn thân 28 ngày",subtitle:"12 ngày tập cân bằng trong 4 tuần",days:28,targetDays:12,muscles:[],symbol:"figure.mixed.cardio"),
        .init(id:"calisthenics-28",title:"Calisthenics",subtitle:"12 ngày tập trọng lượng cơ thể",days:28,targetDays:12,muscles:[],symbol:"figure.strengthtraining.functional"),
        .init(id:"pelvic-14",title:"Thói quen Kegel",subtitle:"14 ngày ghi nhận thực hành sàn chậu",days:14,targetDays:14,muscles:[],symbol:"heart"),
        .init(id:"core-14",title:"Core vững 14 ngày",subtitle:"6 ngày tập bụng và ổn định thân người",days:14,targetDays:6,muscles:["Bụng"],symbol:"figure.core.training"),
        .init(id:"dumbbell-30",title:"30 ngày cùng tạ đơn",subtitle:"12 ngày tập với tạ đơn",days:30,targetDays:12,muscles:[],symbol:"dumbbell"),
        .init(id:"activity-30",title:"Vận động 30 ngày",subtitle:"12 ngày vận động theo sức của bạn",days:30,targetDays:12,muscles:[],symbol:"flame"),
        .init(id:"core-30",title:"Bụng khỏe 30 ngày",subtitle:"12 ngày xây sức bền cơ bụng",days:30,targetDays:12,muscles:["Bụng"],symbol:"figure.core.training"),
        .init(id:"mobility-28",title:"Linh hoạt mỗi ngày",subtitle:"12 ngày thực hành giãn cơ trong 4 tuần",days:28,targetDays:12,muscles:[],symbol:"figure.flexibility")
    ]
    var manualPractice:Bool {id=="pelvic-14" || id=="mobility-28"}
    var photo:String {"challenge-"+id}
    var summary:String {
        switch id {
        case "consistent-14":return "Toàn thân · 6 ngày tập"
        case "upper-28","physique-28":return "Thân trên · 8 ngày tập"
        case "lower-28":return "Chân & mông · 8 ngày tập"
        case "pelvic-14":return "Sàn chậu · Thói quen hằng ngày"
        case "mobility-28":return "Giãn cơ · 12 ngày thực hành"
        case "core-14","core-30":return "Bụng · \(targetDays) ngày tập"
        case "dumbbell-30":return "Tạ đơn · 12 ngày tập"
        default:return "Toàn thân · 12 ngày tập"
        }
    }
    func accepts(_ exercise:Exercise)->Bool {
        if manualPractice{return false}
        if id=="calisthenics-28" {return exercise.equipment=="Trọng lượng cơ thể"}
        if id=="dumbbell-30" {return exercise.equipment=="Cặp tạ đơn"}
        return muscles.isEmpty || !Set(exercise.muscles).isDisjoint(with:muscles)
    }

}
struct ChallengeEnrollment:Identifiable,Codable,Equatable {
    var id=UUID()
    var challengeID:String
    var started:Date
    var left:Date?=nil
}
enum WorkoutCalendarLogic {
    static func calendar()->Calendar {var c=Calendar.current;c.firstWeekday=2;return c}
    static func week(containing date:Date,calendar:Calendar=calendar())->[Date] {
        let day=calendar.startOfDay(for:date),weekday=calendar.component(.weekday,from:day)
        let offset=(weekday-calendar.firstWeekday+7)%7
        let start=calendar.date(byAdding:.day,value:-offset,to:day)!
        return (0..<7).compactMap{calendar.date(byAdding:.day,value:$0,to:start)}
    }
    static func trainingDays(_ sessions:[WorkoutSession],in dates:[Date],calendar:Calendar=calendar())->Set<Date> {
        let wanted=Set(dates.map{calendar.startOfDay(for:$0)})
        return Set(sessions.filter{$0.completedSets>0}.map{calendar.startOfDay(for:$0.started)}).intersection(wanted)
    }
    static func progress(_ challenge:WorkoutChallenge,enrollment:ChallengeEnrollment,history:[WorkoutSession],now:Date=Date(),calendar:Calendar=calendar(),practices:[ChallengePractice]=[])->Set<Date> {
        let first=calendar.startOfDay(for:enrollment.started)
        let end=calendar.date(byAdding:.day,value:challenge.days,to:first)!
        let cutoff=min(now,enrollment.left ?? now)
        if challenge.manualPractice {
            return Set(practices.filter{$0.enrollmentID==enrollment.id && $0.date>=enrollment.started && $0.date<=cutoff && $0.date<end}.map{calendar.startOfDay(for:$0.date)})
        }
        return Set(history.filter {session in
            guard session.started>=enrollment.started,session.started<=cutoff,session.started<end else{return false}
            return session.completedExercises.contains {ex in challenge.accepts(ex.exercise)}
        }.map{calendar.startOfDay(for:$0.started)})
    }
}
extension AppStore {
    func activeEnrollment(_ id:String,on now:Date=Date())->ChallengeEnrollment? {
        guard let challenge=WorkoutChallenge.all.first(where:{$0.id==id}) else{return nil}
        return (data.challenges ?? []).last{enrollment in
            guard enrollment.challengeID==id,enrollment.left==nil else{return false}
            let end=WorkoutCalendarLogic.calendar().date(byAdding:.day,value:challenge.days,to:WorkoutCalendarLogic.calendar().startOfDay(for:enrollment.started))!
            return enrollment.started<=now && now<end
        }
    }
    @discardableResult func joinChallenge(_ id:String,on now:Date=Date())->Bool {
        guard WorkoutChallenge.all.contains(where:{$0.id==id}),activeEnrollment(id,on:now)==nil else{return false}
        data.challenges=(data.challenges ?? [])+[ChallengeEnrollment(challengeID:id,started:now)];persist();return true
    }
    @discardableResult func leaveChallenge(_ id:String,on now:Date=Date())->Bool {
        guard let enrollment=activeEnrollment(id,on:now),let index=data.challenges?.firstIndex(where:{$0.id==enrollment.id}) else{return false}
        data.challenges![index].left=now;persist();return true
    }
    var suggestedMuscles:[String] {
        let available=Set(Catalog.all.filter{currentGym.equipment.contains($0.equipment) && data.preferences[$0.id] != -2 && CheckinLogic.hasVideo($0)}.flatMap(\.muscles))
        return Catalog.muscleNames.enumerated().filter{available.contains($0.element) && muscleRecovery($0.element)>=65}.sorted{a,b in
            let ar=muscleRecovery(a.element),br=muscleRecovery(b.element)
            return ar==br ? a.offset<b.offset:ar>br
        }.prefix(5).map(\.element)
    }
}

struct ChallengePractice:Codable,Equatable {
    var enrollmentID:UUID
    var date:Date
}
extension AppStore {
    @discardableResult func recordPractice(_ challengeID:String,on now:Date=Date(),remove:Bool=false)->Bool {
        guard let challenge=WorkoutChallenge.all.first(where:{$0.id==challengeID}),challenge.manualPractice,let enrollment=activeEnrollment(challengeID,on:now) else{return false}
        let c=WorkoutCalendarLogic.calendar()
        let exists=(data.challengePractices ?? []).contains{$0.enrollmentID==enrollment.id && c.isDate($0.date,inSameDayAs:now)}
        if remove {guard exists else{return false};data.challengePractices?.removeAll{$0.enrollmentID==enrollment.id && c.isDate($0.date,inSameDayAs:now)}}
        else {guard !exists else{return false};data.challengePractices=(data.challengePractices ?? [])+[ChallengePractice(enrollmentID:enrollment.id,date:now)]}
        persist();return true
    }
}
