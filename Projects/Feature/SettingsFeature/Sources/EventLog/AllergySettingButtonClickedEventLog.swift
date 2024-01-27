import TWLog

struct AllergySettingButtonClickedEventLog: EventLog {
    let name: String = "allergy_setting_button_clicked_on_setting_page"
    let params: [String: Any]

    init() {
        self.params = EventLogParameterBuilder().build()
    }
}
