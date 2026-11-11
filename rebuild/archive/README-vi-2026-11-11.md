# Dopafit — audit bản gốc và iOS rebuild

Ngày đối chiếu: 09/11/2026. Người dùng mục tiêu: cả người mới và người tập gym đều.

Project SwiftUI chạy cục bộ, dựng lại các màn và tác vụ đã quan sát từ Dopafit. Đây là bản tái dựng để đối chiếu và tiếp tục phát triển; chưa đạt tương đương hoàn toàn với app gốc. Không có source/backend, thư viện media hay thuật toán độc quyền của Dopafit.

## Tiếp tục bằng tài khoản Codex khác

Đọc [AGENTS.md](AGENTS.md), [changelog](CHANGELOG.md), [bàn giao](rebuild/HANDOFF.md), [đối chiếu từng màn](rebuild/SCREEN-COVERAGE.md) và [các khoảng trống](rebuild/OPEN-GAPS.md). Matrix có 134trạng thái gốc/Figma/source/evidence; chưa có trạng thái nào được gán pixel parity hoàn chỉnh.

## Mở và chạy

Mở `Dopafit.xcodeproj`, chọn scheme **Dopafit**, destination **iPhone 18 Pro Max**, rồi Run. Project đã được mở trong Xcode trên máy này và đã cài lên simulator iOS 27.3.

```sh
./scripts/run-simulator.sh
./scripts/check-models.sh
```

Hai script dùng Xcode tại `/Users/vunguyen/Desktop/Xcode-beta.app`. Có thể đổi qua biến `DOPAFIT_XCODE`; script không đổi `xcode-select` toàn máy. `DOPAFIT_SIMULATOR` đặt UDID khác. Không cần package bên ngoài.

Launch argument `--demo` vào thẳng bốn tab và giữ lịch sử. `--audit-setup` mở từ phần onboarding R19; `--audit-post-setup` mở chuỗi plan/cam kết/Pro để kiểm thử; không xóa lịch sử. Chạy không argument để dùng trạng thái đã lưu. Trong Cài đặt có **Xem lại thiết lập**.

## Tài liệu và Figma

- [Figma — ảnh Dopafit gốc và chú thích](https://www.figma.com/design/2lNpfPEq2wVnGk07bVLghz/Dopafit?node-id=1-24): 134ảnh trạng thái đã nhập; 58 ảnh D01–D58 và 76ảnh R01–R76. Ảnh giữ nguyên; tên, mục đích, luồng, yếu tố chính/phụ và phụ thuộc là text sửa được. Không có ảnh rebuild hoặc Fitbod trong canvas này.
- [Danh mục nguồn ảnh](figma/complete-inventory.json), [kiểm chứng canvas](figma/published-verification.json).
- [Nghiên cứu Fitbod, thị trường Mỹ, đối thủ và pain point](research/2026-11-09/REPORT.md).
- [Audit bốn tab và vòng tập](research/2026-11-09/DOPAFIT-AUDIT.md).
- [Audit onboarding bổ sung](rebuild/ONBOARDING-AUDIT.md).
- [Audit sau đăng nhập và phần mới bổ sung vào app](rebuild/POSTLOGIN-AUDIT.md).
- [Rà soát và sửa các UI/chức năng thiếu trên simulator](rebuild/SIMULATOR-GAP-FIXES.md).
- [Phạm vi tương đương và phần còn thiếu](rebuild/PARITY.md).
- [Kiểm thử](rebuild/VERIFICATION.md).

## Cấu trúc

| File | Vai trò |
|---|---|
| `Models.swift` | Set, buổi tập, kế hoạch, gym, lịch sử, JSON persistence, quy tắc sinh buổi cục bộ |
| `Design.swift` | Màu, nút, card, hàng cài đặt, vùng ảnh tham chiếu, CSV |
| `OnboardingView.swift` | Chào, mục tiêu, câu hỏi, pain point và câu chuyện R01–R18 |
| `SetupOnboardingView.swift` | Hồ sơ nhập tay, focus, nơi tập, lịch, nhắc nhở, xem lại và đăng nhập entry R19–R38 |
| `PostSetupFlow.swift` | Plan đã xong, giữ để hứa 2 giây, Pro introduction tham chiếu |
| `WorkoutViews.swift` | Home, tập, nhập set, timer, RIR, đổi bài, guide, superset |
| `ProgressViews.swift` | Nhật ký, chi tiết buổi, lịch sử bài, trend và report |
| `OpenGymBody.swift` / `OpenGymAnimationView.swift` | Mesh cơ thể, thumbnail SceneKit, chuyển động offline WKWebView/Three.js |
| `ExerciseGuide.swift` | Ba tab Cách tập/Nhóm cơ/Dụng cụ, media/speed hook |
| `BodyAndGoalsViews.swift` | Kết quả, hồi phục/list/chi tiết cơ và mục tiêu ba nhóm màu |
| `MetricDetailView.swift` | Biểu đồ có ngày thật, chọn điểm, khoảng thời gian, PR/trung bình |
| `SavedSetEditor.swift` | Thêm/sửa/xóa set và bài trong buổi đã lưu |
| `SettingsViews.swift` | Plan, gym/nấc tạ, hồ sơ, export, locale, notification/Health entry |

## Dữ liệu và media

State lưu dưới Application Support/DopafitRebuild/state.json trong sandbox app, sau mỗi thay đổi quan trọng, bằng ghi atomic. Cài đè build giữ dữ liệu. Xuất CSV dùng kg làm đơn vị dữ liệu chuẩn; UI có kg/lb.

Bộ cơ thể/thumbnail/preview hiện dùng model nam có cơ dựng bằng MakeHuman/MPFB trên nền tảng OpenGym3D theo yêu cầu người dùng. Ba clip v1 được retarget đúng mapping (curl/RDL/good morning), phát offline bằng Three.js trong WKWebView, có4góc và tốc độ;24bài còn lại có minh họa nhóm cơ. Đây là asset thay thế, không phải mesh/video private của Dopafit. Một số narrative/chart/Pro/location illustration vẫn là ảnh tham chiếu. Xem [nguồn asset](rebuild/ASSET-PROVENANCE.md) và [trạng thái tích hợp/QA](rebuild/OPENGYM-INTEGRATION.md).

`python3 scripts/check-opengym-assets.py` kiểm SHA, GLB geometry/weights/animation và notices. `./scripts/build-opengym-viewer.sh` chỉ cần khi sửa viewer; dependency npm được pin, JS đã bundle sẵn để app chạy offline. `python3 scripts/prepare_opengym_assets.py` chỉ stage upstream vào.build, không ghi đè model cơ bắp. Source Blender được giữ trong third_party để chỉnh tiếp. Original Figma không chứa screenshot simulator.

Remotion public là framework video, không cung cấp riêng source/media Dopafit. AVPlayer hook vẫn nhận MP4 riêng nếu được cấp và thêm vào target resources. Project generator tự bundle Swift, Assets.xcassets và thư mục OpenGym3D.

Các phép sinh buổi, tăng tạ, hồi phục và kcal là mô hình cục bộ được ghi rõ trong source/tài liệu, không phải thuật toán gốc được trích xuất. Không có cloud sync, đăng nhập thật, subscription, Apple Watch hoặc Health workout writing trong bản này.
