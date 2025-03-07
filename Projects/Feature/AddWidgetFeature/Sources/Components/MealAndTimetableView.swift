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
    var body: some View {
        HStack(spacing: 8) {
            // 시간표 영역
            VStack(alignment: .leading, spacing: 8) {
                Text("[시간표]")
                    .twFont(.caption1)
                    .foregroundColor(.textSecondary)

                LazyHGrid(
                    rows: [
                        .init(.flexible(minimum: 0, maximum: .infinity)),
                        .init(.flexible(minimum: 0, maximum: .infinity)),
                        .init(.flexible(minimum: 0, maximum: .infinity)),
                        .init(.flexible(minimum: 0, maximum: .infinity)),
                        .init(.flexible(minimum: 0, maximum: .infinity))
                    ]
                ) {
                    let items = ["현대문학...", "음악 감상...", "운동과 건강", "영미 문학...", "생활과 과학", "미적분", "논술"]
                    ForEach(
                        Array(zip(items.indices, items)),
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

                LazyHGrid(
                    rows: [
                        .init(.flexible(minimum: 0, maximum: .infinity)),
                        .init(.flexible(minimum: 0, maximum: .infinity)),
                        .init(.flexible(minimum: 0, maximum: .infinity)),
                        .init(.flexible(minimum: 0, maximum: .infinity)),
                        .init(.flexible(minimum: 0, maximum: .infinity))
                    ]
                ) {
                    let items = ["퀴노아밥", "트러플 크림...", "한우 불고기", "랍스터 샐러드", "구운 채소", "가지 라따뚜이", "깍두기", "자동 에이드"]
                    ForEach(items, id: \.self) { meal in
                        Text(meal)
                            .twFont(.caption1)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(meal == "구운 채소" ? .point : .extraBlack)
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
