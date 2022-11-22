import SwiftUI
import SwiftUIUtil

struct TWBottomSheet<T: View>: ViewModifier {
    @Binding var isShowing: Bool
    @State var dragHeight: CGFloat = 0
    var content: () -> T
    var height: CGFloat
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
        content: @escaping () -> T
    ) {
        _isShowing = isShowing
        self.height = height
        self.content = content
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            ZStack(alignment: .bottom) {
                if isShowing {
                    Color.black
                        .opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isShowing = false
                            }
                        }
                        .gesture(sheetDragging)
                        .transition(.opacity)

                    ZStack {
                        Color.white
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
    func twBottomSheet<Content: View>(
        isShowing: Binding<Bool>,
        content: @escaping () -> Content
    ) -> some View {
        modifier(TWBottomSheet(isShowing: isShowing, content: content))
    }
}
