# Đối chiếu lại bản simulator với Dopafit gốc — 09/11/2026

Người dùng phát hiện bản simulator thiếu nhiều UI/chức năng. Rà source và đối chiếu ảnh gốc xác nhận phản ánh này đúng. Số 125 hiện tại là ảnh trạng thái được ghi tài liệu, không phải số màn đã triển khai hoặc số luồng đã kiểm thử trong rebuild. Model tests không chứng minh UI tương đương.

## Khoảng trống xác nhận và thay đổi trong lượt sửa

| Phần | Thiếu/sai ở build trước | Thay đổi |
|---|---|---|
| Điều hướng | Một NavigationStack cho bốn tab; vào màn con mất thanh tab và không giữ stack riêng | Bốn stack độc lập, thanh tab nằm ngoài stack, đổi tab giữ màn con từng tab |
| Home → bài tập | Tapping bài trên Home mở nhập set trước khi bắt đầu | Home mở guide; buổi đang chạy mới mở set entry |
| Guide D04/D05/R43 | Các phần Cách tập/Nhóm cơ/Dụng cụ bị dồn vào một trang; cue chung cho tất cả bài | Ba tab hoạt động, crop media và tốc độ; cue T-Bar/Row theo nội dung đã quan sát; cơ chính/phụ và dụng cụ riêng |
| Trends D53/D54 | Bấm chart chỉ mở bài giải thích | Màn metric riêng, Tuần/Tháng/6 tháng/Năm, chart theo ngày dữ liệu, chạm chọn điểm, PR/trung bình và giải thích đúng từng metric; không tạo ngày giả |
| Recovery D14/D40 | Thiếu số ngày từ buổi gần nhất, tip Đã hiểu, nút tất cả cơ và drill-down | Bố cục được dựng lại theo ảnh; list phần trăm từng cơ và chi tiết buổi liên quan; dismiss tip lưu qua restart |
| Results D13/D42 | Dùng bất kỳ bài đã tập làm benchmark; Health CTA mở nhầm hồ sơ | Benchmark tách riêng, giữ empty state khi chưa tập bài đo; CTA Health mở màn kết nối; dismiss card |
| Goals D38/D39 | Một vòng lime thay ba đoạn màu; nhóm cơ chỉ là progress bar, không có target/còn lại | Vòng đẩy/kéo/chân, card mở rộng, target/còn lại từng cơ, giải thích trọng số, các tuần trước, tip đóng/mở |
| Saved workout R60 | Thiếu plus thêm bài và trình sửa set | Thêm bài qua thư viện; sửa reps/tạ/thêm/xóa set, warmup, xóa bài; validate trước save; hủy không ghi; cập nhật volume/history/CSV |
| Exercise picker | Chỉ sort theo tên thực sự chạy; các lựa chọn còn lại đổi nhãn | Tập nhiều/ít/chưa tập chạy theo set đã log; lọc search + gear; best-fit dùng cơ, dụng cụ và preferences cục bộ |
| Saved templates | Dùng lại template làm mất reps/tạ/rest đã chỉnh | Copy prescription/rest/notes/warmup; tạo IDs mới, reset completed/RIR, giữ nhóm superset |
| Rest | Chuyển Set chính/Khởi động chỉ đổi UI; cùng một duration | Hai thời lượng riêng; set warmup dùng duration của warmup; dữ liệu cũ fallback an toàn |
| Journal month | Đổi tháng vẫn hiện mọi session | Lọc session theo tháng/ngày đang chọn, xóa day filter khi đổi tháng; card dùng nền solid như ảnh gốc |

## Phần còn thiếu, không coi là đã hoàn tất

- Clip gốc/góc quay, mesh và màu cơ động, mesh xoay mô hình cơ thể. Đã thêm ảnh trước/sau nhưng chỉ là crop minh họa tĩnh; không vẽ lại một ảnh trước thành ảnh sau để giả lập góc nhìn.
- Thư viện 400+ bài và preset 65 dụng cụ: hiện 27 định nghĩa / 13 loại. Guide phần lớn bài chưa có cue riêng được đối chiếu.
- Score sức mạnh, progression/recovery/goal targets cá nhân và nhiều tuần: dữ liệu/logic hiện dùng quy tắc cục bộ. Target nhóm kéo/chân chi tiết chưa đủ bằng chứng đối chiếu; không trích được engine gốc từ screenshot.
- Plan chưa đủ mọi split/PPL, variability, bodyweight-only và tự sinh superset/circuit/timed exercise; circuit chưa có vòng điều hướng hoàn chỉnh.
- Onboarding còn thiếu narrative trung gian và các nhánh chưa quan sát; paywall/SSO/StoreKit/restore/expiry/sync/Watch chưa có dịch vụ thật.
- Timer nền/âm thanh, Health write, full English/lb, accessibility, mọi trạng thái keyboard/validation và pixel-level comparison chưa đóng.
- Journal profile/badges, đầy đủ report/month picker, chia sẻ summary và các thao tác chưa audit trực tiếp vẫn cần đối chiếu.

## Kiểm chứng

- Build Debug simulator thành công sau nhóm thay đổi chính; build cuối và kết quả UI sẽ ghi ở VERIFICATION.md.
- 48 model checks đạt: 31 nền tảng + saved edit/add/remove, invalid edit không ghi, search/sort, template prescription/reset, tip persistence, timer warmup/main riêng.
- Cài đè giữ dữ liệu. UI đã kiểm guide, saved edit, recovery list/detail/front-back, goals expansion và metric bốn kỳ. Các case bổ sung và giới hạn ở VERIFICATION.md, SCREEN-COVERAGE.md và OPEN-GAPS.md.

## Các case UI phải chạy

1. Home → guide → 3 tab; đổi sang Journal rồi quay lại vẫn ở guide, tab bar còn hiện.
2. Journal → session → sửa một set → lưu → mở lại và trả số test về ban đầu; thêm bài/set rồi hủy không tạo dữ liệu rác.
3. Saved exercise → History → Trends → 1RM → các khoảng thời gian; back vẫn đúng stack và tab.
4. Body → Recovery → tất cả nhóm cơ → chi tiết; dismiss tip rồi mở lại vẫn đóng.
5. Goals → mở nhóm đẩy, thấy target/còn lại; tổng khớp contributions từ history.
6. Library → Tập nhiều nhất / Tập ít nhất / Chưa tập + search/gear; kết quả thực sự thay đổi.
7. Rest → đặt main/warmup khác nhau, log từng loại kiểm tra timer tương ứng.

Ảnh kiểm thử rebuild chỉ lưu cục bộ, không đưa vào Figma ảnh app gốc.

## Bổ sung sau live recheck R62–R67

Editor hồi phục và front/back/list đã thêm; logic override trong ngày chỉ là local. Đã sửa tab container để Lưu không bị thanh tab che. Menu saved exercise đóng sheet rồi push History/Guide; History dùng PillTabs. UI metric và giữ navigation khi đổi tab đã kiểm; slider Save, thêm bài/cancel, library tổ hợp và rest hai loại còn cần UI retest. Xem CHANGELOG.md ở root.
