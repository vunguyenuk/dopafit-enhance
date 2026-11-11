> Cập nhật hiện hành10/11: xem HANDOFF.md, EXERCISE-MEDIA.md và style/LADDER-STYLE.md.32catalog/26ExerciseDB GIF+MP4; primary lime/SF giữ nguyên; Home/picker được redesign có chủ ý; Form work paused. Các con số/checklist cũ bên dưới là lịch sử, không phải trạng thái hiện tại.

# OpenGym3D — nguồn asset và trạng thái tích hợp

Người dùng cung cấp https://github.com/AssiamahS/opengym3d và yêu cầu thay ảnh crop hiện tại; sau đó yêu cầu model phải có cơ bắp và không bị lỗi. Đây là ngoại lệ được người dùng chấp nhận đối với yêu cầu sao chép asset Dopafit. Giữ style/layout/flow gốc; không thay ảnh original trên Figma bằng model rebuild.

## Nguồn đã pin

- Repo OpenGym3D commit `ea3a60130fdcfb3c4771e44d09f84ebab4ee9bae`, archive `dist/opengym3d-exercise-pack-v1.zip`, SHA trong `third_party/opengym3d/manifest.json`.
- Code/v1pose pack MIT, copyright SylvesterAssiamahGK; notice nằm trong bundle `OpenGym3D/licenses/OpenGym3D-MIT.txt`. V1 là pose-authored, không phải mocap mới của live site. Không nhập các clip Mixamo từ live site hoặc nhánh Z-Anatomy có license khác.
- Three.js0.170.0 được bundle offline qua esbuild0.24.0; Three MIT notice trong bundle. Không tải CDN/API khi app chạy. Không cần chạy npm để dùng app đã build; chỉ rebuild viewer JS khi sửa source.
- Nền tảng tạo người của OpenGym3D là MakeHuman/MPFB. Core mesh/targets/rig là CC0 theo tài liệu chính thức: https://www.makehumancommunity.org/about/license.html . MPFB add-on code GPL3 chỉ dùng ở công cụ build, không bundle vào app.

## Các mốc model

1. Bản đầu thay crop bằng neutral mesh/v1clips trong pack. UI đã render được front/back, list muscle thumbnails, animationRDL/góc bên/góc sau/tốc độ0.5. Các ảnhC15–C22 ghi mốc này; model còn quá mannequin, user đã yêu cầu sửa.
2. Bản muscular trước refinement: nam trưởng thành muscle1.0, weight0.55, age0.5; detail targets ngực/lưng/vai/tay/chân/abs. Baked macro/detail vào mesh thật trước export. Cùng một muscular_body và3clip retarget trên rest-skeleton mới đã vào bundle; không còn body mới/clip cũ. Các PNG mannequin đã cất ngoài Asset Catalog; thumbnail cơ/preview bài/4góc dùng model mới.

### Kiểm chứng muscular trước refinement (evidence lịch sử)

- Kiểm toàn bộ214frame: neutral1, curl63, RDL77, goodmorning73. Tất cả finite, bounds không bùng (>2.6m), edge tối đa0.0849m dưới ngưỡng0.30m. QA report gắn SHA đúng model đang ship. Đây là ngưỡng phát hiện lỗi lớn, không kiểm được mọi self-intersection.
- Đã xem neutral front/back và9render pose giữa clip từ trước/bên/sau: chưa phát hiện rách mesh hoặc giãn chi rõ rệt. `rebuild/verification/muscular-preview-front.png`, `muscular-preview-back.png`, `muscular-pose-review.png` là Blender renders, không phải simulator screenshot.
- Asset integrity/GLB weights/indices/animations/notices đạt;61modelchecks đạt; Debug build/cài/launch thành công. Viewer nguồn JS syntax hợp lệ và bundle lại thành công.
- 10/11: UI muscular đã xem trên simulator (C23–C32): trước/sau/list10+6cơ; RDLgóc1/2/3 và0,5×/1×, đổi tab giữ; Goodmorninggóc2/1×; Curlgóc2/4 và1×/2×. Không thấy lỗi mesh lớn/crash ở các case này. Không coi mọi tổ hợp đều đã test. C15–C22 là model cũ.
- Phát hiện vùng đen lúc tải clip; đã thêm model tĩnh + nhãnloading rồi remove khi ready. Loading→ready đã UI kiểmC35/C34; iOSHome→return clip giữC36. Error fallback chưa fault-inject, cold relaunch còn cần kiểm.
- UI curl được thêm tạm vào draft rồi xóa, không log set/finish; dữ liệu cũ giữ. Figma hiện130original images/26roots sau bổ sungR72; không có render/rebuild.

## Thành phần app

- `OpenGymBody.swift`: đọc neutral GLB positions/normals/joints/weights thành mesh SceneKit, tô16mask mềm dẫn xuất từ bone territories xấp xỉ, render thumbnail cache và front/back. Đây chưa phải mask anatomy chính xác của Dopafit. Recovery percentages vẫn logic local trong Models.swift; chỉ màu render nhận dữ liệu đó.
- `OpenGymAnimationView.swift`: WKWebView+Three glTF parse từ dữ liệu bundle, không file fetch/CDN; clip/góc/tốc độ, dừng animation khi tab/scene không active. Có model tĩnh dự phòng khi WebKit/load lỗi; viewer bỏ kết quả load cũ khi đổi model nhanh.
- Mapping chỉ `dumbbell-curl→bicep_curl`, `rdl→romanian_deadlift`, `goodmorning→good_morning`. Các bài khác có minh họa cơ; không gán animation sai bài/dụng cụ. Ba clip dẫn xuất hiện có props tạ/đòn và cử chỉ sửa thêm; không coi là video form gốc hoặc form đã được chuyên gia chứng nhận.
- Hero welcome/goals, setup recovery/focus và core exercise/body media đã chuyển sang model. Narrative ghép chart/UI, location và Pro/signin illustration còn ảnh tham chiếu; đây không phải bộ chuyển động tương ứng trong repo. Crop cơ cũ đã chuyển sang `rebuild/legacy-reference-assets`, không còn trong Asset Catalog chạy.

## Rebuild và kiểm

`./scripts/run-simulator.sh`, `./scripts/check-models.sh`, `python3 scripts/check-opengym-assets.py`.
`./scripts/build-opengym-viewer.sh` để bundle JS từ source và package-lock.
Asset generation đã dùng Blender4.5.9 official trong `.build/blender-4.5.9-volume` (DMG mount read-only, không thay Blender4.0 đã cài), MPFB2.0.16 từ official extensions với SHA `b5cdc8b08147e0c6463e4faa01147491b13a0b062f73415363f029debd11c934`. 10/11: DMG đã eject/xóa để giải phóng ổ gần đầy; mount hiện không còn binary. Muốn regenerate model cần tải lại Blender4.5.9 official, source.blend/GLB/MPFB vẫn còn. Scripts không save Blender preferences. Core MakeHuman assets CC0; MPFB tool code không bundle vào app.

### Chỉnh tiếp và tránh quay về asset cũ

1. Source chỉnh sửa được giữ tại `third_party/opengym3d/workfiles/muscular_source.blend` (2.9MB), thông số và source/derived hashes trong cùng thư mục cha. Không chỉ nằm trong.build.
2. `python3 scripts/prepare_opengym_assets.py` stage MIT upstream originals vào.build/opengym-original, không ghi đè bundle. Muốn dựng lại macro/detail từ đầu: chuẩn bị MPFB2.0.16 ở.build/mpfb-2.0.16 rồi chạy build_muscular.py bằng Blender4.5.9. Không dùng Blender4.0 cho add-on này.
3. Chạy retarget_muscular.py (dùng generated source.blend mới nếu có, nếu không dùng bản workfiles), rồi qa_muscular.py bằng Blender background. Output trong.build/opengym-muscular. Ví dụ đặt BLENDER_USER_CONFIG=$PWD/.build/blender-profile và BLENDER_USER_EXTENSIONS=$PWD/.build/blender-extensions để tách profile công cụ.
4. Xem toàn bộ render, chỉ copy4GLB đã QA sang bundle cùng lúc; update manifest.models SHA, generation/retarget/geometry reports và source.blend. `upstreamModels` là hash pack gốc, không được thay bằng hash dẫn xuất. check-opengym-assets.py buộc hash QA khớp model shipped.
5. Build, test UI những thay đổi mới và chụpC33+ khi máy mở khóa; C23–C32 đã là evidence muscular. Giữ partial cho các gap media chưa đủ; mask anatomy chỉ xấp xỉ; bản refined có props nhưng24bài vẫn thiếu animation. Geometry QA không chứng minh kỹ thuật tập đúng hoặc không còn mọi lỗi.

## 10/11 — Refined motion, props và muscle pulse hiện đang ship

Lỗi thực đã phát hiện thêm sau QA cũ:2skeletal clips trùng, viewer phát cả2; foot drift/penetration; spine quá cong khihinge; Goodmorning tay qua ngực; dấu gập finger thay giữa frame. Cũ chỉ kiểmfinite/bounds/edge nên không đủ. Đã sửa một clip NLA chungbody+props, IK chân, rest-spine hinge, Goodmorning back-rack grip, cổ tay theo forearm vàfingercurl direction cố định;2dumbbell tách nhau. Mesh weld duplicate seams, smooth cục bộ vùng pec/shoulder, bỏ custom splitnormals cũ; không bịt bừa mắt/khe giải phẫu.

4GLB mới cùng16mask `_MUSCLE_0…3` VEC4; tên schema trong rootextras.openGymMuscleNames. Masks approximate từskinning+băng vị trí, không phải anatomy groundtruth. Cảnative+Three dùng cùngweights; props khôngmask. Three chỉ phát duy nhất1clip, cơ chính cammạnh/phụ0.45; pulse theo pha động tác. Nativepreview pulse1.8giây; thumb/recovery khôngpulse. ReduceMotiongiữsteadyhighlight, hidden/tabinactive dừng pulse/clip. Camera không bịreset khiđổiheat/speed, fitcả chiều ngangprop. Shader/contexterror có fallbacknativebody giữheat/góc (chưafaultinject).

Kiểm mới:214frame đều passngưỡngfinite/bounds2.6m/edge0.3m, footanchor≤2mm, grip≤25mm,loopseam≤5mm,maxvertexstep≤100mm/frame; thực tếfoot<0.006mm,grip<1.1mm,seam<3.1mm,maxstep68.1mm/frame. MinmeshZ≈−11.2mm vẫn trongtolerance15mm, không gọi là hoàn toàntrênsàn. 9keyframe/góc mỗiclipđược render;9ảnhreview chọn giữ trong rebuild/verification/refined-model. Không chứng minh khôngcònmọi self-intersection/lõm/cửchỉsai.

Three170 CPU QA parse đúng1clip,maskattrs,skin+prop,5pha×3clip×17,515đỉnh finite; report rebuild/verification/three-runtime-qa.json.61modelchecks,assetgatevàDebugbuild/cài/launchđạt. **Mac khóa nên UI/GPU/pulse/style bản mới CHƯA kiểm.** C23–C40 là evidence phiên bản trước, không dùng làmproofbản mới. Figma134ảnhoriginal/27root, không có renderrebuild.

### Dựng lại đúng phiên bản refined

- Input4GLB cố định ở third_party/opengym3d/workfiles/retargeted-v1, hash trong manifest.refinement.inputHashes; source muscular_source.blend gốc vẫn giữ. Không chạy refinementtrênoutputrefinedlầnnữa.
- Blender4.0.2 installed `/Applications/Blender.app/Contents/MacOS/Blender`, không cầnMPFBcho bướcrefine. Dùng `--factory-startup --background --python-exit-code 1`, BLENDER_USER_CONFIG=.build/blender-profile-4, không save userprefs.
- Chạy scripts/opengym/refine_motion.py, CHỜxong; python3 scripts/opengym/bake_muscle_regions.py, CHỜxong; Blender scripts/opengym/qa_refined.py. Output .build/opengym-refined. QA/load/render thất bại thì không promote.
- Chỉ copy4GLB sauQA+review; update manifest.models,geometry-qa,refinement-report,muscle-mask-report; neutraleditable mới là workfiles/refined_source.blend. Giữsourcecũđểtruyxuất.
- Bundle JS từ scripts/opengym/viewer-entry.js bằng esbuildđãpin. `node scripts/opengym/qa_three.mjs` kiểmloader/skinningCPU; `python3 scripts/check-opengym-assets.py`, `./scripts/check-models.sh`, `./scripts/run-simulator.sh`. GPUshader/nativeflash vẫn cần UI.
