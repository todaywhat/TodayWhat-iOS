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
        public var isShowingSuccessToast: Bool = false
        public var isLoading: Bool = false
        public var weekdayString: String {
            let weekday = WeekdayType.allCases[currentTab].rawValue
            return Date.getDateForDayOfWeek(dayOfWeek: weekday)?.weekdayString ?? "오늘"
        }
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
        case toastDismissed(Bool)
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
                    state.isLoading = true
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
                state.isLoading = false
                state.inputedTimeTables = timeTables
                    .sorted { $0.perio < $1.perio }
                    .map { $0.content }

            case .timeTableResponse(.failure(_)):
                state.isLoading = false
                state.inputedTimeTables = []

            case let .tabChanged(tab):
                state.currentTab = tab
                let modifiedTimeTables = try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)
                    .filter { $0.weekday == WeekdayType.allCases[safe: tab]?.rawValue ?? 2 }
                if (modifiedTimeTables ?? []).isEmpty {
                    state.isLoading = true
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
                state.inputedTimeTables = (modifiedTimeTables ?? [])
                    .sorted { $0.perio < $1.perio }
                    .map { $0.content }

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
                            weekday: WeekdayType.allCases[state.currentTab].rawValue,
                            perio: $0 + 1,
                            content: state.inputedTimeTables[$0]
                        )
                    }
                try? localDatabaseClient.deleteAll(record: ModifiedTimeTableLocalEntity.self)
                try? localDatabaseClient.save(records: modifiedTimeTables)
                state.isShowingSuccessToast = true

            case let .toastDismissed(dismissed):
                state.isShowingSuccessToast = dismissed

            default:
                return .none
            }

            return .none
        }
    }
}
