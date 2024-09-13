import TWLog

struct MealTabSelectedEventLog: EventLog {
    let name: String = "select_meal_tab"
    let params: [String: String]

    init(tabSelectionType: TabSelectionType) {
        self.params = [
            "type": tabSelectionType.rawValue
        ]
    }
}
