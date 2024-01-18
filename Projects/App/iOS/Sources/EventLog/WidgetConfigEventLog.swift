import TWLog

struct WidgetConfigEventLog: EventLog {
    let name: String = "widget_configuration"
    let params: [String: Any]

    init(family: String, kind: String) {
        self.params = EventLogParameterBuilder()
            .set(key: "family", value: family)
            .set(key: "kind", value: kind)
            .build()
    }
}
