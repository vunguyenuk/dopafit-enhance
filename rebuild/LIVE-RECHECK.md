# Đối chiếu app thật bổ sung R62–R67

09/11/2026, sau phản ánh thiếu UI/chức năng trên simulator. Ảnh lấy từ iPhone Mirroring app Dopafit gốc. Đã thêm vào Figma cùng mục đích, entry/exit, chính/phụ, dependencies và giới hạn. JSON nguồn: figma/additional-live-recheck.json; nhóm Figma33:510.

| ID | Quan sát thực tế | Rebuild / giới hạn |
|---|---|---|
| R62 | Home có7bài, một số2/4set; khác prescription beginner trước đó | Giữ mẫu/local generator; chưa biết nguyên nhân engine gốc đổi plan |
| R63 | Guide có anatomy trước/sau trong vùng media, hai thumbnail góc, ba tab | Có ba tab và ảnh crop; chưa có clip/mesh/góc quay gốc |
| R64 | Recovery mặt trước:0ngày,7cơ ready trong dataset original Row720 | Có layout/count local; rebuild hai session nên không so count như cùng dataset |
| R65 | Nút xoay đổi hình mặt sau | Đã thêm ảnh mặt sau tĩnh; màu không cập nhật theo dữ liệu, chưa là3D |
| R66 | Ready counter mở list full page: Sửa,10cơ chính, thumbnail, phần trăm, bài gần nhất | Đã có list push, thumbnail, phần trăm và bài gần nhất; chưa audit hết phần cuộn/nhóm phụ original |
| R67 | Editor có slider từng cơ, Lưu disabled trước khi đổi; copy nói ưu tiên cơ ready và bỏ qua0% | Có editor0–100/Save/Cancel; model kiểm clamp/persist/local expiry1ngày. Original Save/expiry/active-workout chưa test; rule local chưa xác nhận gốc |

Ảnh giữ ở rebuild/audit/R62–R67. UI đã test và phần còn mở ở VERIFICATION.md và OPEN-GAPS.md. Tất cả125ID có coverage row; số ảnh không chứng minh đã khám phá mọi màn.
