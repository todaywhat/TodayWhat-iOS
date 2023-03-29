import ComposableArchitecture
import Entity
import Foundation
import TimeTableClient
import UserDefaultsClient

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

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear, .refresh:
                state.isLoading = true
                return .task {
                    .timeTableResponse(
                        await TaskResult {
                            var targetDate = Date()
                            if targetDate.hour >= 19, userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true {
                                targetDate = targetDate.adding(by: .day, value: 1)
                            }
                            return try await timeTableClient.fetchTimeTable(targetDate)
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
