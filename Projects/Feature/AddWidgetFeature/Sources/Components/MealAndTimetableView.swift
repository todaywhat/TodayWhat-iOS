import DesignSystem
import SwiftUI

struct MealAndTimetableView: View {
    let family: WidgetReperesentation.WidgetFamilyType

    var body: some View {
        switch family {
        case .systemMedium:
            MealAndTimeTableMediumView()
                .frame(width: WidgetSizeConstants.medium.width, height: WidgetSizeConstants.medium.height)

        default:
            EmptyView()
        }
    }
}

private struct MealAndTimeTableMediumView: View {
    private static let gridRows: [GridItem] = Array(repeating: .init(.flexible(minimum: 0, maximum: .infinity)), count: 5)
    private static let timetableItems: [String] = ["현대문학...", "음악 감상...", "운동과 건강", "영미 문학...", "생활과 과학", "미적분", "논술"]
    private static let indexedTimetableItems: [(Int, String)] = Array(zip(timetableItems.indices, timetableItems))
    private static let mealItems: [String] = ["퀴노아밥", "트러플 크림...", "한우 불고기", "랍스터 샐러드", "구운 채소", "가지 라따뚜이", "깍두기", "자동 에이드"]

    var body: some View {
        HStack(spacing: 8) {
            // 시간표 영역
            VStack(alignment: .leading, spacing: 8) {
                Text("[시간표]")
                    .twFont(.caption1)
                    .foregroundColor(.textSecondary)

                LazyHGrid(rows: Self.gridRows) {
                    ForEach(
                        Self.indexedTimetableItems,
                        id: \.0
                    ) { index, item in
                        HStack(spacing: 2) {
                            Text("\(index + 1)")
                                .twFont(.caption1)
                                .foregroundColor(.textSecondary)

                            Text(item)
                        }
                        .twFont(.caption1)
                        .foregroundColor(.extraBlack)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
            )

            // 급식 영역
            VStack(alignment: .leading, spacing: 8) {
                Text("[아침]")
                    .twFont(.caption1)
                    .foregroundColor(.textSecondary)

                LazyHGrid(rows: Self.gridRows) {
                    ForEach(Self.mealItems, id: \.self) { meal in
                        let mealColor: Color = meal == "구운 채소" ? .point : .extraBlack
                        Text(meal)
                            .twFont(.caption1)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(mealColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
            )
        }
        .padding(6)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.backgroundMain)
        }
    }
}
