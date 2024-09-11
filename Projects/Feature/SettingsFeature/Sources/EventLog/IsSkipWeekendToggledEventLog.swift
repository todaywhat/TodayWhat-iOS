import TWLog

struct IsSkipWeekendToggledEventLog: EventLog {
    let name: String = "click_is_skip_after_dinner_toggle"
    let params: [String: String]

    init(isSkipWeekend: Bool) {
        self.params = [
            "value": "\(isSkipWeekend)"
        ]
    }
}
