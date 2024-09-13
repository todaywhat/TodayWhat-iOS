import TWLog

struct IsSkipAfterDinnerToggledEventLog: EventLog {
    let name: String = "click_is_skip_weekend_toggle"
    let params: [String: String]

    init(isSkipAfterDinner: Bool) {
        self.params = [
            "value": "\(isSkipAfterDinner)"
        ]
    }
}
