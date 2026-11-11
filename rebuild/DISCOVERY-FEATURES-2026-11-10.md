# Khám phá bài tập — phần mới được user duyệt, 10/11/2026

Đây là chức năng bổ sung theo ảnh Home Workout và phản hồi trực tiếp của user. Không phải màn original Dopafit, không dùng số lượng này để tăng parity của140 ảnh gốc/Figma. UI vẫn nền Ladder trung tính, primary lime/SF Dopafit.

## Danh mục

12 thử thách local, giữ ID3 thử thách cũ. Shelf → Tất cả12 → search không dấu + nhóm Tất cả/Toàn thân/Sức mạnh/Core/Thói quen → detail → join/leave. Ngày tiến độ là unique local days trong hạn sau join. Không tự tạo buổi khi join.

| ID | Nội dung | Tiến độ |
|---|---|---|
| consistent-14 | Xây nhịp tập | 6 ngày có tập/14 |
| upper-28 | Vững thân trên | 8 ngày thân trên/28 |
| lower-28 | Vững đôi chân | 8 ngày chân/mông/28 |
| physique-28 | Xây nền sức mạnh | 8 ngày thân trên/28 |
| fullbody-28 | Toàn thân28 ngày | 12 ngày có tập/28 |
| calisthenics-28 | Calisthenics | 12 ngày bài bodyweight/28 |
| pelvic-14 | Thói quen Kegel | Ghi nhận thực hành thủ công,14 ngày |
| core-14 | Core vững14 ngày | 6 ngày bụng/14 |
| dumbbell-30 | 30 ngày cùng tạ đơn | 12 ngày có bài tạ đơn/30 |
| activity-30 | Vận động30 ngày | 12 ngày có tập/30 |
| core-30 | Bụng khỏe30 ngày | 12 ngày bụng/30 |
| mobility-28 | Linh hoạt mỗi ngày | 12 ngày ghi nhận giãn cơ/28 |

Không bê nguyên lời hứa tăng chiều cao, giảm mỡ tại chỗ, chắc chắn có6múi hoặc kết quả điều trị. Kegel ảnh tư thế thư giãn chỉ minh hoạ, link NHS; checkin không đo kỹ thuật. Manual practice có xác nhận và undo hôm nay, lưu riêng `challengePractices`, không tạo workout hoặc Health. Bài giãn cơ không được đếm là buổi tập tạ. Quy tắc matching là local, không phải engine original.

## Chương trình theo nhóm

7 nhóm ×3 cấp độ =21 preset: Bụng, Cánh tay, Cẳng tay, Ngực, Chân, Mông, Vai & lưng. Một ảnh nhóm +3 hàng cấp độ; nhãn nhóm ngang gạch chân, không phải21 card ảnh lặp. Thời gian và số bài tính từ prescription thực tế; cấp độ lần lượt2/3/4set, thời gian khoảng13/19/25phút với nhóm3bài. Đây là mẫu chỉnh được, không phải giáo án cá nhân hoá đã được thẩm định.

Detail → từng bài mở guide; Add nối thêm UUID mới, giữ bài đang có. Replace có xác nhận và chỉ được khi draft chưa bắt đầu/không set hoàn tất. Không thay lịch sử. Chương trình gợi ý từ challenge dùng đường này. Thư viện cũ vẫn32bài;9 definition bổ sung chỉ qua preset, không tự nhập vào generator cũ.

Plank/farmer carry dùng số **giây**, không reps/volume tạ/1RM giả; editor lưu history và CSV `duration_seconds`. Ghi giây **thủ công**, chưa có countdown exercise interval tự động. Duration sheet giữ giá trị preset thực tế thay vì reset60phút.

## Media

27/32 bài thư viện có exact motion ExerciseDB. Thêm 6/9 definition preset: dead bug, crunch, push-up, wrist curl, reverse wrist curl, farmer carry. Tổng 33 pin GIF/MP4/guide; nguồn180px, guide720 là upscale, không nativeHD. Hai preset chưa có exact motion: bodyweight squat và glute bridge. Hai metadata/GIF lệch động tác bị loại; program-mapping-review.json và program-details/ giữ phản hồi nguồn.

Plank có video thật riêng ShotPot/Pexels4117854: thumbnail320, guide1080,25fps/4giây, crop/downsample từ4K. Cùng đoạn nguồn cho hai output, không AI/nội suy chuyển động; đúng forearm hold không thêm tạ. C136/C137 video guide phát, C138 hàng thumbnail. Khác kiểu anatomy các bài bên trên, không giả là ExerciseDB. Nguồn/license/hash/encode tại third_party/stock-motion/manifest.json; credit trong About.

13 ảnh thật có nguồn/license/hash. Theo user20:21, **không đổi màu**: thay sáu nguồn ảnh nhiều màu, bỏ saturation/tint. Ba ảnh được duyệt giữ nguyên. Core14 đã thay closeup bằng high-plank thấy tư thế; ảnh chỉ minh họa, không thay video kỹ thuật. Fullbody ảnh ngang6389079 giữ động tác chèo; mobility aspectFit. Không AI. C122–C127 và C140 là các thử nghiệm đã bị thay thế.

## Bằng chứng

C107 catalog12; C108Core2; C109thói quen2; C110–C112 Kegel join → ghi1 → undo0 → leave, record left còn trong test account; C113 search/filter empty. C114abs preset; C115/C116Add/Replace xác nhận rồi **Cancel**, không nhập vào draft chính; C117/C118forearms/advanced; C119wristcurl guide. Những ảnh này trước pass neutral/button mới.

C120/C121: phân cấp Add/nav/filter, tap đổi Cẳng tay đúng3hàng, Add→picker32→Close không thêm. C122–C127 thử giảm màu đã bị bác bỏ. C135 thumbnail Plank ban đầu còn khuất cuối viewport; C138 đã cuộn đủ hàng. C136/C137 video guide; C139 catalog nguồn tự nhiên; C140 ảnh dọc fullbody cắt tay nên thay bằng nguồn ngang. Bằng chứng ảnh cuối xem handoff-manifest.json.

109 model checks đạt:87cũ + chương trình, bảo toàn dữ liệu, practice/undo/persist, timed validation/save/reload/CSV. C128–C134 **bundle QA riêng** kiểm Replace7→3, Duration13,0giây không ghi được,30giây log/finish/volume0/HealthOff, sửa40giây và relaunch, Add7+3→10 giữ đúng7bài cũ/history. discovery-qa-run.json và hai state snapshot lưu chi tiết; chỉ QA bundle đã gỡ. Không ghi workout mới vào main7draft/2history. CSV chưa UI export. Còn mọi preset, countdown exercise, nhỏ màn/Dynamic Type/VoiceOver/lifecycle và benchmark; không gọi toàn bộ app đã hoàn tất.

Bằng chứng ảnh nguồn cuối: C141 toàn thân ngang; C142 vận động; C143 hai ảnh core; C144 core14 thấy tư thế; C145 Kegel/giãn cơ; C146 giãn cơ chi tiết. C147 Home phân cấp Add/Start/tab. Tất cả là ảnh rebuild cục bộ, không thêm vào bảng Figma original.

Latest22:31–23:00:33pins include standingpress A6wtbuL. ExerciseGuide/setentry use exact videos fullwidthsquare; no3D/staticfallback. Missingclip omits image only, retains actions. Home checkin is compactmenu, time-shortening moves to durationmenu; underlying rules unchanged.
