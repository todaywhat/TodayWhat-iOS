import ComposableArchitecture
import Firebase
import FirebaseCore
import RootFeature
import SwiftUI
import UIKit
import UserDefaultsClient

@main
struct TodayWhatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    init() {
        let appOpenCount = (userDefaultsClient.getValue(.appOpenCount) as? Int) ?? 0
        userDefaultsClient.setValue(.appOpenCount, appOpenCount + 1)
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                store: .init(
                    initialState: .init(),
                    reducer: {
                        RootCore()
                    }
                )
            )
        }
    }
}

extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
