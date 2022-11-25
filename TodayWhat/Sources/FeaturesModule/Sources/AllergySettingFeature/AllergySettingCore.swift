import ComposableArchitecture

public struct AllergySettingCore: ReducerProtocol {
    public init() {}
    public enum State: Equatable {
        
        public init() { self = .splashCore(.init()) }
    }

    public enum Action: Equatable {
        
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            
            default:
                return .none
            }
            return .none
        }
    }
}
