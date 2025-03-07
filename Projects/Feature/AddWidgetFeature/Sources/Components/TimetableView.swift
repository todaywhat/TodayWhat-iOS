import DateUtil
import DesignSystem
import SwiftUI

struct TimetableView: View {
    let family: WidgetReperesentation.WidgetFamilyType

    var body: some View {
        switch family {
        case .systemSmall:
            TimetableSmallView()
                .frame(width: WidgetSizeConstants.small.width, height: WidgetSizeConstants.small.height)

        case .systemMedium:
            TimetableMediumView()
                .frame(width: WidgetSizeConstants.medium.width, height: WidgetSizeConstants.medium.height)

        case .systemLarge:
            TimetableLargeView()
                .frame(width: WidgetSizeConstants.large.width, height: WidgetSizeConstants.large.height)

        case .controlCenter:
            VStack(alignment: .leading) {
                HStack {
                    TimetableControlCenterSmallView()
                        .frame(
                            width: WidgetSizeConstants.controlCenterSmall.width,
                            height: WidgetSizeConstants.controlCenterSmall.height
                        )

                    TimetableControlCenterMediumView()
                        .frame(
                            width: WidgetSizeConstants.controlCenterMedium.width,
                            height: WidgetSizeConstants.controlCenterMedium.height
                        )
                }

                TimetableControlCenterLargeView()
                    .frame(
                        width: WidgetSizeConstants.controlCenterLarge.width,
                        height: WidgetSizeConstants.controlCenterLarge.height
                    )
            }
        default:
            EmptyView()
        }
    }
}

private struct TimetableSmallView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.backgroundMain)
            .overlay(
                VStack(alignment: .leading, spacing: 0) {
                    let items = ["현대문학 감상", "음악 감상과 비평", "운동과 건강", "영미 문학 읽기", "생활과 과학", "미적분", "논술"]
                    ForEach(
                        Array(zip(items.indices, items)),
                        id: \.0
                    ) { index, item in
                        HStack(spacing: 4) {
                            Text("\(index + 1)")
                                .twFont(.caption1)
                                .foregroundColor(.textSecondary)

                            Text(item)
                                .twFont(.caption1)
                                .foregroundStyle(Color.extraBlack)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                }
                .padding(10)
            )
    }
}

private struct TimetableMediumView: View {
    private let rows = Array(repeating: GridItem(.flexible(), spacing: nil), count: 4)
    private let today = Date()

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.backgroundMain)
            .overlay {
                GeometryReader { proxy in
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Text("오늘의 [시간표]")
                                .twFont(.caption1, color: .textPrimary)

                            Spacer()

                            Text("\(today.month)월 \(today.day)일 \(today.weekdayString)")
                                .twFont(.caption1, color: .textSecondary)
                        }
                        .padding(.horizontal, 4)

                        let items = ["현대문학 감상", "음악 감상과 비평", "운동과 건강", "영미 문학 읽기", "생활과 과학", "미적분", "논술"]
                        LazyHGrid(rows: rows, spacing: 0) {
                            ForEach(
                                Array(zip(items.indices, items)),
                                id: \.0
                            ) { index, timetable in
                                HStack(spacing: 2) {
                                    Text("\(index + 1)")
                                        .twFont(.caption1, color: .textSecondary)

                                    Text(timetable)
                                        .twFont(.caption1, color: .extraBlack)
                                }
                                .frame(maxHeight: .infinity)
                                .frame(width: (proxy.size.width / 2) - 24, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(8)
                        .background {
                            Color.cardBackground
                                .cornerRadius(8)
                        }
                        .padding([.bottom, .horizontal], 4)
                    }
                    .padding(8)
                }
            }
    }
}

private struct TimetableLargeView: View {
    private let today = Date()

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.backgroundMain)
            .overlay {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("오늘의 [시간표]")
                            .twFont(.caption1, color: .textPrimary)

                        Spacer()

                        Text("\(today.month)월 \(today.day)일 \(today.weekdayString)")
                            .twFont(.caption1, color: .textSecondary)
                    }
                    .padding(.horizontal, 4)

                    let items = ["현대문학 감상", "음악 감상과 비평", "운동과 건강", "영미 문학 읽기", "생활과 과학", "미적분", "논술"]
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(
                            Array(zip(items.indices, items)),
                            id: \.0
                        ) { index, timetable in
                            HStack(spacing: 4) {
                                Text("\(index + 1)")
                                    .twFont(.body1, color: .textSecondary)

                                Text(timetable)
                                    .twFont(.body1, color: .extraBlack)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                        }
                    }
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background {
                        Color.cardBackground
                    }
                    .cornerRadius(8)
                }
                .padding(8)
            }
    }
}

private struct TimetableControlCenterSmallView: View {
    var body: some View {
        Circle()
            .fill(.thinMaterial)
            .overlay {
                Image(systemName: "clock.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Color.extraBlack)
            }
    }
}

private struct TimetableControlCenterMediumView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay {
                HStack(alignment: .center) {
                    Image(systemName: "clock.fill")
                        .resizable()
                        .frame(width: 32, height: 32)

                    Text("시간표")
                        .twFont(.body3)
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.extraBlack)
            }
    }
}

private struct TimetableControlCenterLargeView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay {
                VStack {
                    Image(systemName: "clock.fill")
                        .resizable()
                        .frame(width: 32, height: 32)

                    Spacer()

                    Text("시간표")
                        .twFont(.body3)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.extraBlack)
            }
    }
}
