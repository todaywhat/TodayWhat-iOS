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
                Button {
                    withAnimation {
                        currentTab = index
                    }
                } label: {
                    VStack {
                        Text(items[index])
                            .twFont(.headline4)
                            .foregroundColor(currentTab == index ? .extraBlack : .unselectedPrimary)

                        if currentTab == index {
                            RoundedRectangle(cornerRadius: 17)
                                .fill(Color.textPrimary)
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "TAB", in: tabAnimation, properties: .position)
                                .offset(y: 0.5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background {
                        Color.extraWhite
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(alignment: .bottom) {
            Rectangle()
                .frame(maxWidth: .infinity)
                .foregroundColor(.unselectedSecondary)
                .frame(height: 1)
        }
    }
}
