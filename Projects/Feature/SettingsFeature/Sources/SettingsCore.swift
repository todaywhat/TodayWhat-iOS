import AllergySettingFeature
import BaseFeature
import ComposableArchitecture
import DeviceClient
import ITunesClient
import ModifyTimeTableFeature
import SchoolSettingFeature
import TWLog
import UIKit.UIApplication
import UserDefaultsClient

public struct SettingsCore: Reducer {
    public init() {}

    public struct State: Equatable {
        public var schoolName: String = ""
        public var grade: Int = 0
        public var `class`: Int = 0
        public var isSkipWeekend: Bool = false
        public var isSkipAfterDinner: Bool = false
        public var isOnModifiedTimeTable: Bool = false
        @PresentationState public var schoolSettingCore: SchoolSettingCore.State?
        @PresentationState public var allergySettingCore: AllergySettingCore.State?
        @PresentationState public var modifyTimeTableCore: ModifyTimeTableCore.State?
        @PresentationState public var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        @PresentationState public var alert: AlertState<Action.Alert>?

        public init() {}
    }

    @CasePathable
    public enum Action {
        case onAppear
        case isSkipWeekendChanged(Bool)
        case isSkipAfterDinnerChanged(Bool)
        case isOnModifiedTimeTableChagned(Bool)
        case schoolBlockButtonDidTap
        case allergyBlockButtonDidTap
        case modifyTimeTableButtonDidTap
        case consultingButtonDidTap
        case schoolSettingCore(PresentationAction<SchoolSettingCore.Action>)
        case allergySettingCore(PresentationAction<AllergySettingCore.Action>)
        case modifyTimeTableCore(PresentationAction<ModifyTimeTableCore.Action>)
        case alert(PresentationAction<Alert>)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)

        public enum Alert: Equatable, Sendable {
            case githubIssueButtonDidTap
            case mailIssueButtonDidTap
        }

        public enum ConfirmationDialog: Equatable, Sendable {
            case githubIssueButtonDidTap
            case mailIssueButtonDidTap
        }
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.deviceClient) var deviceClient
    @Dependency(\.iTunesClient) var iTunesClient

    public var body: some ReducerOf<SettingsCore> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let pageShowedEvengLog = PageShowedEventLog(pageName: "setting_page")
                TWLog.event(pageShowedEvengLog)

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

            case .modifyTimeTableButtonDidTap:
                state.modifyTimeTableCore = .init()

            case .modifyTimeTableCore(.dismiss):
                state.modifyTimeTableCore = nil

            case .schoolSettingCore(.dismiss):
                state.schoolSettingCore = nil

            case .allergyBlockButtonDidTap:
                state.allergySettingCore = .init()

            case .allergySettingCore(.dismiss):
                state.allergySettingCore = nil

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

            case .alert(.presented(.githubIssueButtonDidTap)),
                 .confirmationDialog(.presented(.githubIssueButtonDidTap)):
                guard let url = URL(string: "https://github.com/baekteun/TodayWhat-new/issues") else { break }
                UIApplication.shared.open(url)

            case .alert(.presented(.mailIssueButtonDidTap)),
                 .confirmationDialog(.presented(.mailIssueButtonDidTap)):
                guard let url = URL(string: "mailto:baegteun@gmail.com") else { break }
                UIApplication.shared.open(url)

            case .alert(.dismiss):
                state.alert = nil

            case .confirmationDialog(.dismiss):
                state.confirmationDialog = nil

            default:
                return .none
            }

            return .none
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
        .ifLet(\.$schoolSettingCore, action: \.schoolSettingCore) {
            SchoolSettingCore()
        }
        .ifLet(\.$allergySettingCore, action: \.allergySettingCore) {
            AllergySettingCore()
        }
        .ifLet(\.$modifyTimeTableCore, action: \.modifyTimeTableCore) {
            ModifyTimeTableCore()
        }
    }
}
