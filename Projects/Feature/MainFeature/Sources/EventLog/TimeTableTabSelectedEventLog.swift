import TWLog

struct TimeTableTabSelectedEventLog: EventLog {
    let name: String = "time_table_tab_selected_on_main_page"
    let params: [String: Any]

    init(tabSelectionType: TabSelectionType) {
        self.params = EventLogParameterBuilder()
            .set(key: "type", value: tabSelectionType.rawValue)
            .build()
    }
}
