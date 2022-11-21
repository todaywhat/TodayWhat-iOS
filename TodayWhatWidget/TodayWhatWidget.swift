import Dependencies
import WidgetKit
import SwiftUI
import Intents
import Entity

struct Provider: IntentTimelineProvider {
    typealias Entry = SimpleEntry
    func placeholder(in context: Context) -> SimpleEntry {
        let currentDate = Date()
        return SimpleEntry(date: currentDate, configuration: ConfigurationIntent(), mealPartTime: MealPartTime(hour: currentDate))
    }

    func getSnapshot(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (SimpleEntry) -> ()
    ) {
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, configuration: configuration, mealPartTime: .breakfast)
        completion(entry)
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? .init()
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let mealPartTime = MealPartTime(hour: currentDate)
            let entry = SimpleEntry(date: entryDate, configuration: configuration, mealPartTime: mealPartTime)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let mealPartTime: MealPartTime
}

@main
struct TodayWhatWidget: Widget {
    let kind: String = "TodayWhatWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            MealWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}



struct TodayWhatWidget_Previews: PreviewProvider {
    static var previews: some View {
        MealWidgetEntryView(
            entry: .init(
                date: Date(),
                configuration: ConfigurationIntent(),
                mealPartTime: .breakfast
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
