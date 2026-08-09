import SwiftUI

public struct TopTabbarView: View {
    @Binding var currentTab: Int
    let items: [String]
    let badgedIndices: Set<Int>
    @Namespace var tabAnimation

    public init(
        currentTab: Binding<Int>,
        items: [String],
        badgedIndices: Set<Int> = []
    ) {
        _currentTab = currentTab
        self.items = items
        self.badgedIndices = badgedIndices
    }

    public var body: some View {
        HStack {
            ForEach(items.indices, id: \.self) { index in
                let isSelected: Bool = currentTab == index
                let itemTitle: String = items[index]
                let tabForeground: Color = isSelected ? .extraBlack : .unselectedPrimary
                let isBadged: Bool = badgedIndices.contains(index)
                let selectionLabel: String = isSelected ? "선택됨" : "선택안됨"
                let badgeLabel: String = isBadged ? ", 커스텀 저장됨" : ""
                let accessLabel: String = "\(itemTitle), \(selectionLabel)\(badgeLabel)"

                Button {
                    withAnimation {
                        currentTab = index
                    }
                } label: {
                    VStack(spacing: 0) {
                        Text(itemTitle)
                            .twFont(.headline4)
                            .foregroundColor(tabForeground)
                            .overlay(alignment: .topTrailing) {
                                if isBadged {
                                    Circle()
                                        .fill(Color.point)
                                        .frame(width: 4, height: 4)
                                        .offset(x: 6)
                                        .accessibilityHidden(true)
                                }
                            }
                            .frame(minHeight: 44)

                        if isSelected {
                            RoundedRectangle(cornerRadius: 17)
                                .fill(Color.textPrimary)
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "TAB", in: tabAnimation, properties: .position)
                                .offset(y: 0.5)
                                .accessibilityHidden(true)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .background {
                        Color.backgroundMain
                    }
                    .padding(.horizontal, 16)
                }
                .accessibilityLabel(accessLabel)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                .accessibilitySortPriority(1)
            }
        }
        .background(alignment: .bottom) {
            Rectangle()
                .frame(maxWidth: .infinity)
                .foregroundColor(.unselectedSecondary)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
    }
}
