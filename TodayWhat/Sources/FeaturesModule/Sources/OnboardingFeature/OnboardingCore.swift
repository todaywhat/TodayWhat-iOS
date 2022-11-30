import ComposableArchitecture
import UserDefaultsClient

public struct OnboardingCore: ReducerProtocol {
    public init() {}
    public enum State: Equatable {
        
        public init() {}
    }

    public enum Action: Equatable {
        
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            
            default:
                return .none
            }
            return .none
        }
    }
}
