import ComposableArchitecture
import UserDefaultsClient

public struct SplashCore: Reducer {
    public init() {}
    public struct State: Equatable {
        
        public init() {}
    }

    public enum Action: Equatable {
        case initialize
        case userInfoIsRequired
        case userInfoIsExist
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient

    public var body: some ReducerOf<SplashCore> {
        Reduce { state, action in
            switch action {
            case .initialize:
                guard
                    let code = userDefaultsClient.getValue(.schoolCode) as? String,
                    !code.isEmpty,
                    let orgCode = userDefaultsClient.getValue(.orgCode) as? String,
                    !orgCode.isEmpty,
                    userDefaultsClient.getValue(.grade) as? Int != nil,
                    userDefaultsClient.getValue(.class) as? Int != nil,
                    let school = userDefaultsClient.getValue(.school) as? String,
                    !school.isEmpty,
                    let type = userDefaultsClient.getValue(.schoolType) as? String,
                    !type.isEmpty
                else {
                    return .run { send in
                        await send(.userInfoIsRequired, animation: .default)
                    }
                }
                return .run { send in
                    await send(.userInfoIsExist, animation: .default)
                }
            
            default:
                return .none
            }
            return .none
        }
    }
}
