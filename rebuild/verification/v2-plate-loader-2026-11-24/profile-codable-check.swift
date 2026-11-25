import Foundation
enum WeightUnit: String, Codable { case kg, lb }
enum Joint: String, Codable { case neck, shoulder, elbow, wrist, lowerBack, knee }
enum Gear: String, CaseIterable { case barbell, dumbbell, cable, machine, smith, band, bodyweight, tbar }
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
    // Optional so existing saved profiles decode unchanged.
    var activity: Activity? = nil
    enum Activity: String, Codable, CaseIterable {
        case sedentary, light, moderate, high
        var name: String { switch self {
        case .sedentary: "Ít vận động"
        case .light: "Vận động nhẹ"
        case .moderate: "Khá tích cực"
        case .high: "Rất tích cực"
        } }
        var detail: String { switch self {
        case .sedentary: "Tôi ngồi nhiều và ít khi tập thể dục."
        case .light: "Tôi thỉnh thoảng tập thể dục hoặc đi bộ khoảng 30 phút."
        case .moderate: "Tôi thường vận động hoặc tập thể dục 3–4 ngày mỗi tuần."
        case .high: "Tôi vận động nhiều và tập luyện hầu hết các ngày trong tuần."
        } }
        var photo: String { switch self {
        case .sedentary: "person-seated"
        case .light: "person-walk"
        case .moderate: "person-run"
        case .high: "person-lift"
        } }
    }
    var recent: Recent? = nil
    var obstacles: [String]? = nil
    var reminderHour: Int? = nil
    var firstDay: Date? = nil
    var desires: [String]? = nil
    var heightCm: Int? = nil
    var injuries: [Joint]? = nil

    enum Recent: String, Codable, CaseIterable { case regular, onOff, returning
        var name: String { switch self { case .regular: "Đang tập đều"; case .onOff: "Lúc tập lúc nghỉ"; case .returning: "Đang nghỉ, muốn tập lại" } }
        var icon: String { switch self { case .regular: "checkmark.seal"; case .onOff: "waveform.path"; case .returning: "arrow.uturn.backward" } }
    }
}

let decoder = JSONDecoder()
let encoder = JSONEncoder()
var base = Profile()
let old = try encoder.encode(base)
let oldObject = try JSONSerialization.jsonObject(with: old) as! [String: Any]
precondition(oldObject["activity"] == nil)
let legacy = try decoder.decode(Profile.self, from: old)
precondition(legacy.activity == nil && legacy.sex == .male)
for level in Profile.Activity.allCases {
 var profile = legacy
 profile.activity = level
 profile.sex = .female
 let restored = try decoder.decode(Profile.self, from: encoder.encode(profile))
 precondition(restored == profile)
}
print("PASS legacy profile without activity; 4 activity values round trip; existing sex preserved")
