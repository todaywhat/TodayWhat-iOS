import ComposableArchitecture

public struct RootCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            
            default:
                return .none
            }
        }
    }
}
