import ComposableArchitecture
import Entity
import MealClient
import Foundation

public struct MealCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var meal: Meal?
        public var isError = false
        public var errorMessage = ""
        public init() {}
    }

    public enum Action: Equatable {
        case initialize
        case refresh
        case mealResponse(TaskResult<Meal>)
    }

    @Dependency(\.mealClient) var mealClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize, .refresh:
                return .task {
                    .mealResponse(
                        await TaskResult {
                            try await mealClient.fetchMeal(Date())
                        }
                    )
                }

            case let .mealResponse(.success(meal)):
                state.meal = meal

            case let .mealResponse(.failure(error)):
                state.isError = true
                state.errorMessage = error.localizedDescription
                
            default:
                return .none
            }
            return .none
        }
    }
}
