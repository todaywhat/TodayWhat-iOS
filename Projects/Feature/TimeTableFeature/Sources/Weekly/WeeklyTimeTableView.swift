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
        ScrollView(.vertical) {
            VStack {
                if viewStore.weeklyTimeTable == nil && !viewStore.isLoading {
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
                                ScrollView(.horizontal) {
                                    timeTableGrid(weeklyTimeTable: weeklyTimeTable)
                                        .frame(alignment: .top)
                                }
                            }
                        }
                    }
                }
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
        VStack(spacing: 0) {
            headerRow(weeklyTimeTable: weeklyTimeTable)

            ForEach(weeklyTimeTable.periods, id: \.self) { period in
                timeTableRow(period: period, weeklyTimeTable: weeklyTimeTable)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .overlay {
            if #available(iOS 16.0, *) {
                ColumnBorder(
                    borderWidth: 1,
                    cornerRadius: 16,
                    selectedColumnIndex: weeklyTimeTable.todayIndex,
                    headerHeight: 44,
                    firstColumnWidth: 40,
                    columnWidth: columnWidth(weeklyTimeTable: weeklyTimeTable),
                    useFlexibleWidth: shouldUseFlexibleWidth(weeklyTimeTable: weeklyTimeTable),
                    columnCount: weeklyTimeTable.weekdays.count,
                    cellHeight: 56,
                    selectedColumnPeriodCount: {
                        if let todayIndex = weeklyTimeTable
                            .todayIndex { weeklyTimeTable.actualPeriodCount(for: todayIndex)
                        } else {
                            0
                        }
                    }()
                )
                .stroke(Color.extraBlack.opacity(0.8), lineWidth: 2)
            }
        }
    }

    @ViewBuilder
    private func headerRow(weeklyTimeTable: WeeklyTimeTableCore.WeeklyTimeTable) -> some View {
        HStack(spacing: 0) {
            Text("")
                .frame(width: 40, height: 44)
                .background(Color.unselectedSecondary.opacity(0.1))

            ForEach(0..<weeklyTimeTable.weekdays.count, id: \.self) { index in
                VStack(spacing: 2) {
                    Text(weeklyTimeTable.weekdays[index])
                        .twFont(horizontalSizeClass == .regular ? .body2 : .body3, color: .textPrimary)
                }
                .frame(
                    maxWidth: shouldUseFlexibleWidth(weeklyTimeTable: weeklyTimeTable) ? .infinity : nil,
                    minHeight: 44
                )
                .frame(
                    width: { () -> CGFloat? in
                        return shouldUseFlexibleWidth(weeklyTimeTable: weeklyTimeTable)
                            ? nil
                            : columnWidth(weeklyTimeTable: weeklyTimeTable)
                    }()
                )
                .background(
                    weeklyTimeTable.isToday(weekdayIndex: index)
                        ? Color.unselectedSecondary.opacity(0.2)
                        : Color.unselectedSecondary.opacity(0.1)
                )
                .overlay(
                    Rectangle()
                        .fill(Color.unselectedSecondary.opacity(0.3))
                        .frame(height: 0.5),
                    alignment: .bottom
                )
            }
        }
    }

    @ViewBuilder
    private func timeTableRow(
        period: Int,
        weeklyTimeTable: WeeklyTimeTableCore.WeeklyTimeTable
    ) -> some View {
        HStack(spacing: 0) {
            Text("\(period)")
                .twFont(horizontalSizeClass == .regular ? .body2 : .body3, color: .textPrimary)
                .frame(width: 40, height: 56)
                .background(Color.unselectedSecondary.opacity(0.05))

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
                        color: .textPrimary
                    )
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(
                        maxWidth: shouldUseFlexibleWidth(weeklyTimeTable: weeklyTimeTable) ? .infinity : nil,
                        minHeight: 56
                    )
                    .frame(
                        width: { () -> CGFloat? in
                            shouldUseFlexibleWidth(weeklyTimeTable: weeklyTimeTable)
                                ? nil
                                : columnWidth(weeklyTimeTable: weeklyTimeTable)
                        }()
                    )
                    .background(Color.extraWhite)
                    .overlay(
                        Rectangle()
                            .fill(Color.unselectedSecondary.opacity(0.3))
                            .frame(height: 0.5),
                        alignment: .bottom
                    )
            }
        }
    }

    private func shouldUseFlexibleWidth(weeklyTimeTable: WeeklyTimeTableCore.WeeklyTimeTable) -> Bool {
        return horizontalSizeClass == .regular || !viewStore.showWeekend
    }

    private func columnWidth(weeklyTimeTable: WeeklyTimeTableCore.WeeklyTimeTable) -> CGFloat {
        return viewStore.showWeekend ? 55.0 : 65.5
    }

    private func fontForCell(isToday: Bool, horizontalSizeClass: UserInterfaceSizeClass?) -> Font.TWFontSystem {
        if horizontalSizeClass == .regular {
            return isToday ? .body1 : .body2
        } else {
            return isToday ? .body3 : .body2
        }
    }
}
