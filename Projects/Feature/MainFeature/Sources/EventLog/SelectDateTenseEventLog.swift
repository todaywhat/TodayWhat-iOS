import TWLog

struct SelectDateTenseEventLog: EventLog {
    enum Tense: String {
        case past
        case present
        case future
    }

    let name: String = "select_date_tense"
    let params: [String: String]

    init(tense: Tense) {
        self.params = [
            "tense": tense.rawValue
        ]
    }
}
