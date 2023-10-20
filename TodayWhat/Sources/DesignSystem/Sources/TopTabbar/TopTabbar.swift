import SwiftUI
import TWColor

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
        VStack(spacing: 0) {
            HStack {
                ForEach(items.indices, id: \.self) { index in
                    Button {
                        withAnimation {
                            currentTab = index
                        }
                    } label: {
                        VStack {
                            Text(items[index])
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(currentTab == index ? .n00 : .n20)

                            if currentTab == index {
                                RoundedRectangle(cornerRadius: 17)
                                    .fill(Color.n00)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "TAB", in: tabAnimation, properties: .position)
                            } else {
                                Color.clear
                                    .frame(height: 2)
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

            LinearGradient(colors: [.extraWhite, .n30.opacity(0.08)], startPoint: .bottom, endPoint: .top)
                .frame(height: 8)
                .opacity(0.8)
        }
    }
}
