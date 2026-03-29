import ComposableArchitecture
import DateUtil
import Entity
import Foundation
import MealClient
import TimeTableClient
import TWLog
import UserDefaultsClient

public struct AhaMomentCore: Reducer {
    public init() {}

    public struct State: Equatable {
        public var meal: Meal?
        public var timeTable: [TimeTable] = []
        public var isLoading = true
        public var displayDate: Date = Date()
        public var isNextSchoolDay = false
        public var schoolName: String = ""
        public var grade: Int = 0
        public var `class`: Int = 0
        public var hasError = false

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case mealResponse(TaskResult<Meal>)
        case timeTableResponse(TaskResult<[TimeTable]>)
        case nextButtonTapped
    }

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    public var body: some ReducerOf<AhaMomentCore> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let schoolName = userDefaultsClient.getValue(.school) as? String ?? ""
                let grade = userDefaultsClient.getValue(.grade) as? Int ?? 0
                let classNum = userDefaultsClient.getValue(.class) as? Int ?? 0
                state.schoolName = schoolName
                state.grade = grade
                state.class = classNum

                // Find the appropriate date (today or next school day)
                var targetDate = Date()
                let weekday = targetDate.weekday

                // If weekend, find next Monday
                if weekday == 1 { // Sunday
                    targetDate = targetDate.adding(by: .day, value: 1)
                    state.isNextSchoolDay = true
                } else if weekday == 7 { // Saturday
                    targetDate = targetDate.adding(by: .day, value: 2)
                    state.isNextSchoolDay = true
                }

                state.displayDate = targetDate

                let hasData = !state.isNextSchoolDay
                TWLog.event(DefaultEventLog(
                    name: "onboarding_aha_moment_reached",
                    params: [
                        "has_data": "\(hasData)",
                        "is_next_school_day": "\(state.isNextSchoolDay)"
                    ]
                ))

                let date = targetDate
                return .merge(
                    .run { send in
                        await send(.mealResponse(TaskResult { try await mealClient.fetchMeal(date) }))
                    },
                    .run { send in
                        await send(.timeTableResponse(TaskResult { try await timeTableClient.fetchTimeTable(date) }))
                    }
                )

            case let .mealResponse(.success(meal)):
                state.meal = meal
                state.isLoading = false
                return .none

            case .mealResponse(.failure):
                state.isLoading = false
                state.hasError = true
                return .none

            case let .timeTableResponse(.success(timeTable)):
                state.timeTable = timeTable
                return .none

            case .timeTableResponse(.failure):
                return .none

            case .nextButtonTapped:
                return .none
            }
        }
    }
}
