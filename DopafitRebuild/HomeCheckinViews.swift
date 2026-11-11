import SwiftUI

/// "Hôm nay bạn thế nào?" — chọn một lần, app chỉnh buổi hôm nay. Chỉ chỉnh được khi buổi chưa bắt đầu.
struct HomeCheckinCard:View {
    @EnvironmentObject var store:AppStore
    @State private var sheet:CheckinFeeling?=nil
    var body:some View {
        let current=store.todayCheckin
        let editable=store.checkinEditable
        Menu {
            ForEach([CheckinFeeling.good,.tired,.pain]){feeling in
                Button{choose(feeling)}label:{Label(feeling.title,systemImage:current?.feeling==feeling ? "checkmark":feeling.symbol)}
            }
            if current != nil {Divider();Button(store.t("Hoàn tác điều chỉnh","Undo adjustment")){store.clearCheckin()}}
        } label:{
            HStack(spacing:4){
                Text(current.map{$0.feeling == .short ? store.t("Thể trạng","Readiness"):$0.feeling.title} ?? store.t("Thể trạng","Readiness"))
                Image(systemName:editable ? "chevron.down":"lock.fill").font(.dopa(size:10))
            }.font(.dopa(size:14)).foregroundStyle(current != nil ? Dopa.lime:.white)
                .padding(.horizontal,12).frame(height:40).background(Dopa.card).clipShape(Capsule())
                .padding(.vertical,2).contentShape(Rectangle())
        }.disabled(!editable).accessibilityLabel(store.t("Thể trạng hôm nay","Today's readiness"))
            .accessibilityValue(current?.feeling.title ?? store.t("Chưa chọn","Not selected"))
            .accessibilityHint(editable ? store.t("Chọn khỏe, hơi mệt hoặc đang đau","Choose good, tired or pain"):store.t("Buổi tập đã bắt đầu, không thể điều chỉnh thể trạng","Workout started; readiness adjustments are locked"))
        .sheet(item:$sheet){feeling in
            Group {
                if feeling == .pain {CheckinPainSheet()} else {CheckinTimeSheet()}
            }.environmentObject(store)
        }
    }
    func choose(_ feeling:CheckinFeeling){
        switch feeling {
        case .pain,.short:sheet=feeling
        default:store.applyCheckin(feeling)
        }
    }
}

struct CheckinPainSheet:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var picked:Set<String>=[]
    var body:some View {
        VStack(alignment:.leading,spacing:16){
            SheetTitle(title:store.t("Đau ở đâu?","Where does it hurt?"))
            Text(store.t("App sẽ đổi các bài dồn lực vào chỗ đó sang bài cùng nhóm cơ nhẹ hơn cho khớp.","Exercises that load this area are swapped for gentler ones on the same muscle.")).font(.dopa(size:15)).foregroundStyle(Dopa.muted).fixedSize(horizontal:false,vertical:true).padding(.horizontal,20)
            LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:10){
                ForEach(JointLoad.areas,id:\.self){area in
                    let on=picked.contains(area)
                    Button{if on{picked.remove(area)}else{picked.insert(area)}}label:{
                        HStack{Text(area).font(.dopa(size:16,weight:on ? .semibold:.regular));Spacer();Image(systemName:on ? "checkmark.circle.fill":"circle").foregroundStyle(on ? Dopa.lime:Dopa.muted)}
                        .foregroundStyle(.white).padding(.horizontal,14).frame(height:52)
                        .background(on ? Dopa.raised:Dopa.card).clipShape(RoundedRectangle(cornerRadius:12))
                        .overlay(RoundedRectangle(cornerRadius:12).stroke(on ? Dopa.lime:Dopa.stroke,lineWidth:on ? 1.5:1))
                    }.buttonStyle(.plain).accessibilityAddTraits(on ? .isSelected:[])
                }
            }.padding(.horizontal,20)
            HStack(alignment:.top,spacing:8){
                Image(systemName:"exclamationmark.triangle").font(.dopa(size:13)).foregroundStyle(Dopa.muted)
                Text(store.t("Đau nhói, tê hoặc sưng thì dừng tập và hỏi bác sĩ. App chỉ đổi bài, không chữa chấn thương.","Sharp pain, numbness or swelling: stop and see a doctor. The app only swaps exercises; it doesn't treat injuries.")).font(.dopa(size:13)).foregroundStyle(Dopa.muted).fixedSize(horizontal:false,vertical:true)
            }.padding(.horizontal,20)
            Spacer(minLength:0)
            DopaButton(title:store.t("Điều chỉnh buổi tập","Adjust workout"),enabled:!picked.isEmpty){
                store.applyCheckin(.pain,pain:JointLoad.areas.filter{picked.contains($0)});dismiss()
            }.padding(.horizontal,20).padding(.bottom,12)
        }.frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.top).background(Dopa.background).presentationBackground(Dopa.background).presentationDetents([.height(560),.large]).presentationDragIndicator(.visible)
        .onAppear{if let current=store.todayCheckin,current.feeling == .pain{picked=Set(current.painAreas)}}
    }
}

struct CheckinTimeSheet:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var minutes=20
    var keep:Int {max(2,minutes/8)}
    var total:Int {store.todayCheckin?.original.count ?? store.data.draft?.exercises.count ?? 0}
    var body:some View {
        VStack(spacing:18){
            SheetTitle(title:store.t("Hôm nay bạn có bao lâu?","How much time do you have?"))
            HStack(spacing:8){ForEach([15,20,30,45],id:\.self){n in
                Button{minutes=n}label:{Text("\(n) phút").font(.dopa(size:16,weight:.semibold)).frame(maxWidth:.infinity).frame(height:52).background(minutes==n ? Dopa.lime:Dopa.raised).foregroundStyle(minutes==n ? .black:.white).clipShape(Capsule())}.buttonStyle(.plain)
            }}.padding(.horizontal,20)
            Text(total>keep ? "Giữ \(keep) bài đầu, các bài còn lại để buổi sau." : "Buổi hôm nay đã vừa thời gian này.").font(.dopa(size:15)).foregroundStyle(Dopa.muted).padding(.horizontal,20)
            DopaButton(title:store.t("Rút gọn buổi tập","Shorten workout")){store.applyCheckin(.short,minutes:minutes);dismiss()}.padding(.horizontal,20)
        }.padding(.bottom,12).frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.top).background(Dopa.background).presentationBackground(Dopa.background).presentationDetents([.height(300),.large]).presentationDragIndicator(.visible)
        .onAppear{if let current=store.todayCheckin?.minutes{minutes=current}}
    }
}

/// Lỡ buổi theo kế hoạch: báo rõ, cho chọn tập đủ hôm nay hoặc rút gọn còn 20 phút.
struct HomeMissedCard:View {
    @EnvironmentObject var store:AppStore
    var day:Date
    var label:String {
        let f=DateFormatter();f.locale=Locale(identifier:"vi_VN");f.dateFormat="EEEE"
        return f.string(from:day).lowercased()
    }
    var body:some View {
        VStack(alignment:.leading,spacing:10){
            HStack(alignment:.top){
                VStack(alignment:.leading,spacing:4){
                    Text("Bạn lỡ buổi \(label)").font(.dopa(size:16,weight:.semibold))
                    Text("Hôm nay tập bù đúng buổi đó để không sót nhóm cơ.").font(.dopa(size:14)).foregroundStyle(.white.opacity(0.8)).fixedSize(horizontal:false,vertical:true)
                }
                Spacer(minLength:8)
                Button{store.dismissTip(AppStore.missedKey(day))}label:{Image(systemName:"xmark").font(.dopa(size:13,weight:.semibold)).foregroundStyle(Dopa.muted).frame(width:44,height:44)}.accessibilityLabel("Ẩn thông báo lỡ buổi").padding(.top,-12).padding(.trailing,-12)
            }
            HStack(spacing:8){
                Button{store.dismissTip(AppStore.missedKey(day))}label:{Text("Tập đủ").font(.dopa(size:14,weight:.semibold)).foregroundStyle(.black).padding(.horizontal,16).frame(height:40).background(Dopa.lime).clipShape(Capsule())}.buttonStyle(.plain)
                Button{if store.applyCheckin(.short,minutes:20){store.dismissTip(AppStore.missedKey(day))}}label:{Text("Rút gọn 20 phút").font(.dopa(size:14,weight:.medium)).foregroundStyle(.white).padding(.horizontal,16).frame(height:40).background(Dopa.raised).clipShape(Capsule())}.buttonStyle(.plain).disabled(!store.checkinEditable)
            }
        }.padding(14).frame(maxWidth:.infinity,alignment:.leading).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
    }
}

/// Một dòng giải thích vì sao buổi hôm nay như vậy.
struct HomeReasonCard:View {
    var text:String
    var icon:String="sparkles"
    var body:some View {
        HStack(alignment:.firstTextBaseline,spacing:8){
            Image(systemName:icon).font(.dopa(size:13,weight:.semibold)).foregroundStyle(Dopa.lime)
            Text(text).font(.dopa(size:14)).foregroundStyle(.white.opacity(0.85)).fixedSize(horizontal:false,vertical:true)
        }.frame(maxWidth:.infinity,alignment:.leading).padding(.top,-4)
        .accessibilityElement(children:.combine).accessibilityLabel("Vì sao buổi này: "+text)
    }
}
