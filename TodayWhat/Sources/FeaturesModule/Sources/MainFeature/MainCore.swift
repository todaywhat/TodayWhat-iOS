import ComposableArchitecture
import UserDefaultsClient
import MealFeature
import TimeTableFeature
import SchoolSettingFeature
import AllergySettingFeature
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
        public var confirmationDialog: ConfirmationDialogState<Action>? = nil
        public var alert: AlertState<Action>? = nil
        public var isNavigateSchoolSetting = false
        public var schoolSettingCore: SchoolSettingCore.State? = nil
        public var isNavigateAllergySetting = false
        public var allergySettingCore: AllergySettingCore.State? = nil

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case tabChanged(Int)
        case mealCore(MealCore.Action)
        case timeTableCore(TimeTableCore.Action)
        case settingButtonDidTap
        case confirmationDialogDismissed
        case alertDismissed
        case skipWeekDidSelect
        case allergySettingDidSelect
        case schoolSettingDidSelect
        case schoolSettingCore(SchoolSettingCore.Action)
        case schoolSettingDismissed
        case allergySettingCore(AllergySettingCore.Action)
        case allergySettingDismissed
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.school = userDefaultsClient.getValue(key: .school, type: String.self) ?? ""
                state.grade = "\(userDefaultsClient.getValue(key: .grade, type: Int.self) ?? 1)"
                state.class = "\(userDefaultsClient.getValue(key: .class, type: Int.self) ?? 1)"
                if state.mealCore == nil {
                    state.mealCore = .init()
                }
                if state.timeTableCore == nil {
                    state.timeTableCore = .init()
                }

            case let .tabChanged(tab):
                state.currentTab = tab

            case .settingButtonDidTap:
                let isSkipWeekend = userDefaultsClient.getValue(key: .isSkipWeekend, type: Bool.self) ?? false
                if UIDevice.current.userInterfaceIdiom != .phone {
                    state.alert = AlertState {
                        .init("오늘 뭐임")
                    } actions: {
                        ButtonState.default(.init("학교 바꾸기"), action: .send(.schoolSettingDidSelect))
                        ButtonState.default(.init("알레르기설정"), action: .send(.allergySettingDidSelect))
                        ButtonState.default(.init(isSkipWeekend ? "주말 스킵하지 않기" : "주말 스킵하기"), action: .send(.skipWeekDidSelect))
                        ButtonState.cancel(.init("취소"))
                    }
                } else {
                    state.confirmationDialog = ConfirmationDialogState {
                        .init("")
                    } actions: {
                        ButtonState.default(.init("학교 바꾸기"), action: .send(.schoolSettingDidSelect))
                        ButtonState.default(.init("알레르기설정"), action: .send(.allergySettingDidSelect))
                        ButtonState.default(.init(isSkipWeekend ? "주말 스킵하지 않기" : "주말 스킵하기"), action: .send(.skipWeekDidSelect))
                        ButtonState.cancel(.init("취소"))
                    }
                }

            case .confirmationDialogDismissed:
                state.confirmationDialog = nil

            case .alertDismissed:
                state.alert = nil

            case .schoolSettingDidSelect:
                state.schoolSettingCore = .init()
                state.isNavigateSchoolSetting = true

            case .schoolSettingDismissed:
                state.schoolSettingCore = nil
                state.isNavigateSchoolSetting = false

            case .schoolSettingCore(.schoolSettingFinished):
                state.schoolSettingCore = nil
                state.isNavigateSchoolSetting = false

            case .allergySettingDidSelect:
                state.allergySettingCore = .init()
                state.isNavigateAllergySetting = true

            case .allergySettingDismissed:
                state.allergySettingCore = nil
                state.isNavigateAllergySetting = false

            case .skipWeekDidSelect:
                userDefaultsClient.setValue(
                    .isSkipWeekend,
                    !(userDefaultsClient.getValue(key: .isSkipWeekend, type: Bool.self) ?? false)
                )
            
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
        .ifLet(\.schoolSettingCore, action: /Action.schoolSettingCore) {
            SchoolSettingCore()
        }
        .ifLet(\.allergySettingCore, action: /Action.allergySettingCore) {
            AllergySettingCore()
        }
    }
}
