import SwiftUI

@main
struct TodayWhat_Mac_App: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: .init(
                    initialState: .init(),
                    reducer: ContentCore()
                )
            )
        }
    }
}
