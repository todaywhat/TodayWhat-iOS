import TWLog

struct SettingButtonClickedEventLog: EventLog {
    let name: String = "setting_button_clicked_on_main_page"
    let params: [String: Any]

    init() {
        self.params = EventLogParameterBuilder().build()
    }
}
