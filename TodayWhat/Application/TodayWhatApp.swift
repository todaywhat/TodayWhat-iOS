import SwiftUI
import RootFeature
import ComposableArchitecture

@main
struct TodayWhatApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: .init(
                    initialState: .init(),
                    reducer: RootCore()
                )
            )
        }
    }
}
