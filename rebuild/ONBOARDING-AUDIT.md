# Audit bổ sung onboarding Dopafit gốc

09/11/2026. 38 ảnh R01–R38 trong `rebuild/audit`; đã nhập cùng ảnh D01–D58 vào Figma người dùng. Đây là nhánh cụ thể đã khảo sát, không phải toàn bộ mọi tổ hợp câu trả lời.

Nhánh: Tăng sức mạnh → Không biết nên tập gì → nhu cầu sử dụng → nguồn Khác → Mới bắt đầu → Lúc tập lúc nghỉ → gần đây 2 buổi/tuần → ba câu hỏi pain point → câu chuyện sản phẩm → nhập hồ sơ bằng tay → 25–34 / Nam → không điều chỉnh số đo mặc định → ưu tiên Cân bằng → Phòng gym → giữ preset dụng cụ → 3 buổi T2/T4/T6 → 60 phút → nhắc nhở Để sau → không có vận động khác → xem lại thiết lập.

## Ma trận đã quan sát

| Ảnh | Mục đích và trạng thái |
|---|---|
| R01–R02 | Màn chào, reset minh họa, locale, đăng nhập entry; giới thiệu log set/progress |
| R03–R09 | Mục tiêu, rào cản, tối đa ba nhu cầu, referral, kinh nghiệm, mức đều đặn, tần suất gần đây |
| R10–R12 | Ba câu hỏi có/không: vóc dáng, không biết tập gì, không chắc form |
| R13–R15 | Tập theo cảm giác, bỏ lỡ buổi, plateau; số liệu minh họa |
| R16–R19 | Lời hứa hệ thống, plan cá nhân, tăng tạ, hồi phục |
| R20–R21 | Cam kết quyền riêng tư, bốn chỉ số Health đọc và workout ghi, có lựa chọn Tự nhập |
| R22–R25 | Nhóm tuổi, giới tính, chiều cao cm/ft-in, cân nặng kg/lb; có trường bỏ qua |
| R26–R27 | Focus tối đa hai nhóm hoặc Cân bằng; sheet giải thích volume/hồi phục có hai nguồn tiếng Anh |
| R28–R29 | Bốn nơi tập; preset Phòng gym chọn 65 dụng cụ; checkbox, tìm, nấc tạ |
| R30–R32 | 1–7 buổi, ba buổi mặc định T2/T4/T6; thời lượng 15/30/45/60/90 đã gồm nghỉ và warmup |
| R33 | Mời bật reminder theo ngày, chọn giờ 08/12/17/18/20; nhánh Để sau đã thử |
| R34–R35 | Không có/có hoạt động khác; sheet năm loại, ngày mỗi tuần, ngày cố định tùy chọn, mức độ |
| R38 | Sau Lưu và nhận plan mở màn đăng nhập Apple/Google, có Điều khoản/Chính sách; chưa tiếp tục xác thực |
| R36–R37 | Xem lại có nút Sửa; thiết bị ưa thích; mục tiêu/hồ sơ/nơi tập; lưu và nhận plan entry |

## Những điều audit này thay đổi

1. **Onboarding có phần giải thích sản phẩm dài trước cấu hình sâu.** Chuỗi pain point → cảm giác tiến bộ → lời hứa cụ thể là cơ chế thuyết phục quan sát được. Chưa có funnel analytics để biết giúp hay làm giảm activation. Cần đo drop-off mỗi bước và thời gian tới buổi đầu, tách người mới/người tập đều.
2. **Không bắt buộc dùng Health để đi tiếp.** Đã đi nhánh Tự nhập và tới trang xem lại. Chưa cấp Health, chưa kiểm tra dữ liệu được đọc/ghi. Các câu “không bán”, “mã hoá” là lời app trình bày; audit giao diện không chứng minh backend thực hiện.
3. **Plan ban đầu có yếu tố chọn mẫu.** Footer R36 ghi sẽ chọn một plan soạn sẵn hợp trình độ và nơi tập. Chỉ kết luận về lời giải thích ở nhánh này; chưa suy ra toàn bộ hệ thống không thích ứng hay không có mô hình AI.
4. **Số đo mặc định và dữ liệu đã lưu có thể khác nhau.** R24/R25 hiển thị 170 cm / 68 kg; sau Tiếp tục mà không kéo thước, R37 hiện Chưa trả lời. Đây là rủi ro hiểu nhầm trạng thái, cần tái hiện bằng chọn/đổi đơn vị/kéo/back rồi lưu, chưa chốt bug. Tiêu chí: người dùng biết rõ đang bỏ qua hay chấp nhận con số.
5. **Có giải thích giới hạn focus.** R27 giảm phán đoán “app áp đặt hai nhóm không lý do”. Chưa kiểm tra độ đúng của tài liệu khoa học được app liên kết và tác động thực tế của focus lên plan.

## Còn chưa kiểm chứng

- Cập nhật sau: người dùng đã đăng nhập và luồng R39–R61 được audit ở POSTLOGIN-AUDIT.md. Tạo/khôi phục tài khoản, trial/purchase/restore vẫn chưa kiểm thử đầy đủ.
- Tất cả mục tiêu/kinh nghiệm/nơi tập khác, nhánh có hoạt động khác đã mở nhưng chưa lưu; chỉnh toàn bộ 65 dụng cụ.
- Permission Health/notification, delivery reminder, cloud và dữ liệu nhiều tuần.
- VoiceOver/Dynamic Type, English đầy đủ, hiệu năng/animation/frame rate, mất mạng/force quit giữa onboarding.

Mirroring nhiều lần pause/timeout hoặc tiến trình đóng trong lúc thao tác. Không ghi các gián đoạn hệ thống này thành lỗi Dopafit. Không mua gói, không ghi buổi giả vào Health, không gửi tin nhắn hay dữ liệu cho người trong ảnh Slack.
