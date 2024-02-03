import TWLog

struct InquireButtonClickedEventLog: EventLog {
    let name: String = "inquire_button_clicked_on_setting_page"
    let params: [String: Any]

    init() {
        self.params = EventLogParameterBuilder().build()
    }
}
