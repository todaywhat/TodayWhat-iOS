import ComposableArchitecture
import DateUtil
import EnumUtil
import Entity
import Foundation
import FoundationUtil
import TimeTableClient
import LocalDatabaseClient

public struct ModifyTimeTableCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var currentTab: Int = Date().weekday == 1 ? 6 : Date().weekday - 2
        public var inputedTimeTables: [String] = []
        public var modifiedTimeTables: [ModifiedTimeTableLocalEntity] = []
        public init() {}
    }

    public enum Action: Equatable {
        case onLoad
        case tabChanged(Int)
        case timeTableResponse(TaskResult<[TimeTable]>)
        case timeTableInputed(index: Int, content: String)
        case appendTimeTableButtonDidTap
        case removeTimeTable(index: Int)
        case saveButtonDidTap
    }

    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    struct TabID: Hashable {}
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onLoad:
                let modifiedTimeTables = try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)
                    .filter { $0.weekday == WeekdayType.allCases[safe: state.currentTab]?.rawValue ?? 2 }
                if (modifiedTimeTables ?? []).isEmpty {
                    return .task {
                        .timeTableResponse(
                            await TaskResult {
                                try await timeTableClient.fetchTimeTable(
                                    Date.getDateForDayOfWeek(dayOfWeek: Date().weekday) ?? .init()
                                )
                            }
                        )
                    }.animation()
                }
                state.inputedTimeTables = (modifiedTimeTables ?? [])
                    .sorted { $0.perio < $1.perio }
                    .map { $0.content }
                
            case let .timeTableResponse(.success(timeTables)):
                state.inputedTimeTables = timeTables
                    .sorted { $0.perio < $1.perio }
                    .map { $0.content }

            case let .tabChanged(tab):
                state.currentTab = tab
                let modifiedTimeTables = try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)
                    .filter { $0.weekday == WeekdayType.allCases[safe: tab]?.rawValue ?? 2 }
                if (modifiedTimeTables ?? []).isEmpty {
                    return .task {
                        .timeTableResponse(
                            await TaskResult {
                                let weekday = WeekdayType.allCases[tab].rawValue
                                return try await timeTableClient.fetchTimeTable(
                                    Date.getDateForDayOfWeek(dayOfWeek: weekday) ?? .init()
                                )
                            }
                        )
                    }
                    .debounce(id: TabID(), for: 0.3, scheduler: RunLoop.main)
                }

            case let .timeTableInputed(index, content):
                guard state.inputedTimeTables[safe: index] != nil else { return .none }
                state.inputedTimeTables[index] = content

            case .appendTimeTableButtonDidTap:
                state.inputedTimeTables.append("시간표")

            case let .removeTimeTable(index):
                state.inputedTimeTables.remove(at: index)

            case .saveButtonDidTap:
                let modifiedTimeTables = state.inputedTimeTables.indices
                    .map {
                        ModifiedTimeTableLocalEntity(
                            weekday: WeekdayType.allCases[$0].rawValue,
                            perio: $0,
                            content: state.inputedTimeTables[$0]
                        )
                    }
                try? localDatabaseClient.save(records: modifiedTimeTables)

            default:
                return .none
            }

            return .none
        }
    }
}
