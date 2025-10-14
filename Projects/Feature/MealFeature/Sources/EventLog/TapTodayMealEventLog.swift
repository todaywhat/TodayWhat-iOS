import TWLog

struct TapTodayMealEventLog: EventLog {
    let name: String = "tap_today_meal"
    let params: [String: String] = [:]
}
