import ComposableArchitecture
import AddWidgetFeature
import TWLog

public struct OnboardingCore: Reducer {
    public init() {}

    public enum State: Equatable {
        case ahaMoment(AhaMomentCore.State)
        case addWidget(AddWidgetCore.State)

        public init() { self = .ahaMoment(.init()) }
    }

    public enum Action {
        case ahaMomentCore(AhaMomentCore.Action)
        case addWidgetCore(AddWidgetCore.Action)
        case onboardingFinished
    }

    public var body: some ReducerOf<OnboardingCore> {
        Reduce { state, action in
            switch action {
            case .ahaMomentCore(.nextButtonTapped):
                TWLog.event(DefaultEventLog(name: "onboarding_widget_guide_viewed", params: [:]))
                state = .addWidget(.init())
                return .none

            case .addWidgetCore(.addWidgetComplete):
                return .run { send in
                    await send(.onboardingFinished, animation: .default)
                }

            default:
                return .none
            }
        }
        .ifCaseLet(/State.ahaMoment, action: /Action.ahaMomentCore) {
            AhaMomentCore()
        }
        .ifCaseLet(/State.addWidget, action: /Action.addWidgetCore) {
            AddWidgetCore()
        }
    }
}
