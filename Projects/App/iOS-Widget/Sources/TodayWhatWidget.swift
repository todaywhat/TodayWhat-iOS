import Dependencies
import Entity
import EnumUtil
import IntentsUI
import LocalDatabaseClient
import MealClient
import SwiftUI
import TimeTableClient
import WidgetKit

@main
struct TodayWhatWidget: WidgetBundle {
    var body: some Widget {
        TodayWhatMealTimeTableWidget()
        TodayWhatMealWidget()
        TodayWhatTimeTableWidget()
    }
}

struct TodayWhatWidget_Previews: PreviewProvider {
    static var previews: some View {
        MealWidgetEntryView(
            entry: .empty()
        )
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
