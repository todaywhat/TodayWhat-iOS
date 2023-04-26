import SwiftUI
import TWColor

public extension View {
    func twToast(
        isShowing: Binding<Bool>,
        text: String
    ) -> some View {
        self
            .modifier(TWToast(isShowing: isShowing, text: text))
    }
}

public struct TWToast: ViewModifier {
    @Binding var isShowing: Bool
    var text: String

    public init(
        isShowing: Binding<Bool>,
        text: String
    ) {
        _isShowing = isShowing
        self.text = text
    }

    public func body(content: Content) -> some View {
        ZStack {
            content

            toastView()
        }
        .onChange(of: isShowing) { _ in
            if isShowing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
        }
    }

    @ViewBuilder
    func toastView() -> some View {
        VStack {
            if isShowing {
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(.background)
                    .padding(.vertical, 15.5)
                    .padding(.horizontal, 16)
                    .background {
                        Capsule()
                            .fill(Color.extraPrimary)
                    }
                    .opacity(isShowing ? 1 : 0)
                    .transition(.move(edge: .top).combined(with: AnyTransition.opacity.animation(.easeInOut)))
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                        }
                    }
            }

            Spacer()
        }
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.4), value: isShowing)
    }

    private func safeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        return safeArea
    }
}
