import TWLog

struct IsSkipWeekendToggledEventLog: EventLog {
    let name: String = "is_skip_weekend_toggled_on_setting_page"
    let params: [String: Any]

    init(isSkipWeekend: Bool) {
        self.params = EventLogParameterBuilder()
            .set(key: "value", value: isSkipWeekend)
            .build()
    }
}
