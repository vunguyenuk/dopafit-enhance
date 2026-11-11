import SwiftUI
import UserNotifications
import HealthKit

struct SettingsView:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) var dismiss
    @State private var sheet=""
    @State private var exporting=false
    var body:some View {
        VStack(spacing:0){
            ScreenHeader(title:store.t("Cài đặt","Settings"),back:{dismiss()})
            ScrollView {
                VStack(alignment:.leading,spacing:0) {
                    SectionLabel(title:"Tài khoản")
                    GroupCard {
                        SettingRow(title:"Gói thành viên",value:"Dopafit Pro",chevron:false)
                        Divider().padding(.leading,16)
                        SettingRow(title:"Báo cáo buổi tập"){sheet="report"}
                        Divider().padding(.leading,16)
                        SettingRow(title:"Đăng xuất"){sheet="logout"}
                    }
                    SectionLabel(title:"Về bạn")
                    GroupCard {
                        NavigationLink{HealthProfileView()}label:{SettingRow(title:"Hồ sơ sức khỏe",chevron:true)}.buttonStyle(.plain)
                        Divider().padding(.leading,16)
                        SettingRow(title:"Xuất dữ liệu buổi tập",value:store.data.history.isEmpty ? "Chưa có buổi tập":""){exporting=true}.disabled(store.data.history.isEmpty).opacity(store.data.history.isEmpty ? 0.45:1)
                    }
                    SectionLabel(title:"Ứng dụng kết nối")
                    GroupCard {SettingRow(title:"Apple Health",value:"Chưa kết nối",icon:"heart"){sheet="health"}}
                    SectionLabel(title:"Cài đặt buổi tập")
                    GroupCard {
                        NavigationLink{NotificationSettings()}label:{SettingRow(title:"Thông báo")}.buttonStyle(.plain)
                        Divider().padding(.leading,16)
                        Toggle("Âm thanh trong app",isOn:Binding(get:{store.data.plan.sound},set:{v in store.changePlan{$0.sound=v}})).tint(Dopa.lime).padding(16)
                    }
                    GroupCard {SettingRow(title:"Ngôn ngữ",value:store.data.plan.language){sheet="language"}}.padding(.top,24)
                    SectionLabel(title:"Hỗ trợ")
                    GroupCard {
                        SettingRow(title:"Trung tâm trợ giúp",icon:"questionmark.circle"){sheet="help"}
                        Divider().padding(.leading,16)
                        SettingRow(title:"Về Dopafit",value:"1.0.0",icon:"info.circle"){sheet="about"}
                        Divider().padding(.leading,16)
                        SettingRow(title:"Xem lại thiết lập",icon:"arrow.counterclockwise"){store.data.onboarded=false;store.persist()}
                    }
                }.padding(.horizontal,16).padding(.bottom,28)
            }
        }.background(Dopa.background).toolbar(.hidden,for:.navigationBar)
            .fileExporter(isPresented:$exporting,document:CSVDocument(text:store.csvData()),contentType:.commaSeparatedText,defaultFilename:"Dopafit-Workouts"){result in if case .failure(let error)=result{store.toast=error.localizedDescription}}
            .sheet(isPresented:Binding(get:{!sheet.isEmpty},set:{if !$0{sheet=""}})){
                switch sheet {
                case "report":NavigationStack {WorkoutReportView()}
                case "language":ChoiceSheet(title:"Ngôn ngữ",choices:["Theo ngôn ngữ của máy","Tiếng Việt","English"],selected:store.data.plan.language){value in store.changePlan{$0.language=value}}
                case "health":HealthConnectionView()
                case "about":ArticleSheet(title:"Dopafit",sections:[("Dopafit Rebuild 1.0.0","Bản dựng cục bộ để đối chiếu giao diện và tác vụ. Dữ liệu lưu trên thiết bị. Cloud, subscription và thuật toán gốc chưa được cung cấp."),("Dữ liệu và minh họa bài tập","ExerciseDB / AscendAPI — https://ascendapi.com. Nguồn GIF 180p dành cho bản thử nghiệm phi thương mại; cần gói được cấp phép cho sản phẩm thương mại."),("Video Plank","ShotPot / Pexels — https://www.pexels.com/video/4117854/. Video người thật giữ Plank trên cẳng tay, dùng theo Pexels License. Không phải người hướng dẫn của Dopafit.")])
                case "logout":VStack(spacing:20){SheetTitle(title:"Đăng xuất");Text("Bản dựng này dùng hồ sơ cục bộ. Lịch sử vẫn được giữ trên thiết bị.").foregroundStyle(Dopa.muted).padding();DopaButton(title:"Về màn hình chào"){store.data.onboarded=false;store.persist();sheet=""}.padding(20)}.dopaSheet().presentationDetents([.medium])
                default:ArticleSheet(title:"Trung tâm trợ giúp",sections:[("Ghi buổi tập","Bắt đầu buổi → chọn bài → nhập reps và mức tạ → ghi set. Kết thúc và lưu để cập nhật nhật ký."),("Dữ liệu của bạn","Dữ liệu được lưu cục bộ sau các thay đổi. Có thể xuất CSV trong Cài đặt."),("Mức tạ","Tạ đòn bao gồm thanh đòn. Kiểm tra nhãn quy ước ở từng bài.")])
                }
            }
    }
}
struct PlanSettingsView:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) var dismiss
    @State private var sheet=""
    var body:some View {
        VStack(spacing:0){
            ScreenHeader(title:"Kế hoạch của tôi",back:{dismiss()})
            ScrollView {
                VStack(alignment:.leading,spacing:0) {
                    SectionLabel(title:"Mục tiêu tập luyện")
                    GroupCard{SettingRow(title:"Mục tiêu",value:store.data.plan.goal){sheet="goal"};Divider().padding(.leading,16);SettingRow(title:"Kinh nghiệm",value:store.data.plan.experience){sheet="experience"}}
                    SectionLabel(title:"Kế hoạch")
                    GroupCard {
                        SettingRow(title:"Buổi tập mỗi tuần",value:"\(store.data.plan.days) buổi"){sheet="days"}
                        Divider().padding(.leading,16)
                        SettingRow(title:"Thời lượng",value:"\(store.data.plan.minutes) phút"){sheet="duration"}
                        Divider().padding(.leading,16)
                        SettingRow(title:"Chia buổi tập",value:store.data.plan.split){sheet="split"}
                        Divider().padding(.leading,16)
                        SettingRow(title:"Độ đa dạng bài tập",value:store.data.plan.variability){sheet="variability"}
                        Divider().padding(.leading,16)
                        SettingRow(title:"Nhóm cơ ưu tiên",value:store.data.plan.focus.isEmpty ? "Không":store.data.plan.focus.joined(separator:", ")){sheet="focus"}
                    }
                    SectionLabel(title:"Phòng tập")
                    GroupCard {NavigationLink{GymSettingsView()}label:{SettingRow(title:"Dụng cụ",value:"\(store.currentGym.equipment.count) đã chọn")}.buttonStyle(.plain);Divider().padding(.leading,16);SettingRow(title:"Đơn vị tạ",value:store.unit){sheet="unit"}}
                    SectionLabel(title:"Tùy chọn")
                    GroupCard{
                        VStack(alignment:.leading,spacing:4){
                            Toggle("Chế độ nhẹ nhàng",isOn:Binding(get:{store.data.plan.gentle==true},set:{v in store.changePlan{$0.gentle=v};if store.checkinEditable {store.makeDraft(lower:store.data.lowerNext);store.toast="Đã làm lại buổi hôm nay"}})).tint(Dopa.lime)
                            Text("Ít bài hơn, 2 set mỗi bài, nghỉ lâu hơn, ưu tiên máy và tạ đơn. Hợp với người lớn tuổi hoặc ít sức.").font(.dopa(size:13)).foregroundStyle(Dopa.muted).fixedSize(horizontal:false,vertical:true)
                        }.padding(16)
                        Divider().padding(.leading,16)
                        SettingRow(title:"Cỡ chữ",value:store.data.plan.textSize ?? "Vừa"){sheet="textsize"}
                        Divider().padding(.leading,16)
                        Toggle("Set khởi động",isOn:Binding(get:{store.data.plan.warmup},set:{v in store.changePlan{$0.warmup=v}})).padding(16)
                        Divider().padding(.leading,16)
                        Toggle("Superset",isOn:Binding(get:{store.data.plan.supersets},set:{v in store.changePlan{$0.supersets=v}})).padding(16)
                        Divider().padding(.leading,16)
                        Toggle("Bài tập tính thời gian",isOn:Binding(get:{store.data.plan.timedTraining},set:{v in store.changePlan{$0.timedTraining=v}})).padding(16)
                    }.tint(Dopa.lime)
                    SectionLabel(title:"Bài tập")
                    GroupCard{SettingRow(title:"Bài không gợi ý",value:"\(store.data.preferences.values.filter{$0 == -2}.count)"){sheet="excluded"}}
                }.padding(.horizontal,16).padding(.bottom,30)
            }
        }.background(Dopa.background).toolbar(.hidden,for:.navigationBar)
            .sheet(isPresented:Binding(get:{!sheet.isEmpty},set:{if !$0{sheet=""}})){planSheet}
    }
    @ViewBuilder var planSheet:some View {
        switch sheet {
        case "goal":ChoiceSheet(title:"Mục tiêu",choices:["Tăng cơ","Khỏe hơn","Giảm mỡ","Duy trì thể lực"],selected:store.data.plan.goal){v in store.changePlan{$0.goal=v}}
        case "experience":ChoiceSheet(title:"Kinh nghiệm",choices:["Mới bắt đầu","Trung bình","Nâng cao"],selected:store.data.plan.experience){v in store.changePlan{$0.experience=v}}
        case "days":ChoiceSheet(title:"Buổi tập mỗi tuần",choices:(1...7).map{"\($0) buổi"},selected:"\(store.data.plan.days) buổi"){v in store.changePlan{$0.days=Int(v.prefix(1)) ?? 3}}
        case "duration":DurationSheet()
        case "split":ChoiceSheet(title:"Chia buổi tập",choices:["Tự động","Toàn thân","Thân trên / Thân dưới","Đẩy / Kéo / Chân"],selected:store.data.plan.split,detail:"Chia buổi tập giúp phân bố các nhóm cơ giữa các ngày. Chọn lịch phù hợp với số buổi mỗi tuần."){v in store.changePlan{$0.split=v}}
        case "variability":ChoiceSheet(title:"Độ đa dạng bài tập",choices:["Ít thay đổi","Cân bằng","Đa dạng"],selected:store.data.plan.variability){v in store.changePlan{$0.variability=v}}
        case "textsize":ChoiceSheet(title:"Cỡ chữ",choices:DopaText.options.map(\.0),selected:store.data.plan.textSize ?? "Vừa"){v in store.changePlan{$0.textSize=v}}.dopaSheet().presentationDetents([.medium])
        case "unit":ChoiceSheet(title:"Đơn vị tạ",choices:["kg","lb"],selected:store.unit){v in store.changePlan{$0.unit=v}}
        case "focus":VStack{SheetTitle(title:"Nhóm cơ ưu tiên");ForEach(Catalog.muscleNames,id:\.self){m in Toggle(m,isOn:Binding(get:{store.data.plan.focus.contains(m)},set:{v in store.changePlan{if v{$0.focus.append(m)}else{$0.focus.removeAll{$0==m}}}})).tint(Dopa.lime).padding(.horizontal,24)};Spacer()}.background(Dopa.background)
        default:VStack{SheetTitle(title:"Bài không gợi ý");ForEach(Catalog.all.filter{store.data.preferences[$0.id] == -2}){ex in SettingRow(title:ex.name,value:"Khôi phục"){store.setPreference(ex.id,0)}};Spacer()}.background(Dopa.background)
        }
    }
}
struct GymSelector:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) var dismiss
    @State private var adding=false
    @State private var name=""
    @State private var editing:GymProfile?=nil
    var body:some View {
        VStack(spacing:20){
            SheetTitle(title:"Nơi tập")
            ForEach(store.data.gyms){gym in HStack {
                Button{store.data.gymID=gym.id;store.persist();dismiss()}label:{HStack{Text(gym.name);Spacer();if store.currentGym.id==gym.id{Image(systemName:"checkmark").foregroundStyle(Dopa.lime)}}.foregroundStyle(.white).padding(20)}.buttonStyle(.plain)
                Button{editing=gym}label:{Image(systemName:"ellipsis").foregroundStyle(.white).frame(width:44,height:52)}.accessibilityLabel("Quản lý \(gym.name)")
            }.background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14)).padding(.horizontal,16)}
            if !store.data.gyms.contains(where:{$0.locationType=="home"}) {
                DopaButton(title:"Thêm nơi tập Ở nhà",icon:"house",secondary:true){
                    let home=GymProfile(name:"Ở nhà",locationType:"home",equipment:["Cặp tạ đơn","Dây kháng lực","Trọng lượng cơ thể","Ghế tập"],dumbbells:[2.5,5,7.5,10,12.5,15,17.5,20])
                    store.data.gyms.append(home);store.data.gymID=home.id;store.makeDraft();store.persist();dismiss()
                }.padding(.horizontal,20)
                Text("Tạ đơn đến 20 kg, dây kháng lực và bài không dụng cụ. Chỉnh lại trong ⋯ nếu nhà bạn có khác.").font(.dopa(size:13)).foregroundStyle(Dopa.muted).padding(.horizontal,24)
            }
            DopaButton(title:"Thêm phòng tập",icon:"plus",secondary:true){adding=true}.padding(.horizontal,20)
            Spacer()
        }.dopaSheet().presentationDetents([.medium,.large]).alert("Thêm phòng tập",isPresented:$adding){TextField("Tên phòng tập",text:$name);Button("Thêm"){let gym=GymProfile(name:name.isEmpty ? "Phòng tập mới":name);store.data.gyms.append(gym);store.data.gymID=gym.id;store.persist();name=""};Button("Huỷ",role:.cancel){}}
            .sheet(item:$editing) { gym in GymManagementView(gymID:gym.id) }
    }
}
struct GymManagementView:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) var dismiss
    var gymID:UUID
    @State private var rename=false
    @State private var location=false
    @State private var name=""
    var gym:GymProfile? {store.data.gyms.first{$0.id==gymID}}
    var body:some View {
        VStack(alignment:.leading,spacing:16) {
            SheetTitle(title:gym?.name ?? "Nơi tập")
            GroupCard {
                SettingRow(title:"Đổi tên") { name=gym?.name ?? "";rename=true }
                Divider().padding(.leading,16)
                SettingRow(title:"Đổi loại nơi tập",value:gym?.locationType ?? "") {location=true}
                Divider().padding(.leading,16)
                Button("Xóa",role:.destructive) {if store.removeGym(gymID){dismiss()}}.frame(maxWidth:.infinity,alignment:.leading).padding(16).disabled(store.data.gyms.count<=1)
            }.padding(.horizontal,16)
            if store.data.gyms.count<=1 {Text("Bạn cần giữ ít nhất một nơi tập.").foregroundStyle(Dopa.muted).padding(.horizontal,16)}
            Spacer(minLength:0)
        }.dopaSheet().presentationDetents([.height(340)])
            .alert("Đổi tên",isPresented:$rename) {TextField("Tên nơi tập",text:$name);Button("Lưu"){store.renameGym(gymID,to:name)};Button("Hủy",role:.cancel){}}
            .sheet(isPresented:$location) {ChoiceSheet(title:"Đổi loại nơi tập",choices:["Tại nhà","Phòng tập nhỏ","Sân calisthenics","Phòng gym"],selected:gym?.locationType ?? "Phòng gym") {value in if let i=store.data.gyms.firstIndex(where:{$0.id==gymID}) {store.data.gyms[i].locationType=value;store.persist()}}}
    }
}
struct GymSettingsView:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) var dismiss
    @State private var query=""
    @State private var weights=false
    var body:some View {
        VStack(spacing:12){
            ScreenHeader(title:"Dụng cụ phòng tập",back:{dismiss()})
            TextField("Tìm dụng cụ",text:$query).padding(14).background(Dopa.card).clipShape(Capsule()).padding(.horizontal,16)
            ScrollView {
                VStack(alignment:.leading,spacing:16){
                    Text("\(store.currentGym.equipment.count) dụng cụ được chọn").foregroundStyle(Dopa.muted)
                    ForEach(Catalog.equipment.filter{query.isEmpty || $0.localizedCaseInsensitiveContains(query)},id:\.self){gear in
                        HStack {
                            Toggle(gear,isOn:Binding(get:{store.currentGym.equipment.contains(gear)},set:{v in
                                if let i=store.data.gyms.firstIndex(where:{$0.id==store.currentGym.id}){if v{store.data.gyms[i].equipment.append(gear)}else{store.data.gyms[i].equipment.removeAll{$0==gear}};store.persist()}
                            })).tint(Dopa.lime)
                            if ["Cặp tạ đơn","Tạ đòn","Bánh tạ"].contains(gear){Button{weights=true}label:{Image(systemName:"slider.horizontal.3").foregroundStyle(Dopa.muted)}}
                        }.padding(16).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
                    }
                }.padding(16)
            }
        }.background(Dopa.background).toolbar(.hidden,for:.navigationBar).sheet(isPresented:$weights){WeightIncrementsView()}
    }
}
struct WeightIncrementsView:View {
    @EnvironmentObject var store:AppStore
    @State private var custom=""
    var body:some View {
        ScrollView{
            VStack(alignment:.leading,spacing:18){
                SheetTitle(title:"Cặp tạ đơn")
                Text("Chọn các mức tạ có tại phòng tập của bạn.").foregroundStyle(Dopa.muted)
                LazyVGrid(columns:[GridItem(.adaptive(minimum:80))],spacing:10){ForEach(stride(from:2.5,through:50,by:2.5).map{$0},id:\.self){w in
                    Button{mutate{gym in if gym.dumbbells.contains(w){gym.dumbbells.removeAll{$0==w}}else{gym.dumbbells.append(w)}}}label:{Text("\(store.weight(w)) \(store.unit)").frame(maxWidth:.infinity).padding(.vertical,15).background(store.currentGym.dumbbells.contains(w) ? Dopa.lime:Dopa.raised).foregroundStyle(store.currentGym.dumbbells.contains(w) ? .black:.white).clipShape(Capsule())}
                }}
                HStack{TextField("Mức tạ khác",text:$custom).keyboardType(.decimalPad).padding(14).background(Dopa.card).clipShape(Capsule());Button("Thêm"){if let value=Double(custom.replacingOccurrences(of:",",with:".")),value>0{mutate{$0.dumbbells.append(store.kilograms(value))};custom=""}}}
                Text("Tạ đòn").font(.dopa(size:22,weight:.bold))
                Picker("Khối lượng thanh đòn",selection:Binding(get:{store.currentGym.barWeight},set:{v in mutate{$0.barWeight=v}})){ForEach([10.0,15,20,20.41165665,25],id:\.self){w in Text("\(store.weight(w)) \(store.unit)").tag(w)}}.pickerStyle(.menu)
            }.padding(20)
        }.background(Dopa.background)
    }
    func mutate(_ f:(inout GymProfile)->Void){if let i=store.data.gyms.firstIndex(where:{$0.id==store.currentGym.id}){f(&store.data.gyms[i]);store.persist()}}
}
struct HealthProfileView:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) var dismiss
    @State private var field=""
    @State private var value=""
    var body:some View {
        VStack(spacing:0){
            ScreenHeader(title:"Hồ sơ sức khỏe",back:{dismiss()})
            ScrollView{
                VStack(alignment:.leading,spacing:24){
                    InfoCard(title:"Đồng bộ với Apple Health",text:"Bài, số rep và mức tạ hợp với cơ thể bạn\nƯớc tính năng lượng tiêu hao\nTheo dõi tiến bộ của cơ thể\nDữ liệu chỉ dùng để điều chỉnh buổi tập của bạn",icon:"heart")
                    NavigationLink{HealthConnectionView()}label:{SettingRow(title:"Apple Health",value:"Chưa kết nối",icon:"heart")}.background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
                    Text("HOẶC").foregroundStyle(Dopa.muted).frame(maxWidth:.infinity)
                    Text("Nhập tay").dopaTitle(25)
                    Text("Không bắt buộc, bạn có thể thêm sau.").foregroundStyle(Dopa.muted)
                    GroupCard{
                        SettingRow(title:"Giới tính",value:store.data.plan.gender){field="gender"}
                        Divider()
                        SettingRow(title:"Ngày sinh",value:store.data.plan.birthDate?.formatted(date:.abbreviated,time:.omitted) ?? ""){field="birth"}
                        Divider()
                        SettingRow(title:"Chiều cao",value:"\(Int(store.data.plan.height)) cm"){value=String(store.data.plan.height);field="height"}
                        Divider()
                        SettingRow(title:"Cân nặng hiện tại",value:"\(AppStore.number(store.data.plan.bodyWeight)) kg"){value=String(store.data.plan.bodyWeight);field="weight"}
                    }
                }.padding(16)
            }
        }.background(Dopa.background).toolbar(.hidden,for:.navigationBar)
            .sheet(isPresented:Binding(get:{!field.isEmpty},set:{if !$0{field=""}})){
                if field=="gender"{ChoiceSheet(title:"Giới tính",choices:["Nam","Nữ","Khác"],selected:store.data.plan.gender){v in store.changePlan{$0.gender=v}}}
                else if field=="birth"{VStack{SheetTitle(title:"Ngày sinh");DatePicker("Ngày sinh",selection:Binding(get:{store.data.plan.birthDate ?? Date(timeIntervalSince1970:946684800)},set:{v in store.changePlan{$0.birthDate=v}}),in:...Date(),displayedComponents:.date).datePickerStyle(.wheel).labelsHidden()}.dopaSheet().presentationDetents([.medium])}
                else{VStack(spacing:20){SheetTitle(title:field=="height" ? "Chiều cao":"Cân nặng");TextField("Giá trị",text:$value).keyboardType(.decimalPad).font(.largeTitle).multilineTextAlignment(.center);DopaButton(title:"Lưu"){if let n=Double(value.replacingOccurrences(of:",",with:".")),n>0{store.changePlan{if field=="height"{$0.height=n}else{$0.bodyWeight=n}};field=""}}.padding()}.dopaSheet().presentationDetents([.medium])}
            }
    }
}
struct NotificationSettings:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) var dismiss
    @State private var message=""
    var body:some View {
        VStack(spacing:24){
            ScreenHeader(title:"Thông báo",back:{dismiss()})
            Text("Nhắc lịch tập").dopaTitle(30)
            HStack{ForEach(1...7,id:\.self){day in Button{if store.data.plan.notificationDays.contains(day){store.data.plan.notificationDays.removeAll{$0==day}}else{store.data.plan.notificationDays.append(day)};store.persist()}label:{Text(["CN","T2","T3","T4","T5","T6","T7"][day-1]).font(.dopa(size:13)).frame(maxWidth:.infinity).frame(height:42).background(store.data.plan.notificationDays.contains(day) ? Dopa.lime:Dopa.raised).foregroundStyle(store.data.plan.notificationDays.contains(day) ? .black:.white).clipShape(Circle())}}}.padding(.horizontal,16)
            Picker("Giờ nhắc",selection:Binding(get:{store.data.plan.reminderHour},set:{v in store.changePlan{$0.reminderHour=v}})){ForEach(0..<24){h in Text(String(format:"%02d:00",h)).tag(h)}}.pickerStyle(.wheel).frame(height:170)
            DopaButton(title:"Lưu nhắc nhở"){
                Task{
                    let center=UNUserNotificationCenter.current()
                    do{
                        let granted=try await center.requestAuthorization(options:[.alert,.sound,.badge])
                        guard granted else{message="Thông báo chưa được cho phép.";return}
                        center.removePendingNotificationRequests(withIdentifiers:(1...7).map{"dopafit.day.\($0)"})
                        for day in store.data.plan.notificationDays{
                            let content=UNMutableNotificationContent();content.title="Đến giờ tập rồi!";content.body="Buổi tập tiếp theo đang chờ bạn trong Dopafit.";content.sound = .default
                            var date=DateComponents();date.weekday=day;date.hour=store.data.plan.reminderHour
                            try await center.add(UNNotificationRequest(identifier:"dopafit.day.\(day)",content:content,trigger:UNCalendarNotificationTrigger(dateMatching:date,repeats:true)))
                        }
                        message="Đã lưu nhắc nhở."
                    }catch{message=error.localizedDescription}
                }
            }.padding(.horizontal,20)
            Text(message).foregroundStyle(Dopa.muted)
            Spacer()
        }.background(Dopa.background).toolbar(.hidden,for:.navigationBar)
    }
}
struct HealthConnectionView:View {
    @State private var status="Chưa kết nối"
    private let health=HKHealthStore()
    var body:some View {
        VStack(spacing:24){
            SheetTitle(title:"Apple Health")
            Image(systemName:"heart.fill").font(.dopa(size:60)).foregroundStyle(.pink).padding(.top,40)
            Text("Kết nối Apple Health").dopaTitle(26)
            Text("Cho phép đọc chiều cao, cân nặng và lưu buổi tập vào ứng dụng Sức khỏe. Bạn kiểm soát từng quyền trong hộp thoại của iOS.").foregroundStyle(Dopa.muted).multilineTextAlignment(.center).padding(.horizontal,24)
            Text(status).font(.footnote).foregroundStyle(Dopa.muted)
            DopaButton(title:"Kết nối"){Task{guard HKHealthStore.isHealthDataAvailable()else{status="Thiết bị này không hỗ trợ Health.";return};do{try await health.requestAuthorization(toShare:[HKObjectType.workoutType()],read:[HKObjectType.quantityType(forIdentifier:.bodyMass)!,HKObjectType.quantityType(forIdentifier:.height)!]);status="Đã hoàn tất yêu cầu quyền."}catch{status=error.localizedDescription}}}.padding(.horizontal,20)
            Spacer()
        }.background(Dopa.background)
    }
}
