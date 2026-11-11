import SwiftUI

struct ExerciseGuide:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) private var phase
    @State private var ownerTab:AppTab?=nil
    var exercise:Exercise
    var modal=false
    @State private var section=0
    @State private var speed:Float=1
    @State private var gifData:Data?=nil
    @State private var loadingGIF=false
    @State private var retry=0
    @State private var visible=false
    var body:some View {
        GeometryReader { geometry in
            let demoURL=ExerciseDBMedia.guideVideoURL(for:exercise)
            let hasMedia=demoURL != nil || gifData != nil
            let mediaHeight=geometry.size.width
            ScrollView {
                VStack(alignment:.leading,spacing:20) {
                    if hasMedia {
                        ZStack(alignment:.topLeading) {
                            Group {
                                if let demoURL {ExerciseLoopVideo(url:demoURL,speed:visible && phase == .active && ownerTab==store.tab ? speed:0)}
                                else if let gifData {AnimatedGIF(data:gifData,speed:visible && phase == .active && ownerTab==store.tab ? speed:0).background(Color.white)}
                            }.frame(width:geometry.size.width,height:mediaHeight)
                                .frame(maxWidth:.infinity).frame(height:mediaHeight).clipped()
                            CircleButton(icon:modal ? "xmark":"chevron.left"){dismiss()}.padding(.horizontal,16).padding(.top,16)
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Menu {ForEach([0.5,1,1.5,2],id:\.self){value in Button(speedLabel(Float(value))){speed=Float(value)}}} label:{
                                        Text(speedLabel(speed)).font(.dopa(size:14,weight:.semibold)).foregroundStyle(.white).padding(.horizontal,9).padding(.vertical,5).background(.black.opacity(0.65)).clipShape(RoundedRectangle(cornerRadius:9))
                                    }.accessibilityLabel("Tốc độ phát")
                                }.padding(16)
                            }
                        }.frame(height:mediaHeight)
                    } else {
                        HStack {
                            Spacer()
                            CircleButton(icon:modal ? "xmark":"chevron.left"){dismiss()}
                        }.padding(.horizontal,16).padding(.top,16)
                        if ExerciseDBMedia.record(for:exercise) != nil {
                            HStack(spacing:8){
                                if loadingGIF {ProgressView().tint(Dopa.lime);Text("Đang tải video hướng dẫn…")}
                                else {Text("Chưa tải được video hướng dẫn.");Button("Thử lại"){retry+=1}.foregroundStyle(Dopa.lime)}
                            }.font(.dopa(size:13)).foregroundStyle(Dopa.muted).padding(.horizontal,16)
                        }
                    }
                    Text(store.t(exercise.name,exercise.english)).font(.dopa(size:23,weight:.semibold)).padding(.horizontal,16)
                    PillTabs(titles:[store.t("Cách tập","How to"),store.t("Nhóm cơ","Muscles"),store.t("Dụng cụ","Equipment")],selection:$section).padding(.horizontal,16)
                    Group {
                        switch section {
                        case 1:muscles
                        case 2:equipment
                        default:instructions
                        }
                    }.padding(.horizontal,16)
                }.padding(.bottom,25)
            }.background(Dopa.background).toolbar(.hidden,for:.navigationBar)
                .onAppear{visible=true;ownerTab=store.tab}
                .task(id:exercise.id+"-\(retry)"){
                    gifData=nil
                    guard ExerciseDBMedia.guideVideoURL(for:exercise)==nil,ExerciseDBMedia.record(for:exercise) != nil else{loadingGIF=false;return}
                    loadingGIF=true
                    let result=await ExerciseDBMedia.gif(for:exercise)
                    guard !Task.isCancelled else{return};gifData=result;loadingGIF=false
                }
                .onDisappear{visible=false}
        }
    }
    func speedLabel(_ value:Float)->String {String(format:"%.1f",value).replacingOccurrences(of:".",with:store.english ? ".":",")+" x"}
    var instructions:some View {
        VStack(alignment:.leading,spacing:15) {
            if !store.english {ExerciseTipsCards(exercise:exercise)}
            ForEach(instructionLines,id:\.self) {Text($0).font(.dopa(size:17)).lineSpacing(5).fixedSize(horizontal:false,vertical:true)}
        }
    }
    var instructionLines:[String] {
        if store.english,let lines=ExerciseDBMedia.record(for:exercise)?.instructions,!lines.isEmpty {return lines.map{line in line.replacingOccurrences(of:#"^Step:\d+\s*"#,with:"",options:.regularExpression)}}
        if exercise.id=="tbar" {return ["Tải máy T-Bar Row với trọng lượng mong muốn. Đứng sao cho hai chân ở hai bên thanh tạ.","Nắm tay cầm bằng lòng bàn tay hướng xuống.","Nắm thanh tạ. Khi thở ra, kéo trọng lượng lên và siết cơ lưng. Giữ cánh tay sát thân người.","Ở điểm cao nhất của động tác, hít vào và hạ thanh tạ trở về vị trí ban đầu."]}
        if exercise.id=="dumbbell-row" {return ["Đặt một tạ đơn ở mỗi bên của ghế tập phẳng.","Đặt gối phải lên trên ghế và tay phải đặt ở phía bên kia của ghế. Thân người phải song song với mặt đất.","Cầm tạ đơn bằng tay trái trong khi giữ lưng thẳng. Lòng bàn tay phải hướng về phía thân người.","Kéo tạ đơn thẳng lên phía bên hông cơ thể. Gây căng cơ lưng và thở ra khi thực hiện động tác này. Thân người phải giữ cố định trong khi cánh tay di chuyển."]}
        return exercise.instructions
    }
    var muscles:some View {
        VStack(alignment:.leading,spacing:18) {
            Text(store.t("CƠ CHÍNH","PRIMARY MUSCLES")).font(.dopa(size:11,weight:.semibold)).tracking(1).foregroundStyle(Dopa.muted)
            ForEach(exercise.muscles,id:\.self){muscleRow($0)}
            Divider()
            Text(store.t("CƠ HỖ TRỢ","SECONDARY MUSCLES")).font(.dopa(size:11,weight:.semibold)).tracking(1).foregroundStyle(Dopa.muted)
            ForEach(exercise.secondary,id:\.self){muscleRow($0)}
            if exercise.secondary.isEmpty {Text("—").foregroundStyle(Dopa.muted)}
            Divider()
        }.padding(.top,4)
    }
    func muscleRow(_ muscle:String)->some View {
        HStack(spacing:14) {
            MuscleGlyph(muscle:muscle).frame(width:46,height:50).background(Dopa.raised).clipShape(RoundedRectangle(cornerRadius:9))
            Text(exercise.id=="tbar" && muscle=="Lưng" ? "Cơ xô":muscle).font(.dopa(size:18,weight:.medium))
            Spacer()
        }
    }
    var equipment:some View {
        HStack(spacing:18) {
            Image(systemName:"dumbbell.fill").font(.dopa(size:38)).foregroundStyle(Dopa.muted).frame(width:85,height:85).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
            VStack(alignment:.leading,spacing:6) {Text(exercise.equipment).font(.dopa(size:20,weight:.semibold));if !exercise.convention.isEmpty{Text(exercise.convention).foregroundStyle(Dopa.muted)}}
            Spacer()
        }.padding(.vertical,8)
    }
}
