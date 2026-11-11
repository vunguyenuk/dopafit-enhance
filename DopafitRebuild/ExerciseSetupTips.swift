import SwiftUI

/// Chuẩn bị/chỉnh máy và lỗi hay gặp, cho người mới. Dịch và rút gọn từ metadata MIT của free-exercise-db-with-videos
/// (third_party/zenith-video/zenith-mapping.json), phần chỉnh máy viết thêm cho máy/cáp/ghế.
enum ExerciseSetupTips {
    static let setup:[String:[String]]=[
        "tbar":["Lắp tạ vào đầu thanh, đứng hai chân hai bên thanh.","Gập hông, lưng thẳng, ngực hướng xuống sàn trước khi kéo."],
        "incline":["Chỉnh ghế dốc khoảng 30–45°.","Nằm sao cho mắt ở ngay dưới thanh đòn, bàn chân đặt chắc trên sàn."],
        "closebench":["Nằm thẳng trên ghế, mắt dưới thanh đòn.","Nắm thanh hẹp hơn vai một chút, cổ tay thẳng."],
        "tricep":["Gắn dây thừng vào ròng rọc trên cao, đứng đối diện máy.","Khuỷu tay ép sát hông và giữ yên suốt bài."],
        "squat":["Chỉnh giá đỡ ngang ngực trên, đặt thanh lên phần vai sau.","Chân rộng bằng vai, bước lùi ra 1–2 bước rồi mới tập."],
        "rdl":["Đứng chân rộng bằng hông, thanh đòn sát đùi.","Gối hơi chùng và giữ nguyên độ chùng đó."],
        "adductor":["Chỉnh ghế để gối thẳng hàng với trục xoay của máy.","Ngồi thẳng, lưng tựa sát đệm, chân đặt phía ngoài miếng đệm đùi."],
        "arnold":["Dùng ghế có tựa lưng, ngồi thẳng, bàn chân đặt chắc.","Cầm tạ trước vai, lòng bàn tay hướng vào người."],
        "reversefly":["Hạ hai tay cầm cáp xuống ròng rọc thấp, đứng giữa hai cột.","Tay phải cầm dây bên trái và ngược lại, bước lên một bước cho dây căng."],
        "machinefly":["Chỉnh ghế để tay cầm ngang vai khi ngồi.","Ép ngực vào đệm, bàn chân đặt trên sàn."],
        "frontraise":["Gắn tay cầm vào ròng rọc thấp, đứng quay lưng về máy.","Cầm tay cầm một tay, tay duỗi dọc thân."],
        "dumbbell-skullcrusher":["Nằm trên ghế phẳng, đẩy tạ lên trên ngực, hai lòng bàn tay hướng vào nhau."],
        "incline-dumbbell-curl":["Chỉnh ghế dốc 45–60°, ngồi tựa lưng, để tay buông thẳng hai bên."],
        "dumbbell-shoulder-press":["Dùng ghế có tựa lưng, ngồi thẳng, bàn chân đặt chắc trên sàn."],
        "discovery-wristcurl":["Ngồi cạnh ghế, đặt cẳng tay lên mặt ghế, cổ tay thò ra ngoài mép ghế."]
    ]
    static let mistakes:[String:[String]]=[
        "tbar":["Võng lưng dưới","Không duỗi hết tay khi hạ","Nảy tạ"],
        "incline":["Bẻ khuỷu tay sang ngang","Nảy thanh khỏi ngực","Nhấc chân hoặc xê dịch trên ghế"],
        "closebench":["Nắm quá hẹp hoặc quá rộng","Khuỷu tay mở ra ngoài","Nảy thanh khỏi ngực"],
        "tricep":["Khuỷu tay mở ra ngoài","Dùng đà người","Không duỗi hết tay"],
        "squat":["Gối đổ vào trong","Cong lưng dưới","Nhấc gót khỏi sàn"],
        "rdl":["Gập gối thành squat khi hạ thanh","Để thanh trôi xa chân","Cong lưng dưới ở cuối động tác"],
        "adductor":["Ngả người ra trước, lưng rời đệm","Để đệm bật mở khi về","Đẩy nảy, biên độ ngắn"],
        "arnold":["Võng lưng khi đẩy tạ lên","Khuỷu tay mở ngang ở dưới","Đẩy lên mà không xoay tay"],
        "reversefly":["Đứng thẳng người, thành bài kéo","Co duỗi khuỷu tay trong lúc tập","Nhún vai lên tai"],
        "machinefly":["Nhún vai lên tai","Duỗi thẳng khuỷu tay thành bài đẩy","Ngực rời khỏi đệm"],
        "frontraise":["Dùng đà người","Nhún vai","Nâng quá cao"],
        "bent-over-dumbbell-row":["Cong lưng","Giật tạ","Không duỗi hết tay"],
        "dumbbell-skullcrusher":["Khuỷu tay mở rộng khi hạ","Bắp tay trên đưa ra trước hoặc sau","Hạ tạ quá thấp ra sau đầu"],
        "ez-curl":["Dùng đà người","Đưa khuỷu tay ra trước","Làm nửa biên độ"],
        "dumbbell-curl":["Lắc người để nhấc tạ","Khuỷu tay trôi ra trước","Không hạ tạ hết"],
        "dumbbell-shrug":["Xoay vai thành vòng tròn","Co khuỷu tay","Ngả người để vung tạ"],
        "incline-dumbbell-curl":["Vung tay lấy đà","Khuỷu tay trôi ra trước","Làm nửa biên độ"],
        "dumbbell-lateral-raise":["Nhún vai lên tai","Lắc người để hất tạ","Nâng tay cao quá vai"],
        "dumbbell-shoulder-press":["Võng lưng nhiều","Hạ tạ quá nhanh","Hạ khuỷu tay quá thấp"],
        "goblet-squat":["Để tạ rời khỏi ngực","Nhấc gót ở đáy","Gối đổ vào trong"],
        "discovery-crunch":["Kéo cổ","Không siết bụng","Dùng đà người"],
        "discovery-pushup":["Võng hông","Khuỷu tay mở quá rộng","Không xuống hết biên độ"],
        "discovery-wristcurl":["Nhấc cẳng tay khỏi ghế","Vung tạ thay vì chỉ cử động cổ tay","Không hạ cổ tay hết"],
        "discovery-bodysquat":["Gối đổ vào trong","Cong lưng dưới","Ngồi chưa đủ sâu"]
    ]
}

struct ExerciseTipsCards:View {
    var exercise:Exercise
    var body:some View {
        VStack(alignment:.leading,spacing:12){
            if let steps=ExerciseSetupTips.setup[exercise.id] {card("Chuẩn bị trước khi tập","slider.horizontal.3",steps,Dopa.lime)}
            if let list=ExerciseSetupTips.mistakes[exercise.id] {card("Lỗi hay gặp","exclamationmark.triangle",list,Color.orange)}
        }
    }
    func card(_ title:String,_ icon:String,_ lines:[String],_ tint:Color)->some View {
        VStack(alignment:.leading,spacing:10){
            Label(title,systemImage:icon).font(.dopa(size:16,weight:.semibold)).foregroundStyle(tint)
            ForEach(lines,id:\.self){line in
                HStack(alignment:.firstTextBaseline,spacing:8){Text("•").foregroundStyle(Dopa.muted);Text(line).font(.dopa(size:15)).foregroundStyle(.white.opacity(0.9)).fixedSize(horizontal:false,vertical:true)}
            }
        }.padding(14).frame(maxWidth:.infinity,alignment:.leading).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
    }
}
