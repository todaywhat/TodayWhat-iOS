import TWLog

struct MacOSTabSelectedEventLog: EventLog {
    let name: String = "tab_selected"
    let params: [String: String]

    init(tab: String) {
        self.params = [
            "tab": tab
        ]
    }
}
