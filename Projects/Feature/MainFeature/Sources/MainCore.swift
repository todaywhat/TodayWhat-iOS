import BaseFeature
import ComposableArchitecture
import Entity
import FoundationUtil
import MealFeature
import NoticeClient
import NoticeFeature
import SettingsFeature
import Sharing
import StoreKit
import TimeTableFeature
import TWLog
import UIKit
import UserDefaultsClient

public struct MainCore: Reducer {
    public init() {}

    public struct State: Equatable {
        public enum DateSelectionMode: Equatable {
            case daily
            case weekly
        }

        public var school = ""
        public var grade = ""
        public var `class` = ""
        @Shared public var displayDate: Date
        public var currentTab = 0
        public var isInitial: Bool = true
        public var mealCore: MealCore.State?
        public var weeklyMealCore: WeeklyMealCore.State?
        public var timeTableCore: TimeTableCore.State?
        public var weeklyTimeTableCore: WeeklyTimeTableCore.State?
        @PresentationState public var settingsCore: SettingsCore.State?
        @PresentationState public var noticeCore: NoticeCore.State?
        public var isShowingReviewToast: Bool = false
        public var dateSelectionMode: DateSelectionMode = .weekly

        public var displayTitle: String {
            let calendar = Calendar.autoupdatingCurrent
            let today = Date()

            switch dateSelectionMode {
            case .daily:
                if calendar.isDate(displayDate, inSameDayAs: today) {
                    return "오늘뭐임"
                }

                if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                   calendar.isDate(displayDate, inSameDayAs: yesterday) {
                    return "어제뭐임"
                }

                if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today),
                   calendar.isDate(displayDate, inSameDayAs: tomorrow) {
                    return "내일뭐임"
                }

                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_kr")
                formatter.dateFormat = "EEEE"
                return "\(formatter.string(from: displayDate))뭐임"

            case .weekly:
                let policy = DatePolicy(isSkipWeekend: false, isSkipAfterDinner: false)
                let label = policy.weekDisplayText(for: policy.startOfWeek(for: displayDate), baseDate: today)
                return "\(label)뭐임"
            }
        }

        public init() {
            self._displayDate = Shared(value: Date())
        }
    }

    @CasePathable
    public enum Action {
        case onLoad
        case onAppear
        case tabTapped(Int)
        case tabSwiped(Int)
        case weeklyMealCore(WeeklyMealCore.Action)
        case weeklyTimeTableCore(WeeklyTimeTableCore.Action)
        case settingButtonDidTap
        case noticeButtonDidTap
        case settingsCore(PresentationAction<SettingsCore.Action>)
        case noticeCore(PresentationAction<NoticeCore.Action>)
        case dateSelected(Date)
        case showReviewToast
        case hideReviewToast
        case requestReview
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.iTunesClient) var iTunesClient
    @Dependency(\.noticeClient) var noticeClient

    public var body: some Reducer<State, Action> {
        Reduce { (state: inout MainCore.State, action: MainCore.Action) in
            switch action {
            case .onLoad:
                let pageShowedEvengLog = PageShowedEventLog(pageName: "main_page")
                TWLog.event(pageShowedEvengLog)

                let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false
                let isSkipAfterDinner = userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true

                let datePolicy = DatePolicy(
                    isSkipWeekend: isSkipWeekend,
                    isSkipAfterDinner: isSkipAfterDinner
                )

                let today = Date()
                let adjustedDate = datePolicy.adjustedDate(for: today)
                state.$displayDate.withLock { date in
                    switch state.dateSelectionMode {
                    case .daily:
                        date = adjustedDate
                    case .weekly:
                        date = datePolicy.startOfWeek(for: adjustedDate)
                    }
                }

                if shouldRequestReview() {
                    return .send(.showReviewToast)
                }

            case .onAppear:
                let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false
                let isSkipAfterDinner = userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true

                let datePolicy = DatePolicy(
                    isSkipWeekend: isSkipWeekend,
                    isSkipAfterDinner: isSkipAfterDinner
                )

                let today = Date()
                let adjustedDate = datePolicy.adjustedDate(for: today)
                state.$displayDate.withLock { date in
                    switch state.dateSelectionMode {
                    case .daily:
                        date = adjustedDate
                    case .weekly:
                        date = datePolicy.startOfWeek(for: adjustedDate)
                    }
                }

                state.school = userDefaultsClient.getValue(.school) as? String ?? ""
                state.grade = "\(userDefaultsClient.getValue(.grade) as? Int ?? 1)"
                state.class = "\(userDefaultsClient.getValue(.class) as? Int ?? 1)"

                if state.weeklyMealCore == nil {
                    state.weeklyMealCore = .init(displayDate: state.$displayDate)
                }
                if state.weeklyTimeTableCore == nil {
                    state.weeklyTimeTableCore = .init(displayDate: state.$displayDate)
                }
                return .none

            case .weeklyMealCore(.refresh), .weeklyTimeTableCore(.refresh):
                let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false
                let isSkipAfterDinner = userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true

                let datePolicy = DatePolicy(
                    isSkipWeekend: isSkipWeekend,
                    isSkipAfterDinner: isSkipAfterDinner
                )

            case let .tabTapped(tab):
                state.currentTab = tab
                logTabSelected(index: tab, selectionType: .tapped)

            case let .tabSwiped(tab):
                state.currentTab = tab
                logTabSelected(index: tab, selectionType: .swiped)

            case .settingButtonDidTap, .weeklyMealCore(.settingsButtonDidTap):
                state.settingsCore = .init()
                let log = SettingButtonClickedEventLog()
                TWLog.event(log)

            case .settingsCore(.dismiss):
                state.settingsCore = nil

            case .settingsCore(.presented(.allergySettingCore(.presented(.saveButtonDidTap)))):
                state.settingsCore = nil

            case .settingsCore(.presented(.schoolSettingCore(.presented(.schoolSettingFinished)))):
                state.settingsCore = nil

            case .noticeButtonDidTap:
                state.noticeCore = .init()
                let log = BellButtonClickedEventLog()
                TWLog.event(log)

            case .noticeCore(.dismiss):
                state.noticeCore = nil

            case let .dateSelected(date):
                state.$displayDate.withLock { $0 = date }
                return .none

            case .showReviewToast:
                state.isShowingReviewToast = true
                return .none

            case .hideReviewToast:
                state.isShowingReviewToast = false
                return .none

            case .requestReview:
                state.isShowingReviewToast = false
                userDefaultsClient.setValue(.hasReviewed, true)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
                return .none

            default:
                return .none
            }
            return .none
        }
        .subFeatures()
    }

    private func shouldRequestReview() -> Bool {
        let hasReviewed = userDefaultsClient.getValue(.hasReviewed) as? Bool ?? false
        if hasReviewed {
            return false
        }

        let appOpenCount = (userDefaultsClient.getValue(.appOpenCount) as? Int) ?? 0

        return appOpenCount >= 5
    }

    private func logTabSelected(index: Int, selectionType: TabSelectionType) {
        let log: EventLog? = switch index {
        case 0: MealTabSelectedEventLog(tabSelectionType: selectionType)
        case 1: TimeTableTabSelectedEventLog(tabSelectionType: selectionType)
        default: nil
        }
        guard let log else { return }
        TWLog.event(log)
    }
}

extension Reducer where State == MainCore.State, Action == MainCore.Action {
    func subFeatures() -> some ReducerOf<Self> {
        self
            .ifLet(\.weeklyMealCore, action: \.weeklyMealCore) {
                WeeklyMealCore()
            }
            .ifLet(\.weeklyTimeTableCore, action: \.weeklyTimeTableCore) {
                WeeklyTimeTableCore()
            }
            .ifLet(\.$settingsCore, action: \.settingsCore) {
                SettingsCore()
            }
            .ifLet(\.$noticeCore, action: \.noticeCore) {
                NoticeCore()
            }
    }
}
