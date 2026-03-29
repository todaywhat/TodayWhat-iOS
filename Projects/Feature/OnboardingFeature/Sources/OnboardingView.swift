import ComposableArchitecture
import AddWidgetFeature
import SwiftUI

public struct OnboardingView: View {
    private let store: StoreOf<OnboardingCore>

    public init(store: StoreOf<OnboardingCore>) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            switch $0 {
            case .ahaMoment:
                CaseLet(/OnboardingCore.State.ahaMoment, action: OnboardingCore.Action.ahaMomentCore) { store in
                    AhaMomentView(store: store)
                }

            case .addWidget:
                CaseLet(/OnboardingCore.State.addWidget, action: OnboardingCore.Action.addWidgetCore) { store in
                    AddWidgetView(store: store)
                }
            }
        }
    }
}
