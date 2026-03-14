import TWLog

struct MacOSIsSkipAfterDinnerToggledEventLog: EventLog {
    let name: String = "click_is_skip_after_dinner_toggle"
    let params: [String: String]

    init(isSkipAfterDinner: Bool) {
        self.params = [
            "value": "\(isSkipAfterDinner)"
        ]
    }
}
