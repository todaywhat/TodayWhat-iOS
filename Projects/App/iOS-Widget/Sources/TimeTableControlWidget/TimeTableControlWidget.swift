import AppIntents
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 18.0, *)
struct TimeTableControlWidget: ControlWidget {
    static let kind: String = "TodayWhatTimeTableControlWidget"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: TimeTableControlWidget.kind
        ) {
            ControlWidgetButton(action: TodayWhatAppOpenIntent()) {
                Label {
                    Text("시간표")
                } icon: {
                    Image(systemName: "clock.fill")
                }
            }
        }
    }
}
