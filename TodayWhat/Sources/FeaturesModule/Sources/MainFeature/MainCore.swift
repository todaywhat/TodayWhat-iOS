import AllergySettingFeature
import ComposableArchitecture
import UserDefaultsClient
import MealFeature
import TimeTableFeature
import SchoolSettingFeature
import SettingsFeature
import UIKit

public struct MainCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var school = ""
        public var grade = ""
        public var `class` = ""
        public var currentTab = 0
        public var mealCore: MealCore.State? = nil
        public var timeTableCore: TimeTableCore.State? = nil
        public var settingsCore: SettingsCore.State? = nil
        public var isNavigateSettings = false

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case tabChanged(Int)
        case mealCore(MealCore.Action)
        case timeTableCore(TimeTableCore.Action)
        case settingButtonDidTap
        case settingsCore(SettingsCore.Action)
        case settingsDismissed
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.school = userDefaultsClient.getValue(.school) as? String ?? ""
                state.grade = "\(userDefaultsClient.getValue(.grade) as? Int ?? 1)"
                state.class = "\(userDefaultsClient.getValue(.class) as? Int ?? 1)"
                if state.mealCore == nil {
                    state.mealCore = .init()
                }
                if state.timeTableCore == nil {
                    state.timeTableCore = .init()
                }

            case let .tabChanged(tab):
                state.currentTab = tab

            case .settingButtonDidTap:
                state.settingsCore = .init()
                state.isNavigateSettings = true

            case .settingsDismissed:
                state.settingsCore = nil
                state.isNavigateSettings = false

            case .settingsCore(.allergySettingCore(.saveButtonDidTap)):
                state.settingsCore = nil
                state.isNavigateSettings = false

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
        .ifLet(\.settingsCore, action: /Action.settingsCore) {
            SettingsCore()
        }
    }
}
