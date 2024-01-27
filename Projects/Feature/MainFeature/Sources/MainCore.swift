import BaseFeature
import ComposableArchitecture
import Entity
import MealFeature
import NoticeClient
import NoticeFeature
import SettingsFeature
import TimeTableFeature
import TWLog
import UIKit
import UserDefaultsClient

public struct MainCore: Reducer {
    public init() {}
    public struct State: Equatable {
        public var school = ""
        public var grade = ""
        public var `class` = ""
        public var displayDate = Date()
        public var currentTab = 0
        public var isInitial: Bool = true
        public var isExistNewVersion: Bool = false
        public var mealCore: MealCore.State?
        public var timeTableCore: TimeTableCore.State?
        @PresentationState public var settingsCore: SettingsCore.State?
        @PresentationState public var noticeCore: NoticeCore.State?

        public init() {}
    }

    @CasePathable
    public enum Action {
        case onLoad
        case onAppear
        case tabChanged(Int)
        case mealCore(MealCore.Action)
        case timeTableCore(TimeTableCore.Action)
        case settingButtonDidTap
        case checkVersion(TaskResult<String>)
        case noticeButtonDidTap
        case settingsCore(PresentationAction<SettingsCore.Action>)
        case noticeCore(PresentationAction<NoticeCore.Action>)
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.iTunesClient) var iTunesClient
    @Dependency(\.noticeClient) var noticeClient

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onLoad:
                let pageShowedEvengLog = PageShowedEventLog(pageName: "main_page")
                TWLog.event(pageShowedEvengLog)

            case .onAppear:
                state.displayDate = Date()
                let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool == true
                if isSkipWeekend, state.displayDate.weekday == 7 {
                    state.displayDate = state.displayDate.adding(by: .day, value: 2)
                } else if isSkipWeekend, state.displayDate.weekday == 1 {
                    state.displayDate = state.displayDate.adding(by: .day, value: 1)
                } else if state.displayDate.hour >= 19,
                          userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true {
                    state.displayDate = state.displayDate.adding(by: .day, value: 1)
                }
                state.school = userDefaultsClient.getValue(.school) as? String ?? ""
                state.grade = "\(userDefaultsClient.getValue(.grade) as? Int ?? 1)"
                state.class = "\(userDefaultsClient.getValue(.class) as? Int ?? 1)"
                if state.mealCore == nil {
                    state.mealCore = .init()
                }
                if state.timeTableCore == nil {
                    state.timeTableCore = .init()
                }
                return .run { send in
                    let checkVersion = await Action.checkVersion(
                        TaskResult {
                            try await iTunesClient.fetchCurrentVersion(.ios)
                        }
                    )
                    await send(checkVersion)
                }

            case .mealCore(.refresh), .timeTableCore(.refresh):
                state.displayDate = Date()
                let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool == true
                if isSkipWeekend, state.displayDate.weekday == 7 {
                    state.displayDate = state.displayDate.adding(by: .day, value: 2)
                } else if isSkipWeekend, state.displayDate.weekday == 1 {
                    state.displayDate = state.displayDate.adding(by: .day, value: 1)
                } else if state.displayDate.hour >= 19,
                          userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true {
                    state.displayDate = state.displayDate.adding(by: .day, value: 1)
                }

            case let .tabChanged(tab):
                state.currentTab = tab

            case .settingButtonDidTap, .mealCore(.settingsButtonDidTap):
                state.settingsCore = .init()

            case .settingsCore(.dismiss):
                state.settingsCore = nil

            case .settingsCore(.presented(.allergySettingCore(.presented(.saveButtonDidTap)))):
                state.settingsCore = nil

            case .settingsCore(.presented(.schoolSettingCore(.presented(.schoolSettingFinished)))):
                state.settingsCore = nil

            case let .checkVersion(.success(latestVersion)):
                guard !latestVersion.isEmpty else { break }
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                state.isExistNewVersion = currentVersion != latestVersion

            case .noticeButtonDidTap:
                state.noticeCore = .init()

            case .noticeCore(.dismiss):
                state.noticeCore = nil

            default:
                return .none
            }
            return .none
        }
        .ifLet(\.mealCore, action: /Action.mealCore) {
            MealCore()
        }
        .ifLet(\.timeTableCore, action: /Action.timeTableCore) {
            TimeTableCore()
        }
        .ifLet(\.$settingsCore, action: \.settingsCore) {
            SettingsCore()
        }
        .ifLet(\.$noticeCore, action: \.noticeCore) {
            NoticeCore()
        }
    }
}
