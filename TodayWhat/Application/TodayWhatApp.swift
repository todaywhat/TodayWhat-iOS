import SwiftUI
import RootFeature
import ComposableArchitecture
import UIKit

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

extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
