import ComposableArchitecture

public struct SplashCore: ReducerProtocol {
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
