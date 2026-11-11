# Rà soát phần còn thiếu sau báo cáo

Ngày rà: **09/11/2026**. Đối chiếu lại đúng 5 yêu cầu gốc và các bằng chứng đã lưu. Đây là kiểm tra độ phủ của công việc; **không tạo thêm kết quả kiểm thử thiết bị**.

## Cập nhật sau đăng nhập và rebuild

Đã audit thêm onboarding, nhánh nhập tay, login do người dùng thực hiện, activation/Pro introduction, English trên các màn chính, Row mỗi bên và RIR sau lưu. Figma có 119 ảnh trạng thái gốc. Xem [audit cập nhật](../../rebuild/POSTLOGIN-AUDIT.md) và [phạm vi bản dựng](../../rebuild/PARITY.md). Các khoảng trống dưới đây phản ánh thời điểm rà cũ; các mục nhiều tuần, SSO/giao dịch/restore, offline/sync, Health/Watch, accessibility và đối chiếu mọi nhánh vẫn chưa đóng. Không coi việc có ảnh English là hoàn tất US localization.

## Kết luận tại lượt rà trước

Năm chủ đề đều đã được xử lý, nhưng **audit Dopafit chưa toàn diện theo vòng đời sản phẩm**, và **độ sâu nghiên cứu chưa đồng đều giữa tất cả đối thủ**. Có thể dùng báo cáo hiện tại để ưu tiên UX và chuẩn bị benchmark; chưa đủ để kết luận app sẵn sàng phát hành tại Mỹ, thuật toán hiệu quả dài hạn hoặc mọi luồng đều đáng tin.

## Khoảng trống theo thứ tự ưu tiên

| Ưu tiên | Phần còn thiếu | Vì sao ảnh hưởng kết luận | Cách đóng khoảng trống / bằng chứng cần có |
|---|---|---|---|
| 1 | **Đúng build và tái hiện được** | Đã biết tên thiết bị qua Mirroring nhưng thiếu phiên bản iOS/build Dopafit đang cài; khó giao bug cho dev và retest | Ghi iOS, app version/build, loại account, cấu hình và thời điểm; giữ cùng bộ case khi retest |
| 1 | **Người mới từ lần mở đầu và vòng đời tài khoản** | Tài khoản đã là Pro, cấu hình Trung bình; chưa thử onboarding của người mới dù sản phẩm nhắm cả hai nhóm | Account test mới: câu hỏi bắt buộc, bỏ qua/quay lại, thời điểm thấy giá, first workout, trial/restore/expiry; không reset account đang dùng để giả lập |
| 1 | **Mất mạng, app bị đóng và dữ liệu xung đột** | Background/quay lại thành công không chứng minh force quit, hết pin, offline, crash hoặc nhiều thiết bị | Dataset biết trước; log/sửa → offline/đóng → mở lại → sync; đối chiếu từng set/ID, không mất/nhân đôi, trạng thái lưu rõ |
| 1 | **Chỉnh sửa và biến thể dữ liệu tập** | Chưa xác minh nhập tạ thành công qua Mirroring, undo/sửa set đã log/sửa sau finish; chỉ đã lưu 3 set giống nhau | Native touch/keyboard: đổi reps/tạ từng set, undo, thêm/xóa set thử, sửa sau lưu, bodyweight/assisted/unilateral/timed; đối chiếu summary/history/export |
| 1 | **Trải nghiệm thực sự cho Mỹ** | Có English và lb trong menu nhưng chưa áp dụng; không chứng minh chuyển đơn vị, dụng cụ và lịch đúng | en-US/lb, đòn 45 lb, plate/increments khả dụng, làm tròn hai chiều, ngày/tháng, tuần, timezone/DST; dữ liệu cũ vẫn đúng sau chuyển |
| 1 | **Chương trình và progression nhiều tuần** | Một session kiểm được phép cộng và 1RM; không kiểm được learning, deload, comeback, fatigue hay tính phù hợp chương trình | Dataset 4–8 tuần cho cả Beginner và Intermediate, plateau, bỏ buổi/nghỉ dài, RIR thay đổi, đổi split/gear; chuyên môn review cả plan, không chỉ từng bài |
| 2 | **Các chức năng mới mở menu** | Save workout, superset/circuit, warm-up, timed training, refresh, preference, đổi gym/thời lượng chưa được thử đầy đủ | Thực thi từng chức năng trên test account; xác minh scope hôm nay/lâu dài, persistence và tác động lên session đã chấp nhận |
| 2 | **Export, quyền dữ liệu, hỗ trợ và pháp lý** | Export mới mở share sheet; chưa đọc file; phần cuối Settings chưa tới hết | Lưu file cục bộ và đối chiếu dữ liệu/đơn vị/ngày; kiểm privacy/support, quyền đọc dữ liệu khi hết Pro, đường quản lý account; không cần gửi file ra ngoài |
| 2 | **Accessibility và điều kiện gym** | Screenshot chưa đo VoiceOver, chữ lớn, contrast, tap target, timer khi không nhìn máy và âm thanh khi nghe nhạc | Hoàn tất task native với VoiceOver/Dynamic Type; timer hết giờ, pause/resume, màn khóa/app nền, podcast/nhạc; nhiều kích thước thiết bị |
| 2 | **Watch / Health / đa nền tảng** | Chưa test thiết bị/quyền; Android chỉ có đối chiếu review chọn lọc, locale không chuẩn hóa US | Test Health denied/partial, tránh log trùng; Watch phone-only/watch-only/reconnect; kiểm iOS/Android parity nếu Dopafit có scope đó |
| 2 | **Fitbod trực tiếp** | App trên máy dừng ở paywall VND; thông tin Fitbod chủ yếu từ nguồn công khai, chưa có đối chiếu tác vụ live ngang nhau | Tài khoản có quyền truy cập hợp lệ; cùng các task target/log/swap/history/settings; không suy UI giống nhau từ tính năng cùng tên |
| 3 | **6 lựa chọn cạnh tranh chưa có corpus review tương đương** | Bản đồ 16 đối thủ khác Fitbod; corpus hiện gồm Fitbod + 10 đối thủ | Bổ sung JEFIT, JuggernautAI, StrengthLog, Future, Apple Fitness+ và Nike Training Club khi cần đánh giá sâu; cùng phương pháp lấy mẫu và tình trạng fix |
| 3 | **Cơ chế thu hút chưa có chứng minh nhân quả** | Phản hồi và tính năng hỗ trợ giả thuyết, chưa có cohort/telemetry hoặc quan sát người dùng thật | Test hai nhóm người dùng; đo hiểu target, logging friction, hiểu progress và tập đều; attribution/retention nội bộ chỉ phân tích khi có dữ liệu |

Ưu tiên ở đây là thứ tự hoàn thiện bằng chứng, không phải mức severity của bug đã tái hiện. Các chức năng chưa thử không được coi là thiếu. Những case cần môi trường hoặc thiết bị khác vẫn chưa đóng; tạo thêm các buổi giả giống nhau không thay thế được.

## Phần nghiên cứu cần đọc đúng phạm vi

- **11 app có dữ liệu review**, gồm Fitbod và 10 đối thủ. Bản đồ có **16 lựa chọn cạnh tranh ngoài Fitbod**. Vì vậy không nên nói đã nghiên cứu pain point sâu đồng đều của cả 16.
- Corpus chính: 8 × 150 = **1.200 review**, **633** trong cửa sổ 09/08–09/11; **119** review ≤3 sao trong cửa sổ. Mẫu bổ sung: 3 × 50 = **150**, **34** trong cửa sổ. Không trộn hai thiết kế mẫu để so tỷ lệ lỗi.
- PUSH chỉ có **1** review trong cửa sổ ở mẫu lấy được; thiếu bằng chứng mới không có nghĩa app không có vấn đề.
- Mới nhất trong bộ dữ liệu là **07/11/2026**; chưa bảo đảm có mọi review đến hết ngày 09/11.
- Reddit/review ở US storefront không chứng minh người viết ở Mỹ. Chưa có market share/revenue/retention được xác minh.
- Cơ chế onboarding/paywall/notification của các app chưa được walkthrough live đồng đều; phần “cuốn hút” hiện là tổng hợp tính năng, lời khen và suy luận, không phải mở được thuật toán độc quyền.

## Đã kiểm tra lại ngay trong lượt rà này

- Đếm lại: **1.350 review không trùng khóa app + review ID**, ở **11 app**.
- **100/100** dòng chứng cứ khớp app/ID/ngày/sao/phiên bản với JSON đã lưu.
- **58 ảnh Dopafit**, **15 dòng backlog**; A05 đã hiệu chỉnh không nằm trong backlog còn mở.
- Không có đường dẫn file nội bộ bị thiếu trong các Markdown đã kiểm.
- Không phát hiện lỗi đếm tổng hiện hành trong các số 1.200 / 150 / 633 / 119 / 34. Việc đối chiếu metadata không chứng minh mọi diễn giải ngữ nghĩa đều đúng hoặc mọi báo cáo bug đều đã tái hiện.

## Cách dùng bản hiện tại

Đủ cơ sở giao các vấn đề UI có ảnh như benchmark empty state, nhãn trục chart và quy ước/nhãn chỉ số; ranking swap cần chuyên môn review. Trước quyết định phát hành Mỹ, ưu tiên đóng các mục mức 1. Trước khi thay nhận diện, nên kiểm tra cùng một flow với hai nhóm người dùng, vì phiên hiện có mới trực tiếp đại diện cấu hình Intermediate.
