import ComposableArchitecture
import Entity
import EnumUtil
import Foundation
import LocalDatabaseClient
import MealClient
import Sharing
import UserDefaultsClient

public struct WeeklyMealCore: Reducer {
    private enum CancellableID: Hashable {
        case fetch
    }

    public init() {}

    public struct State: Equatable {
        public struct DayMeal: Equatable {
            public let date: Date
            public let meal: Meal

            public init(date: Date, meal: Meal) {
                self.date = date
                self.meal = meal
            }

            public var isEmpty: Bool {
                meal.breakfast.meals.isEmpty &&
                    meal.lunch.meals.isEmpty &&
                    meal.dinner.meals.isEmpty
            }
        }

        public var weeklyMeals: [DayMeal] = []
        public var isLoading = false
        public var allergyList: [AllergyType] = []
        public var showWeekend = false
        public var currentTimeMealType: MealType = .breakfast
        public var today: Date = Date()
        @Shared public var displayDate: Date

        public init(displayDate: Shared<Date>) {
            self._displayDate = displayDate
        }
    }

    public enum Action: Equatable {
        case onLoad
        case onAppear
        case refresh
        case refreshData
        case settingsButtonDidTap
        case mealsResponse(TaskResult<[Date: Meal]>)
    }

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.date) var dateGenerator

    public var body: some ReducerOf<WeeklyMealCore> {
        Reduce { state, action in
            switch action {
            case .onLoad:
                do {
                    state.allergyList = try localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
                        .compactMap { AllergyType(rawValue: $0.allergy) ?? nil }
                } catch {}

                state.showWeekend = !(userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false)
                state.isLoading = true

                let displayDate = state.displayDate
                let showWeekend = state.showWeekend

                return .merge(
                    fetchWeeklyMeals(displayDate: displayDate, showWeekend: showWeekend),
                    .publisher {
                        state.$displayDate.publisher
                            .map { _ in Action.refreshData }
                    }
                )

            case .onAppear:
                do {
                    state.allergyList = try localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
                        .compactMap { AllergyType(rawValue: $0.allergy) ?? nil }
                } catch {}

                state.showWeekend = !(userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false)
                state.isLoading = true

                let displayDate = state.displayDate
                let showWeekend = state.showWeekend

                return fetchWeeklyMeals(displayDate: displayDate, showWeekend: showWeekend)

            case .refresh:
                return .send(.refreshData)

            case .refreshData:
                state.showWeekend = !(userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false)
                state.isLoading = true

                let displayDate = state.displayDate
                let showWeekend = state.showWeekend

                return fetchWeeklyMeals(displayDate: displayDate, showWeekend: showWeekend)

            case let .mealsResponse(.success(mealDictionary)):
                state.isLoading = false

                let calendar = Calendar.current
                let sortedEntries = mealDictionary
                    .map { (calendar.startOfDay(for: $0.key), $0.value) }
                    .sorted { $0.0 < $1.0 }
                state.weeklyMeals = sortedEntries.map { entry in
                    State.DayMeal(date: entry.0, meal: entry.1)
                }

                let now = dateGenerator.now
                state.today = now
                let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false
                state.currentTimeMealType = MealType(hour: now, isSkipWeekend: isSkipWeekend)

            case .mealsResponse(.failure):
                state.isLoading = false
                state.weeklyMeals = []

            case .settingsButtonDidTap:
                break
            }
            return .none
        }
    }

    private func fetchWeeklyMeals(displayDate: Date, showWeekend: Bool) -> Effect<Action> {
        var isoCalendar = Calendar(identifier: .iso8601)
        isoCalendar.timeZone = Calendar.current.timeZone
        isoCalendar.locale = Calendar.current.locale
        let components = isoCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: displayDate)
        let mondayDate = isoCalendar.date(from: components) ?? displayDate
        let dayCount = showWeekend ? 7 : 5

        return .concatenate(
            .cancel(id: CancellableID.fetch),
            .run { [mondayDate, dayCount] send in
                let response = await Action.mealsResponse(
                    TaskResult {
                        try await mealClient.fetchMeals(mondayDate, dayCount)
                    }
                )
                await send(response)
            }
            .cancellable(id: CancellableID.fetch, cancelInFlight: true)
        )
    }
}
