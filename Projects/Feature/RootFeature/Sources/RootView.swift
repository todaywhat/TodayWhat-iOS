import ComposableArchitecture
import MainFeature
import OnboardingFeature
import SplashFeature
import SwiftUI

public struct RootView<SiriSection: View>: View {
    private let store: StoreOf<RootCore>
    private let siriSection: SiriSection

    public init(store: StoreOf<RootCore>, @ViewBuilder siriSection: () -> SiriSection) {
        self.store = store
        self.siriSection = siriSection()
    }

    public var body: some View {
        SwitchStore(store) {
            switch $0 {
            case .splashCore:
                CaseLet(/RootCore.State.splashCore, action: RootCore.Action.splashCore) { store in
                    SplashView(store: store)
                }

            case .onboardingCore:
                CaseLet(/RootCore.State.onboardingCore, action: RootCore.Action.onboardingCore) { store in
                    OnboardingView(store: store) { siriSection }
                }

            case .mainCore:
                CaseLet(/RootCore.State.mainCore, action: RootCore.Action.mainCore) { store in
                    MainView(store: store)
                }
            }
        }
    }
}

extension RootView where SiriSection == EmptyView {
    public init(store: StoreOf<RootCore>) {
        self.store = store
        self.siriSection = EmptyView()
    }
}
