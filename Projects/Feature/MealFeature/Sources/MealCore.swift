import ComposableArchitecture
import Entity
import EnumUtil
import Foundation
import LocalDatabaseClient
import MealClient
import Sharing
import UserDefaultsClient

public struct MealCore: Reducer {
    private enum CancellableID: Hashable {
        case fetch
    }

    public init() {}

    public struct State: Equatable {
        public var meal: Meal?
        public var isLoading = false
        public var allergyList: [AllergyType] = []
        public var currentTimeMealType: MealType = .breakfast
        @Shared public var displayDate: Date

        public init(displayDate: Shared<Date>) {
            self._displayDate = displayDate
        }
    }

    public enum Action: Equatable {
        case onLoad
        case onAppear
        case refreshData
        case refresh
        case settingsButtonDidTap
        case mealResponse(TaskResult<Meal>)
    }

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.date) var dateGenerator

    public var body: some ReducerOf<MealCore> {
        Reduce { state, action in
            switch action {
            case .onLoad:
                return .publisher {
                    state.$displayDate.publisher
                        .map { _ in
                            return Action.refreshData
                        }
                }

            case .onAppear:
                do {
                    state.allergyList = try localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
                        .compactMap { AllergyType(rawValue: $0.allergy) ?? nil }
                } catch {}
                state.isLoading = true

                var displayDate = state.displayDate

                return .run { [displayDate] send in
                    let task = await Action.mealResponse(
                        TaskResult {
                            try await mealClient.fetchMeal(displayDate)
                        }
                    )
                    await send(task)
                }

            case .refreshData:
                state.isLoading = true

                var displayDate = state.displayDate

                return .concatenate(
                    .cancel(id: CancellableID.fetch),
                    .run { [displayDate] send in
                        let task = await Action.mealResponse(
                            TaskResult {
                                try await mealClient.fetchMeal(displayDate)
                            }
                        )
                        await send(task)
                    }
                    .cancellable(id: CancellableID.fetch)
                )

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
