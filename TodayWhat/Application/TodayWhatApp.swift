import SwiftUI

@main
struct TodayWhatApp: App {
    var body: some Scene {
        WindowGroup {
            SchoolSettingView(
                store: .init(
                    initialState: .init(),
                    reducer: SchoolSettingCore()
                )
            )
        }
    }
}
