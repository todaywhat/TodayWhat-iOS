import TWLog

struct IsOnModifiedTimeTableToggledEventLog: EventLog {
    let name: String = "click_is_on_modified_time_table_toggle"
    let params: [String: String]

    init(isOnModifiedTimeTable: Bool) {
        self.params = [
            "value": "\(isOnModifiedTimeTable)"
        ]
    }
}
