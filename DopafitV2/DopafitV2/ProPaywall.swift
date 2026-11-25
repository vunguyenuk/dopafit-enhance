import SwiftUI
import UIKit

/// Local demo of the requested three-screen offer. No StoreKit product or charge.
struct ProPaywall: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var firstTime: Bool
    enum Page: String { case plans, gift, offer }
    @State private var page: Page = .plans
    @State private var yearly = true
    @State private var notice: Notice?
    @State private var legal: String?
    @State private var openingGift = false
    enum Notice: String, Identifiable {
        case activate, restore
        var id: String { rawValue }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                switch page {
                case .plans: plans
                case .gift: gift
                case .offer: offer
                }
            }.id(page).transition(page == .gift ? .identity : .opacity)
            IconButton(icon: "xmark", label: "Đóng") { close() }
                .padding(.trailing, 20).padding(.top, 8)
                .accessibilityIdentifier("pro.close")
        }.screenBackground()
            .animation(reduceMotion || page == .gift ? nil : .easeInOut(duration: 0.3), value: page)
            .safeAreaInset(edge: .bottom) { bottom }
            .overlayPreferenceValue(GiftLightSourceKey.self) { anchor in
                GeometryReader { geometry in
                    if let anchor {
                        GiftScreenLight(opening: openingGift && page == .gift, source: geometry[anchor])
                    }
                }.ignoresSafeArea().allowsHitTesting(false)
            }
            .alert(item: $notice) { kind in
                if kind == .restore {
                    Alert(title: Text("Chưa kết nối App Store"), message: Text("Bản demo chưa có giao dịch để khôi phục."), dismissButton: .default(Text("Đã hiểu")))
                } else {
                    Alert(title: Text("Bật Pro cho bản demo?"), message: Text("Không có giao dịch, không bắt đầu dùng thử trả phí và không trừ tiền."), primaryButton: .default(Text("Bật Pro demo")) { activate() }, secondaryButton: .cancel(Text("Để sau")))
                }
            }
            .sheet(isPresented: Binding(get: { legal != nil }, set: { if !$0 { legal = nil } })) {
                let title = legal ?? "Điều khoản"
                VStack(alignment: .leading, spacing: 20) {
                    SheetHeader(title: title, subtitle: "Dopafit · bản demo cục bộ") { legal = nil }
                    Text(title == "Quyền riêng tư" ? "Hồ sơ và lịch tập hiện được lưu trên thiết bị. Chưa có đồng bộ tài khoản, thanh toán hay gửi dữ liệu Health ở luồng này." : "Các gói và ưu đãi đang minh họa giao diện. Bản demo không tạo đăng ký App Store, không gia hạn và không tính phí. Điều khoản thương mại sẽ được cung cấp khi có dịch vụ thật.")
                        .font(T.font(16)).foregroundStyle(T.sub).padding(.horizontal, 20)
                    Spacer()
                }.screenBackground().presentationDetents([.medium])
            }
            .onAppear {
                #if DEBUG
                if Bundle.main.bundleIdentifier?.hasSuffix(".designqa") == true,
                   let i = ProcessInfo.processInfo.arguments.firstIndex(of: "--preview-paywall"),
                   ProcessInfo.processInfo.arguments.indices.contains(i + 1),
                   let value = Page(rawValue: ProcessInfo.processInfo.arguments[i + 1]) {
                    page = value
                    if value == .offer && state.data.offerExpiresAt == nil { state.data.offerExpiresAt = Date().addingTimeInterval(900) }
                }
                #endif
            }
            .task(id: openingGift) {
                guard openingGift else { return }
                do {
                    try await Task.sleep(for: .milliseconds(reduceMotion ? 150 : 1850))
                } catch { return }
                guard !Task.isCancelled, page == .gift else { return }
                if state.data.offerExpiresAt == nil { state.data.offerExpiresAt = Date().addingTimeInterval(900) }
                page = .offer
                openingGift = false
            }
    }

    private var plans: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                GeometryReader { geometry in
                    let imageHeight = geometry.size.width * 1.5
                    Image(BodyIllustration.hero(state.data.profile.sex)).resizable().scaledToFill()
                        .frame(width: geometry.size.width, height: imageHeight)
                        .offset(y: -max(0, imageHeight - geometry.size.height) * 0.12)
                }.frame(height: 320).clipped()
                    .overlay(LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .clear, location: 0.65), .init(color: T.bg, location: 1)], startPoint: .top, endPoint: .bottom))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 22) {
                    Text("Dopafit Pro").font(T.font(14, .medium)).foregroundStyle(T.sub)
                    Text("Plan mạnh nhất khi có Pro.").font(T.font(26, .bold)).foregroundStyle(T.text).lineSpacing(3)
                    VStack(alignment: .leading, spacing: 13) {
                        benefit("Tự tăng tạ khi đủ rep, điều chỉnh khi mệt hoặc đau.")
                        benefit("Theo dõi sức mạnh từng bài và hồi phục nhóm cơ.")
                        benefit("Đổi bài trong một chạm khi máy đang có người.")
                    }
                    VStack(spacing: 12) {
                        plan(title: "Gói năm", price: "79,99 US$ / năm", note: "Khoảng 6,67 US$ mỗi tháng", selected: yearly) { yearly = true }
                        plan(title: "Gói tháng", price: "9,99 US$ / tháng", note: "Linh hoạt theo từng tháng", selected: !yearly) { yearly = false }
                    }
                    Text("Dùng thử 3 ngày (minh họa). Bản demo chưa kết nối App Store.")
                        .font(T.font(13)).foregroundStyle(T.sub).lineSpacing(3)
                }.padding(.horizontal, 20)
            }.padding(.bottom, 20)
        }.scrollIndicators(.hidden).ignoresSafeArea(edges: .top)
    }

    private var gift: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 22) {
                    ProGiftVisual(opening: openingGift, size: min(300, geometry.size.width - 48))
                        .anchorPreference(key: GiftLightSourceKey.self, value: .bounds) { $0 }
                        .padding(.top, max(70, geometry.size.height * 0.14))
                    Text("Khoan đã!\nDopafit có quà cho bạn.").font(T.font(28, .bold)).foregroundStyle(T.text)
                        .multilineTextAlignment(.center).lineSpacing(4)
                    Text("Thêm một lý do để bắt đầu.").font(T.font(16)).foregroundStyle(T.sub)
                }.frame(maxWidth: .infinity).padding(.horizontal, 24).padding(.bottom, 30)
            }.scrollIndicators(.hidden)
        }
    }

    /// Offer layout after Mobbin refs: Sunlitt 0c960695 (one focal price, small strikethrough,
    /// per-month line), QUITTR 09ef2499 (big discount + compact timer + single "lowest price" plan),
    /// Pillow 06cd6479 / Nibble 8add0191 (discount rising from an illustrated gift) and
    /// Vocabulary d5dd533b (three short benefits). Prices/timer/activation logic unchanged.
    private var offer: some View {
        ScrollView {
            VStack(spacing: 18) {
                OfferHero()
                VStack(spacing: 6) {
                    Text("Pro cả năm, chỉ còn một nửa.").font(T.font(24, .bold)).foregroundStyle(T.text)
                    Text("Ưu đãi một lần, chỉ dành cho bạn.").font(T.font(15)).foregroundStyle(T.sub)
                }.multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let remaining = max(0, Int((state.data.offerExpiresAt ?? context.date).timeIntervalSince(context.date)))
                    HStack(spacing: 8) {
                        Image(systemName: "clock").foregroundStyle(T.lime).accessibilityHidden(true)
                        Text("Hết hạn sau").foregroundStyle(T.sub)
                        Text(String(format: "%02d:%02d", remaining / 60, remaining % 60))
                            .font(T.num(16, .semibold)).foregroundStyle(T.text)
                            .contentTransition(.numericText(countsDown: true))
                    }.font(T.font(14, .medium))
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(T.surface, in: Capsule())
                        .overlay(Capsule().stroke(T.line))
                        .accessibilityElement(children: .combine)
                }
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Pro · Năm").font(T.font(18, .semibold)).foregroundStyle(T.text)
                        Text("≈ 3,33 US$/tháng").font(T.font(14)).foregroundStyle(T.sub)
                    }
                    Spacer(minLength: 8)
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("79,99 US$").strikethrough().font(T.num(14, .medium)).foregroundStyle(T.faint)
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Text("39,99 US$").font(T.num(28, .bold)).foregroundStyle(T.text)
                            Text("/năm").font(T.font(13)).foregroundStyle(T.sub)
                        }.lineLimit(1).minimumScaleFactor(0.8)
                    }
                }.padding(.horizontal, 18).padding(.top, 26).padding(.bottom, 18)
                    .frame(maxWidth: .infinity)
                    .background(T.surface, in: RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(T.lime.opacity(0.7), lineWidth: 1.5))
                    .overlay(alignment: .top) {
                        Text("Giá thấp nhất").font(T.font(12, .bold)).foregroundStyle(T.bg)
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(T.lime, in: Capsule()).offset(y: -12)
                    }
                    .padding(.top, 8)
                    .accessibilityElement(children: .combine)
                VStack(alignment: .leading, spacing: 12) {
                    offerBenefit("Tự tăng tạ khi đủ rep, điều chỉnh khi mệt hoặc đau.")
                    offerBenefit("Theo dõi sức mạnh từng bài và hồi phục nhóm cơ.")
                    offerBenefit("Đổi bài trong một chạm khi máy đang có người.")
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 4)
                Text("Gia hạn minh họa 39,99 US$/năm · Hủy bất cứ lúc nào")
                    .font(T.font(12)).foregroundStyle(T.sub).multilineTextAlignment(.center)
            }.padding(.horizontal, 20).padding(.bottom, 20)
        }.scrollIndicators(.hidden)
    }
    private func offerBenefit(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark").font(.system(size: 14, weight: .bold)).foregroundStyle(T.lime).padding(.top, 2)
            Text(text).font(T.font(15)).foregroundStyle(T.sub).fixedSize(horizontal: false, vertical: true)
        }
    }

    private var bottom: some View {
        VStack(spacing: 12) {
            if page == .offer {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let active = (state.data.offerExpiresAt ?? .distantPast) > context.date
                    PrimaryButton(title: active ? "Nhận ưu đãi · 39,99 US$/năm" : "Ưu đãi đã hết hạn", enabled: active) { notice = .activate }
                }
            } else {
                PrimaryButton(title: page == .gift ? (openingGift ? "Đang mở quà…" : "Mở quà") : "Dùng thử 3 ngày", enabled: !openingGift) {
                    if page == .gift {
                        openingGift = true
                    } else {
                        state.data.sawOffer = true
                        page = .gift
                    }
                }.accessibilityIdentifier(page == .gift ? "pro.open-gift" : "pro.trial")
            }
            if page != .plans { legalLinks }
            Text("Bản demo · chưa kết nối thanh toán · không trừ tiền.")
                .font(T.font(11)).foregroundStyle(T.faint).multilineTextAlignment(.center)
        }.padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 12).background(T.bg)
    }

    private var legalLinks: some View {
        HStack(spacing: 12) {
            Button("Khôi phục\nmua hàng") { notice = .restore }
            Button("Điều khoản") { legal = "Điều khoản" }
            Button("Quyền riêng tư") { legal = "Quyền riêng tư" }
            Image(systemName: "lock").accessibilityHidden(true)
        }.font(T.font(11)).foregroundStyle(T.sub).buttonStyle(.plain).frame(minHeight: 44)
    }
    private func close() {
        if page == .plans && firstTime && state.data.sawOffer != true {
            state.data.sawOffer = true
            page = .gift
        } else { exit() }
    }
    private func exit() { if firstTime { state.data.sawPro = true } else { dismiss() } }
    private func activate() { state.data.demoProPlan = page == .offer ? "year-offer" : (yearly ? "year" : "month"); state.data.isPro = true; exit() }
    private func benefit(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark").font(T.font(16, .medium)).foregroundStyle(T.text)
            Text(text).font(T.font(15)).foregroundStyle(T.sub).fixedSize(horizontal: false, vertical: true)
        }
    }
    private func timerUnit(_ number: Int, label: String) -> some View {
        VStack(spacing: 6) {
            Text(String(format: "%02d", number)).font(T.num(32, .bold)).foregroundStyle(T.text)
                .frame(width: 66, height: 50).background(T.surface, in: RoundedRectangle(cornerRadius: 14))
            Text(label).font(T.font(11, .medium)).foregroundStyle(T.sub)
        }
    }
    private func plan(title: String, price: String, note: String, selected: Bool, pick: @escaping () -> Void) -> some View {
        Button(action: pick) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title).font(T.font(18, .semibold)).foregroundStyle(T.text)
                    Text(note).font(T.font(12)).foregroundStyle(T.sub)
                }
                Spacer(minLength: 4)
                Text(price).font(T.num(16, .bold)).foregroundStyle(T.text)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle").font(T.font(23)).foregroundStyle(selected ? T.lime : T.faint)
            }.padding(17).frame(minHeight: 88)
                .background(T.surface, in: RoundedRectangle(cornerRadius: 21))
                .overlay(RoundedRectangle(cornerRadius: 21).stroke(selected ? T.lime.opacity(0.7) : T.line, lineWidth: 1.3))
        }.buttonStyle(.plain).accessibilityAddTraits(selected ? .isSelected : [])
            .accessibilityIdentifier(selected ? "pro.plan.selected" : "pro.plan.unselected")
    }
}



/// The gift is already open on the previous page, so no box here: the discount
/// itself is the hero, lit by the lime glow left from the unboxing. Entrance once;
/// Reduce Motion shows the end state.
private struct OfferHero: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var risen = false
    var body: some View {
        ZStack {
            Circle().fill(T.lime.opacity(0.22)).frame(width: 240, height: 240).blur(radius: 70)
                .scaleEffect(risen ? 1 : 0.6).opacity(risen ? 1 : 0)
            VStack(spacing: 4) {
                Text("Quà của bạn").font(T.font(14, .semibold)).foregroundStyle(T.lime)
                Text("−50%").font(T.num(104, .heavy)).foregroundStyle(T.lime)
                    .lineLimit(1).minimumScaleFactor(0.6)
                    .shadow(color: T.lime.opacity(0.45), radius: 30)
                    .scaleEffect(risen ? 1 : 0.7).opacity(risen ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity).frame(height: 230).padding(.top, 36)
        .accessibilityElement(children: .ignore).accessibilityLabel("Quà của bạn: giảm 50%")
        .onAppear {
            if reduceMotion { risen = true } else { withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) { risen = true } }
        }
    }
}
