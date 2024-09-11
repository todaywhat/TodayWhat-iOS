import TWLog

struct InquireButtonClickedEventLog: EventLog {
    let name: String = "click_inquiry_button"
    let params: [String: String] = [:]
}
