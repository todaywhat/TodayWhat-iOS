import ComposableArchitecture
import DateUtil
import EnumUtil
import Entity
import Foundation
import FoundationUtil
import TimeTableClient

public struct ModifyTimeTableCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var currentTab: Int = Date().weekday == 1 ? 6 : Date().weekday - 2
        public var timeTables: [TimeTable] = []
        public var inputedTimeTables: [String] = ["한국사", "네트워크"]
        public var modifiedTimeTables: [ModifiedTimeTableLocalEntity] = []
        public init() {}
    }

    public enum Action: Equatable {
        case tabChanged(Int)
        case timeTableResponse(TaskResult<[TimeTable]>)
        case timeTableInputed(index: Int, content: String)
        case appendTimeTableButtonDidTap
        case removeTimeTable(index: Int)
    }

    @Dependency(\.timeTableClient) var timeTableClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .timeTableResponse(.success(timeTables)):
                state.timeTables = timeTables

            case let .tabChanged(tab):
                state.currentTab = tab

            case let .timeTableInputed(index, content):
                guard state.inputedTimeTables[safe: index] != nil else { return .none }
                state.inputedTimeTables[index] = content

            case .appendTimeTableButtonDidTap:
                state.inputedTimeTables.append("시간표")

            case let .removeTimeTable(index):
                state.inputedTimeTables.remove(at: index)

            default:
                return .none
            }

            return .none
        }
    }
}
