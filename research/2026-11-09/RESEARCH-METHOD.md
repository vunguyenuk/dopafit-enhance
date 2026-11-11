# Phương pháp nghiên cứu — Dopafit / thị trường Mỹ

Ngày nghiên cứu: **09/11/2026, giờ Việt Nam**. Đây là ảnh chụp tại thời điểm nghiên cứu, không phải theo dõi liên tục.

## Yêu cầu và bối cảnh

Người dùng yêu cầu: nhận diện Fitbod ở Mỹ, audit Dopafit đang mở trên iPhone Mirroring, tìm đối thủ hiện tại, nghiên cứu pain point mới và giải thích cơ chế thu hút/giữ người dùng. Ảnh Slack được cung cấp mô tả mong muốn làm gần Fitbod và thay icon/style; đó là bối cảnh từ bên thứ ba, **không phải quyền để tự sửa sản phẩm, gửi tin nhắn hoặc phát hành thiết kế**.

Người dùng đã xác nhận Dopafit phục vụ **cả người mới lẫn người tập đều**; tài khoản đang mở là **tài khoản test, được phép ghi dữ liệu tập giả**. Brand tone chưa được xác nhận. Bản nghiên cứu không tự giả định một tính cách thương hiệu đã chốt.

## Nhãn bằng chứng

| Nhãn | Ý nghĩa | Không được suy ra |
|---|---|---|
| OBS | Quan sát/thao tác trực tiếp trên Dopafit, có ảnh và bước kiểm tra | Không chứng minh tất cả thiết bị/tài khoản đều giống nhau |
| STORE | Listing, Apple Lookup hoặc review ở storefront US | Không chứng minh người viết đang sống tại Mỹ; rating không phải retention |
| USER | Ý kiến người dùng trên Reddit hoặc review | Không tự trở thành bug đã tái hiện hoặc kết luận sinh lý đúng |
| VENDOR | Tài liệu/help/release notes của nhà phát triển | Không phải đánh giá độc lập về hiệu quả thuật toán |
| INFER | Nhận định sản phẩm của người nghiên cứu | Cần kiểm thử, không phải số liệu kinh doanh đã biết |
| TODO | Chưa kiểm chứng | Không coi là tính năng thiếu hoặc app bị lỗi |

## Mẫu App Store

Apple public RSS, country=US, sortBy=mostRecent, 3 trang × tối đa 50 review/app. Tám app: Fitbod, Gravl, Hevy, Ladder, MacroFactor Workouts, Strong, Boostcamp, Caliber. Tổng thu được **1.200 review không trùng ID trong mỗi app**. Phân tích mới ưu tiên cửa sổ **09/08–09/11/2026**; phần ngoài cửa sổ được tách riêng.

Định dạng feed: `https://itunes.apple.com/us/rss/customerreviews/page=1/id=1041517543/sortBy=mostRecent/json`. Trang 2/3 thay `page`. Apple Lookup xác thực danh tính app, phiên bản và số rating bằng `https://itunes.apple.com/lookup?id=1041517543&country=us`.

Script `analyze_app_store.py` tạo chỉ mục từ khoá và số đếm; đọc sâu các review thấp trong cửa sổ gần đây cùng review điểm cao có ý kiến cụ thể. **Từ khoá không phải phân loại cảm xúc**. Bảng bằng chứng tuyển chọn sử dụng diễn giải, không sao chép toàn văn review. Các dữ liệu thô trong `sources` phục vụ đối chiếu nội bộ.

### Giới hạn lấy mẫu

- Mẫu mới nhất không ngẫu nhiên, không đại diện mọi người dùng.
- Tần suất review rất khác nhau: 150 review Hevy bao phủ vài ngày, trong khi 150 review một số app phủ hơn một năm. Không xếp hạng chất lượng bằng tỷ lệ sao thấp trong hai cửa sổ khác nhau.
- RSS là ngày cập nhật của review; người dùng có thể sửa review cũ. Không luôn biết lần đầu họ gặp lỗi.
- Storefront US là tiêu chí thị trường, không xác minh quốc tịch/nơi ở reviewer.
- Đánh giá 5★ cũng có pain point; đánh giá 1★ cũng có thể bắt nguồn từ hiểu nhầm hoặc bản cũ.
- Chưa có cohort, retention, revenue, subscription conversion, crash telemetry hay thử nghiệm có đối chứng của từng app. Không suy ra các số này từ rating, downloads hoặc Reddit.

## Reddit và nguồn internet

Ưu tiên bài gốc có ngày cụ thể, trao đổi từ người dùng và phản hồi nhà phát triển; đối chiếu release notes nếu có. Chủ động tìm cả lời khen lẫn phản ánh tiêu cực. Reddit có thiên lệch người dùng chủ động phản hồi, self-promotion, referral và bình luận từ nhà phát triển; không dùng số upvote như tỷ lệ phổ biến trong thị trường Mỹ.

Giá lấy từ website/help chính thức khi có giá hiện hành rõ; khi chỉ thấy nhiều sản phẩm IAP, ghi **các mức niêm yết**, không chọn mức thấp nhất làm giá chung. Không thực hiện thanh toán hoặc đăng ký trial trả phí.

## Audit thiết bị

Sử dụng `cua_repl` để thao tác iPhone Mirroring; ảnh lưu trong `evidence`. Cây accessibility của mirroring không lộ cấu trúc UI trong app nên thao tác dựa ảnh. Điều này **không phải bằng chứng Dopafit thiếu accessibility**.

Chỉ đánh giá trạng thái thực sự đi tới. Chụp riêng trạng thái trước/sau; không lấy frame chuyển cảnh làm lỗi layout. Độ trễ mirroring không được gọi là độ trễ app. Không có repo/mã nguồn ứng dụng trong workspace ban đầu, không thể kiểm tra bundle, component, API hoặc implementation thuật toán.

Các ranh giới: không reset tài khoản, không đăng xuất để xem lại onboarding khi có nguy cơ mất quyền truy cập; không mua subscription; không cấp quyền Health/camera/notification mới ngoài yêu cầu; không xoá dữ liệu vĩnh viễn. Dữ liệu tập thử chỉ được ghi sau xác nhận của người dùng. Tính đúng đắn sinh lý của gợi ý cần review chuyên môn và kiểm thử dọc nhiều tuần, không thể kết luận chỉ bằng một buổi giả.

## Skill và đánh giá độc lập

Đã đọc `audit`, `critique`, `impeccable`. Áp dụng phần nguyên tắc phù hợp cho native mobile, ghi rõ các kiểm tra mã nguồn/DOM không khả thi. Theo yêu cầu đánh giá độc lập của `critique`, có một lượt xem ảnh UX riêng và một lượt phân tích bằng chứng review. Không dùng detector HTML lên ảnh hoặc tự chấm WCAG toàn app khi chưa đo.

## Cách sử dụng kết quả

Đọc báo cáo tổng hợp trước; dùng audit chi tiết để giao việc; mở ảnh theo ID để tái hiện; dùng CSV evidence để truy ngược ngày/phiên bản/nguồn. Ưu tiên vấn đề có tác động lên việc hiểu tạ, hoàn tất buổi, bảo toàn dữ liệu và khả năng đọc tiến bộ. Các ý tưởng khác biệt hóa là đề xuất cần thử nghiệm, không phải kết quả tăng retention đã được chứng minh.

## Cập nhật sau kiểm thử tiếp tục

Đã hoàn tất một buổi giả được người dùng cho phép: 3 set × 6 reps × 42.5 kg, RIR 2. Kiểm tra trước/sau ở nhật ký, per-exercise history, trends, report, mục tiêu tuần và recovery; background/return còn dữ liệu. Tổng 765 kg khớp; 1RM 51 kg khớp công thức UI công khai. Chỉ một case không chứng minh toàn bộ integrity hoặc thuật toán.

Có 58 ảnh Dopafit và 1 ảnh Fitbod, danh mục ở EVIDENCE-INDEX.md. Fitbod trên máy hiện paywall giá VND; không đăng ký trial, không dùng giá này đại diện storefront Mỹ. Có entry export nhưng chỉ tới share sheet, chưa đọc file. English có option nhưng chưa áp dụng. Cuộn settings/help chưa tới hết qua Mirroring; không kết luận app chặn nội dung.

Các nhận xét ban đầu được cập nhật theo bằng chứng: barbell có quy ước gồm đòn, swap có prompt scope, progress có per-exercise detail và công thức; set mục tiêu là contribution chính/phụ chứ chưa có bằng chứng duplicate. Audit chính là nguồn kết luận sau cùng; review độc lập D01–D08 được giữ như tài liệu giai đoạn đầu.

## Mẫu bổ sung ba đối thủ trực tiếp

Lấy thêm 1 trang US RSS (50/app) của Alpha Progression 1462277793, PUSH 1621689462, FitnessAI 1446224156; lưu riêng sources/supplementary để script corpus chính không trộn. 150 review bổ sung, 34 trong cửa sổ ba tháng; đọc toàn bộ 34, trong đó 15 ≤3 sao. Chọn 20 dòng diễn giải riêng ở SUPPLEMENTARY-APP-EVIDENCE.csv. Tổng lưu là 1.350 review ở 11 app, nhưng thiết kế mẫu 150/app và 50/app khác nhau: báo cáo giữ số riêng, không so tỷ lệ hoặc tổng hợp thành tỷ lệ thị trường.
