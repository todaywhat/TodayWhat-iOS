import ComposableArchitecture
import Entity

public struct MealCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var meal: Meal?
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
