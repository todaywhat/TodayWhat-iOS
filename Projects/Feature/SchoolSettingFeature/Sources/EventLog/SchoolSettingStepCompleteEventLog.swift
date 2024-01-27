import TWLog

public enum SchoolSettingStep: String {
    case school
    case grade
    case `class`
    case major
}

struct SchoolSettingStepCompleteEventLog: EventLog {
    let name: String = "school_setting_step_complete_on_school_setting_page"
    let params: [String: Any]

    init(step: SchoolSettingStep) {
        self.params = EventLogParameterBuilder()
            .set(key: "step", value: step.rawValue)
            .build()
    }
}
