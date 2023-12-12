import ComposableArchitecture
import Entity
import EnumUtil
import Foundation
import TimeTableClient
import UserDefaultsClient
import LocalDatabaseClient

public struct TimeTableCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var timeTableList: [TimeTable] = []
        public var isLoading = false
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case refresh
        case timeTableResponse(TaskResult<[TimeTable]>)
    }

    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear, .refresh:
                var todayDate = Date()
                let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool == true
                if isSkipWeekend, todayDate.weekday == 7 {
                    todayDate = todayDate.adding(by: .day, value: 2)
                } else if isSkipWeekend, todayDate.weekday == 1 {
                    todayDate = todayDate.adding(by: .day, value: 1)
                } else if todayDate.hour >= 19, userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true {
                    todayDate = todayDate.adding(by: .day, value: 1)
                }
                state.isLoading = true

                if userDefaultsClient.getValue(.isOnModifiedTimeTable) as? Bool ?? false {
                    let modifiedTimeTables = try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)
                        .filter { $0.weekday == WeekdayType(weekday: todayDate.weekday).rawValue }
                    state.timeTableList = (modifiedTimeTables ?? [])
                        .sorted { $0.perio < $1.perio }
                        .map { TimeTable(perio: $0.perio, content: $0.content) }
                    state.isLoading = false
                    return .none
                }
                return .task { [todayDate] in
                    .timeTableResponse(
                        await TaskResult {
                            try await timeTableClient.fetchTimeTable(todayDate)
                        }
                    )
                }

            case let .timeTableResponse(.success(timeTableList)):
                state.isLoading = false
                state.timeTableList = timeTableList

            case .timeTableResponse(.failure(_)):
                state.timeTableList = []
                state.isLoading = false
            }
            return .none
        }
    }
}
