import SwiftUI

@main
struct TodayWhat_Watch_AppApp: App {
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
