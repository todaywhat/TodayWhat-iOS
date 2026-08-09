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
        public var editedTimeTables: [Int: [String]] = [:]
        public var customizedTabs: Set<Int> = []
        public var isShowingSuccessToast: Bool = false
        public var toastText: String = ""
        public var isLoading: Bool = false
        @PresentationState public var alert: AlertState<Action.Alert>?

        public var hasUnsavedChanges: Bool {
            !editedTimeTables.isEmpty
        }

        public var isCurrentTabEdited: Bool {
            editedTimeTables[currentTab] != nil
        }

        public var isCurrentTabCustomized: Bool {
            customizedTabs.contains(currentTab)
        }

        public var weekdayString: String {
            let weekday = WeekdayType.allCases[currentTab].rawValue
            return Date.getDateForDayOfWeek(dayOfWeek: weekday)?.weekdayString ?? "오늘"
        }

        public init() {}
    }

    @CasePathable
    public enum Action: Equatable {
        case onAppear
        case onLoad
        case tabChanged(Int)
        case timeTableResponse(tab: Int, TaskResult<[TimeTable]>)
        case timeTableInputed(index: Int, content: String)
        case appendTimeTableButtonDidTap
        case removeTimeTable(index: Int)
        case saveButtonDidTap
        case revertButtonDidTap
        case toastDismissed(Bool)
        case alert(PresentationAction<Alert>)

        public enum Alert: Equatable, Sendable {
            case revertConfirmed
        }
    }

    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    enum CancelID: Hashable {
        case fetch
    }

    public var body: some ReducerOf<ModifyTimeTableCore> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let pageShowedEvengLog = PageShowedEventLog(pageName: "modify_time_table_page")
                TWLog.event(pageShowedEvengLog)

            case .onLoad:
                state.customizedTabs = loadCustomizedTabs()
                return loadTimeTable(state: &state, tab: state.currentTab, debounced: false)

            case let .tabChanged(tab):
                state.currentTab = tab
                return loadTimeTable(state: &state, tab: tab, debounced: true)

            case let .timeTableResponse(tab, .success(timeTables)):
                guard tab == state.currentTab else { return .none }
                state.isLoading = false
                state.inputedTimeTables = timeTables
                    .sorted { $0.perio < $1.perio }
                    .map(\.content)

            case let .timeTableResponse(tab, .failure):
                guard tab == state.currentTab else { return .none }
                state.isLoading = false
                state.inputedTimeTables = []

            case let .timeTableInputed(index, content):
                guard state.inputedTimeTables[safe: index] != nil else { return .none }
                state.inputedTimeTables[index] = content
                markCurrentTabEdited(state: &state)

            case .appendTimeTableButtonDidTap:
                state.inputedTimeTables.append("시간표")
                markCurrentTabEdited(state: &state)

            case let .removeTimeTable(index):
                guard state.inputedTimeTables[safe: index] != nil else { return .none }
                state.inputedTimeTables.remove(at: index)
                markCurrentTabEdited(state: &state)

            case .saveButtonDidTap:
                guard !state.editedTimeTables.isEmpty else { return .none }
                let savedTabs = state.editedTimeTables.keys.sorted()
                savedTabs.forEach { tab in
                    replaceRecords(tab: tab, contents: state.editedTimeTables[tab] ?? [])

                    let log = CompleteModifyTimeTable(week: weekdayName(of: tab))
                    TWLog.event(log)
                }
                state.editedTimeTables = [:]
                userDefaultsClient.setValue(.isOnModifiedTimeTable, true)
                state.toastText = "\(savedTabs.map(weekdayName(of:)).joined(separator: ", ")) 시간표 저장완료"
                state.isShowingSuccessToast = true
                refreshCustomizedTabs(state: &state)

            case .revertButtonDidTap:
                guard state.isCurrentTabCustomized else { return .none }
                state.alert = AlertState(
                    title: {
                        TextState("\(state.weekdayString) 시간표 되돌리기")
                    },
                    actions: {
                        ButtonState.destructive(.init("되돌리기"), action: .send(.revertConfirmed))
                        ButtonState.cancel(.init("취소"))
                    },
                    message: {
                        TextState("저장해둔 커스텀 시간표를 지우고 학교 시간표를 다시 불러와요.")
                    }
                )

            case .alert(.presented(.revertConfirmed)):
                let tab = state.currentTab
                replaceRecords(tab: tab, contents: [])
                state.editedTimeTables[tab] = nil

                let log = RevertModifyTimeTable(week: weekdayName(of: tab))
                TWLog.event(log)

                state.toastText = "\(state.weekdayString) 시간표를 되돌렸어요"
                state.isShowingSuccessToast = true
                refreshCustomizedTabs(state: &state)
                return loadTimeTable(state: &state, tab: tab, debounced: false)

            case let .toastDismissed(dismissed):
                state.isShowingSuccessToast = dismissed

            default:
                return .none
            }

            return .none
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}

private extension ModifyTimeTableCore {
    func weekdayName(of tab: Int) -> String {
        WeekdayType.allCases[safe: tab]?.analyticsValue ?? ""
    }

    func weekday(of tab: Int) -> Int {
        WeekdayType.allCases[safe: tab]?.rawValue ?? WeekdayType.monday.rawValue
    }

    func savedRecords(tab: Int) -> [ModifiedTimeTableLocalEntity] {
        let records = (try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)) ?? []
        return records
            .filter { $0.weekday == weekday(of: tab) }
            .sorted { $0.perio < $1.perio }
    }

    func loadCustomizedTabs() -> Set<Int> {
        let records = (try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)) ?? []
        let customizedWeekdays = Set(records.map(\.weekday))
        return Set(
            WeekdayType.allCases.indices
                .filter { customizedWeekdays.contains(WeekdayType.allCases[$0].rawValue) }
        )
    }

    func replaceRecords(tab: Int, contents: [String]) {
        savedRecords(tab: tab).forEach { record in
            try? localDatabaseClient.delete(record: record)
        }
        let records = contents.indices.map {
            ModifiedTimeTableLocalEntity(
                weekday: weekday(of: tab),
                perio: $0 + 1,
                content: contents[$0]
            )
        }
        try? localDatabaseClient.save(records: records)
    }

    func markCurrentTabEdited(state: inout State) {
        state.editedTimeTables[state.currentTab] = state.inputedTimeTables
    }

    func refreshCustomizedTabs(state: inout State) {
        state.customizedTabs = loadCustomizedTabs()

        // 커스텀 시간표가 하나도 남지 않았는데 토글이 켜져 있으면 시간표가 빈 화면으로 보이므로 함께 내린다.
        if state.customizedTabs.isEmpty {
            userDefaultsClient.setValue(.isOnModifiedTimeTable, false)
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "TodayWhatTimeTableWidget")
        NotificationCenter.default.post(
            name: Notification.Name("TodayWhatWatchSyncDidRequest"),
            object: nil
        )
    }

    func loadTimeTable(state: inout State, tab: Int, debounced: Bool) -> Effect<Action> {
        if let editedTimeTables = state.editedTimeTables[tab] {
            state.isLoading = false
            state.inputedTimeTables = editedTimeTables
            return .cancel(id: CancelID.fetch)
        }

        let savedTimeTables = savedRecords(tab: tab).map(\.content)
        if !savedTimeTables.isEmpty {
            state.isLoading = false
            state.inputedTimeTables = savedTimeTables
            return .cancel(id: CancelID.fetch)
        }

        state.isLoading = true
        state.inputedTimeTables = []
        let fetchEffect = Effect<Action>.run { [weekday = weekday(of: tab)] send in
            let task = await Action.timeTableResponse(
                tab: tab,
                TaskResult {
                    try await timeTableClient.fetchTimeTable(
                        Date.getDateForDayOfWeek(dayOfWeek: weekday) ?? .init()
                    )
                }
            )
            await send(task)
        }
        return debounced
            ? fetchEffect.debounce(id: CancelID.fetch, for: 0.3, scheduler: RunLoop.main)
            : fetchEffect.cancellable(id: CancelID.fetch, cancelInFlight: true)
    }
}
