> **Phạm vi lịch sử:** tài liệu này chỉ review ảnh D01–D08 trước kiểm thử luồng tập. Một số nghi vấn đã được giải đáp ở D21/D33/D39/D52–D56. Dùng [DOPAFIT-AUDIT.md](DOPAFIT-AUDIT.md) làm kết luận sau cùng; không gộp mọi nhận xét ban đầu thành bug còn mở.

# Dopafit — đánh giá UX độc lập từ bằng chứng giao diện

Ngày đánh giá: 09/11/2026, giờ Việt Nam. Người đánh giá độc lập không đọc kết quả phân tích App Store hay kết luận audit chính của tác vụ.

## Phạm vi và cách đọc kết luận

Đã xem trực tiếp 8 ảnh chụp màn hình: D01 đến D08 trong thư mục `evidence`. D09 chưa tồn tại tại thời điểm đánh giá. Đây là đánh giá hình ảnh của trạng thái đã đăng nhập/có kế hoạch, bằng tiếng Việt; không phải kiểm thử thao tác và không thay thế audit toàn app. Không điều khiển thiết bị, không thay đổi tài khoản hoặc dữ liệu tập.

Tách ba mức bằng chứng:

- **Quan sát**: nội dung hoặc cấu trúc thực sự có trong ảnh.
- **Rủi ro UX**: hệ quả có thể xảy ra, cần kiểm thử với người dùng hoặc thao tác.
- **Chưa xác minh**: không coi là bug đã tái hiện, không đưa vào tổng số lỗi xác nhận.

Không có mã nguồn/DOM để chạy detector, không đo contrast hoặc kích thước vùng chạm, không kiểm thử VoiceOver/Dynamic Type, mạng yếu, lưu/khôi phục buổi tập, Watch hoặc tính đúng đắn của thuật toán. Không suy ra những tính năng chưa thấy là không tồn tại. Không chấm điểm tổng /40 vì phần lớn trạng thái vận hành chưa được kiểm thử.

## Nhận định tổng thể

Giao diện có cấu trúc của một công cụ tập tạ thực dụng: một buổi tập cụ thể, các bài được lên sẵn, con số set/reps/tạ, video và nút bắt đầu rõ. Phần khó còn lại là giúp người dùng hiểu và tin vào con số được đề xuất, đồng thời phân biệt thay đổi cho hôm nay với thay đổi ảnh hưởng những buổi sau.

Không đủ cơ sở nói giao diện do AI tạo ra. Nền tối với điểm nhấn xanh sáng, pill, bottom sheet và thumbnail giải phẫu là phong cách quen thuộc của nhóm fitness; tính quen thuộc này không phải bằng chứng nguồn gốc AI. Chưa thấy gradient text, các thẻ trang trí vô nghĩa hay dashboard số liệu phô trương trong mẫu ảnh. Tuy vậy, bộ ảnh này chưa chứng minh một nét nhận diện thương hiệu riêng ngoài màu nhấn. Mức độ phù hợp cảm xúc phải chờ xác nhận đối tượng và brand từ chủ sản phẩm.

## Những điểm đang làm tốt

1. **Ưu tiên hành động chính rõ** (D01). “Bắt đầu buổi tập” có màu và vị trí tách biệt. Tên ngày tập, số bài và thời lượng cho người dùng biết họ chuẩn bị làm gì trước khi bắt đầu.
2. **Có nền tảng cho cảm giác được hướng dẫn** (D01, D04, D05). Mức tạ có lời giải thích là ước lượng ban đầu; video và văn bản cùng hiện diện; tab nhóm cơ tách cơ chính và cơ hỗ trợ. Đây là những yếu tố hỗ trợ người dùng ra quyết định, không chỉ ghi dữ liệu.
3. **Có các lớp điều khiển thay vì dồn hết ra màn chính** (D02, D06, D07, D08). Đổi bài, lịch sử, preference và thiết bị nằm ở ngữ cảnh liên quan. Điều chỉnh thời lượng có phân biệt “Chỉ cho buổi này” và “Đặt làm mặc định” trên giao diện; cần bảo đảm hành vi thực tế giữ đúng lời hứa này.
4. **Trạng thái chọn có cả màu và dấu kiểm** (D06, D07). Người dùng không phải dựa hoàn toàn vào màu để xác định lựa chọn hiện tại. Bottom navigation có chữ, không chỉ icon.

## Danh sách phát hiện ưu tiên

| ID | Mức | Bằng chứng quan sát | Tác động/rủi ro | Hướng xử lý đề xuất | Độ tin cậy |
|---|---|---|---|---|---|
| V01 | P1 | D01 ghi `42.5 kg`, `20 kg`, `15 kg` cạnh từng bài, không có định nghĩa ngay tại danh sách về tạ tổng/tạ mỗi bên/tạ mỗi quả; video D04 yêu cầu tải máy “với trọng lượng mong muốn” | Người mới có thể hiểu khác nhau giữa máy, đòn và tạ đơn; đây là vấn đề nghĩa của đơn vị, chưa chứng minh số gợi ý sai hoặc không an toàn | Hiển thị quy ước theo loại bài ở điểm cần nhập/đọc tạ; chú thích bar included, per dumbbell, additional weight hoặc stack tùy bài; kiểm tra cả kg và lb | Cao về thiếu chú giải tại màn đã thấy; chưa kiểm tra màn nhập set |
| V02 | P2 | D01 nói mức tạ ước lượng từ câu trả lời, nhưng không hiện yếu tố cụ thể hoặc lối xử lý khi hôm nay thấy quá nặng/quá nhẹ | App yêu cầu niềm tin vào con số khá chính xác mà chưa giúp người dùng hiệu chỉnh ngay ở bước chuẩn bị | Thêm trợ giúp ngắn theo ngữ cảnh: đây là điểm khởi đầu, cách hiệu chỉnh và cơ chế điều chỉnh các buổi sau; kiểm thử discoverability của sửa tạ | Cao về nội dung hiện tại; chưa kiểm tra chỉnh tạ trong buổi |
| V03 | P2 | D08 trình bày “Mức thay đổi bài tập”, “Bài trọng tâm”, “Set khởi động”, “Superset”, “Tập theo thời gian” trong cùng lớp cài đặt; tại viewport này không thấy mô tả ngắn cho các mục | Người ít kinh nghiệm phải hiểu thuật ngữ và hệ quả trước khi lựa chọn; cùng kiểu row khiến các quyết định khác mức quan trọng có trọng lượng ngang nhau | Mô tả tác động bằng một câu hoặc disclosure tại từng mục; nhóm lựa chọn thiết yếu và nâng cao; nêu mặc định khuyến nghị theo mục tiêu | Cao về bố cục; chưa xem trang con nên không kết luận không có help |
| V04 | P2 | D02 dùng hai toggle riêng “Gợi ý bài này thường hơn” và “Gợi ý bài này ít hơn”; đồng thời có “Không gợi ý bài này nữa” | Nhìn giao diện có thể hiểu cả hai toggle là độc lập; người dùng cần biết trạng thái bình thường và cách hoàn nguyên cấm bài | Dùng lựa chọn duy nhất: bình thường/thường hơn/ít hơn/loại trừ, hoặc bảo đảm tương tác loại trừ nhau và giải thích hiệu lực | Cao về hình thức; **chưa xác minh có thể bật đồng thời**, không gọi là bug logic |
| V05 | P2 | D04 có câu “Tải máy T-Bar Row với trọng lượng mong muốn”, tiếp theo “Nắm tay cầm…” rồi “Nắm thanh tạ…” | Thuật ngữ dịch chưa tự nhiên; đổi tên cùng bộ phận có thể làm người dùng phân vân đang nói tay cầm hay đòn | Biên tập nội dung theo đúng biến thể thiết bị, thống nhất danh từ; QA hướng dẫn bằng huấn luyện viên; đối chiếu từng cue với video | Cao về câu chữ; chưa đánh giá chuyên môn kỹ thuật bài |
| V06 | P2 | D01 thumbnail bài có badge giải phẫu chồng lên góc; các dòng tên bài dài xuống hàng | Vùng nhận diện thao tác và vùng nhận diện cơ cùng tranh diện tích trong ảnh nhỏ; người mới cần nhìn thiết bị hoặc tư thế rõ | So sánh usability giữa ảnh bài rõ hơn và badge cơ nhỏ hơn/đưa vào detail; giữ hình giải phẫu khi nó phục vụ chọn nhóm cơ | Cao về cấu trúc; tác động cần test |
| V07 | P2 | D03 empty state nói phải ghi bài trong buổi tập để hiện kết quả, nhưng không có CTA ngữ cảnh ngay trong vùng nội dung | Người lần đầu tới lịch sử phải tự quay lại buổi tập qua Back hoặc tab, dù app biết hành động tiếp theo | Bổ sung đường trở về bài trong buổi hiện tại hoặc bắt đầu buổi phù hợp; giữ thông báo ngắn đang có | Cao; workaround qua điều hướng hiện có |
| V08 | P3 | D08 “Mục tiêu” hiển thị giá trị “Khỏe hơn”, “Kinh nghiệm” là “Trung bình” | Nhãn rộng, chưa nói cụ thể kiểu tiến bộ nào được tối ưu; nếu trang con không giải thích, người dùng khó dự đoán kế hoạch | Kiểm tra trang con và mô tả trade-off của mục tiêu; ví dụ mục tiêu sức mạnh khác hypertrophy ở điểm nào, không hứa kết quả định lượng | Cao về nhãn; chưa xem trang con |

P1 ở V01 là ưu tiên làm rõ ý nghĩa của con số trước khi đưa sản phẩm tới người mới; không phải kết luận một người cụ thể nên tập mức tạ nào. Không có P0 đã được chứng minh từ bộ ảnh.

## Các điểm dễ bị kết luận quá mức — cần kiểm thử tiếp

- **Nút nổi che danh sách**: D01 cho thấy CTA và tab bar chồng lên một phần các dòng phía dưới. Chưa biết padding cuối danh sách và khả năng cuộn, nên chưa khẳng định bài cuối không thể đọc/bấm. Kiểm tra cuộn hết danh sách và font lớn.
- **Độ tương phản**: Có chữ phụ màu xám và nút trông mờ trên nền tối, nhưng chưa đo. D06 có thể là trạng thái disabled vì chưa đổi lựa chọn; không chấm lỗi contrast của nút disabled chỉ bằng ảnh.
- **Tốc độ/phát video**: Một ảnh có `1,0 x` không chứng minh có/không có pause, audio, caption, đổi góc hoặc offline. Cần thao tác.
- **Mức khởi động off**: D08 toggle “Set khởi động” đang tắt là trạng thái tài khoản cụ thể. Không suy ra đây là mặc định cho mọi người hoặc app không có warm-up. Cần kiểm tra onboarding và profile của người mới.
- **Nội dung kỹ thuật**: D04 nói lòng bàn tay hướng xuống. Cần đối chiếu cả video, thiết bị và biến thể trước khi quyết định cue đúng/sai. Không kết luận an toàn từ một frame.
- **Thông tin tuần/chương trình dài hạn**: D01 chỉ là màn buổi tập hiện tại, nên chưa chứng minh app không có lịch tuần, periodization hoặc deload.
- **Tên tab “Cơ thể” và “Mục tiêu”**: Chưa mở hai tab này; không suy luận chúng chứa recovery, body metrics hoặc goals gamification.

## Hai hành trình người dùng giả định

Các persona dưới đây là khung kiểm tra, chưa phải phân khúc khách hàng được chủ sản phẩm xác nhận.

### Người mới tập gym, chưa quen thiết bị

D01 giúp bắt đầu nhanh vì có sẵn buổi tập. Điểm nghi ngại đầu tiên là hiểu `42.5 kg` đúng nghĩa; card ước lượng có ích nhưng chưa cho thấy cách tự chọn mức phù hợp. Video D04 là điểm hỗ trợ tốt. Câu chữ cần biên tập theo thiết bị để tránh người mới vừa xem hình vừa giải mã bản dịch. D08 đưa nhiều thuật ngữ nâng cao vào một trang; cần xác định người mới có bắt buộc dùng chúng hay có thể tập an toàn theo thiết lập đã hướng dẫn. Chưa kiểm thử onboarding nên không kết luận app bỏ rơi người mới.

**Bài test quan trọng**: Cho người dùng giải thích tạ theo ba loại bài trước khi bấm Start; tìm nơi đổi tạ/đổi bài; nhận biết warm-up và một set hoàn tất. Ghi số lần hỏi trợ giúp và lỗi nghĩa đơn vị, không chỉ thời gian thao tác.

### Người tập đều, chỉ có 45 phút, máy đang bận

D01 có duration và gym ở gần đầu trang, phù hợp thay đổi tình huống. D06 thể hiện hai phạm vi áp dụng là điểm tốt để bảo toàn lịch tập dài hạn. D02 có “Thay bài”, nhưng đang nằm cùng lịch sử/video và preference; cần đo số thao tác thực để đổi bài và xem liệu có giữ rep/tạ tương ứng. Hai toggle preference không nên làm người dùng nhầm việc “máy bận hôm nay” thành giảm tần suất lâu dài. Chưa kiểm thử trang thay bài nên không kết luận swap khó hay mất dữ liệu.

**Bài test quan trọng**: Đổi sang 45 phút chỉ hôm nay, thay bài một lần vì thiếu máy, hoàn tất set, kiểm tra buổi sau không bị đổi preference ngoài ý muốn.

## Tải nhận thức theo 8 tiêu chí

| Tiêu chí | Nhận định giới hạn trong ảnh |
|---|---|
| Một hành động chính | Tốt ở D01: Start nổi bật |
| Chia nhỏ thông tin | D02 chia chức năng thành nhóm 3/3/1; D08 có nhóm thiết lập lớn, cần mô tả ngắn |
| Nhóm liên quan | Nhất quán bằng section, nền và separator |
| Thứ bậc | D01 rõ tên buổi và Start; D08 nhiều tùy chọn có trọng lượng ngang nhau |
| Một quyết định mỗi bước | D06 tốt; D08 là danh mục thiết lập, không nên coi tất cả là quyết định bắt buộc |
| Số lựa chọn | D06 có 5 mức thời lượng nhưng có thứ tự rõ; bản thân số 5 không đủ để gọi overload. D02 có 7 hành động nhưng đã phân nhóm |
| Trí nhớ | Quy ước tạ chưa được đồng hành ở danh sách; D03 yêu cầu tự chọn đường quay về |
| Tiết lộ dần | Có qua menu/detail; chưa biết hiệu quả thực tế vì chưa tương tác |

Không cộng một điểm “tải nhận thức toàn app”: mẫu ảnh là nhiều ngữ cảnh khác nhau, không phải cùng một decision point. Hai rủi ro rõ nhất là thuật ngữ nâng cao và nghĩa/scope của dữ liệu, không phải số lượng thẻ.

## Nielsen: trạng thái bằng chứng thay vì điểm tổng

| Heuristic | Quan sát có bằng chứng | Còn thiếu để chấm điểm |
|---|---|---|
| Trạng thái hệ thống | Active tab, chọn duration/gym, empty history có thông báo | Loading, save, sync, finish, offline |
| Khớp thế giới thật | Tên bài và hình, có set/reps/kg | Quy ước tạ, chất lượng toàn thư viện, English |
| Kiểm soát | Back, X, Done xuất hiện | Undo, huỷ thay đổi, recovery |
| Nhất quán | Pattern sheet/list/tab khá đồng nhất | Hành vi qua toàn app, định dạng số |
| Ngăn lỗi | Gợi ý tạ được gọi là ước lượng | Input validation, destructive confirmation |
| Nhận biết | Nhãn bottom tab và thumbnail | Lối vào swap nhanh, discoverability thao tác |
| Hiệu quả | Duration, gym, preference và cấu hình hiện diện | Số tap thực, persistence, duplicate session |
| Tối giản | Không có feed/ad trên home đã chụp | Nội dung bị che và readability khi font lớn |
| Phục hồi lỗi | Chưa có trạng thái lỗi trong mẫu | Mất mạng, crash, conflict/sync |
| Trợ giúp | Video, văn bản, nhóm cơ, help icon duration | Tính chính xác/cập nhật, ngữ cảnh khi nhập set |

## Kiểm tra riêng cho thị trường Mỹ

Mẫu hiện tại bằng tiếng Việt không chứng minh thiếu English. Trước khi kết luận mức sẵn sàng cho Mỹ, kiểm thử en-US gồm tên bài phổ biến trong gym Mỹ, lbs và bước nhảy tạ thực, quy ước mỗi quả/tổng/stack, bar weight, khoảng reps, hiển thị dấu thập phân, thời gian và lịch tuần. D01 dùng `42.5` trong khi D04 dùng `1,0 x`; đây là điểm cần rà soát format theo locale, chưa đủ để gọi lỗi English.

Cũng cần kiểm tra việc lưu dữ liệu tập, tôn trọng quyền Health/Watch, và khả năng dùng khi mạng gym yếu. Đây là checklist chưa thực hiện, không phải phát hiện app đang thiếu.

## Thứ tự đề xuất cho nhóm sản phẩm

1. `/clarify`: nghĩa của tạ và hướng dẫn thiết bị; sau đó scope của lựa chọn buổi hiện tại/mặc định.
2. `/shape`: thử hai hành trình nêu trên để xác định lựa chọn nào cần hướng dẫn, lựa chọn nào có thể ở lớp nâng cao.
3. `/layout`: kiểm tra danh sách cuối trang, thumbnail/badge và thứ bậc trong cài đặt trên thiết bị thật.
4. `/adapt`: xác minh font lớn, en-US, đơn vị lb và các kích thước thiết bị sau khi có bản build tương ứng.
5. `/polish`: thống nhất thuật ngữ, định dạng số, icon và trạng thái sau khi luồng cốt lõi đã được kiểm chứng.

Không đề xuất thay toàn bộ style hoặc đổi màu chỉ vì interface giống ngôn ngữ chung của fitness app. Đầu tiên cần chứng minh người dùng có hiểu, tin và thao tác đúng với buổi tập.
