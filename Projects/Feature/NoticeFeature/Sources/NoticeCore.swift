import BaseFeature
import ComposableArchitecture
import Entity
import NoticeClient
import TWLog

public struct NoticeCore: Reducer {
    public init() {}
    public struct State: Equatable {
        public var selectedNotice: Notice?
        public var noticeList: [Notice] = []

        public init(selectedNotice: Notice? = nil) {
            self.selectedNotice = selectedNotice
        }
    }

    public enum Action {
        case onAppear
        case noticeDidSelect(Notice)
        case noticeModalDismissed
        case fetchNoticeListResponse(TaskResult<[Notice]>)
    }

    @Dependency(\.noticeClient) var noticeClient

    public var body: some ReducerOf<NoticeCore> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let pageShowedEvengLog = PageShowedEventLog(pageName: "notice_page")
                TWLog.event(pageShowedEvengLog)

                return .run { send in
                    let taskResult = await TaskResult<[Notice]> {
                        try await noticeClient.fetchNoticeList()
                    }
                    await send(.fetchNoticeListResponse(taskResult))
                }

            case let .noticeDidSelect(notice):
                state.selectedNotice = notice

            case .noticeModalDismissed:
                state.selectedNotice = nil

            case let .fetchNoticeListResponse(.success(noticeList)):
                state.noticeList = noticeList

            default:
                return .none
            }
            return .none
        }
    }
}
