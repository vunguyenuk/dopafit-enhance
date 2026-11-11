import SwiftUI

struct WorkoutProgramShelf:View {
    @EnvironmentObject var store:AppStore
    @State private var groupID="abs"
    @State private var selected:WorkoutProgram?
    var group:WorkoutProgramGroup {WorkoutProgramGroup.all.first{$0.id==groupID} ?? WorkoutProgramGroup.all[0]}
    var body:some View {
        VStack(alignment:.leading,spacing:16){
            Text("Tập theo nhóm cơ").dopaSection()
            ScrollView(.horizontal,showsIndicators:false){HStack(spacing:20){ForEach(WorkoutProgramGroup.all){g in
                Button{groupID=g.id}label:{
                    Text(g.title).font(.dopa(size:14,weight:.medium))
                        .foregroundStyle(groupID==g.id ? Color.white:Dopa.muted)
                        .frame(minWidth:44,minHeight:44)
                        .overlay(alignment:.bottom){Capsule().fill(groupID==g.id ? Dopa.lime:Color.clear).frame(height:2)}
                        .contentShape(Rectangle())
                }.buttonStyle(.plain).accessibilityLabel("Chương trình "+g.title).accessibilityAddTraits(groupID==g.id ? .isSelected:[]).accessibilityRemoveTraits(groupID==g.id ? []:.isSelected)
            }}}.overlay(alignment:.bottom){Rectangle().fill(Dopa.stroke.opacity(0.4)).frame(height:0.5).allowsHitTesting(false)}
            DiscoveryPhoto(asset:group.photo,focal:group.id=="glutes" ? .leading:.center).frame(height:168).clipShape(RoundedRectangle(cornerRadius:14)).id(group.id)
            VStack(spacing:0){ForEach(1...3,id:\.self){level in
                let program=WorkoutProgram(group:group,level:level)
                Button{selected=program}label:{
                    HStack(spacing:14){Text("\(level)").font(.dopa(size:17,weight:.semibold)).foregroundStyle(Dopa.lime).frame(width:40,height:40).background(Dopa.raised).clipShape(Circle())
                        VStack(alignment:.leading,spacing:5){Text(program.levelName).font(.dopa(size:17,weight:.semibold)).foregroundStyle(.white);Text("Khoảng \(program.minutes) phút · \(program.exercises.count) bài · \(level+1) set/bài").font(.dopa(size:13)).foregroundStyle(Dopa.muted)}
                        Spacer(minLength:4);Image(systemName:"chevron.right").font(.dopa(size:13)).foregroundStyle(Dopa.muted)
                    }.padding(.vertical,14).contentShape(Rectangle())
                }.buttonStyle(.plain).accessibilityLabel(program.title+", khoảng \(program.minutes) phút, \(program.exercises.count) bài")
                if level<3 {Divider().overlay(Dopa.stroke.opacity(0.5))}
            }}
        }.padding(.top,12).sheet(item:$selected){p in NavigationStack{WorkoutProgramDetail(program:p).environmentObject(store)}}
    }
}
struct WorkoutProgramDetail:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) private var dismiss
    let program:WorkoutProgram
    @State private var confirmAdd=false
    @State private var confirmReplace=false
    @State private var guide:Exercise?
    var canReplace:Bool {store.data.draft?.hasStarted != true && (store.data.draft?.completedSets ?? 0)==0}
    var body:some View {
        VStack(spacing:0){
            SheetTitle(title:"Chương trình tập")
            ScrollView{VStack(alignment:.leading,spacing:20){
                DiscoveryPhoto(asset:program.group.photo,focal:.center).frame(height:220).clipShape(RoundedRectangle(cornerRadius:14))
                Text(program.title).font(.dopa(size:27,weight:.bold))
                Label("Khoảng \(program.minutes) phút · \(program.exercises.count) bài",systemImage:"clock").font(.dopa(size:15)).foregroundStyle(Dopa.muted)
                Text(program.equipment.joined(separator:" · ")).font(.dopa(size:14)).foregroundStyle(Dopa.muted)
                Text("Một buổi tập mẫu có thể chỉnh sửa. Chọn mức tạ và số lần phù hợp trước khi bắt đầu.").font(.dopa(size:15)).foregroundStyle(Dopa.muted)
                VStack(spacing:0){ForEach(program.exercises){item in
                    Button{guide=item.exercise}label:{HStack(spacing:12){
                        if ExerciseDBMedia.hasMotionThumbnail(for:item.exercise) {
                            ExerciseMotionThumbnail(exercise:item.exercise).frame(width:60,height:60).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:10))
                        }
                        VStack(alignment:.leading,spacing:5){Text(item.exercise.name).font(.dopa(size:16,weight:.medium)).foregroundStyle(.white).multilineTextAlignment(.leading)
                            Text("\(item.sets.count) set · "+(item.exercise.timed ? "\(item.sets[0].seconds) giây":"\(item.sets[0].reps) lần")+" · nghỉ 60 giây").font(.dopa(size:13)).foregroundStyle(Dopa.muted)}.frame(maxWidth:.infinity,alignment:.leading)
                        Image(systemName:"info.circle").foregroundStyle(Dopa.muted)
                    }.padding(.vertical,12).contentShape(Rectangle())}.buttonStyle(.plain)
                    Divider().overlay(Dopa.stroke.opacity(0.5))
                }}
            }.padding(20)}
            VStack(spacing:10){
                DopaButton(title:"Thêm \(program.exercises.count) bài vào buổi tập"){confirmAdd=true}
                Button("Dùng làm buổi tập hôm nay"){confirmReplace=true}.font(.dopa(size:15,weight:.medium)).foregroundStyle(canReplace ? Dopa.lime:Dopa.muted).frame(minHeight:44).disabled(!canReplace)
                if !canReplace{Text("Bạn đang có buổi đã bắt đầu. Hãy hoàn tất buổi đó trước khi đổi chương trình.").font(.dopa(size:12)).foregroundStyle(Dopa.muted)}
            }.padding(.horizontal,20).padding(.vertical,12).background(Dopa.background)
        }.background(Dopa.background).toolbar(.hidden,for:.navigationBar)
        .alert("Thêm bài vào buổi hiện tại?",isPresented:$confirmAdd){Button("Hủy",role:.cancel){};Button("Thêm bài"){if store.applyProgram(program){store.toast="Đã thêm \(program.exercises.count) bài";dismiss()}}}message:{Text("Buổi hôm nay sẽ có \((store.data.draft?.exercises.count ?? 0)+program.exercises.count) bài. Bạn có thể chỉnh từng bài trước khi tập.")}
        .alert("Dùng chương trình này cho hôm nay?",isPresented:$confirmReplace){Button("Hủy",role:.cancel){};Button("Thay buổi chưa bắt đầu",role:.destructive){if store.applyProgram(program,replacing:true){store.toast="Đã chuẩn bị buổi tập";dismiss()}}}message:{Text("Thay \(store.data.draft?.exercises.count ?? 0) bài chưa bắt đầu bằng \(program.exercises.count) bài của chương trình. Lịch sử tập vẫn được giữ.")}
        .sheet(item:$guide){ex in ExerciseGuide(exercise:ex,modal:true).environmentObject(store)}
    }
}

struct ChallengeCatalogView:View {
    @EnvironmentObject var store:AppStore
    @State private var query=""
    @State private var selected:WorkoutChallenge?
    @State private var category="Tất cả"
    let onBrowse:(String?)->Void
    var filtered:[WorkoutChallenge] {WorkoutChallenge.all.filter{(category=="Tất cả" || $0.category==category) && (query.isEmpty || ExerciseMeta.fold($0.title+" "+$0.subtitle).contains(ExerciseMeta.fold(query)))}}
    var body:some View {
        VStack(spacing:0){
            SheetTitle(title:"Tất cả thử thách")
            HStack(spacing:10){Image(systemName:"magnifyingglass").foregroundStyle(Dopa.muted);TextField("Tìm thử thách",text:$query).font(.dopa(size:16)).autocorrectionDisabled();if !query.isEmpty{Button{query=""}label:{Image(systemName:"xmark.circle.fill").foregroundStyle(Dopa.muted)}.accessibilityLabel("Xóa tìm kiếm")}}.padding(12).background(Dopa.card).clipShape(Capsule()).padding(.horizontal,20)
            ScrollView(.horizontal,showsIndicators:false){HStack(spacing:8){ForEach(["Tất cả","Toàn thân","Sức mạnh","Core","Thói quen"],id:\.self){name in Button{category=name}label:{Text(name).font(.dopa(size:14,weight:.medium)).foregroundStyle(category==name ? Dopa.lime:Dopa.muted).padding(.horizontal,14).frame(height:40).background(category==name ? Dopa.raised:Dopa.card).clipShape(Capsule())}.buttonStyle(.plain).accessibilityAddTraits(category==name ? .isSelected:[]).accessibilityRemoveTraits(category==name ? []:.isSelected)}}.padding(.horizontal,20)}.padding(.vertical,12)
            ScrollView{LazyVStack(alignment:.leading,spacing:16){
                Text("\(filtered.count) thử thách").font(.dopa(size:13)).foregroundStyle(Dopa.muted)
                if filtered.isEmpty{Text("Không tìm thấy thử thách. Thử từ khóa hoặc nhóm khác.").font(.dopa(size:16)).foregroundStyle(Dopa.muted).padding(.vertical,28)}
                ForEach(filtered){challenge in Button{selected=challenge}label:{
                    HStack(spacing:14){ChallengePhoto(challengeID:challenge.id).frame(width:112,height:100).clipShape(RoundedRectangle(cornerRadius:12))
                        VStack(alignment:.leading,spacing:6){Text("\(challenge.days) ngày").font(.dopa(size:12,weight:.semibold)).foregroundStyle(Dopa.lime);Text(challenge.title).font(.dopa(size:17,weight:.semibold)).foregroundStyle(.white).multilineTextAlignment(.leading);Text(challenge.summary).font(.dopa(size:13)).foregroundStyle(Dopa.muted).multilineTextAlignment(.leading)}.frame(maxWidth:.infinity,alignment:.leading)
                        Image(systemName:store.activeEnrollment(challenge.id)==nil ? "chevron.right":"checkmark.circle").font(.dopa(size:15)).foregroundStyle(Dopa.muted)
                    }.contentShape(Rectangle())
                }.buttonStyle(.plain);Divider().overlay(Dopa.stroke.opacity(0.4))}
            }.padding(20)}.scrollDismissesKeyboard(.interactively)
        }.background(Dopa.background).sheet(item:$selected){challenge in ChallengeDetail(challenge:challenge,onBrowse:onBrowse).environmentObject(store)}
    }
}
extension WorkoutChallenge {
    var category:String {
        if manualPractice{return "Thói quen"}
        if id.hasPrefix("core-"){return "Core"}
        if ["upper-28","lower-28","physique-28","dumbbell-30"].contains(id){return "Sức mạnh"}
        return "Toàn thân"
    }
}

/// Real source photography without tinting, desaturation or AI editing.
struct DiscoveryPhoto:View {
    var asset:String
    var focal:Alignment?=nil
    var alignment:Alignment {
        if let focal{return focal}
        if asset=="challenge-upper-28" || asset=="challenge-dumbbell-30"{return .top}
        if asset=="challenge-fullbody-28"{return .bottom}
        return .center
    }
    var body:some View {GeometryReader{g in
        if asset=="challenge-activity-30" {
            let ratio:CGFloat=1400/1751
            let height=max(g.size.height,g.size.width/ratio)
            Image(asset).resizable().scaledToFill().frame(width:g.size.width,height:height)
                .offset(y:-(height-g.size.height)*0.28)
                .frame(width:g.size.width,height:g.size.height,alignment:.top).clipped().allowsHitTesting(false)
        } else {
            Image(asset).resizable()
                .aspectRatio(contentMode:asset=="challenge-mobility-28" ? .fit:.fill)
                .frame(width:g.size.width,height:g.size.height,alignment:alignment).clipped().allowsHitTesting(false)
        }
    }.background(asset=="challenge-mobility-28" ? Color.black:Dopa.card).clipped().contentShape(Rectangle()).accessibilityHidden(true)}
}
