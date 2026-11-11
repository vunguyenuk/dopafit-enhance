import SwiftUI

// R39–R41, observed after the original app's sign-in. No transaction or biometric request.
struct PostSetupFlow:View {
    @EnvironmentObject var store:AppStore
    var complete:()->Void
    @State private var page=0
    @State private var holding=false
    @State private var offer=false
    var body:some View {
        ZStack {
            LinearGradient(colors:[Dopa.raised,Dopa.card,Dopa.background],startPoint:.topLeading,endPoint:.bottomTrailing).ignoresSafeArea()
            if page==0 { ready } else if page==1 { promise } else { pro }
        }.animation(.easeInOut(duration:0.25),value:page)
            .sheet(isPresented:$offer) {
                VStack(spacing:22) {
                    SheetTitle(title:"Dopafit Pro")
                    Text("Plan riêng, lịch sử và tiến bộ của bạn").font(.dopa(size:22,weight:.bold)).multilineTextAlignment(.center)
                    Text("$56.99 / năm").dopaTitle(32)
                    Text("Giá tham chiếu từ màn hình đã khảo sát. Bản thử chưa kết nối thanh toán Apple.").foregroundStyle(Dopa.muted).multilineTextAlignment(.center).padding(.horizontal,20)
                    DopaButton(title:"Tiếp tục bản thử") { offer=false;complete() }.padding(20)
                }.dopaSheet().presentationDetents([.medium])
            }
    }
    var ready:some View {
        VStack(alignment:.leading,spacing:16) {
            Spacer(minLength:30)
            Label("PLAN ĐÃ XONG",systemImage:"checkmark.circle.fill").font(.dopa(size:13,weight:.bold)).tracking(1).foregroundStyle(Dopa.lime)
            Text("Ngày đầu của bạn\nlà hôm nay").dopaTitle(30)
            Text("Bạn chỉ cần có mặt, plan lo phần còn lại.").font(.dopa(size:17)).foregroundStyle(Dopa.muted)
            HStack(spacing:14) {
                Image(systemName:"checkmark.circle.fill").font(.title).foregroundStyle(Dopa.blue)
                VStack(alignment:.leading,spacing:4) {Text("Tuần đầu của bạn").font(.dopa(size:18,weight:.semibold));Text("\(store.data.plan.goal) · \(store.data.plan.days) buổi tập / tuần · \(store.data.plan.minutes) phút").font(.dopa(size:15)).foregroundStyle(Dopa.muted)}
            }.padding(18).frame(maxWidth:.infinity,alignment:.leading).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
            Text("CÙNG MỤC TIÊU TĂNG SỨC MẠNH").font(.dopa(size:12,weight:.bold)).foregroundStyle(Dopa.muted)
            ReferenceCrop(asset:"reference-plan-ready",rect:[30,880,795,610]).aspectRatio(795/610,contentMode:.fit)
            Spacer(minLength:20)
            DopaButton(title:"Tôi sẵn sàng rồi") { page=1 }
        }.padding(16)
    }
    var promise:some View {
        VStack(spacing:22) {
            Spacer(minLength:45)
            Text("LỜI HỨA VỚI CHÍNH MÌNH").font(.dopa(size:12,weight:.bold)).tracking(1).foregroundStyle(Dopa.muted)
            Text("Tôi sẽ tập").font(.dopa(size:26,weight:.medium)).foregroundStyle(Dopa.muted)
            Text("\(store.data.plan.days) buổi mỗi tuần").font(Dopa.metricFont(36)).minimumScaleFactor(0.7).lineLimit(1)
            Text("\(store.data.plan.minutes) phút mỗi buổi.").font(.dopa(size:20)).foregroundStyle(Dopa.muted)
            HStack(spacing:12) {
                ForEach(Array(["T2","T3","T4","T5","T6","T7","CN"].enumerated()),id:\.offset) { i,day in
                    let selected=(store.data.plan.trainingDays ?? [2,4,6]).contains(i==6 ? 1:i+2)
                    VStack(spacing:8) {Image(systemName:selected ? "checkmark":"").font(.dopa(size:20,weight:.bold)).frame(maxWidth:.infinity).frame(height:38).background(selected ? .white:Dopa.raised).foregroundStyle(.black).clipShape(RoundedRectangle(cornerRadius:12));Text(day).font(.dopa(size:12,weight:.bold)).foregroundStyle(selected ? .white:Dopa.muted)}
                }
            }.padding(.vertical,18)
            Text("Không cần hoàn hảo.\nChỉ cần không bỏ giữa chừng.").font(.dopa(size:21,weight:.medium)).multilineTextAlignment(.center)
            Spacer(minLength:50)
            Image(systemName:"touchid").font(.dopa(size:42)).frame(width:100,height:100).background(holding ? Dopa.lime:Dopa.raised).foregroundStyle(holding ? .black:.white).clipShape(Circle()).padding(12)
                .overlay(Circle().stroke(holding ? Dopa.lime:Dopa.raised,lineWidth:4)).scaleEffect(holding ? 1.08:1)
                .onLongPressGesture(minimumDuration:2,maximumDistance:60,perform:{page=2},onPressingChanged:{value in withAnimation(.easeInOut(duration:0.2)){holding=value}})
                .accessibilityLabel("Giữ để hứa").accessibilityHint("Nhấn giữ 2 giây để tiếp tục")
                .accessibilityAddTraits(.isButton).accessibilityAction { page=2 }
            VStack(spacing:5) {Text("Giữ để hứa").font(.dopa(size:18,weight:.bold));Text("Nhấn giữ 2 giây").foregroundStyle(Dopa.muted)}
        }.padding(.horizontal,24).padding(.bottom,22)
    }
    var pro:some View {
        VStack(spacing:14) {
            Text("Plan của bạn mạnh nhất\nkhi có Pro.").dopaTitle(29).multilineTextAlignment(.center).padding(.top,32)
            Text("Tập không giới hạn mọi plan, theo dõi từng kỷ lục.").font(.dopa(size:17)).foregroundStyle(Dopa.muted).multilineTextAlignment(.center)
            Spacer(minLength:10)
            ReferenceCrop(asset:"reference-pro-intro",rect:[16,630,832,620]).aspectRatio(832/620,contentMode:.fit)
            Spacer(minLength:20)
            Label("400+ bài tập có video mẫu",systemImage:"play.fill").font(.dopa(size:17,weight:.bold)).foregroundStyle(.white)
            Text("Plan riêng theo mục tiêu của bạn").font(.dopa(size:15)).foregroundStyle(Dopa.muted)
            Text("$56.99/năm").dopaTitle(28)
            Text("Tự động gia hạn $56.99/năm cho đến khi bạn hủy trong Cài đặt Apple.").font(.dopa(size:14)).foregroundStyle(Dopa.muted).multilineTextAlignment(.center)
            DopaButton(title:"Xem gói Pro") { offer=true }
        }.padding(16)
    }
}
