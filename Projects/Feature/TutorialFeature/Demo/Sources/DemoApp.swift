import ComposableArchitecture
import SwiftUI
import TutorialClient
@testable import TutorialFeature

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                TutorialView(
                    store: Store(
                        initialState: TutorialCore.State(),
                        reducer: {
                            withDependencies {
                                $0.tutorialClient.fetchTutorialList = {
                                    return [
                                        .init(
                                            id: "1",
                                            index: 1,
                                            thumbnailImageURL: "https://github.com/baekteun/TodayWhat-new/assets/74440939/c74e4611-a15b-481d-b436-3b82bedd8391",
                                            title: "스탠바이"
                                        ),
                                        .init(
                                            id: "2",
                                            index: 2,
                                            thumbnailImageURL: "https://github.com/baekteun/TodayWhat-new/assets/74440939/c74e4611-a15b-481d-b436-3b82bedd8391",
                                            title: "위젯"
                                        )
                                    ]
                                }
                            } operation: {
                                TutorialCore()
                            }
                        }
                    )
                )
            }
        }
    }
}
