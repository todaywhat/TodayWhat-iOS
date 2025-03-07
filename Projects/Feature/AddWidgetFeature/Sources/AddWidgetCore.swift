import ComposableArchitecture
import ComposableArchitectureWrapper
import Intents

public struct AddWidgetCore: Reducer {
    public struct State: Equatable {
        public var selectedWidget: WidgetReperesentation?
        public var availableWidgets: [WidgetReperesentation]

        public init(
            availableWidgets: [WidgetReperesentation] = []
        ) {
            self.selectedWidget = nil
            self.availableWidgets = availableWidgets
        }
    }

    public enum Action: Equatable {
        case selectWidget(WidgetReperesentation)
        case onAppear
        case loadWidgets([WidgetReperesentation])
        case showWidgetGuide(Bool)
        case addWidgetComplete
    }

    public init() {}

    public var body: some ReducerOf<AddWidgetCore> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let widgets: [WidgetReperesentation] = [
                    WidgetReperesentation(kind: .mealAndTimetable, family: .systemMedium),
                    WidgetReperesentation(kind: .meal, family: .systemSmall),
                    WidgetReperesentation(kind: .meal, family: .systemMedium),
                    WidgetReperesentation(kind: .meal, family: .systemLarge),
                    WidgetReperesentation(kind: .meal, family: .accessory),
                    WidgetReperesentation(kind: .meal, family: .controlCenter),
                    WidgetReperesentation(kind: .timetable, family: .systemSmall),
                    WidgetReperesentation(kind: .timetable, family: .systemMedium),
                    WidgetReperesentation(kind: .timetable, family: .systemLarge),
                    WidgetReperesentation(kind: .timetable, family: .controlCenter)
                ]

                return .send(.loadWidgets(widgets))

            case let .loadWidgets(widgets):
                state.availableWidgets = widgets
                return .none

            case let .selectWidget(widget):
                state.selectedWidget = widget
                return .none

            case let .showWidgetGuide(isShowing):
                if isShowing == false {
                    state.selectedWidget = nil
                }
                return .none

            case .addWidgetComplete:
                state.selectedWidget = nil
                return .none
            }
        }
    }
}
