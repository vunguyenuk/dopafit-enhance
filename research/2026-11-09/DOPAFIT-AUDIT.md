# Dopafit — audit sản phẩm trên thiết bị

Ngày: **09/11/2026, giờ Việt Nam**. Đối tượng được người dùng xác nhận: **người mới và người tập gym đều**. Tài khoản test đã được cho phép ghi dữ liệu tập giả. Đây là audit giao diện/hành vi truy cập được trên một thiết bị; không phải chứng nhận thuật toán, an toàn tập luyện hay accessibility.

## 1. Phạm vi và cách xác thực

Quan sát qua iPhone Mirroring, lưu ảnh theo ID trong `evidence`. Workspace ban đầu không có source code app. Mirroring có hiển thị tên thiết bị iPhone 14 Pro Max khi kết nối. Chưa xác minh phiên bản iOS và build Dopafit đang cài; không suy ra build từ email thông báo TestFlight hoặc tên file. Không reset tài khoản hoặc thanh toán để mở các luồng ngoài trạng thái được cấp.

Điện thoại mở app có sẵn kế hoạch: mục tiêu “Khỏe hơn”, kinh nghiệm “Trung bình”, 3 buổi/tuần, 1 giờ, split thân trên/thân dưới, 65 dụng cụ được chọn. Đây là trạng thái tài khoản hiện có, **không phải kết luận về mặc định của mọi người dùng**. Thời gian chờ mirroring và những lần Mac tự khoá không được ghi là bug Dopafit.

P0 = chặn hoàn tất tác vụ đã tái hiện; P1 = ảnh hưởng lớn đến độ hiểu/độ tin cậy; P2 = ma sát có workaround; P3 = hoàn thiện. Mức ưu tiên đề xuất không tự biến một rủi ro thành lỗi kỹ thuật đã xác nhận.

## 2. Ma trận phủ luồng — sau kiểm thử trực tiếp

Đã lưu **58 ảnh Dopafit D01–D58**, tương ứng các màn/trạng thái, không phải 58 màn độc lập. Có thêm F01 là paywall Fitbod trên thiết bị. Danh mục và ghi chú nằm ở [EVIDENCE-INDEX.md](EVIDENCE-INDEX.md).

| Luồng | Kết quả | Bằng chứng / giới hạn |
|---|---|---|
| Mở app tài khoản hiện có | Đã quan sát | D01; vào buổi thân trên; D57 sau lưu chuyển sang thân dưới |
| Xem bài, sets/reps/tạ | Đã quan sát | D01, D17, D57; 7 bài ở mỗi buổi hiển thị |
| Menu bài và menu buổi | Đã mở | D02, D51, D58; có save, superset/circuit, refresh; chưa thực thi các chức năng menu buổi |
| Video, hướng dẫn, nhóm cơ | Đã mở và xem | D04–D05 có video, hướng dẫn và nhóm cơ; chưa xác minh nhiều góc quay hoặc QA toàn thư viện. D23 là màn nhập set với timer, tên file cũ gây nhầm. |
| History chưa có / đã có dữ liệu | Đã đối chiếu | D03 → D52; đúng 3 set 6 × 42.5 kg sau lưu |
| Chọn thời lượng, gym | Đã xem UI | D06–D07; scope hôm nay/mặc định; chưa áp dụng đổi gym/thời lượng |
| Kế hoạch, split, dụng cụ/nấc tạ | Đã mở | D08–D12; chưa thay cấu hình gốc |
| Start và chỉnh reps | Đã thao tác | D17–D19; sửa hàng đầu từ 6 lên 8, các hàng chưa log cùng đổi |
| Nhập mức tạ / validation | Một phần | D20: giá trị 0 làm nút log bị vô hiệu; nhập 40 qua Mac không tin cậy, chưa kết luận app lỗi input |
| Quy ước tạ đòn | Đã thấy tại nhập set | D21: có nhãn “Gồm thanh đòn” và entry tính bánh tạ |
| Log từng set / cả bài | Đã thao tác | D25, D27–D28; log all có xác nhận và lựa chọn không hỏi lại; chỉ chọn xác nhận thường |
| Timer, pause | Đã thao tác | D22, D25–D26: bật 2:00, countdown chạy rồi pause; chưa kiểm tra resume/chuông khi khóa màn hình |
| Khôi phục buổi dở | Đã quan sát một tình huống | D24: còn bài và rest setting sau ngắt mirroring/iPhone được dùng; không tương đương force quit/offline/crash |
| RIR | Đã chọn và đối chiếu sau lưu | D29 chọn còn 2 reps, D51 vẫn giữ đúng |
| Đổi bài đang tập | Đã thao tác | D31–D33: face pull cáp → face pull dây kháng lực, có prompt ảnh hưởng kế hoạch; chọn Bỏ qua |
| Finish / summary / nhật ký | Đã hoàn tất | D34–D37, D50: lưu đúng 1 bài, 3 set, 765 kg; buổi 11:23; không cộng bài chưa log |
| Mục tiêu tuần trước/sau | Đã đối chiếu | D15 → D38–D39: 0 → 6/65 set quy đổi, 9%; có giải thích cơ chính/phụ |
| Recovery trước/sau và help | Đã đối chiếu | D14 → D40–D41: thay đổi nhóm cơ; help công khai mô hình ước tính |
| Strength / benchmark / trend | Đã mở | D13, D42, D53–D56: history có 1RM 51 kg; tổng điểm vẫn khóa 3 buổi; benchmark placeholder còn 00 |
| Báo cáo tập luyện | Đã đổi khoảng xem | D45–D47: mặc định tuần trước; chọn 7 ngày qua hiện 1 buổi và chart 51 kg |
| Background → quay lại | Đã quan sát | D55 giữ màn và dữ liệu; chưa force quit / relaunch cold start |
| Settings, membership, profile | Đã mở | D43, D48; Pro; profile nhập tay không bắt buộc; Health chưa kết nối |
| Export | Đã gọi entry | Mở system share sheet; không gửi ra ngoài; chưa đọc định dạng/nội dung file xuất |
| Ngôn ngữ | Đã mở danh sách | D44 có theo máy / Tiếng Việt / English; chưa chuyển và QA en-US |
| Support / pháp lý / build | Chưa xác minh đầy đủ | Thấy heading Hỗ trợ; thao tác cuộn settings không tới các row dưới; chưa quy lỗi cho app |
| Onboarding mới / paywall Dopafit / restore | Chưa kiểm tra | Tài khoản Pro đã thiết lập; không reset, đăng xuất hay mua |
| en-US, lb, 45 lb bar và chuyển đổi | Chưa kiểm tra hành vi | Có lựa chọn kg/lb ở D09; chưa áp dụng và đối chiếu dữ liệu |
| Watch / Health / offline / đa thiết bị | Chưa kiểm tra | Chưa cấp quyền Health hoặc có quy trình test thiết bị phù hợp |
| VoiceOver / Dynamic Type / contrast / hit area | Chưa đo | Không chấm đạt/vi phạm từ screenshot hay AX của Mirroring |

### Dữ liệu test và trạng thái bàn giao

- Đã lưu **1 buổi tập giả**, ngày 09/11/2026, bắt đầu hiển thị 09:37: **đẩy ngực tạ đòn ghế dốc lên, 3 set × 6 reps × 42.5 kg, RIR cuối = 2**.
- Tổng khối lượng 3 × 6 × 42.5 = **765 kg**, xuất hiện nhất quán ở summary, nhật ký và report. History giữ đúng từng set. Không có bằng chứng nhân đôi trong case này.
- Timer của bài này được bật 2:00 rồi pause. Buổi được lưu đã kết thúc; app đang ở màn **Ngày thân dưới**, nút **Bắt đầu buổi tập**, không còn chạy buổi test.
- T-Bar draft từng có 8 reps / 0 kg do thử nhập; không log. Face pull được đổi nhưng không log. Cả hai không xuất hiện như bài đã thực hiện trong buổi đã lưu.
- Apple Health giữ **chưa kết nối**, tùy chọn đồng bộ khi finish để tắt. Không ghi dữ liệu tập giả sang Health, không đăng ký trial Fitbod, không gửi share/export.
- Thời lượng 11:23 gồm thời gian thao tác audit và gián đoạn; **68 kcal là app ước tính trên buổi giả**, không phải năng lượng con người đã tiêu hao.

## 3. Những gì đang làm tốt

1. **Vào app là có việc để làm.** D01 đặt buổi hôm nay và nút bắt đầu ở vị trí rõ; thông tin bài, thời lượng, gym có sẵn. Điều này hợp với nhu cầu giảm quyết định của Fitbod/Gravl.
2. **Không giấu mức khởi đầu là ước lượng.** Card D01 nói mức tạ dựa trên câu trả lời và sẽ sát hơn qua điều chỉnh. Đây là cách đặt kỳ vọng hợp lý. Đã thấy log và trend được cập nhật; chưa chứng minh target cá nhân hóa qua nhiều tuần.
3. **Thư viện hướng dẫn có nhiều lớp.** D04–D05 có video, mô tả, nhóm cơ chính/phụ và dụng cụ. Một màn có thể phục vụ người mới học bài và người tập đều tra nhanh.
4. **Có kiểm soát thiết bị thực.** D11–D12 cho thấy lựa chọn nấc tạ và bar weight; không nên kết luận Dopafit thiếu cấu hình tạ như một số app khác.
5. **Scope thay đổi thời lượng đã được thể hiện bằng chữ.** “Chỉ cho buổi này” / “Đặt làm mặc định” là điểm tốt của D06. Cần kiểm thử hành vi trước khi xác nhận persistence.
6. **Split có giải thích ở trang con.** D10 giải nghĩa cách chia và mô tả PPL/full body/upper-lower. Vì vậy nhận xét “mọi thuật ngữ hoàn toàn không có help” sẽ sai.
7. **Tab có nhãn chữ, trạng thái chọn có checkmark.** Không buộc người dùng nhận biết chỉ từ màu hoặc một icon không nhãn.

## 4. Phát hiện có bằng chứng ở luồng đã xem

### D-A01 · P1 · Quy ước mức tạ chưa nhất quán tại các điểm đọc target

**Quan sát:** D01 ghi 42.5 kg cho kéo T-Bar và đẩy ngực, 20 kg cho face pull; danh sách không có chú thích quy ước cạnh target. D18 nhập T-Bar chưa thấy nhãn có gồm đòn/tạ thêm. D12 dùng tiêu đề “Cặp tạ đơn” nhưng chưa nói mỗi quả hay tổng cặp. **Kiểm tra bổ sung D21 xác nhận entry tạ đòn có “Gồm thanh đòn”**, do đó nhận xét app hoàn toàn không giải thích tạ là sai.

**Tác động:** người mới và người tập chuyển app có thể hiểu khác nhau; đơn vị kg/lb chỉ giải quyết hệ đo, không giải quyết nghĩa của số. Chưa kết luận mức tạ cụ thể sai; phát hiện là độ rõ không đồng đều giữa danh sách, loại dụng cụ và entry. Chưa kiểm tra entry tạ đơn.

**Đề xuất:** quy ước theo bài, thí dụ `20 kg mỗi quả`, `tổng đã gồm đòn`, `tạ thêm`, `mức máy`; đặt ở điểm đọc/nhập và giữ xuyên history/export. Mục tiêu kiểm thử: người mới giải thích đúng số trước khi bấm log, không cần hỏi người nghiên cứu. `/clarify`.

### D-A02 · P2 · Lời giải thích tạ còn chung so với độ chính xác con số

**Quan sát:** D01 nói ước lượng từ câu trả lời, nhưng không hiện yếu tố và lý do riêng cho 42.5 kg / 6 reps của bài đó.

**Tác động:** người mới cần biết sửa thế nào; người tập đều muốn so với buổi trước và biết vì sao số thay đổi. Trong entry đã mở chưa thấy lý do riêng cho prescription; history/trend đã có số thực hiện. Chưa kiểm chứng điều chỉnh target dài hạn.

**Đề xuất:** entry “Vì sao mức này?” theo bài; phân biệt cold start, lịch sử, buổi quay lại, deload và nấc tạ gym; chỉ nêu yếu tố thực sự được thuật toán dùng. Không tạo lời giải thích tưởng tượng. `/clarify`.

### D-A03 · P2 · Hai preference đối nghịch được biểu diễn bằng hai toggle

**Quan sát:** D02 có “thường hơn” và “ít hơn” riêng, cùng “không gợi ý nữa”.

**Tác động:** mô hình thị giác giống hai boolean độc lập, trong khi ý định thường là một trục preference. Chưa chứng minh có thể bật đồng thời hoặc gây xung đột logic.

**Đề xuất:** lựa chọn một trạng thái: bình thường/thường hơn/ít hơn/loại trừ; nếu giữ toggle, phải bảo đảm loại trừ nhau và hiển thị trạng thái cuối rõ. Tách “máy bận hôm nay” khỏi sở thích dài hạn. `/shape`, `/clarify`.

### D-A04 · P2 · Bản dịch hướng dẫn cần biên tập theo đúng thiết bị

**Quan sát:** D04 có “Tải máy T-Bar Row với trọng lượng mong muốn”, và dùng cả “tay cầm” lẫn “thanh tạ” trong các câu liên tiếp.

**Tác động:** người mới phải giải mã câu trong lúc cần hiểu động tác. Một bản dịch nghe như máy làm giảm niềm tin dù video có ích.

**Đề xuất:** biên tập Việt/English bởi người hiểu bài tập, thống nhất biến thể và tên thiết bị, QA text với toàn video. Không kết luận cue nguy hiểm hoặc sai kỹ thuật chỉ từ một frame. `/clarify`.

### D-A05 · Đã hiệu chỉnh sau kiểm thử · Scope swap có bước hỏi rõ

**Quan sát ban đầu:** D02 đặt video, history, swap và preference vào cùng sheet; auditor nêu rủi ro người dùng hiểu sai scope.

**Bằng chứng sau thao tác:** D33 **có** “Cập nhật kế hoạch” sau khi swap, với ít gợi ý hơn/không gợi ý/khác/Bỏ qua. Đã chọn Bỏ qua và quay về buổi. Vì vậy **không giữ nhận xét “swap thiếu phân biệt hôm nay và lâu dài” như lỗi được xác nhận**.

**Cơ hội nhỏ:** “Chỉ đổi buổi này” có thể rõ nghĩa hơn “Bỏ qua”; cần usability test trước khi thay. Hành vi có loại trừ preference và tính bền vững qua những buổi sau vẫn chưa thử.

### D-A06 · P2 · Empty history thiếu hành động tiếp theo trong ngữ cảnh

**Quan sát:** D03 nói ghi bài trong buổi tập để có kết quả, nhưng vùng nội dung chưa có nút trở về bài/buổi phù hợp. Back và bottom tab vẫn có.

**Tác động:** lần đầu mở lịch sử chưa thấy lợi ích trước mắt, phải tự quyết định đường quay lại. Không phải blocker.

**Đề xuất:** đường quay lại buổi hiện tại; cho biết sau log sẽ xem được loại kết quả nào, tránh tạo chart giả. `/clarify`, `/layout`.

### D-A07 · P2 · Cài đặt khá dày cho người mới; trang con đã giảm một phần vấn đề

**Quan sát:** D08–D09 có kinh nghiệm, split, variability, focus, warm-up, superset và timed training; các row ở cấp danh mục ít mô tả. D10 đã có mô tả cho split.

**Tác động:** nhiều quyết định có hệ quả khác nhau được đặt ngang nhau. Người mới có thể không biết mục nào nên để app chọn; người tập đều lại cần không bị giấu quyền chỉnh.

**Đề xuất:** tóm tắt plan và mặc định gợi ý theo kinh nghiệm; những lựa chọn nâng cao có help theo ngữ cảnh. Không ép cả hai nhóm qua cùng checklist dài. `/shape`.

### D-A08 · P3 · Các lớp hình ở thumbnail tranh diện tích

**Quan sát:** D01 thumbnail bài có badge cơ đặt chồng góc; tên dài xuống dòng.

**Tác động:** trên diện tích nhỏ, nhận biết tư thế/thiết bị và nhận biết cơ cạnh tranh nhau. Chưa đo mức sai nhận diện.

**Đề xuất:** usability test ảnh rõ hơn so với badge nhỏ hơn; ưu tiên nhận diện đúng bài ở danh sách, đưa chi tiết cơ về màn đã có. Không bỏ hình cơ chỉ vì thị hiếu. `/layout`, `/polish`.

### D-A09 · P3 · Định dạng số và tên gọi cần rà theo locale

**Quan sát:** D01 có dấu chấm trong 42.5, D04 có `1,0 x`, D11–D12 dùng dấu phẩy thập phân. D11 gọi bar “Tạ đòn” trong khi nhóm thiết bị là đòn và bánh.

**Tác động:** chưa gây blocker quan sát được, nhưng locale không thống nhất làm giảm độ chỉn chu và có thể gây hiểu nhầm khi nhập/export.

**Đề xuất:** một chính sách format rõ cho en-US/vi-VN; kiểm tra số thập phân, unit, reps/time và CSV. `/clarify`, `/polish`.

### D-A10 · P1 · Thứ tự “Hợp nhất” khi thay face pull cần rà theo ý định động tác

**Tái hiện:** trong buổi active, menu bài Kéo cáp về mặt → đổi bài → sort mặc định Hợp nhất. D31 xếp đẩy vai dây có tay cầm và Arnold press trước reverse fly; face pull bằng dây kháng lực nằm thấp hơn, có cả giãn vai chéo người trong danh sách. D32 có lọc thiết bị và nhiều kiểu sort.

**Tác động:** cùng vùng vai chưa chắc thay thế cùng ý định kéo/đẩy hoặc cùng vai trò chương trình. Người mới có thể chọn mục đầu vì hiểu là khuyến nghị tốt nhất; người tập đều mất thời gian tìm bài gần ý định hơn. Đây là vấn đề thứ tự/relevance quan sát được, **chưa phải kết luận một bài là nguy hiểm hoặc thuật toán tập sai sinh lý**.

**Đề xuất:** ưu tiên movement intent + thiết bị + vai trò trong buổi + hạn chế người dùng, rồi mới dùng nhóm cơ/độ phổ biến. Giải thích “tương tự vì…”; tách “cùng nhóm cơ nhưng khác động tác”. Review thư viện đối sánh với chuyên môn, không chỉ sửa riêng một screenshot. **Điều kiện đạt:** tập case kéo/đẩy/hinge/squat/accessory, có/không thiết bị; top lựa chọn giữ ý định hoặc nói rõ khác biệt. Người mới hiểu vì sao chọn. 

### D-A11 · P2 · Empty benchmark hiển thị 00 và sai loại đơn vị dưới nhãn 1RM

**Quan sát:** D13 và D42, sau quay lại app vẫn thấy card “1RM ước tính” với “00 lần trong 1 set”, trục 0–2 và lời hứa sẽ có dữ liệu khi ghi bài đo. Trong khi D52–D54 cho thấy bài incline bench đã có history và 1RM 51 kg. D56 giải thích 1RM là mức tạ, có công thức và loại set đủ điều kiện.

**Phạm vi kết luận:** 00 + đơn vị reps là **vấn đề empty state/semantic display có bằng chứng**. Chưa biết bài incline này có thuộc mapping benchmark tổng hay không, nên không kết luận mất log hay benchmark không cập nhật vì bug. Tổng điểm khóa đến 3 buổi cũng là điều kiện công khai, chưa phải lỗi.

**Đề xuất:** khi thiếu benchmark, thay chart số 0 bằng “Chưa có dữ liệu bài đo”; liệt kê chính xác bài đủ điều kiện, chỉ lối xem tiến bộ bài vừa log; 1RM có kg/lb theo hệ đo. Cho thấy tiến độ 1/3 buổi nếu áp dụng. **Điều kiện đạt:** phân biệt chưa ghi, chưa đủ buổi, bài không đủ điều kiện, lỗi tải dữ liệu và giá trị thật bằng 0.

### D-A12 · P2 · “6/65 set” cần nói đây là set quy đổi theo nhóm cơ

**Tái hiện:** thực hiện 3 set incline bench; D38 mục tiêu lên 6/65, 9%, nhóm đẩy 6. Mở rộng D39: ngực 3, vai 1.5, tay sau 1.5; footer giải thích cơ chính 1, cơ phụ 0.5. Phép cộng đúng với mô hình UI công khai.

**Tác động:** nhãn tổng “set” có thể khiến người dùng tưởng log trùng hoặc đã làm 6 set. Chỉ thấy quy ước sau khi mở rộng. **Không báo đây là lỗi đếm dữ liệu.** Chưa chứng minh mục tiêu 65 có phù hợp mọi người.

**Đề xuất:** nhãn “set theo nhóm cơ” hoặc “set quy đổi”, preview công thức gần tổng; tách 3 set thực hiện và 6 set đóng góp nếu hai số cùng có giá trị. **Điều kiện đạt:** người mới và người tập đều giải thích được 3 → 6 mà không cần người nghiên cứu giúp.

### D-A13 · P2 · Help recovery minh bạch hơn lời khẳng định ở mặt ngoài

**Quan sát:** D40 thay màu nhóm cơ sau log. D41 help nói recovery 0–100 là ước lượng từ lịch sử, không phải đo trực tiếp; dựa số set, cơ chính/phụ, **không dùng mức tạ hoặc reps** trong mô hình mô tả, có hồi phục theo thời gian 2–3 ngày. Đây là tuyên bố của sản phẩm, chưa kiểm chứng implementation. Thông điệp mặt ngoài kiểu app “biết” tình trạng cơ mạnh hơn độ chắc chắn trong help.

**Tác động:** một số phần trăm/màu có thể bị hiểu như trạng thái cơ thể đã đo; nhất là khi người dùng chỉ xem dashboard. Không tự chứng minh mô hình vô ích hoặc đưa khuyến cáo sinh lý từ đó.

**Đề xuất:** đặt “Ước tính từ các set đã ghi” tại heatmap, nêu yếu tố chưa dùng; phân biệt soreness/readiness tự khai nếu có trong tương lai. **Điều kiện đạt:** người dùng biết đây là chỉ báo từ log, không coi là xác nhận sẵn sàng tập hay chỉ định y tế.

### D-A14 · P2 · Trục mức tạ làm tròn thành nhãn trùng

**Quan sát:** D53, card Mức tạ hiển thị 42,5 kg đúng nhưng năm tick trục là **44, 44, 42, 42, 40**. Cùng màn 1RM 51 kg dùng các tick 49–53 khác nhau.

**Tác động:** gridline khác nhau mang nhãn giống nhau, làm người đọc khó đặt vị trí và hiểu thay đổi nhỏ. Vấn đề hiển thị chart đã quan sát, không phải giá trị set sai.

**Đề xuất:** bước tick phù hợp đơn vị/increment; giữ đủ chữ số thập phân hoặc giảm tick; kiểm tra range nhỏ, một điểm, kg/lb và số rất lớn. **Điều kiện đạt:** không có hai tick khác vị trí mang cùng nhãn trong range thông thường.

### D-A15 · P2 · Kcal trên summary cần gắn nhãn ước tính tại điểm đọc

**Quan sát:** D34 trước lưu 67 kcal, D35/D50 sau lưu 68 kcal khi thời lượng tiếp tục tăng đến 11:23. Buổi là giả, không có vận động thực, Health chưa kết nối. D48 profile có mô tả “ước tính năng lượng tiêu hao”; summary chỉ ghi “Năng lượng” và số.

**Tác động:** độ chính xác nguyên số cùng các số đo tải thật có thể khiến người dùng hiểu kcal là được đo. Chênh 67 → 68 chưa phải bug vì timer vẫn chạy; chưa có bằng chứng công thức năng lượng đúng hay sai.

**Đề xuất:** “Năng lượng ước tính”, help yếu tố dùng và cách xử lý thời gian tạm nghỉ/chỉnh buổi; không dùng kcal làm bằng chứng cá nhân hóa chính. **Điều kiện đạt:** phân biệt đo từ thiết bị, tính từ hồ sơ và tính từ thời lượng; không đánh đồng buổi audit giả với tiêu hao thật.

### D-A16 · P2 · Nhiều phạm vi thời gian trong cùng report cần phân biệt rõ

**Quan sát:** mở D45–D46, phần số buổi chọn 1–7/11 nên đúng là chưa có buổi; volume riêng chọn 6 tháng nên vẫn có 765 kg. Chọn 7 ngày qua → D47 có 1 buổi và 1RM 51 kg. Trước đổi khoảng, sức mạnh 6 tháng trong cùng report từng hiện empty state; chưa tái kiểm đủ để xác định đây là filter phụ thuộc phần trên hay refresh.

**Tác động:** các phần cùng trang có thời gian khác nhau; nếu chưa thấy filter trên cùng sẽ tưởng dữ liệu mâu thuẫn. **Không gọi là mất dữ liệu**; thời gian chọn giải thích được phần số buổi/volume.

**Đề xuất:** nhãn khoảng ngay trên từng card, hoặc một filter chung với sự khác biệt được nói rõ; kiểm tra dependency/refresh của chart sức mạnh. **Điều kiện đạt:** có dataset nhiều tuần, các card lấy đúng khoảng và đổi filter có kết quả xác định; người đọc chỉ ra được số đang thuộc kỳ nào.

## 5. Điểm mạnh được kiểm thử bổ sung

- **Log có phòng ngừa nhầm:** 0 kg làm log không khả dụng (D20); log toàn bài cần xác nhận (D27). Chưa thử bodyweight/assisted để kết luận mọi quy tắc validation phù hợp.
- **Feedback trong tập:** set đã ghi có check xanh, timer chạy sau set và pause được; RIR dùng ngôn ngữ đời thường, giữ đúng sau lưu.
- **Swap có quyền chọn lâu dài:** D33 giúp tách hành động hôm nay khỏi preference; không nên bỏ điểm mạnh này khi viết backlog.
- **Bảo toàn dữ liệu trong case đã thử:** một buổi lưu → nhật ký → history từng set → trends → background/quay lại khớp 765 kg và RIR. Không cộng bài draft chưa log.
- **Progress có đường đi sâu:** per-exercise history, trend, detail, PR/trung bình và công thức 1RM; không kết luận app chỉ có streak/tổng volume.
- **Công thức được công khai:** D56 mô tả mức tạ × (1 + reps/30), xử lý 1 rep, >30 reps, làm tròn 0.5 kg và chọn set có kết quả cao nhất trong ngày. Case 42.5 × (1 + 6/30) = 51 khớp UI. Đây là kiểm tra một case, không xác thực toàn thuật toán.
- **Quyền riêng tư và tùy chọn:** luồng tập hoàn tất được khi không kết nối Health; nhập hồ sơ ghi không bắt buộc; có entry export và English.
- **Vòng quay lại đã hiện diện:** sau lưu có milestone/streak, nhật ký 1/3 ngày, mục tiêu tuần, recovery và buổi thân dưới kế tiếp. Chưa chứng minh cơ chế nào làm tăng retention.

## 6. Những điều không được kết luận từ ảnh và một buổi test

- Không có P0 tái hiện trong **case đã hoàn tất** không đồng nghĩa app không có lỗi chặn ở case khác.
- CTA/tab đè một phần danh sách trong viewport không chứng minh phần cuối không tới được. Cuộn trong một số view/settings/help chưa đạt; phải thử lại bằng chạm trực tiếp trên iPhone trước khi báo app chặn nội dung.
- Bàn phím qua Mirroring nhập reps được một lần, tạ 40 không đáng tin; không báo keyboard Dopafit hỏng từ tương tác Mac này.
- Mac khóa, iPhone in Use, reconnect và frame chuyển cảnh không phải crash/performance bug của Dopafit.
- Chữ xám không tự chứng minh contrast fail; screenshot scale không đo được touch target.
- AX Mirroring không có nội dung app không chứng minh VoiceOver app hỏng.
- Có English/kg/lb chưa chứng minh locale US hoạt động đúng; chưa chuyển thử.
- Toggle warm-up đang tắt là trạng thái account, chưa phải mặc định onboarding hoặc thiếu warm-up.
- Có video/AI/recovery không chứng minh kỹ thuật đúng, thuật toán tối ưu hoặc hiệu quả sinh lý.
- D53/D54 có per-exercise trend; D56 có công thức 1RM. Không giữ nhận xét “thiếu progress theo bài/không giải thích mọi chỉ số”.
- Report/summary khớp trong một session chưa chứng minh offline, Watch, crash recovery hoặc xung đột đa thiết bị đáng tin.

## 7. Tiêu chí riêng cho hai nhóm

| Tình huống | Người mới | Người tập đều |
|---|---|---|
| Trước buổi đầu | Hiểu bài, quy ước tạ và cách điều chỉnh | Thấy mục tiêu buổi, last set, kế hoạch tuần/block |
| Máy bận | Tìm bài thay gần ý định, hướng dẫn rõ | Thay nhanh và kiểm soát scope/progression |
| Log set | Phân biệt dự kiến/thực hiện, tránh log nhầm | Ít thao tác; sửa/undo; set types và RIR khi cần |
| Sau buổi | Một bằng chứng hoàn thành và bước tiếp theo | Trend/PR có ý nghĩa, volume và kế hoạch dài hạn |
| Nghỉ một thời gian | Đường trở lại ít áp lực | Kiểm soát lịch và tải theo khả năng hiện tại |

Không chấm tổng điểm toàn app từ một thiết bị. Đánh giá kỹ thuật: accessibility, performance, adaptive layout, theme modes, API/data integrity và thuật toán nhiều tuần **chưa đủ bằng chứng để cho điểm**. Bản audit phân mức ưu tiên cho các quan sát cụ thể, không tạo con số tổng chính xác giả.

## 8. Case còn cần trước quyết định phát hành

| Nhóm | Case tối thiểu | Điều kiện đạt / trạng thái hôm nay |
|---|---|---|
| Dữ liệu cơ bản | Start→edit→log→finish→history→background | Đã pass một case log 3 set; edit tạ/undo/sửa sau lưu chưa pass đủ |
| Khôi phục | Mạng yếu, offline, force quit, crash, trùng event sync | Chưa thử; phải khôi phục có thứ tự, không mất/nhân đôi |
| Gym thực | Máy bận, nhiều gym, increments, bar weight | Swap một case xong; ranking cần review; áp dụng increments chưa thử |
| Thuật toán | Dataset 4–8 tuần; bỏ tập; deload; RIR; đổi split | Chưa thử; review chuyên môn, constraints và lý do từ dữ liệu thật |
| Kế hoạch kế tiếp | Phân bổ bài/set, overlap, thứ tự, thời lượng | D57 có squat + thruster + RDL + good morning; cần chuyên môn kiểm tra toàn chương trình theo mục tiêu, chưa gọi nguy hiểm/sai từ screenshot |
| Thị trường Mỹ | en-US, lb, 45 lb bar, decimal, timezone/DST | Chưa thử hành vi; UI có option; chart D53 dùng 11/09 trong UI Việt cần QA locale |
| Accessibility | VoiceOver, Dynamic Type, Reduce Motion, contrast, thao tác khi mệt | Chưa đo trên native app; phải hoàn tất task chính |
| Thương mại | Onboarding, trial, renewal, restore, expiry | Chưa có điều kiện kiểm tra trên tài khoản Pro đang cấp |
| Quyền dữ liệu | Đọc file export, privacy/support, offline/expiry history | Export mới mở share sheet; chưa kiểm tra nội dung hoặc lifecycle |
| Thiết bị | OS tối thiểu, màn nhỏ/lớn, Watch, Health denied/partial | Chưa thử; không giả định từ model hiện có |
| Cấu hình | Superset, timed, warm-up, preference exclusivity, saved workout, refresh | Đã thấy entry; chưa kiểm tra hành vi và persistence |

Các case này là khoảng trống kiểm thử được công khai, không phải toàn bộ đều cần xin quyền mới hoặc là chức năng thiếu. Những case cần account/build/thiết bị khác phải có môi trường phù hợp; không thể thay bằng tạo thêm buổi giả giống hệt nhau.

## 9. Thứ tự sửa và nghiên cứu tiếp

1. **Làm rõ/rà relevance:** quy ước tạ theo dụng cụ (A01), ranking swap (A10), benchmark empty state (A11).
2. **Đọc tiến bộ đúng:** set quy đổi (A12), trục chart (A14), kỳ báo cáo (A16).
3. **Giải thích có giới hạn:** target (A02), recovery (A13), kcal (A15), dịch hướng dẫn (A04).
4. **Tối ưu cho hai nhóm:** hierarchy cài đặt (A07), empty history (A06), preference (A03); đo usability trước khi tái cấu trúc.
5. **Kiểm tra tính nhất quán:** locale (A09), thumbnail (A08), sau đó native accessibility và các regression case dữ liệu.

Chưa sửa source code, thiết kế hoặc phát hành app. Nhận xét D-A05 đã được hiệu chỉnh theo bằng chứng sau, không đưa vào danh sách bug còn mở.
