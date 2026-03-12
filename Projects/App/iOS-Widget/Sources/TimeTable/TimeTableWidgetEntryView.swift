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
            if entry.timeTable.isEmpty {
                Spacer()

                Text("시간표를 찾을 수 없어요!")
                    .twFont(.caption1, color: .textSecondary)
                    .frame(maxWidth: .infinity)

                if Date().month == 3 || Date().month == 9 {
                    Text("학기 초에는 neis에 정규시간표가\n등록되어있지 않을 수도 있어요.")
                        .multilineTextAlignment(.center)
                        .twFont(.caption1, color: .textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                }

                Spacer()
            } else {
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
        }
        .padding(12)
    }
}

private struct MediumTimeTableWidgetView: View {
    let entry: TimeTableProvider.Entry
    private let rows = Array(repeating: GridItem(.flexible(), spacing: nil), count: 4)
    @Environment(\.backportedWidgetRenderingMode) var widgetRenderingMode: BackportedWidgetRenderingMode

    @ViewBuilder
    private var columnBackground: some View {
        switch widgetRenderingMode {
        case .accented:
            if #available(iOSApplicationExtension 26.0, *) {
                EmptyView()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.cardBackground, lineWidth: 1)
            }

        case .fullColor, .vibrant:
            if #available(iOSApplicationExtension 26.0, *) {
                ConcentricRectangle()
                    .fill(Color.cardBackground)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
            }

        default:
            if #available(iOSApplicationExtension 26.0, *) {
                ConcentricRectangle()
                    .fill(Color.cardBackground)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
            }
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(getTimeTableText(date: entry.date))
                        .twFont(.caption1, color: .textPrimary)

                    Spacer()

                    Text("\(entry.date.month)월 \(entry.date.day)일 \(entry.date.weekdayString)")
                        .twFont(.caption1, color: .textSecondary)
                }
                .widgetAccentableIfAvailable()
                .padding(.horizontal, 4)

                if entry.timeTable.isEmpty {
                    VStack(spacing: 4) {
                        Text("시간표를 찾을 수 없어요!")
                            .twFont(.caption1, color: .textSecondary)

                        if Date().month == 3 || Date().month == 9 {
                            Text("학기 초에는 neis에 정규시간표가\n등록되어있지 않을 수도 있어요.")
                                .multilineTextAlignment(.center)
                                .twFont(.caption1, color: .textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                    .background {
                        columnBackground
                    }
                    .padding([.bottom, .horizontal], 4)
                } else {
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
                    .widgetAccentableIfAvailable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                    .background {
                        columnBackground
                    }
                    .padding([.bottom, .horizontal], 4)
                }
            }
            .padding(12)
        }
    }

    func getTimeTableText(date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDate(date, inSameDayAs: now) {
            return "오늘의 [시간표]"
        }

        let components = calendar.dateComponents([.day], from: now, to: date)

        if let days = components.day, days == 1 {
            return "내일의 [시간표]"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeek = dateFormatter.string(from: date)
        return "\(dayOfWeek) [시간표]"
    }
}

private struct LargeTimeTableWidgetView: View {
    let entry: TimeTableProvider.Entry
    @Environment(\.backportedWidgetRenderingMode) var widgetRenderingMode: BackportedWidgetRenderingMode

    @ViewBuilder
    private var columnBackground: some View {
        switch widgetRenderingMode {
        case .accented:
            if #available(iOSApplicationExtension 26.0, *) {
                EmptyView()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.cardBackground, lineWidth: 1)
            }

        case .fullColor, .vibrant:
            if #available(iOSApplicationExtension 26.0, *) {
                ConcentricRectangle()
                    .fill(Color.cardBackground)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
            }

        default:
            if #available(iOSApplicationExtension 26.0, *) {
                ConcentricRectangle()
                    .fill(Color.cardBackground)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
            }
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text(getTimeTableText(date: entry.date))
                    .twFont(.caption1, color: .textPrimary)

                Spacer()

                Text("\(entry.date.month)월 \(entry.date.day)일 \(entry.date.weekdayString)")
                    .twFont(.caption1, color: .textSecondary)
            }
            .widgetAccentableIfAvailable()
            .padding(.horizontal, 4)

            if entry.timeTable.isEmpty {
                VStack(spacing: 4) {
                    Text("시간표를 찾을 수 없어요!")
                        .twFont(.body1, color: .textSecondary)

                    if Date().month == 3 || Date().month == 9 {
                        Text("학기 초에는 neis에 정규시간표가\n등록되어있지 않을 수도 있어요.")
                            .multilineTextAlignment(.center)
                            .twFont(.caption1, color: .textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 4)
                .background {
                    columnBackground
                }
            } else {
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
                .widgetAccentableIfAvailable()
                .padding(.top, 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    columnBackground
                }
            }
        }
        .padding(12)
    }

    func getTimeTableText(date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDate(date, inSameDayAs: now) {
            return "오늘의 [시간표]"
        }

        let components = calendar.dateComponents([.day], from: now, to: date)

        if let days = components.day, days == 1 {
            return "내일의 [시간표]"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeek = dateFormatter.string(from: date)
        return "\(dayOfWeek) [시간표]"
    }
}
