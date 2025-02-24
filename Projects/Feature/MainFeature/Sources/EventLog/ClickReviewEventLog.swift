import TWLog

struct ClickReviewEventLog: EventLog {
    let name: String = "click_review"
    let params: [String: String] = [:]
}
