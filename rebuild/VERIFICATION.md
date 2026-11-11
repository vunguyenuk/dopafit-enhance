# Kiểm thử bản rebuild

09/11/2026. Xcode 27.3 (27C5020n), iPhone 18 Pro Max simulator, iOS 27.3. Log build: `rebuild/build.log`. Log model: `rebuild/model-checks.log`.

## Kiểm chứng các lượt nền tảng (mốc cũ)

Số model/ảnh dưới đây là lịch sử; trạng thái mới nhất ở cuối tài liệu và CHANGELOG.md.

## Đã kiểm chứng

- Build Debug cho simulator thành công; cài và launch app thực tế. Project mở trong Xcode và chọn đúng máy ảo.
- 31 kiểm tra model qua script (20 nền tảng + 11 bổ sung): start/resume, chặn tạ đòn bằng 0, undo, log all, 765 kg volume, draft reload, finish giữ set đã tập, RIR 2, 1RM 51 kg, không nhân đôi buổi, history reload, đóng góp cơ chính/phụ, CSV, đổi đơn vị, loại bài khỏi plan, warmup, tăng tạ cục bộ, profile/answers reload và đọc state cũ sau bổ sung trường. Kiểm tra mới: plan beginner, 12×30, volume hai bên 720 kg / 1RM mỗi tay theo mô hình, RIR sau lưu/reload/giới hạn, CSV multiplier, chặn xóa gym cuối, rename trim/reload/blank và xóa gym phụ đang chọn.
- UI: bắt đầu buổi → mở incline barbell → ghi set → nghỉ 2 phút → pause/resume → xác nhận log all → chọn RIR 2 → kết thúc/lưu → summary 765 kg → nhật ký một buổi → mở lại buổi thấy 3 × 6 × 42,5 và RIR 2.
- Cài đè và khởi động lại vẫn giữ buổi thử. Ảnh chụp state trước đó ở `verification/persisted-state-summary.json` có một buổi 765 kg/RIR 2. State mới ở `verification/persisted-postlogin-summary.json` có hai buổi: Incline 765 kg (đã sửa RIR 2→3 bằng UI) và Row 720 kg/RIR 3; bản nháp thân dưới chưa ghi set. Đổi lb hiển thị 42,5 kg thành 93,7 lb; tổng 765 kg thành 1686,5 lb.
- Điều hướng kế hoạch và menu đơn vị hoạt động bằng native controls.
- UI onboarding nhánh nhập tay đi xuyên R19 → quyền riêng tư → Health/Tự nhập → tuổi → giới tính → số đo → focus → gym/dụng cụ → 3 buổi → 60 phút → Để sau → Không có hoạt động khác → xem lại → màn đăng nhập → Dùng bản thử cục bộ → Home. Kéo thước đã đổi 170 thành 168 cm. Nút Apple trong rebuild mở thông báo chưa kết nối dịch vụ, không chạy SSO thật.
- UI bổ sung: Plan đã xong → giữ hơn 2 giây → Pro intro → Xem gói → Tiếp tục bản thử → Home. Đổi experience Mới bắt đầu, sinh lại upper, thấy 7 bài theo mẫu; ghi một set Row 12×30 → finish/summary 720 kg. Sửa RIR buổi Incline từ 2→3, đóng rồi mở lại vẫn 3. Buổi Row cũng lưu RIR 3; đã terminate/launch rồi mở lại trên UI vẫn 720 kg và RIR 3, khớp JSON.
- Gym UI: Xóa disabled khi chỉ có một nơi; đổi tên sang Gym test và loại Phòng tập nhỏ, kiểm tra UI và JSON; sau thử đã trả tên/loại Phòng gym. Không xóa gym qua UI; ràng buộc xóa được kiểm bằng model.
- Figma kiểm chứng: 119 image fills, 119 card gắn ID, 22 root groups, không trùng ID, không font thiếu. Render các nhóm R01–R06, R31–R36, R39–R44 và R57–R61; lưu PNG vào `figma/verification-*.png`. Đã sửa R42 từ Home thành guide, nối R38 tới R39 sau khi người dùng đăng nhập. Bảy dẫn chiếu liên quan R42 đã sửa qua desktop và đọc lại khớp 7/7 (`figma/completed-flow-corrections.json`).

## Chưa đủ để kết luận

Build thành công và model checks không chứng minh từng view đều giống gốc hoặc toàn bộ feature chạy đúng. Không có UI automation suite hay golden screenshot comparison toàn bộ 125 trạng thái. Chưa test mọi option, Health quyền thật, thông báo đến hạn, offline/crash recovery, đăng nhập/mua gói, Watch, accessibility, performance, locale English đầy đủ và nhiều tuần dữ liệu.

`rebuild/verification/B*.png` là bằng chứng bản rebuild, chỉ lưu cục bộ; không nằm trong Figma ảnh gốc. Ảnh gốc ở `research/2026-11-09/evidence/D*.png` và `rebuild/audit/R*.png`.


## Lượt sửa sau phản ánh thiếu UI trên simulator

Build Debug thành công với các view/luồng mới; 44 model checks đạt. Những kiểm chứng UI phía trên thuộc build trước. Các thay đổi hiện tại gồm stack/tab bar, guide, metric detail, body/goals, saved-set editing, library sort/template và warmup rest; đang chờ retest UI vì Mac tự khóa. Không coi build/model checks là đã xác nhận layout/tap-through của các view mới. Danh sách case và phần còn thiếu ở SIMULATOR-GAP-FIXES.md.

## Kiểm chứng mới nhất — sau live recheck R62–R67

- Debug simulator build thành công sau sửa VStack/tab bar và History PillTabs, cài và launch thực tế; `rebuild/build.log` có BUILD SUCCEEDED. 48 model checks đạt ở `rebuild/model-checks.log`.
- Guide: bấm Cách tập/Nhóm cơ/Dụng cụ; đổi Journal rồi quay Workout giữ guide; thanh tab còn hiện (C01/C02).
- Saved Row: sửa12→10 reps, save thấy600kg; trả12 reps, save/reopen thấy720kg. RIR3 giữ nguyên (C03).
- Body: mở Results empty benchmark; Recovery list và chest detail; nút xoay đổi ảnh trước/sau (C04–C06/C08). Hình cơ vẫn là ảnh tĩnh, không phải màu động từ dữ liệu. Recovery editor hiện10slider và Save disabled khi chưa đổi. Sau sửa container, Save hiện phía trên thanh tab; không còn bị che. Chưa lưu được evidenceC10 trước khi Mac khóa.
- Goals: nhóm đẩy mở rộng với target/còn lại; dữ liệu local7,5/65=11%, push6/27 (C07). Chưa xác minh target kéo/chân gốc.
- Saved exercise menu→History: sheet đóng và chuyển full-page, không còn nhốt nội dung trong half-sheet. Trends có ba metrics;1RM Row42kg; Tuần/Tháng/6tháng/Năm đổi range; đổi sang Cơ thể rồi quay Nhật ký vẫn ở1RM và kỳNăm (C09).
- 125original cards/125image fills/23roots được đọc lại qua Figma connector, không trùng ID. NhómR62–R67 ở3040,19950;6card nội bộ đúng grid. `figma/verification-125.json` và `figma/verification-R62-R67.png`. 7flow corrections cũ giữ nguyên.
- Script coverage kiểm đủ125ID, source/ảnh/evidence paths tồn tại, mỗiID có Figma node và entries/exit/purpose/primary-secondary/dependencies. Tất cả dòng vẫn partial, pixel parity chưa xác nhận.

### Chưa kiểm UI đầy đủ

Slider AX setValue chỉ thay giá trị control, không kích hoạt SwiftUI binding/Save; không dùng đó để kết luận Save hoạt động. Model kiểm bounds/persistence/expiry/exclusion đã đạt. Cần thao tác kéo thật và testSave/cancel/reopen; original cũng mới quan sát editor chưaSave. Các mục library phối hợpsort/search/gear, savedadd/cancel, timer main/warmup và chart point selection vẫn mởG11/G12. Mac tự khóa khi bước kiểm tiếp đang bắt đầu; không tự mở khóa hoặc sửa security.

Không có kiểm thử tự động UI toàn bộ. 48 model checks không phải48screen tests. Media/engine/services và pixel comparison còn thiếu xem OPEN-GAPS.md. Mốc44checks/chờretest ở đoạn lịch sử đã được cập nhật bởi mục này.

## Bổ sung R68–R71

Build Debug cuối thành công;52model checks đạt. UI đã thấy6cơ phụ và headerpin; durationRow28giây→1phút save/reopen, chọn2phút rồiClose vẫn1phút; volume720/RIR3giữ. UI search dumbbellrow + sortTập nhiều nhất + gearTạđòn→empty, Cặp tạđơn→Row; chọnRow rồiClose editor không thêm vào session. Calendar toggle cả tháng/tuần và past/future màu đã xem lại(C14); month navigation chưa xác minh. Figma129original cards/images/25roots không trùngID. Chưa UI-test sliderSave, secondaryeditor, timer main/warmup, chartpoint hoặc mọi tổ hợp sort/gear.

## Kiểm chứng asset muscular mới — mốc cuối09/11/2026

52modelchecks đạt; Debug build/cài/launch thành công sau thay4GLB, native thumbnail/4góc và WebKit fallback. Asset integrity đạt, JS syntax/bundle đạt. Mesh QA toàn bộ214frame finite/bounds/edge, maxedge0.0849m;9render pose từ trước/bên/sau và neutral2góc đã xem. Chi tiết hash/report/giới hạn ở OPENGYM-INTEGRATION.md. Đây là kiểm offline và build, chưa là UI pass muscular. Mac đang khóa; C15–C22 vẫn là v1mannequin cũ. Các muscular-*.png là Blender render, tuyệt đối không gắn nhãn screenshot simulator.

## 10/11/2026 — UI muscular và R72

C23–C32 ghi model muscular trên simulator: trước/sau/list10+6cơ; RDLgóc1/2/3,1×/0,5× và đổi tab; Goodmorninggóc2/1×; Curlgóc2/4,1×/2×. Không thấy crash hoặc biến dạng lớn trong những case này; không phải toàn bộ tổ hợp. Temporarycurl được thêm rồi xóa, không log; draft/history giữ.

R72original discard dialog đã chụp, bấm Tập tiếp và giữ buổi7giờ. Figma130cards/130images/26roots, không duplicate; root46:2 vàcard46:6, renderđã xem. RebuildXcóalert, thêmdiscardWorkoutvà4testtrongstoretạm;56/56đạt. Đã thêmloadingmodelplaceholder để không đen lúc clipchưa ready; build/cài/launchđạt. UI alert/cancel/loading/error mới chưa retest doMac khóa lại. Không dùng screenshotmedia trước thayplaceholder làm chứng cứ nhánhloading.

## Lượt tiếp10/11 — C33–C40, active superset, pending original rollback

C33 X→alert→Tập tiếp giữtimer/6set; C35loadingbody→C34clipready; C36iOSHome→return giữguide/clip. C37active menu chỉGhép; C38/C39Lưu disabled ở0/1; C40Lưu enabled ở2; Hủy giữ draft.61modelchecks đạt (thêm5superset/group/reorder/persist/orphan cases), build/cài/launch mới đạt. Savehelper dùng chungHome/Active, không đổi globalplan toggle; R77quan sát trong tool chứng minh1+3phải gom cạnh nhau. Ruleanchorvị tríđầu vàsốvòngkhiunequal vẫnlocal/unverified. Groupheader/reorder vừa đổi source chưa UI test.

Figma134cards/134images/27roots, root49:2 ở6080,22800, cards49:6/29/53/75. Renderđã xem sau cập nhậtannotationR76sangSavecase mới. R77attemptedcapturefailedMaclock, không cófile, không upload/rộngcount. Nhóm thử originalRow+Shoulder đang còn, cần tháo/restoreorder khi mởkhóa; xemHANDOFF đầu. Không logset/finishsession gốc.

CUA phục hồi sau dọn cacheproject+DMGBlender tạm (ổ144MiB→741MiBtrống). Source.blend/GLB giữ; addon có sẵn nhưng Blender4.5mount đã tháo, muốn regenerate tải lạiofficialDMG. Không test lại số liệu/chức năng đã đạt nếu không có thay đổi liên quan.
