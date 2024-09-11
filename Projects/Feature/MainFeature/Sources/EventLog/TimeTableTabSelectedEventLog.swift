import TWLog

struct TimeTableTabSelectedEventLog: EventLog {
    let name: String = "select_time_table_tab"
    let params: [String: String]

    init(tabSelectionType: TabSelectionType) {
        self.params = [
            "type": tabSelectionType.rawValue
        ]
    }
}
