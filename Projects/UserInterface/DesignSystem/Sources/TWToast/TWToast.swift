import SwiftUI

#if os(iOS)
public extension View {
    func twToast(
        isShowing: Binding<Bool>,
        text: String,
        toastTime: DispatchTime = .now() + 3,
        onTap: (() -> Void)? = nil
    ) -> some View {
        self
            .modifier(TWToast(isShowing: isShowing, text: text, toastTime: toastTime, onTap: onTap))
    }
}

public struct TWToast: ViewModifier {
    @Binding var isShowing: Bool
    var text: String
    var toastTime: DispatchTime
    var onTap: (() -> Void)?

    public init(
        isShowing: Binding<Bool>,
        text: String,
        toastTime: DispatchTime = .now() + 3,
        onTap: (() -> Void)? = nil
    ) {
        _isShowing = isShowing
        self.text = text
        self.toastTime = toastTime
        self.onTap = onTap
    }

    public func body(content: Content) -> some View {
        ZStack {
            content

            toastView()
        }
        .onChange(of: isShowing) { _ in
            if isShowing {
                DispatchQueue.main.asyncAfter(deadline: toastTime) {
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
                    .twFont(.headline4, color: .absoluteBlack)
                    .padding(.vertical, 15.5)
                    .padding(.horizontal, 16)
                    .background {
                        Capsule()
                            .fill(Color.absoluteWhite)
                            .shadow(
                                color: .absoluteBlack.opacity(0.16),
                                radius: 48,
                                x: 0,
                                y: 12
                            )
                    }
                    .opacity(isShowing ? 1 : 0)
                    .transition(.move(edge: .top).combined(with: AnyTransition.opacity.animation(.easeInOut)))
                    .onTapGesture {
                        if let onTap {
                            onTap()
                        } else {
                            withAnimation {
                                self.isShowing = false
                            }
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

#endif
