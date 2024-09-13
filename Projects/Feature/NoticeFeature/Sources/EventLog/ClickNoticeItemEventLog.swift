import TWLog

struct ClickNoticeItemEventLog: EventLog {
    let name: String = "click_notice_item"
    let params: [String: String]

    init(id: String) {
        self.params = [
            "notice_id": id
        ]
    }
}
