import TWLog

struct MacOSSchoolSelectedEventLog: EventLog {
    let name: String = "school_selected"
    let params: [String: String]

    init(schoolName: String) {
        self.params = [
            "school_name": schoolName
        ]
    }
}
