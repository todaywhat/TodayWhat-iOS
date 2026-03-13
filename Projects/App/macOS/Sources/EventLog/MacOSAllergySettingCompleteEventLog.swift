import EnumUtil
import TWLog

struct MacOSAllergySettingCompleteEventLog: EventLog {
    let name: String = "complete_setting_allergy"
    let params: [String: String]

    init(allergies: [AllergyType]) {
        self.params = [
            "allergies": allergies.map(\.analyticsValue).joined(separator: ",")
        ]
    }
}
