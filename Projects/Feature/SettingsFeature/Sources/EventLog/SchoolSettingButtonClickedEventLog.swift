import TWLog

struct SchoolSettingButtonClickedEventLog: EventLog {
    let name: String = "click_school_setting_button"
    let params: [String: String] = [:]
}
