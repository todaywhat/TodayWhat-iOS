import ComposableArchitecture
import UserDefaultsClient

public struct MainCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var school = ""
        public var grade = ""
        public var `class` = ""
        public var currentTab = 0
        
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case tabChanged(Int)
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.school = userDefaultsClient.getValue(key: .school, type: String.self) ?? ""
                state.grade = "\(userDefaultsClient.getValue(key: .grade, type: Int.self) ?? 1)"
                state.class = "\(userDefaultsClient.getValue(key: .class, type: Int.self) ?? 1)"

            case let .tabChanged(tab):
                state.currentTab = tab
            
            default:
                return .none
            }
            return .none
        }
    }
}
