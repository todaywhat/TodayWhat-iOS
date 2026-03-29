import ComposableArchitecture
import DesignSystem
import Entity
import SwiftUI

public struct AhaMomentView: View {
    let store: StoreOf<AhaMomentCore>

    public init(store: StoreOf<AhaMomentCore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        headerSection(viewStore: viewStore)

                        if viewStore.isLoading {
                            loadingSection()
                        } else {
                            // Meal Card
                            mealCard(viewStore: viewStore)

                            // Timetable Card
                            if !viewStore.timeTable.isEmpty {
                                timeTableCard(viewStore: viewStore)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 32)
                    .padding(.bottom, 100)
                }

                // Bottom button
                nextButton(viewStore: viewStore)
            }
            .background { Color.backgroundMain.ignoresSafeArea() }
            .onAppear { viewStore.send(.onAppear) }
        }
    }

    // MARK: - Header
    @ViewBuilder
    private func headerSection(viewStore: ViewStoreOf<AhaMomentCore>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewStore.isNextSchoolDay {
                Text("다음 등교일 급식이에요!")
                    .twFont(.headline2, color: .extraBlack)
            } else {
                Text("오늘의 학교 정보에요!")
                    .twFont(.headline2, color: .extraBlack)
            }

            Text("\(viewStore.schoolName) \(viewStore.grade)학년 \(viewStore.class)반")
                .twFont(.body2, color: .textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Loading
    @ViewBuilder
    private func loadingSection() -> some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .frame(height: 80)
                    .shimmer()
            }
        }
    }

    // MARK: - Meal Card
    @ViewBuilder
    private func mealCard(viewStore: ViewStoreOf<AhaMomentCore>) -> some View {
        let meal = viewStore.meal
        let lunchMeals = meal?.lunch.meals ?? []

        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                let dateString = viewStore.displayDate.toStringCustomFormat(format: "M월 d일")
                let weekdayString = viewStore.displayDate.weekdayString
                Text("\(dateString) \(weekdayString) 중식")
                    .twFont(.headline4, color: .textPrimary)

                Spacer()

                if let cal = meal?.lunch.cal, cal > 0 {
                    Text("\(String(format: "%.0f", cal)) kcal")
                        .twFont(.body2, color: .unselectedPrimary)
                }
            }

            Divider()
                .foregroundStyle(Color.unselectedSecondary)

            if lunchMeals.isEmpty {
                // Try dinner or breakfast
                let dinnerMeals = meal?.dinner.meals ?? []
                let breakfastMeals = meal?.breakfast.meals ?? []

                if !dinnerMeals.isEmpty {
                    mealItemsList(items: dinnerMeals, label: "석식")
                } else if !breakfastMeals.isEmpty {
                    mealItemsList(items: breakfastMeals, label: "조식")
                } else {
                    Text("급식 정보가 없어요")
                        .twFont(.body1, color: .textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                }
            } else {
                mealItemsList(items: lunchMeals, label: nil)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
        }
    }

    @ViewBuilder
    private func mealItemsList(items: [String], label: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label {
                Text(label)
                    .twFont(.body3, color: .textSecondary)
                    .padding(.bottom, 4)
            }
            ForEach(items, id: \.self) { item in
                Text(item)
                    .twFont(.headline4, color: .textPrimary)
            }
        }
    }

    // MARK: - Timetable Card
    @ViewBuilder
    private func timeTableCard(viewStore: ViewStoreOf<AhaMomentCore>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("시간표")
                .twFont(.headline4, color: .textPrimary)

            Divider()
                .foregroundStyle(Color.unselectedSecondary)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewStore.timeTable, id: \.perio) { period in
                    HStack(spacing: 12) {
                        Text("\(period.perio)")
                            .twFont(.caption1, color: .unselectedPrimary)
                            .frame(width: 20, alignment: .center)

                        Divider()
                            .frame(height: 16)

                        Text(period.content)
                            .twFont(.headline4, color: .textPrimary)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
        }
    }

    // MARK: - Next Button
    @ViewBuilder
    private func nextButton(viewStore: ViewStoreOf<AhaMomentCore>) -> some View {
        VStack(spacing: 8) {
            Text("이게 매일 바로 보여요!")
                .twFont(.body2, color: .textSecondary)

            TWButton(title: "다음", style: .wide) {
                viewStore.send(.nextButtonTapped, animation: .default)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background {
            Color.backgroundMain.ignoresSafeArea()
        }
    }
}

// MARK: - Shimmer Effect
private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    colors: [.clear, Color.white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 300
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
