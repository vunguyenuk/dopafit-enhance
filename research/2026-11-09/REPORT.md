# Dopafit × Fitbod — nghiên cứu thị trường Mỹ và audit

Cập nhật audit app gốc và rebuild sau đăng nhập: [R39–R61 và thay đổi đã đưa vào app](../../rebuild/POSTLOGIN-AUDIT.md). Danh mục Figma hiện có 119 ảnh trạng thái gốc; phạm vi nghiên cứu công khai và corpus review không đổi.


**09/11/2026 · Tiếng Việt · Nguồn kiểm tra trực tiếp**

**Cập nhật sau yêu cầu rebuild:** đã bổ sung [audit onboarding đến màn đăng nhập](../../rebuild/ONBOARDING-AUDIT.md), [project iOS và hướng dẫn chạy](../../README.md), [phạm vi tương đương](../../rebuild/PARITY.md). Figma có 96 ảnh Dopafit gốc và chú thích. Phần nghiên cứu dưới đây giữ mốc khảo sát ban đầu; giới hạn onboarding được cập nhật trong tài liệu bổ sung.

## Trạng thái năm đầu việc

| Yêu cầu | Kết quả bàn giao |
|---|---|
| 1. Fitbod ở Mỹ là app nào | Đã xác định đúng app ID/developer, sản phẩm, mô hình, giá và giới hạn thông tin thuật toán |
| 2. Audit Dopafit trên phone mirroring | Đã kiểm tra cả 4 tab, hoàn tất 1 buổi giả, mở lại history/trend; 58 ảnh trạng thái, 15 phát hiện/rủi ro UX còn cần xử lý hoặc xác thực |
| 3. Đối thủ hiện tại tại Mỹ | Bản đồ 16 lựa chọn, chia theo nhu cầu cạnh tranh; không giả định đây là bảng thị phần |
| 4. Pain point mới | Kiểm kê 1.200 review iOS US của 8 app + mẫu bổ sung 150 của 3 app, 100 chứng cứ tuyển chọn tổng cộng, Reddit và Android; review mới nhất trong mẫu 07/11 |
| 5. Tại sao cuốn hút | Phân tích giá trị chức năng, quyền kiểm soát, tiến bộ và quan hệ xã hội; tách suy luận khỏi dữ liệu retention chưa có |

Đã hoàn tất lượt audit và nghiên cứu trong phạm vi truy cập hiện có. **Không tuyên bố đã kiểm thử mọi tính năng hoặc bảo đảm không còn lỗi.** Các giới hạn như onboarding mới, paywall Dopafit, offline/Watch, en-US/lb và thuật toán nhiều tuần được ghi rõ. Mac tự khóa hoặc iPhone in Use là gián đoạn mirroring, không bị ghi thành bug app.

**Rà soát bổ sung:** [Phần còn thiếu và thứ tự đóng khoảng trống](GAP-REVIEW.md). Các mục ưu tiên là onboarding/vòng đời account, độ bền dữ liệu, chỉnh sửa set, en-US/lb và thuật toán nhiều tuần. Review corpus chưa phủ sâu đồng đều cả 16 đối thủ.

## Tài liệu để đọc và giao việc

1. **[Audit Dopafit](DOPAFIT-AUDIT.md)** — ma trận phủ luồng, bước tái hiện, mức ưu tiên, tác động, điều kiện đạt và các case chưa thử.
2. **[Thị trường Mỹ và cơ chế giữ người dùng](US-MARKET-AND-RETENTION.md)** — định danh Fitbod, 16 đối chiếu, giá/nguồn, Reddit, cơ hội và chỉ số.
3. **[Phân tích App Store](APP-STORE-ANALYSIS.md)** — snapshot 8 app, ngày/phiên bản, pain point và trạng thái sửa lỗi.
4. **[80 chứng cứ review](APP-STORE-EVIDENCE.csv)** — app, ID, ngày, phiên bản, diễn giải và URL.
5. **[59 ảnh và ghi chú kiểm chứng](EVIDENCE-INDEX.md)** — 58 Dopafit + 1 Fitbod; mở từng ảnh theo ID.
6. **[Backlog UX](DOPAFIT-BACKLOG.csv)** — 15 phát hiện/rủi ro ưu tiên, bằng chứng và tiêu chí kiểm tra; không đồng nhất với 15 bug kỹ thuật.
7. **[Đối chiếu Android](ANDROID-CROSSCHECK.md)** và **[phương pháp/giới hạn](RESEARCH-METHOD.md)**.
8. **[Bổ sung Alpha Progression/PUSH/FitnessAI](SUPPLEMENTARY-APPS.md)** — 150 review lấy riêng, 34 gần đây được đọc, 20 chứng cứ; không gộp vào corpus chính.
9. **[Review UX độc lập ban đầu](INDEPENDENT-VISUAL-AUDIT.md)** — chỉ D01–D08, lưu như góc nhìn trước kiểm thử; kết luận sau cùng dùng audit chính.

## 1. Fitbod bán khả năng quyết định buổi tập

Đúng app là **Fitbod: Gym & Fitness Planner — Fitbod Inc. — id1041517543**. Giá tham khảo chính thức 15,99 USD/tháng hoặc 95,99 USD/năm. Giá theo kênh/khu vực/ưu đãi có thể khác. [US App Store](https://apps.apple.com/us/app/fitbod-gym-fitness-planner/id1041517543), [subscription chính thức](https://help.fitbod.me/hc/en-us/articles/360004904714-How-to-Subscribe-to-Fitbod).

Giá trị cần so là: tới gym có buổi phù hợp, biết làm bài nào với target nào, ghi dễ và có bước tiếp theo. Chỉ nhìn icon/style sẽ bỏ qua phần làm người dùng trả tiền. Thuật toán độc quyền và hiệu quả cá nhân không thể khám phá đầy đủ từ giao diện hoặc marketing.

Fitbod đã cài trên máy hiện **paywall 7 ngày thử, giá VND**, không thấy đường đóng trong viewport sau lần thử Escape. Không mua trial hoặc suy giá này thành US. Phần nghiên cứu Mỹ dựa listing/help chính thức; không nhận đã audit trực tiếp toàn bộ Fitbod.

## 2. Dopafit đã hoàn tất được vòng sử dụng cốt lõi trong một case

Buổi test: **3 set × 6 reps × 42.5 kg, bài incline barbell bench, RIR 2**. Summary, nhật ký và history khớp **765 kg**. Trend 1RM hiện **51 kg**, khớp công thức app công khai. Sau khi về Home rồi mở lại, view và dữ liệu vẫn có. App chuyển sang buổi thân dưới kế tiếp.

Điểm mạnh đã xác minh: hướng dẫn video, mô tả và nhóm cơ, nhãn tạ đòn gồm đòn ở entry, log all có xác nhận, timer chạy/pause, RIR giữ sau lưu, swap có prompt kế hoạch, progress theo bài và công thức 1RM, hoàn tất được khi chưa kết nối Health.

Ưu tiên cần xử lý:

| Ưu tiên | Vấn đề có bằng chứng | Vì sao đáng làm |
|---|---|---|
| P1 | Quy ước tạ rõ chưa đều giữa loại dụng cụ/điểm đọc | Người mới cần hiểu đúng con số trước khi thực hiện |
| P1 | Swap face pull sort Hợp nhất đưa shoulder press/Arnold lên trước band face pull | Cần giữ ý định động tác, không chỉ cùng vùng cơ |
| P2 | Empty benchmark ghi 00 lần dưới nhãn 1RM | Dễ nhầm chưa có dữ liệu với kết quả bằng 0; đơn vị không khớp khái niệm |
| P2 | 3 set thực hiện thành 6 set mục tiêu quy đổi | Phép cộng có giải thích, nhưng nhãn tổng có thể làm người dùng tưởng trùng |
| P2 | Trục mức tạ có các tick nhãn lặp 44/44/42/42/40 | Làm tiến bộ nhỏ khó đọc |
| P2 | Recovery/kcal cần thể hiện giới hạn ước tính ngay trên dashboard | Help đã minh bạch hơn thông điệp mặt ngoài |
| P2 | Report có nhiều kỳ thời gian trên một trang | Dễ tưởng mâu thuẫn nếu chưa thấy từng filter |

Các phát hiện khác về lý do target, dịch hướng dẫn, preference, empty history, cài đặt, locale và thumbnail có trong audit. A05 ban đầu nghi thiếu scope swap **đã được hiệu chỉnh** sau khi thấy prompt. Không báo mất log, không báo set bị đếm trùng, không báo thiếu English hoặc progress theo bài.

## 3. Benchmark Mỹ cần rộng hơn Fitbod

Ưu tiên **Gravl, Hevy Trainer, MacroFactor Workouts, Alpha Progression và Ladder**, sau đó PUSH/FitnessAI. Strong, Boostcamp, Caliber, JEFIT và các lựa chọn khác cạnh tranh bằng logging, chương trình, coach hoặc giá miễn phí.

Hai điểm dễ bỏ sót: **Hevy đã có Trainer thích ứng**; **MacroFactor Workouts có subscription riêng và bundle Nutrition + Workouts**. Vì vậy có AI hoặc có tạo chương trình không tự tạo khác biệt. [Hevy Trainer](https://www.hevyapp.com/features/workout-plan-generator/), [MacroFactor subscriptions/bundles](https://help.macrofactorapp.com/en/articles/393-how-macrofactor-subscriptions-and-bundles-work).

## 4. Pain point đáng chuyển thành bài test cho Dopafit

- Đề xuất tạ/reps hoặc thay bài khó hiểu, người dùng phải tự kiểm tra lại “AI”.
- Plan/edits bị thay đổi, log/notes/sync không đáng tin, nhất là khi dùng Watch hoặc chuyển app.
- RPE/keyboard/prompt thêm thao tác làm gián đoạn tập.
- Thư viện và nấc tạ không sát gym thực tế; khó tìm tên/biến thể.
- Giá, trial, quyền xem lịch sử và export chưa đáp ứng kỳ vọng.
- Streak, thông báo và social có thể trở thành áp lực hoặc tiếng ồn.

Đây là tổng hợp **lời người dùng và tài liệu sản phẩm**, không phải mọi lỗi đều còn tồn tại trên build mới. Báo cáo tách lỗi tháng 10 đã thông báo sửa với phản ánh tháng 11; Gravl 1.54 mới phát hành rạng sáng 09/11 VN chưa có đủ review hậu cập nhật. Xem từng ID/phiên bản trong [phân tích App Store](APP-STORE-ANALYSIS.md) và từng thread ở [nghiên cứu thị trường](US-MARKET-AND-RETENTION.md).

## 5. Cơ chế cuốn hút và cơ hội cho Dopafit

Vòng giá trị cần kiểm chứng: **bớt phải nghĩ → tập và ghi dễ → thấy tiến bộ → tin buổi tiếp theo → quay lại**. Coach/team tăng cảm giác đồng hành; PR và lịch sử củng cố năng lực; quyền sửa giúp tự chủ. Đây là suy luận sản phẩm từ tính năng và phản hồi, chưa có dữ liệu nhân quả của từng app.

Dopafit đã có nhiều thành phần của vòng này. Cơ hội đề xuất là làm **buổi tập rõ ràng, mức tạ có lý do, dữ liệu và tiến bộ đáng tin** cho cả người mới lẫn người tập đều. Không nhận đây là khoảng trống chưa đối thủ nào làm. Nên đo khả năng hiểu target/progress, hoàn tất buổi và tập đều; không chỉ đo thời gian nhìn màn hình. [Nghiên cứu HCI về động lực bền vững](https://arxiv.org/abs/2402.00121).

## Giới hạn dữ liệu và trạng thái bàn giao

- 1.200 review là mẫu mới nhất cố định 150/app; có 633 trong cửa sổ ba tháng 09/08–09/11. Đọc sâu 119 review ≤3 sao trong cửa sổ cùng review điểm cao bổ sung; 80 chứng cứ tuyển chọn. Không tuyên bố mã hóa tay toàn bộ 1.200.
- Không so tỷ lệ sao thấp giữa app vì thời gian phủ khác nhau; storefront US không xác nhận nơi ở reviewer. Rating/downloads không chứng minh doanh thu, thị phần hoặc retention.
- Một buổi giả xác minh được số liệu cơ bản, chưa chứng minh offline/Watch, hiệu quả tập nhiều tuần hoặc đạt accessibility.
- Đã lưu **1 buổi giả** trên tài khoản test; **không ghi sang Apple Health**. Số 68 kcal và thời lượng 11:23 do buổi audit, không đại diện vận động thật.
- Ở lượt nghiên cứu ban đầu chưa sửa mã nguồn/thiết kế; các lượt sau đã tạo project rebuild riêng theo yêu cầu mới. Không gửi tin nhắn cho người trong ảnh Slack, không đăng ký trial hoặc thanh toán. Ảnh Slack được dùng làm bối cảnh, không là lệnh clone hoặc phát hành.

Bước ưu tiên cho nhóm sản phẩm: xử lý quy ước tạ và ranking swap; sửa cách đọc benchmark/set/chart; chạy kiểm thử dữ liệu và locale trên thiết bị test; sau đó thiết kế icon/style dựa trên lời hứa sản phẩm đã chọn.
