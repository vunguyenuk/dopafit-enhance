# Phân tích phản hồi App Store Mỹ — Dopafit competitive research

Ngày nghiên cứu: 09/11/2026, múi giờ Việt Nam. Đây là phân tích nguồn công khai, độc lập với audit giao diện Dopafit trên thiết bị.

## Kết luận sử dụng ngay

Người dùng trả tiền chủ yếu để **bớt phải quyết định, dễ làm đúng và nhìn thấy mình tiến bộ**. Điểm đứt gãy mạnh nhất là app lại buộc họ tự sửa kế hoạch, nhập lại dữ liệu hoặc kiểm tra xem set có được lưu thật không. Thêm AI, social hay animation chỉ hữu ích khi không làm chậm vòng lặp tập chính.

Ba nhóm cơ hội cho Dopafit có bằng chứng cụ thể trong mẫu:

1. **Sự tin cậy trong buổi tập:** lưu từng set chắc chắn; khôi phục khi chuyển app; đồng bộ Watch có trạng thái rõ; không thay kế hoạch đã chỉnh một cách khó hiểu.
2. **Tính thực tế của gym:** tìm theo tên gọi khác nhau; đúng thiết bị, bước nhảy mức tạ và loại thanh; đổi bài khi máy bận; không bắt người tập di chuyển qua lại một trạm.
3. **Tự chủ cùng giải thích:** biết tại sao mức tạ thay đổi, khi nào app học từ điều chỉnh, khi nào chỉ đổi một buổi; xem tiến bộ riêng từng bài; buổi quay lại sau thời gian nghỉ phải dễ hiểu.

Đây là các giả thuyết sản phẩm để xác thực, không phải bằng chứng rằng Dopafit hiện đã làm kém những mục đó.

## Phương pháp và giới hạn

- Nguồn: Apple US RSS `customerreviews`, ba trang theo `mostRecent`, 50 review/trang/app; 8 app × 150 = **1.200 review có ID duy nhất theo app**. Tệp JSON gốc và bản chuẩn hóa nằm trong `sources/`.
- **633 review** có ngày từ 09/08 đến 09/11/2026 trong dữ liệu nhận được. Review mới nhất trong toàn bộ mẫu mang ngày 07/11/2026; không tự nhận đã có đủ phản hồi đến hết ngày 09/11.
- Toàn bộ 1.200 được kiểm kê và quét từ khóa chủ đề bằng script. Đã đọc sâu tất cả **119 review ≤3 sao trong cửa sổ gần đây**, đọc bổ sung review 4/5 sao có nội dung phản đối, và phản hồi tích cực. Không tuyên bố đã mã hóa ngữ nghĩa thủ công đầy đủ từng review trong 1.200.
- `APP-STORE-KEYWORD-INDEX.csv` chỉ là chỉ mục tìm chủ đề. Ví dụ từ “watch” có thể nằm trong lời khen hoặc lời chê. **Không dùng số lần khớp từ làm tỷ lệ lỗi.** Một review 5 sao vẫn có thể hoàn toàn tiêu cực; ví dụ MacroFactor 01/10 và Gravl 19/08 trong bảng chứng cứ.
- **80 dòng chứng cứ được chọn và diễn giải thủ công** nằm trong `APP-STORE-EVIDENCE.csv`; bảng bên dưới giữ ID, phiên bản, ngày, mức ưu tiên và đường dẫn RSS. Mức P1/P2 thể hiện tác động UX nếu phản ánh là đúng, không phải mức độ lỗi đã được auditor tái hiện.
- Mẫu theo số lượng cố định có thời gian rất khác nhau: 150 review Hevy chỉ bao phủ vài ngày, còn 150 review Boostcamp kéo dài hơn hai năm. **Không xếp hạng chất lượng app, thị phần, churn hoặc tỷ lệ người không hài lòng bằng tỷ lệ sao thấp trong mẫu này.**
- Review storefront Mỹ không chứng minh người viết đang sống tại Mỹ. iOS không đại diện Android. Reviewer tự chọn viết bài; phản hồi có thể đã sửa, thiếu thông tin account, nhầm gói, sai cách dùng hoặc chưa cập nhật app.
- Trường `updated` của RSS là ngày Apple cung cấp, có thể là lúc sửa review. Phiên bản gắn review không xác nhận chính xác build khi lỗi đầu tiên xảy ra. Các URL RSS có thể thay đổi nội dung theo thời gian; bản JSON đã lưu giúp giữ dấu vết.
- Đánh giá về thuật toán, sinh lý học, giảm cân, chấn thương, tính tiền hay hành vi công ty là **lời người dùng**, không được biến thành sự thật kỹ thuật hoặc kết luận sai phạm. Không trích nguyên văn dài trong báo cáo.

Chạy lại kiểm kê: `python3 research/2026-11-09/analyze_app_store.py`. Bản TSV diễn giải thủ công là `app_store_manual_evidence.tsv`; CSV đã bổ sung metadata từ JSON gốc.

## Định danh app và snapshot thương mại

Đối chiếu bằng Apple Lookup US chính thức, lưu thành `sources/*-lookup-us.json`. Strong ở đây là **Strong Workout Tracker Gym Log — Strong Fitness PTE Limited**, ID464254577, bundle `com.cameronchow.Strong`; không phải app khác tên STRONG dành cho nữ. Gravl có seller GAINS COACH PTY LTD và tên developer GAINS AI.

Các điểm số/count dưới đây thuộc storefront iOS US tại thời điểm lấy dữ liệu; không phải người dùng trả tiền hay active users. Điểm raw làm tròn hai chữ số; giao diện App Store có thể làm tròn một chữ số khác. Giá USD là giá tham chiếu/những SKU công khai, không phải cam kết giá checkout của mọi tài khoản.

| App | Rating US / số ratings | Phiên bản Lookup | Giá tham chiếu / SKU công khai | Nguồn |
|---|---:|---|---|---|
| Fitbod | 4,81 / 289.478 | 8.39.0, phát hành 05/11 UTC | Hãng công bố $15,99/tháng hoặc $95,99/năm; App Store còn SKU legacy/promo | [Giá hãng](https://help.fitbod.me/hc/en-us/articles/360004904714-How-to-Subscribe-to-Fitbod), [US](https://apps.apple.com/us/app/id1041517543), [Lookup](https://itunes.apple.com/lookup?id=1041517543&country=us) |
| Gravl | 4,89 / 6.298 | **1.54, phát hành 08/11 20:43 UTC = 09/11 03:43 VN** | IAP: $14,99/tháng; $34,99/3 tháng; gói năm $59,99/$79,99/$89,99 cùng xuất hiện | [US](https://apps.apple.com/us/app/id6450921637), [Lookup](https://itunes.apple.com/lookup?id=6450921637&country=us) |
| Hevy | 4,92 / 102.593 | 3.2.5, phát hành 06/11 UTC | IAP: tháng $2,99 **và** $3,99; năm $23,99; lifetime $74,99 | [US](https://apps.apple.com/us/app/id1458862350), [Lookup](https://itunes.apple.com/lookup?id=1458862350&country=us) |
| Ladder | 4,95 / 219.768 | 4.16.2, phát hành 04/11 UTC | Pro $29,99/tháng hoặc $179,99/năm; trial 7 ngày không thu thẻ | [Giá hãng](https://www.joinladder.com/pricing), [Lookup](https://itunes.apple.com/lookup?id=1502936453&country=us) |
| MacroFactor Workouts | 4,84 / 4.927 | 1.4.3, phát hành 05/11 UTC | $11,99/tháng, $47,99/6tháng, $71,99/năm; bundle Nutrition+Workouts $89,99/năm | [Hướng dẫn gói hãng](https://help.macrofactorapp.com/en/articles/393-how-macrofactor-subscriptions-and-bundles-work), [Lookup](https://itunes.apple.com/lookup?id=6737156524&country=us) |
| Strong | 4,86 / 108.545 | 6.5.1, phát hành 08/10 UTC | Mô tả hãng: $4,99/tháng/$29,99/năm. IAP có Forever $99,99 và $79,99; không mặc định ai cũng được mua SKU thấp | [US](https://apps.apple.com/us/app/id464254577), [Lookup](https://itunes.apple.com/lookup?id=464254577&country=us) |
| Boostcamp | 4,85 / 10.901 | 268, phát hành 06/11 UTC | Pro $14,99/tháng/$59,99/năm; core free; trial 7 ngày ở gói năm | [Giá hãng](https://www.boostcamp.app/pro), [Lookup](https://itunes.apple.com/lookup?id=1529354455&country=us) |
| Caliber | 4,84 / 6.227 | 5.18.0, phát hành 03/11 UTC | Base free; Plus $12/tháng/$72/năm; IAP có promo $9/tháng và $36/$54/năm; coaching là sản phẩm riêng | [US](https://apps.apple.com/us/app/id1482405410), [Hướng dẫn hãng](https://caliberstrong.freshdesk.com/support/solutions/articles/48001257778-account-management-user-guide), [Lookup](https://itunes.apple.com/lookup?id=1482405410&country=us) |

Không dùng bảng SKU để suy ra mức giá “rẻ nhất chắc chắn mua được”. Nhiều gói legacy, promo, thử nghiệm hoặc khu vực có thể cùng tồn tại. Không dùng báo cáo tính tiền của reviewer làm giá chuẩn.

## Đọc tình trạng lỗi theo thời gian

- **Fitbod Watch:** hãng đã có thông báo sửa lỗi trong tháng10, và một review cũng sửa nội dung để xác nhận Watch hoạt động lại. Tuy nhiên mẫu có phản ánh 03/11 v8.38.1 về sync/nhịp tim. Cách viết đúng là “có báo cáo tái phát/phát sinh sau lần sửa”, không phải “lỗi tháng10 chắc chắn chưa được sửa”. Build Lookup mới nhất8.39.0 chỉ có release notes chung, nên không xác nhận tình trạng hiện tại cho từng lỗi.
- **Gravl:** Lookup lấy được1.54 mới phát hành rạng sáng09/11VN, mới hơn review trong mẫu. Release notes nêu sửa rounding mức tạ, warm-up/pyramid, timer Watch và sync split; **không ghi rõ** lỗi no-progression đã sửa. Vì vậy không được lấy than phiền tháng10 làm sự thật của1.54, cũng không tự gắn mọi than phiền đã được giải quyết.
- **Hevy:** bug launch tháng10 đã được nhóm thông báo sửa3.2.3. Các review trong mẫu gần đây3.2.4/3.2.5 nói về RPE, keyboard và Watch; đó là những vấn đề khác, không được gộp thành cùng lỗi crash cũ. Notes3.2.5 có cảnh báo ngay khi hoàn tất set0reps/time/distance, cho thấy error prevention đang được cải tiến.
- **MacroFactor Workouts:** phàn nàn tháng8–9 “chưa có Watch app” đã lỗi thời về availability. Review29/10 v1.4.1 nói Watch app đã hiện hữu nhưng đơn giản và thiếu nhịp tim theo nhu cầu người viết. Báo cáo phải ưu tiên nhận định mới hơn.
- **Boostcamp/Strong/Caliber:** phần lớn lỗi trong chứng cứ được viết trên build cũ hơn Lookup hiện tại. Không có thử nghiệm đối chứng bản mới trong phân tích này; để trạng thái “chưa tái kiểm”.

## Tại sao người dùng thấy cuốn hút — diễn giải từ lời khen

Đây là phân tích hành vi sản phẩm, không phải khám phá thuật toán bí mật hoặc chứng minh cơ chế thần kinh.

| App | Giá trị người dùng nhắc tới | Cơ chế giữ người dùng hợp lý | Khi cơ chế có thể đảo ngược |
|---|---|---|---|
| Fitbod | Tới gym là có việc để làm, bớt lo sai, tập theo dụng cụ | Giảm việc phải quyết định + cảm giác có người lập kế hoạch | Phải sửa AI mỗi buổi khiến lý do trả phí biến mất |
| Gravl | Đề xuất tải, feedback form, chương trình thách thức vừa sức | Cảm giác được hướng dẫn riêng + biết mình có thể tăng gì | Đề xuất hồi phục hoặc dụng cụ thiếu hợp lý làm giảm tin tưởng |
| Hevy | Log nhanh, số buổi trước, PR, mốc150buổi, badge | Phản hồi ngay + tự cạnh tranh với thành tích cũ | Thêm một thao tác RPE, keyboard lỗi hoặc khó tìm tên bài phá nhịp tập |
| Ladder | Coach/team, buổi có cấu trúc, streak và lời động viên | Cảm giác thuộc về team + nhịp lịch tuần + có người đồng hành | Nói/quảng bá/prompt quá nhiều gây phiền; người chỉ muốn tập không cần social |
| MacroFactor Workouts | Đưa chương trình từ spreadsheet vào app, bundle nutrition, gợi ý tải | Giảm công quản lý + sự liên tục giữa chương trình và dữ liệu | Quá nhiều taxonomy, builder khó dùng hoặc quyền truy cập gói mơ hồ |
| Strong | Ít thao tác, thay sổ tay, tự dựng routine | Thói quen công cụ đáng tin, tốc độ và quyền kiểm soát | Mất lịch sử/notes hoặc sync Watch làm app không còn đáng tin hơn sổ |
| Boostcamp | Chương trình coach theo trình độ, swap hữu ích, core free | Độ tin cậy của chương trình + cảm giác làm theo lộ trình có sẵn | Chỉnh chương trình không lưu, quá trình nền mất log hoặc UI đổi làm thao tác chậm |
| Caliber | Video rõ, khả năng tự tập miễn phí; coaching có PT theo sát | Được dạy cách làm + trách nhiệm với con người thật | Thư viện không khớp gym hoặc người dùng không phân biệt appfree với gói coaching |

Không gọi dữ liệu lịch sử khó chuyển là thành công retention lành mạnh. Trong một số review Fitbod/Boostcamp, người dùng nói ở lại vì tiếc lịch sử dù không thích sản phẩm. Đó có thể là chi phí chuyển đổi, khác với yêu thích và kết quả thực tế.

## Hàm ý kiểm chứng cho Dopafit

- Đo **thời gian từ mở app đến bắt đầu bài đầu tiên** và **số thao tác để log/sửa/undo một set** trên người mới lẫn người có chương trình riêng. Không chỉ đo thời gian ở trong app; ít screen time có thể là thành công.
- Kiểm tra **khôi phục buổi tập khi app nền/đóng/mạng yếu**, đối chiếu từng set và nguồn sync, bảo đảm người dùng biết dữ liệu đã lưu ở đâu.
- Tạo tình huống **máy bận, tạ không có mức đề xuất, gym mới, người dùng quay lại sau vài tuần**. Giải thích phạm vi điều chỉnh, không chỉ đổi số trên màn hình.
- Thử **tìm bài bằng tênPT dùng, tên phổ biến, viết tắt và biến thể**; đưa bài gần nhất hợp lý, không buộc người tập biết đúng taxonomy của hệ thống.
- Đặt **AI hỗ trợ và manual mode** rõ ràng: người tự dựng chương trình cần lưu nguyên ý định; người muốn được dẫn dắt cần mức tạ/bài giải thích được. Không xem hai nhóm này có cùng kỳ vọng.
- **Streak/PR/celebration tùy chọn**, có cơ chế nghỉ/điều chỉnh mục tiêu dễ hiểu; không ép rating hay chia sẻ để hoàn tất công việc chính.
- Trình bày **giá, ngày bắt đầu tính tiền và nơi quản lý thuê bao** trước khi người dùng bỏ quá nhiều công nhập hồ sơ; lưu rõ họ mua qua kênh nào. Giữ đường xem/xuất lịch sử dễ hiểu kể cả khi quyền tập premium hết hạn.

Các acceptance criteria này do phân tích suy ra; cần ghép với audit Dopafit để quyết định thứ tự làm. Chưa có bằng chứng doanh thu, retention cohort, conversion hoặc thử nghiệm A/B của các app trong bộ dữ liệu này.

## Bảng mẫu và chứng cứ chi tiết

Phần sau được điền từ JSON và80 dòng TSV đã đọc/diễn giải thủ công. “P1/P2” là ưu tiên UX nếu đúng; “N/A” là lời khen. NguồnRSS dẫn tới trang có record lúc thu thập; dùng ID để tìm chính xác trong bản JSON lưu.


| App | Toàn mẫu | Cửa sổ toàn mẫu | Trong ba tháng | ≤3★ trong ba tháng | Ngoài ba tháng |
|---|---:|---|---:|---:|---:|
| boostcamp | 150 | 2024-10-22 → 2026-11-05 | 35 | 16 | 115 |
| caliber | 150 | 2025-06-20 → 2026-11-06 | 14 | 2 | 136 |
| fitbod | 150 | 2026-10-03 → 2026-11-07 | 150 | 54 | 0 |
| gravl | 150 | 2025-09-15 → 2026-11-07 | 53 | 11 | 97 |
| hevy | 150 | 2026-11-03 → 2026-11-07 | 150 | 7 | 0 |
| ladder | 150 | 2026-10-28 → 2026-11-07 | 150 | 4 | 0 |
| macrofactor-workouts | 150 | 2026-01-30 → 2026-11-05 | 34 | 12 | 116 |
| strong | 150 | 2026-04-15 → 2026-11-03 | 47 | 13 | 103 |

Tổng: 1.200; 633 trong cửa sổ gần đây;119 review ≤3★ gần đây;567 cũ hơn. Đây là mô tả mẫu, không so sánh xác suất gặp lỗi giữa app.

### fitbod

| Ngày / version / sao / ID | Loại / mức | Chủ đề và diễn giải | Tình trạng kiểm chứng | Nguồn |
|---|---|---|---|---|
| 2026-11-03 · v8.38.1 · 1★ · 14747265724 | painpoint / P1 | **Watch/sync** — Người dùng báo bản cập nhật gần đây làm mất đồng bộ Watch và nhịp tim, có ý định hủy thuê bao. | Phản ánh 03/11 ở v8.38.1; chưa tái hiện; không suy ra v8.39.0 còn lỗi. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1041517543/sortBy=mostRecent/json) |
| 2026-11-02 · v8.38.0 · 2★ · 14743790696 | painpoint / P1 | **Control/data/support** — Không đổi được training split, ghi chú máy không hiện/lưu; hỗ trợ tự động không giải quyết được. | Một tài khoản báo 02/11 v8.38.0; cần kiểm tra build mới. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1041517543/sortBy=mostRecent/json) |
| 2026-11-02 · v8.38.0 · 2★ · 14743554954 | painpoint / P1 | **AI/control** — Người tập lâu năm phải dựng lại buổi tập hầu như mỗi lần, làm mất lợi ích tiết kiệm quyết định. | Đánh giá chủ quan về đề xuất; lời giải thích sinh lý của reviewer không được coi là sự thật kỹ thuật. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1041517543/sortBy=mostRecent/json) |
| 2026-10-22 · v8.37.0 · 1★ · 14699267600 | painpoint / P1 | **Value/progression** — Sau hai năm lưu dữ liệu vẫn tự lập chương trình; thông tin Coach bị coi là hiển nhiên, báo cáo thiên về tổng hoạt động hơn tiến bộ từng bài. | Không kiểm chứng lịch sử hai năm hay hiệu quả thuật toán; hữu ích để xác định kỳ vọng premium. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1041517543/sortBy=mostRecent/json) |
| 2026-10-13 · v8.35.1 · 1★ · 14663218493 | painpoint / P1 | **Return after break** — Sau nhiều tuần nghỉ, Coach nhận ra vắng tập nhưng vẫn gợi ý max-effort ở mức đỉnh cũ; người dùng mong buổi quay lại nhẹ dần. | Rủi ro trải nghiệm cần kiểm tra; không kết luận đã có chấn thương. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=3/id=1041517543/sortBy=mostRecent/json) |
| 2026-11-01 · v8.38.0 · 1★ · 14737340217 | painpoint / P1 | **Plan preservation** — Người dùng báo buổi tự chỉnh bị thay bằng buổi app tạo và mất nhiều routine. | Chưa tái hiện; phân biệt regeneration với xóa dữ liệu vĩnh viễn. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1041517543/sortBy=mostRecent/json) |
| 2026-11-04 · v8.38.1 · 4★ · 14752520446 | painpoint / P1 | **Offline** — Review 4 sao muốn tải video, lịch sử và biểu đồ để tập ở gym sóng yếu; khi offline app báo buổi có thể khác kế hoạch. | Quan sát do người dùng báo, không kết luận app hoàn toàn không hỗ trợ offline. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1041517543/sortBy=mostRecent/json) |
| 2026-11-01 · v8.38.0 · 3★ · 14738705167 | painpoint / P2 | **Superset timer** — Warm-up chỉ có ở một vế superset làm thứ tự và timer khó theo, phải nhảy tay giữa bài. | Tình huống cụ thể v8.38.0 cần regression test. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1041517543/sortBy=mostRecent/json) |
| 2026-10-30 · v8.38.0 · 1★ · 14729838651 | painpoint / P2 | **Review prompt** — Người dùng vẫn thích app nhưng chấm 1 sao vì bị hỏi rating sau mỗi buổi. | Rating thấp phản ánh sự quấy rầy, không đồng nghĩa không thích bài tập. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1041517543/sortBy=mostRecent/json) |
| 2026-11-04 · v8.38.1 · 1★ · 14750414780 | painpoint / P1 | **Paywall/trial** — Người tìm app miễn phí thất vọng khi phải chọn trial hoặc trả tiền và nhập thông tin thanh toán. | Bất mãn do kỳ vọng; không xác nhận có gói miễn phí hay lỗi tính tiền. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1041517543/sortBy=mostRecent/json) |
| 2026-10-18 · v8.36.0 · 1★ · 14683265369 | painpoint / P1 | **Price clarity** — Người dùng báo mức tính tiền sau trial khác mức chồng đang trả và không rõ chuyển Family có mất lịch sử không. | Khoản tiền cụ thể là cáo buộc chưa đối chiếu hóa đơn; không dùng làm giá chuẩn. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1041517543/sortBy=mostRecent/json) |
| 2026-10-15 · v8.36.0 · 4★ · 14669485752 | resolution / P2 | **Watch recovery** — Reviewer cập nhật rằng Watch đã hoạt động lại sau bản sửa, còn thiếu icon trên mặt đồng hồ. | Bằng chứng tích cực rằng một số lỗi Watch đã sửa; không phủ nhận báo cáo phát sinh muộn hơn. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1041517543/sortBy=mostRecent/json) |
| 2026-10-14 · v8.36.0 · 5★ · 14665968630 | positive / N/A | **Confidence/decision relief** — Người dùng mô tả giảm áp lực không biết tập gì, tự tin hơn sau trial và tiếp tục dùng nhiều năm. | Tự thuật, không xác minh kết quả sức khỏe hay mức tăng tự tin. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1041517543/sortBy=mostRecent/json) |
| 2026-11-07 · v8.39.0 · 5★ · 14760687255 | positive / N/A | **Context flexibility** — Người đi thuyền dài ngày đánh giá cao bài tập theo dụng cụ sẵn có. | Chứng cứ giá trị theo hoàn cảnh, không phải thử nghiệm hiệu quả tập. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1041517543/sortBy=mostRecent/json) |

### gravl

| Ngày / version / sao / ID | Loại / mức | Chủ đề và diễn giải | Tình trạng kiểm chứng | Nguồn |
|---|---|---|---|---|
| 2026-10-12 · v1.53.4 · 1★ · 14659692075 | painpoint / P1 | **Recovery trust** — Người dùng chọn recovery split nhưng vẫn nhận bài cho nhóm cơ vừa tập hôm trước. | 12/10 v1.53.4; v1.54 mới phát hành sau review, chưa biết tình trạng hiện tại. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6450921637/sortBy=mostRecent/json) |
| 2026-10-14 · v1.53.4 · 3★ · 14665847909 | painpoint / P2 | **Weight entry** — Nhập mức tạ bị báo không khớp dụng cụ, phải thử nhiều số; muốn chọn đĩa để tự cộng. | 14/10 v1.53.4; v1.54 có thông báo sửa rounding máy/plate, chưa tái kiểm riêng trường hợp này. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6450921637/sortBy=mostRecent/json) |
| 2026-10-05 · v1.53.1 · 4★ · 14631852755 | painpoint / P2 | **Busy-gym logistics** — Người dùng muốn cấu hình loại thanh tạ và gom bài quanh cùng trạm, tránh bỏ ghế rồi quay lại khi gym đông. | Review 4 sao khen nền tảng nhưng chỉ ra khác biệt giữa lập kế hoạch và thực tế gym. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6450921637/sortBy=mostRecent/json) |
| 2026-10-10 · v1.53.4 · 3★ · 14652456645 | painpoint / P1 | **Equipment profile** — Review báo danh sách thiết bị gym sai và chạm giới hạn 15 thiết bị tự thêm. | 10/10 v1.53.4; giới hạn do reviewer báo, chưa xác nhận còn áp dụng. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6450921637/sortBy=mostRecent/json) |
| 2026-09-21 · v1.52.1 · 2★ · 14575805539 | painpoint / P1 | **Support/catalog** — Người dùng thấy thiếu biến thể landmine/kettlebell; AI trả lời khác nhau khi hỏi lặp buổi cũ, ticket bị đóng không lời giải. | 21/09 v1.52.1; không gộp toàn bộ thành lỗi hiện tại. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6450921637/sortBy=mostRecent/json) |
| 2026-08-10 · v1.50 · 5★ · 14412823414 | painpoint / P2 | **Swap/search** — Reviewer 5 sao vẫn báo khi tìm bài thay thế có lúc ảnh chồng hoặc app khựng. | 10/08 v1.50; bằng chứng lịch sử, không khẳng định v1.54 lỗi này. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=6450921637/sortBy=mostRecent/json) |
| 2026-08-19 · v1.51 · 5★ · 14446696350 | painpoint / P1 | **Onboarding** — Review 5 sao nhưng nội dung thất vọng vì không hoàn tất được hồ sơ để bắt đầu tập. | Cho thấy không thể dùng số sao làm bộ phân loại cảm xúc duy nhất; 19/08 v1.51. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6450921637/sortBy=mostRecent/json) |
| 2026-08-20 · v1.51 · 5★ · 14451466789 | painpoint / P1 | **Injury/context** — Người dùng muốn khai báo chấn thương để app hiểu việc giảm tạ là tạm thời. | Yêu cầu tính năng tại 20/08 v1.51; không kết luận bản mới thiếu khả năng này. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6450921637/sortBy=mostRecent/json) |
| 2026-10-11 · v1.53.4 · 5★ · 14655531627 | positive / N/A | **Form/decision relief** — Đánh giá cao phản hồi video về tư thế và mở app là có thể tập ngay. | Tự thuật 11/10 v1.53.4; không xác minh độ chính xác đánh giá tư thế. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6450921637/sortBy=mostRecent/json) |
| 2026-09-25 · v1.52.1 · 5★ · 14591224816 | positive / N/A | **Progress/change** — Người chuyển từ Fitbod cho biết buổi tập thách thức hơn và định mua gói năm. | Không suy ra Gravl hiệu quả hơn Fitbod cho mọi người. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6450921637/sortBy=mostRecent/json) |

### hevy

| Ngày / version / sao / ID | Loại / mức | Chủ đề và diễn giải | Tình trạng kiểm chứng | Nguồn |
|---|---|---|---|---|
| 2026-11-07 · v3.2.5 · 1★ · 14761637754 | painpoint / P1 | **Keyboard/logging** — Người dùng báo cập nhật làm keyboard còn mở và dễ bấm nhầm khi xác nhận xong set. | 07/11 v3.2.5; bằng chứng rất gần ngày khảo sát, chưa tái hiện. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1458862350/sortBy=mostRecent/json) |
| 2026-11-04 · v3.2.4 · 1★ · 14751931696 | painpoint / P2 | **RPE friction** — Màn nhập RPE mới bị chê thêm thao tác bấm và làm sửa mức tạ khó chịu hơn. | 04/11 v3.2.4; cần so lại v3.2.5 trước đánh giá lỗi hiện tại. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1458862350/sortBy=mostRecent/json) |
| 2026-11-07 · v3.2.5 · 3★ · 14763109698 | painpoint / P2 | **Search aliases** — Tên bài do PT dùng không trùng từ khóa trong app, người dùng không tìm được để ghi log. | 07/11 v3.2.5; cơ hội synonym/fuzzy search. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1458862350/sortBy=mostRecent/json) |
| 2026-11-06 · v3.2.4 · 5★ · 14759812474 | painpoint / P2 | **Optional social** — Người dùng 5 sao muốn giấu phần social và tùy chỉnh trang đầu để chỉ tập trung tập. | 06/11 v3.2.4; sở thích phân khúc, không phải mọi người đều ghét social. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1458862350/sortBy=mostRecent/json) |
| 2026-11-06 · v3.2.4 · 5★ · 14757393536 | painpoint / P2 | **Watch/equipment** — Người dùng vẫn yêu thích app nhưng đôi khi Watch và phone lệch trạng thái, muốn đặt trần mức tạ của máy. | 06/11 v3.2.4; một tài khoản, chưa xác định nguyên nhân. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1458862350/sortBy=mostRecent/json) |
| 2026-11-03 · v3.2.4 · 3★ · 14748603922 | painpoint / P2 | **Cardio fields** — Người dùng muốn ghi độ dốc treadmill thay vì chỉ các thông số hiện có. | 03/11 v3.2.4; scope cardio có thể ngoài ưu tiên strength. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=3/id=1458862350/sortBy=mostRecent/json) |
| 2026-11-07 · v3.2.5 · 1★ · 14761927406 | painpoint / P2 | **New device layout** — Review mong tối ưu giao diện cho thiết bị Duo. | 07/11 v3.2.5; chưa kiểm tra trên loại thiết bị này, không suy ra hỗ trợ toàn bộ màn hình lỗi. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1458862350/sortBy=mostRecent/json) |
| 2026-11-04 · v3.2.4 · 5★ · 14750894722 | positive / N/A | **Freemium/history** — Người dùng thích tự điền số buổi trước, timer và PR; trả tiền để ủng hộ dù thấy hạn chế bản free ít. | 04/11 v3.2.4; bằng chứng mô hình free tạo thiện chí trả tiền. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=3/id=1458862350/sortBy=mostRecent/json) |
| 2026-11-05 · v3.2.4 · 5★ · 14755530716 | positive / N/A | **Milestone/identity** — Người dùng mừng mốc 150 buổi, thích nhìn lại tiến độ và tự thách thức mình. | 05/11 v3.2.4; minh họa vòng lặp thói quen, không phải đo retention. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1458862350/sortBy=mostRecent/json) |
| 2026-11-07 · v3.2.5 · 5★ · 14763138592 | positive / N/A | **Badges** — Review khen badge tạo thêm động lực. | 07/11 v3.2.5; một ví dụ tác động phần thưởng nhỏ. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1458862350/sortBy=mostRecent/json) |

### ladder

| Ngày / version / sao / ID | Loại / mức | Chủ đề và diễn giải | Tình trạng kiểm chứng | Nguồn |
|---|---|---|---|---|
| 2026-11-05 · v4.16.2 · 1★ · 14755708009 | painpoint / P2 | **Repeated prompts** — Người dùng khó chịu vì phải đánh giá buổi và hỏi bật nhạc lặp lại; muốn tùy chọn không hỏi nữa. | 05/11 v4.16.2; phân biệt rating nội bộ buổi tập với App Store review. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1502936453/sortBy=mostRecent/json) |
| 2026-10-30 · v4.16.0 · 5★ · 14729772966 | painpoint / P2 | **Repeated prompts** — Ngay cả review 5 sao vẫn chê thao tác rating sau mỗi buổi tốn công. | 30/10 v4.16.0; hai review độc lập cùng chủ đề, không xác định tần suất toàn bộ user. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=3/id=1502936453/sortBy=mostRecent/json) |
| 2026-11-04 · v4.16.1 · 1★ · 14750491197 | painpoint / P1 | **Navigation/value** — Người dùng thích bài tập nhưng thấy điều hướng rối đến mức bỏ app để tự tập; giá làm ngưỡng chịu đựng thấp hơn. | 04/11 v4.16.1; nhận định chủ quan về UX, không phải quan sát trực tiếp của auditor. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1502936453/sortBy=mostRecent/json) |
| 2026-11-01 · v4.16.1 · 3★ · 14739582977 | painpoint / P2 | **Price anchoring** — Reviewer đối chiếu phí tháng với tiền gym và thấy giá trị chưa xứng. | 01/11 v4.16.1; đối chiếu giá theo cảm nhận, không khẳng định giá gym phổ biến. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1502936453/sortBy=mostRecent/json) |
| 2026-10-29 · v4.15.0 · 1★ · 14725715214 | painpoint / P2 | **Coaching signal** — Người dùng thấy coach nói nhiều nhưng thiếu thông tin mức tạ và kỹ thuật mong muốn. | 29/10 v4.15.0; đánh giá một trải nghiệm coach, không đại diện mọi team. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=3/id=1502936453/sortBy=mostRecent/json) |
| 2026-11-04 · v4.16.1 · 4★ · 14749361812 | painpoint / P2 | **Form visibility** — Muốn nhiều góc quay hơn để so tư thế. | 04/11 v4.16.1, review 4 sao. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1502936453/sortBy=mostRecent/json) |
| 2026-11-02 · v4.16.1 · 4★ · 14743947301 | painpoint / P1 | **Platform switching** — Người dùng yêu app nhưng chuyển sang Pixel rồi không tìm được app Ladder để tiếp tục. | 02/11 v4.16.1; cần xác nhận platform qua nguồn chính thức trước làm tuyên bố tuyệt đối. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1502936453/sortBy=mostRecent/json) |
| 2026-11-02 · v4.16.1 · 5★ · 14742749808 | painpoint / P2 | **External workout log** — Người dùng muốn log tạ/reps của buổi ngoài Ladder và lớp nhóm vào cùng journal. | 02/11 v4.16.1; nhu cầu hybrid, không tự động đồng nghĩa không có bất kỳ import nào. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1502936453/sortBy=mostRecent/json) |
| 2026-11-02 · v4.16.1 · 5★ · 14743137378 | painpoint / P1 | **Session playback** — Review 5 sao nhưng nội dung báo buổi liên tục tự pause sau cập nhật. | 02/11 v4.16.1; chưa tái hiện trên v4.16.2. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1502936453/sortBy=mostRecent/json) |
| 2026-11-06 · v4.16.2 · 5★ · 14758521291 | positive / N/A | **Decision relief** — Người dùng thích có buổi sẵn mỗi ngày, được chọn coach và đổi bài/ngày khi cần. | 06/11 v4.16.2; giá trị là sự kết hợp hướng dẫn và tự chủ. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1502936453/sortBy=mostRecent/json) |
| 2026-10-30 · v4.16.0 · 5★ · 14730408198 | positive / N/A | **Streak/history** — Nhìn chuỗi tập và lịch đã hoàn thành giúp người dùng duy trì đều. | 30/10 v4.16.0; tự thuật, không đo tác động nhân quả. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=3/id=1502936453/sortBy=mostRecent/json) |
| 2026-11-02 · v4.16.1 · 5★ · 14742306586 | positive / N/A | **Belonging/confidence** — Người mới từng ngại tập nơi công cộng cho biết lời động viên của coach và team giúp tự tin. | 02/11 v4.16.1; bằng chứng cảm nhận thuộc về cộng đồng. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1502936453/sortBy=mostRecent/json) |

### macrofactor-workouts

| Ngày / version / sao / ID | Loại / mức | Chủ đề và diễn giải | Tình trạng kiểm chứng | Nguồn |
|---|---|---|---|---|
| 2026-10-30 · v1.4.1 · 1★ · 14730988620 | painpoint / P1 | **Entitlement** — Người báo có gói năm đang hoạt động nhưng bị yêu cầu đăng ký lại nên không vào được tập. | 30/10 v1.4.1; chưa đối chiếu phương thức đăng nhập, bundle hoặc hóa đơn. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6737156524/sortBy=mostRecent/json) |
| 2026-10-23 · v1.4.1 · 2★ · 14702231372 | painpoint / P1 | **Beginner usability** — Người ít kinh nghiệm mất nhiều thời gian nhập bù lịch sử và không tìm được cách ưu tiên bài dễ hơn. | 23/10 v1.4.1; bằng chứng chi phí học sử dụng cao. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6737156524/sortBy=mostRecent/json) |
| 2026-09-07 · v1.3.1 · 3★ · 14521900335 | painpoint / P1 | **Data access after trial** — Người hết truy cập miễn phí báo không xem hoặc tải được lịch sử nếu không trả tiền. | 07/09 v1.3.1; không xác định eligibility bundle; không kết luận hãng cố ý giữ dữ liệu. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6737156524/sortBy=mostRecent/json) |
| 2026-10-02 · v1.4.0 · 1★ · 14620535518 | painpoint / P1 | **Load/support** — Người dùng không tải được workout và thất vọng vì hỗ trợ không đưa cách khắc phục. | 02/10 v1.4.0; chưa tái kiểm trên1.4.3. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6737156524/sortBy=mostRecent/json) |
| 2026-08-18 · v1.2.4 · 2★ · 14442695617 | painpoint / P2 | **Taxonomy/search** — Độ chi tiết biến thể bài và dụng cụ khiến tìm bài phổ biến, tạo chương trình và xuất dữ liệu trở nên rối. | 18/08 v1.2.4; cách diễn giải framework và nguyên nhân kỹ thuật của reviewer không được xác minh. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6737156524/sortBy=mostRecent/json) |
| 2026-10-01 · v1.4.0 · 5★ · 14616835107 | painpoint / P1 | **Authored-plan control** — Review 5 sao nhưng phàn nàn app tự đổi các bài/reps đã nhập khi dùng tính năng hỗ trợ. | 01/10 v1.4.0; dấu hiệu kỳ vọng về manual mode chưa rõ, không xác nhận hành vi chính xác. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6737156524/sortBy=mostRecent/json) |
| 2026-09-26 · v1.3.1 · 4★ · 14596403109 | painpoint / P2 | **Split choice** — Người tập 6 ngày muốn nhiều kiểu split hơn trong builder thay vì tự xây toàn bộ. | 26/09 v1.3.1; danh sách split có thể đã đổi ở1.4.x. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6737156524/sortBy=mostRecent/json) |
| 2026-10-29 · v1.4.1 · 4★ · 14727004646 | painpoint / P2 | **Watch/heart rate** — Reviewer xác nhận Watch app đã có nhưng đơn giản, muốn xem nhịp tim để cân nhắc hồi phục giữa set. | 29/10 v1.4.1; bằng chứng thay thế kết luận cũ không có Watch app. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6737156524/sortBy=mostRecent/json) |
| 2026-09-05 · v1.3.1 · 3★ · 14513189636 | historical / P1 | **Watch availability** — Review tháng9 muốn Watch app trước khi chuyển hoàn toàn sang nền tảng. | Đã lỗi thời về availability so với review29/10; chỉ giữ để hiểu nhu cầu. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6737156524/sortBy=mostRecent/json) |
| 2026-10-04 · v1.4.1 · 5★ · 14628374469 | positive / N/A | **Bundle/automation** — Người chuyển từ spreadsheet đánh giá cao theo dõi tập và dinh dưỡng thuận tiện, mức tạ được gợi ý khi log. | 04/10 v1.4.1; không xác nhận nhận diện thức ăn chính xác. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6737156524/sortBy=mostRecent/json) |
| 2026-09-25 · v1.3.1 · 5★ · 14592064173 | positive / N/A | **Program migration** — Người dùng thích đưa chương trình đang theo vào app, có demo cho bài và chương trình tùy thời gian. | 25/09 v1.3.1; minh họa giảm chi phí chuyển từ file sang app. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=6737156524/sortBy=mostRecent/json) |

### strong

| Ngày / version / sao / ID | Loại / mức | Chủ đề và diễn giải | Tình trạng kiểm chứng | Nguồn |
|---|---|---|---|---|
| 2026-11-03 · v6.5.1 · 2★ · 14747489075 | painpoint / P1 | **History/catalog** — Người dùng báo set biến mất khỏi lịch sử và thấy thiếu bài phổ biến. | 03/11 v6.5.1; chưa tái hiện; không lấy phát biểu cường điệu số bài làm kích thước thư viện. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=464254577/sortBy=mostRecent/json) |
| 2026-11-02 · v6.5.1 · 4★ · 14743894723 | painpoint / P2 | **Notes/template sync** — Ghi chú kỹ thuật trong buổi không luôn có tùy chọn cập nhật về template, phải copy tay sau đó. | 02/11 v6.5.1; case cụ thể giữa session và template. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=464254577/sortBy=mostRecent/json) |
| 2026-09-30 · v6.5.0 · 3★ · 14613344308 | painpoint / P1 | **Watch data loss** — Người dùng báo Watch sync làm mất set hoặc không hiện buổi đã kết thúc, phải nhập lại. | 30/09 v6.5.0; v6.5.1 có sau review, không mặc định còn lỗi. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=464254577/sortBy=mostRecent/json) |
| 2026-09-20 · v6.5.0 · 4★ · 14573900418 | painpoint / P1 | **Watch data loss** — Người dùng lâu năm báo đôi lúc buổi hiện synced rồi sau đó lịch sử thiếu toàn bộ hoặc một phần. | 20/09 v6.5.0; một báo cáo bổ trợ cùng nhóm vấn đề. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=464254577/sortBy=mostRecent/json) |
| 2026-09-18 · v6.5.0 · 4★ · 14564262897 | painpoint / P2 | **Search/value** — Người dùng muốn tìm gần đúng, ưu tiên tên khớp và thêm ảnh bài tùy chỉnh; khó thấy giá trị gói Pro. | 18/09 v6.5.0; yêu cầu tìm kiếm cụ thể có thể chuyển thành acceptance criteria. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=464254577/sortBy=mostRecent/json) |
| 2026-10-24 · v6.5.1 · 5★ · 14705253552 | painpoint / P2 | **Mixed metrics** — Review 5 sao muốn ghi farmer carry theo cả mức tạ và thời gian cùng lúc. | 24/10 v6.5.1; scope exercise type cụ thể. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=464254577/sortBy=mostRecent/json) |
| 2026-09-21 · v6.5.0 · 5★ · 14576481182 | positive / N/A | **Minimal interaction** — Người dùng thích ít thao tác giữa buổi, thấy hình ảnh/animation của app khác không cần thiết. | 21/09 v6.5.0; phân khúc ưu tiên tốc độ hơn trang trí. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=464254577/sortBy=mostRecent/json) |
| 2026-08-19 · v6.5.0 · 5★ · 14447125651 | positive / N/A | **Stable freemium** — Người dùng lâu năm thấy bản miễn phí với vài template đủ cho nhu cầu kế hoạch đơn giản. | 19/08 v6.5.0; số template chuẩn phải theo nguồn hãng, không suy từ reviewer khác. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=464254577/sortBy=mostRecent/json) |

### boostcamp

| Ngày / version / sao / ID | Loại / mức | Chủ đề và diễn giải | Tình trạng kiểm chứng | Nguồn |
|---|---|---|---|---|
| 2026-10-15 · v266 · 1★ · 14669557830 | painpoint / P1 | **Background persistence** — Người trả Pro báo rời app giữa buổi làm mất phần lớn số đã log. | 15/10 v266; bản hiện tại268 có sau review, chưa tái hiện. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1529354455/sortBy=mostRecent/json) |
| 2026-10-18 · v266 · 2★ · 14683775147 | painpoint / P1 | **Program editing** — Người dùng mất công chỉnh chương trình nhưng thay đổi không được lưu. | 18/10 v266; cần phân biệt save failure với nhập sai phạm vi tuần. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1529354455/sortBy=mostRecent/json) |
| 2026-09-14 · v265 · 1★ · 14549384649 | painpoint / P1 | **Undo/error recovery** — Lỡ xóa bài giữa buổi và không kịp undo ngắn khiến buổi lẫn tracking tiếp theo khó khôi phục. | 14/09 v265; thời lượng undo do reviewer báo chưa đo trực tiếp. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1529354455/sortBy=mostRecent/json) |
| 2026-09-12 · v265 · 1★ · 14543424176 | painpoint / P1 | **Data loss** — Người dùng báo mất dữ liệu sau cập nhật dù đã tập một năm. | 12/09 v265; chưa kiểm chứng phạm vi server hoặc login account. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1529354455/sortBy=mostRecent/json) |
| 2026-11-01 · v267 · 1★ · 14738336436 | painpoint / P1 | **Late paywall** — Người dùng không hài lòng vì nhập hồ sơ xong mới biết chi phí. | 01/11 v267; phản ánh minh bạch onboarding, không chứng minh toàn bộ sản phẩm bắt buộc trả phí. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1529354455/sortBy=mostRecent/json) |
| 2026-11-05 · v267 · 2★ · 14754783431 | painpoint / P1 | **Account deletion** — Người dùng không tìm được cách xóa tài khoản trong app. | 05/11 v267; chưa kiểm chứng đường dẫn; không kết luận vi phạm quy định. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1529354455/sortBy=mostRecent/json) |
| 2026-09-19 · v265 · 4★ · 14568483813 | painpoint / P2 | **Timer regression** — Review4 sao chê timer mất nhớ thời gian cũ và nút tắt nhanh, dù vẫn thích khả năng dùng/tạo chương trình. | 19/09 v265; chưa tái kiểmv268. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1529354455/sortBy=mostRecent/json) |
| 2026-10-10 · v266 · 5★ · 14650907828 | positive / N/A | **Useful iteration** — Người dùng khen đề xuất bài tương tự khi swap và tự gọn bài sau khi hoàn thành set. | 10/10 v266; ví dụ cập nhật tạo lợi ích thực tế. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1529354455/sortBy=mostRecent/json) |
| 2026-09-06 · v265 · 5★ · 14518830708 | positive / N/A | **Coach programs** — Người mới đánh giá cao chương trình theo trình độ giúp giữ kế hoạch đều. | 06/09 v265; tự thuật về giá trị chương trình. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1529354455/sortBy=mostRecent/json) |

### caliber

| Ngày / version / sao / ID | Loại / mức | Chủ đề và diễn giải | Tình trạng kiểm chứng | Nguồn |
|---|---|---|---|---|
| 2026-10-16 · v5.17.0 · 1★ · 14673052635 | painpoint / P1 | **Catalog/price fit** — Người dùng thấy số bài phù hợp mỗi nhóm cơ ít, phải tự thêm nhiều nên không muốn trả phí. | 16/10 v5.17.0; cảm nhận thư viện không đồng nghĩa hãng chỉ có ít bài tổng thể. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1482405410/sortBy=mostRecent/json) |
| 2026-09-21 · v5.16.1 · 2★ · 14578379246 | painpoint / P2 | **Equipment catalog** — Người dùng báo thiếu nhiều máy tiêu chuẩn trong lựa chọn bài. | 21/09 v5.16.1; chưa kiểm chứng từng máy, cần nghiên cứu gym thật. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1482405410/sortBy=mostRecent/json) |
| 2026-09-02 · v5.16.0 · 4★ · 14503182746 | painpoint / P2 | **Warm-up guidance** — Review4 sao muốn có stretching theo buổi để được chỉ dẫn tốt hơn. | 02/09 v5.16.0; không khẳng định stretching ngăn được mọi chấn thương. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1482405410/sortBy=mostRecent/json) |
| 2026-08-06 · v5.15.1 · 1★ · 14397406411 | historical / P1 | **Trial expectation** — Người dùng nói quảng cáo miễn phí nhưng khi thử bị tính tiền ngay. | 06/08 v5.15.1, ngoài ba tháng; cáo buộc cần hóa đơn, không dùng làm kết luận thương mại. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1482405410/sortBy=mostRecent/json) |
| 2026-08-28 · v5.16.0 · 5★ · 14481743533 | positive / N/A | **Human accountability** — Người dùng đánh giá giá trị lớn nhất đến từ PT, học cùng và được theo sát hơn là chỉ app lập lịch. | 28/08 v5.16.0; phân biệt trải nghiệm coaching với free logger. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1482405410/sortBy=mostRecent/json) |
| 2026-10-03 · v5.16.1 · 5★ · 14625145905 | positive / N/A | **Instruction/free value** — Sau một tháng, người dùng thấy video và mô tả giúp hiểu bài mới, giá trị có thể so với app trả phí. | 03/10 v5.16.1; cảm nhận cá nhân. | [RSS](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1482405410/sortBy=mostRecent/json) |
