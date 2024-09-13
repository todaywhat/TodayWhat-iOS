import TWLog

struct AllergySettingButtonClickedEventLog: EventLog {
    let name: String = "click_allergy_setting_button"
    let params: [String: String] = [:]
}
