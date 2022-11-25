import ComposableArchitecture
import UserDefaultsClient
import MealFeature
import TimeTableFeature

public struct MainCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var school = ""
        public var grade = ""
        public var `class` = ""
        public var currentTab = 0
        public var mealCore: MealCore.State? = MealCore.State()
        public var timeTableCore: TimeTableCore.State? = TimeTableCore.State()
        public var confirmationDialog: ConfirmationDialogState<Action>? = nil

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case tabChanged(Int)
        case mealCore(MealCore.Action)
        case timeTableCore(TimeTableCore.Action)
        case settingButtonDidTap
        case confirmationDialogDismissed
        case skipWeekDidSelect
        case allergySettingDidSelect
        case schoolSettingDidSelect
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.school = userDefaultsClient.getValue(key: .school, type: String.self) ?? ""
                state.grade = "\(userDefaultsClient.getValue(key: .grade, type: Int.self) ?? 1)"
                state.class = "\(userDefaultsClient.getValue(key: .class, type: Int.self) ?? 1)"

            case let .tabChanged(tab):
                state.currentTab = tab

            case .settingButtonDidTap:
                state.confirmationDialog = .init {
                    .init("")
                } actions: {
                    [
                        .default(.init("학교 바꾸기"), action: .send(.schoolSettingDidSelect)),
                        .default(.init("알레르기 설정"), action: .send(.allergySettingDidSelect)),
                        .default(.init("주말 스킵하기"), action: .send(.skipWeekDidSelect)),
                        .cancel(.init("취소"))
                    ]
                }

            case .confirmationDialogDismissed:
                state.confirmationDialog = nil
            
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
    }
}
