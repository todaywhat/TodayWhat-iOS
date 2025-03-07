import DesignSystem
import SwiftUI

struct MealView: View {
    let family: WidgetReperesentation.WidgetFamilyType

    var body: some View {
        switch family {
        case .systemSmall:
            MealSmallView()
                .frame(width: WidgetSizeConstants.small.width, height: WidgetSizeConstants.small.height)
        case .systemMedium:
            MealMediumView()
                .frame(width: WidgetSizeConstants.medium.width, height: WidgetSizeConstants.medium.height)
        case .systemLarge:
            MealLargeView()
                .frame(width: WidgetSizeConstants.large.width, height: WidgetSizeConstants.large.height)
        case .accessory:
            HStack {
                MealCircularView()
                    .frame(width: WidgetSizeConstants.circular.width, height: WidgetSizeConstants.circular.height)

                MealRectangularView()
                    .frame(width: WidgetSizeConstants.rectangular.width, height: WidgetSizeConstants.rectangular.height)
            }
        case .controlCenter:
            VStack(alignment: .leading) {
                HStack {
                    MealControlCenterSmallView()
                        .frame(
                            width: WidgetSizeConstants.controlCenterSmall.width,
                            height: WidgetSizeConstants.controlCenterSmall.height
                        )

                    MealControlCenterMediumView()
                        .frame(
                            width: WidgetSizeConstants.controlCenterMedium.width,
                            height: WidgetSizeConstants.controlCenterMedium.height
                        )
                }

                MealControlCenterLargeView()
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

private struct MealSmallView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.backgroundMain)
            .overlay {
                VStack(alignment: .leading, spacing: 0) {
                    Text("[아침]")
                        .twFont(.caption1)
                        .foregroundColor(.textSecondary)
                        .padding(.bottom, 4)

                    let items = ["퀴노아밥", "테리야키 그릴스테이크", "한우 불고기", "팝스터 쉐이크", "구운 채소", "가지 라따뚜이", "깍두기", "자몽에이드"]
                    ForEach(items, id: \.self) { meal in
                        Text(meal)
                            .twFont(.caption1)
                            .foregroundColor(meal == "구운 채소" ? .point : .extraBlack)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                }
                .padding(10)
            }
    }
}

private struct MealMediumView: View {
    private let rows = Array(repeating: GridItem(.flexible(), spacing: nil), count: 4)

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.backgroundMain)
            .overlay {
                GeometryReader { proxy in
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Text("[아침]")
                                .twFont(.body3, color: .extraBlack)

                            Spacer()

                            HStack(spacing: 0) {
                                if #available(iOS 17.0, *) {
                                    ForEach([MealPartTime.breakfast, .lunch, .dinner], id: \.self) { partTime in
                                        Button {} label: {
                                            let isSelected = partTime == .breakfast
                                            Text(partTime.display)
                                                .twFont(.body3, color: isSelected ? .extraWhite : .textSecondary)
                                                .minimumScaleFactor(0.5)
                                                .padding(.horizontal, 12)
                                                .background {
                                                    if isSelected {
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .fill(Color.extraBlack)
                                                            .frame(height: 24)
                                                    } else {
                                                        Color.clear
                                                    }
                                                }
                                        }
                                        .buttonStyle(.borderless)
                                        .frame(height: 24)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 4)

                        let items = ["퀴노아밥", "테리야키 그릴스테이크", "한우 불고기", "팝스터 쉐이크", "구운 채소", "가지 라따뚜이", "깍두기", "자몽에이드"]
                        LazyHGrid(rows: rows, spacing: 0) {
                            ForEach(items, id: \.self) { meal in
                                HStack(spacing: 0) {
                                    Text(meal)
                                        .frame(maxHeight: .infinity)
                                        .twFont(.caption1)
                                        .foregroundColor(meal == "구운 채소" ? .point : .extraBlack)

                                    Spacer()
                                }
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
                    .padding(8)
                }
            }
    }
}

private struct MealLargeView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.backgroundMain)
            .overlay {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("[아침]")
                            .twFont(.body3, color: .extraBlack)

                        Spacer()

                        HStack(spacing: 0) {
                            if #available(iOS 17.0, *) {
                                ForEach([MealPartTime.breakfast, .lunch, .dinner], id: \.self) { partTime in
                                    Button {} label: {
                                        let isSelected = partTime == .breakfast
                                        Text(partTime.display)
                                            .twFont(.body3, color: isSelected ? .extraWhite : .textSecondary)
                                            .minimumScaleFactor(0.5)
                                            .padding(.horizontal, 12)
                                            .background {
                                                if isSelected {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.extraBlack)
                                                        .frame(height: 24)
                                                } else {
                                                    Color.clear
                                                }
                                            }
                                    }
                                    .buttonStyle(.borderless)
                                    .frame(height: 24)
                                }
                            }
                        }
                    }

                    let items = ["퀴노아밥", "테리야키 그릴스테이크", "한우 불고기", "팝스터 쉐이크", "구운 채소", "가지 라따뚜이", "깍두기", "자몽에이드"]
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(items, id: \.self) { meal in
                            HStack {
                                Text(meal)
                                    .twFont(.body1)
                                    .frame(maxHeight: .infinity)
                                    .foregroundColor(meal == "구운 채소" ? .point : .extraBlack)

                                Spacer()
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        Color.cardBackground
                    }
                    .cornerRadius(8)

                    Text("\(String(format: "%.1f", 1290)) kcal")
                        .twFont(.caption1, color: .textSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(8)
            }
    }
}

private struct MealRectangularView: View {
    let items = ["퀴노아밥", "테리야키 그릴스테이크", "한우 불고기", "팝스터 쉐이크", "구운 채소", "가지 라따뚜이", "깍두기", "자몽에이드"]

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(.ultraThinMaterial)
            .overlay {
                Text("아침 - \(items.joined(separator: ","))")
                    .twFont(.caption1)
                    .lineLimit(nil)
            }
    }
}

private struct MealCircularView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(.ultraThinMaterial)
            .overlay {
                Image.circularMeal
                    .resizable()
                    .frame(width: 66, height: 66)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
            }
    }
}

private struct MealControlCenterSmallView: View {
    var body: some View {
        Circle()
            .fill(.thinMaterial)
            .overlay {
                Image(systemName: "fork.knife")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Color.extraBlack)
            }
    }
}

private struct MealControlCenterMediumView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay {
                HStack(alignment: .center) {
                    Image(systemName: "fork.knife")
                        .resizable()
                        .frame(width: 32, height: 32)

                    Text("아침")
                        .twFont(.body3)
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.extraBlack)
            }
    }
}

private struct MealControlCenterLargeView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay {
                VStack {
                    Image(systemName: "fork.knife")
                        .resizable()
                        .frame(width: 32, height: 32)

                    Spacer()

                    Text("아침")
                        .twFont(.body3)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.extraBlack)
            }
    }
}
