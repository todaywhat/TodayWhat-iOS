import TWLog

struct SchoolSettingButtonClickedEventLog: EventLog {
    let name: String = "school_setting_button_clicked_on_setting_page"
    let params: [String: Any]

    init() {
        self.params = EventLogParameterBuilder().build()
    }
}
