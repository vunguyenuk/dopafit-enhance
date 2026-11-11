import SwiftUI

struct OnboardingView:View {
    @EnvironmentObject var store:AppStore
    @State private var step=ProcessInfo.processInfo.arguments.contains("--audit-setup") ? 18:0
    @State private var answers:[Int:Set<String>]=[:]
    @State private var language=false
    @State private var login=false
    @State private var name=""
    let obstacle=["Không có thời gian","Không biết nên tập gì","Thiếu động lực","Đau mỏi hoặc chấn thương","Không đủ dụng cụ","Chưa tập bao giờ"]
    let jobs=["Có plan tập phù hợp","Ghi lại tạ và rep","Biết khi nào nên tăng tạ","Giữ streak tập mỗi tuần","Xem video kỹ thuật","Đổi bài khi máy đang bận","Tự tạo buổi tập riêng"]
    var body:some View {
        GeometryReader { geo in
            ZStack {
                Dopa.background.ignoresSafeArea()
                LinearGradient(colors:[Dopa.card,Dopa.background],startPoint:.top,endPoint:.bottom).ignoresSafeArea()
                    .overlay { Ellipse().fill(Color.orange.opacity(0.12)).frame(width:geo.size.width*1.6,height:180).blur(radius:55).offset(y:-geo.size.height*0.23).accessibilityHidden(true) }
                VStack(spacing:0) {
                    if step==0 {welcome}
                    else if step==1 {intro}
                    else if step==2 {goal}
                    else if (9...11).contains(step) {motivation}
                    else if (12...17).contains(step) {story}
                    else if step>=18 { SetupOnboardingView { step=17 } }
                    else {question}
                }.frame(width:geo.size.width,height:geo.size.height)
            }.frame(width:geo.size.width,height:geo.size.height)
        }.sheet(isPresented:$language){ChoiceSheet(title:"Ngôn ngữ",choices:["Tiếng Việt","English"],selected:store.english ? "English":"Tiếng Việt"){v in store.changePlan{$0.language=v}}.dopaSheet().presentationDetents([.medium])}
            .fullScreenCover(isPresented:$login){OnboardingSaveGate{store.data.onboarded=true;store.persist();login=false}}
    }
    var welcome:some View {
        VStack(spacing:0) {
            HStack{(Text("DOPA").foregroundColor(.white)+Text("FIT").foregroundColor(Dopa.lime)).font(.dopa(size:16,weight:.heavy,design:.monospaced)).tracking(4);Spacer();Button{language=true}label:{Label(store.english ? "EN":"VI",systemImage:"globe").padding(12).background(Dopa.raised).clipShape(Capsule()).foregroundStyle(.white)}}.padding(.horizontal,16).padding(.top,14)
            Text(store.t("Theo dõi từng buổi tập.","Track every workout.")).dopaTitle(32).padding(.top,24)
            Text(store.t("Ghi lại bài tập và xem những nhóm cơ bạn đã tập.","Log exercises and see the muscles you've trained.")).font(.dopa(size:16)).foregroundStyle(Dopa.muted).multilineTextAlignment(.center).padding(.horizontal,24).padding(.top,10)
            OpenGymBodyView().allowsHitTesting(false).frame(maxWidth:.infinity,maxHeight:.infinity).padding(.top,16).mask(LinearGradient(stops:[.init(color:.clear,location:0),.init(color:.black,location:0.03),.init(color:.black,location:0.87),.init(color:.clear,location:1)],startPoint:.top,endPoint:.bottom))
            Button{answers=[:];store.toast="Đã đặt lại minh họa"}label:{HStack{Image(systemName:"arrow.counterclockwise");Text("Đặt lại minh họa");Spacer();Image(systemName:"checkmark.circle.fill")}.font(.dopa(size:16,weight:.semibold)).foregroundStyle(Dopa.lime).padding(16).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14)).overlay(RoundedRectangle(cornerRadius:12).stroke(.white.opacity(0.2)))}.padding(.horizontal,16)
            DopaButton(title:store.t("Bắt đầu thiết lập","Get Started")){step=1}.padding(16)
            Button {login=true}label:{(Text("Đã có tài khoản? ").foregroundColor(Dopa.muted)+Text("Đăng nhập").foregroundColor(Dopa.lime).underline()).font(.dopa(size:16))}.padding(.bottom,28)
        }
    }
    var intro:some View {
        VStack(spacing:16) {
            HStack{CircleButton(icon:"chevron.left"){step=0};Spacer()}.padding(.horizontal,16).padding(.top,16)
            ReferenceCrop(asset:"reference-intro",rect:[16,325,832,1100]).frame(maxWidth:.infinity,maxHeight:.infinity)
            Text("Ghi từng set.\nThấy mình mạnh lên.").dopaTitle(28).multilineTextAlignment(.center)
            Text("Dopafit lên plan, ghi lại từng set và cho bạn thấy rõ mình tiến bộ.").font(.dopa(size:17)).foregroundStyle(Dopa.muted).multilineTextAlignment(.center).padding(.horizontal,24)
            DopaButton(title:"Tiếp tục"){step=2}.padding(16)
        }
    }
    var header:some View {
        HStack(spacing:12) {
            CircleButton(icon:"chevron.left"){step=max(0,step-1)}
            VStack(alignment:.leading,spacing:12) {
                Text(step<18 ? "VỀ BẠN":step<21 ? "TẬP LUYỆN":"KẾ HOẠCH").font(.dopa(size:12,weight:.bold)).tracking(1)
                HStack(spacing:5){ForEach(0..<3){i in GeometryReader{g in ZStack(alignment:.leading){Capsule().fill(.white.opacity(0.3));Capsule().fill(Dopa.lime).frame(width:g.size.width*max(0,min(1,Double(step-2-i*5)/5)))}}.frame(height:4)}}
            }
        }.padding(.horizontal,16).padding(.top,14)
    }
    var goal:some View {
        VStack(spacing:16){
            header
            Text("Bạn muốn đạt điều gì?").dopaTitle(31).frame(maxWidth:.infinity,alignment:.leading).padding(.horizontal,16).padding(.top,12)
            OpenGymBodyView(heat:["Ngực":0.5,"Vai":0.5]).allowsHitTesting(false).frame(width:170).frame(maxHeight:.infinity)
            Text("Chọn mục tiêu để xem hướng tập của bạn.").font(.dopa(size:16)).foregroundStyle(Dopa.muted)
            LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:9){
                ForEach(Array(["Tăng cơ","Tăng sức mạnh","Giảm mỡ","Duy trì thể lực"].enumerated()),id:\.offset){i,title in
                    Button{store.changePlan{$0.goal=title};select(title,auto:true)}label:{
                        VStack(alignment:.leading,spacing:6){Text(title).font(.dopa(size:20,weight:.semibold));Spacer(minLength:2);OpenGymMuscleImage(muscle:["Ngực","Vai","Bụng","Lưng"][i]).frame(height:75)}.padding(16).frame(height:145).frame(maxWidth:.infinity,alignment:.leading).foregroundStyle(.white).background(Dopa.raised).clipShape(RoundedRectangle(cornerRadius:14)).overlay(RoundedRectangle(cornerRadius:14).stroke(.white.opacity(0.1)))
                    }
                }
            }.padding(.horizontal,16).padding(.bottom,20)
        }
    }
    func goalRect(_ i:Int)->[Double]{switch i{case 0:return [155,1245,250,180];case 1:return [560,1245,250,180];case 2:return [155,1580,250,180];default:return [560,1580,250,180]}}
    var question:some View {
        VStack(alignment:.leading,spacing:18) {
            header
            Text(questionTitle).dopaTitle(31).fixedSize(horizontal:false,vertical:true).padding(.horizontal,16).padding(.top,15)
            if step==4 {HStack{Text("Chọn tối đa 3.");Spacer();Text("\(answers[step]?.count ?? 0) / 3")}.foregroundStyle(Dopa.muted).padding(.horizontal,16)}
            Spacer(minLength:14)
            if step==8 || step==21 {
                VStack(spacing:20){Text(answers[step]?.first ?? "–").font(Dopa.metricFont(70));Label("BUỔI / TUẦN",systemImage:"calendar").font(.dopa(size:12,weight:.semibold)).foregroundStyle(Dopa.muted)}.frame(maxWidth:.infinity).frame(height:195).overlay(RoundedRectangle(cornerRadius:12).stroke(.white.opacity(0.3))).padding(.horizontal,16)
                HStack(spacing:5){ForEach(0...7,id:\.self){n in Button{answers[step]=["\(n)"];if step==21{store.changePlan{$0.days=max(1,n)}}}label:{Text(n==7 ? "7+":"\(n)").font(.dopa(size:16,weight:.semibold)).frame(maxWidth:.infinity).frame(height:50).background(answers[step]?.contains("\(n)")==true ? Dopa.lime:Dopa.raised).foregroundStyle(answers[step]?.contains("\(n)")==true ? .black:.white).clipShape(RoundedRectangle(cornerRadius:12))}}}.padding(.horizontal,16)
            } else {
                ScrollView {
                    VStack(spacing:8){ForEach(Array(options.enumerated()),id:\.offset){index,title in
                        Button{if step==6{store.changePlan{$0.experience=title=="Đã có kinh nghiệm" ? "Trung bình":"Mới bắt đầu"}};if step==22{store.changePlan{$0.minutes=Int(title.components(separatedBy:" ").first ?? "") ?? 60}};select(title,auto:![3,4,18,19].contains(step))}label:{
                            HStack(spacing:14){
                                Image(systemName:optionIcon(index)).font(.dopa(size:21)).foregroundStyle(Dopa.muted).frame(width:24)
                                Text(title).font(.dopa(size:18,weight:.medium)).foregroundStyle(.white)
                                Spacer()
                                if step==4 || step==18{Image(systemName:answers[step]?.contains(title)==true ? "checkmark.square.fill":"square").foregroundStyle(answers[step]?.contains(title)==true ? Dopa.lime:Dopa.muted)}
                                else if answers[step]?.contains(title)==true{Image(systemName:"checkmark").foregroundStyle(Dopa.lime)}
                            }.padding(16).frame(minHeight:56).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
                        }.buttonStyle(.plain)
                    }}.padding(.horizontal,16)
                }.fixedSize(horizontal:false,vertical:true)
            }
            Spacer(minLength:20)
            if [3,4,8,18,19,21].contains(step) {
                DopaButton(title:"Tiếp tục",enabled:!(answers[step] ?? []).isEmpty){advance()}.padding(.horizontal,16).padding(.bottom,20)
            }
        }
    }
    var motivation:some View {
        VStack(spacing:16){
            HStack{CircleButton(icon:"chevron.left"){step-=1};Spacer()}.padding(16)
            ReferenceCrop(asset:step==9 ? "reference-motivation":step==10 ? "reference-uncertainty":"reference-form",rect:[16,320,832,1100]).frame(maxWidth:.infinity,maxHeight:.infinity)
            Text(step==9 ? "Muốn đổi vóc dáng\nmà mãi chưa làm được?":step==10 ? "Vào phòng gym\nmà không biết tập gì?":"Không chắc mình tập\nđã đúng form chưa?").dopaTitle(28).multilineTextAlignment(.center)
            Text("Không có câu trả lời đúng hay sai.").foregroundStyle(Dopa.muted)
            HStack{DopaButton(title:"× Không phải tôi",secondary:true){step+=1};DopaButton(title:"✓ Đúng vậy",secondary:true){step+=1}}.padding(16)
        }
    }
    var story:some View {
        let index=step-12
        let assets=["reference-story-progress","reference-story-consistency","reference-story-plateau","reference-story-system","reference-story-plan","reference-story-overload"]
        let titles=["Cảm giác nặng hơn.\nChưa chắc là tiến bộ.","“Mai tập vậy.”\nRồi lại là ngày mai.","Bỏ bao công sức.\nVẫn chưa thấy thay đổi.","Bạn không thiếu nỗ lực.\nBạn thiếu một hệ thống.","Đừng chép plan người khác.\nCó plan của riêng bạn.","Hết đoán mò mức tạ.\nDopafit báo lúc nên tăng."]
        let details=["Bạn không biết hôm nay mình có nâng nặng hơn tháng trước không. Bạn đang tập theo cảm giác, mà cảm giác thì hay đánh lừa.","“Hơi mệt”, “mai đi bù”. Lý do để nghỉ lúc nào cũng có, và mỗi buổi bỏ lỡ lại khiến bắt đầu khó hơn.","Gương không đổi, cân cũng không. Cố mãi mà chẳng thấy gì, bỏ cuộc là chuyện dễ nhất.","Dopafit cho bạn biết hôm nay tập gì, ghi lại từng set và báo đúng lúc nên tăng tạ.","Dopafit xếp buổi tập theo nơi bạn tập, số buổi và thời gian bạn có.","Đủ rep là Dopafit gợi ý tăng tạ cho buổi sau. Không còn giậm chân mãi ở 40 kg."]
        return VStack(spacing:18){
            HStack{CircleButton(icon:"chevron.left"){step-=1};Spacer()}.padding(16)
            ReferenceCrop(asset:assets[index],rect:[16,310,832,900]).frame(maxWidth:.infinity,maxHeight:.infinity)
            Text(titles[index]).dopaTitle(28).multilineTextAlignment(.center).padding(.horizontal,20)
            Text(details[index]).font(.dopa(size:17)).foregroundStyle(Dopa.muted).multilineTextAlignment(.center).padding(.horizontal,24)
            Spacer(minLength:30)
            CircleButton(icon:"chevron.up"){step+=1}.padding(.bottom,30)
        }
    }
    var questionTitle:String {
        switch step {
        case 3:return "Điều gì đang cản bạn\ntăng sức mạnh?"
        case 4:return "Bạn muốn dùng Dopafit\nđể làm gì?"
        case 5:return "Bạn biết đến Dopafit\nqua đâu?"
        case 6:return "Kinh nghiệm tập luyện\ncủa bạn?"
        case 7:return "Dạo này bạn tập\nthế nào?"
        case 8:return "Trong 4 tuần qua, trung bình bạn tập mấy buổi mỗi tuần?"
        case 18:return "Bạn có những dụng cụ nào?"
        case 19:return "Bạn muốn ưu tiên nhóm cơ nào?"
        case 20:return "Bạn muốn tập ở đâu?"
        case 21:return "Bạn muốn tập mấy buổi mỗi tuần?"
        default:return "Mỗi buổi bạn có bao nhiêu thời gian?"
        }
    }
    var options:[String] {
        switch step {
        case 3:return obstacle
        case 4:return jobs
        case 5:return ["Bạn bè hoặc người thân","Facebook","Instagram","TikTok","App Store","Google","YouTube","Khác"]
        case 6:return ["Chưa từng tập","Mới bắt đầu","Đã có kinh nghiệm"]
        case 7:return ["Đang tập đều","Lúc tập lúc nghỉ","Đang nghỉ, muốn tập lại"]
        case 18:return Catalog.equipment
        case 19:return Catalog.muscleNames
        case 20:return ["Phòng gym","Tại nhà"]
        default:return ["15 phút","30 phút","45 phút","60 phút","90 phút"]
        }
    }
    func optionIcon(_ index:Int)->String{if step==3{return ["clock.fill","book.closed","battery.25","bandage.fill","dumbbell.fill","figure.stand"][index]};if step==4{return ["list.clipboard","square.and.pencil","chart.line.uptrend.xyaxis","flame.fill","play.rectangle.fill","arrow.triangle.2.circlepath","plus.square.on.square"][index]};return step==5 ? "circle.grid.2x2.fill":"figure.strengthtraining.traditional"}
    func select(_ value:String,auto:Bool) {
        if step==4 || step==18 {var set=answers[step] ?? [];if set.contains(value){set.remove(value)}else if step != 4 || set.count<3{set.insert(value)};answers[step]=set}
        else{answers[step]=[value]}
        store.data.onboardingAnswers=Dictionary(uniqueKeysWithValues:answers.map{(String($0.key),Array($0.value))});store.persist()
        if auto{advance()}
    }
    func advance() {
        store.data.onboardingAnswers=Dictionary(uniqueKeysWithValues:answers.map{(String($0.key),Array($0.value))});store.persist()
        if step>=22 {
            store.data.onboarded=true
            if let equipment=answers[18],!equipment.isEmpty{store.data.gyms[0].equipment=Array(equipment)}
            store.makeDraft();store.persist()
        } else{step+=1}
    }
}
