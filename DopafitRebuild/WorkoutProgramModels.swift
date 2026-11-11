import Foundation

/// Local, editable presets. Counts and durations come from the actual prescription,
/// not the marketing numbers in the reference screenshots.
struct WorkoutProgram:Identifiable {
    let group:WorkoutProgramGroup
    let level:Int
    var id:String {group.id+"-\(level)"}
    var levelName:String {["Người mới","Trung bình","Nâng cao"][max(0,min(2,level-1))]}
    var title:String {group.title+" · "+levelName}
    var exercises:[WorkoutExercise] {
        group.exerciseIDs.compactMap {id in
            (Catalog.all+WorkoutProgramCatalog.exercises).first{$0.id==id}
        }.filter{CheckinLogic.hasVideo($0)}.map {definition in
            var item=WorkoutExercise(definition)
            item.sets=(0..<(level+1)).map{_ in LoggedSet(reps:definition.timed ? 0:8+level*2,weight:definition.defaultWeight,seconds:definition.timed ? 15+level*5:0)}
            item.restSeconds=60
            return item
        }
    }
    var minutes:Int {max(5,Int(ceil(exercises.reduce(0.0){total,item in total+Double(item.sets.count)*(item.exercise.timed ? Double(item.sets[0].seconds+60):Double(item.sets[0].reps*4+60))}/60))+3)}
    var equipment:[String] {Array(Set(exercises.map{ $0.exercise.equipment })).sorted()}
}
struct WorkoutProgramGroup:Identifiable {
    let id:String,title:String,photo:String,exerciseIDs:[String]
    static let all:[WorkoutProgramGroup]=[
        .init(id:"abs",title:"Bụng",photo:"challenge-core-30",exerciseIDs:["discovery-deadbug","discovery-crunch","discovery-plank"]),
        .init(id:"arms",title:"Cánh tay",photo:"challenge-dumbbell-30",exerciseIDs:["dumbbell-curl","tricep","hammer"]),
        .init(id:"forearms",title:"Cẳng tay",photo:"discovery-grip",exerciseIDs:["discovery-wristcurl","discovery-reversewristcurl","discovery-farmercarry"]),
        .init(id:"chest",title:"Ngực",photo:"challenge-physique-28",exerciseIDs:["discovery-pushup","smith-bench","incline"]),
        .init(id:"legs",title:"Chân",photo:"challenge-lower-28",exerciseIDs:["goblet-squat","rdl","calf"]),
        .init(id:"glutes",title:"Mông",photo:"program-glutes",exerciseIDs:["discovery-glutebridge","goblet-squat","rdl"]),
        .init(id:"back",title:"Vai & lưng",photo:"challenge-calisthenics-28",exerciseIDs:["dumbbell-row","dumbbell-lateral-raise","facepull"])
    ]
}
enum WorkoutProgramCatalog {
    static func body(_ id:String,_ title:String,_ english:String,_ muscles:[String],_ cues:[String],timed:Bool=false,gear:String="Trọng lượng cơ thể",weight:Double=0,photo:String="challenge-consistent-14")->Exercise {
        Exercise(id:"discovery-"+id,name:title,english:english,equipment:gear,muscles:muscles,secondary:[],image:photo,imageRect:[],instructions:cues,defaultSets:2,defaultReps:10,defaultWeight:weight,timed:timed)
    }
    static let exercises:[Exercise]=[
        body("deadbug","Dead bug – duỗi tay chân đối bên","Dead Bug",["Bụng"],["Nằm ngửa, nâng tay và gập hông/gối; giữ thân người ổn định.","Duỗi chậm tay và chân đối bên trong biên độ kiểm soát, rồi đổi bên.","Thở đều; giảm biên độ nếu lưng bị ưỡn hoặc khó chịu."],photo:"challenge-core-30"),
        body("crunch","Gập bụng ngắn","Crunch",["Bụng"],["Nằm ngửa, gối gập và bàn chân đặt vững trên sàn.","Nâng nhẹ vai khỏi sàn bằng cơ bụng; không kéo cổ.","Hạ chậm có kiểm soát; không cần ngồi dậy hoàn toàn."],photo:"challenge-core-30"),
        body("plank","Plank trên cẳng tay","Forearm Plank",["Bụng"],["Đặt khuỷu tay dưới vai, giữ thân người thành đường thẳng.","Giữ cơ bụng vừa phải và thở đều; không võng lưng.","Hạ gối xuống nếu cần để giữ tư thế thoải mái."],timed:true,photo:"challenge-core-14"),
        body("pushup","Chống đẩy","Push-up",["Ngực"],["Đặt tay hơi rộng hơn vai và giữ thân người ổn định.","Hạ ngực chậm, rồi đẩy lên trong biên độ kiểm soát.","Có thể chống tay lên mặt phẳng cao, chắc chắn để giảm độ khó."],photo:"challenge-consistent-14"),
        body("glutebridge","Nâng hông nằm ngửa","Glute Bridge",["Mông","Đùi sau"],["Nằm ngửa, gối gập, bàn chân đặt vững trên sàn.","Đẩy qua bàn chân và nâng hông đến khi thân người thẳng; không ưỡn lưng.","Hạ hông chậm, có kiểm soát."],photo:"challenge-lower-28"),
        body("wristcurl","Cuốn cổ tay với tạ đơn","Dumbbell Wrist Curl",["Cẳng tay"],["Ngồi vững, đặt cẳng tay lên đùi, lòng bàn tay hướng lên.","Giữ cẳng tay cố định và cuốn cổ tay trong biên độ thoải mái.","Dùng tạ nhẹ, hạ chậm; không giật cổ tay."],gear:"Cặp tạ đơn",weight:2.5,photo:"challenge-dumbbell-30"),
        body("reversewristcurl","Duỗi cổ tay với tạ đơn","Reverse Dumbbell Wrist Curl",["Cẳng tay"],["Đặt cẳng tay lên đùi, lòng bàn tay hướng xuống.","Nâng mu bàn tay nhẹ rồi hạ chậm, giữ cẳng tay cố định.","Chọn tạ nhẹ và tránh biên độ gây khó chịu."],gear:"Cặp tạ đơn",weight:2.5,photo:"challenge-dumbbell-30"),
        body("farmercarry","Xách tạ đi bộ","Farmer Carry",["Cẳng tay"],["Cầm tạ ở hai bên, đứng thẳng và giữ vai tự nhiên.","Đi bước ngắn, có kiểm soát trên lối đi thông thoáng.","Đặt tạ xuống nhẹ nhàng khi kết thúc."],timed:true,gear:"Cặp tạ đơn",weight:5,photo:"challenge-dumbbell-30"),
        body("bodysquat","Squat trọng lượng cơ thể","Bodyweight Squat",["Đùi trước","Mông"],["Đứng chân rộng thoải mái, giữ bàn chân vững.","Gập hông/gối để hạ người trong biên độ kiểm soát rồi đứng lên.","Giữ gối theo hướng mũi chân, không ép xuống sâu."],photo:"challenge-lower-28")
    ]
    static func suggested(for challenge:WorkoutChallenge)->WorkoutProgram {
        let group:WorkoutProgramGroup
        switch challenge.id {
        case "core-14","core-30": group=WorkoutProgramGroup.all[0]
        case "lower-28": group=WorkoutProgramGroup.all[4]
        case "dumbbell-30": group=WorkoutProgramGroup(id:"dumbbell",title:"Toàn thân với tạ đơn",photo:"challenge-dumbbell-30",exerciseIDs:["goblet-squat","dumbbell-row","dumbbell-shoulder-press","dumbbell-curl"])
        case "fullbody-28","calisthenics-28","activity-30","consistent-14": group=WorkoutProgramGroup(id:"bodyweight",title:"Toàn thân không dụng cụ",photo:challenge.photo,exerciseIDs:["discovery-bodysquat","discovery-pushup","discovery-glutebridge","discovery-deadbug"])
        default: group=WorkoutProgramGroup.all[6]
        }
        return WorkoutProgram(group:group,level:1)
    }
}
extension AppStore {
    /// No data mutation from browsing; called only after an explicit UI choice.
    @discardableResult func applyProgram(_ program:WorkoutProgram,replacing:Bool=false)->Bool {
        guard (1...3).contains(program.level),!program.exercises.isEmpty else{return false}
        if replacing,let draft=data.draft,draft.hasStarted || draft.completedSets>0{return false}
        if replacing || data.draft==nil {
            data.draft=WorkoutSession(name:program.title,plannedMinutes:program.minutes,exercises:program.exercises)
        } else {data.draft!.exercises.append(contentsOf:program.exercises)}
        persist();return true
    }
}
