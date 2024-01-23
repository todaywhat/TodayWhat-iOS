import ComposableArchitecture
import MainFeature
import SchoolSettingFeature
import SplashFeature
import SwiftUI

public struct RootView: View {
    private let store: StoreOf<RootCore>

    public init(store: StoreOf<RootCore>) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            switch $0 {
            case .splashCore:
                CaseLet(/RootCore.State.splashCore, action: RootCore.Action.splashCore) { store in
                    SplashView(store: store)
                }

            case .schoolSettingCore:
                CaseLet(/RootCore.State.schoolSettingCore, action: RootCore.Action.schoolSettingCore) { store in
                    SchoolSettingView(store: store)
                }

            case .mainCore:
                CaseLet(/RootCore.State.mainCore, action: RootCore.Action.mainCore) { store in
                    MainView(store: store)
                }
            }
        }
    }
}
