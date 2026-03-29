import ComposableArchitecture
import MainFeature
import OnboardingFeature
import SchoolSettingFeature
import SplashFeature
import UserDefaultsClient

public struct RootCore: Reducer {
    public init() {}
    public enum State: Equatable {
        case splashCore(SplashCore.State)
        case schoolSettingCore(SchoolSettingCore.State)
        case onboardingCore(OnboardingCore.State)
        case mainCore(MainCore.State)

        public init() { self = .splashCore(.init()) }
    }

    public enum Action {
        case splashCore(SplashCore.Action)
        case schoolSettingCore(SchoolSettingCore.Action)
        case onboardingCore(OnboardingCore.Action)
        case mainCore(MainCore.Action)
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .splashCore(.userInfoIsRequired):
                state = .schoolSettingCore(.init())

            case .splashCore(.userInfoIsExist):
                state = .mainCore(.init())

            case .schoolSettingCore(.schoolSettingFinished):
                state = .onboardingCore(.init())

            case .onboardingCore(.onboardingFinished):
                state = .mainCore(.init())

            case .mainCore(.delegate(.navigateToSchoolSetting)):
                state = .schoolSettingCore(.init())

            case .mainCore(.delegate(.navigateToGradeClassSetting)):
                state = .schoolSettingCore(.init())

            default:
                return .none
            }
            return .none
        }
        .ifCaseLet(/State.splashCore, action: /Action.splashCore) {
            SplashCore()
        }
        .ifCaseLet(/State.schoolSettingCore, action: /Action.schoolSettingCore) {
            SchoolSettingCore()
        }
        .ifCaseLet(/State.onboardingCore, action: /Action.onboardingCore) {
            OnboardingCore()
        }
        .ifCaseLet(/State.mainCore, action: /Action.mainCore) {
            MainCore()
        }
    }
}
