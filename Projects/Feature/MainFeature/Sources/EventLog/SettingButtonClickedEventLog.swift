import TWLog

struct SettingButtonClickedEventLog: EventLog {
    let name: String = "click_setting_button"
    let params: [String: String] = [:]
}
