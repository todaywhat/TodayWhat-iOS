import Dependencies
import DesignSystem
import Entity
import Intents
import SwiftUI
import SwiftUIUtil
import WidgetKit

struct TimeTableWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    let entry: TimeTableProvider.Entry

    var body: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            widgetBody()
                .containerBackground(for: .widget) {
                    Color.backgroundMain
                }
        } else {
            widgetBody()
        }
    }

    @ViewBuilder
    func widgetBody() -> some View {
        switch widgetFamily {
        case .systemSmall:
            SmallTimeTableWidgetView(entry: entry)

        case .systemMedium:
            MediumTimeTableWidgetView(entry: entry)

        case .systemLarge:
            LargeTimeTableWidgetView(entry: entry)

        default:
            EmptyView()
        }
    }
}

private struct SmallTimeTableWidgetView: View {
    let entry: TimeTableProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(entry.timeTable, id: \.hashValue) { timeTable in
                HStack(spacing: 4) {
                    Text("\(timeTable.perio)")
                        .twFont(.caption1, color: .textSecondary)

                    Text(timeTable.content)
                        .twFont(.caption1, color: .extraBlack)
                        .lineLimit(1)

                    Spacer()
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(12)
    }
}

private struct MediumTimeTableWidgetView: View {
    let entry: TimeTableProvider.Entry
    private let rows = Array(repeating: GridItem(.flexible(), spacing: nil), count: 4)

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("ONMI")
                        .font(.custom("Fraunces9pt-Black", size: 16))
                        .foregroundColor(.extraBlack)

                    Text("[시간표]")
                        .twFont(.caption1, color: .textPrimary)

                    Spacer()

                    Text("\(entry.date.month)월 \(entry.date.day)일 \(entry.date.weekdayString)")
                        .twFont(.caption1, color: .textSecondary)
                }
                .padding(.horizontal, 4)

                LazyHGrid(rows: rows, spacing: 0) {
                    ForEach(entry.timeTable, id: \.hashValue) { timetable in
                        HStack(spacing: 2) {
                            Text("\(timetable.perio)")
                                .twFont(.caption1, color: .textSecondary)

                            Text(timetable.content)
                                .twFont(.caption1, color: .extraBlack)

                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
                        .frame(width: (proxy.size.width / 2) - 24)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(8)
                .background {
                    Color.cardBackground
                        .cornerRadius(8)
                }
                .padding([.bottom, .horizontal], 4)
            }
            .padding(12)
        }
    }
}

private struct LargeTimeTableWidgetView: View {
    let entry: TimeTableProvider.Entry

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("ONMI")
                    .font(.custom("Fraunces9pt-Black", size: 16))
                    .foregroundColor(.extraBlack)

                Text("[시간표]")
                    .twFont(.caption1, color: .textPrimary)

                Spacer()

                Text("\(entry.date.month)월 \(entry.date.day)일 \(entry.date.weekdayString)")
                    .twFont(.caption1, color: .textSecondary)
            }
            .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(entry.timeTable, id: \.hashValue) { timetable in
                    HStack(spacing: 4) {
                        Text("\(timetable.perio)")
                            .twFont(.body1, color: .textSecondary)

                        Text(timetable.content)
                            .twFont(.body1, color: .extraBlack)

                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, 8)
                }
            }
            .padding(.top, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.cardBackground
            }
            .cornerRadius(8)
        }
        .padding(12)
    }
}
