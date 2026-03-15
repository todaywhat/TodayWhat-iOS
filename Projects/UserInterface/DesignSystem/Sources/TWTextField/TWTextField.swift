import SwiftUI

public struct TWTextField: View {
    @Binding private var text: String
    private var placeholder: String
    private var onCommit: () -> Void
    @FocusState private var isFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        onCommit: @escaping () -> Void = {}
    ) {
        _text = text
        self.placeholder = placeholder
        self.onCommit = onCommit
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .twFont(.body1, color: .textPrimary)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.cardBackground)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isFocused ? Color.extraBlack : .clear, lineWidth: 1)
                }
                .focused($isFocused)
                .onSubmit(onCommit)
                .accessibilityLabel(placeholder)
                .zIndex(1)

            Group {
                if isFocused || !text.isEmpty {
                    Text(placeholder)
                        .twFont(.body2, color: .textPrimary)
                        .offset(y: -44)
                        .transition(.offset(y: 20))
                        .zIndex(0)
                        .accessibilityHidden(true)
                } else {
                    Text(placeholder)
                        .twFont(.body1, color: .unselectedPrimary)
                        .padding()
                        .onTapGesture {
                            isFocused = true
                        }
                        .zIndex(1)
                        .accessibilityHidden(true)
                }
            }
            .animation(reduceMotion ? .none : .default, value: isFocused)

            HStack {
                Spacer()

                Button {
                    withAnimation(reduceMotion ? .none : nil) {
                        text = ""
                    }
                } label: {
                    if isFocused && !text.isEmpty {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.unselectedPrimary)
                            .frame(width: 28, height: 28)
                    } else {
                        EmptyView()
                    }
                }
                .accessibilityLabel("입력 내용 삭제")
                .accessibilityHidden(!isFocused || text.isEmpty)
            }
            .zIndex(2)
            .padding(.trailing)
            .animation(reduceMotion ? .none : .default, value: text)
            .animation(reduceMotion ? .none : .default, value: isFocused)
        }
    }
}
