import TWLog

struct IsOnModifiedTimeTableToggledEventLog: EventLog {
    let name: String = "is_on_modified_time_table_toggled_on_setting_page"
    let params: [String: Any]

    init(isOnModifiedTimeTable: Bool) {
        self.params = EventLogParameterBuilder()
            .set(key: "value", value: isOnModifiedTimeTable)
            .build()
    }
}
