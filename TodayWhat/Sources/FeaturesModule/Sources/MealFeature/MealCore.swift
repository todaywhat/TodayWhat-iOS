import ComposableArchitecture
import Entity
import MealClient
import LocalDatabaseClient
import Foundation
import EnumUtil

public struct MealCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var meal: Meal?
        public var isError = false
        public var errorMessage = ""
        public var allergyList: [AllergyType] = []
        public init() {}
    }

    public enum Action: Equatable {
        case initialize
        case refresh
        case mealResponse(TaskResult<Meal>)
    }

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize:
                do {
                    state.allergyList = try localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
                        .compactMap { AllergyType(rawValue: $0.allergy) ?? nil }
                } catch { }
                return .task {
                    .mealResponse(
                        await TaskResult {
                            try await mealClient.fetchMeal(Date())
                        }
                    )
                }

            case .refresh:
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
