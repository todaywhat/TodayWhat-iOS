import BaseFeature
import ComposableArchitecture
import DateUtil
import Entity
import Foundation
import MealClient
import SchoolSettingFeature
import TimeTableClient
import TWLog

public struct OnboardingCore: Reducer {
    public init() {}

    public enum Step: Int, CaseIterable, Equatable {
        case school
        case meal
        case timetable
        case widget
        case ecosystem

        public var index: Int { rawValue + 1 }
        public var totalCount: Int { Self.allCases.count }
    }

    public struct State: Equatable {
        public var step: Step
        public var schoolSettingCore: SchoolSettingCore.State
        public var schoolName: String
        public var meal: Meal?
        public var mealUsesFallback: Bool
        public var isMealLoading: Bool
        public var mealDisplayDate: Date
        public var timeTables: [TimeTable]
        public var timeTableUsesFallback: Bool
        public var isTimeTableLoading: Bool
        public var timeTableDisplayDate: Date

        public init(
            step: Step = .school,
            schoolSettingCore: SchoolSettingCore.State = .init(),
            schoolName: String = "",
            meal: Meal? = nil,
            mealUsesFallback: Bool = false,
            isMealLoading: Bool = false,
            mealDisplayDate: Date = Date(),
            timeTables: [TimeTable] = [],
            timeTableUsesFallback: Bool = false,
            isTimeTableLoading: Bool = false,
            timeTableDisplayDate: Date = Date()
        ) {
            self.step = step
            self.schoolSettingCore = schoolSettingCore
            self.schoolName = schoolName
            self.meal = meal
            self.mealUsesFallback = mealUsesFallback
            self.isMealLoading = isMealLoading
            self.mealDisplayDate = mealDisplayDate
            self.timeTables = timeTables
            self.timeTableUsesFallback = timeTableUsesFallback
            self.isTimeTableLoading = isTimeTableLoading
            self.timeTableDisplayDate = timeTableDisplayDate
        }

        public var progressText: String {
            "\(step.index) / \(step.totalCount)"
        }

        public var progressValue: Double {
            Double(step.index) / Double(step.totalCount)
        }
    }

    @CasePathable
    public enum Action: Equatable {
        case onAppear
        case schoolSettingCore(SchoolSettingCore.Action)
        case backButtonDidTap
        case nextButtonDidTap
        case fetchPreviewData
        case fetchMeal(Date)
        case mealResponse(Date, TaskResult<Meal>)
        case fetchTimeTable(Date)
        case timeTableResponse(Date, TaskResult<[TimeTable]>)
        case onboardingFinished
    }

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.timeTableClient) var timeTableClient

    public var body: some ReducerOf<OnboardingCore> {
        Scope(state: \.schoolSettingCore, action: \.schoolSettingCore) {
            SchoolSettingCore()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                self.logStepShowed(step: state.step)
                return .none

            case .schoolSettingCore(.schoolSettingFinished):
                state.schoolName = state.schoolSettingCore.school
                state.step = .meal
                state.isMealLoading = true
                state.isTimeTableLoading = true
                self.logStepShowed(step: state.step)
                return .send(.fetchPreviewData)

            case .schoolSettingCore:
                return .none

            case .backButtonDidTap:
                switch state.step {
                case .school:
                    return .none
                case .meal:
                    state.step = .school
                case .timetable:
                    state.step = .meal
                case .widget:
                    state.step = .timetable
                case .ecosystem:
                    state.step = .widget
                }
                self.logStepShowed(step: state.step)
                return .none

            case .nextButtonDidTap:
                switch state.step {
                case .school:
                    return .none
                case .meal:
                    state.step = .timetable
                case .timetable:
                    state.step = .widget
                case .widget:
                    state.step = .ecosystem
                case .ecosystem:
                    return .send(.onboardingFinished)
                }
                self.logStepShowed(step: state.step)
                return .none


            case .fetchPreviewData:
                let targetDate = schoolDay(from: Date())
                state.mealDisplayDate = targetDate
                state.timeTableDisplayDate = targetDate
                return .merge(
                    .send(.fetchMeal(targetDate)),
                    .send(.fetchTimeTable(targetDate))
                )

            case let .fetchMeal(targetDate):
                return .run { send in
                    await send(
                        .mealResponse(
                            targetDate,
                            TaskResult {
                                try await mealClient.fetchMeal(targetDate)
                            }
                        )
                    )
                }

            case let .mealResponse(targetDate, .success(meal)):
                state.mealDisplayDate = targetDate
                state.meal = meal.isEmpty ? nil : meal
                state.mealUsesFallback = meal.isEmpty
                state.isMealLoading = false
                return .none

            case let .mealResponse(targetDate, .failure):
                state.mealDisplayDate = targetDate
                state.meal = nil
                state.mealUsesFallback = true
                state.isMealLoading = false
                return .none

            case let .fetchTimeTable(targetDate):
                return .run { send in
                    await send(
                        .timeTableResponse(
                            targetDate,
                            TaskResult {
                                try await timeTableClient.fetchTimeTable(targetDate)
                            }
                        )
                    )
                }

            case let .timeTableResponse(targetDate, .success(timeTables)):
                let sorted = timeTables
                    .filter { !$0.content.isEmpty }
                    .sorted { $0.perio < $1.perio }
                state.timeTableDisplayDate = targetDate
                state.timeTables = sorted
                state.timeTableUsesFallback = sorted.isEmpty
                state.isTimeTableLoading = false
                return .none

            case let .timeTableResponse(targetDate, .failure):
                state.timeTableDisplayDate = targetDate
                state.timeTables = []
                state.timeTableUsesFallback = true
                state.isTimeTableLoading = false
                return .none

            case .onboardingFinished:
                TWLog.event(OnboardingCompleteEventLog())
                return .none
            }
        }
    }

    private func schoolDay(from date: Date) -> Date {
        switch date.weekday {
        case 7:
            return date.adding(by: .day, value: 2)
        case 1:
            return date.adding(by: .day, value: 1)
        default:
            return date
        }
    }

    private func logStepShowed(step: Step) {
        let log = PageShowedEventLog(pageName: onboardingPageName(for: step))
        TWLog.event(log)
    }

    private func onboardingPageName(for step: Step) -> String {
        switch step {
        case .school:
            return "onboarding_school_page"
        case .meal:
            return "onboarding_meal_page"
        case .timetable:
            return "onboarding_timetable_page"
        case .widget:
            return "onboarding_widget_page"
        case .ecosystem:
            return "onboarding_ecosystem_page"
        }
    }
}
