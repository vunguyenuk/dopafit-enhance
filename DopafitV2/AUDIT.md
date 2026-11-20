# Dopafit V2 — audit 2 app và những gì bản mới giữ / sửa

Ngày 19/11/2026. So sánh:
- **App chính**: bản build master 8e8ebea9 (chạy trên iPhone qua iPhone Mirroring), review đầy đủ 96 màn ở https://claude.ai/artifact/57MCRs6cBCJ1nTHfVEeLhQ
- **App cũ**: DopafitRebuild (bundle `com.local.dopafit.rebuild`, chạy trên simulator)
- **Bản mới**: DopafitV2 (bundle `com.local.dopafit.v2`), project riêng, không đụng 2 app trên.

Hướng hình: **B — ảnh đen trắng, con số làm điểm nhấn**. Giao diện tiếng Việt.

## Giữ lại từ app chính
| Điểm hay | Trong V2 |
|---|---|
| Tự điền tạ sang set sau (#070) | Đánh dấu xong set → các set sau chưa sửa nhận cùng tạ và rep |
| Tính bánh tạ mỗi bên (#071) | Nút "Tính bánh tạ" ở bài tạ đòn, theo kg hoặc lb |
| Hộp "Bỏ buổi tập này?" rõ hậu quả (#074) | Giữ, dùng một kiểu hộp thoại cho mọi xác nhận |
| Menu một bài gom đủ việc (#061) | Menu ⋯: hướng dẫn & lịch sử, đổi bài, bỏ khỏi buổi |
| Ghi rõ giá và ngày tính phí (#045, #050) | Màn Pro ghi giá, dùng thử 3 ngày, nhắc trước khi tính phí |
| Màn trống có hướng dẫn (#063) | Mọi danh sách trống đều có câu hướng dẫn |
| Thông báo ghi rõ khi nào nhắc (#096) | Cài đặt > Thông báo |
| Có xóa dữ liệu (#097) | Cài đặt > Xóa toàn bộ dữ liệu |

## Giữ lại từ app cũ (DopafitRebuild)
- "Hôm nay thế nào?": mệt / đau một chỗ / ít thời gian, hoàn tác được, bài thay đổi có vạch xanh và ghi lý do.
- Một dòng lý do dưới tên buổi (vì sao tăng/giữ tạ).
- "Máy đang có người": đổi sang bài cùng nhóm cơ, ưu tiên dụng cụ khác.
- Quay lại sau ≥14 ngày nghỉ: tạ giảm 20%. Nghỉ 3–13 ngày: gợi ý bản 20 phút.
- Hướng dẫn chuẩn bị máy/ghế cho lần đầu tập bài, lỗi hay gặp.
- Chế độ nhẹ nhàng, cỡ chữ 3 mức, kg/lb, tập ở nhà.
- Lịch tuần gọn, lịch tháng ở Nhật ký.

## Sửa những lỗi cả hai app đang có
| Vấn đề | Cách V2 xử lý |
|---|---|
| Thiết lập ~37 màn, hỏi lặp (#005 vs #011–014, #006, #007, #025–027) | 6 bước, mỗi câu hỏi một lần, chỉ hỏi điều app dùng tới |
| Thiếu lựa chọn "trên 2 năm" (#008) | Có lại |
| 66 dụng cụ chọn sẵn (#030) | Chọn nơi tập: gym đầy đủ / gym nhỏ / ở nhà |
| "722 dSTRENGTH", Đẩy 17 vs Chân 1.708 (#078) | Một con số dễ hiểu: "ước tính nâng được X kg × 1 lần" |
| Số vô lý 6.060 kg, trục "2,0E7" (#089–#094) | Giới hạn nhập 0–400 kg, 1–100 rep, cảnh báo khi tạ cao gấp rưỡi lần trước; trục biểu đồ bám dữ liệu |
| Dấu thập phân lẫn lộn, kg lẫn lb (#079, #092) | Một kiểu: phẩy thập phân, chấm hàng nghìn; mọi chỗ theo đơn vị đã chọn |
| Nút nổi/thanh tab che nội dung (#051, #062, #084) | Nút đáy đặt trong vùng an toàn, nội dung được đẩy lên |
| Nội dung chạy dưới giờ/pin (#052, #088) | Có nền che thanh trạng thái |
| Paywall 2 + đếm ngược 15 phút (#049–#050) | Một màn Pro, nút X hiện ngay, thấy cả 2 gói, không đếm ngược |
| Vân tay ở lời hứa (#043), ảnh trước/sau (#039) | Bỏ |
| Màu nhiều nghĩa (#086): cam vừa "cần nghỉ" vừa tô cơ, đỏ, sọc xanh dương | Mỗi màu một nghĩa: xanh chanh = hành động/con số chính, tím nhạt = đang hồi phục, vàng cam = cảnh báo |
| Trộn 4–5 kiểu hình (nhân vật vẽ, hình nộm 3D, ảnh thật, đồ vật 3D) | Ảnh thật luôn đen trắng; video động tác đen trắng; sơ đồ cơ phẳng 2 màu (không còn hình nộm 3D tô cam kiểu Fitbod) |
| 4 tab, Mục tiêu tách rời | 3 tab: Buổi tập, Tiến bộ (hồi phục, sức mạnh, tuần này), Nhật ký |
| "Seed", tên tiếng Anh lẫn (#040, #089) | Toàn bộ tên bài tiếng Việt, tên tiếng Anh chỉ là dòng phụ |

## Còn thiếu / cần lưu ý
- Video 3D (`*-guide.mp4`, `*-thumb.mp4`) **chưa có bản quyền thương mại**, chỉ dùng demo. Clip ExerciseDB độ phân giải thấp.
- Sơ đồ cơ thể: react-native-body-highlighter 3.2.0 (MIT).
- Ảnh: Unsplash/Pexels, nguồn ở `third_party/challenge-photos/manifest.json` của repo.
- Chưa có: đăng nhập thật, thanh toán thật, đồng bộ, Apple Health, thông báo thật (công tắc chỉ là giao diện).
- Luật tập (tăng tạ, hồi phục, đau) là luật đơn giản tự viết, cần người có chuyên môn xem lại.

## Chạy
Mở `DopafitV2.xcodeproj`, chọn iPhone 18 Pro Max, bấm Run. Thêm file Swift mới vào thư mục `DopafitV2/` là Xcode tự nhận.
Tham số chạy: `--reset` xoá dữ liệu, `--demo` nạp 12 buổi tập mẫu (khi chưa có lịch sử).
