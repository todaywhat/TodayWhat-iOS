import SwiftUI

@main
struct TodayWhatWatchApp: App {
    @StateObject var sceneFlowState = SceneFlowState()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                RootView()
                    .environmentObject(sceneFlowState)
            }
        }
    }
}
