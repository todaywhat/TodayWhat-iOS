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
        public var isLoading = false
        public var allergyList: [AllergyType] = []
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case refresh
        case mealResponse(TaskResult<Meal>)
    }

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                do {
                    state.allergyList = try localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
                        .compactMap { AllergyType(rawValue: $0.allergy) ?? nil }
                } catch { }
                state.isLoading = true
                return .task {
                    .mealResponse(
                        await TaskResult {
                            try await mealClient.fetchMeal(Date())
                        }
                    )
                }

            case .refresh:
                state.isLoading = true
                return .task {
                    .mealResponse(
                        await TaskResult {
                            try await mealClient.fetchMeal(Date())
                        }
                    )
                }

            case let .mealResponse(.success(meal)):
                state.meal = meal
                state.isLoading = false

            case let .mealResponse(.failure(error)):
                state.isError = true
                state.errorMessage = error.localizedDescription
                state.isLoading = false

            default:
                return .none
            }
            return .none
        }
    }
}
