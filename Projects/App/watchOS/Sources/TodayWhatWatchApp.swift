import SwiftUI

@main
struct TodayWhatWatchApp: App {
    @StateObject var sceneFlowState = SceneFlowState()

    init() {
        WatchSessionManager.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                RootView()
                    .environmentObject(sceneFlowState)
            }
        }
    }
}
