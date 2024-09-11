import TWLog

struct BellButtonClickedEventLog: EventLog {
    let name: String = "click_notice_button"
    let params: [String: String] = [:]
}
