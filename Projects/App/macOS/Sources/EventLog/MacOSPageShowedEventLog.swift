import TWLog

struct MacOSPageShowedEventLog: EventLog {
    let name: String = "page_showed"
    let params: [String: String]

    init(pageName: String) {
        self.params = [
            "page_name": pageName
        ]
    }
}
