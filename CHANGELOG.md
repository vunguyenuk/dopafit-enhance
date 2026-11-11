# Changelog Dopafit rebuild

## 2026-11-11 08:46 (Claude) — Lịch tuần gọn 1 dòng; thống nhất kiểu chữ/khung giữa các tab

- **Lịch tuần (thay mục 08:40):** user muốn mọi tuần gọn như tuần này. Bỏ dòng khoảng ngày và nút “Hôm nay”; tuần cũ “n/3 ngày tập”, tuần tương lai “Tuần tới/Sau N tuần”, chỉ 1 dòng + 2 mũi tên. Bấm dòng tiêu đề để về hôm nay (id calendar.today, VoiceOver đọc khoảng ngày + gợi ý “Về hôm nay”). Đã thấy trên simulator.
- **Tiêu đề mục thống nhất:** thêm `.dopaSection()` (22 đậm) thay 6 cỡ cũ (20/22/23/25/26): Cơ thể (Sức mạnh tổng, Bài đo sức mạnh, Thành phần cơ thể, Hồi phục), Mục tiêu (Lịch sử), Nhật ký (Lịch tập, Các buổi đã tập, Buổi tập đã ghi, Sức mạnh cơ bắp, Khối lượng theo nhóm cơ), Buổi tập (Nhóm cơ gợi ý, Thử thách, Tập theo nhóm cơ, Buổi tập đã lưu, Buổi tập trong ngày). Tiêu đề chính màn (tên buổi 29, Mục tiêu set tuần 29) và onboarding/paywall giữ nguyên.
- **Bo góc:** thẻ nền Dopa.card bo 12 → 14 (13 chỗ) và `Dopa.radius` 12 → 14 (GroupCard) cho cùng một kiểu.
- **Nút chọn trên Home:** pill “Phòng gym” 15 → 14 cho bằng “45 phút”/“Thể trạng”.
- **Ngày đã tập ở lịch Nhật ký:** nền đỏ sẫm → lime chữ đen, giống lịch tuần ở Buổi tập.
- Nút bánh răng Nhật ký có nhãn đọc “Cài đặt” (trước VoiceOver đọc “Gear Shape”).
Build/Run đạt; đã xem Buổi tập, Nhật ký, Cơ thể trên simulator. Chưa sửa: nút X ở vài thẻ VoiceOver còn đọc “Close”; đầu 4 tab vẫn khác nhau theo thiết kế gốc (link Kế hoạch / tab Kết quả–Hồi phục / thẻ mẹo / tiêu đề Nhật ký giữa). Backup: .build/claude-textsize/.

## 2026-11-11 08:40 (Claude) — Đầu lịch tuần khi xem tuần khác

Theo ảnh user: sang tuần khác vẫn “0/3 ngày tập trong tuần” + một ngày lẻ + mũi tên ↩ nhỏ. WorkoutWeekCalendar nay: tuần này giữ “n/3 ngày tập tuần này” (không dòng ngày); tuần cũ “n/3 ngày tập” + khoảng ngày “2 – 8 tháng 11”; tuần tương lai “Tuần tới”/“Sau N tuần” (không đếm 0/3) + khoảng ngày; tuần khác có nút lime “Hôm nay” (44pt, giữ id calendar.today) thay ↩. Đã kiểm trên simulator: tuần tới 16–22/11, tuần 2–8/11 0/3, bấm Hôm nay về 1/3 tuần này. Backup: .build/claude-textsize/WorkoutDiscoveryViews.swift.cal.

## 2026-11-11 08:25 (Claude) — Bỏ nút Thêm bài tập trùng ở màn đang tập

Theo ảnh user: ActiveWorkoutView có 3 nút cùng mở picker (dấu + trên thanh trên cùng, nút “+ Thêm bài tập” đầu danh sách, nút to cuối danh sách). Giữ đúng nút đầu danh sách (cái user khoanh), chuyển accessibilityIdentifier "active.add" sang nút này để tự động hóa cũ vẫn tìm được. Thanh trên còn ⋯. Build/Run đạt; chưa mở màn đang tập trên simulator vì phải bấm Bắt đầu trên buổi chính.

## 2026-11-11 08:22 (Claude) — Ảnh riêng cho Mông; cỡ chữ toàn app

- **Ảnh Mông:** Chân và Mông cùng dùng challenge-lower-28. Thêm asset `program-glutes` = Pexels 31028213 (TMA Management, Pexels License; máy hip thrust, gym tối, màu gốc, bytes nguồn không sửa), nguồn ở third_party/challenge-photos/sources, entry trong manifest.json. Chân giữ ảnh leg press. Đã thấy cả hai tab trên simulator. Ảnh xem trước cũ chuyển vào third_party/challenge-photos/_to_delete (không xóa được).
- **Cỡ chữ (người lớn tuổi):** thay toàn bộ 317 `.system(size:)` bằng `Font.dopa(size:)` = cỡ gốc × `DopaText.scale` (Vừa 1 / Lớn 1,15 / Rất lớn 1,3). Kế hoạch → Tùy chọn → “Cỡ chữ”; RootView đặt scale và dựng lại tab khi đổi. PlanSettings.textSize Optional. Bản Vừa giống hệt trước (×1). Build/Run đạt; thấy dòng Cỡ chữ trên simulator nhưng CHƯA chọn được Lớn/Rất lớn (click nền trong sheet bị đóng sheet) — cần user thử; ở 1,3 có thể vài nút cố định chiều rộng (VD “Thêm bài” 108pt) bị chật. Backup trước khi thay: .build/claude-textsize/.
- Còn chưa làm (cần dịch vụ thật): đăng nhập, mua gói, ghi Apple Health.

## 2026-11-11 08:10 (Claude) — Ẩn bài chưa có video đúng động tác

Theo user (“không có video thì ẩn đi”, “sửa luôn”). 5 bài không có clip đúng biến thể ở cả ExerciseDB lẫn Zenith (đã dò lại 317 bài): facepull, shrug (trap bar), reversefly (cáp 1 tay), bandface, discovery-glutebridge. Nay ẩn khỏi: thư viện/picker (`AppStore.exercises`), chương trình tập theo nhóm cơ (`WorkoutProgram.exercises`), nhóm cơ gợi ý (WorkoutDiscoveryModels). Buổi tự tạo và bài thay thế đã lọc video từ trước. Lịch sử, draft hiện có và bài đã lưu KHÔNG bị xóa. Test giữ hasVideo=true nên không đổi model checks.
Kiểm trên simulator: picker 28 bài (trước 32), nhóm Vai 7 bài đều có video; đóng picker không thêm bài. Chương trình Vai & lưng còn 2 bài, Mông còn 2 bài. Backup: .build/claude-sheet-fix/.

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

## 2026-11-11 01:05 (Claude) — Ở nhà, video người tập nữ, chế độ nhẹ nhàng

- **Ở nhà:** GymSelector có “Thêm nơi tập Ở nhà” (tạ đơn 2,5–20 kg, dây kháng lực, không dụng cụ, ghế) và làm lại buổi hôm nay. makeDraft nay THAY bài thiếu dụng cụ bằng bài cùng cơ chính dùng được (trước đây chỉ loại bỏ → buổi ở nhà gần như trống). Có thể làm đổi kết quả model check cũ về số bài khi phòng thiếu dụng cụ.
- **Video nữ:** RootView đặt `ExerciseDBMedia.preferFemale` theo plan.gender == "Nữ"; zenithURL ưu tiên `<id>-f-thumb/guide.mp4`. `scripts/fetch-zenith-female.sh` (22 bài có bản nữ; crunch đã là nữ; close-grip bench không có) — CHỜ user chạy trên Mac, rồi chạy lại `python3 scripts/build-zenith-media.py` để tạo clip `-f-`. Chưa có file nữ thì vẫn dùng clip nam.
- **Chế độ nhẹ nhàng** (Kế hoạch → bật/tắt, làm lại buổi hôm nay nếu chưa bắt đầu): tối đa 5 bài, 2 set/bài, nghỉ ≥120 giây, không dùng tạ đòn/trap bar/T-bar (thay bằng máy/tạ đơn cùng cơ). PlanSettings.gentle Optional. +1 model check.
- Chưa làm: chữ to theo cài đặt hệ thống (app dùng cỡ chữ cố định khắp nơi — việc lớn), đăng nhập/mua gói/ghi Apple Health (cần dịch vụ thật).
- Build/Run Xcode đạt. Chưa kiểm UI các phần này (màn Mac khóa). Chưa chạy check-models.

## 2026-11-11 00:58 (Claude) — 24 video demo mới + 5 việc từ audit tình huống người tập

**Video (CHƯA CÓ LICENSE — chỉ demo, user cam kết mua license trước khi phát hành):** nguồn buzops9/exercisedb (free-exercise-db-with-videos, commit 399a8af). Code/metadata MIT, nhưng README tự ghi video mua lại qua quảng cáo, không rõ nguồn gốc. User tải bằng `scripts/fetch-zenith-videos.sh` (25 file 1080p ở third_party/zenith-video/raw, không bundle). `scripts/build-zenith-media.py` cắt vuông theo hộp bao người (8 khung, nền trắng), ra `ExerciseMedia/zenith/<id>-thumb.mp4` 240px và `<id>-guide.mp4` 720px (H.264, không tiếng, 5,5 MB) + `zenith-manifest.json` (nguồn, hash, bbox, ghi chú license). Bỏ glute bridge (clip là hip raise từ plank). `ExerciseDBMedia.videoURL/guideVideoURL`: plank thật → zenith → ExerciseDB 180px. 24 bài có clip mới; dumbbell-row, smith-bench, dumbbell-back-fly, facepull… vẫn dùng clip cũ hoặc chưa có.

**Audit:** artifact “Dopafit tình huống người tập” (22 tình huống: 11 có, 6 một phần, 5 chưa). Đã làm 5 việc đề xuất:
1. Lịch Nhật ký bắt đầu thứ Hai (ProgressViews.calendarWeek). Đã thấy trên simulator.
2. ⋯ trên mỗi bài có “Máy đang có người” → đổi ngay sang bài cùng cơ chính, ưu tiên dụng cụ khác, có video, giữ số set/nghỉ (`busySwapCandidate/busySwap`). Đã thấy nút + gợi ý trên simulator, không bấm để giữ draft.
3. Lỡ buổi: `missedPlannedDay()` dựa plan.trainingDays (3 ngày gần nhất, chưa tập từ đó), thẻ HomeMissedCard “Tập đủ / Rút gọn 20 phút”, ẩn theo ngày qua dismissedTips. Chưa thấy trên UI (không có ngày lỡ trong dữ liệu hiện tại).
4. Quay lại sau nghỉ: AppSnapshot.returnStart; tuần 1 ≥75%, tuần 2 ≥85% mức trước nghỉ, không vượt mức cũ, tuần 3 bình thường (`CheckinLogic.ramped`, WorkoutSession.returnWeek, dòng lý do). +1 model check.
5. Người mới: thẻ “Chuẩn bị trước khi tập” (15 bài máy/cáp/ghế) + “Lỗi hay gặp” (24 bài, dịch từ metadata MIT) trong tab Cách tập (`ExerciseSetupTips.swift`); Home 3 buổi đầu: “Buổi n/3 làm quen…”; Cơ thể: “Đã ghi n/3 buổi” và Bài đo sức mạnh lấy mọi bài đã ghi set (trước chỉ squat/deadlift/bench, 2 id sau không tồn tại → luôn trống). Đã thấy Cơ thể trên simulator: Kéo lưng 42 kg, Đẩy ngực dốc 51 kg.
Chưa chạy `./scripts/check-models.sh`; chưa thấy thẻ tips trong guide (màn Mac khóa giữa chừng). Backup trước lượt: .build/claude-sheet-fix/.

## 2026-11-11 00:10 (Claude) — Ẩn bài không có video khỏi buổi tự tạo; check-in hết hạn qua ngày

- Theo user 00:05: bài không có video thì không hiện. makeDraft (Models.swift) thay bài không video bằng bài cùng cơ chính có video (đúng dụng cụ, không bị loại), không có thì bỏ. Đổi buổi “Toàn thân” cũng chỉ lấy bài có video. Bài thay khi Đang đau đã chỉ lấy bài có video (lượt trước). Bài user tự thêm từ thư viện KHÔNG bị ẩn. Draft hiện có không tự sinh lại; muốn áp luật mới cho draft cũ: ⋯ → Làm mới buổi tập.
- Bug qua nửa đêm: check-in hôm qua bị ẩn nhưng draft vẫn ở bản đã giảm tạ. Thêm `expireCheckinIfNeeded()` (gọi khi Home xuất hiện): buổi chưa bắt đầu thì trả về bản gốc rồi xóa check-in. Đã thấy trên simulator: 2 set·25 kg → 3 set·30 kg. +1 model check.
- Test giữ hasVideo=true nên luật video không ảnh hưởng model checks. Chưa chạy check-models.

## 2026-11-11 00:05 (Claude) — Bài thay phải có video; tab “Tập theo nhóm cơ” bấm được

- Đang đau: bài thay thế chỉ chọn bài có video hướng dẫn (`CheckinLogic.hasVideo`, gắn `ExerciseDBMedia.hasMotionThumbnail` trong DopafitApp.init; test giữ mặc định true). Không có bài thay có video thì bỏ bài như cũ.
- Cổ: chỉ giảm tạ bài có cơ chính là Vai (trước đây bài ngực có Vai phụ cũng bị giảm “cho cổ”).
- Tab Cẳng tay/Ngực/Chân/Mông trong “Tập theo nhóm cơ” không bấm được: ảnh DiscoveryPhoto scaledToFill tràn ra ngoài khung (chỉ bị cắt hình, không cắt vùng chạm) và đè lên hàng tab. Nay ảnh allowsHitTesting(false) + khung clipped/contentShape. Áp cho mọi chỗ dùng DiscoveryPhoto/ChallengePhoto; thẻ vẫn bấm được nhờ nền thẻ.
- Đã thấy trên simulator: Đang đau · Cổ → “Đổi 1 bài, giảm tạ 5 bài…”, hàng đổi màu lime + ghi chú (trước khi thu hẹp luật Cổ). **Chưa kiểm** bấm tab (không cuộn được app từ điều khiển nền) và chưa chạy check-models.

## 2026-11-10 23:55 (Claude) — Sheet hết lộ nền xám; chọn thể trạng thì buổi tập đổi thật

**Sheet:** thêm `View.dopaSheet()` (Design.swift): nền Dopa.background phủ kín + presentationBackground. Áp cho 20 sheet có chiều cao cố định (Thời lượng, Tùy chọn buổi tập, Đổi buổi, Nghỉ giữa set, Superset, Phòng tập, Settings, Progress…), bỏ dải xám hệ thống ở đầu/đáy sheet. Sheet Tùy chọn buổi tập có tiêu đề thay vì khoảng trống. Kiểm UI sheet Tùy chọn: nền liền màu tới đáy.

**Đang đau (theo user 23:44 “set điều kiện thì data phải thay đổi”):** trước đây chỉ đổi bài có trong danh sách khớp viết tay nên buổi 9 bài thường chỉ đổi 0–1 bài. Nay:
- Bổ sung khớp cho dumbbell-back-fly, reversefly, machinefly, facepull, bandface.
- Bài không bị đổi nhưng vẫn dùng vùng đau (theo cơ chính + phụ, VD Vai ↔ Vai/Ngực; Gối ↔ Đùi trước/Mông/Bắp chân) → tạ ×0,8 theo bậc tạ thật, bớt 1 set nếu >2, ghi chú “Nhẹ hơn cho vai”.
- Dòng lý do: “Đổi 2 bài, giảm tạ 3 bài để đỡ cho vai”.
- Hàng bài bị thay đổi (mệt/đau/rút gọn) tô số set·tạ màu lime để thấy ngay.
- DailyCheckin.lightened là Optional để snapshot cũ vẫn đọc được. +2 model checks. **Chưa chạy check-models** và **chưa bấm thử Đang đau trên UI** (menu hệ thống không bấm được bằng điều khiển nền) — cần Codex/user chạy `./scripts/check-models.sh` và thử Đang đau → Vai.
- Khỏe vẫn = buổi đúng kế hoạch (không chỉnh), chỉ khôi phục nếu trước đó đang Mệt/Đau.
Backup: .build/claude-sheet-fix/.

## 2026-11-10 23:40 (Claude) — Gọn màn Buổi tập, bớt chữ

Theo user “hơi nhiều chữ, rối”. Chỉ đổi giao diện/chữ, không đổi logic draft/history:
- Tên buổi bấm được (có ⌄) để đổi buổi; bỏ hàng riêng “Đổi buổi”. Dòng phụ “7 bài · 5 nhóm cơ”.
- Lịch tuần: ẩn dòng ngày “Thứ Ba, 10 tháng 11” khi đang ở hôm nay (ô ngày đã có “Hôm nay”); vẫn hiện khi xem ngày khác.
- “Vì sao buổi này” thành 1 dòng ngắn không khung (VD “Lưng, ngực đã hồi phục · giữ mức tạ”); accessibility vẫn đọc “Vì sao buổi này: …”. Các câu lý do check-in/nghỉ lâu rút ngắn (vẫn chứa “nghỉ N ngày” cho test).
- Bỏ tiêu đề “Bài trong buổi hôm nay”. Thẻ “MỨC TẠ KHỞI ĐẦU” (người chưa có lịch sử) thành 1 dòng.
- Hơi mệt không còn ghi chú lặp trên từng bài (dòng lý do đã nói); ghi chú “Thay cho…” khi đau vẫn giữ.
- Bỏ câu mô tả phụ dưới “Nhóm cơ gợi ý” và “Tập theo nhóm cơ”.
Backup bản trước: .build/claude-home-tidy/. Build/Run Xcode đạt, Home hiện thêm ~1 bài trên màn đầu; bấm tên buổi mở sheet Đổi buổi rồi Đóng, không đổi draft. Chưa chạy lại check-models (logic không đổi, chỉ chuỗi lý do).

## Cập nhật 22:31–23:00 — video, sheet lưu và Home gọn hơn

Theo ảnh/user steering: ExerciseDetail và ExerciseGuide dùng clip ExerciseDB thay model Form/OpenGym ở phần minh hoạ bài. Thêm đúng biến thể standing dumbbell overhead press A6wtbuL: 27/32 bài thư viện +6 preset =33 pin; source response/GIF/hash/QA lưu cục bộ. Không fallback 3D/static hay giả nút phát khi thiếu clip. Body map giữ nguyên; Form mesh vẫn paused. ExerciseThumb chung đã bỏ MuscleGlyph ở Active/selection/saved editor/progress rows, bổ sung chỗ còn sót ở lượt22:30.

User22:47 bác khung220pt quá nhỏ: video ghi set và guide nay full-width square, aspect-fit giữ trọn người/dụng cụ, respect safe area; C161–C164 là kích thước cũ. Nguồn180px,720px chỉ upscale, không nativeHD/không thêm pose. Thiếu exactclip vẫn là gap.

FinishSheet có nền đặc liền khối/bo góc hệ thống, nội dung cuộn và hai CTA cố định, disabled Save trung tính rõ chữ kèm lý do cần ít nhất1set; không đổi luật lưu/Health. Home theo22:51/22:54: bỏ khung lồng trong lịch, paddingvertical8/gap4, mục tiêu18pt thay23; hàng ngày vẫn T2–CN, tick/selected/today phân biệt. Gộp thời lượng/nơi tập/thể trạng thành3capsule; ba trạng thái khỏe/mệt/đau và undo nằm trong menu, rút gọn buổi chuyển vào menu thời lượng. Giữ bộ điều chỉnh/checkin đã có từ công việc khác, không đổi thuật toán. Checkin pain/time sheets nền đặc, thêm large detent. Lime/SF giữ nguyên.

Bản cũ main8đã bắt đầu đã được người dùng đổi trong lúc thao tác sang7chưa bắt đầu, checkinKhỏe,0set/2history (quan sát trước bảncompact). Không tự khôi phục snapshot8/7cũ. Baseline mới pre-compact-home-state.json chỉ để đối chiếu read-only; không ghi ngược vào app. Các lượt QA tạo bundle riêng, không log/finish main. Bằng chứng UI cuối và hash trong handoff-manifest.json;140trạng thái original vẫn partial, Figmaoriginal140/28 không thay. 109modelchecks là lần trước, không rerun vì không đổi model trong lượt này.

Mọi tài khoản Codex tiếp tục project phải đọc AGENTS.md → rebuild/HANDOFF.md → rebuild/SCREEN-COVERAGE.md → rebuild/OPEN-GAPS.md. Lưu thay đổi và bằng chứng ở repo, không chỉ trong chat. Ngày dưới đây là ngày làm việc; không phải release production.

### Kiểm chứng cuối23:05
- User23:02 phản hồi chữ nhỏ: final count20pt, mô tả/date14pt trắng85/80%, weekday12pt/today10pt; thay bản count18/label12 ở C165. C171 là lịch cuối, không quay về cỡ nhỏ để giảm chiều cao.
- C165Homecompact, C166thểtrạng/undo, C167menu thời lượng; rútgọn mở rồiClose khôngapply. C168Rowguide fullwidth; C169FinishSheet0set disabled/HealthOff, Tiếp tục trở vềActive; C170Incline setentry fullwidth giữ người/ghế. Source0setlimit unchanged. Không chứng nhận nativeHD/FPS/DynamicType/mọi biến thể.
- compact-media-qa-run.json: start chỉ QA bundle riêng,0set/0history; đã terminate/uninstall. Main7chưa bắt đầu/checkinKhỏe/0set/2history giữ, kiểm bằng read-only baseline. Build và33pin asset gates đạt;109modelchecks là chứng cứ cũ, không chạy lại.

### Chốt kiểm thử23:07 — thay trạng thái109 ở trên
Đã chạy lại scripts/check-models.sh vì phần DailyCheckin từ công việc song song vừa được nối vào UI: **121/121 model checks đạt**, gồm mệt/đau/rútgọn/hoàn tác/persistence/khóa khi đã bắt đầu/deload sau nghỉ lâu. Các test dùng storage tạm, không sửa main. Đây là model evidence; không coi mọi nhánhpain/time/deload đã UI kiểm. Read-only main so baseline: draft/history nguyên, checkin vẫnKhỏe nhưng timestampdate đổi do thao tác song song của người dùng; không ghi ngược snapshot. CompactQA đã gỡ; main đang Home.

## 2026-11-10 22:30 — Chỉ hiện thumbnail khi có video bài tập

Theo ảnh user, bỏ hình cơ phẳng thay thế trong các hàng bài tập chưa có clip. Thêm hasMotionThumbnail kiểm URL MP4 thực sự trong bundle; ExerciseMotionThumbnail chỉ render clip, bỏ muscle glyph/GIF loading fallback. Home/active row, picker và preset detail đều bỏ toàn bộ slot ảnh khi không có video, không để ô trống hoặc nút play giả. Home row không ảnh gọn64pt tối thiểu, còn hàng video giữ86pt; tên/set/reps/tạ/menu và callback giữ.

Picker giữ chọn bài/tick như cũ. Khi thiếu thumbnail, dùng nút info44pt “Xem hướng dẫn” để route hướng dẫn không bị mất; không giả video. Program detail và Home mở hướng dẫn bằng tên/hàng. Các hình nhóm cơ ở suggestions/filter/Body vẫn giữ đúng vai trò, guide/model hiện có không bị xoá. Không xóa bài tập hay sửa draft/history. Primary/font/media sources giữ.

Build + assetgates và UI verification được ghi trong handoff-manifest. Model/data không đổi; không rerun model checks cho lượt này. Source/media parity vẫn theo OPEN-GAPS; ẩn hình fallback không có nghĩa đã bổ sung clip còn thiếu.

Kiểm chứng: Debug build/install/launch + assetgates đạt. C158 presetMông: glute bridge không ảnh, hai bài cóvideo giữ. C159 pickerT-Bar: khôngảnh/play, text/chọn/info44pt giữ; info mở guide rồiClose, pickerClose khôngchọn. Sourceguard Home/active compile; không tạo bàiunmapped trongdraftmain để chụp. Snapshot pre-thumbnail-hide-state.json so nguyên draft/history sau UI: không đổi. Các phần DailyCheckin có sẵn do công việc khác giữ nguyên, không được coi là thay đổi trong lượt này.

## 2026-11-10 (Claude) — Home: “Hôm nay bạn thế nào?”, dòng “Vì sao buổi này”, tự hạ tạ khi nghỉ lâu

File mới: DopafitRebuild/DailyCheckinModels.swift (logic) và HomeCheckinViews.swift (UI theo token Dopa hiện có). Sửa Models.swift (AppSnapshot.checkin, WorkoutSession.returnBreakDays, deload trong makeDraft), WorkoutViews.swift (chèn thẻ check-in + thẻ lý do trên Home, ExerciseRow nhận note), scripts/check-models.sh (thêm file), tests/ModelChecks.swift (+~12 check).

- Khỏe: giữ buổi gốc. Hơi mệt: tạ ×0,9 làm tròn xuống bậc tạ thật gần nhất (30→27,5 kg), bớt 1 set nếu >2 set. Đang đau: chọn vùng (Cổ/Vai/Khuỷu/Cổ tay/Lưng dưới/Gối), đổi bài dồn lực vào khớp đó sang bài cùng cơ chính không chạm khớp, không có thì bỏ bài; kèm câu an toàn. Ít thời gian: 15/20/30/45 phút → giữ max(2, phút/8) bài.
- Mỗi lần chọn đều khôi phục bản gốc trước; Hoàn tác trả lại nguyên draft. Chỉ sửa khi draft chưa bắt đầu và 0 set.
- Nghỉ ≥14 ngày: draft mới hạ tạ còn ~75% và Home ghi số ngày nghỉ.
- Kiểm trên simulator Pro Max: Hơi mệt 3×12·30 kg → 2 set·27,5 kg kèm ghi chú, Hoàn tác về 3 set·30 kg; đổi bài khi đau Cổ chạy đúng. **Chưa kiểm**: bấm trong sheet Đang đau/Ít thời gian (click nền trên sheet bị dismiss), UI deload. **Chưa chạy ./scripts/check-models.sh** (máy làm việc không có xcrun) — cần Codex chạy.
- Trong lúc test có lỡ bấm Bắt đầu một buổi rỗng; đã “Bỏ buổi tập”, 0 set ghi, history không đổi; draft main hiện không có check-in.

## 2026-11-10 21:50 — Lịch tuần theo mẫu mới, dành cho người Việt

Đổi WorkoutWeekCalendar theo cấu trúc ảnh tham khảo: số ngày tập/mục tiêu ở đầu, dải7ngày tách nền trung tính và vòng tròn trạng thái. Giữ primary Dopafit/SF/nền tối. Dương lịch T2–CN, tuần bắt đầu thứ Hai, số ngày/tháng và nhãn truy cập bằng tiếng Việt; ngày địa phương theo thiết bị. Ngày đã tập tô lime +tick; ngày đang chọn viền lime (viền trắng khi cũng đã tập); Hôm nay có nhãn riêng. Ngày trống vẫn có số ngày, không biến thành nút check-in ghi dữ liệu.

Giữ số liệu **ngày tập/mục tiêu tuần**, không đổi thành Day Streak hoặc thêm flame gợi chuỗi ngày liên tiếp. Đếm unique training days có set ghi, không số buổi. Tuần ngoài hiện tại dùng copy “ngày tập trong tuần”. Header chọn ngày/Về hôm nay nay có hit target44pt; previous/next vẫn44pt. SessionCard khi xem ngày cũ dùng ngày/tháng/năm tiếng Việt thay Nov9 để đồng bộ. Không đổi draft/history/practice/Health hoặc logic tính tuần.

Build/assetgates đạt. UI C153 hiện tại, C154 chọn9/11 thấy2buổi nhưng1ngày tập, C155tuần sau0/3/empty và headerquayvề. C156 kiểm lại historydate đã Việt hoá, C157 Home cuối. Model/calendar logic không đổi;109modelchecks là kết quả trước, không rerun cho UI. Màn nhỏ/DynamicType/VoiceOver toàn luồng vẫn chưa kiểm đủ; không tuyên bố full parity.

## 2026-11-10 21:42 — Thay ảnh Core vững 14 ngày

Theo ảnh user, thay riêng challenge-core-14 từ Peggy_Marco/Pixabay1634786 sang Li Sun/Pexels2294363: người thật tập side plank, toàn tư thế rõ, gym xám tối, màu da tự nhiên. Giữ nguyên bytes JPEG1600px tải từ nguồn, không AI/tint/desaturation; không đổi UI/function/primary/font. Source/license/hash trong manifest, ảnh và entry cũ archive previous/2026-11-10-2142-core14-replaced. Không thay ảnh core30 vừa duyệt hoặc video Plank. C144/C143 core14 là ảnh cũ đã supersede. Build và UI evidence mới xem handoff-manifest. Không rerun model tests cho thay ảnh.

Đã build/install và kiểm trên simulator: C151 detail, C152 thẻ Home; thấy đủ tư thế, không thêm/join/log. Asset gate và read-only data/hash updater đạt; main7draft/0set/2history giữ.

## 2026-11-10 21:35 — Thay ảnh “Bụng khỏe 30 ngày” theo ảnh user

Thay asset challenge-core-30 (ShotPot/Pexels4047104) bằng khung hình ở giây3 từ video thật cottonbro studio/Pexels4754028: người tập gập bụng, gym tối, trang phục xám–đen. Giữ màu tự nhiên, không filter/tint/desaturation/AI. Trích JPEG1600×844 từ footage4096×2160; không phải ảnh sinh. Nguồn/license/video SHA và cách trích trong manifest; nguồn video giữ ở third_party/challenge-photos/sources, ảnh cũ + entry lưu previous/2026-11-10-2135-core30-replaced. Shared asset cũng cập nhật ở chương trình Bụng đang dùng cùng ảnh. Không sửa UI/function/font/primary hoặc dữ liệu tập. Build/asset gate và kiểm UI được ghi ở handoff-manifest; ảnh core30 trong C135/C143 là phiên bản cũ, không dùng làm chuẩn mới.

Kiểm chứng: build/install/launch và asset gates đạt; C149 trang chi tiết, C150 thẻ Home thấy rõ động tác/caption. Dữ liệu main 7 bài/0 set/2 history giữ nguyên qua read-only updater. Chỉ thay ảnh, không chạy lại model tests cho lượt này.

## 2026-11-10 — Sau phản hồi 20:21: thay nguồn ảnh tự nhiên, video Plank và kiểm thử luồng thật

- Bỏ cách giảm saturation đã thử ở checkpoint trước. Thay **sáu ảnh nguồn** bằng người thật, màu tự nhiên, nền gym/đen trung tính; không AI, tint hoặc đổi màu ảnh. Giữ nguyên ba ảnh đã được duyệt. Manifest 13 ảnh lưu nguồn/tác giả/license/hash; ảnh bị bác bỏ được archive. Fullbody dùng ảnh ngang Tima6389079 sau khi audit thấy ảnh dọc cắt bàn tay. C122–C127 giảm màu và C140 ảnh dọc là bằng chứng cũ đã bị thay thế.
- Plank dùng video thật **ShotPot/Pexels4117854**, đúng giữ trên cẳng tay, không thêm tạ. Guide1080×1080 và thumbnail320×320/25fps cùng đoạn4giây, crop/downsample từ nguồn4K; không AI/nội suy động tác. C136/C137 xác nhận video phát, C138 thấy đủ3hàng. Kiểu người thật khác anatomy ở các bài trên. Stock manifest/credit riêng, không nhập nhầm vào32pin ExerciseDB. Squat bodyweight và glute bridge vẫn thiếu exactmotion.
- Giữ primary lime/SF và phân cấp nút C120/C121: selector chữ/gạch chân, Add capsule108×52 trung tính, Startlime, root active trắng/gạch lime nhỏ. Không đổi route.
- **QA riêng C128–C134:** Replace7→3, Duration13phút, 0giây disableLog/LogAll, nhập/log30giây, finishHealthOff/volume0, sửa history40giây, Add7+3→10 giữ nguyên7bài cũ, relaunch giữ draft/history. Chỉ gỡ bundle com.local.dopafit.discoveryqa sau khi lưu snapshot; main7draft/0set/0group/2history giữ. CSV mới model-test; không tuyên bố UI export hay mọi preset đã kiểm.
- 109 model checks đạt; Debug build/install/launch và các asset gates đạt. Chi tiết bằng chứng cuối ở rebuild/verification/handoff-manifest.json. Changelog/HANDOFF/AGENTS/coverage/media/style/inventory/gaps đã đồng bộ. Figma original140/28 không thay, mọi parity row vẫn partial.

## 2026-11-10 — Checkpoint cũ 19:54–19:55 (cách giảm màu bên dưới đã bị bác bỏ 20:21)

- Bộ chọn7nhóm cơ ở chương trình bỏ capsule/viền lime, dùng nhãn chữ + gạch chân2pt, vùng chạm≥44pt. Thao tác đổi nhóm vẫn giữ3cấp độ tương ứng.
- Sticky Add đổi từ vòng tròn52pt khiến chữ chật sang viên thuốc108×52, icon/chữ trắng, nền card/viền xám. Một Add duy nhất, route picker giữ. Start/Resume52pt vẫn là CTA nền lime. Root nav active trắng + dấu lime16×2, bỏ nền pill riêng từng tab để tránh giống nút hành động. Giữ nguyên primary RGB(.71,.96,.24), SF/font weights/case.
- Neutral palette dựa trên mẫu ảnh Ladder: nền#101010,card#1E1E1E,raised#292929,sheet#141414,muted#A6A6A6,stroke#3E3E3E. Không tuyên bố là token chính thức. `rebuild/style/COLOR-SYSTEM.md` và samples JSON ghi phương pháp.
-6ảnh user chỉ ra quá bão hòa;9cover bổ sung +grip được cân saturation0.12 khi render trong DiscoveryPhoto. **Không thay nguồn bằng ảnh khác**, không AI, không sửa bytes/hash gốc.3ảnh được chọn trước giữ màu/file nguyên. Mobility aspectFit nền đen giữ đủ tư thế thay crop đầu/chân. Caption vẫn riêng dưới ảnh. Manifest thêm rendering policy; rút nhãnactivity thành “Vận động30ngày” để giảm cắt chữ.
- C120Home, C121filter/3levels; đã đổi Cẳng tay và mở Add→picker32→Close không chọn. C122fullbody/C123pelvic/C124core14/C125activity/C126core30/C127mobility là kiểm màu; C124/C126 đã chụp lại qua hàng danh mục đang nhìn thấy, header/Close/CTA đầy đủ. C125 màu đã quan sát nhưng lần auto-scroll lệch khung, không coi là full layoutpass. C127 giữ đầy đủ tư thế, portrait có khoảng đen hai bên. Không ghi set/join mới trong lượt nút/màu.

### Chức năng bổ sung đã triển khai trong cùng lượt tiếp tục

12challenge local (3cũ+9mới), danh mục/search/filter/detail/join/leave/progress;7nhóm×3cấp độ=21preset. Detail có guide/Add/Replace với xác nhận; Replace chặn draft đang tập/có set hoàn tất. Add không làm mất bài cũ. Kegel/mobility dùng checkin riêng +undo, không tạo workout/Health. Loại các lời hứa tăng chiều cao/spotfat/6múi đảm bảo. Preset hiển thị thời gian/số bài thực tế, không sao chép chỉ số giả. Xem `rebuild/DISCOVERY-FEATURES-2026-11-10.md` để có đầy đủ mapping/flow/dependencies/evidence/còn mở.

Thêm6exactExerciseDB motion cho9definition preset; tổng32pin (26thư viện+6preset). Rejected2metadata/GIF lệch động tác; squatbodyweight/glutebridge/plank vẫn static fallback rõ. API response đã lưu repo, script không còn phụ thuộc /tmp. Nguồn180px, guide720 chỉ nội suy. Timed exercise dùng giây thật, validation>0, history/editor/CSV giữ giây, không đổi thành volume/1RM. Ghi giây thủ công; countdown exercise chưa làm. DurationSheet giữ plannedMinutes preset.

109modelchecks đạt; Debug build/install/launch và3assetgates đạt (32pin/13photo). C107–C119 kiểm catalog/manualpractice/program confirms/guide trước passmàu mới. Kegel test31D9E976-0907-4310-B574-617C396CB129: join→ghi1→undo0→leave; giữ recordleft, checkins rỗng. Draft chính7bài,0completedsets,0group,2history; không Add/Replace thực sự trên account chính (cả2confirmation Cancel). QA build bundle riêng đã compile nhưng chưa dùng dữ liệu giả cho timed UI; timed finish/edit/persist hiện model-tested, chưa UI-tested. Original/Figma140states/28roots không thay, mọi parityrow vẫnpartial. Các checkpoint87checks/3ảnh bên dưới là lịch sử, không phải hiện tại.

## 2026-11-10 15:57 — Ảnh chân khác rõ ảnh giữa, chỉ người thật

Theo phản hồi15:54, thay ảnh squat Tima bằng ảnh nữ leg press của Scott Webb (Pexels28076), tông gym đen, góc chéo thấy đầu gối/bàn chân. Ảnh gốc được Pexels đăng04/01/2016, cùng ảnh ở Pixabay03/07/2015 với metadata NikonD300. Không dùng AI generation/editing. Không thay hai ảnh còn lại. Detail270pt vừa tỷ lệ landscape; bỏ offset dành cho squat cũ. Nguồn/license/hash trong manifest; ảnh squat cũ archive ngoài app ở previous/2026-11-10-1554-squat-rejected. Build/install/assetgates đạt. C105detail và C106card đã quan sát; không join/log/đổi workout. Lượt này chỉ ảnh/UI, không rerun87modelchecks. Đang tiếp yêu cầu mới bổ sung danh mục challenge và chương trình theo nhóm/cấp độ, giữ primary/font và palette Ladder.

## 2026-11-10 15:35 — Ảnh gym tối, nút tròn và audit Cơ thể

- **Chốt mới nhất của user15:23:** dùng nền gym tối, người tập ở giữa; bỏ hướng ảnh sáng trước đó. Khôi phục đúng ảnh Samuel Girven đẩy vai được chọn. Thay hai ảnh còn lại bằng Gard Pro chống đẩy và Tima Miroshnichenko squat. Tên/tác giả/URL/license/hash tại `third_party/challenge-photos/manifest.json`; ảnh gốc không chỉnh bằng AI. Ảnh sáng bị bác bỏ lưu ngoài app trong `previous/2026-11-10-bright-rejected`. Caption dưới ảnh, không che động tác; giữ carousel snap và join/leave/progress hiện có. Detail squat cao320pt để giữ thêm ngữ cảnh tư thế.
- Nút Add cố định đổi thành vòng tròn52pt, bằng chiều cao Start52pt; metadata dùng Capsule. Không thêm nút Add trùng.
- Root nav active đổi từ chữ trắng/nền olive sang icon+chữ lime gốc/nền neutral raised. Body Kết quả/Hồi phục cùng quy tắc,44ptfixed header. Giữ nguyên primary RGB(0.71,0.96,0.24), SF/weight/case.
- User cho phép học UI hữu ích từ Ladder nhưng giữ chức năng. Gom hai recovery metrics trong một card; tip/CTA bớt cạnh tranh, copy nói rõ ước tính. Hiển thị tên nhóm cơ thật của draft thay legend vòng tròn không có trên model.
- Sức mạnh tổng dùng10vạch hình bình hành theo ảnh user, bỏ hình chữ nhật xoay. Empty1RM hiện “— kg / Chưa có dữ liệu bài đo”, bỏ0lần/set và trục giả. Không sửa công thức strength/recovery hay thêm Health/backend.
- Model Body chỉ chỉnh camera/đèn để giảm cháy sáng; không sửa mesh/mask/motion. C98/C103 có trước/sau, nhưng anatomy/chất lượng mask vẫn partial và task Form tiếp tục paused. C90 là ảnh trước sửa đèn, không dùng làm bằng chứng pass.
- **Kiểm chứng:** Debug build/install/launch đạt; OpenGym/Form/26ExerciseDB+3photo hash gates đạt. C91 nút tròn; C92/C95/C96 thẻ tối; C93 chống đẩy detail; C94 squat detail trước tăng chiều cao; C104 sau tăng chiều cao. C97 strength/active; C98/C103 model; C100 list; C101 chi tiết Ngực; C102 editor Save disabled. Đã mở/đóng detail và editor Cancel, help; nút Add tròn mở thư viện32bài rồi Close, không chọn thêm; không Save slider, join challenge, log set hoặc kết nối Health.87modelchecks đã đạt ở checkpoint trước; không tuyên bố rerun cho thay đổi ảnh/UI.
- History/prescriptions kiểm read-only bằng manifest updater; giữ7draft,0completedset,0group,2history. Original/Figma vẫn140/28, không có ảnh mới original; mọi parity row partial. Các thuật toán/dịch vụ/khả năng truy cập toàn app vẫn theo OPEN-GAPS.

## 2026-11-10 — Audit và sửa Home, lịch, thử thách và media mờ

Giữ nguyên primary lime RGB(0.71, 0.96, 0.24) và font SF theo yêu cầu mới nhất. Ladder chỉ ảnh hưởng nền trung tính, viền và bo góc; đã bỏ màu yellow, font expanded và uppercase của bản thử. Đã xem193 ảnh tham khảo, không nhập nội dung hoặc thương hiệu Ladder.

### Home và thứ tự nội dung

- Hai đánh giá độc lập cùng xác định: phần khám phá đứng trước buổi tập, ba nút Add trùng nhau, số nhóm cơ hardcode, nhãn tiếng Anh và Resume không phản ánh đúng draft.
- Đưa danh sách bài hôm nay ngay sau tên buổi và thiết lập. Buổi đã lưu, gợi ý nhóm cơ và thử thách nằm sau danh sách. C84 xác minh thấy các bài trước khi bắt đầu; C87 xác minh phần khám phá vẫn cuộn tới đầy đủ.
- Giữ một nút “Thêm bài” cố định, có icon và nhãn; bỏ hai nút trùng ở header và cuối danh sách. Mở thư viện32 bài rồi đóng đã kiểm qua UI, không ghi thêm bài.
- Đếm nhóm cơ chính duy nhất từ draft; buổi đang xem thực tế có5 nhóm cơ, thay nhãn6 cố định. Tên tiếng Anh dựa trên tên draft; Resume xét hasStarted hoặc set đã ghi. Thay vòng tròn avatar trắng bằng icon thiết lập kế hoạch.
- Gom header và thiết lập, giảm nền lime ở nút phụ; điều khiển metadata cao40pt với vùng chạm44pt. Menu bài rộng44pt và có nhãn theo tên bài. Giữ font và primary.

### Calendar, gợi ý và thử thách

- Lịch tuần bắt đầu thứ Hai theo ngày địa phương; chọn ngày cũ xem history, ngày tương lai hiện empty, không tự sinh buổi giả. Mục tiêu tuần đếm ngày có set đã ghi, không đếm trùng hai buổi cùng ngày.
- Thu gọn lịch: previous/next ở header, chạm nhãn ngày về hôm nay, bỏ hàng điều hướng dưới. Ngày đã tập dùng chấm3pt; copy rõ “Tuần này1/3 ngày tập”. C86 kiểm đúng hai buổi cũ và quay về hôm nay.
- Gợi ý nhóm cơ vào picker đã lọc sẵn. Đây là logic recovery/gear cục bộ; đặt sau buổi hôm nay và ghi “Khám phá thêm bài theo nhóm cơ” để không gây hiểu nhầm là phải tập chân trong ngày thân trên.
- Ba thử thách cục bộ14/28 ngày: join/leave, lưu trạng thái, tiến độ tính ngày duy nhất có bài phù hợp sau khi tham gia và trước hạn. Không thay draft/history khi join.
- Ảnh người thật thể hiện chống đẩy, đẩy vai và squat. Ảnh tách khỏi caption, title/summary ngắn, carousel tự căn thẻ; không có chữ hoặc gradient che động tác. C80/C81/C88 kiểm tư thế; C87 thấy đủ caption ở cuối trang. Nguồn, tác giả, license và hash lưu trong third_party/challenge-photos/manifest.json.

### Picker và motion thumbnails

- Tiếp phần Claude: tìm không dấu/token AND, lọc phối hợp, chọn nhiều giữ qua lọc/detail, recent từ history và preset muscle từ Home.
- Row thoáng hơn với thumbnail64pt, khoảng ngang16pt, padding dọc17pt, dấu chọn tròn22pt nét1.25. Độ khó/dụng cụ chuyển vào filter sheet; giữ quick filters. Sửa stale selected row identity và accessibility selected trait. C71/C72 là bằng chứng.
-26/32 bài có mapping ExerciseDB đúng biến thể; giữ GIF và MP4 offline. Không map landmine T-Bar sang máy chest-supported hoặc trap-bar shrug sang straight barbell.
- Bài hôm nay dùng motion thumbnail80pt; hàng gợi ý vẫn dùng hình cơ phẳng. AVPlayerLooper phát file nhỏ, dừng theo tab/scene/disappear; Reduce Motion dừng clip trang trí. Chưa có benchmark FPS/CPU trước–sau.

### Audit clip mờ và cải thiện có giới hạn

- Row nguồn thật là180×180,12 frame trong3 giây:4 pose/giây. Phóng kín màn gây vỡ; chuyển MP4 CFR30 không khôi phục chi tiết hoặc pose đã mất.
- Guide ưu tiên9 renderer Form/OpenGym khớp đúng động tác đã có. Không chỉnh mesh hoặc animation; task Form vẫn tạm dừng. Các clip2D thấp nét được giới hạn220pt trong vùng media tối đa300pt.
- Đã so trước–sau và tạo26 bản guide-only720px bằng Lanczos4x + unsharp0.35, tổng3.3MB. Viền rõ hơn nhẹ; giữ pose/timing nguồn, không AI hoặc optical flow. Đây là **nội suy**, không phải nativeHD hoặc true30 pose/giây. List vẫn dùng MP4 nhỏ để tránh tăng tải. C83/C85 kiểm guide và tốc độ0.5×. HD gap vẫn mở.
- Tài liệu OSS chính thức giới hạn180p, cho prototype phi thương mại, yêu cầu credit AscendAPI; thương mại cần gói được cấp phép. Thêm credit trong Settings → Về Dopafit. Không mua/subscription. Đã loại một HD GitHub mirror vì tác giả thừa nhận không rõ quyền footage.
- Thêm scripts/check-exercise-media.py vào build: kiểm mapping, hash GIF/MP4/guide, khai báo upscale không phải nativeHD và hash ba ảnh.

### Kiểm chứng, dữ liệu và bàn giao

-87 model checks đạt, gồm filter, calendar/challenge, old-state compatibility và bảo toàn dữ liệu khi leave. Debug build/install/launch đạt; OpenGym/Form/media integrity gates đạt.
- Picker test thêm2 rồi xóa đúng2 UUID qua UI đã trả7 bài tại checkpoint. Challenge test id1FC29B17-16D4-4F1B-84A7-C0846FEA147E đã leave qua UI sau nhánh Cancel; giữ record left, không ghi buổi giả.
- Cuối lượt:7 bài beginner upper,0 set hoàn tất,0 nhóm,2 history. History và thứ tự/prescription giống baseline trước test. UUID/start draft khác snapshot cũ; không tự khôi phục UUID cũ. Snapshot read-only và manifest cập nhật.
- Original đã restore tạiR82, không còn rollback nhóm pending. Figma vẫn140 ảnh ORIGINAL/28 root groups; không upload ảnh rebuild hoặc stock. Tất cả140 dòng parity còn partial.
- HANDOFF viết lại thống nhất, bản cũ giữ trong archive. Báo cáo HOME-UX-AUDIT-2026-11-10.md phân biệt finding, thay đổi, bằng chứng và giới hạn. Màn nhỏ, Dynamic Type, VoiceOver toàn luồng, destructive guards, nguồn HD thật và các gapG01–G12 còn cần tiếp tục.

## 2026-11-10 — Chuyển sang tiếp việc Claude theo yêu cầu mới

Người dùng yêu cầu dừng task model/animation Form đang làm, đọc Claude và tiếp tục phần của Claude. Đã đọc cuộc chat “Audit phần thêm bài tập” qua UI Claude; không gửi prompt hoặc message. Phạm vi mới: Thêm/Đổi bài mới, icon phẳng lime, tìm/lọc/chọn nhiều; nút Thêm bài dễ thấy; chi tiết đúng bài; ExerciseDB GIF và tham khảo animation danh sách kiểu Home Workout. Giữ ngoại lệ thiết kế Claude trong AGENTS. File trước khi sửa lưu trong rebuild/claude-handoff-2026-11-10.

Phần Form đã có trong source/bản cài trước khi đổi task: commit upstream be16cb22c4ceb4ad134894250062fd0782410233, runtime offline, neutral Form và8mapping; RDL GPU ready/đổi góc/tốc độ/tab C60–C64,64upstreamtests và264CPUposes đạt,72modelchecks mới đang chốt log. Good Morning giữ OpenGym. Không tiếp tục chỉnh style/mesh Form ở task mới; không coi toàn bộ8clip UI đã kiểm. Giấy phép project-code Form chưa rõ, chỉ thử cục bộ. Figma vẫn140ảnh ORIGINAL, không upload rebuild.


## 2026-11-10 — Màn chọn bài kiểu mới (Claude, theo yêu cầu trực tiếp của người dùng)

Người dùng yêu cầu thiết kế lại màn Thêm/Đổi bài tập và icon nhóm cơ để tìm bài nhanh và khác Fitbod (góp ý của anh Chẩn). Đây là NGOẠI LỆ có chủ ý so với quy tắc "không redesign"; đừng hoàn nguyên về bản sao màn gốc.

- Thêm `DopafitRebuild/ExerciseLibrary.swift`: `ExercisePicker` mới (ô tìm trên cùng, tìm không dấu; hàng nhóm cơ bằng icon; nút lọc cộng dồn Hợp hôm nay / Dụng cụ tôi có / độ khó / nhóm dụng cụ; gom theo nhóm cơ, "Tập gần đây" ở đầu; chọn nhiều bài với nút "Thêm N bài"), `MuscleGlyph` (hình người ghép khối tô lime), `GearGlyph`, `ExerciseMeta`.
- Gỡ `ExercisePicker` cũ khỏi `WorkoutViews.swift` (bản cũ lưu ở `rebuild/legacy-ExercisePicker-2026-11-10.swift.txt`); hai chỗ Thêm bài trong buổi tập dùng `multiple:true`. Đổi bài và thêm bài vào buổi đã lưu vẫn chọn một bài.
- Chạy lại `scripts/generate_project.py` để thêm file vào project.
- Độ khó và nhóm dụng cụ là nhãn CỤC BỘ tự gán trong `ExerciseMeta`, không phải dữ liệu gốc. `ExerciseThumb` ở các màn khác chưa đổi.
- 10:30: `MuscleGlyph` vẽ lại thành hình cơ thể phẳng (bóng người xám, mảng cơ tô lime, cơ phụ lime nhạt; dữ liệu đường vẽ trong `MuscleFigure`). `ExerciseThumb` trong `Design.swift` chuyển sang dùng `MuscleGlyph` thay ảnh 3D. Hình lớn ở tab Cơ thể/Hồi phục vẫn là model 3D.
- Kiểm chứng: build và chạy bằng Xcode Run trên iPhone 18 Pro Max, màn Buổi tập hiện thumbnail mới. Chưa chạy model checks. Xem phần trả lời của phiên để biết UI đã bấm thử tới đâu.

## 2026-11-10 — Grip thật, kiểm GPU và menu nhóm trên simulator

- Phát hiện C48: tay curl còn cầm tạ sai dù điểm wrist-tail khớp tạ. Wrist-tail là gót lòng bàn tay, không phải tâm nắm. Đã đổi sang tâm các khớp MCP +12mm theo pháp tuyến lòng bàn tay, hướng supination cho curl/pronation choRDL; Good Morning wrist hướng theo rack và IK theo tâm nắm; ngón gập75/95/65độ, cùng dấu ổn định trên mỗi ngón. Render cận bàn tay tại verification/refined-model/curl-grip-palm-centered.png. Không lấy kiểm điểm wrist-tail cũ làm bằng chứng grip đúng.
- QA214frame sau export có gripReferenceMCP, đo cả khoảng cách đầu ngón tới trục tay cầm. Cả3clip đạt: tâm nắm lệch<1.1mm, ngón tới trục≤38.5mm (ngưỡng60mm), maxedge0.0861m, loop<2.9mm, bước frame≤63.5mm, footdrift<0.006mm; minmeshZ vẫn−11.2mm trongtolerance15mm. Assetgate buộc MCP/fingertipQA. Three170CPU parse/skin5pha lại đạt. Hash/report/model bundle cập nhật đồng bộ, neutral không đổi.
- C56/C57: curl mới đã xem front/side, hai tạ tách và ôm bằng lòng bàn tay, ngón gập, màu chỉ ở tay trước; C58 đổi tab rồi quay lại giữ góc. Good Morning sau grip mới đã xem qua luồng active→detail→guide, góc bên không còn cắt tạ; ảnh chưa lưu cuối. Những chỗ chưa xem đủ hoặc self-collision chi tiết vẫn G02, không cam kết mọi form đã chuẩn.
- C49–C54: UI Save nhóm3+4set→4vòng; menu3action; Ghi→Hủy giữ data; Nhân đôi tạo2bài unlogged; Ghi nhóm bản sao ghi3+4set; Tách giữ dữliệu; xóa2bản sao vàtách nhóm gốc thử. Snapshot sau dọn7bài/6set/2history/0group, không lưu thêm buổi. ORIGINAL chỉ menu/Tách/sốvòng đã audit; duplicate/log semantics cònlocal.
- Models thêm orphan cleanup khi xóa một trong2bài nhóm,2checks persistence/preservation; tổng70checks đạt. Build/cài/launch bản grip/pulse/group đạt. Guide modal từactive dùng X theoR80, push guide từHome giữ chevron; patch này đang build kiểmUI cuối.
- Native C59 sau tăng tươngphản pulse:7ảnh pose/camera cốđịnh trong~3.6s, ROI đùi có meanG khoảng0.460…0.522 so với0.511…0.525ởC55. Chỉ hỗtrợ biếnthiênchiếusáng, không chứngnhận flicker hoặcReduceMotion. Guide Three pulse theo pha clip, native1.8s; vẫn cần testReduceMotionthực vàfaultinjection.
- Figma vẫn140original/28root, không thêm render/model/simulator. Matrix/HANDOFF/OPEN-GAPS/provenance sẽ chốt theo bản cuối. Không cónhóm thửpending trênoriginal; R82 làbằngchứngrestore.

## 2026-11-10 — Nối lại app thật, khôi phục dữ liệu; Figma140 và menu nhóm

- App gốc: chụp R77 (đã lưu nhóm), R78 menu nhóm, R79 tách giữ thứ tự, R80 video hướng dẫn vai ready, R81 nhóm2+4set hiện4vòng, R82 đã tách và trả đúng thứ tự7bài ban đầu. Không ghi set/finish/discard. Thứ tự được trả bằng ghép tạm Row+Hammer rồi tách; drag ngắn không đổi thứ tự, chưa coi gesture reorder đạt.
- R80 filename cũ có anatomy nhưng ảnh lưu thực tế đã chuyển sang video. Đã xem file và sửa annotation đúng video-ready; anatomy chỉ từng thấy trong tool trước khi tải xong. Không dùng screenshot trạng thái khác để mô tả ảnh.
- Figma connector phiên hiện tại chỉ đọc; đã dùng desktop nhập SVG6ảnh gốc, sửa tên bằng pasteUnicode, đặt root56:944 ở(0,25650),2860×2540. Bản thử có annotationR80 cũ đã xóa bằng Undo/recoverable editor, không duplicate. Đọc lại140card/140image/140IDriêng/28root; xem render verification-R77-R82.png. Chú thích là TEXT, ảnh giữ IMAGE fill. Không upload ảnh rebuild.
- Thêm3tác vụ nhóm vào ActiveWorkoutView: Ghi mọi bài (confirmationlocal), Nhân đôi (IDmới/unlogged/local placement), Tách (giữ thứtự/set). Header sốvòng dùng maxsetcount theoR81.7modelchecks mới kiểm uniqueIDs/reset/preserve/log/detach/reload/invalid: tổng68đạt. Ghi/Nhân đôi ORIGINAL chưa thực thi, semantics vẫn cần đối chiếu; circuit execution chưa hoàn chỉnh.
- UI model sau mởkhóa: C41 phát hiện native vùng cơ cháy vàng, đã giảm light/emission và bù basecolor; thumb hết cháy vàng trên Home. RDL ThreeGPU đã ready, đổi front/side/rear, vùng cơ vàtạriêng; tốcđộ0,5×giữgóc. C43/C44là haiảnhpha khácthực, C45gócbên. C42trướcsửalight còn tối. Goodmorning front/side đã thấy, phát hiện nearplate bịcắtméptrên. Camera đang đổi sang fitboundingsphere của13pha toànclip đểchứacảprop ởmọigóc; native fullbody margin cũng tăng đểfallbackkhôngcắthead. Bản camera mới đang build/retest, không coi bằng chứngcũ passcamera mới.
- Published inventory/matrix140 dòng đều partial, giữ G01–G12. Handoff cần tiếp tục kiểm menu nhóm thật trên simulator,3clip/masks/pulse vàReduceMotion, camera mới/loading/failure/background; giữ draft6set đã ghi và2history. Chưa có pixel parity toàn app hoặc dịch vụ private.

## 2026-11-10 — Audit motion/mesh, thêm nhấp nháy cơ; UI bản mới còn chờ Mac mở khóa

- Yêu cầu mới: rà cử chỉ/mesh bị lõm, sáng vùng cơ đang tập, style và chức năng theo app cũ. Đã đọc lại Figma: 134 card /134 ID duy nhất, gồm D05/R43/R63–R65 và R73–R76. Không có ảnh gốc mới vì Mac vẫn khóa; không upload rebuild vào board. Nhóm thử ORIGINAL R77 vẫn CHƯA THÁO, giữ cảnh báo đầu HANDOFF.
- Phát hiện lỗi thực ở bản trước: mỗi GLB động có hai clip skeletal, viewer phát đồng thời; chân RDL/Good morning trượt xuống; lưng gập cong quá mức sau retarget; tay Good morning đi qua ngực; ngón tay có thể đổi dấu gập giữa frame. Các QA finite/bounds trước đây KHÔNG phát hiện được những lỗi này.
- Sửa bộ dẫn xuất trong Blender4.0.2: một NLA clip đồng bộ cả body/tạ; IK neo cổ chân; giữ đường cong spine rest khi gập hông; tay Good morning ôm đòn ở lưng trên; wrist theo forearm; dấu gập ngón cố định; dumbbell hai tay tách nhau. Weld seam xuất GLB, làm mềm cục bộ ngực–vai và bỏ custom normals cũ. Có dumbbell/barbell procedural, không dùng clip/license mới từ live site.
- Cùng4GLB đã được thay đồng bộ sau QA. Baked16 mask mềm `_MUSCLE_0…3` chỉ trên skin, không tô tạ. Three tô cơ chính mạnh/cơ phụ nhẹ và pulse theo pha clip; native preview pulse1.8giây. Reduce Motion giữ highlight tĩnh; dừng pulse ở scene/tab không active. Thêm fallback khi shader/context lỗi; fallback giữ vùng cơ và góc. Không đổi engine recovery local.
- Sửa camera không bị reset/đẩy lùi khi chỉ cập nhật tốc độ/heat, fit theo cả chiều ngang dụng cụ. Guide theoR43/R63: media1.09×width đi dưới statusbar, back ởsafearea, thumbnailbo8cao60, tốc độ VI dấu phẩy + x/hộp bo; D05dividercuối cơ phụ; khôi phục4đoạn Row quan sát được. Phần hướng dẫn phía dưới chưa chụp vẫn unknown; nhiều bài còn cue chung.
- Kiểm: asset gate đạt (hash/skin/16mask/1clip/props/notices);61modelchecks đạt; Debug build/cài/launch đạt.214frame Blender QA: foot drift tối đa<0.006mm, grip<1.1mm, loop seam<3.1mm, bước đỉnh≤68.1mm/frame; maxedge<0.083m. MinmeshZ còn khoảng−11.2mm, trong tolerance15mm, không gọi là zero floor penetration. Three170CPU loader/skinning đạt5pha×3clip,87,575đỉnh/bài; shaderGPU chưa được kiểm bởi test này.
- Xem9render Blender ở verification/refined-model (KHÔNG phải simulator screenshot). Chưa thấy vết rách lớn ở các góc đã xem, nhưng chưa có kiểm self-collision/anatomy đầy đủ. Pulse/shaderGPU, safearea/layout mới và mọi cử chỉ trung gian phải UI kiểm sau mở khóa. C23–C40 là evidence trước các thay đổi media/style này, không tự nâng thành pass bản mới.
- Handoff/provenance: workfiles/retargeted-v1 giữ đầu vào hash cố định; muscular_source.blend gốc vẫn nguyên; refined_source.blend là neutral đã chỉnh. Scripts refine_motion→bake_muscle_regions→qa_refined và qa_three, reports/motion-pulse-audit, coverage/OPEN-GAPS/PARITY cập nhật.24bài vẫn thiếu clip; auth/backend/Health/Watch/circuit đầy đủ chưa có. Không tuyên bố tương đương100%.

Bảng rà soát lượt model/pulse/style và các feature còn mở: `rebuild/AUDIT-2026-11-10.md`. Palette model native/Three đã đồng bộ charcoal #303b46 và orange #ff820a; ánh sáng/GPU vẫn cần kiểm trên UI.

## 2026-11-10 — Cập nhật cuối lượt: reorder đã sửa, rollback original đang chờ

- Đã sửa helper theo quan sát Save1+3: gom bài chọn cạnh nhau, giữ thứ tự trong nhóm và phần còn lại, không đổi globalplan preference hoặc log/history. Anchor tại bài chọn đầu là rule local cho các vị trí chưa quan sát. Header Superset·Nvòng hiện khi setcount bằng nhau; trường hợp không đều/circuit còn cần audit.61modelchecks mới vàbuild/cài/launch đạt. Header/reorder mới chưa UI retest.
- Simulatorđã UI kiểmC33 Cancel bỏbuổi, C35→C34loading→ready, C36background-return, C37–C40superset0/1/2→Cancel. JSONcuối vẫn2history,7draft,adductor3/calf3completed,khônggroup. Đã cập nhậtcoverage134dòng,notes/dẫnchiếuFigmaR76,manifest/handoff vàcácgap. Figma134ảnh/27rootđãrenderxem, khôngđếmR77.
- **Original đang còn nhóm thử Row(machine)+Shoulder(dumbbell), chưa tháo/khôi phục thứ tự.** Mackhóa lúc mởmenu nhóm; đã hỏiuser mở. R77 đã thấytrong screenshottool nhưng attemptedcapturebịlock, KHÔNG cófile; metadataobservationtạmởverification/pending-R77-observation.json ngoàiinventory. Khi mởkhóa cần chụpR77rồi audittháonhóm vàrestoreRow→Hammer→Shoulder. Không nói originalđã khôi phục. Khônglogset/finishsession.

## 2026-11-10 — Lượt tiếp đang làm: popup/loading, menu superset, cần tháo nhóm thử original

- CUA ban đầu lỗi app-server rồi “No space left on device”, ổ còn144MiB. Đã dọn Index/SDK/modules/intermediate cache của project và eject/xóa BlenderDMG tải tạm; giải phóng khoảng600MiB, khôi phục CUA. Source Blender/GLB/evidence giữ nguyên. Sau rebuild dung lượng trống khoảng0,4GiB; không dọn file cá nhân.
- UI C33: X→dialog→Tập tiếp giữ timer/6set. C35/C34: model loading→clipready. C36: iOSHome→mởapp giữguide/clip. Error fallback chưa fault-inject.
- OriginalR73–R76: active menu chỉ Ghép superset/circuit, selection cùng trang cóHủy/timer/Lưu,0/1Lưu xám,2Lưu lime, Hủy không ghi. Đã lênFigma và render/đọc lại134cards/134images/27roots, không trùng; root49:2(6080,22800). C37–C40 là simulator menu/0/1/2→Hủy.61modelchecks đạt; build/cài/launch đạt. Chưa cập nhật hết coverage/current manifest sau discoveryR77.
- Đã thêm active selection và groupDraftExercises, test5ca invalid/group/preservation/reload/orphans; HomeSupersetSheet dùng chung save method. Nhưng quy tắc giữ order mới là giả định local, R77 vừa xác minh khác và đang sửa.
- OriginalR77: đã Save nhóm thử Row(machine)1 + Shoulder(dumbbell)3. Chúng lên đầu thành group “Superset · 2 vòng”; Hammerstrength từ2→3. Không log set/finish. Mac khóa khi mở menu NHÓM nên chưa tháo nhóm/khôi phục thứ tự; đã hỏi user mở. Đây là mutation test đang dang dở, phải đọc HANDOFF và hoàn tất rollback khi mở khóa. R77 mới là quan sát trong tool, ảnh cục bộ chưa lưu được; Figma vẫn134đếnR76.

## 2026-11-10 — UI model mới đã kiểm; phát hiện và bổ sung xác nhận bỏ buổi

### Model muscular trên simulator

- C23/C24: Recovery mặt trước/sau; C25/C26: thumbnail10cơ chính/6cơ phụ đã cuộn xem. Model/ảnh không trống, không thấy rách mesh/giãn chi ở các khung đã quan sát. Mask cơ vẫn xấp xỉ theo bone territories, màu/ranh giới chưa phải anatomy gốc.
- RDL: góc1/2/3,1×→0,5×, đổi sang Cơ thể rồi quay lại giữ góc3/tốc độ0,5× và hiển thị tiếp (C27–C29). Good morning: góc bên1× (C30). Curl: góc2/4,1×/2× và tabNhóm cơ (C31/C32). Đây là tập case cụ thể, không phải mọi clip×mọi góc×mọi tốc độ. Không thấy crash hoặc vùng media trống sau khi tải xong; chưa fault-inject WebKit.
- Để mở guide curl qua flow thật, thêm tạm dumbbell-curl vào draft (7→8bài), xem rồi xóa đúng bài thử (8→7). Không log set/finish; giữ3adductor+3calf đã có và2session cũ. Original không bị sửa set/session ở lượt này.
- Phát hiện vùng clip đen lúc chờ tải. Đã thêm placeholder model tĩnh + “Đang tải chuyển động…” trước khi ready, cập nhật thành lỗi nếu load/WebKit thất bại. Bản mới build/cài/launch đạt; nhánh loading/error mới chưa retest UI vì Mac khóa lại. Tài khoản sau không được coi C27–C32 là evidence của placeholder mới.

### Original R72 và chức năng bỏ buổi

- Mở lại app gốc thấy một buổi đang chạy hơn7giờ; không suy rằng đây là buổi được phép bỏ. Chạm X mở dialog “Bỏ buổi tập này?” / “Mọi thứ trong buổi này sẽ không được lưu.”, Tập tiếp lime / Bỏ buổi tập đỏ. Đã chọn Tập tiếp, timer vẫn chạy; không bấm Bỏ, không lưu buổi. Clickellipsis sau đó bị Mac lock trước khi thấy menu, không tính là đã audit menu.
- Rebuild trước đây X chỉ persist/dismiss. ActiveWorkoutView giờ có native alert đúng copy và2nhánh. Tập tiếp giữ draft; Bỏ gọi discardWorkout xóa draft chưa lưu, hủy rest state, sinh draft mới bằng generator LOCAL; giữ history/templates/lowerNext. Cách original sinh plan sau bỏ vẫn UNKNOWN vì chưa bấm.
- Thêm4modelchecks với store riêng trong thư mục tạm: discard không lưu sets, xóa timer/paused/active, giữ history/templates/split, reload draft mới đúng.56/56đạt, build/cài/launch đạt. Chưa bấm Bỏ trên draft simulator đang có6set và chưa UI test alert/cancel do Mac lock. Không reset draft để làm đẹp evidence.

### Figma và bàn giao

- R72 screenshotoriginal + annotation tên/mục đích/entry/exit/chính/phụ/phụ thuộc/caveat đã lên Figma. Root46:2 tại(3040,22800), card46:6; đã render xem và đọc lại130cards/130imagefills/26roots, không trùngID.58D+72R. `figma/verification-130.json`, `verification-R72.png`. Không đưa C23–C32/Blender renders lên board original.
- Sửa generator coverage dùng deepcopy mỗi ID, tránh cùng object bị nối lặp source paths/media notes khi enrich nhiều dòng. Đã regenerate130dòng và kiểm không trùng paths/không lặp chú thích; vẫn tất cảpartial. Cập nhật media UI evidence và R72, không biến số ảnh thành số màn hoàn thành.
- Mac khóa lại lúc rà menu original. Đã hỏi user mở, tiếp tục code/Figma/docs qua công cụ độc lập; không đổi auto-lock. Còn UI popup/cancel/placeholder và các gap G01–G12 cần tiếp tục.

## 2026-11-09 — Model có cơ bắp: bộ dẫn xuất đồng bộ, QA offline đạt, chờ UI mở khóa

Theo yêu cầu “model nên có cơ bắp tí, và đừng có bị lỗi”, thay mannequin v1 bằng nam trưởng thành tạo bằng MakeHuman/MPFB trên nền tảng OpenGym3D. Đây là model dẫn xuất mới, không phải asset muscular có sẵn nguyên bản trong repo. Bake macro/detail targets vào geometry; giữ source.blend để chỉnh tiếp; retarget3animation bằng rotation lên rest-skeleton mới, tránh chép chiều dài chi cũ. Không nhập preview Z-Anatomy có vấn đề hoặc clip Mixamo khác license.

- Bundle hiện có muscular_body/curl/RDL/goodmorning cùng phiên bản. ExerciseThumb, preview bài, list cơ và thumbnail4góc đều dùng model mới; PNG mannequin và crop cơ cũ được giữ ngoài app tại legacy-reference-assets. Giữ style/layout/flow và dữ liệu tập. Board Figma vẫn129ảnh ORIGINAL/25nhóm.
- Native full-body camera dùng chiều cao model thực, focused thumbnails theo tỉ lệ; mỗi góc preview có hướng camera riêng. Heatmap nhận recovery local, vùng cơ theo bone territories xấp xỉ. Không coi là mask anatomy chuẩn hoặc engine gốc.
- Viewer offline có loại bỏ kết quả load cũ khi đổi model nhanh, ngừng animation lúc hidden/tab inactive; native fallback model tĩnh nếu load/WebKit lỗi. Fallback mới chỉ source/build, chưa fault-injection UI.
- QA214frame: neutral1/curl63/RDL77/goodmorning73 đều finite, không bounds bùng hoặc edge vượt0.30m (max0.0849m). Đã xem neutral trước/sau và9render động tác/góc, chưa thấy rách/giãn chi rõ. geometry-qa.json gắn SHA đúng model ship; integrity checks geometry/weights/indices/animation/notices đạt.52modelchecks đạt. Debug build/cài/launch đạt, chỉ warning metadata AppIntents không có dependency.
- Evidence Blender render: verification/muscular-preview-front.png, muscular-preview-back.png, muscular-pose-review.png. Chúng KHÔNG phải simulator screenshot. C15–C22 là v1cũ, không được dùng chứng minh muscular UI.
- Mac vẫn khóa khi bước UI cuối; đã hỏi user mở, không thay auto-lock. Cần kiểm simulator front/back/list/cả3clip/góc/speed/tab/relaunch khi mở khóa. Không khẳng định “không còn mọi lỗi”.24bài vẫn chưa có animation,3clip thiếu props, các gap G01–G12 còn mở.
- Manifest tách upstreamModels/derived models; prepare script chỉ stage nguồn vào.build, không restore model cũ đè app. Scripts/source Blender/QA/notices được giữ để tài khoản khác tiếp tục. Cập nhật OPENGYM-INTEGRATION, ASSET-PROVENANCE, HANDOFF, PARITY, OPEN-GAPS, coverage và manifest bàn giao.

- Ghi chú đối soát JSON cuối lượt asset: history vẫn Row720kg/RIR3/60giây và Incline765kg/RIR3. Draft thực tế có3set adductor +3set calf completed; snapshot calf-only cũ thiếu thông tin. Đã cập nhật current-test-state và HANDOFF, không reset/sửa draft. Resources trong app đã cài khớp hash source.
- run-simulator.sh kiểm asset integrity trước build/cài để chặn asset cũ hoặc QA/hash không khớp.

## 2026-11-09 — Asset OpenGym3D theo yêu cầu mới (đang hoàn thiện model cơ bắp)

Người dùng cung cấp repo AssiamahS/opengym3d, yêu cầu thay asset crop hiện tại, rồi yêu cầu model có cơ bắp và không lỗi. Đã pin repo/archive/license, bundle viewer offline và đưa neutral3D/thumbnail/3animation đúng mapping vào app; giữ nguyên board Figma original129ảnh. Đã UI render front/back, thumbnail, RDL góc bên/sau và tốc độ0.5 (C15–C22),52modelchecks đạt. Crop cơ cũ chuyển sang legacy-reference-assets. Model v1 còn mannequin, user yêu cầu sửa nên chưa coi media xong.

Đang tạo adultmale muscular trên MakeHuman/MPFB cùng nền tảng OpenGym3D, bake macro và detail targets, retarget3clip trên rest skeleton mới. Đã có scripts generation/retarget/geometryQA; không nhập nhánh Z-Anatomy có biến dạng trong preview. Đọc OPENGYM-INTEGRATION.md để biết trạng thái chính xác. Mac bị khóa khi sắp xem model cơ bắp, đã hỏi user mở; tiếp tục QA asset độc lập, chưa đánh dấu UI pass cho phiên bản mới.

## 2026-11-09 — Rà trực tiếp lần tiếp: cơ phụ, thời lượng và lịch tháng

### Bằng chứng original mới

- R68/R69: đã cuộn tới cuối danh sách hồi phục, xác nhận6cơ phụ đúng thứ tự Bắp chân, Cơ thang, Cơ dạng hông, Cơ khép hông, Cẳng tay, Cổ. List gốc giữ header/back/Sửa khi cuộn. Phần editor cơ phụ vẫn chưa xác minh; không suy từ list.
- R70: Nhật ký → ellipsis trên card → Sửa thời lượng buổi tập mở sheet hai bánh xe giờ/phút, số lớn2p, subtitle, X đóng, CTA Xong. Đã đóng X, không đổi dữ liệu original. Khoảng giới hạn/zero validation chưa được kiểm trên original.
- R71: chạm Tháng11 mở rộng một tuần thành lưới cả tháng7cột CN→T7, ring ngày9 và2p; chạm ngày3trống không lọc hết danh sách. Chuyển tháng bằng swipe chưa xác nhận.

### Bản simulator đã thay đổi

- BodyAndGoalsViews.swift: thêm section6cơ phụ sau10cơ chính, dùng crop từ R69; header list giữ cố định; dòng bài gần nhất có số giờ đã qua. Không đổi engine recovery local và chưa thêm editor cơ phụ khi chưa có bằng chứng.
- SavedDurationEditor.swift: thay slider bằng hai wheel giờ/phút, header/subtitle/close, giá trị lớn và Xong; dùng chung từ SessionDetail và ellipsis mới trên card Nhật ký. Validation0và range0–23giờ/0–59phút là lựa chọn local cần đối chiếu thêm.
- Models.swift: updateSavedDuration validate, persist và không sửa set/volume. Bổ sung4model checks cho invalid0/minute60,1h17 và reload/volume.
- ProgressViews.swift: nút tháng toggle lịch tuần/tháng thay menu tháng trước/này/sau; grid đủ số tuần trong tháng, ngày ngoài tháng/tương lai mờ, ngày có session có ring/màu và tổng phút; ngày trống không thay filter. Chưa có bằng chứng chuyển tháng nên phần đó còn mở.

### Kiểm thử thực tế

- Model52/52đạt. Debug build/cài/launch thành công; bản cuối chỉnh past-day opacity và vị trí ellipsis đã build/cài thành công và xem lại trên UI.
- UI: danh sách đủ6cơ phụ, thumbnail được so với R69, header giữ khi cuộn (C11/C13); C10 editor cũ đã chụp sau mở khóa, Save vẫn disabled khi chưa đổi.
- Row test duration28giây → chọn1phút → Xong → mở lại1phút; chọn2phút rồi X đóng vẫn1phút. Volume720kg/RIR3 giữ nguyên; kcal local tự đổi2→6theo duration. Đây là thay đổi dữ liệu test được giữ lại, không phải dữ liệu original. EvidenceC12.
- UI picker: Tập nhiều nhất xếp Incline/Row đầu; search English dumbbell row ra Row; gearTạđòn trả empty, gearCặp tạđơn trả Row; chọn Row mở editor rồi đóng khôngSave, session vẫn1bài/720kg. Chưa coi là đã test mọi sort/gear hoặc Save bài mới.
- UI calendar: mở rộng có đủ35ô cho tháng11/2026 gồm ngày1→30 và spillover1→5tháng12; nút đổi Thu gọn; future mờ. Dữ liệu2session trên9/11 hiện13p. Expanded/collapsed không đổi history.

### Tài liệu / Figma

Đã nhập R68–R70 vào root39:2 (6080,19950), card39:7/33/58; đã render và đọc lại128card/128ảnh/24nhóm không trùng. R71 nhập riêng root41:2 ở(0,22800); đã render và đọc lại129card/129ảnh/25nhóm, không trùngID. Không upload lại batch23sau khi thêmR71 vì batch đó chứa3ảnh đã có.

Chưa đóngG01–G12. Đặc biệt sliderSave original/rebuild, editor cơ phụ, media/mesh, engine/services, report/locale/circuit và pixel parity còn mở. Các mốc125/128dưới đây là lịch sử; số hiện tại xem published-verification và HANDOFF.

## 2026-11-09 — Làm rõ nguồn hình và số hồi phục theo câu hỏi người dùng

- Thumbnail cơ màu cam trong simulator lấy từ crop ảnh original R66 (`rebuild/audit/R66-recovery-muscle-list-live.png`), đưa vào `Assets.xcassets/reference-muscle-list.imageset/reference.png`. `MuscleThumbnail` trong BodyAndGoalsViews.swift cắt từng hàng; đây là raster tĩnh, không phải asset/mesh gốc đã trích xuất.
- Phần trăm hồi phục simulator do `AppStore.muscleRecovery` trong Models.swift tính: xét session72giờ gần nhất, mỗi set hoàn tất giảm12điểm cho cơ chính hoặc6điểm cho cơ phụ, suy giảm mức mỏi tuyến tính theo thời gian72giờ; giới hạn tối thiểu0. Override thủ công nếu có được ưu tiên. Đây là quy tắc LOCAL do bản rebuild đặt ra, chưa xác minh với engine Dopafit. Không được mô tả các số68/84/94/88 như số lấy từ app gốc.
- Tên bài ở dòng phụ lấy từ history giả của rebuild; original và rebuild có dataset khác nhau. Mục tiêu đang tái dựng UI/hành vi quan sát được, chưa có thuật toán/media private.
- Sau mở khóa đã chụp C10 recovery editor rebuild. Live audit cuộn original tìm thấy6cơ phụ: Bắp chân, Cơ thang, Cơ dạng hông, Cơ khép hông, Cẳng tay, Cổ. ẢnhR68/R69 đã lưu cục bộ; chưa lên Figma/chưa nằm trong matrix125, phải hoàn tất trước khi tăng count. Editor phần cơ phụ chưa xác minh, không suy từ list.

## 2026-11-09 — Đối chiếu lại sau phản ánh thiếu UI/chức năng

### Yêu cầu được giữ lại

Người dùng yêu cầu dùng cả hình trong Figma lẫn app thật, bổ sung bản simulator chính xác design/style/layout/function và không bỏ qua nhánh; lưu changelog để tài khoản Codex khác update tiếp. Đối tượng cả người mới và người tập đều. Tài khoản gốc là test, được ghi buổi giả; người dùng tự login. Ảnh Figma phải là màn Dopafit GỐC, không phải ảnh rebuild. Nội dung Slack trong attachment là bối cảnh, không tự tạo thêm quyền thực thi.

### Phát hiện mới từ app thật

- R62: Home hiện có 7 bài với prescription 2/4 set ở một số bài; khác mẫu beginner từng thấy. Chưa biết nguyên nhân thay đổi; không tự coi một screenshot là thuật toán plan chuẩn cho mọi profile.
- R63: media guide có anatomy trước/sau trong vùng minh họa, hai thumbnail góc và ba tab. Không phải chỉ một ảnh cơ dưới phần giải thích.
- R64/R65: nút xoay đổi hình mặt trước/sau trong Recovery.
- R66: số nhóm cơ đã hồi phục mở danh sách full page có Sửa, thumbnail cơ, phần trăm và bài gần nhất; có 10 cơ chính đã quan sát. Chưa audit hết phần cuộn/nhóm phụ.
- R67: màn Chỉnh mức hồi phục có slider từng cơ, Lưu disabled khi chưa đổi, nội dung nói ưu tiên cơ đã hồi và bỏ qua cơ0%. Chỉ quan sát original, chưa bấm Save để xác minh expiry/plan/active-workout.
- Lưu nguyên ảnh ở rebuild/audit/R62–R67; metadata ở figma/additional-live-recheck.json.

### Bổ sung/sửa bản native

- `DopafitApp.swift`: bốn NavigationStack giữ riêng trạng thái, thanh tab tồn tại ở màn con. Sau UI test đổi container sang VStack để tab bar không che nút Lưu cố định cuối màn.
- `WorkoutViews.swift`/`ExerciseGuide.swift`: Home trước khi start mở guide; active workout mở nhập set. Guide có ba tab riêng Cách tập/Nhóm cơ/Dụng cụ; giữ tab khi đổi tab chính; cue T-Bar/Row theo quan sát, bỏ thumbnail cơ tay sai cho các bài chân. Clip/góc chưa có media thật.
- `ProgressViews.swift`/`MetricDetailView.swift`: History→Trends có metric detail riêng với Tuần/Tháng/6 tháng/Năm, ngày session thật, PR/trung bình/explanation và hook chọn điểm. Menu bài đã lưu đóng sheet trước khi push History/Guide, tránh màn con bị nhốt trong half-sheet. Thay segmented picker History bằng PillTabs đồng nhất style/có control accessible.
- `BodyAndGoalsViews.swift`: kết quả benchmark không dùng mọi bài bất kỳ; Health CTA mở đúng kết nối. Recovery có ngày từ buổi gần nhất, tip persist, trước/sau, list cơ và drill-down. Bổ sung editor10cơ chính, slider0–100, Save disabled khi chưa thay đổi, Cancel/Save; thumbnail crop theo R66.
- `Models.swift`: thêm optional RecoveryAdjustment để dữ liệu cũ đọc được; override clamp0–100, persist trong ngày local; draft mới bỏ bài có primary cơ0% và ưu tiên cơ sẵn sàng. Không đổi draft đang tập. Expiry một ngày là quyết định LOCAL chưa xác minh với original.
- Goals: ba nhóm màu đẩy/kéo/chân, mở rộng target/còn lại, trọng số cơ chính1/phụ0,5, lịch sử và tip. Target kéo/chân còn local, chưa xác nhận gốc.
- `SavedSetEditor.swift`: sửa reps/load/warmup, thêm/xóa set và bài trong session cũ, validate và save/cancel; thêm bài qua picker. UI đã sửa Row12→10 reps (720→600kg), lưu rồi khôi phục12 reps/720kg.
- Sort exercise picker thực sự theo history/preferences/query/gear; template reuse giữ prescription/rest/notes/group nhưng reset IDs/completion/RIR. Rest warmup và main tách riêng có fallback dữ liệu cũ. Journal lọc đúng tháng/ngày, clear day khi đổi tháng và dùng card solid.

### Figma và bộ ghi nhớ chuyển tài khoản

- Đọc lại125 card /125 image fills /23 root groups, không trùng D/R ID; 58D+67R. Sáu card mới root33:510 nằm (3040,19950), nội bộ card/grid đúng vị trí. Không thay vị trí các nhóm cũ. Xem figma/verification-125.json và verification-R62-R67.png.
- 7 dẫn chiếu R42 sai trước đây đã sửa/đọc lại7/7. R42 là guide trong ảnh, không gắn nhãn Home.
- Tạo AGENTS.md, rebuild/HANDOFF.md, OPEN-GAPS.md, SCREEN-COVERAGE.md/JSON và script build_screen_coverage.py. Matrix có đủ125ID/ảnh gốc/Figma/source/UI evidence/gap, purpose/flows/primary-secondary/dependencies ởJSON. Path source là tương đối trong repo để chuyển máy/account.
- Toàn bộ dòng vẫn partial; không đánh đồng số ảnh với số màn hoàn tất. Chưa có golden pixel comparisons toàn bộ.

### Kiểm chứng lượt này

- Debug build thành công và cài/chạy trên simulator iPhone18ProMax iOS27.3; model48/48 đạt. Model checks gồm48ca lưu/draft/volume/RIR/migration/sort/template/edit/rest/recovery, không phải48UItests.
- UI thực tế: guide ba tab và stack giữ; Row saved edit/save/reopen/restore; recovery list/detail/front/back; editor hiện slider và Save disabled; goals đẩy mở rộng; saved menu→History full page→Trends→1RM cả4kỳ; đổi Cơ thể rồi quay Nhật ký giữ metric/kỳ.
- Bằng chứng rebuild C01–C09 ở rebuild/verification, chỉ cục bộ. C08 chụp trước thay đổi container cuối; C09 sau thay đổi. Không đưa vào board original.
- Chưa xác nhận UI slider→Save (AX setter đổi control nhưng không phát binding), library tổ hợp filter/sort/gear, saved add/cancel, main/warmup rest timer UI và chart point selection. Các mục này vẫn mở G11/G12.
- Mac tự khóa ở bước chụp editor/thư viện tiếp theo; user đã được hỏi mở khóa. Không sửa auto-lock/security, không coi bước bị chặn là đã test. Không tạo file C10 khi chưa chụp được.

Snapshot dữ liệu cuối: hai session vẫn765/720kg vàRIR3; không có recoveryAdjustment đã lưu. Draft thân dưới hiện có3set nhón bắp chân completed, chưa lưu thành session; ghi riêng ở rebuild/verification/current-test-state.json để lượt sau không reset nhầm.

### Còn thiếu phải tiếp tục

G01–G12 trong rebuild/OPEN-GAPS.md là backlog bắt buộc, đặc biệt: full visual comparison; media/mesh gốc; thư viện bài/dụng cụ; engine plan/progression/recovery/strength; auth/subscription/cloud; Health/Watch; onboarding nhánh khác; timed/circuit/background timer; journal/report/streak metadata; English/accessibility. Thiếu source/assets/service thật không được che bằng dữ liệu hoặc nút giả mang nghĩa đã kết nối.

## 2026-11-09 — Các lượt nền tảng trước đối chiếu bổ sung

- Tạo project SwiftUI cục bộ, JSON persistence, bốn tab, Home/plan/gym/set/timer/log-all/RIR/finish/summary/history/trend/report/settings/profile/CSV; có demo và launch argument audit giữ history.
- Audit original D01–D58 và onboarding R01–R38; sau khi user tự login audit R39–R61. Figma từng có119ảnh/22nhóm. Đây là mốc lịch sử đã được thay bằng125 ở trên.
- Native UI đã thử vòng Incline3×6×42,5=765kg, RIR2 rồi sửa3; Row12×30 mỗi bên=720kg/RIR3; restart vẫn giữ. Rebuild có2session, original có1sessionRow; không so số recovery giữa hai dataset như một bug UI.
- Audit onboarding nhánh nhập tay qua Home; plan/cam kết giữ2giây/Pro demo; đổi beginner; rename/type gym trả lại Phòng gym; chặn xóa gym cuối. 31 rồi44 model checks là mốc cũ, hiện48.
- Nghiên cứu Fitbod, US competitor landscape, Reddit/app-store pain points, retention trong research/2026-11-09, có nguồn và giới hạn mẫu. Remotion public chỉ là framework, chưa có source/media riêng Dopafit.

## Mẫu ghi tiếp

Thêm mục ngày/lượt mới ở đầu: yêu cầu → phát hiện original (D/R ID) → source thay đổi → build/model/UI/ảnh đã kiểm chứng → dữ liệu test đã đổi và khôi phục → gap còn mở/blocker. Cập nhật SCREEN-COVERAGE và HANDOFF cùng lúc. Không xóa lịch sử để làm trạng thái trông hoàn chỉnh hơn.


Bằng chứng ảnh nguồn cuối: C141 toàn thân ngang; C142 vận động; C143 hai ảnh core; C144 core14 thấy tư thế; C145 Kegel/giãn cơ; C146 giãn cơ chi tiết. C147 Home phân cấp Add/Start/tab. Tất cả là ảnh rebuild cục bộ, không thêm vào bảng Figma original.
