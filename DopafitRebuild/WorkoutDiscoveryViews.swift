import SwiftUI

struct WorkoutWeekCalendar:View {
    @EnvironmentObject var store:AppStore
    @Binding var selected:Date
    private var calendar:Calendar {WorkoutCalendarLogic.calendar()}
    private var days:[Date] {WorkoutCalendarLogic.week(containing:selected)}
    private var trained:Set<Date> {WorkoutCalendarLogic.trainingDays(store.data.history,in:days)}
    private var currentWeek:Bool {days.contains{calendar.isDateInToday($0)}}
    private var weeksAhead:Int {
        let thisWeek=WorkoutCalendarLogic.week(containing:Date())[0]
        return (calendar.dateComponents([.day],from:thisWeek,to:days[0]).day ?? 0)/7
    }
    private var future:Bool {weeksAhead>0}
    /// "16 – 22 tháng 11" (cùng tháng) hoặc "30 tháng 11 – 6 tháng 12".
    private var rangeLabel:String {
        guard let first=days.first,let last=days.last else{return ""}
        let d={(x:Date) in calendar.component(.day,from:x)},m={(x:Date) in calendar.component(.month,from:x)}
        if store.english {
            let f=DateFormatter();f.calendar=calendar;f.locale=Locale(identifier:"en_US");f.dateFormat="MMM d"
            return f.string(from:first)+" – "+f.string(from:last)
        }
        return m(first)==m(last) ? "\(d(first)) – \(d(last)) tháng \(m(last))":"\(d(first)) tháng \(m(first)) – \(d(last)) tháng \(m(last))"
    }
    private func dateLabel(_ date:Date)->String {
        let f=DateFormatter();f.calendar=calendar;f.timeZone=calendar.timeZone
        f.locale=Locale(identifier:store.english ? "en_US":"vi_VN")
        f.dateFormat=store.english ? "EEEE, MMMM d":"EEEE, d 'tháng' M"
        let value=f.string(from:date)
        return value.prefix(1).uppercased()+value.dropFirst()
    }
    var body:some View {
        VStack(alignment:.leading,spacing:4){
            HStack(spacing:0){
                VStack(alignment:.leading,spacing:3){
                    HStack(alignment:.firstTextBaseline,spacing:6){
                        if future {
                            Text(store.t(weeksAhead==1 ? "Tuần tới":"Sau \(weeksAhead) tuần",weeksAhead==1 ? "Next week":"In \(weeksAhead) weeks")).font(.dopa(size:20,weight:.bold)).foregroundStyle(.white)
                        } else {
                            Text("\(trained.count)/\(max(1,store.data.plan.days))").font(.dopa(size:20,weight:.bold)).monospacedDigit().foregroundStyle(.white)
                            Text(store.t(currentWeek ? "ngày tập tuần này":"ngày tập",currentWeek ? "days this week":"training days")).font(.dopa(size:14,weight:.medium)).foregroundStyle(.white.opacity(0.85))
                        }
                    }
                }.frame(maxWidth:.infinity,minHeight:44,alignment:.leading).contentShape(Rectangle())
                .onTapGesture{selected=Date()}
                .accessibilityElement(children:.combine).accessibilityAddTraits(.isButton)
                .accessibilityValue(currentWeek ? "":rangeLabel).accessibilityHint(currentWeek ? "":store.t("Về hôm nay","Back to today")).accessibilityIdentifier("calendar.today")
                Button{shift(-7)}label:{Image(systemName:"chevron.left").frame(width:44,height:44)}.accessibilityLabel(store.t("Tuần trước","Previous week"))
                Button{shift(7)}label:{Image(systemName:"chevron.right").frame(width:44,height:44)}.accessibilityLabel(store.t("Tuần sau","Next week"))
            }.foregroundStyle(Dopa.muted)
            HStack(spacing:2){
                ForEach(days,id:\.self){date in
                    let on=calendar.isDate(date,inSameDayAs:selected),today=calendar.isDateInToday(date),done=trained.contains(calendar.startOfDay(for:date))
                    Button{selected=date}label:{
                        VStack(spacing:4){
                            Text((store.english ? ["Su","Mo","Tu","We","Th","Fr","Sa"]:["CN","T2","T3","T4","T5","T6","T7"])[calendar.component(.weekday,from:date)-1]).font(.dopa(size:12,weight:.medium)).foregroundStyle(today ? Dopa.lime:Dopa.muted)
                            Text("\(calendar.component(.day,from:date))").font(.dopa(size:17,weight:.semibold)).monospacedDigit().foregroundStyle(done ? .black:.white)
                                .frame(width:34,height:34).background(done ? Dopa.lime:Dopa.card).clipShape(Circle())
                                .overlay(Circle().stroke(on ? (done ? Color.white:Dopa.lime):(done ? Color.clear:Dopa.stroke),lineWidth:on ? 2:1))
                            ZStack {
                                if done {Image(systemName:"checkmark").font(.dopa(size:10,weight:.semibold)).foregroundStyle(Dopa.lime)}
                                else if today {Text(store.t("Hôm nay","Today")).font(.dopa(size:10,weight:.medium)).foregroundStyle(Dopa.lime)}
                            }.frame(height:12)
                        }.frame(maxWidth:.infinity).frame(minHeight:60).contentShape(Rectangle())
                    }.buttonStyle(.plain).accessibilityLabel(dateLabel(date)+(done ? store.t(", đã tập",", trained"):"")+(today ? store.t(", hôm nay",", today"):"")).accessibilityAddTraits(on ? .isSelected:[]).accessibilityRemoveTraits(on ? []:.isSelected)
                }
            }
        }.padding(.horizontal,12).padding(.vertical,8).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:18))
    }
    func shift(_ count:Int){selected=calendar.date(byAdding:.day,value:count,to:selected) ?? selected}
}
struct WorkoutSuggestions:View {
    @EnvironmentObject var store:AppStore
    var onChoose:(String)->Void
    var body:some View {
        VStack(alignment:.leading,spacing:12){
            HStack{Text(store.t("Nhóm cơ gợi ý","Suggested muscles")).dopaSection();Spacer()}
            ScrollView(.horizontal,showsIndicators:false){HStack(spacing:12){ForEach(store.suggestedMuscles,id:\.self){muscle in
                Button{onChoose(muscle)}label:{
                    VStack(spacing:8){MuscleGlyph(muscle:muscle).frame(width:72,height:66);Text(muscle).font(.dopa(size:13,weight:.medium)).foregroundStyle(.white)}.padding(10).frame(width:96).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
                }.buttonStyle(.plain).accessibilityLabel("Tìm bài cho "+muscle)
            }}}
            if store.suggestedMuscles.isEmpty{Text("Đã tập hết nhóm cơ gợi ý gần đây.").font(.dopa(size:14)).foregroundStyle(Dopa.muted)}
        }.padding(.top,8)
    }
}
struct WorkoutChallengeShelf:View {
    @EnvironmentObject var store:AppStore
    @State private var selected:WorkoutChallenge?=nil
    @State private var showCatalog=false
    var onBrowse:(String?)->Void
    var body:some View {
        VStack(alignment:.leading,spacing:14){
            HStack{Text(store.t("Thử thách","Challenges")).dopaSection();Spacer();Button{showCatalog=true}label:{HStack(spacing:4){Text("Tất cả \(WorkoutChallenge.all.count)");Image(systemName:"chevron.right").font(.dopa(size:12))}.font(.dopa(size:14,weight:.medium)).foregroundStyle(Dopa.lime).frame(minHeight:44)}.accessibilityLabel("Xem tất cả thử thách")}
            ScrollView(.horizontal,showsIndicators:false){HStack(spacing:14){ForEach(WorkoutChallenge.all){challenge in
                Button{selected=challenge}label:{card(challenge)}.buttonStyle(.plain)
            }}.scrollTargetLayout()}.scrollTargetBehavior(.viewAligned)
        }.padding(.top,8).sheet(item:$selected){challenge in ChallengeDetail(challenge:challenge,onBrowse:onBrowse).environmentObject(store)}.sheet(isPresented:$showCatalog){ChallengeCatalogView(onBrowse:onBrowse).environmentObject(store)}
    }
    func card(_ challenge:WorkoutChallenge)->some View {
        let enrollment=store.activeEnrollment(challenge.id)
        let count=enrollment.map{WorkoutCalendarLogic.progress(challenge,enrollment:$0,history:store.data.history,practices:store.data.challengePractices ?? []).count} ?? 0
        return VStack(alignment:.leading,spacing:0){
            ChallengePhoto(challengeID:challenge.id).frame(width:260,height:164)
                .overlay(alignment:.topLeading){Text("\(challenge.days) ngày").font(.dopa(size:12,weight:.semibold)).foregroundStyle(.white).padding(.horizontal,8).padding(.vertical,5).background(.black.opacity(0.65)).clipShape(Capsule()).padding(12)}
            VStack(alignment:.leading,spacing:6){
                HStack(spacing:8){Text(challenge.title).font(.dopa(size:20,weight:.bold)).foregroundStyle(.white).lineLimit(1);Spacer(minLength:0);Image(systemName:enrollment == nil ? "arrow.up.right":"checkmark.circle").foregroundStyle(Dopa.lime)}
                Text(enrollment == nil ? challenge.summary:"\(count)/\(challenge.targetDays) "+(challenge.manualPractice ? "ngày thực hành":"ngày đã tập")).font(.dopa(size:13)).foregroundStyle(enrollment == nil ? Dopa.muted:Dopa.lime).lineLimit(1)
            }.padding(12).frame(width:260,alignment:.leading)
        }.frame(width:260).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14)).overlay(RoundedRectangle(cornerRadius:14).stroke(enrollment == nil ? Dopa.stroke:Dopa.lime.opacity(0.6),lineWidth:1))


    }
}
struct ChallengeDetail:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) private var dismiss
    var challenge:WorkoutChallenge
    var onBrowse:(String?)->Void
    @State private var confirmLeave=false
    @State private var confirmPractice=false
    @State private var program:WorkoutProgram?
    var enrollment:ChallengeEnrollment? {store.activeEnrollment(challenge.id)}
    var progress:Set<Date> {enrollment.map{WorkoutCalendarLogic.progress(challenge,enrollment:$0,history:store.data.history,practices:store.data.challengePractices ?? [])} ?? []}
    var body:some View {
        VStack(spacing:0){
            SheetTitle(title:"Thử thách")
            ScrollView{VStack(alignment:.leading,spacing:20){
                ChallengePhoto(challengeID:challenge.id).frame(height:220).clipShape(RoundedRectangle(cornerRadius:12))
                Text(challenge.title).font(.dopa(size:29,weight:.bold))
                Text(challenge.subtitle).font(.dopa(size:17)).foregroundStyle(Dopa.muted)
                HStack{Label("\(challenge.days) ngày",systemImage:"calendar");Spacer();Text("\(progress.count)/\(challenge.targetDays) "+(challenge.manualPractice ? "ngày thực hành":"ngày đã tập")).foregroundStyle(Dopa.lime)}.font(.dopa(size:14,weight:.semibold))
                ProgressView(value:min(1,Double(progress.count)/Double(challenge.targetDays))).tint(Dopa.lime)
                Text(enrollment == nil ? "Tham gia để bắt đầu từ hôm nay. Tiến độ tính theo ngày thực hành phù hợp sau khi tham gia.":"Mỗi ngày được tính một lần sau khi tham gia. Buổi có set phù hợp đã ghi sẽ cập nhật tự động; thử thách thực hành dùng ghi nhận thủ công.").font(.dopa(size:15)).foregroundStyle(Dopa.muted)
                if challenge.manualPractice {practiceInstructions}
                if let enrollment {
                    let calendar=WorkoutCalendarLogic.calendar(),start=calendar.startOfDay(for:enrollment.started)
                    LazyVGrid(columns:Array(repeating:GridItem(.flexible()),count:7),spacing:12){ForEach(0..<challenge.days,id:\.self){offset in
                        let date=calendar.date(byAdding:.day,value:offset,to:start)!,done=progress.contains(date)
                        VStack(spacing:5){Text("\(offset+1)").font(.dopa(size:15,weight:.semibold)).frame(width:34,height:34).background(done ? Dopa.lime:Dopa.raised).foregroundStyle(done ? .black:.white).clipShape(Circle());if done{Image(systemName:"checkmark").font(.dopa(size:9)).foregroundStyle(Dopa.lime)}else{Color.clear.frame(height:9)}}
                    }}
                    Button("Rời thử thách"){confirmLeave=true}.font(.dopa(size:14)).foregroundStyle(Dopa.muted).padding(.top,8)
                }
            }.padding(20)}
            VStack(spacing:10){
                if enrollment==nil{DopaButton(title:"Tham gia thử thách"){store.joinChallenge(challenge.id)}}
                else if challenge.manualPractice {
                    let done=progress.contains(WorkoutCalendarLogic.calendar().startOfDay(for:Date()))
                    DopaButton(title:done ? "Đã thực hành hôm nay":"Ghi nhận hôm nay",enabled:!done){confirmPractice=true}
                    if done{Button("Bỏ ghi nhận hôm nay"){_ = store.recordPractice(challenge.id,remove:true)}.font(.dopa(size:14)).foregroundStyle(Dopa.muted).frame(minHeight:44)}
                } else{DopaButton(title:progress.count>=challenge.targetDays ? "Đã đạt mục tiêu · Xem buổi tập":"Xem buổi tập gợi ý"){program=WorkoutProgramCatalog.suggested(for:challenge)}}
            }.padding(20)
        }.background(Dopa.background).presentationDragIndicator(.visible)
        .sheet(item:$program){p in NavigationStack{WorkoutProgramDetail(program:p).environmentObject(store)}}
        .alert("Ghi nhận đã thực hành hôm nay?",isPresented:$confirmPractice){Button("Hủy",role:.cancel){};Button("Đã thực hành"){_ = store.recordPractice(challenge.id)}}message:{Text("Chỉ ghi nhận khi bạn đã thực hành. Thao tác này không tạo buổi tập hoặc ghi dữ liệu Apple Health.")}
        .alert("Rời thử thách?",isPresented:$confirmLeave){Button("Tiếp tục",role:.cancel){};Button("Rời thử thách",role:.destructive){store.leaveChallenge(challenge.id)}}message:{Text("Lịch sử tập của bạn vẫn được giữ lại.")}
    }
}

/// Image and text have separate bounds so captions cannot hide the movement.
struct ChallengePhoto:View {
    var challengeID:String
    var body:some View {DiscoveryPhoto(asset:"challenge-"+challengeID)}
}
private extension ChallengeDetail {
    var practiceInstructions:some View {
        VStack(alignment:.leading,spacing:12){
            Text(challenge.id=="pelvic-14" ? "Thực hành sàn chậu":"Giãn cơ theo cảm nhận").font(.dopa(size:19,weight:.semibold))
            if challenge.id=="pelvic-14" {
                Text("Ngồi, đứng hoặc nằm thoải mái. Nhẹ nhàng siết và nâng cơ sàn chậu, sau đó thả lỏng hoàn toàn; thở bình thường. Tránh siết bụng, mông hoặc đùi. Không tập bằng cách ngắt dòng tiểu; dừng nếu đau.").font(.dopa(size:15)).foregroundStyle(Dopa.muted)
                Link("Xem hướng dẫn từ NHS",destination:URL(string:"https://www.cuh.nhs.uk/patient-information/pelvic-floor-exercises-in-men-frequently-asked-questions/")!).font(.dopa(size:15,weight:.medium)).foregroundStyle(Dopa.lime).frame(minHeight:44)
                Text("Ảnh minh hoạ tư thế thư giãn. Ghi nhận thói quen không đo kỹ thuật co cơ hay kết quả điều trị.").font(.dopa(size:13)).foregroundStyle(Dopa.muted)
            } else {
                Text("Chọn những động tác giãn nhẹ cho vai, lưng và hông. Di chuyển chậm trong biên độ thoải mái, thở đều và không nảy ép. Ghi nhận sau khi bạn đã thực hành.").font(.dopa(size:15)).foregroundStyle(Dopa.muted)
            }
        }.padding(16).frame(maxWidth:.infinity,alignment:.leading).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
    }
}
