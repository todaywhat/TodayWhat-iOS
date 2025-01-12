import AppIntents
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 18.0, *)
struct MealControlWidget: ControlWidget {
    static let kind: String = "TodayWhatMealControlWidget"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: MealControlWidget.kind,
            provider: MealControlValueProvider()
        ) { value in
            ControlWidgetButton(action: TodayWhatAppOpenIntent()) {
                Label {
                    Text(value.partTime.display)
                } icon: {
                    Image(systemName: "fork.knife")
                }
            }
        }
    }
}

struct MealControlValueProvider: ControlValueProvider {
    struct Value {
        let partTime: MealPartTime
    }

    var previewValue: Value = .init(
        partTime: .breakfast
    )

    func currentValue() async throws -> Value {
        let today = Date()
        let partTime = MealPartTime(hour: today)
        return .init(partTime: partTime)
    }
}
