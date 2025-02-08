import ComposableArchitecture
import Entity
import EnumUtil
import Foundation
import LocalDatabaseClient
import Sharing
import TimeTableClient
import UserDefaultsClient

public struct TimeTableCore: Reducer {
    private enum CancellableID: Hashable {
        case fetch
    }

    public init() {}

    public struct State: Equatable {
        public var timeTableList: [TimeTable] = []
        public var isLoading = false
        @Shared public var displayDate: Date

        public init(displayDate: Shared<Date>) {
            self._displayDate = displayDate
        }
    }

    public enum Action: Equatable {
        case onLoad
        case onAppear
        case refresh
        case refreshData
        case timeTableResponse(TaskResult<[TimeTable]>)
    }

    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    public var body: some ReducerOf<TimeTableCore> {
        Reduce { state, action in
            switch action {
            case .onLoad:
                return .publisher {
                    state.$displayDate.publisher
                        .map { _ in Action.refreshData }
                }

            case .onAppear, .refreshData:
                state.isLoading = true

                var todayDate = state.displayDate

                if userDefaultsClient.getValue(.isOnModifiedTimeTable) as? Bool ?? false {
                    let modifiedTimeTables = try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)
                        .filter { $0.weekday == WeekdayType(weekday: todayDate.weekday).rawValue }
                    state.timeTableList = (modifiedTimeTables ?? [])
                        .sorted { $0.perio < $1.perio }
                        .map { TimeTable(perio: $0.perio, content: $0.content) }
                    state.isLoading = false
                    return .none
                }
                return .concatenate(
                    .cancel(id: CancellableID.fetch),
                    .run { [todayDate] send in
                        let task = await Action.timeTableResponse(
                            TaskResult {
                                try await timeTableClient.fetchTimeTable(todayDate)
                            }
                        )
                        await send(task)
                    }
                    .cancellable(id: CancellableID.fetch)
                )

            case let .timeTableResponse(.success(timeTableList)):
                state.isLoading = false
                state.timeTableList = timeTableList

            case .timeTableResponse(.failure(_)):
                state.timeTableList = []
                state.isLoading = false

            default:
                return .none
            }
            return .none
        }
    }
}
