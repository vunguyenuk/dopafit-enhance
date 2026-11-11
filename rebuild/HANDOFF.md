# Bàn giao hiện tại —10/11/2026

## 2026-11-11 07:18 — hoàn tất kiểm video trực tiếp sau mở khóa

C172Home app chính thấy thumbnail ZenithRow/Skullcrusher, Smith/BackFly vẫn clipExerciseDB cũ đúng fallback. C173RowguideNam fullwidth giữ người/ghế, rõ hơn ảnh180px cũ bằng quan sát; C174chọn0,5× và thấy pose đổi. Không đo FPS.

Tạo **com.local.dopafit.zenithqa** từ compiledapp mới, bundle/container riêng; fixture giữdraft cục bộ, profileNữ, history0/checkinrỗng. C175thumbnailRowNữ; C176guideRowNữ fullwidth; C177tabNhómcơ vẫn phát clip, pose khác; C178sauQAStart trangghiSet dùng videoNữ. Không bấmGhi/Lưu/Health. QA0set/0history đã terminate/uninstall; live-ui-run.json xác nhậncleanup. Main vẫnNam/7bài/chưa bắt đầu/0set/2history/checkinĐangđau và toàn bộ snapshot không đổi so trước nhậpmedia; đã trả appchính Home.

Đây là UI sample củaRow ở2profile, không phải21bài đều đã tap-through.80MP4 đãdecode/sourcecropQA ở lượttrước;126modeltests/buildgiữ kếtquả, không rerun khi chỉ chụpUI. Còn4library+1preset thiếumotion, một sốfallback180px, chưabenchmarkFPS/alllifecycle/VoiceOver/anatomy. Figmaoriginal140/28 không thay. ChặnMaclock ở checkpoint06:45 đã hết; không tiếp tục báo pendingunlock.

## 2026-11-11 06:45 — nhập video vừa tải, kiểm lại đúng biến thể

User báo fetch-zenith-videos.sh25file và fetch-zenith-female.sh22file tải xong. Đã probe đủ47source:1920×1080, khoảng5,23–6,64giây, fps29,97/30. Không coi thông báo tải0lỗi là chứng nhận motion/variant/license.

Đã review3pose mỗi source +Arnold12frame, sửa pipeline chỉ encode allowlist. **21bài**, trong đó**19bài có thêm file nữ**, tổng40motionvariants/80MP4 (guide720,thumb240),12.739.610bytes. Crunch mặc định đã là nữ; closebench không có bản nữ. RootView ưu tiên nữ theo kế hoạch có sẵn giữ nguyên. Cropdetect dùng toàn bộframe, padding8/12%, giữ timingnguồn, không opticalflow/AIpose. Nguồnraw giữ nguyên; outputcũ archive. Không sửa màu/font/UI/buổi tập.

Sửa mapping sai từ lượtClaude trước: source “dumbbell-bent-over-row” thực tế bench-supported1tay → gắn dumbbell-row, KHÔNG gắn bài kéo2tay. Không bundle reversefly2tay cho catalog1tay; seatedshoulderpress không thay standingpress; straightlegdeadlift chưa xác minh đúngRDL; hipraiseplank không phải glutebridge. T-Bar đã thấy đứng straddlelever/footplatform, không chestpad. RDL/standingpress/bilateralDBrow giữ clipExerciseDB đúng biến thể; reversefly/glutebridge thiếuclip thì không giảảnh. mapping-review.json là allowlist/rejection nguồn chuẩn.

Kiểm chứng:80MP4 decode hết không lỗi,40variant đều có ≥2pose khác trong3mốc; đã xem6contactsheet đầu ra, không thấy cropmất người/dụngcụ ở pose lấy mẫu. Build/install/launchđạt, assetgate kiểmraw/outputhash+allowlist+khôngorphan; installed81file (80MP4+manifest) đúng nguồn, không sót clipbịloại. **126modelchecks đạt**, gồm các thay đổiClaude qua đêm; không coi là126luồngUI. Nguồn1080canvas vàcrop720 không còn là upscale180cũ, nhưng không chứng nhận FPSrender thực tế hay anatomy.

Main trước lượt này:7bài/chưa bắt đầu/0set/2history, Nam, checkinĐangđau. Snapshot main-state-before.json hôm11/11 ưu tiên hơn checkpointKhỏe10/11; không restore snapshotcũ. Data sau build so nguyênsnapshot không đổi. UI nam/nữ đang chờ Mac mở khóa; chưa có ảnhsimulator mới thì không ghi đãUIverified. Mediaquyền vẫn unresolved/localdemo như đã ghi; không xuất bản.

## Cập nhật 22:31–23:00 — video, sheet lưu và Home gọn hơn

Theo ảnh/user steering: ExerciseDetail và ExerciseGuide dùng clip ExerciseDB thay model Form/OpenGym ở phần minh hoạ bài. Thêm đúng biến thể standing dumbbell overhead press A6wtbuL: 27/32 bài thư viện +6 preset =33 pin; source response/GIF/hash/QA lưu cục bộ. Không fallback 3D/static hay giả nút phát khi thiếu clip. Body map giữ nguyên; Form mesh vẫn paused. ExerciseThumb chung đã bỏ MuscleGlyph ở Active/selection/saved editor/progress rows, bổ sung chỗ còn sót ở lượt22:30.

User22:47 bác khung220pt quá nhỏ: video ghi set và guide nay full-width square, aspect-fit giữ trọn người/dụng cụ, respect safe area; C161–C164 là kích thước cũ. Nguồn180px,720px chỉ upscale, không nativeHD/không thêm pose. Thiếu exactclip vẫn là gap.

FinishSheet có nền đặc liền khối/bo góc hệ thống, nội dung cuộn và hai CTA cố định, disabled Save trung tính rõ chữ kèm lý do cần ít nhất1set; không đổi luật lưu/Health. Home theo22:51/22:54: bỏ khung lồng trong lịch, paddingvertical8/gap4, mục tiêu18pt thay23; hàng ngày vẫn T2–CN, tick/selected/today phân biệt. Gộp thời lượng/nơi tập/thể trạng thành3capsule; ba trạng thái khỏe/mệt/đau và undo nằm trong menu, rút gọn buổi chuyển vào menu thời lượng. Giữ bộ điều chỉnh/checkin đã có từ công việc khác, không đổi thuật toán. Checkin pain/time sheets nền đặc, thêm large detent. Lime/SF giữ nguyên.

Bản cũ main8đã bắt đầu đã được người dùng đổi trong lúc thao tác sang7chưa bắt đầu, checkinKhỏe,0set/2history (quan sát trước bảncompact). Không tự khôi phục snapshot8/7cũ. Baseline mới pre-compact-home-state.json chỉ để đối chiếu read-only; không ghi ngược vào app. Các lượt QA tạo bundle riêng, không log/finish main. Bằng chứng UI cuối và hash trong handoff-manifest.json;140trạng thái original vẫn partial, Figmaoriginal140/28 không thay. 109modelchecks là lần trước, không rerun vì không đổi model trong lượt này.

Đọc current-test-state.json và preservation-baseline-note.json để biết checkpoint mới nhất; không dùng các mô tả7/8draft lịch sử để restore app.

Đọc AGENTS.md → CHANGELOG.md → SCREEN-COVERAGE.md → OPEN-GAPS.md trước khi sửa. Tài liệu này thay thế các trạng thái cũ mâu thuẫn; bản cũ giữ tại archive/HANDOFF-before-home-media-2026-11-10.md. Không dựa vào chat hoặc connector session của tài khoản trước.

### Kiểm chứng cuối23:05
- User23:02 phản hồi chữ nhỏ: final count20pt, mô tả/date14pt trắng85/80%, weekday12pt/today10pt; thay bản count18/label12 ở C165. C171 là lịch cuối, không quay về cỡ nhỏ để giảm chiều cao.
- C165Homecompact, C166thểtrạng/undo, C167menu thời lượng; rútgọn mở rồiClose khôngapply. C168Rowguide fullwidth; C169FinishSheet0set disabled/HealthOff, Tiếp tục trở vềActive; C170Incline setentry fullwidth giữ người/ghế. Source0setlimit unchanged. Không chứng nhận nativeHD/FPS/DynamicType/mọi biến thể.
- compact-media-qa-run.json: start chỉ QA bundle riêng,0set/0history; đã terminate/uninstall. Main7chưa bắt đầu/checkinKhỏe/0set/2history giữ, kiểm bằng read-only baseline. Build và33pin asset gates đạt;109modelchecks là chứng cứ cũ, không chạy lại.

### Chốt kiểm thử23:07 — thay trạng thái109 ở trên
Đã chạy lại scripts/check-models.sh vì phần DailyCheckin từ công việc song song vừa được nối vào UI: **121/121 model checks đạt**, gồm mệt/đau/rútgọn/hoàn tác/persistence/khóa khi đã bắt đầu/deload sau nghỉ lâu. Các test dùng storage tạm, không sửa main. Đây là model evidence; không coi mọi nhánhpain/time/deload đã UI kiểm. Read-only main so baseline: draft/history nguyên, checkin vẫnKhỏe nhưng timestampdate đổi do thao tác song song của người dùng; không ghi ngược snapshot. CompactQA đã gỡ; main đang Home.

## Phạm vi và ràng buộc đã chốt

- Người dùng muốn phục vụ cả người mới và người tập gym đều.
- Đã chuyển sang tiếp phần Claude “Audit phần thêm bài tập”. Chỉ đọc Claude desktop, không gửi tin. Task chỉnh mesh/animation Form đang tạm dừng; giữ source và bundle.
- Giữ primary Dopafit lime RGB(0.71,0.96,0.24), font SF, weight và case. Ladder193 ảnh tham khảo nền trung tính, card, viền/góc; user mới cho phép học thêm UI hữu ích với chức năng Dopafit giữ nguyên. Yellow/expanded font/uppercase tự động đã bị bác bỏ.
- Người dùng duyệt thiết kế picker mới, calendar, gợi ý nhóm cơ, thử thách, ảnh người thật, motion thumbnails và audit/sắp xếp lại Home. Không hoàn nguyên các ngoại lệ này về ảnh original.

## Cập nhật 22:30 — ẩn thumbnail nếu thiếu video

User yêu cầu không hiện hình thay thế khi bài không có video. ExerciseDBMedia.hasMotionThumbnail kiểm MP4 trong bundle. Cả3caller Home/active ExerciseRow, ExercisePicker và WorkoutProgramDetail bỏ slot ảnh nếufalse; ExerciseMotionThumbnail chỉ phát clip, không fallback MuscleGlyph/GIF. Hàng khôngảnh có thêm không gian cho tên, Home minheight64 thay86; hàng cóvideo giữ.

Không xóa exercise hay dữ liệu. Picker cần nútinfo44pt cho bài không thumbnail để vẫn mở hướng dẫn; names/selection/menu/prescriptions giữ. Suggestions/filter/Body muscle glyph có ý nghĩa thật nên không bị đụng; guide/renderers không thay. Đây là quy tắc mới ưu tiên hơn các mô tả staticthumbnailfallback bên dưới. Thiếu clip vẫn là gapG02, không được gọi fixedmedia.

Kiểm chứng: Debug build/install/launch + assetgates đạt. C158 presetMông: glute bridge không ảnh, hai bài cóvideo giữ. C159 pickerT-Bar: khôngảnh/play, text/chọn/info44pt giữ; info mở guide rồiClose, pickerClose khôngchọn. Sourceguard Home/active compile; không tạo bàiunmapped trongdraftmain để chụp. Snapshot pre-thumbnail-hide-state.json so nguyên draft/history sau UI: không đổi. Các phần DailyCheckin có sẵn do công việc khác giữ nguyên, không được coi là thay đổi trong lượt này.

## Cập nhật 21:50 — lịch tuần mới bằng tiếng Việt

User gửi mẫu DayStreak và yêu cầu lịch người Việt. Đã đổi bố cục: mục tiêu tuần lớn + date ở header, dải ngày inset trung tính, T2–CN/có số ngày. Giữ primary xanh/SF/nền tối. Ngày đã tập filllime+tick; ngày chọn viềnlime hoặcwhite nếudone; hômnay có nhãn. Không tính streak mới, không thêm checkin/Health. Previous/next vàheaderVềhômnay44pt; chọnngàyxemhistory giữ. Calendar AX/dateLabel và SessionCard ngày cũ Việt hoá. Các mô tả lịch cũ limefill=selected hoặc chấm3pt bên dưới đã supersede.

C153 calendarHome, C1549/11haihistory/1trainingday, C155nextweek0/3empty→headerreset; C156historydatesVI/C157Homefinal. Build/assetgates đạt, updater giữ7draft/0set/0group/2history.109modelchecks không rerun vì không sửa model; còn nhỏmàn/DynamicType/VoiceOver. Figmaoriginal140/28 không thay.

## Cập nhật 21:42 — core14 mới

Asset challenge-core-14 đã đổi theo user từ Peggy_Marco1634786 sang ảnh người thật side plank của Li Sun/Pexels2294363, gym xám tối, không đổi màu/AI. JPEG tải1600px giữ nguyên, source/license/hash tại manifest; bản cũ archive21:42. C144/C143 core14 cũ không dùng làm chuẩn. Core30 vẫn cottonbro4754028, Plank video ShotPot4117854 giữ. Không đổi UI/chức năng/dữ liệu; build/UI evidence mới nằm handoff-manifest.

Đã build/install và kiểm trên simulator: C151 detail, C152 thẻ Home; thấy đủ tư thế, không thêm/join/log. Asset gate và read-only data/hash updater đạt; main7draft/0set/2history giữ.

## Cập nhật 21:35 — ảnh core30 mới, ưu tiên hơn checkpoint bên dưới

User yêu cầu thay ảnh “Bụng khỏe30ngày”. Asset challenge-core-30 hiện là khung hình giây3 của video người thật cottonbro studio/Pexels4754028, gym tối, người đang gập bụng, áo xám/quần đen. Nguồn4K trích JPEG1600×844, **không đổi màu hoặc AI**; metadata sourceBytesUnmodified=false vì trích/downsample frame, không phải file JPEG nguồn trực tiếp. Video nguồn/hash/cách trích nằm manifest; ảnh ShotPot4047104 cũ archive ngoài app. Các mô tả tất cả13ảnh giữ nguyên bytes và core30ShotPot bên dưới là lịch sử đã supersede cho riêng asset này. Shared program Bụng dùng cùng asset, nên ảnh hero cũng đổi. Không thay Plank video. Xem ảnh UI mới trong handoff-manifest.

Kiểm chứng: build/install/launch và asset gates đạt; C149 trang chi tiết, C150 thẻ Home thấy rõ động tác/caption. Dữ liệu main 7 bài/0 set/2 history giữ nguyên qua read-only updater. Chỉ thay ảnh, không chạy lại model tests cho lượt này.

## Checkpoint mới nhất — sau phản hồi 20:21, 10/11/2026

**Không đổi màu ảnh:** user bác bỏ cách giảm saturation. Đã bỏ toàn bộ bộ lọc trong DiscoveryPhoto và thay sáu nguồn ảnh fullbody-28, pelvic-14, core-14, activity-30, core-30, mobility-28 bằng ảnh người thật, màu tự nhiên, nền gym/đen trung tính. Không AI, tint hoặc chỉnh màu. Ba ảnh đầu được duyệt (Gard Pro/Samuel Girven/Scott Webb leg press) giữ đúng file/hash. Tổng 13 ảnh có nguồn, tác giả, license và hash tại third_party/challenge-photos/manifest.json. Ảnh cũ giữ ở previous/2026-11-10-2021-colorful-rejected. Fullbody dùng ảnh ngang Tima 6389079 sau khi ảnh dọc 6389080 bị cắt bàn tay; C140 là bản dọc đã loại, không phải ảnh cuối. C122–C127 là thử nghiệm giảm màu bị user bác bỏ, không dùng làm chuẩn.

**Plank đã có video thật:** ShotPot/Pexels 4117854, giữ Plank trên cẳng tay không thêm tạ. Nguồn 2160×3840/25fps, cùng đoạn 4 giây được crop/downsample thành guide 1080×1080 và thumbnail 320×320. Không AI hoặc nội suy chuyển động. C136/C137 thấy video phát; C138 thấy đủ ba hàng. Đây là người thật, khác kiểu anatomy ở các bài bên trên; không gọi là animation anatomy. Provenance/hash/encode tại third_party/stock-motion/manifest.json. Không map weighted plank hoặc up-down plank sang bài này.

12 thử thách và 21 preset (7 nhóm/3 cấp độ) đã có. Thư viện cũ vẫn 32 bài; 9 definition preset riêng. ExerciseDB vẫn 26 pin thư viện + 6 pin preset = 32 pin nguồn 180px; guide 720 là upscale. Video Plank là nguồn riêng, không tăng số pin ExerciseDB. Hai preset còn thiếu exact motion: bodyweight squat và glute bridge. Form/model vẫn PAUSED. Manual practice lưu riêng challengePractices; timed set dùng giây, không reps/volume/1RM giả; countdown exercise vẫn chưa có.

**UI hiện tại:** primary lime RGB(.71,.96,.24), SF/weight/case giữ. Neutral theo style/COLOR-SYSTEM.md. Group selector nhãn + underline; sticky Add 108×52 capsule trung tính có nhãn, Start/Resume nền lime; root active trắng + gạch lime nhỏ. C120/C121 kiểm đổi nhóm và Add → picker → Close. Không khôi phục mô tả Add 52pt circle/active pill ở các checkpoint cũ.

**Kiểm thử:** 109 model checks đạt; Debug build/install/launch và asset gates đạt. Bundle QA riêng com.local.dopafit.discoveryqa đã kiểm Replace 7→3, thời lượng 13 phút, 0 giây không ghi được, nhập/log 30 giây, finish Health Off/volume 0, sửa history thành 40 giây, Add 7+3→10 giữ nguyên 7 bài cũ, relaunch giữ draft/history (C128–C134). Snapshot và cleanup trong verification/discovery-qa-run.json; bundle QA đã gỡ, chỉ main còn lại. CSV được model-test, chưa UI export. Không coi một preset là đã kiểm đủ cả 21.

**Dữ liệu main:** 7 draft beginner upper, 0 set hoàn tất, 0 nhóm, 2 history; prescription/order/history được so baseline read-only. Kegel test đã undo checkin rồi leave; có 2 left records, challengePractices rỗng. Không sửa JSON để xóa dấu vết test, không ghi Health. Original/Figma vẫn 140 trạng thái/28 nhóm; rollback R82 resolved. Không upload ảnh rebuild/stock vào board original. Mọi parity row vẫn partial; còn lifecycle, màn nhỏ, Dynamic Type/VoiceOver, mọi nhánh và HD cho các bài khác.


## Cập nhật15:57 — ưu tiên hơn ảnh squat15:35

lower28 hiện dùng Scott Webb leg press (Pexels28076, published2016; Pixabay2015 NikonD300), góc chéo khác upper. Không AI generation/editing. C105detail/C106card verified; detail270pt, offset0. Manifest là nguồn hiện tại; squat rejected archive outsideapp. User mới yêu cầu bổ sung challenge types + muscle programs3levels từ ảnh HomeWorkout; vẫn dark Ladder neutral/lime gốc/SF.

## Cập nhật15:35 — ưu tiên hơn hướng ảnh sáng trước đó

User15:23 chọn ảnh gym tối. Giữ đúng Samuel Girven Pv97-3sdjdY ở giữa; Gard Pro push-up và Tima Miroshnichenko squat là hai ảnh mới. Manifest3ảnh là nguồn hiện tại. Bright experiment bị bác bỏ đã archive ngoài app, không khôi phục. C92/C95/C96/C104 là bằng chứng ảnh mới; C88 là hướng sáng cũ. Detail squat320pt, caption riêng và carousel snap giữ.

Add52ptCircle cạnh Start52ptCapsule, metadata capsules. Root và Body selected dùng lime gốc trên nền neutral raised, không olive. Body segmented header44ptfixed, recovery metrics chung card, copyước tính/nhóm cơ draft thật. Strength10parallelogram theo ảnh user, empty1RM “— kg” không giả0rep/chart. Các route/công thức/dữ liệu giữ.

C97Results, C98front/C103rear lighting-camera-only, C100list/C101muscle detail/C102editor disabledSave; help mở/đóng và editor Cancel đã kiểm. Nút Add tròn mở picker32bài rồi Close đã kiểm. Không Save slider/Health/join/log. Anatomy/mask vẫn partial, Form mesh/motion paused; không lấy screenshot lighting làm pass anatomy. C90 trước sửa đèn. Build/install/hash gates đạt;87modelchecks là kết quả checkpoint trước, không rerun trong passUI này. Manifest updater read-only xác nhận history/prescription.

## Home sau audit14:48

Thứ tự: Kế hoạch của tôi → lịch tuần → tên buổi/metadata → bài hôm nay → buổi đã lưu nếu có → gợi ý nhóm cơ → thử thách. Một nút Add có icon và nhãn cố định cạnh Start; đã bỏ Add trùng ở header và cuối list. Header/control căn hàng; menu bài44pt có nhãn theo bài. Avatar trắng giả được thay bằng icon thiết lập kế hoạch.

Số nhóm cơ là unique primary muscles từ draft, không hardcode5/6. Buổi hiện có7 bài và5 nhóm cơ. Tên tiếng Anh phản ánh actual draft; Resume xét hasStarted hoặc completed sets. Không thay dữ liệu để khớp nhãn.

Calendar bắt đầu thứ Hai theo ngày địa phương; weekly goal đếm unique ngày có completed sets. “Tuần này1/3 ngày tập” có đơn vị rõ. Ngày đang chọn có nền lime, hôm nay chưa chọn có viền, ngày đã tập có chấm3pt. Previous/next ở header; chạm nhãn ngày về hôm nay. Ngày cũ mở history, tương lai empty; không sinh buổi giả khi xem ngày khác.

Suggestions dùng recovery/gear/exclusion LOCAL; vào picker lọc sẵn nhóm cơ. Đặt sau buổi hôm nay, copy “Khám phá thêm bài theo nhóm cơ”. Không gọi đây là recommendation engine gốc.

Ba challenge cục bộ14/28 ngày: join/leave/persist, tiến độ tính unique ngày có bài phù hợp sau join và trước hạn; không thay draft/history. Ảnh thật thể hiện push-up, shoulder press và squat; caption bên dưới, carousel snap. Nguồn/tác giả/license/hash tại third_party/challenge-photos/manifest.json; ảnh minh họa, không phải coach/endorsement.

## Picker và media

Picker mới giữ tìm không dấu/token AND, combined filters, recent từ history, multi-select qua filter/detail. Thumbnail mở guide; vùng tên chọn bài. Row64pt media,16pt gap,17pt padding dọc; vòng chọn22pt nét1.25. Difficulty/gear trong filter sheet. Đã sửa stale row identity và selected accessibility trait. Sticky Add vẫn có trong Active.

Catalog32 bài;26 mapping ExerciseDB chính xác. Giữ26 GIF nguồn,26 MP4 nhỏ cho list và26 guide-only MP4 nội suy720px. Sáu variant chưa có ExerciseDB pin: tbar, shrug(trapbar), facepull, reversefly, bandface, dumbbell-shoulder-press. Shoulder guide có Form fallback. Không map sang biến thể sai để lấp chỗ thiếu.

**Blur audit:** nguồn180×180; Row12 frames/3 giây=4 pose/giây. CFR30 chỉ lặp pose. Guide ưu tiên9 renderer Form/OpenGym khớp đúng động tác đã có, không sửa mesh/motion. Clip2D còn lại giới hạn220pt trong media≤300pt. Guide-only Lanczos4x/unsharp0.35 làm viền rõ hơn nhẹ, tổng3.3MB; không phải nativeHD, không khôi phục chi tiết hay true30 pose/giây. List vẫn dùng MP4 nhỏ. Xem EXERCISE-MEDIA.md, media-blur-audit.json và guide-upscale-qa.json.

AVPlayerLooper muted/aspectFit; dừng theo scene/tab/disappear, Reduce Motion dừng thumbnail trang trí. Chưa có benchmark FPS/CPU trước–sau hoặc full Reduce Motion UI test.

OSS OpenAPI chính thức cho non-commercial/prototype, yêu cầu credit AscendAPI, commercial cần paid plan. Credit nằm trong Settings → Về Dopafit. Không tự mua/subscription. Form runtime-code license vẫn chưa rõ. Một HD GitHub mirror bị loại vì tác giả thừa nhận không rõ quyền footage; không nhập nguồn đó.

## Kiểm chứng và dữ liệu

-87 model checks đạt: filter, old-state compatibility, calendar, challenge join/duplicate/expiry/muscle matching/unique day/leave preservation và các checks cũ.
- Debug build/install/launch đạt trên iPhone18ProMax/iOS27.3. OpenGym, Form và ExerciseMedia gates đạt.95 resource files và Assets.car trong app cài khớp source/build.
- C71/C72: picker thin tick/filter. C73/C74: history/future empty trước compact. C77: photo detail. C78:7 motion rows. C79–C82: các bước sửa calendar/photo/header trước reorder.
- C83: guide capped + spatial upscale. C84: Home ưu tiên bài hôm nay, đúng5 nhóm cơ và một Add. C85: guide0.5×. C86: calendar mở2 history rồi về hôm nay. C87: discovery và caption cuộn tới đầy đủ. C88: squat rõ động tác. Screenshot không chứng minh pixel parity hoặc full lifecycle.
- Add → picker32 bài → Close đã kiểm sau reorder, không ghi thêm bài. Không Start/log/finish để test layout.
- Cuối lượt:7 bài beginner upper,0 completed sets,0 group,2 history. History và thứ tự/prescription giống baseline trước picker test. UUID/start draft đã khác snapshot cũ; không tự restore UUID cũ. Luôn inspect sandbox thật trước mutation.
- Picker test trước đó thêm2 rồi xóa đúng2 UUID qua UI đã trả7 bài tại checkpoint. Challenge test consistent14 id1FC29B17-16D4-4F1B-84A7-C0846FEA147E đã leave qua UI sau nhánh Cancel; giữ record left, không ghi buổi giả.

## Original và Figma

140 original states=58D+82R;140 cards/images/unique IDs,28 root groups. R77–R82 root56:944. Inventory và node map trong figma/published-verification.json, verification-140.json, coverage-node-map.json. Không có ảnh original mới trong lượt Home/media. Không upload C/stock/rebuild vào board original. Tất cả140 parity rows vẫn partial; số ảnh không phải số màn đã hoàn tất.

Original temporary superset đã tháo và restore tạiR82: Row → Hammer → Shoulder → Cablefly → LyingTriceps → EZcurl → Shrug. Không log set/finish/discard. Không còn rollback nhóm pending. pending-R77-observation.json giữ lịch sử resolved.

## Chạy và tiếp tục

```sh
./scripts/check-models.sh
./scripts/run-simulator.sh
python3 scripts/generate_project.py  # khi thêm Swift
python3 scripts/build_screen_coverage.py
python3 scripts/update-handoff-evidence.py
```

Xcode /Users/vunguyen/Desktop/Xcode-beta.app; UDID54B67C9B-28C9-4698-98A3-968BA4AB75B6; bundle com.local.dopafit.rebuild. Override bằng DOPAFIT_XCODE/DOPAFIT_SIMULATOR. Không erase simulator/reset state. Tìm sandbox mới bằng simctl get_app_container; state ở Library/Application Support/DopafitRebuild/state.json. Manifest updater chỉ đọc state, so history/prescription với checkpoint và kiểm installed hashes; nếu assert thì inspect thay đổi, không sửa dữ liệu để ép pass.

CUA dùng Device Hub (có thể AppTranslocation), original com.apple.ScreenContinuity. Re-observe sau mỗi action. AX scroll vào element hoạt động tốt hơn drag tọa độ. Nếu Mac khóa thì không bypass/đổi security. Figma cần session mới và kiểm quyền/inventory trước write; read-only connector cũ không đại diện mọi tài khoản.

## Còn mở

Đọc OPEN-GAPS G01–G12 và HOME-UX-AUDIT-2026-11-10.md. Chưa pixel parity, Dynamic Type/màn nhỏ/long gym name, VoiceOver toàn luồng, date-header hit target44pt, full English, Reduce Motion/lifecycle/failure và performance benchmark. Switch/refresh/template trên buổi đang ghi cần audit destructive guards. Auth/subscription/Health/Watch/cloud chưa tích hợp thật; progression/recovery là local. Circuit/timed và nhiều nhánh original chưa kiểm đủ.

Form8 motions chỉ RDL GPU có C60–C64;264 CPU poses/64 upstream tests không chứng minh8 clip GPU hoặc anatomy không lỗi. Không tiếp Form khi chưa có steering. Research Fitbod/US/painpoints ở research/2026-11-09/REPORT.md; không làm lại nếu chưa có lý do.

Bằng chứng ảnh nguồn cuối: C141 toàn thân ngang; C142 vận động; C143 hai ảnh core; C144 core14 thấy tư thế; C145 Kegel/giãn cơ; C146 giãn cơ chi tiết. C147 Home phân cấp Add/Start/tab. Tất cả là ảnh rebuild cục bộ, không thêm vào bảng Figma original.
