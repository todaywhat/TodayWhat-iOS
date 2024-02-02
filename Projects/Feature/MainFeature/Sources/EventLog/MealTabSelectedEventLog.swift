import TWLog

struct MealTabSelectedEventLog: EventLog {
    let name: String = "meal_tab_selected_on_main_page"
    let params: [String: Any]

    init(tabSelectionType: TabSelectionType) {
        self.params = EventLogParameterBuilder()
            .set(key: "type", value: tabSelectionType.rawValue)
            .build()
    }
}
