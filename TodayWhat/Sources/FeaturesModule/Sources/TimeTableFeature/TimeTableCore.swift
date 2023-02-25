import ComposableArchitecture
import Entity
import Foundation
import TimeTableClient

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

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear, .refresh:
                state.isLoading = true
                return .task {
                    .timeTableResponse(
                        await TaskResult {
                            try await timeTableClient.fetchTimeTable(Date())
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
