import TWLog

struct ModifyTimeTableButtonClickedEventLog: EventLog {
    let name: String = "modify_time_table_button_clicked_on_setting_page"
    let params: [String: Any]

    init() {
        self.params = EventLogParameterBuilder().build()
    }
}
