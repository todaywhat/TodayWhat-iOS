import TWLog

struct ClickDateTensePickerEventLog: EventLog {
    let name: String = "click_date_tense_picker"
    let params: [String: String]

    init() {
        self.params = [:]
    }
}
