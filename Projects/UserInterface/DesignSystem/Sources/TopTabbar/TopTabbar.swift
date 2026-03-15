import SwiftUI

public struct TopTabbarView: View {
    @Binding var currentTab: Int
    let items: [String]
    @Namespace var tabAnimation

    public init(
        currentTab: Binding<Int>,
        items: [String]
    ) {
        _currentTab = currentTab
        self.items = items
    }

    public var body: some View {
        HStack {
            ForEach(items.indices, id: \.self) { index in
                let isSelected: Bool = currentTab == index
                let itemTitle: String = items[index]
                let tabForeground: Color = isSelected ? .extraBlack : .unselectedPrimary
                let accessLabel: String = "\(itemTitle), \(isSelected ? "선택됨" : "선택안됨")"

                Button {
                    withAnimation {
                        currentTab = index
                    }
                } label: {
                    VStack(spacing: 0) {
                        Text(itemTitle)
                            .twFont(.headline4)
                            .foregroundColor(tabForeground)
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
