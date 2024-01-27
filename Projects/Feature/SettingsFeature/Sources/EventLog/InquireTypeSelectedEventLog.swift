import TWLog

enum SelectedInquireType: String {
    case mail
    case github
}

struct InquireTypeSelectedEventLog: EventLog {
    let name: String = "inquire_type_selected_on_inquire_modal"
    let params: [String: Any]

    init(inquireType: SelectedInquireType) {
        self.params = EventLogParameterBuilder()
            .set(key: "type", value: inquireType.rawValue)
            .build()
    }
}
