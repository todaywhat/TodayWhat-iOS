import ComposableArchitecture
import MainFeature
import SchoolSettingFeature
import SplashFeature
import UserDefaultsClient

public struct RootCore: Reducer {
    public init() {}
    public enum State: Equatable {
        case splashCore(SplashCore.State)
        case schoolSettingCore(SchoolSettingCore.State)
        case mainCore(MainCore.State)

        public init() { self = .splashCore(.init()) }
    }

    public enum Action {
        case splashCore(SplashCore.Action)
        case schoolSettingCore(SchoolSettingCore.Action)
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
                state = .mainCore(.init())

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
        .ifCaseLet(/State.mainCore, action: /Action.mainCore) {
            MainCore()
        }
    }
}
