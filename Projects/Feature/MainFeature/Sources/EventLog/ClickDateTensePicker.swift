import TWLog

struct ClickDateTensePicker: EventLog {
    let name: String = "click_date_tense_picker"
    let params: [String: String]

    init(tabSelectionType: TabSelectionType) {
        self.params = [
            "type": tabSelectionType.rawValue
        ]
    }
}
