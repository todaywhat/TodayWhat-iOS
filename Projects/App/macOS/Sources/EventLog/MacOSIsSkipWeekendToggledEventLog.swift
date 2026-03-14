import TWLog

struct MacOSIsSkipWeekendToggledEventLog: EventLog {
    let name: String = "click_is_skip_weekend_toggle"
    let params: [String: String]

    init(isSkipWeekend: Bool) {
        self.params = [
            "value": "\(isSkipWeekend)"
        ]
    }
}
