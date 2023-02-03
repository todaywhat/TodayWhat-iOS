import SwiftUI
import WidgetKit
import Intents
import Dependencies
import Entity
import TWColor
import SwiftUIUtil

struct TimeTableWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    let entry: TimeTableProvider.Entry

    var body: some View {
        widgetBody()
    }

    @ViewBuilder
    func widgetBody() -> some View {
        switch widgetFamily {
        case .systemSmall:
            SmallTimeTableWidgetView(entry: entry)

        default:
            EmptyView()
        }
    }
}

private struct SmallTimeTableWidgetView: View {
    var entry: TimeTableProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("[시간표]")
                .frame(maxHeight: .infinity)
                .font(.system(size: 12).bold())

            ForEach(entry.timeTable, id: \.hashValue) { timeTable in
                HStack(spacing: 4) {
                    Text("\(timeTable.perio)교시")
                        .font(.system(size: 12).bold())

                    Text(timeTable.content)
                        .font(.system(size: 12))
                        .foregroundColor(.darkGray)
                        .lineLimit(1)

                    Spacer()
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(12)
    }
}
