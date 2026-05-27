import TWLog

struct OnboardingCompleteEventLog: EventLog {
    let name: String = "onboarding_complete"
    let params: [String: String] = [:]
}
