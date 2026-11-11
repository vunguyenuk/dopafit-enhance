import SwiftUI

// R19–R36: observed manual-input branch. Account/subscription services remain separate.
struct SetupOnboardingView: View {
    @EnvironmentObject var store: AppStore
    var back: () -> Void
    @State private var page = 0
    @State private var help = false
    @State private var health = false
    @State private var reminders = false
    @State private var activitySheet = false
    @State private var age = "25–34"
    @State private var selectedAge = false
    @State private var selectedGender = false
    @State private var imperial = false
    @State private var height = 170.0
    @State private var bodyWeight = 68.0
    @State private var focus: Set<String> = []
    @State private var rear = false
    @State private var location = "Phòng gym"
    @State private var equipment: Set<String> = Set(Catalog.equipment)
    @State private var days = 0
    @State private var weekdays: Set<Int> = []
    @State private var minutes = 0
    @State private var reminderHour = 18
    @State private var other = ""
    @State private var activity = "Chạy bộ"
    @State private var activityDays = 1
    @State private var effort = "Vừa"
    @State private var preferred = "Không ưu tiên"
    @State private var saveGate = false
    @State private var postSetup = false

    var body: some View {
        VStack(spacing: 0) {
            if page != 0 && page != 15 { header }
            content
        }
        .sheet(isPresented: $help) {
            ArticleSheet(title: "Vì sao chỉ ưu tiên 2 nhóm?", sections: [
                ("Cơ tăng theo số set", "Mỗi nhóm được phân bổ thêm số set trong tuần, trong giới hạn khả năng hồi phục."),
                ("Sức hồi phục có hạn", "Các nhóm còn lại vẫn được tập. Ưu tiên nhiều nhóm sẽ chia nhỏ số set bổ sung."),
                ("Lựa chọn của bạn", "Chọn tối đa hai nhóm hoặc phát triển cân bằng. Bạn có thể đổi lại trong kế hoạch.")])
        }
        .sheet(isPresented: $health) { HealthConnectionView() }
        .sheet(isPresented: $reminders) { NotificationSettings() }
        .sheet(isPresented: $activitySheet) { activityDetail }
        .fullScreenCover(isPresented:$saveGate) { OnboardingSaveGate { saveGate=false;finish() } }
        .fullScreenCover(isPresented:$postSetup) { PostSetupFlow { store.data.onboarded=true;store.persist() } }
    }
    var header: some View {
        HStack(spacing: 12) {
            CircleButton(icon: "chevron.left") { previous() }
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(page < 7 ? "VỀ BẠN" : "NHỊP TẬP").font(.dopa(size: 12, weight: .bold)).tracking(1)
                    Spacer()
                    if [4,5,6,14].contains(page) { Button("BỎ QUA") { next() }.foregroundStyle(.white) }
                }
                HStack(spacing: 5) {
                    ForEach(0..<3) { i in
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule().fill(.white.opacity(0.25))
                                Capsule().fill(Dopa.lime).frame(width: g.size.width * min(1,max(0,Double(page + 9 - i*8)/8)))
                            }
                        }.frame(height: 4)
                    }
                }
            }
        }.padding(.horizontal,16).padding(.top,14).padding(.bottom,22)
    }
    @ViewBuilder var content: some View {
        switch page {
        case 0: recovery
        case 1: privacy
        case 2: healthChoice
        case 3: ageChoice
        case 4: genderChoice
        case 5,6: measurement
        case 7: focusChoice
        case 8: locationChoice
        case 9: equipmentChoice
        case 10: daysChoice
        case 11: durationChoice
        case 12: reminderChoice
        case 13,14: otherChoice
        default: review
        }
    }
    func title(_ value: String, detail: String = "") -> some View {
        VStack(alignment:.leading,spacing:14) {
            Text(value).dopaTitle(32).fixedSize(horizontal:false,vertical:true)
            if !detail.isEmpty { Text(detail).font(.dopa(size:18)).foregroundStyle(Dopa.muted).fixedSize(horizontal:false,vertical:true) }
        }.frame(maxWidth:.infinity,alignment:.leading).padding(.horizontal,16)
    }
    func footer(_ label: String = "Tiếp tục", enabled: Bool = true, action: (() -> Void)? = nil) -> some View {
        DopaButton(title:label,enabled:enabled) { if let action { action() } else { next() } }.padding(16)
    }
    var recovery: some View {
        VStack(spacing:18) {
            HStack { CircleButton(icon:"chevron.left") { back() }; Spacer() }.padding(16)
            OpenGymBodyView(heat:["Ngực":0.7,"Tay sau":0.4]).allowsHitTesting(false).frame(maxWidth:.infinity,maxHeight:.infinity)
            Text("Biết nhóm cơ nào\nđã sẵn sàng.").dopaTitle(30).multilineTextAlignment(.center)
            Text("Sau mỗi buổi, Dopafit theo dõi từng nhóm cơ hồi phục và ưu tiên nhóm đã khỏe cho buổi sau.").font(.dopa(size:18)).foregroundStyle(Dopa.muted).multilineTextAlignment(.center).padding(.horizontal,24)
            Spacer(minLength:35)
            footer("Tiếp tục thiết lập")
        }
    }
    var privacy: some View {
        VStack(alignment:.leading,spacing:22) {
            Image(systemName:"heart.square.fill").font(.dopa(size:90)).foregroundStyle(.pink).frame(maxWidth:.infinity)
            title("Dữ liệu sức khoẻ của bạn\nluôn an toàn")
            VStack(spacing:10) {
                privacyRow("Không bán, không quảng cáo","Dữ liệu từ Apple Health không dùng để quảng cáo.","nosign")
                privacyRow("Chỉ để phục vụ bạn","Dùng để lên kế hoạch tập vừa với bạn.","scope")
                privacyRow("Bạn nắm quyền","Chỉ đọc chỉ số bạn cho phép. Tắt bất cứ lúc nào.","slider.horizontal.3")
            }.padding(.horizontal,16)
            Spacer()
            footer()
        }
    }
    func privacyRow(_ name:String,_ detail:String,_ icon:String)->some View {
        HStack(spacing:14) {
            Image(systemName:icon).font(.title2).frame(width:36)
            VStack(alignment:.leading,spacing:3) { Text(name).font(.dopa(size:18,weight:.semibold));Text(detail).foregroundStyle(Dopa.muted).font(.dopa(size:16)) }
            Spacer(minLength:0)
            Image(systemName:"checkmark.circle.fill").foregroundStyle(Dopa.blue)
        }.padding(16).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
    }
    var healthChoice: some View {
        VStack(alignment:.leading,spacing:20) {
            title("Lấy nhanh chỉ số từ\nApple Health",detail:"Để plan vừa với bạn. Khỏi nhập tay, vẫn sửa được ở bước sau.")
            Spacer()
            Text("DOPAFIT ĐỌC").font(.caption.bold()).foregroundStyle(Dopa.muted).padding(.horizontal,16)
            LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:8) {
                ForEach(["Giới tính","Tuổi","Chiều cao","Cân nặng"],id:\.self) { name in
                    VStack(alignment:.leading,spacing:10) { Text(name);Text("–").font(.title2) }.foregroundStyle(Dopa.muted).frame(maxWidth:.infinity,alignment:.leading).padding(18).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
                }
            }.padding(.horizontal,16)
            InfoCard(title:"Mỗi buổi tập bạn hoàn thành",text:"Lưu vào Apple Health dưới dạng Tập sức mạnh",icon:"dumbbell.fill").padding(.horizontal,16)
            Spacer()
            Button("Tự nhập") { next() }.font(.dopa(size:20,weight:.semibold)).foregroundStyle(.white).frame(maxWidth:.infinity)
            footer("Kết nối Apple Health",action:{health=true})
        }
    }
    var ageChoice: some View {
        VStack(spacing:18) {
            title("Bạn thuộc nhóm\ntuổi nào?",detail:"Nhóm tuổi sẽ được lưu vào hồ sơ tập của bạn.")
            Spacer()
            Picker("Nhóm tuổi",selection:$age) {
                ForEach(["Dưới 18","18–24","25–34","35–44","45–54","55+","Không muốn trả lời"],id:\.self) { Text($0).dopaTitle(30).tag($0) }
            }.pickerStyle(.wheel).frame(height:260).onChange(of:age) { _,_ in selectedAge=true }
            Button(age) { selectedAge=true }.font(Dopa.metricFont(52)).foregroundStyle(selectedAge ? .black:.white).padding(20).background(selectedAge ? .white:Dopa.card).clipShape(Capsule())
            Spacer()
            footer(enabled:selectedAge,action:{store.changePlan{$0.ageGroup=age};next()})
        }
    }
    var genderChoice: some View {
        VStack(spacing:22) {
            title("Giới tính của bạn?")
            Spacer()
            Image(systemName:store.data.plan.gender=="Nam" ? "figure.stand":"figure.stand.dress").font(.dopa(size:150,weight:.light)).frame(height:170)
            HStack { ForEach(["Nam","Nữ"],id:\.self) { value in
                selection(value,selected:selectedGender && store.data.plan.gender==value) { store.changePlan{$0.gender=value};selectedGender=true }
            }}.padding(.horizontal,16)
            confidentiality
            Spacer()
            footer(enabled:selectedGender)
        }
    }
    var confidentiality: some View {
        VStack(alignment:.leading,spacing:16) {
            Label("Thông tin của bạn được bảo mật, không bán hay dùng để quảng cáo.",systemImage:"checkmark.shield")
            Label("Lưu vào hồ sơ của bạn, sửa được bất cứ lúc nào.",systemImage:"info.circle")
        }.font(.dopa(size:16)).foregroundStyle(Dopa.muted).padding(18).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14)).padding(.horizontal,16)
    }
    var measurement: some View {
        VStack(spacing:20) {
            title(page==5 ? "Bạn cao bao nhiêu?":"Cân nặng hiện tại?")
            Spacer()
            Picker("Đơn vị",selection:$imperial) {
                Text(page==5 ? "Centimet (cm)":"Kilogram (kg)").tag(false)
                Text(page==5 ? "Feet và inch (ft/in)":"Pound (lb)").tag(true)
            }.pickerStyle(.segmented).padding(.horizontal,16)
            Spacer()
            HStack(alignment:.firstTextBaseline,spacing:6) {
                Text(measurementText).font(Dopa.metricFont(88)).monospacedDigit()
                Text(page==5 ? (imperial ? "ft/in":"cm"):(imperial ? "lb":"kg")).font(.dopa(size:28,weight:.semibold))
            }
            Text("Kéo thước để chọn").font(.footnote).foregroundStyle(Dopa.muted)
            MeasurementRuler(value:page==5 ? $height:$bodyWeight,range:page==5 ? 100...230:30...200,step:imperial ? (page==5 ? 2.54:1/2.2046226218):1,majorEvery:page==5 ? 10:5).frame(height:85).padding(.horizontal,16)
            confidentiality
            Spacer()
            footer(action:{store.changePlan { if page==5 {$0.height=height} else {$0.bodyWeight=bodyWeight} };next()})
        }
    }
    var measurementText:String {
        if page==5 { if imperial { let inches=Int((height/2.54).rounded());return "\(inches/12)′ \(inches%12)″" };return "\(Int(height))" }
        return "\(Int((imperial ? bodyWeight*2.2046226218:bodyWeight).rounded()))"
    }
    var focusChoice: some View {
        VStack(spacing:12) {
            title("Bạn muốn ưu tiên nhóm\ncơ nào?",detail:"Chọn 1–2 nhóm để tập thêm. Các nhóm khác vẫn được tập đều.")
            Button("ⓘ Vì sao tối đa 2 nhóm?") { help=true }.font(.dopa(size:16)).underline().foregroundStyle(Dopa.muted).frame(maxWidth:.infinity,alignment:.leading).padding(.horizontal,16)
            OpenGymBodyView(heat:Dictionary(uniqueKeysWithValues:focus.filter{$0 != "Cân bằng"}.flatMap{muscle in muscle=="Tay" ? ["Tay trước","Tay sau"]:muscle=="Chân" ? ["Đùi trước","Đùi sau","Bắp chân"]:[muscle]}.map{($0,1.0)}),rear:rear).frame(maxWidth:.infinity).frame(maxHeight:.infinity)
            Picker("Mặt cơ thể",selection:$rear) {Text("Mặt trước").tag(false);Text("Mặt sau").tag(true)}.pickerStyle(.segmented).frame(width:240)
            LazyVGrid(columns:Array(repeating:GridItem(.flexible()),count:4),spacing:8) {
                ForEach(["Cân bằng","Ngực","Lưng","Vai","Tay","Bụng","Mông","Chân"],id:\.self) { muscle in
                    selection(muscle,selected:focus.contains(muscle)) {
                        if muscle=="Cân bằng" {focus=[muscle]}
                        else if focus.contains(muscle) {focus.remove(muscle)}
                        else {focus.remove("Cân bằng");if focus.count<2{focus.insert(muscle)}}
                    }
                }
            }.padding(.horizontal,16)
            Spacer(minLength:20)
            footer("Xác nhận",enabled:!focus.isEmpty,action:{store.changePlan{$0.focus=expandedFocus};next()})
        }
    }
    var expandedFocus:[String] {
        focus.flatMap { value -> [String] in switch value {case "Cân bằng":return [];case "Tay":return ["Tay trước","Tay sau"];case "Chân":return ["Đùi trước","Đùi sau","Bắp chân"];default:return [value]} }
    }
    var locationChoice: some View {
        VStack(spacing:20) {
            title("Bạn tập ở đâu?",detail:"Bài tập sẽ hợp với dụng cụ ở đó.")
            Spacer(minLength:15)
            LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:9) {
                ForEach(Array(["Tại nhà","Phòng tập nhỏ","Sân calisthenics","Phòng gym"].enumerated()),id:\.offset) { i,name in
                    Button {
                        location=name
                        equipment=Set(name=="Phòng gym" ? Catalog.equipment:name=="Tại nhà" ? ["Cặp tạ đơn","Dây kháng lực","Trọng lượng cơ thể"]:["Tạ đòn","Cặp tạ đơn","Trọng lượng cơ thể"])
                        next()
                    } label: {
                        VStack(alignment:.leading,spacing:10) {
                            Text(name).font(.dopa(size:22,weight:.semibold))
                            Text(["Tạ đơn, dây kháng lực, xà đơn","Tạ đòn, tạ đơn, ghế, khung squat","Xà đơn, xà kép, vòng treo","Máy, cáp và tạ tự do"][i]).font(.dopa(size:17)).foregroundStyle(Dopa.muted)
                            Spacer(minLength:10)
                            ReferenceCrop(asset:"reference-onboard-location",rect:locationRect(i)).frame(height:100)
                        }.padding(16).frame(height:245).frame(maxWidth:.infinity,alignment:.leading).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14)).foregroundStyle(.white)
                    }.buttonStyle(.plain)
                }
            }.padding(.horizontal,16)
            Spacer()
        }
    }
    func locationRect(_ i:Int)->[Double] { switch i {case 0:return [150,930,250,200];case 1:return [530,930,250,200];case 2:return [150,1380,250,215];default:return [530,1380,250,215]} }
    var equipmentChoice: some View {
        VStack(alignment:.leading,spacing:12) {
            title("Bạn có những dụng\ncụ nào?",detail:"Đã chọn sẵn những gì nơi bạn tập thường có. Bỏ chọn món bạn không có, chọn thêm món bạn có.")
            HStack {Text("Đã chọn \(equipment.count)");Spacer();Button("Chọn hết"){equipment=Set(Catalog.equipment)};Button("Bỏ chọn hết"){equipment=[]}}.font(.dopa(size:15)).padding(.horizontal,16)
            ScrollView { VStack(spacing:8) { ForEach(Catalog.equipment,id:\.self) { gear in
                Button { if equipment.contains(gear){equipment.remove(gear)}else{equipment.insert(gear)} } label: {
                    HStack {Image(systemName:"dumbbell.fill");Text(gear);Spacer();Image(systemName:equipment.contains(gear) ? "checkmark.square.fill":"square")}.foregroundStyle(.white).font(.dopa(size:18)).padding(18).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
                }.buttonStyle(.plain)
            }}.padding(.horizontal,16) }
            footer("Xác nhận",enabled:!equipment.isEmpty,action:{store.data.gyms[0].name=location;store.data.gyms[0].equipment=Array(equipment);store.persist();next()})
        }
    }
    var daysChoice: some View {
        VStack(spacing:22) {
            title("Mỗi tuần, bạn muốn tập\nmấy buổi?")
            Spacer()
            HStack(spacing:6) { ForEach(1...7,id:\.self) { n in selection("\(n)",selected:days==n) {days=n;weekdays=Set(defaultDays(n))} } }.padding(.horizontal,16)
            schedule
            Spacer()
            footer(enabled:days>0 && weekdays.count==days,action:{store.changePlan{$0.days=days;$0.trainingDays=weekdays.sorted()};next()})
        }
    }
    func defaultDays(_ count:Int)->[Int] { Array([2,4,6,3,5,7,1].prefix(count)) }
    var schedule: some View {
        VStack(alignment:.leading,spacing:26) {
            HStack(alignment:.firstTextBaseline) {Text("\(days)").font(Dopa.metricFont(70));VStack(alignment:.leading){Text("buổi / tuần").font(.dopa(size:22,weight:.bold));Text("\(days) ngày tập · \(7-days) ngày nghỉ").foregroundStyle(Dopa.muted)}}
            HStack(alignment:.bottom,spacing:6) {
                ForEach([2,3,4,5,6,7,1],id:\.self) { day in
                    Button {if weekdays.contains(day){weekdays.remove(day)}else if weekdays.count<days{weekdays.insert(day)}} label: {
                        VStack(spacing:9) {RoundedRectangle(cornerRadius:2).fill(weekdays.contains(day) ? Dopa.lime:Dopa.raised).frame(height:weekdays.contains(day) ? 46:14).overlay {if weekdays.contains(day){Image(systemName:"checkmark").foregroundStyle(.black)}};Text(day==1 ? "CN":"T\(day)").font(.dopa(size:13)).foregroundStyle(Dopa.muted)}
                    }.frame(maxWidth:.infinity).buttonStyle(.plain)
                }
            }.frame(height:75,alignment:.bottom)
            Text(days==0 ? "Lịch tuần của bạn sẽ hiện ở đây khi bạn chọn số buổi.":"Đã chọn \(weekdays.count) ngày tập · \(weekdays.count)/\(days)").foregroundStyle(Dopa.muted).font(.dopa(size:16))
        }.padding(22).frame(maxWidth:.infinity,alignment:.leading).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14)).padding(.horizontal,16)
    }
    var durationChoice: some View {
        VStack(spacing:25) {
            title("Bạn có bao nhiêu thời\ngian cho mỗi buổi?",detail:"Đã gồm khởi động và nghỉ giữa các set.")
            Spacer()
            ZStack {Circle().stroke(Dopa.raised,lineWidth:12).frame(width:170,height:170);VStack{Text(minutes==0 ? "–":"\(minutes)").font(Dopa.metricFont(64));Text("phút / buổi").foregroundStyle(Dopa.muted)}}
            HStack(spacing:7) {ForEach([15,30,45,60,90],id:\.self) { n in selection("\(n) phút",selected:minutes==n){minutes=n} }}.padding(.horizontal,16)
            Spacer()
            footer(enabled:minutes>0,action:{store.changePlan{$0.minutes=minutes};next()})
        }
    }
    var reminderChoice: some View {
        VStack(alignment:.leading,spacing:22) {
            title("Nhắc bạn vào ngày\ntập nhé?",detail:"Chỉ nhắc vào ngày đã chọn, tối đa một lần mỗi ngày.")
            Spacer()
            Text("NHẮC LÚC").font(.caption.bold()).foregroundStyle(Dopa.muted).padding(.horizontal,16)
            HStack(spacing:7) {ForEach([8,12,17,18,20],id:\.self){hour in selection(String(format:"%02d:00",hour),selected:reminderHour==hour){reminderHour=hour}}}.padding(.horizontal,16)
            Text("Đổi giờ hoặc tắt bất cứ lúc nào trong Tài khoản → Thông báo.").font(.dopa(size:16)).foregroundStyle(Dopa.muted).padding(.horizontal,16)
            Spacer().frame(height:25)
            Button("Để sau"){next()}.font(.dopa(size:20,weight:.semibold)).foregroundStyle(.white).frame(maxWidth:.infinity)
            footer("Bật nhắc nhở",action:{store.changePlan{$0.notificationDays=weekdays.sorted();$0.reminderHour=reminderHour};reminders=true})
            Button("Tiếp tục") { next() }.foregroundStyle(Dopa.muted).frame(maxWidth:.infinity).padding(.bottom,12)
        }
    }
    var otherChoice: some View {
        VStack(spacing:22) {
            title("Ngoài các buổi tập này,\nbạn còn vận động gì?",detail:"Để tính cả thể thao và lao động chân tay trong tuần.")
            Spacer()
            VStack(spacing:8) {
                selection("⊖ Không có gì khác",selected:other=="Không có gì khác"){other="Không có gì khác"}
                selection("Có vận động khác",selected:other=="Có vận động khác"){other="Có vận động khác"}
            }.padding(.horizontal,16)
            Spacer()
            footer(enabled:!other.isEmpty,action:{if other=="Có vận động khác"{activitySheet=true}else{store.changePlan{$0.otherActivity=other};page=15}})
        }
    }
    var activityDetail: some View {
        ScrollView { VStack(alignment:.leading,spacing:20) {
            SheetTitle(title:"Hoạt động khác")
            Text("Chọn hoạt động chính nếu bạn có nhiều loại.").foregroundStyle(Dopa.muted)
            ForEach(["Chạy bộ","Đạp xe","Chơi thể thao","Lao động chân tay","Khác"],id:\.self){name in selection(name,selected:activity==name){activity=name}}
            Text("SỐ NGÀY MỖI TUẦN").font(.caption.bold()).foregroundStyle(Dopa.muted)
            HStack {ForEach(1...7,id:\.self){n in selection("\(n)",selected:activityDays==n){activityDays=n}}}
            Text("MỨC ĐỘ BẠN CẢM NHẬN").font(.caption.bold()).foregroundStyle(Dopa.muted)
            HStack {ForEach(["Nhẹ","Vừa","Nặng"],id:\.self){value in selection(value,selected:effort==value){effort=value}}}
            footer("Lưu",action:{store.changePlan{$0.otherActivity="\(activity) · \(activityDays) ngày · \(effort)"};activitySheet=false;page=15})
        }.padding(16) }.background(Dopa.background)
    }
    var review: some View {
        VStack(spacing:0) {
            ScrollView { VStack(alignment:.leading,spacing:18) {
                title("Thiết lập của bạn",detail:"Xem lại và chỉnh lựa chọn nếu cần.").padding(.top,30)
                schedule
                VStack(alignment:.leading,spacing:14) {
                    Text("Tùy chọn thêm").font(.title3)
                    Text("THÍCH TẬP VỚI").font(.caption.bold()).foregroundStyle(Dopa.muted)
                    LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())]) {ForEach(["Không ưu tiên","Máy tập","Tạ tự do","Bodyweight"],id:\.self){value in selection(value,selected:preferred==value){preferred=value}}}
                }.padding(18).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14)).padding(.horizontal,16)
                reviewGroup("MỤC TIÊU",items:[("Mục tiêu",store.data.plan.goal,-1),("Ưu tiên",focus.isEmpty || focus.contains("Cân bằng") ? "Phát triển cân bằng":focus.sorted().joined(separator:", "),7)])
                reviewGroup("HỒ SƠ",items:[("Kinh nghiệm",store.data.plan.experience,-1),("Nhóm tuổi",store.data.plan.ageGroup ?? "Chưa trả lời",3),("Giới tính",store.data.plan.gender,4),("Chiều cao","\(Int(store.data.plan.height)) cm",5),("Cân nặng","\(Int(store.data.plan.bodyWeight)) kg",6)])
                reviewGroup("NHỊP TẬP",items:[("Nơi tập",location,8),("Dụng cụ","\(equipment.count) đã chọn",9),("Số buổi","\(days) buổi / tuần",10),("Thời lượng","\(minutes) phút",11),("Hoạt động khác",store.data.plan.otherActivity ?? "Không có gì khác",13)])
            }.padding(.bottom,20) }
            Text("SAU KHI LƯU, DOPAFIT SẼ CHỌN MỘT PLAN SOẠN SẴN HỢP VỚI TRÌNH ĐỘ VÀ NƠI TẬP CỦA BẠN.").font(.dopa(size:11,weight:.semibold)).tracking(0.7).multilineTextAlignment(.center).padding(.horizontal,20).padding(.top,12)
            footer("Lưu và nhận plan",action:{saveGate=true})
        }
    }
    func reviewGroup(_ name:String,items:[(String,String,Int)])->some View {
        VStack(alignment:.leading,spacing:15) {
            Text(name).font(.caption.bold()).foregroundStyle(Dopa.muted)
            ForEach(items.indices,id:\.self) { i in
                Button { if items[i].2>=0{page=items[i].2} } label: {
                    HStack {Text(items[i].0).foregroundStyle(Dopa.muted);Spacer();Text(items[i].1).multilineTextAlignment(.trailing);if items[i].2>=0{Text("SỬA").font(.caption.bold()).foregroundStyle(Dopa.lime)}}.font(.dopa(size:17)).foregroundStyle(.white).padding(.vertical,8)
                }.buttonStyle(.plain)
            }
        }.padding(18).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14)).padding(.horizontal,16)
    }
    func selection(_ label:String,selected:Bool,action:@escaping()->Void)->some View {
        Button(action:action) {Text(label).font(.dopa(size:16,weight:.medium)).multilineTextAlignment(.leading).frame(maxWidth:.infinity).padding(.vertical,17).padding(.horizontal,6).foregroundStyle(selected ? .black:.white).background(selected ? Color.white:Dopa.card).clipShape(RoundedRectangle(cornerRadius:12)).overlay(RoundedRectangle(cornerRadius:12).stroke(.white.opacity(0.1)))}.buttonStyle(.plain)
    }
    func next() { imperial=false;page+=1 }
    func previous() { if page==0{back()}else{page-=1} }
    func finish() {
        store.data.plan.equipmentPreference=preferred
        store.data.plan.days=max(1,days)
        store.data.plan.minutes=max(15,minutes)
        store.data.plan.trainingDays=weekdays.sorted()
        store.makeDraft();store.persist()
        DispatchQueue.main.asyncAfter(deadline:.now()+0.35) { postSetup=true }
    }
}

struct OnboardingSaveGate:View {
    @Environment(\.dismiss) private var dismiss
    var onLocal:()->Void
    @State private var provider=""
    var body:some View {
        VStack(spacing:18) {
            HStack {CircleButton(icon:"xmark"){dismiss()};Spacer()}.padding(.horizontal,16).padding(.top,18)
            Text("Lưu thiết lập của bạn").dopaTitle(30).multilineTextAlignment(.center)
            Text("Đăng nhập để lưu thiết lập, nhận plan khởi đầu và theo dõi buổi tập.").font(.dopa(size:17)).foregroundStyle(Dopa.muted).multilineTextAlignment(.center).padding(.horizontal,22)
            ReferenceCrop(asset:"reference-signin",rect:[16,580,832,840]).frame(maxWidth:.infinity,maxHeight:.infinity)
            DopaButton(title:"Tiếp tục với Apple",icon:"apple.logo"){provider="Apple"}.padding(.horizontal,16)
            DopaButton(title:"Tiếp tục với Google"){provider="Google"}.padding(.horizontal,16)
            Text("Khi tiếp tục, bạn đồng ý với Điều khoản và Chính sách riêng tư.").font(.footnote).foregroundStyle(Dopa.muted).multilineTextAlignment(.center).padding(.horizontal,20)
            Button("Dùng bản thử cục bộ",action:onLocal).foregroundStyle(Dopa.lime).font(.dopa(size:16,weight:.semibold)).padding(.bottom,18)
        }.background(LinearGradient(colors:[Dopa.card,Dopa.background],startPoint:.top,endPoint:.bottom).ignoresSafeArea())
            .alert("Đăng nhập \(provider)",isPresented:Binding(get:{!provider.isEmpty},set:{if !$0{provider=""}})){
                Button("Đóng",role:.cancel){provider=""}
            }message:{Text("Bản thử chưa kết nối dịch vụ tài khoản. Bạn có thể dùng hồ sơ cục bộ để kiểm tra buổi tập.")}
    }
}

struct MeasurementRuler:View {
    @Binding var value:Double
    var range:ClosedRange<Double>
    var step:Double=1
    var majorEvery:Int=10
    @State private var dragStart:Double?
    private let spacing:CGFloat=10
    var body:some View {
        GeometryReader { geometry in
            Canvas { context,size in
                let center=value/step
                let radius=Int(size.width/spacing/2)+2
                for mark in (Int(center)-radius)...(Int(center)+radius) {
                    let raw=Double(mark)*step
                    guard range.contains(raw) else{continue}
                    let x=size.width/2+CGFloat(Double(mark)-center)*spacing
                    let major=mark%majorEvery==0
                    let opacity=max(0.12,1-abs(x-size.width/2)/(size.width/2))
                    var path=Path();path.move(to:CGPoint(x:x,y:0));path.addLine(to:CGPoint(x:x,y:major ? 40:20))
                    context.stroke(path,with:.color(.white.opacity(opacity*0.6)),lineWidth:1)
                    if major { context.draw(Text("\(mark)").font(.dopa(size:14,weight:.medium)).foregroundStyle(.white.opacity(opacity*0.65)),at:CGPoint(x:x,y:62)) }
                }
                var marker=Path();marker.move(to:CGPoint(x:size.width/2,y:0));marker.addLine(to:CGPoint(x:size.width/2,y:48))
                context.stroke(marker,with:.color(Dopa.lime),style:StrokeStyle(lineWidth:3,lineCap:.round))
            }.contentShape(Rectangle()).gesture(DragGesture(minimumDistance:0).onChanged{event in
                if dragStart==nil{dragStart=value}
                let delta=Double(event.translation.width/spacing)*step
                value=min(range.upperBound,max(range.lowerBound,((dragStart!-delta)/step).rounded()*step))
            }.onEnded{_ in dragStart=nil})
        }.accessibilityElement().accessibilityLabel("Thước đo").accessibilityValue(AppStore.number(value)).accessibilityAdjustableAction{direction in
            switch direction {case .increment:value=min(range.upperBound,value+step);case .decrement:value=max(range.lowerBound,value-step);@unknown default:break}
        }
    }
}
