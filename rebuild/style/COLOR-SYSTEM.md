# Màu và phân cấp — 10/11/2026, checkpoint sau phản hồi 20:21

Giữ nguyên Dopafit primary RGB(0.71,0.96,0.24), xấp xỉ **#B5F53D**; SF family, weights và casing. User không cho đổi sang vàng/font Ladder. Học nền trung tính từ ảnh Ladder iOS Jul2024, không lấy logo/nội dung/media Ladder.

| Vai trò | Token hiện tại |
|---|---|
| Nền | #101010 |
| Card | #1E1E1E |
| Lớp nổi | #292929 |
| Sheet | #141414 |
| Chữ phụ | #A6A6A6 |
| Viền | #3E3E3E |

`ladder-neutral-samples.json` lưu mẫu deviceRGB từ 5 ảnh tham khảo134/139/140/160/167. Đây là lựa chọn token dựa trên ảnh raster, không phải trích xuất design system chính thức/pixel parity. Màu semantic push/pull/legs/blue vẫn riêng cho dữ liệu.

Phản hồi19:55: nhiều capsule và lime active gây nhầm vai trò. Chọn nhóm cơ trong chương trình dùng **nhãn + gạch chân2pt**, vùng chạm≥44pt, không capsule/viền xanh. Sticky Add là **viên thuốc108×52 trung tính, chữ trắng + icon, viền xám**; Start/Resume là nút nền lime chính. Root nav giữ khung capsule tổng nhưng không còn pill xanh/raised từng tab: active trắng + gạch lime nhỏ16×2. Không đổi route/label/action.

User20:21 bác bỏ đổi màu ảnh. `DiscoveryPhoto` hiện không có saturation/tint/filter: sáu ảnh nguồn khác thay các ảnh nhiều màu; ba ảnh được chọn trước (Gard Pro push-up, Samuel Girven shoulder press, Scott Webb leg press) giữ đúng file/hash. Toàn bộ 13 ảnh là ảnh thật với màu tự nhiên, không AI. Mobility aspectFit giữ tư thế; fullbody dùng nguồn ngang để giữ mặt/tay/dụng cụ. URL/tác giả/license/hash trong manifest. C122–C127 là thử nghiệm bị bác bỏ; không dùng làm chuẩn style hiện tại.

Bằng chứng ảnh nguồn cuối: C141 toàn thân ngang; C142 vận động; C143 hai ảnh core; C144 core14 thấy tư thế; C145 Kegel/giãn cơ; C146 giãn cơ chi tiết. C147 Home phân cấp Add/Start/tab. Tất cả là ảnh rebuild cục bộ, không thêm vào bảng Figma original.

Lịch21:50: outercard#1E1E1E, dảingày#292929, vòngngàytrốngcard/viền#3E3E3E. Đãtậpfillprimarylime/chữđen+tick; đangxemviềnlime hoặctrắngnếuđãtập. Ngàychưa tập không có olivefill. NhãnHômnay/Tthứ chỉ dùnglimegốc.
