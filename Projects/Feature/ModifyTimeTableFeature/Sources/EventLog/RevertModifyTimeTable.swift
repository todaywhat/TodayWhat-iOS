import TWLog

struct RevertModifyTimeTable: EventLog {
    let name: String = "revert_modify_time_table"
    let params: [String: String]

    init(week: String) {
        self.params = [
            "week": week
        ]
    }
}
