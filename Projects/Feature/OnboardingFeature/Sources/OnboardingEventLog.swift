import TWLog

struct OnboardingStartedEventLog: EventLog {
    let name: String = "onboarding_started"
}

struct OnboardingSchoolSearchStartedEventLog: EventLog {
    let name: String = "onboarding_school_search_started"
    let method: String

    var params: [String: String] {
        ["method": method]
    }
}

struct OnboardingSchoolSelectedEventLog: EventLog {
    let name: String = "onboarding_school_selected"
    let schoolType: String
    let searchMethod: String

    var params: [String: String] {
        ["school_type": schoolType, "search_method": searchMethod]
    }
}

struct OnboardingAhaMomentReachedEventLog: EventLog {
    let name: String = "onboarding_aha_moment_reached"
    let hasData: Bool
    let isNextSchoolDay: Bool

    var params: [String: String] {
        ["has_data": "\(hasData)", "is_next_school_day": "\(isNextSchoolDay)"]
    }
}

struct OnboardingWidgetAddTappedEventLog: EventLog {
    let name: String = "onboarding_widget_add_tapped"
}

struct OnboardingWidgetSkippedEventLog: EventLog {
    let name: String = "onboarding_widget_skipped"
}

struct OnboardingCompletedEventLog: EventLog {
    let name: String = "onboarding_completed"
    let durationSeconds: Int
    let stepsCompleted: Int

    var params: [String: String] {
        ["duration_seconds": "\(durationSeconds)", "steps_completed": "\(stepsCompleted)"]
    }
}
