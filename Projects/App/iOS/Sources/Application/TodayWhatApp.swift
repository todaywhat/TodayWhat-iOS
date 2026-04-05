import AppIntents
import AppRouteClient
import ComposableArchitecture
import Firebase
import FirebaseCore
import RootFeature
import SwiftUI
import UIKit
import UserDefaultsClient

@main
@MainActor
struct TodayWhatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    init() {
        let appOpenCount = (userDefaultsClient.getValue(.appOpenCount) as? Int) ?? 0
        userDefaultsClient.setValue(.appOpenCount, appOpenCount + 1)

        if #available(iOS 16, *) {
            AppDependencyManager.shared.add(dependency: TodayWhatAppRouteStore.shared)
            TodayWhatAppShortcuts.updateAppShortcutParameters()
        }
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
            .onOpenURL { url in
                guard let route = TodayWhatAppRoute.from(url: url) else { return }
                TodayWhatAppRouteStore.shared.request(route)
            }
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
