import Dependencies
import WidgetKit
import SwiftUI
import Intents
import Entity
import MealClient

struct Provider: IntentTimelineProvider {
    typealias Entry = SimpleEntry

    @Dependency(\.mealClient) var mealClient

    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry.empty(configuration: ConfigurationIntent())
    }

    func getSnapshot(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (SimpleEntry) -> ()
    ) {
        let currentDate = Date()
        Task {
            do {
                let meal = try await mealClient.fetchMeal(currentDate)
                let entry = SimpleEntry(
                    date: currentDate,
                    configuration: configuration,
                    meal: meal,
                    mealPartTime: MealPartTime(hour: currentDate)
                )
                completion(entry)
            } catch {
                let entry = SimpleEntry.empty(configuration: configuration)
                completion(entry)
            }
        }
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? .init()
        let currentDate = Date()
        Task {
            do {
                let meal = try await mealClient.fetchMeal(currentDate)
                let entry = SimpleEntry(
                    date: currentDate,
                    configuration: configuration,
                    meal: meal,
                    mealPartTime: MealPartTime(hour: currentDate)
                )
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                let entry = SimpleEntry.empty(configuration: configuration)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let meal: Meal
    let mealPartTime: MealPartTime

    static func empty(configuration: ConfigurationIntent) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: configuration,
            meal: .init(
                breakfast: .init(meals: [], cal: 0),
                lunch: .init(meals: [], cal: 0),
                dinner: .init(meals: [], cal: 0)
            ),
            mealPartTime: .breakfast
        )
    }
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
            entry: .empty(configuration: ConfigurationIntent())
        )
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
