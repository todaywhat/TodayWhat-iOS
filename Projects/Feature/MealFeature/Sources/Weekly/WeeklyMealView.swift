import ComposableArchitecture
import DesignSystem
import Entity
import EnumUtil
import SwiftUI
import TWLog
import UIKit

public struct WeeklyMealView: View {
    let store: StoreOf<WeeklyMealCore>
    @ObservedObject var viewStore: ViewStoreOf<WeeklyMealCore>
    @Environment(\.calendar) private var calendar
    @Environment(\.displayScale) var displayScale
    @State private var shouldShowTodayButton = false
    @State private var todayButtonDirection: TodayButtonDirection = .up

    public init(store: StoreOf<WeeklyMealCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        GeometryReader { outerGeometry in
            ScrollViewReader { proxy in
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        ZStack(alignment: .top) {
                            if (viewStore.weeklyMeals.isEmpty || viewStore.weeklyMeals.allSatisfy { $0.isEmpty }) && !viewStore.isLoading {
                                emptyStateView
                            } else {
                                LazyVStack(spacing: 40) {
                                    ForEach(viewStore.weeklyMeals, id: \.date) { dayMeal in
                                        daySection(dayMeal: dayMeal)
                                            .background(
                                                GeometryReader { geometry in
                                                    Color.clear.preference(
                                                        key: DayFramePreferenceKey.self,
                                                        value: [
                                                            calendar.startOfDay(for: dayMeal.date): geometry.frame(in: .global)
                                                        ]
                                                    )
                                                }
                                            )
                                            .id(dayMeal.date)
                                    }

                                    Spacer()
                                        .frame(height: 64)
                                }
                                .padding(.top, 16)
                            }

                            if viewStore.isLoading {
                                ProgressView()
                                    .progressViewStyle(.automatic)
                                    .padding(.top, 16)
                                    .accessibilityLabel("이번 주 급식 정보를 불러오는 중입니다")
                                    .accessibilitySortPriority(1)
                            }
                        }
                    }
                    .coordinateSpace(name: "WeeklyMealScroll")
                    .onLoad {
                        viewStore.send(.onLoad)
                    }
                    .onAppear {
                        viewStore.send(.onAppear, animation: .default)
                        scrollToToday(proxy: proxy)
                    }
                    .onChange(of: viewStore.weeklyMeals) { _ in
                        scrollToToday(proxy: proxy)
                    }
                    .refreshable {
                        viewStore.send(.refresh, animation: .default)
                    }
                    .onPreferenceChange(DayFramePreferenceKey.self) { frames in
                        let containerFrame = outerGeometry.frame(in: .global)
                        updateTodayButtonVisibility(containerFrame: containerFrame, dayFrames: frames)
                    }

                    if shouldShowTodayButton {
                        todayButton(direction: todayButtonDirection) {
                            scrollToToday(proxy: proxy)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                        .transition(
                          .opacity.combined(with: .move(edge: .trailing))
                        )
                        .zIndex(1)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Spacer()

            Text("이번 주 급식을 찾을 수 없어요!")
                .twFont(.body1, color: .textSecondary)
                .padding(.top, 16)
                .foregroundColor(.textSecondary)
                .accessibilityLabel("급식을 찾을 수 없습니다")
                .accessibilitySortPriority(1)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func daySection(dayMeal: WeeklyMealCore.State.DayMeal) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(dayMeal.date, format: .dateTime.month().day().weekday(.wide))
                .twFont(.body3, color: .textSecondary)
                .padding(.horizontal, 28)

            if dayMeal.isEmpty {
                Text("급식 없음")
                    .twFont(.body1, color: .textSecondary)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.backgroundMain)
                    }
                    .padding(.horizontal, 16)
            } else {
                ForEach([MealType.breakfast, .lunch, .dinner], id: \.hashValue) { type in
                    let subMeal = dayMeal.meal.mealByType(type: type)
                    if !subMeal.meals.isEmpty {
                        mealCard(dayMeal: dayMeal, type: type, subMeal: subMeal)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func mealCard(
        dayMeal: WeeklyMealCore.State.DayMeal,
        type: MealType,
        subMeal: Meal.SubMeal
    ) -> some View {
        let isToday = calendar.isDate(dayMeal.date, inSameDayAs: viewStore.today)
        let isHighlighted = isToday && viewStore.currentTimeMealType == type

        let mealCardView = VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(relativeTitle(for: dayMeal.date, mealType: type))
                    .twFont(.headline4, color: .textPrimary)

                Spacer()

                Text("\(String(format: "%.1f", subMeal.cal)) Kcal")
                    .twFont(.body2, color: .unselectedPrimary)
            }

            Divider()
                .foregroundStyle(Color.unselectedSecondary)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(subMeal.meals, id: \.hashValue) { meal in
                    let mealText = mealDisplay(meal: meal)
                    let containsAllergy = isMealContainsAllergy(meal: meal)

                    HStack(alignment: .center, spacing: 8) {
                        Text(mealText)
                            .twFont(.headline4, color: containsAllergy ? .point : .textPrimary)

                        if containsAllergy {
                            Image.allergy
                                .renderingMode(.template)
                                .foregroundStyle(Color.point)
                                .accessibilityHidden(true)
                        }

                        Spacer()
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(mealText)
                    .accessibilityHint(
                        containsAllergy
                            ? "알레르기 유발 식품이 포함되어 있습니다"
                            : ""
                    )
                    .contentShape(Rectangle())
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.backgroundMain)
        }

        mealCardView
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(relativeTitle(for: dayMeal.date, mealType: type)) \(String(format: "%.1f", subMeal.cal)) 칼로리")
            .contextMenu {
                Button {
                    let mealToCopy = subMeal.meals
                        .map { mealDisplay(meal: $0) }
                        .joined(separator: "\n")
                    let dateText = "\(dayMeal.date.formatted(.dateTime.month().day().weekday(.wide))) \(type.display)"
                    UIPasteboard.general.string = "\(dateText)\n\(mealToCopy)"
                    TWLog.event(ShareMealEventLog())
                } label: {
                    Label("복사하기", systemImage: "doc.on.doc")
                }

                if #available(iOS 16.0, *) {
                    Button {
                        let renderer = ImageRenderer(content: mealCardView)
                        renderer.scale = displayScale
                        if let image = renderer.uiImage {
                            UIPasteboard.general.image = image
                            TWLog.event(ShareMealImageEventLog())
                        }
                    } label: {
                        Label("이미지로 복사하기", systemImage: "photo")
                    }
                }
            }
            .onDrag {
                let mealToDrag = subMeal.meals
                    .map { mealDisplay(meal: $0) }
                    .joined(separator: "\n")
                let dateText = "\(dayMeal.date.formatted(.dateTime.month().day().weekday(.wide))) \(type.display)"
                return NSItemProvider(object: "\(dateText)\n\(mealToDrag)" as NSString)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isHighlighted ? Color.extraBlack : Color.clear, lineWidth: 2)
            }
            .padding(.horizontal, 16)
    }

    private func mealDisplay(meal: String) -> String {
        meal.replacingOccurrences(of: "[0-9.() ]", with: "", options: [.regularExpression])
    }

    private func isMealContainsAllergy(meal: String) -> Bool {
        viewStore.allergyList.first {
            meal.contains("(\($0.number)") || meal.contains(".\($0.number)")
        } != nil
    }

    private func relativeTitle(for date: Date, mealType: MealType) -> String {
        let today = calendar.startOfDay(for: viewStore.today)
        let target = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: today, to: target)
        let dayDifference = components.day ?? 0

        let dayPrefix: String
        switch dayDifference {
        case 0:
            dayPrefix = "오늘"
        case 1:
            dayPrefix = "내일"
        case -1:
            dayPrefix = "어제"
        default:
            dayPrefix = date.formatted(.dateTime.weekday(.wide))
        }

        return "\(dayPrefix) \(mealType.display)"
    }

    @ViewBuilder
    private func todayButton(direction: TodayButtonDirection, action: @escaping () -> Void) -> some View {
        let baseButton = Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: direction.systemName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.extraWhite)

                Text("오늘")
                    .twFont(.headline3, color: .extraWhite)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
            .accessibilityLabel("오늘 급식으로 이동")
            .accessibilityHint("스크롤해서 오늘 날짜 섹션을 보여줍니다")

        if #available(iOS 26.0, *) {
            baseButton
                .glassEffect(.regular.tint(Color.extraBlack).interactive(), in: .capsule)
        } else {
            baseButton
                .background {
                    Capsule()
                        .fill(Color.extraBlack)
                }
        }
    }

    private func updateTodayButtonVisibility(containerFrame: CGRect, dayFrames: [Date: CGRect]) {
        guard containerFrame != .zero else {
            withAnimation(.easeInOut(duration: 0.2)) {
                shouldShowTodayButton = false
            }
            return
        }

        let hasToday = viewStore.weeklyMeals.contains {
            calendar.isDate($0.date, inSameDayAs: viewStore.today)
        }
        guard hasToday else {
            withAnimation(.easeInOut(duration: 0.2)) {
                shouldShowTodayButton = false
            }
            return
        }

        let todayKey = calendar.startOfDay(for: viewStore.today)
        if let todayFrame = dayFrames[todayKey], !todayFrame.isNull {
            let isTodayVisible = todayFrame.intersects(containerFrame)

            if isTodayVisible {
                withAnimation(.easeInOut(duration: 0.2)) {
                    shouldShowTodayButton = false
                }
            } else {
                let direction: TodayButtonDirection = todayFrame.maxY < containerFrame.minY ? .up : .down
                withAnimation(.easeInOut(duration: 0.2)) {
                    todayButtonDirection = direction
                    shouldShowTodayButton = true
                }
            }
            return
        }

        let visibleDates = dayFrames.keys.sorted()
        guard let firstVisible = visibleDates.first,
              let lastVisible = visibleDates.last else {
            withAnimation(.easeInOut(duration: 0.2)) {
                shouldShowTodayButton = false
            }
            return
        }

        if calendar.compare(lastVisible, to: todayKey, toGranularity: .day) == .orderedAscending {
            withAnimation(.easeInOut(duration: 0.2)) {
                todayButtonDirection = .down
                shouldShowTodayButton = true
            }
        } else if calendar.compare(firstVisible, to: todayKey, toGranularity: .day) == .orderedDescending {
            withAnimation(.easeInOut(duration: 0.2)) {
                todayButtonDirection = .up
                shouldShowTodayButton = true
            }
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                shouldShowTodayButton = false
            }
        }
    }

    private func scrollToToday(proxy: ScrollViewProxy) {
        guard let todayMeal = viewStore.weeklyMeals.first(where: {
            calendar.isDate($0.date, inSameDayAs: viewStore.today)
        }) else { return }

        withAnimation(.easeInOut(duration: 0.4)) {
            proxy.scrollTo(todayMeal.date, anchor: .top)
        }
    }
}

private struct DayFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Date: CGRect] { [:] }

    static func reduce(value: inout [Date: CGRect], nextValue: () -> [Date: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

private enum TodayButtonDirection {
    case up
    case down

    var systemName: String {
        switch self {
        case .up:
            return "arrow.up"
        case .down:
            return "arrow.down"
        }
    }
}
