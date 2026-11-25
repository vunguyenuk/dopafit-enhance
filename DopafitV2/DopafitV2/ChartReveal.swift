import SwiftUI

/// Reveals final marks, never interpolates recorded values or changes chart domains.
/// Use inside chartPlotStyle so axes, labels and accessibility data remain readable.
struct ChartReveal: ViewModifier {
    var key: String
    var vertical = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var amount: CGFloat = 1
    @State private var visible = false
    @State private var revealedKey: String?
    private var token: String { key + "-\(reduceMotion)-\(scenePhase == .active)-\(visible)" }

    func body(content: Content) -> some View {
        content.mask(alignment: vertical ? .bottom : .leading) {
            Rectangle().padding(-12)
                .scaleEffect(x: vertical ? 1 : amount, y: vertical ? amount : 1,
                             anchor: vertical ? .bottom : .leading)
        }
        .modifier(ChartVisibility(visible: $visible))
        .task(id: token) {
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) { amount = reduceMotion || scenePhase != .active || revealedKey == key ? 1 : 0 }
            guard !reduceMotion, scenePhase == .active, visible, revealedKey != key else { return }
            do {
                // Commit the initial mask before starting a single finite reveal.
                try await Task.sleep(for: .milliseconds(160))
                try Task.checkCancellation()
                withAnimation(.timingCurve(0.32, 0, 0.2, 1, duration: 0.95)) { amount = 1 }
                revealedKey = key
            } catch { /* Leaving the chart cancels the pending start. */ }
        }
    }
}

/// Keep the existing iOS 17 deployment target. Modern systems wait for the viewport;
/// the compatibility path retains the finite on-appear reveal.
private struct ChartVisibility: ViewModifier {
    @Binding var visible: Bool
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.onScrollVisibilityChange(threshold: 0.15) { visible = $0 }
        } else {
            content.onAppear { visible = true }.onDisappear { visible = false }
        }
    }
}
