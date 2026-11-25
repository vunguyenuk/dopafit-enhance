> Latest25/11 review: màn cuối có18đáp án hiện có, sửa trong draft sheet / Apply / Cancel, regenerate preview và final localSave. C408–C417; main installed/fullJSON unchanged. Current V2 review gap covered for collected answers; original gear/sports/acquisition/4week/Health onboarding still missing. Measurement endpoint dates visible at sampled smallphone. See ../rebuild/verification/v2-review-2026-11-25/ui-run.json; not fullparity/all18editor certification.

> Latest25/11 15:22: main installed with4tabs, results/recoverydetail,weeklygoals,journal/report/milestones/manualbodymeasurement/profile. Original Mirroring review left unsaved per user. See `../rebuild/verification/v2-progress-journal-2026-11-25/ui-run.json`. Health status/manual entry now exist, but real Health integration and onboarding permission/privacy flow remain incomplete. dSTRENGTH unknown; no fabricated score/calories. Loading now runs4local stages; comparison collapses matching cells/maintain and uses chosen sex/current/target.179onboarding+37progress checks, samplednativeUI separately. FullmainJSON/oldRebuildJSON preserved; no fullparity claim.

> Final25/11 10:26: prior unlock/maininstall pending status superseded. C285–303 native experiencecalendar/jointglyph/reward/6contextphotos/Potential/calendar sampled,64Blenderflipframes and native up/down recording added. Main finalinstalled noreset/demo; JSON semanticallyequal freshbefore/after/final; QA0historyremoved. Originalaudit reachedreviewunsaved, temporaryanswersremain; noHealth/auth/purchase/reset. FullboardHTML embedded/Chrome readback; no full2kboardPNG. UI/allbranch/accessibility/service gaps remain. See rebuild/verification/v2-onboarding-polish-2026-11-25/ui-run.json.

> 25/11 polish: BUILD SUCCEEDED +74V2model/routechecks;11newassets source=bundle. Nativecalendar/icon/photocrop/Potential/reward QA and maininstall pendingMacunlock. Originalaudit reachedgoal, nextstateunobserved, noHealth/purchase/save/reset. Detailed checkpoint: rebuild/verification/v2-onboarding-polish-2026-11-25/ui-run.json. Existing service/coverage gaps remain; removedintensity is intentional.

> Latest25/11 08:32: new first sex question; body actor realism/crop corrected; current-body and belly combined per user,5facefree choices. Actual selected current supplies comparison left. Experience uses time badges; selected radios have ticks. Build passed,73V2checks, C259–284 sampleUI. FullmainJSON preserved; QA removed. Previous pending-unlock checkpoint below is superseded.
>
> Audit: requested focus/frequency/injuries and Proplans→gift→offer/commitment/2charts exist (native routes sampled). Missing: **Healthprivacy+connect/manual**, individual equipment, other sports/detail, full all-answer edit review, acquisition question/exact past4week frequency. Intro/story functions partly consolidated, not one-to-one original parity. User-removed age/height/duplicate belly stay removed. See ../rebuild/verification/v2-physique-2026-11-25/coverage-audit.json for evidence levels. UI Pro is localdemo, not StoreKit; originalPhoneMirroring was sampled only at initial4steps and returnedwelcome without completion.

> Latest25/11/2026: user now explicitly requested an expanded onboarding and the3-page Pro/gift/year-offer sequence. The historical “6steps/no countdown/no before-after” choices below are superseded only by this new scope. Body illustrations are labelled fictionalAI, not client results. The countdown is a persisted local demo deadline, expired CTA disabled; no StoreKit or purchase. New source tests53pass and C226–C258 sampleUI are recorded separately in ../rebuild/V2-DESIGN-COVERAGE.json. Main install/data check passed; final new goal/focus/Settings/main UI awaits manualMacunlock at checkpoint. Consult latest HANDOFF/ui-run before claiming complete.

> Cập nhật 24/11/2026: mục hướng B/ảnh đen trắng bên dưới là lịch sử, đã được thay bằng dark-only/natural-color photo theo user. Xem DESIGN.md, PHOTO-SOURCES.json và ../rebuild/V2-DESIGN-COVERAGE.json cho hướng hiện tại. Các giới hạn service/model cũ vẫn mở; không dùng audit19/11 để khẳng định kiểm chứng mới.

# Dopafit V2 — audit 2 app và những gì bản mới giữ / sửa

Ngày 19/11/2026. So sánh:
- **App chính**: bản build master 8e8ebea9 (chạy trên iPhone qua iPhone Mirroring), review đầy đủ 96 màn ở https://claude.ai/artifact/57MCRs6cBCJ1nTHfVEeLhQ
- **App cũ**: DopafitRebuild (bundle `com.local.dopafit.rebuild`, chạy trên simulator)
- **Bản mới**: DopafitV2 (bundle `com.local.dopafit.v2`), project riêng, không đụng 2 app trên.

Hướng hình: **B — ảnh đen trắng, con số làm điểm nhấn**. Giao diện tiếng Việt.

## Giữ lại từ app chính
| Điểm hay | Trong V2 |
|---|---|
| Tự điền tạ sang set sau (#070) | Đánh dấu xong set → các set sau chưa sửa nhận cùng tạ và rep |
| Tính bánh tạ mỗi bên (#071) | Nút "Tính bánh tạ" ở bài tạ đòn, theo kg hoặc lb |
| Hộp "Bỏ buổi tập này?" rõ hậu quả (#074) | Giữ, dùng một kiểu hộp thoại cho mọi xác nhận |
| Menu một bài gom đủ việc (#061) | Menu ⋯: hướng dẫn & lịch sử, đổi bài, bỏ khỏi buổi |
| Ghi rõ giá và ngày tính phí (#045, #050) | Màn Pro ghi giá, dùng thử 3 ngày, nhắc trước khi tính phí |
| Màn trống có hướng dẫn (#063) | Mọi danh sách trống đều có câu hướng dẫn |
| Thông báo ghi rõ khi nào nhắc (#096) | Cài đặt > Thông báo |
| Có xóa dữ liệu (#097) | Cài đặt > Xóa toàn bộ dữ liệu |

## Giữ lại từ app cũ (DopafitRebuild)
- "Hôm nay thế nào?": mệt / đau một chỗ / ít thời gian, hoàn tác được, bài thay đổi có vạch xanh và ghi lý do.
- Một dòng lý do dưới tên buổi (vì sao tăng/giữ tạ).
- "Máy đang có người": đổi sang bài cùng nhóm cơ, ưu tiên dụng cụ khác.
- Quay lại sau ≥14 ngày nghỉ: tạ giảm 20%. Nghỉ 3–13 ngày: gợi ý bản 20 phút.
- Hướng dẫn chuẩn bị máy/ghế cho lần đầu tập bài, lỗi hay gặp.
- Chế độ nhẹ nhàng, cỡ chữ 3 mức, kg/lb, tập ở nhà.
- Lịch tuần gọn, lịch tháng ở Nhật ký.

## Sửa những lỗi cả hai app đang có
| Vấn đề | Cách V2 xử lý |
|---|---|
| Thiết lập ~37 màn, hỏi lặp (#005 vs #011–014, #006, #007, #025–027) | 6 bước, mỗi câu hỏi một lần, chỉ hỏi điều app dùng tới |
| Thiếu lựa chọn "trên 2 năm" (#008) | Có lại |
| 66 dụng cụ chọn sẵn (#030) | Chọn nơi tập: gym đầy đủ / gym nhỏ / ở nhà |
| "722 dSTRENGTH", Đẩy 17 vs Chân 1.708 (#078) | Một con số dễ hiểu: "ước tính nâng được X kg × 1 lần" |
| Số vô lý 6.060 kg, trục "2,0E7" (#089–#094) | Giới hạn nhập 0–400 kg, 1–100 rep, cảnh báo khi tạ cao gấp rưỡi lần trước; trục biểu đồ bám dữ liệu |
| Dấu thập phân lẫn lộn, kg lẫn lb (#079, #092) | Một kiểu: phẩy thập phân, chấm hàng nghìn; mọi chỗ theo đơn vị đã chọn |
| Nút nổi/thanh tab che nội dung (#051, #062, #084) | Nút đáy đặt trong vùng an toàn, nội dung được đẩy lên |
| Nội dung chạy dưới giờ/pin (#052, #088) | Có nền che thanh trạng thái |
| Paywall 2 + đếm ngược 15 phút (#049–#050) | Một màn Pro, nút X hiện ngay, thấy cả 2 gói, không đếm ngược |
| Vân tay ở lời hứa (#043), ảnh trước/sau (#039) | Bỏ |
| Màu nhiều nghĩa (#086): cam vừa "cần nghỉ" vừa tô cơ, đỏ, sọc xanh dương | Mỗi màu một nghĩa: xanh chanh = hành động/con số chính, tím nhạt = đang hồi phục, vàng cam = cảnh báo |
| Trộn 4–5 kiểu hình (nhân vật vẽ, hình nộm 3D, ảnh thật, đồ vật 3D) | Ảnh thật luôn đen trắng; video động tác đen trắng; sơ đồ cơ phẳng 2 màu (không còn hình nộm 3D tô cam kiểu Fitbod) |
| 4 tab, Mục tiêu tách rời | 3 tab: Buổi tập, Tiến bộ (hồi phục, sức mạnh, tuần này), Nhật ký |
| "Seed", tên tiếng Anh lẫn (#040, #089) | Toàn bộ tên bài tiếng Việt, tên tiếng Anh chỉ là dòng phụ |

## Còn thiếu / cần lưu ý
- Video 3D (`*-guide.mp4`, `*-thumb.mp4`) **chưa có bản quyền thương mại**, chỉ dùng demo. Clip ExerciseDB độ phân giải thấp.
- Sơ đồ cơ thể: react-native-body-highlighter 3.2.0 (MIT).
- Ảnh: Unsplash/Pexels, nguồn ở `third_party/challenge-photos/manifest.json` của repo.
- Chưa có: đăng nhập thật, thanh toán thật, đồng bộ, Apple Health, thông báo thật (công tắc chỉ là giao diện).
- Luật tập (tăng tạ, hồi phục, đau) là luật đơn giản tự viết, cần người có chuyên môn xem lại.

## Chạy
Mở `DopafitV2.xcodeproj`, chọn iPhone 18 Pro Max, bấm Run. Thêm file Swift mới vào thư mục `DopafitV2/` là Xcode tự nhận.
Tham số chạy: `--reset` xoá dữ liệu, `--demo` nạp 12 buổi tập mẫu (khi chưa có lịch sử).
