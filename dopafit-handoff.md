# DopaFit — ghi chú chuyển tiếp (uxui-workflow)

Cập nhật: 19/11/2026. Kéo file này vào folder dự án DopaFit, rồi gõ `/uxui-workflow` và nhắc Claude đọc file này trước.

---

## 1. Bối cảnh dự án
- DopaFit: app tập gym cho iPhone (SwiftUI), nhắm tới **người tập gym ở Mỹ**.
- App lên plan riêng theo câu trả lời lúc thiết lập, ghi từng set, theo dõi sức mạnh và hồi phục từng nhóm cơ. Thu tiền bằng gói Pro, dùng thử 3 ngày (79,99 US$/năm hoặc 9,99 US$/tháng; ưu đãi 39,99 US$/năm ở paywall 2).
- **Anh Chẩn** (người góp ý chính): mục tiêu là làm theo **chức năng** của Fitbod, nhưng **icon và phong cách nhìn phải khác Fitbod**.
- Bản hiện tại để demo. Video hướng dẫn động tác đang dùng nguồn chưa mua bản quyền; Vu sẽ mua trước khi phát hành.
- Vu muốn giải thích bằng tiếng Việt dễ hiểu, tránh thuật ngữ; review UX thì dùng **ảnh chụp màn hình có khoanh đỏ và ghi chú**.

## 2. Các trang đã có
| Trang | Link |
|---|---|
| Bản đồ màn hình bản 28/10 (81 màn) | https://claude.ai/code/artifact/ae8589bd-81ad-4875-9cd2-472057f18579 |
| Review bản 28/10 | https://claude.ai/artifact/HHk8vQ8ZD8HNNroCG5pNF4 |
| Bản đồ màn hình bản 19/11 (96 màn, build master 8e8ebea9) | https://claude.ai/artifact/83CuuGJGbeKKy6ufA9LYxV |
| **Review bản 19/11 (mới nhất)** | https://claude.ai/artifact/57MCRs6cBCJ1nTHfVEeLhQ |

## 3. Đang ở đâu trong workflow
- `/uxui-workflow`, **Phase 1 · Requirements**, bước Discover.
- Đã làm: review toàn bộ màn (2 bản), play back ý tưởng. **Chưa có `requirements.md`.**
- Việc kế tiếp: Vu xác nhận play back (mục 7) → vòng hỏi đầu tiên gồm 4 câu ở mục 8 → các vòng tiếp theo → chốt problem statement → viết `requirements.md`.
- Hướng hình ảnh (mục 6) là quyết định của Phase 3, nhưng Vu muốn bàn sớm; ghi vào phần Brand & tone của requirements.

## 4. Review bản 19/11 — tóm tắt
Thiết lập ban đầu gần như giữ nguyên; trong app làm lại với 4 tab: Buổi tập, Cơ thể, Mục tiêu, Nhật ký.

**Đã sửa so với 28/10**
- Màn trả phí có nút đóng (#048), nhưng bấm vào lại mở paywall 2 (#049).
- Lời hứa khớp thiết lập (#043). Nút Tiếp tục ở chọn tuổi bật ngay (#024). Giới tính có "Khác" (#025).
- Tab chính ghi tên buổi tiếng Việt, không còn "Seed" (#051). Mất mô tả "Synthetic training fixture".
- Bỏ hệ rank Olympian. Dấu tích set chỉ còn một kiểu (#070). Bảng trượt lên dùng nút X tròn góc phải.
- Hộp "Bỏ buổi tập này?" rõ ràng (#074); tổng kết liệt kê đủ bài (#076).

**Chưa sửa**
- Thiết lập vẫn khoảng 37 màn trước đăng nhập; thanh tiến độ 3 đoạn nhích chậm.
- Hỏi lặp: rào cản (#005) vs 4 thẻ tự đánh giá (#011–014). Vẫn hỏi tính năng (#006), nguồn biết đến (#007). Hộp "bảo mật" lặp (#025–027).
- "Seed"/tên tiếng Anh còn ở #040, #089, #091.
- Số vô lý vẫn hiện: Squat 1.010 lần × 6.060 kg, 12.922.620 kg (#089, #091, #094).
- Ảnh trước/sau tự chụp (#039), biểu tượng vân tay (#043).
- Nhân vật vẽ vẫn dẫn chuyện phần thiết lập (phương án C chưa áp dụng).

**Vấn đề mới (Sửa ngay)**
- #078: "722 dSTRENGTH" là đơn vị tự đặt, không giải thích; Đẩy 17 / Kéo 303 / Chân 1.708 chênh nhau cả trăm lần.
- #094: trục biểu đồ ghi "2,0E7"; biểu đồ nhảy 0 → 14.000 kg.

**Vấn đề mới (Nên sửa)**
- #008 bỏ mất lựa chọn "trên 2 năm kinh nghiệm" (nhóm đông ở gym Mỹ).
- #030 câu dụng cụ mới: 66 món chọn sẵn, quá dài; mức tạ ghi "1,0; 2,0…" theo kg; ô tìm kiếm đè tiêu đề.
- #047 lúc mới mở chưa thấy nút đóng; gói Tháng bị che.
- #049–050 bấm X lại ra paywall 2 có quà và đồng hồ đếm ngược 15 phút: dễ bị cảm là giữ chân, đếm ngược phải là hạn thật.
- #051 nút "Bắt đầu buổi tập" đè danh sách; #052, #088 nội dung chạy dưới vùng giờ/pin khi cuộn; #062 thanh tab che hướng dẫn; #084 chú thích màu bị thanh tab che.
- #053 "Đã chọn 65" vs 66 ở thiết lập; nhiều thuật ngữ (Superset, Set khởi động, Bài trọng tâm, Mức thay đổi bài tập).
- #059 hai nút trông như bị tắt. #066 "100%" không giải thích. #067 nút dừng cùng màu xanh chanh với nút chính.
- #076 pháo giấy đè chữ kỷ lục. #079 dấu thập phân lẫn lộn (47,5 / 27.5 / 1.708), thẻ trống. #086 cam vừa là "cần nghỉ" vừa là màu tô vị trí. #092 dùng lb trong khi app dùng kg. #095 hồ sơ sức khỏe trống dù đã hỏi lúc thiết lập.

**Đang làm tốt (giữ lại)**: tự điền tạ sang set sau (#070), tính bánh tạ (#071), hộp bỏ buổi (#074), menu bài tập (#061), ghi rõ giá và ngày tính phí (#045, #050), màn trống có hướng dẫn (#063), cài đặt thông báo rõ (#096), có xoá tài khoản (#097).

## 5. Phong cách hình — vấn đề Vu nêu
App dùng cùng lúc: nhân vật vẽ kiểu truyện tranh (chỉ ở thiết lập), hình nộm 3D tối (cơ thể, hồi phục), ảnh người thật (ảnh mẫu gym tối, video nền xám, ảnh tự chụp), đồ vật 3D, hình nộm nhỏ trong thẻ. Bản 19/11 còn ghép hình nộm 3D đè lên ảnh thật trong từng ô bài tập (#051). Từ đăng nhập vào app đi qua 4 kiểu hình trong 5 màn (#037 → #039 → #040 → #051 → #075). Gốc vấn đề: chưa có quy tắc kiểu hình nào lo việc nào.

Chỗ giống Fitbod nhất về hình: hình nộm xám tô cơ màu cam đỏ, nền tối kèm ảnh mẫu.

## 6. Ba hướng hình ảnh (đều theo phương án C: bỏ nhân vật vẽ, ảnh thật cùng một tông)
**Phần làm chung cho cả 3:** mỗi màu một nghĩa (xanh chanh = hành động, một màu riêng = cần nghỉ, bỏ đỏ và sọc xanh dương); đổi "dSTRENGTH" thành số dễ hiểu ("nâng được 80 kg × 1 lần"); thống nhất dấu thập phân và kg/lb; bỏ ảnh trước/sau.

- **A. Giữ nền tối, đổi màu và icon.** Tô nhóm cơ bằng xanh chanh thay cam đỏ; icon nhóm cơ nét mảnh phẳng thay hình nộm 3D; ảnh giữ nguyên. Ít việc nhất. Rủi ro: vẫn trông như app gym tối, khó thấy khác Fitbod.
- **B. Ảnh đen trắng, con số làm điểm nhấn (Claude đề xuất).** Mọi ảnh và video chuyển đen trắng; xanh chanh chỉ ở số liệu và nút; số tạ, rep, kỷ lục in to kiểu bảng ghi phòng gym; sơ đồ cơ thể phẳng hai màu, bỏ hình nộm 3D. Lý do: đồng bộ ảnh từ nhiều nguồn với chi phí thấp nhất, khác Fitbod rõ nhất, hợp câu chuyện "thấy mình mạnh lên bằng con số". Rủi ro: hơi lạnh, cần thử độ ấm của xanh chanh.
- **C. Ảnh lớn kiểu poster, hình nộm thành dấu hiệu riêng.** Mỗi buổi có ảnh bìa tràn màn; hình nộm 3D chất kim loại phát sáng xanh chanh. Nhiều cảm xúc, dùng lại được cho landing. Rủi ro: tốn công nhất, cần bộ ảnh đồng bộ có bản quyền.

**Vu chưa chọn.** Câu hỏi đang chờ: chọn luôn một hướng, hay dựng thử cả 3 hướng trên cùng 3 màn (Buổi tập hôm nay, Ghi set, Cơ thể) để so.

## 7. Play back (chờ Vu xác nhận)
DopaFit là app tập gym cho iPhone, nhắm tới người tập gym ở Mỹ. App lên plan riêng theo câu trả lời lúc thiết lập, ghi từng set, theo dõi sức mạnh và hồi phục từng nhóm cơ, để người hay bỏ dở thấy rõ mình tiến bộ. Chức năng theo Fitbod, nhưng phong cách nhìn phải khác. Thu tiền bằng gói Pro, dùng thử 3 ngày.

## 8. Câu hỏi còn mở (vòng hỏi đầu tiên)
1. Lần làm lại này nhắm tới đâu: nhiều người đi hết thiết lập hơn, nhiều người trả tiền hơn, hay người dùng quay lại tập mỗi tuần?
2. Bản cho Mỹ làm tiếng Anh từ đầu, hay giữ cả tiếng Việt?
3. Ai duyệt cuối (anh Chẩn, khách hàng, Vu), và có giới hạn gì về thời gian hay phần code đã viết?
4. Khác Fitbod ở đâu: chỉ hình ảnh và icon, hay cả cách tính và hiển thị sức mạnh, hồi phục?

## 9. Nhật ký quyết định
| Quyết định | Các phương án | Chọn | Ghi chú |
|---|---|---|---|
| Cách làm | Review trước rồi vào workflow / workflow từ đầu / chỉ review | Review trước rồi vào workflow | |
| Phạm vi review | Một phần / toàn bộ | Toàn bộ màn | Đã review cả bản 28/10 và 19/11 |
| Hình cho phần cảm xúc, kể chuyện | A hình nộm làm nhân vật / B giữ nhân vật vẽ / C ảnh thật cùng tông | **C — thử** | Bỏ nhân vật vẽ; hình nộm cho cơ thể, video thật cho hướng dẫn |
| Mức giống Fitbod | — | Chức năng theo Fitbod, phong cách nhìn phải khác | Theo yêu cầu anh Chẩn |
| Hướng hình ảnh cụ thể | A / B / C (mục 6) | Chưa chọn | Claude đề xuất B |
