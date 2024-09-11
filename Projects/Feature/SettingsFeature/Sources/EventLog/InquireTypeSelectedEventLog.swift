import TWLog

enum SelectedInquireType: String {
    case mail
    case github
}

struct InquireTypeSelectedEventLog: EventLog {
    let name: String = "select_inquiry_type"
    let params: [String: String]

    init(inquireType: SelectedInquireType) {
        self.params = [
            "type": inquireType.rawValue
        ]
    }
}
