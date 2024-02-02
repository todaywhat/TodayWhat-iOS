import TWLog

struct BellButtonClickedEventLog: EventLog {
    let name: String = "bell_button_clicked_on_main_page"
    let params: [String: Any]

    init() {
        self.params = EventLogParameterBuilder().build()
    }
}
