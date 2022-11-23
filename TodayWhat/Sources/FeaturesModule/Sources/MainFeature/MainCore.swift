import ComposableArchitecture
import UserDefaultsClient
import MealFeature
import ScheduleFeature

public struct MainCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var school = ""
        public var grade = ""
        public var `class` = ""
        public var currentTab = 0
        public var mealCore: MealCore.State? = MealCore.State()
        public var scheduleCore: ScheduleCore.State? = ScheduleCore.State()
        
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case tabChanged(Int)
        case mealCore(MealCore.Action)
        case scheduleCore(ScheduleCore.Action)
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
            
            default:
                return .none
            }
            return .none
        }
        .ifLet(\.mealCore, action: /Action.mealCore) {
            MealCore()._printChanges()
        }
        .ifLet(\.scheduleCore, action: /Action.scheduleCore) {
            ScheduleCore()
        }
    }
}
