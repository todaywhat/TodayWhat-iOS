import ComposableArchitecture
import SwiftUI
import SplashFeature
import SchoolSettingFeature
import MainFeature

public struct RootView: View {
    private let store: StoreOf<RootCore>
    
    public init(store: StoreOf<RootCore>) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            switch $0 {
            case .splashCore:
                VStack {
                    CaseLet(state: /RootCore.State.splashCore, action: RootCore.Action.splashCore) { store in
                        SplashView(store: store)
                    }
                }

            case .schoolSettingCore:
                VStack {
                    CaseLet(state: /RootCore.State.schoolSettingCore, action: RootCore.Action.schoolSettingCore) { store in
                        SchoolSettingView(store: store)
                    }
                }

            case .mainCore:
                VStack {
                    CaseLet(state: /RootCore.State.mainCore, action: RootCore.Action.mainCore) { store in
                        MainView(store: store)
                    }
                }
            }
        }
    }
}
