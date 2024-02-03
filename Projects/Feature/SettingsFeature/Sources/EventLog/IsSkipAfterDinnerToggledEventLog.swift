import TWLog

struct IsSkipAfterDinnerToggledEventLog: EventLog {
    let name: String = "is_skip_after_dinner_toggled_on_setting_page"
    let params: [String: Any]

    init(isSkipAfterDinner: Bool) {
        self.params = EventLogParameterBuilder()
            .set(key: "value", value: isSkipAfterDinner)
            .build()
    }
}
