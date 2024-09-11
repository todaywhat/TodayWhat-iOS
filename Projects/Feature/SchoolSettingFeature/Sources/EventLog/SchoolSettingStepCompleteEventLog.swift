import TWLog

public enum SchoolSettingStep: String {
    case school
    case grade
    case `class`
    case major
}

struct SchoolSettingStepCompleteEventLog: EventLog {
    let name: String = "complete_school_setting_step"
    let params: [String: String]

    init(step: SchoolSettingStep) {
        self.params = [
            "step": step.rawValue
        ]
    }
}
