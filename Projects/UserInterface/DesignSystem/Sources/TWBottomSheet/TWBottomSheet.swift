import SwiftUI
import SwiftUIUtil

#if os(iOS)
struct TWBottomSheet<T: View>: ViewModifier {
    @Binding var isShowing: Bool
    @State var dragHeight: CGFloat = 0
    var content: () -> T
    var height: CGFloat
    var backgroundColor: Color
    var sheetDragging: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                withAnimation(.spring()) {
                    dragHeight = min(30, -value.translation.height)
                }
            }
            .onEnded { value in
                withAnimation(.spring()) {
                    dragHeight = 0
                }
                let verticalAmount = value.translation.height
                if verticalAmount > 100 {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
    }

    init(
        isShowing: Binding<Bool>,
        height: CGFloat = .infinity,
        backgroundColor: Color = .backgroundMain,
        content: @escaping () -> T
    ) {
        _isShowing = isShowing
        self.height = height
        self.backgroundColor = backgroundColor
        self.content = content
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            ZStack(alignment: .bottom) {
                if isShowing {
                    Color.lightBox
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isShowing = false
                            }
                        }
                        .gesture(sheetDragging)
                        .transition(.opacity)

                    ZStack {
                        backgroundColor
                            .cornerRadius(16, corners: [.topLeft, .topRight])
                            .padding(.top, -dragHeight)
                            .gesture(sheetDragging)

                        VStack {
                            self.content()
                                .frame(maxWidth: .infinity)
                                .transition(.move(edge: .bottom))
                        }
                        .padding(.bottom, 42)
                        .offset(y: -dragHeight)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.move(edge: .bottom))
                    .if(height != .infinity) {
                        $0.frame(height: height)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
        .animation(.default, value: isShowing)
    }
}

public extension View {
    func twBottomSheet(
        isShowing: Binding<Bool>,
        backgroundColor: Color = .backgroundMain,
        content: @escaping () -> some View
    ) -> some View {
        modifier(
            TWBottomSheet(
                isShowing: isShowing,
                backgroundColor: backgroundColor,
                content: content
            )
        )
    }
}
#endif
