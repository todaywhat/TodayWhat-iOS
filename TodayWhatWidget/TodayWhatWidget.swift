//
//  TodayWhatWidget.swift
//  TodayWhatWidget
//
//  Created by 최형우 on 2022/11/15.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct TodayWhatWidgetEntryView : View {
    var entry: Provider.Entry
    var dummy = ["친환경백미찹쌀밥", "매콤어묵무국", "닭갈비", "청포묵무침", "치즈소떡소떡&양념소스", "배추김치", "상큼이주스", "닭가슴살양상추샐러드&오리엔탈"]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(dummy, id: \.self) { meal in
                Text(meal)
                    .font(.system(size: 13))
                    .lineLimit(1)
            }
        }
        .padding(4)
    }
}

@main
struct TodayWhatWidget: Widget {
    let kind: String = "TodayWhatWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TodayWhatWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct TodayWhatWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodayWhatWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
