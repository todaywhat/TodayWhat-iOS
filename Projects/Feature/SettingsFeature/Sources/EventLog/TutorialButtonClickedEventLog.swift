import TWLog

struct TutorialButtonClickedEventLog: EventLog {
    let name: String = "tutorial_button_clicked_on_setting_page"
    let params: [String: Any]

    init() {
        self.params = EventLogParameterBuilder().build()
    }
}
