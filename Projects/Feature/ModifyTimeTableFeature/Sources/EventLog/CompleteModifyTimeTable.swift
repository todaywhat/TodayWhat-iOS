import TWLog

struct CompleteModifyTimeTable: EventLog {
    let name: String = "complete_modify_time_table"
    let params: [String: String]

    init(week: String) {
        self.params = [
            "week": week
        ]
    }
}
