# Audit Home —10/11/2026

Phạm vi: screenshot user14:48 + sourceSwiftUI + simulator trước/sau. Đối tượng: người mới và người tậpgymđều. Mục tiêu chính: biết hôm nay tập gì → điều chỉnh nếu cần → bắt đầu/ghi buổi. Giữ dark/lime/SF theo user. Hai đánh giá độc lập bằng subagents theo skillcritique; không xem output của nhau. Không chạy deterministic impeccable detector vì chỉ hỗ trợ HTML/JSX, không SwiftUI; không có detectorpass hoặc browseroverlay.

## Kết luận

Bố cục cũ có style thống nhất nhưng ưu tiên sai: discovery vàảnhchallenge trước danh sách7bài mà CTAđangmờiStart. Điểm cơ hội lớn nhất là ưu tiên tác vụ tập, không đổi palette/font. Bản sau đưa danh sách lên đầu, discovery/challenge vẫn cuộn tới được; C84/C87.

## Heuristics trước sửa (đánh giá chuyên gia, provisional)

| Heuristic | /4 | Nhận định giới hạn |
|---|---:|---|
| Trạng thái hệ thống |3|Ngày đang chọn/tab/goal rõ, goal thiếuđơnvị|
| Ngôn ngữ thực tế |3|Copy chủyếudễhiểu, suggestionskhácthântrên|
| Quyền điều khiển |2|Cóclose/back/date-return; chưa testmọibranchthaydraft|
| Nhất quán |3|Dark/SF/limeđúngbrief, Addtrùng|
| Ngăn lỗi |2|Draftswitch/loadtemplate cần auditdestructiveguard|
| Nhận biết thay ghi nhớ |2|Khôngthấybàihômnaytrênfirstviewport|
| Hiệu quả |3|Startnhanh, controlsduration/gym|
| Tối giản |2|Discoverylấncore,3Add|
| Khôi phục lỗi |2|Provisionalmidpoint, chưa fault-inject; khônggọiđạt|
| Trợ giúp |2|Cóhint/cue, chưatestbeginnerthật|
| **Tổng** |**24/40**|Không phải điểm đo người dùng hay full-app score|

Không chấmđiểm sau đểtự chứngnhận. Cognitivechecklisttrướcsửa:3/8failure=moderate (singlefocus,onethingatatime,progressivedisclosure).7ngàycalendar là selectorquen thuộc, không coi7optionslàlỗimáymóc. Không códấuhiệugenericAIrõ; lime/dark/SF làconstraintcó chủý. Captionchallenge nằmngoàifirstviewport, khôngphảibằngchứngbịCTAđè vĩnhviễn. C87 xácminhcuộncuốithấyđủcaption.

## Findings và hành động

| Mức | Finding | Sửa / còn mở |
|---|---|---|
|P1|Bài hômnay sau2discoveryshelves|Đưa listngay sauheader/settings, trước saved/discovery/challenge. C84thấy4bàiđầutrướcStart|
|P2|3Addcùngsheet,2visiblecùnglúc|Giữ1stickyAdd cóiconvànhãn, bỏheader/listfooterduplicate; mở/đóngpicker32bài đãkiểm|
|P2|Nhóm cơhardcode5/6, Englishtitle/Resume khôngtheodraft|Uniqueprimarycount: hiện5nhóm; actualdrafttitle/hasStarted+completed. Không đổidữliệuđểkhớpnhãn|
|P2|Suggestions chân sau tênngàythântrêngâyhiểunhầm|Đặt sau workout, copy “Khám phá thêm bài theo nhóm cơ”; khônggọi recommendationgốc|
|P3|1/3khôngrõđếm gì|“Tuần này1/3ngày tập”, đúngunique trainingdays. Dateheader/selectedtoday/trainedAXlabelsđượcgắn|
|P2|Overflowtargetnhỏ/generic|44ptbounds, nhãn “Tùy chọn: [bài]”; dateheaderhitarea/DynamicType/mànnhỏ/VoiceOverđầutớiđuôivẫncầnđo|
|P3|Blankwhiteavatar khôngcóýnghĩa|Đổi sangplan-controlsystemicon, giữlinkMyPlan|

Người mới trước sửa: không biết7bài làgì, upperbodyvslegssuggestionsmâuthuẫn. Sau sửa: xemthẳngtên/sets/reps/loadtrướcStart, copythêmbàicórõ. Người tậpđều trước sửa: phải cuộnquakhámpháđểkiểmexerciseorder; sau sửa listđầutrang/1Add/thumbguide. Người dùngVoiceOver: labelsđãcải thiện, chưa chạyVoiceOversession/DynamicTypethật nênkhông tuyênbốđạt.

## QA và giới hạn

C84 currentHomeorder/count/singleAdd; C83Rowguideupscaleandcap; C85speed0.5×; C86actual2history720/765vàngàytrởvề; C87discoverybelowworkout/captionsreachable; C88squatvisible. Add→picker32→Close khôngghi. KhôngStart/log/finish buổi đểtestlayout.87modelcheckspassedvàDebugbuild/install/launchpass; khôngthay UI testbằngbuild.

Còn mở:44ptdateheaderhitarea, DynamicType/longcustomgym/smalliPhone, Englishmọistring, VoiceOverfocusorder, ReduceMotionthật, before/afterFPS/CPU, destructiveguards switch/refresh/template trênbuổiđangghi. Media180pxchỉcải thiệnviềnquaLanczos720; cầnnativeHDđểnétthật. Khôngkhẳngđịnhmọifeature/parityxong.

Thứ tự xử lý tương ứngskill:layout(corefirst)→clarify(copy/count/state)→distill(duplicateAdd)→polish(alignment/labels), đãthựchiệncácroutinefixtrongscopeđượcuserduyệt. Khôngcầnhỏilạimàu/font/phạmvingườimới-vàđềuvìđãchốt.
