import Foundation

/// Local labels retained from Claude's approved picker, not Dopafit engine data.
enum ExerciseMeta {
    static let gearGroups=["Tạ đòn","Tạ đơn","Máy","Cáp","Cơ thể","Dây"]
    static func gearGroup(_ equipment:String)->String {
        switch equipment {
        case "Tạ đòn","Bánh tạ","Trap Bar","T-Bar Row": return "Tạ đòn"
        case "Cặp tạ đơn","Tạ chuông": return "Tạ đơn"
        case "Máy tập": return "Máy"
        case "Cáp": return "Cáp"
        case "Dây kháng lực": return "Dây"
        default: return "Cơ thể"
        }
    }
    private static let easy:Set<String>=["smith-bench","dumbbell-row","dumbbell-curl","ez-curl","dumbbell-shrug","dumbbell-skullcrusher","dumbbell-back-fly","adductor","calf","tricep","hammer","machinefly","bandface","bandpress","frontraise","goblet-squat","dumbbell-lateral-raise","dumbbell-shoulder-press"]
    private static let hard:Set<String>=["thruster","goodmorning"]
    static func level(_ ex:Exercise)->Int {hard.contains(ex.id) ? 3:(easy.contains(ex.id) ? 1:2)}
    static func levelName(_ level:Int)->String {level==1 ? "Mới tập":(level==2 ? "Đã quen":"Nâng cao")}
    static func fold(_ text:String)->String {text.folding(options:[.diacriticInsensitive,.caseInsensitive],locale:Locale(identifier:"vi")).replacingOccurrences(of:"đ",with:"d")}
}
struct ExerciseLibraryFilter {
    var query=""
    var muscle:String?=nil
    var levels:Set<Int>=[]
    var gears:Set<String>=[]
    var todayMuscles:Set<String>?=nil
    var ownedGear:Set<String>?=nil
    func matches(_ ex:Exercise)->Bool {
        let hay=ExerciseMeta.fold(ex.name+" "+ex.english+" "+ex.equipment+" "+ex.muscles.joined(separator:" "))
        let words=ExerciseMeta.fold(query).split(whereSeparator:{$0.isWhitespace})
        if !words.allSatisfy({hay.contains($0)}) {return false}
        if let muscle,!ex.muscles.contains(muscle){return false}
        if !levels.isEmpty && !levels.contains(ExerciseMeta.level(ex)){return false}
        if !gears.isEmpty && !gears.contains(ExerciseMeta.gearGroup(ex.equipment)){return false}
        if let todayMuscles,todayMuscles.isDisjoint(with:ex.muscles){return false}
        if let ownedGear,ex.equipment != "Trọng lượng cơ thể",!ownedGear.contains(ex.equipment){return false}
        return true
    }
}
