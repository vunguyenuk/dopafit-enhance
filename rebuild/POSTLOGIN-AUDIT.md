# Audit sau đăng nhập và bổ sung vào rebuild — 09/11/2026

Mốc lịch sử: tài liệu này ghi119ảnh đếnR61. Live recheck bổ sungR62–R67 đưa tổng lên125; xem LIVE-RECHECK.md, SCREEN-COVERAGE.md và CHANGELOG.md.

Người dùng tự hoàn tất đăng nhập trên app Dopafit gốc. Các ảnh R39–R61 chụp từ iPhone Mirroring, không từ simulator. Tổng danh mục hiện có 119 ảnh trạng thái: 58 D + 61 R. Có các trạng thái gần nhau (R42/R43 là guide), không có nghĩa 119 màn độc lập hay đã kiểm hết sản phẩm.

## Luồng và bằng chứng mới

| Bằng chứng | Quan sát / thao tác | Kết luận trong phạm vi mẫu |
|---|---|---|
| R39–R41 | Plan đã xong → narrative chuyển tiếp → lời hứa giữ 2 giây → Pro introduction | Onboarding còn có activation, cam kết và bước giới thiệu giá sau đăng nhập. Fingerprint là long press động viên, không phải xác thực sinh trắc. |
| R41 | $56.99/năm và auto-renew copy | Giá hiển thị trên tài khoản đang khảo sát; chưa xác minh storefront Mỹ. Màn chọn gói xuất hiện ngắn, chưa có ảnh ổn định. Không bấm mua. |
| R42–R44 | Guide Row có hai thumbnail góc; plan Mới bắt đầu, 3 buổi, 1 giờ, 65 dụng cụ | Có UI chọn góc cho bài này; chưa xác minh playback khi đổi góc hay cả thư viện. R42 đã chuyển sang guide lúc chụp, đã sửa chú thích tương ứng. |
| R45 | Đổi tên / Đổi loại nơi tập / Xóa disabled | Phải giữ ít nhất một nơi tập. Chưa thử xóa gym trên app gốc. |
| R46–R48 | History 0, export disabled, Pro label, đổi English | Empty export phụ thuộc số buổi. Không biết danh tính account giữa các phiên; không kết luận lịch sử cũ bị mất. |
| R49–R52 | English Home → active → Row; log đúng một set 12 reps ×30 kg | Reps mỗi bên, tạ mỗi tay. Không log hai set còn lại hay các bài còn lại. |
| R53–R54 | Finish và lưu: 720 kg, một bài, một set | Volume = 12×30×2. Health tắt; không ghi buổi test vào Health. 1RM không được nhân đôi theo volume. |
| R55–R57 | Sau lưu mở menu → RIR → chọn 3 → Done | Có thể sửa RIR sau lưu dù chỉ một set đã hoàn thành. |
| R58–R61 | Streak 1/3, còn hai ngày; journal; mở lại session/menu | Session vẫn 720 kg; RIR 3 tồn tại sau mở lại. Locale đã trả Same as phone / theo máy. |

Buổi test mới này khác buổi Incline 3×6×42.5 = 765 kg / RIR 2 ở ngữ cảnh trước. Không gộp thành một buổi hoặc coi history trống sau login là lỗi dữ liệu.

## Đã đưa vào app hiện tại

- `PostSetupFlow.swift`: Plan đã xong, lịch tuần, giữ 2 giây, Pro introduction. Native controls; ảnh marketing là crop tham chiếu. Luồng lưu thiết lập cục bộ nối vào chuỗi này. `--audit-post-setup` mở trực tiếp để đối chiếu, giữ history.
- Gói Pro chỉ là giao diện tham chiếu; nút tiếp tục bản thử thay bước checkout vì chưa có StoreKit/backend. Không tạo entitlement hay giao dịch thật. Narrative trung gian chưa có ảnh ổn định và chưa tái dựng đầy đủ.
- Catalog thêm bảy bài plan beginner đã quan sát. Prescriptions khởi đầu là mẫu đối chiếu, không chứng minh thuật toán cá nhân hóa. Bộ lọc dụng cụ/focus/thời lượng và progression vẫn dùng quy tắc cục bộ.
- Row lưu `repsConvention`, `volumeMultiplier=2`, nhãn mỗi bên/mỗi tay; summary/history/trend/CSV dùng cùng phép tính. Không tự nhân đôi tất cả bài tạ đơn chưa kiểm chứng.
- Menu trên bài của buổi đã lưu và summary: guide/history, preferences, sửa RIR 0–4+, ghi JSON, đọc lại khi mở. Sửa RIR không thay reps/tạ/volume.
- Khóa xuất CSV khi chưa có buổi. Menu gym thêm rename/type, chặn xóa gym cuối, chọn gym còn lại khi xóa gym đang dùng. Đổi loại hiện lưu metadata, chưa tự áp dụng preset 65 dụng cụ như app gốc.

## Kiểm chứng và phần còn mở

Build Debug thành công, cài và launch bản mới trên iPhone 18 Pro Max iOS 27.3. **31 model checks qua**, gồm mẫu 720 kg, 1RM mỗi tay 42 kg theo công thức cục bộ, RIR sau lưu/reload, CSV convention và ràng buộc gym. 1RM 42 kg ở đây là kiểm tra mô hình rebuild, chưa đối chiếu 1RM Row của app gốc.

Sau khi Mac mở khóa, đã thử UI chuỗi plan/cam kết/Pro → Home, sinh plan beginner, log một set Row và lưu summary 720 kg. Đã sửa RIR Incline 2→3 và mở lại vẫn 3; Row đã terminate/launch và mở lại trên UI vẫn 720 kg / RIR 3, khớp JSON. Gym UI rename/type lưu đúng, xóa nơi cuối disabled; trả tên/loại về Phòng gym sau thử. Bằng chứng ảnh ở `rebuild/verification/B-*.png`; không đưa ảnh rebuild lên Figma.

Chưa đóng: SSO thật, purchase/restore/expiry, cloud/sync/offline/crash, Health/Watch, toàn bộ English/lb, tất cả plan/nhánh onboarding, chỉnh set trong session cũ, đủ media/dụng cụ/bài tập, timer nền, accessibility và pixel comparison toàn bộ màn. Xem PARITY.md; chưa có cơ sở gọi bản dựng giống 100%.

## Figma

[R39–R44](https://www.figma.com/design/2lNpfPEq2wVnGk07bVLghz/Dopafit?node-id=19-2), [R45–R50](https://www.figma.com/design/2lNpfPEq2wVnGk07bVLghz/Dopafit?node-id=19-169), [R51–R56](https://www.figma.com/design/2lNpfPEq2wVnGk07bVLghz/Dopafit?node-id=19-336), [R57–R61](https://www.figma.com/design/2lNpfPEq2wVnGk07bVLghz/Dopafit?node-id=19-503).

Ảnh gốc được đặt trong 23 khung mới; tên/mục đích/điểm vào–ra/yếu tố chính–phụ/phụ thuộc/giới hạn là text chỉnh sửa được. Canvas kiểm đếm 119 card ID và 119 image fills, 22 root groups, không trùng ID, không thiếu font. Không có ảnh simulator hoặc Fitbod trên canvas này.


Cập nhật đồng bộ: sau khi Mac mở và Figma desktop kết nối lại, đã sửa đủ bảy dòng dẫn chiếu R42 trong các card lân cận. Đọc lại bằng connector xác nhận 7/7 đúng nội dung trong nguồn. Bằng chứng và node IDs ở `figma/completed-flow-corrections.json`. Bộ ảnh vẫn 119 card/119 image fills, 22 root groups, không thiếu font.
