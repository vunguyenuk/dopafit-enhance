import SwiftUI

@main
struct DopafitV2App: App {
    @StateObject private var state = AppState()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
                .preferredColorScheme(.dark)
                .tint(T.lime)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.scenePhase) private var phase
    @State private var splash = true

    var body: some View {
        T.scale = CGFloat(state.data.textScale)
        return Group {
            if !state.data.onboarded {
                OnboardingFlow()
            } else if !state.data.sawPro {
                ProPaywall(firstTime: true)
            } else {
                MainTabs()
            }
        }
        .id(state.data.textScale)
        .lineSpacing(3 * T.scale) // mặc định cho mọi đoạn chữ nhiều dòng
        .overlay { if splash { LaunchSplash { splash = false }.transition(.opacity) } }
        .onChange(of: phase) { _, p in if p == .active { state.resetDailyIfNeeded() } }
    }
}

struct MainTabs: View {
    @EnvironmentObject var state: AppState
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            WorkoutTab()
                .tabItem { Label("Buổi tập", systemImage: "dumbbell") }
                .tag(0)
            ProgressTab()
                .tabItem { Label("Tiến bộ", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(1)
            LogTab()
                .tabItem { Label("Nhật ký", systemImage: "calendar") }
                .tag(2)
        }
        .fullScreenCover(isPresented: Binding(get: { state.active != nil }, set: { if !$0 { state.active = nil } })) {
            ActiveWorkoutView()
                .environmentObject(state)
        }
        .sheet(item: $state.lastFinished) { s in
            SummaryView(session: s)
                .environmentObject(state)
                .presentationDetents([.large])
        }
    }
}
