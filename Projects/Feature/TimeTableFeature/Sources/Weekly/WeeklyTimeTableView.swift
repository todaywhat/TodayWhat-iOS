import ComposableArchitecture
import DesignSystem
import Entity
import SwiftUI

@available(iOS 16.0, *)
private struct ColumnBorder: Shape {
    var borderWidth: CGFloat
    var cornerRadius: CGFloat
    var selectedColumnIndex: Int?
    var headerHeight: CGFloat
    var firstColumnWidth: CGFloat
    var columnWidth: CGFloat
    var useFlexibleWidth: Bool
    var columnCount: Int
    var cellHeight: CGFloat
    var selectedColumnPeriodCount: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()

        guard let selectedIndex = selectedColumnIndex else { return path }

        let actualColumnWidth: CGFloat
        let columnX: CGFloat

        if useFlexibleWidth {
            let availableWidth = rect.width - firstColumnWidth
            actualColumnWidth = availableWidth / CGFloat(columnCount)
            columnX = firstColumnWidth + CGFloat(selectedIndex) * actualColumnWidth
        } else {
            actualColumnWidth = columnWidth
            columnX = firstColumnWidth + CGFloat(selectedIndex) * columnWidth
        }

        let actualHeight = CGFloat(selectedColumnPeriodCount) * cellHeight

        let columnRect = CGRect(
            x: columnX,
            y: headerHeight,
            width: actualColumnWidth,
            height: actualHeight
        )

        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        path = roundedRect.path(in: columnRect)

        return path
    }
}

public struct WeeklyTimeTableView: View {
    let store: StoreOf<WeeklyTimeTableCore>
    @ObservedObject var viewStore: ViewStoreOf<WeeklyTimeTableCore>
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    public init(store: StoreOf<WeeklyTimeTableCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if viewStore.weeklyTimeTable == nil && !viewStore.isLoading {
                VStack {
                    Text("이번 주 시간표를 찾을 수 없어요!")
                        .padding(.top, 16)
                        .foregroundColor(.textSecondary)
                        .accessibilityLabel("시간표를 찾을 수 없습니다")
                        .accessibilitySortPriority(1)

                    if Date().month == 3 || Date().month == 9 {
                        Text("학기 초에는 neis에 정규시간표가\n 등록되어있지 않을 수도 있어요.")
                            .multilineTextAlignment(.center)
                            .padding(.top, 14)
                            .foregroundColor(.textSecondary)
                            .accessibilityLabel("학기 초에는 정규시간표가 등록되어 있지 않을 수 있습니다")
                            .accessibilitySortPriority(2)
                    }
                }
            } else {
                ZStack(alignment: .top) {
                    if viewStore.isLoading {
                        ProgressView()
                            .progressViewStyle(.automatic)
                            .padding(.top, 16)
                            .accessibilityLabel("시간표를 불러오는 중입니다")
                            .accessibilitySortPriority(1)
                    }

                    if let weeklyTimeTable = viewStore.weeklyTimeTable {
                        if shouldUseFlexibleWidth(weeklyTimeTable: weeklyTimeTable) {
                            timeTableGrid(weeklyTimeTable: weeklyTimeTable)
                                .frame(alignment: .top)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                timeTableGrid(weeklyTimeTable: weeklyTimeTable)
                            }
                            .frame(alignment: .top)
                        }
                    }
                }
                .frame(minHeight: 560, alignment: .top)
            }
        }
        .onLoad {
            viewStore.send(.onLoad)
        }
        .onAppear {
            viewStore.send(.onAppear, animation: .default)
        }
        .refreshable {
            viewStore.send(.refresh, animation: .default)
        }
    }

    @ViewBuilder
    private func timeTableGrid(weeklyTimeTable: WeeklyTimeTableCore.WeeklyTimeTable) -> some View {
        let headerHeight: CGFloat = 40
        let firstColumnWidth: CGFloat = 32
        let columnCount = max(weeklyTimeTable.weekdays.count, 1)
        let periodCount = CGFloat(weeklyTimeTable.periods.count)

        if shouldUseFlexibleWidth(weeklyTimeTable: weeklyTimeTable) {
            GeometryReader { geometry in
                let availableWidth = max(geometry.size.width - firstColumnWidth, 0)
                let fallbackWidth = columnWidth(weeklyTimeTable: weeklyTimeTable)
                let rawCellSide = availableWidth / CGFloat(columnCount)
                let cellSide = rawCellSide > 0 ? rawCellSide : fallbackWidth

                timeTableContent(
                    weeklyTimeTable: weeklyTimeTable,
                    cellSide: cellSide,
                    headerHeight: headerHeight,
                    firstColumnWidth: firstColumnWidth
                )
                .frame(
                    width: firstColumnWidth + cellSide * CGFloat(columnCount),
                    alignment: .topLeading
                )
                .frame(
                    height: headerHeight + cellSide * periodCount,
                    alignment: .top
                )
            }
        } else {
            let cellSide = columnWidth(weeklyTimeTable: weeklyTimeTable)

            timeTableContent(
                weeklyTimeTable: weeklyTimeTable,
                cellSide: cellSide,
                headerHeight: headerHeight,
                firstColumnWidth: firstColumnWidth
            )
            .frame(
                width: firstColumnWidth + cellSide * CGFloat(columnCount),
                alignment: .topLeading
            )
            .frame(
                height: headerHeight + cellSide * periodCount,
                alignment: .top
            )
        }
    }

    @ViewBuilder
    private func timeTableContent(
        weeklyTimeTable: WeeklyTimeTableCore.WeeklyTimeTable,
        cellSide: CGFloat,
        headerHeight: CGFloat,
        firstColumnWidth: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            headerRow(
                weeklyTimeTable: weeklyTimeTable,
                cellWidth: cellSide,
                headerHeight: headerHeight,
                firstColumnWidth: firstColumnWidth
            )

            ForEach(weeklyTimeTable.periods, id: \.self) { period in
                timeTableRow(
                    period: period,
                    periodCount: weeklyTimeTable.periods.count,
                    weeklyTimeTable: weeklyTimeTable,
                    cellSide: cellSide,
                    firstColumnWidth: firstColumnWidth
                )
            }
        }
        .background(Color.cardBackground)
        .overlay {
            if #available(iOS 16.0, *) {
                ColumnBorder(
                    borderWidth: 1,
                    cornerRadius: 16,
                    selectedColumnIndex: weeklyTimeTable.todayIndex,
                    headerHeight: headerHeight,
                    firstColumnWidth: firstColumnWidth,
                    columnWidth: columnWidth(weeklyTimeTable: weeklyTimeTable),
                    useFlexibleWidth: shouldUseFlexibleWidth(weeklyTimeTable: weeklyTimeTable),
                    columnCount: weeklyTimeTable.weekdays.count,
                    cellHeight: cellSide,
                    selectedColumnPeriodCount: {
                        if let todayIndex = weeklyTimeTable.todayIndex {
                            weeklyTimeTable.actualPeriodCount(for: todayIndex)
                        } else {
                            0
                        }
                    }()
                )
                .stroke(Color.extraBlack, lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    private func headerRow(
        weeklyTimeTable: WeeklyTimeTableCore.WeeklyTimeTable,
        cellWidth: CGFloat,
        headerHeight: CGFloat,
        firstColumnWidth: CGFloat
    ) -> some View {
        HStack(spacing: 0) {
            Text("")
                .frame(width: firstColumnWidth, height: headerHeight)

            ForEach(0..<weeklyTimeTable.weekdays.count, id: \.self) { index in
                VStack(spacing: 2) {
                    Text(weeklyTimeTable.weekdays[index])
                        .twFont(horizontalSizeClass == .regular ? .body1 : .body2, color: .textSecondary)
                }
                .frame(width: cellWidth, height: headerHeight)
            }
        }
    }

    @ViewBuilder
    private func timeTableRow(
        period: Int,
        periodCount: Int,
        weeklyTimeTable: WeeklyTimeTableCore.WeeklyTimeTable,
        cellSide: CGFloat,
        firstColumnWidth: CGFloat
    ) -> some View {
        HStack(spacing: 0) {
            Text("\(period)")
                .twFont(.body2, color: .textSecondary)
                .frame(width: firstColumnWidth, height: cellSide)

            ForEach(0..<weeklyTimeTable.weekdays.count, id: \.self) { weekdayIndex in
                let subject = weeklyTimeTable.subject(
                    for: period - 1,
                    weekday: weekdayIndex
                )

                Text(subject)
                    .twFont(
                        fontForCell(
                            isToday: weeklyTimeTable.isToday(weekdayIndex: weekdayIndex),
                            horizontalSizeClass: horizontalSizeClass
                        ),
                        color: weeklyTimeTable.isToday(weekdayIndex: weekdayIndex) ? Color.extraBlack : .textSecondary
                    )
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.3)
                    .padding(8)
                    .frame(width: cellSide, height: cellSide)
                    .background(Color.extraWhite)
                    .overlay(alignment: .bottom) {
                        if period != periodCount {
                            Rectangle()
                                .fill(Color.unselectedSecondary)
                                .frame(height: 1.0)
                        }
                    }
            }
        }
    }

    private func shouldUseFlexibleWidth(weeklyTimeTable: WeeklyTimeTableCore.WeeklyTimeTable) -> Bool {
        return horizontalSizeClass == .regular || !viewStore.showWeekend
    }

    private func columnWidth(weeklyTimeTable: WeeklyTimeTableCore.WeeklyTimeTable) -> CGFloat {
        return viewStore.showWeekend ? 64.0 : 65.5
    }

    private func fontForCell(isToday: Bool, horizontalSizeClass: UserInterfaceSizeClass?) -> Font.TWFontSystem {
        if horizontalSizeClass == .regular {
            return isToday ? .body1 : .body2
        } else {
            return isToday ? .caption1 : .caption1
        }
    }
}
