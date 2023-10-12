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
        public var currentTimeMealType: MealType = .breakfast
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
    @Dependency(\.date) var dateGenerator

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                do {
                    state.allergyList = try localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
                        .compactMap { AllergyType(rawValue: $0.allergy) ?? nil }
                } catch { }
                state.isLoading = true

                var todayDate = Date()
                if userDefaultsClient.getValue(.isSkipWeekend) as? Bool == true {
                    if todayDate.weekday == 7 {
                        todayDate = todayDate.adding(by: .day, value: 2)
                    } else if todayDate.weekday == 1 {
                        todayDate = todayDate.adding(by: .day, value: 1)
                    }
                } else if todayDate.hour >= 19, userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true {
                    todayDate = todayDate.adding(by: .day, value: 1)
                }

                return .task { [todayDate] in
                    .mealResponse(
                        await TaskResult {
                            try await mealClient.fetchMeal(todayDate)
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
                let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false
                state.currentTimeMealType = MealType(hour: dateGenerator.now, isSkipWeekend: isSkipWeekend)
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
