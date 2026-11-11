> Cập nhật hiện hành10/11: xem HANDOFF.md, EXERCISE-MEDIA.md và style/LADDER-STYLE.md.32catalog/26ExerciseDB GIF+MP4; primary lime/SF giữ nguyên; Home/picker được redesign có chủ ý; Form work paused. Các con số/checklist cũ bên dưới là lịch sử, không phải trạng thái hiện tại.

# Nguồn hình và dữ liệu hiển thị — 09/11/2026

## Bộ model hiện tại

Theo yêu cầu mới của người dùng, simulator dùng tài nguyên dẫn xuất từ nền tảng OpenGym3D/MakeHuman, thay các crop cơ thể/bài tập trước đây. Đọc OPENGYM-INTEGRATION.md. Board Figma134ảnh vẫn là ảnh app Dopafit ORIGINAL, không thay bằng ảnh rebuild.

- OpenGym3D repo `https://github.com/AssiamahS/opengym3d`, commit `ea3a60130fdcfb3c4771e44d09f84ebab4ee9bae`, v1pose pack MIT. Manifest pin archive/model SHA256 ở `third_party/opengym3d/manifest.json`.
- Model nam trưởng thành có cơ được tạo bằng MPFB2.0.16/Blender4.5.9, cùng nền tảng tạo người của OpenGym3D. Đây là mesh DẪN XUẤT được dựng trong lượt này, không được mô tả là model muscular có sẵn nguyên bản từ repo. Core MakeHuman mesh/targets/rig CC0; thông số chính xác trong generation.json; file chỉnh sửa `third_party/opengym3d/workfiles/muscular_source.blend`.
- `muscular_body.glb` và3clip retarget trong `DopafitRebuild/OpenGym3D/models`. Animation banđầu retargetrotation từpack trênrest-bonepositions/weights mới; bản10/11chỉnhIK chân/tay,hingespine,grip/fingers vàoneclip theo refinement-report.json.
- Chỉ3mapping: dumbbell-curl→bicep_curl, rdl→romanian_deadlift, goodmorning→good_morning. Các bài khác dùng minh họa nhóm cơ từ model mới; không có animation tương ứng. Ba clip refined có props procedural tạ/đòn, giữ1clipđồngbộ, neo chân vàcửchỉđãsửa; chưa được chứng nhận kỹ thuật tập.
- SceneKit vàThree dùng chung16maskmềm dẫnxuất từbone territories xấp xỉ. Không phải mask giải phẫu chính xác hoặc thuật toán Dopafit. Thumbnail cơ, preview bài và preview từng góc dùng cùng model mới, không còn lẫn PNG mannequin cũ.
- Three.js0.170.0 MIT, viewer bundle offline. Không nhập Mixamo live-site hoặc Z-Anatomy. Notices MIT/CC0 nằm trong bundle.

## Ảnh crop cũ

Thumbnail cơ cam trước đây là crop originalR66/R69; body/guide/các bài từng dùng screenshot audit. Các asset cơ/bài cũ và PNG mannequin v1 được giữ tại `rebuild/legacy-reference-assets`, không nằm trong Asset Catalog chạy. Một số narrative/chart/location/Pro/signin illustration vẫn là ảnh tham chiếu vì không có tài nguyên tương ứng trong pack. Không khẳng định mọi hình trong toàn app đã đổi thành3D.

## Phần trăm hồi phục và bài gần nhất

`AppStore.muscleRecovery` trong Models.swift vẫn là quy tắc LOCAL: xét72giờ, fatigue mỗi set hoàn tất12điểm cho cơ chính/6điểm cho cơ phụ, giảm tuyến tính về0 khi đủ72giờ; recovery=max(0,100-fatigue). Override thủ công trong ngày được ưu tiên. Heatmap3D nhận dữ liệu này; thay model không biến rule local thành engine gốc.

Dòng bài gần nhất lấy từ history giả rebuild. Rebuild có Incline765kg và Row720kg, original chỉ Row720kg tại mốc audit. Không so số phần trăm giữa hai dataset như bằng chứng engine đúng/sai. Remotion public là framework, không cung cấp source/media/thuật toán private Dopafit.

Bảnrefined dùngBlender4.0.2 hậu xử lý. InputGLB/workfiles/retargeted-v1 vàmuscular_source.blend gốc đượcgiữ; neutralđãchỉnh tạiworkfiles/refined_source.blend. Propsthủtục MITupstreamapproach,khôngnhậpmedia/licensekhác. Pulse/16masksourceởOpenGymBody.swift vàviewer-entry.js; GPUbảnmới chưaUIkiểm vìMac khóa. XemOPENGYM-INTEGRATION/motion-pulse-audit.
