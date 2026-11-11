> Cập nhật hiện hành10/11: xem HANDOFF.md, EXERCISE-MEDIA.md và style/LADDER-STYLE.md.32catalog/26ExerciseDB GIF+MP4; primary lime/SF giữ nguyên; Home/picker được redesign có chủ ý; Form work paused. Các con số/checklist cũ bên dưới là lịch sử, không phải trạng thái hiện tại.

# Phạm vi tương đương với Dopafit gốc

Không có căn cứ gọi bản dựng là bản sao 100%. Mức tương đương dưới đây mô tả kết quả hiện tại, không là phần trăm tiến độ hay cam kết production.

| Nhóm | Đã có trong rebuild | Giới hạn cần hoàn thiện |
|---|---|---|
| Style | Nền đen, lime, SF native, card charcoal bo góc, CTA dưới, thanh tab capsule, set hexagon, stack riêng mỗi tab | Guide vừa sửa source media/safearea/tốc độ VI/thumbnail theoR43/R63/D05, chưaUIkiểm. Chưa đo pixel toàn bộ màn; spacing, crop, background vàmột sốicon khácgốc |
| Onboarding | Mục tiêu/câu hỏi/pain point/story, nhập hồ sơ, focus, nơi tập, dụng cụ, tuần, thời lượng, reminder entry, hoạt động khác, xem lại, plan đã xong, giữ 2 giây và Pro introduction | Chưa có auth/StoreKit thật; narrative trung gian và checkout chưa tái dựng đủ; các nhánh khác chưa đối chiếu |
| Kế hoạch | Chỉnh goal/experience/days/duration/split/focus/equipment; lưu preferences; mẫu upper beginner 7 bài R50 | Generator cục bộ chủ yếu upper/lower/full-body + lọc dụng cụ/focus; goal/variability/PPL chưa có tác động tương đương gốc; beginner chỉ dùng mẫu đã quan sát |
| Buổi tập | Bắt đầu/tiếp tục, thêm/xóa/swap bài, chỉnh reps/tạ/set, warmup, log từng set/log all, RIR, notes, timer pause/resume, kết thúc/lưu | Không có engine tập đầy đủ, timed exercises chưa hoàn chỉnh; timer/sound/background delivery chưa tương đương app gốc |
| Superset | Active menu và chọn0/1/2/Hủy cùng trang, Lưu theo ngưỡng2; gom nhóm theoR77, header khi setcount bằng nhau;61modelchecks | Saveoriginal đã thấy đổi thứ tự nhưng chưa chụp đượcR77/rollback doMac khóa; ungroup/round execution/setcount không đều chưa đủ; UI reorder/header bản mới chưa kiểm. Home sheet vẫnlayout cũ, save dùng chung helper |
| Gym | Nhiều nơi, dụng cụ, nấc tạ đơn, thanh đòn, plate calculator, rename/type, chặn xóa nơi cuối | Đổi loại chỉ lưu metadata, chưa đổi preset; 13 loại dụng cụ so với preset gốc 65; chưa đủ nấc tạ riêng cho mọi thiết bị |
| Media | Ba tab guide, model muscular MakeHuman theo yêu cầu thay asset OpenGym3D,3clip retarget offline và4góc; thumbnail/model đồng bộ | Đây là asset thay thế được chấp nhận, không phải original.24bài chưa có clip;3clip refined cóprops/16mask/pulse vàmotionfix, chỉmớiQAoffline+build. C23–C36làmediaTRƯỚCrefinement; GPU/pulse/loading/error/coldlifecyclebảnmới cònchờUI |
| Thư viện | 27 định nghĩa bài mẫu và muscle/equipment/search/filter | Chưa đủ thư viện, cue theo bài đầy đủ, ranking swap; bài chưa có clip dùng model nhóm cơ thay thế |
| Nhật ký | Calendar, session detail, sửa RIR/set/bài sau lưu, thêm bài vào session cũ, history/trend và metric detail theo kỳ, 1RM, volume hai bên cho Row, CSV | Edit reps/save/reopen đã test, thêm bài/cancel cần UI retest; chưa đủ mọi metadata session, benchmark, streak/PR chuẩn gốc |
| Kết quả/hồi phục | Tab, biểu đồ, số ngày gần nhất, list/chi tiết từng cơ, editor chỉnh hồi phục, tip có lưu, dữ liệu set/log và local recovery | Model3D tô màu bằng bone territories xấp xỉ; recovery 72h/kcal 6 mỗi phút và override trong ngày là giả lập cục bộ |
| Mục tiêu/report | Cơ chính 1 set, cơ phụ 0,5; nhóm đẩy/kéo/chân; filter kỳ report | Vòng ba nhóm màu, target/còn lại và mở rộng đã bổ sung; target chi tiết nhóm kéo/chân vẫn quy định cục bộ; report chưa mọi biểu đồ và mọi kỳ gốc |
| Dữ liệu | Codable, atomic JSON, resume draft, lịch sử, CSV; kg/lb | Không có server/sync/multi-device/Watch hoặc migration production đầy đủ |
| Settings | Hồ sơ, ngôn ngữ, xuất (disabled khi trống), notification scheduling entry, Health request entry | English mới một phần; login/logout là local demo; StoreKit và Health workout writing chưa có |

## Những tài nguyên còn cần để hoàn thiện chính xác

1. Repo Dopafit thực tế hoặc tài liệu API/data schema, test environment và quy tắc sinh plan/progression/recovery.
2. Bộ media gốc: MP4 theo bài/góc, Remotion compositions cụ thể nếu có, ảnh dụng cụ, icon, mô hình và mask cơ.
3. Quyền tiếp cận các trạng thái account/paywall và test cases cho mua/restore/Health/Watch.
4. Đối chiếu màn gốc–rebuild cùng viewport, các trạng thái focus/keyboard/validation, rồi kiểm tra thiết bị/locale/accessibility.

Link Remotion do người dùng cung cấp là framework công khai để làm video bằng React. Nó chưa xác định source hoặc asset riêng của Dopafit. Không suy diễn rằng repo đó chứa logic iOS hay dữ liệu độc quyền.

Lượt sửa sau phản ánh thiếu UI: xem SIMULATOR-GAP-FIXES.md để biết chức năng nào đã bổ sung và bước kiểm thử UI còn lại. 134ảnh Figma không đại diện134trạng thái đã có trong simulator. Matrix từng ID ở SCREEN-COVERAGE.md; backlog G01–G12 ở OPEN-GAPS.md.
