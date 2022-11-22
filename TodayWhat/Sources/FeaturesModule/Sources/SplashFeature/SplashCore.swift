import ComposableArchitecture
import UserDefaultsClient

public struct SplashCore: ReducerProtocol {
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

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize:
                guard
                    let code = userDefaultsClient.getValue(key: .schoolCode, type: String.self),
                    !code.isEmpty,
                    let orgCode = userDefaultsClient.getValue(key: .orgCode, type: String.self),
                    !orgCode.isEmpty,
                    userDefaultsClient.getValue(key: .grade, type: Int.self) != nil,
                    userDefaultsClient.getValue(key: .class, type: Int.self) != nil,
                    let school = userDefaultsClient.getValue(key: .school, type: String.self),
                    !school.isEmpty,
                    let type = userDefaultsClient.getValue(key: .schoolType, type: String.self),
                    !type.isEmpty
                else {
                    return .run { send in
                        await send(.userInfoIsRequired)
                    }
                }
                return .run { send in
                    await send(.userInfoIsExist)
                }
            
            default:
                return .none
            }
            return .none
        }
    }
}
