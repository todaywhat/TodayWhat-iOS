import ComposableArchitecture

public struct AllergySettingCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        
        public init() {}
    }

    public enum Action: Equatable {
        
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            
            return .none
        }
    }
}
