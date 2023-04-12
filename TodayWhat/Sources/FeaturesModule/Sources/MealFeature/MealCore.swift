import ComposableArchitecture
import Entity
import MealClient
import LocalDatabaseClient
import UserDefaultsClient
import Foundation
import EnumUtil

public struct MealCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var meal: Meal?
        public var isLoading = false
        public var allergyList: [AllergyType] = []
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case refresh
        case settingsButtonDidTap
        case mealResponse(TaskResult<Meal>)
    }

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient

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
                            var targetDate = Date()
                            if targetDate.hour >= 19, userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true {
                                targetDate = targetDate.adding(by: .day, value: 1)
                            }
                            return try await mealClient.fetchMeal(targetDate)
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

            case .mealResponse(.failure(_)):
                state.meal = Meal(
                    breakfast: .init(meals: [], cal: 0),
                    lunch: .init(meals: [], cal: 0),
                    dinner: .init(meals: [], cal: 0)
                )
                state.isLoading = false

            default:
                break
            }
            return .none
        }
    }
}
