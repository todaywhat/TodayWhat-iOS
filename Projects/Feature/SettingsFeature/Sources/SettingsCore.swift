import AllergySettingFeature
import ComposableArchitecture
import DeviceClient
import SchoolSettingFeature
import ITunesClient
import UserDefaultsClient
import UIKit.UIApplication
import ModifyTimeTableFeature

public struct SettingsCore: ReducerProtocol {
    public init() {}

    public struct State: Equatable {
        public var schoolName: String = ""
        public var grade: Int = 0
        public var `class`: Int = 0
        public var isSkipWeekend: Bool = false
        public var isSkipAfterDinner: Bool = false
        public var isOnModifiedTimeTable: Bool = false
        public var schoolSettingCore: SchoolSettingCore.State? = nil
        public var isNavigateSchoolSetting: Bool = false
        public var allergySettingCore: AllergySettingCore.State? = nil
        public var isNavigateAllergySetting: Bool = false
        public var modifyTimeTableCore: ModifyTimeTableCore.State? = nil
        public var isNavigateModifyTimeTable: Bool = false
        public var confirmationDialog: ConfirmationDialogState<Action>? = nil
        public var alert: AlertState<Action>? = nil

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case isSkipWeekendChanged(Bool)
        case isSkipAfterDinnerChanged(Bool)
        case isOnModifiedTimeTableChagned(Bool)
        case schoolBlockButtonDidTap
        case schoolSettingDismissed
        case schoolSettingCore(SchoolSettingCore.Action)
        case allergyBlockButtonDidTap
        case allergySettingDismissed
        case allergySettingCore(AllergySettingCore.Action)
        case modifyTimeTableButtonDidTap
        case modifyTimeTableDismissed
        case modifyTimeTableCore(ModifyTimeTableCore.Action)
        case consultingButtonDidTap
        case githubIssueButtonDidTap
        case mailIssueButtonDidTap
        case alertDismissed
        case confirmationDialogDismissed
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.deviceClient) var deviceClient
    @Dependency(\.iTunesClient) var iTunesClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.schoolName = userDefaultsClient.getValue(.school) as? String ?? ""
                state.grade = userDefaultsClient.getValue(.grade) as? Int ?? 0
                state.class = userDefaultsClient.getValue(.class) as? Int ?? 0
                state.isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false
                state.isSkipAfterDinner = userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true
                state.isOnModifiedTimeTable = userDefaultsClient.getValue(.isOnModifiedTimeTable) as? Bool ?? false

            case let .isSkipWeekendChanged(isSkipWeekend):
                state.isSkipWeekend = isSkipWeekend
                userDefaultsClient.setValue(.isSkipWeekend, isSkipWeekend)

            case let .isSkipAfterDinnerChanged(isSkipAfterDinner):
                state.isSkipAfterDinner = isSkipAfterDinner
                userDefaultsClient.setValue(.isSkipAfterDinner, isSkipAfterDinner)

            case let .isOnModifiedTimeTableChagned(isOnModifiedTimeTable):
                state.isOnModifiedTimeTable = isOnModifiedTimeTable
                userDefaultsClient.setValue(.isOnModifiedTimeTable, isOnModifiedTimeTable)

            case .schoolBlockButtonDidTap:
                state.schoolSettingCore = .init()
                state.isNavigateSchoolSetting = true

            case .modifyTimeTableButtonDidTap:
                state.modifyTimeTableCore = .init()
                state.isNavigateModifyTimeTable = true

            case .modifyTimeTableDismissed:
                state.modifyTimeTableCore = nil
                state.isNavigateModifyTimeTable = false

            case .schoolSettingDismissed:
                state.schoolSettingCore = nil
                state.isNavigateSchoolSetting = false

            case .allergyBlockButtonDidTap:
                state.allergySettingCore = .init()
                state.isNavigateAllergySetting = true

            case .allergySettingDismissed:
                state.allergySettingCore = .init()
                state.isNavigateAllergySetting = false

            case .consultingButtonDidTap:
                if deviceClient.isPad() {
                    state.alert = AlertState {
                        .init("오늘 뭐임")
                    } actions: {
                        ButtonState.default(.init("깃허브"), action: .send(.githubIssueButtonDidTap))
                        ButtonState.default(.init("메일"), action: .send(.mailIssueButtonDidTap))
                        ButtonState.cancel(.init("취소"))
                    }
                } else {
                    state.confirmationDialog = ConfirmationDialogState {
                        .init("문의하기")
                    } actions: {
                        ButtonState.default(.init("깃허브"), action: .send(.githubIssueButtonDidTap))
                        ButtonState.default(.init("메일"), action: .send(.mailIssueButtonDidTap))
                        ButtonState.cancel(.init("취소"))
                    }
                }
 
            case .githubIssueButtonDidTap:
                guard let url = URL(string: "https://github.com/baekteun/TodayWhat-new/issues") else { break }
                UIApplication.shared.open(url)

            case .mailIssueButtonDidTap:
                guard let url = URL(string: "mailto:baegteun@gmail.com") else { break }
                UIApplication.shared.open(url)

            case .alertDismissed:
                state.alert = nil

            case .confirmationDialogDismissed:
                state.confirmationDialog = nil

            default:
                return .none
            }

            return .none
        }
        .ifLet(\.schoolSettingCore, action: /Action.schoolSettingCore) {
            SchoolSettingCore()
        }
        .ifLet(\.allergySettingCore, action: /Action.allergySettingCore) {
            AllergySettingCore()
        }
        .ifLet(\.modifyTimeTableCore, action: /Action.modifyTimeTableCore) {
            ModifyTimeTableCore()
        }
    }
}
