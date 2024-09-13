import TWLog

struct WidgetConfigEventLog: EventLog {
    let name: String = "widget_configuration"
    let params: [String: String]

    init(family: String, kind: String) {
        self.params = [
            "family": family,
            "kind": kind
        ]
    }
}
