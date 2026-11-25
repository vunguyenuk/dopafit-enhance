import SwiftUI

struct ReminderPreviewStep: View {
    @Binding var hour: Int?
    var day: Date
    var minutes: Int
    private let hours = [8, 12, 17, 18, 20]
    var body: some View {
        OnboardingPage(title: "Nhắc bạn vào [buổi đầu] nhé?", subtitle: "Một lời nhắc nhỏ vào ngày bạn chọn. Các buổi khác chưa được tự lên lịch.") {
            VStack(spacing: 28) {
                VStack(spacing: 7) {
                    Text(Fmt.day(day)).font(T.font(14, .medium)).foregroundStyle(T.sub)
                    Text(String(format: "%02d:00", hour ?? 18)).font(T.num(68, .semibold)).foregroundStyle(T.text)
                }.padding(.top, 25)
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "dumbbell.fill").font(T.font(19)).foregroundStyle(T.bg)
                        .frame(width: 38, height: 38).background(T.lime, in: RoundedRectangle(cornerRadius: 11))
                    VStack(alignment: .leading, spacing: 5) {
                        HStack { Text("Dopafit").font(T.font(12, .medium)); Spacer(); Text("bây giờ").font(T.font(11)) }.foregroundStyle(T.sub)
                        Text("Hôm nay có buổi tập \(minutes) phút").font(T.font(15, .semibold)).foregroundStyle(T.text)
                        Text("Bắt đầu khi bạn sẵn sàng nhé.").font(T.font(14)).foregroundStyle(T.sub)
                    }
                }.padding(16).background(T.raised, in: RoundedRectangle(cornerRadius: 21))
            }.padding(18).padding(.bottom, 10).background(T.surface, in: RoundedRectangle(cornerRadius: 30))
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(T.line))
            Text("Nhắc lúc").font(T.font(14, .medium)).foregroundStyle(T.sub)
            HStack(spacing: 7) {
                ForEach(hours, id: \.self) { value in
                    Button { hour = hour == value ? nil : value } label: {
                        Text(String(format: "%02d:00", value)).font(T.num(15, .semibold))
                            .foregroundStyle(hour == value ? T.bg : T.text).frame(maxWidth: .infinity).frame(height: 49)
                            .background(hour == value ? T.lime : T.surface, in: RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain).accessibilityAddTraits(hour == value ? .isSelected : [])
                }
            }
            if let hour, Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: day).map({ $0 <= Date() }) == true {
                Label("Giờ này đã qua. Quay lại chọn ngày khác hoặc để sau.", systemImage: "clock.badge.exclamationmark")
                    .font(T.font(13)).foregroundStyle(T.warn)
            }
            Button { hour = nil } label: {
                HStack { Text("Để sau"); Spacer(); ChoiceRadio(selected: hour == nil) }
                    .font(T.font(16, .medium)).foregroundStyle(T.sub).frame(height: 44)
            }.buttonStyle(.plain)
            Label("Bạn quyết định có cho phép thông báo ở bước tiếp theo.", systemImage: "bell.badge")
                .font(T.font(13)).foregroundStyle(T.sub)
        }
    }
}
