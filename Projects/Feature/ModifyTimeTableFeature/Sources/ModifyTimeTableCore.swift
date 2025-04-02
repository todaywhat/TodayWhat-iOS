import BaseFeature
import ComposableArchitecture
import DateUtil
import Entity
import EnumUtil
import Foundation
import FoundationUtil
import LocalDatabaseClient
import TimeTableClient
import TWLog
import WidgetKit

public struct ModifyTimeTableCore: Reducer {
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
        case onAppear
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
    public var body: some ReducerOf<ModifyTimeTableCore> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let pageShowedEvengLog = PageShowedEventLog(pageName: "modify_time_table_page")
                TWLog.event(pageShowedEvengLog)

            case .onLoad:
                let modifiedTimeTables = try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)
                    .filter { $0.weekday == WeekdayType.allCases[safe: state.currentTab]?.rawValue ?? 2 }
                if (modifiedTimeTables ?? []).isEmpty {
                    state.isLoading = true
                    return .run { send in
                        let task = await Action.timeTableResponse(
                            TaskResult {
                                try await timeTableClient.fetchTimeTable(
                                    Date.getDateForDayOfWeek(dayOfWeek: Date().weekday) ?? .init()
                                )
                            }
                        )
                        await send(task)
                    }
                }
                state.inputedTimeTables = (modifiedTimeTables ?? [])
                    .sorted { $0.perio < $1.perio }
                    .map(\.content)

            case let .timeTableResponse(.success(timeTables)):
                state.isLoading = false
                state.inputedTimeTables = timeTables
                    .sorted { $0.perio < $1.perio }
                    .map(\.content)

            case .timeTableResponse(.failure(_)):
                state.isLoading = false
                state.inputedTimeTables = []

            case let .tabChanged(tab):
                state.currentTab = tab
                let modifiedTimeTables = try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)
                    .filter { $0.weekday == WeekdayType.allCases[safe: tab]?.rawValue ?? 2 }
                if (modifiedTimeTables ?? []).isEmpty {
                    state.isLoading = true
                    return .run { send in
                        let task = await Action.timeTableResponse(
                            TaskResult {
                                let weekday = WeekdayType.allCases[tab].rawValue
                                return try await timeTableClient.fetchTimeTable(
                                    Date.getDateForDayOfWeek(dayOfWeek: weekday) ?? .init()
                                )
                            }
                        )
                        await send(task)
                    }
                    .debounce(id: TabID(), for: 0.3, scheduler: RunLoop.main)
                }
                state.inputedTimeTables = (modifiedTimeTables ?? [])
                    .sorted { $0.perio < $1.perio }
                    .map(\.content)

            case let .timeTableInputed(index, content):
                guard state.inputedTimeTables[safe: index] != nil else { return .none }
                state.inputedTimeTables[index] = content

            case .appendTimeTableButtonDidTap:
                state.inputedTimeTables.append("시간표")

            case let .removeTimeTable(index):
                state.inputedTimeTables.remove(at: index)

            case .saveButtonDidTap:
                let prevModifiedTimeTables = try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)
                    .filter { $0.weekday == WeekdayType.allCases[safe: state.currentTab]?.rawValue ?? 2 }
                guard let prevModifiedTimeTables else { return .none }
                prevModifiedTimeTables.forEach { timeTable in
                    try? localDatabaseClient.delete(record: timeTable)
                }

                let weekday = WeekdayType.allCases[state.currentTab]
                let log = CompleteModifyTimeTable(week: weekday.analyticsValue)
                TWLog.event(log)

                let modifiedTimeTables = state.inputedTimeTables.indices
                    .map {
                        ModifiedTimeTableLocalEntity(
                            weekday: WeekdayType.allCases[state.currentTab].rawValue,
                            perio: $0 + 1,
                            content: state.inputedTimeTables[$0]
                        )
                    }
                try? localDatabaseClient.save(records: modifiedTimeTables)
                WidgetCenter.shared.reloadTimelines(ofKind: "TodayWhatTimeTableWidget")
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
