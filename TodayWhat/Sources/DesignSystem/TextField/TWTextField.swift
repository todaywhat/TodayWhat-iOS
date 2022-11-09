import SwiftUI

struct TWTextField: View {
    @Binding var text: String
    var placeholder: String
    var onCommit: () -> Void
    @FocusState var isFocused: Bool

    public init(
        text: Binding<String>,
        placeholder: String = "",
        onCommit: @escaping () -> Void = {}
    ) {
        _text = text
        self.placeholder = placeholder
        self.onCommit = onCommit
    }

    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .font(.system(size: 14))
                .foregroundColor(.extraPrimary)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.veryLightGray)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFocused ? Color.extraPrimary : .lightGray, lineWidth: 1)
                }
                .focused($isFocused)
                .onSubmit(onCommit)
                .zIndex(1)

            Group {
                if isFocused || !text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 12))
                        .foregroundColor(.extraGray)
                        .offset(y: -35)
                        .transition(.offset(y: 20))
                        .zIndex(0)
                } else {
                    Text(placeholder)
                        .font(.system(size: 14))
                        .foregroundColor(.extraGray)
                        .padding()
                        .onTapGesture {
                            isFocused = true
                        }
                        .zIndex(1)
                }
            }
            .animation(.default, value: isFocused)

            if isFocused && !text.isEmpty {
                HStack {
                    Spacer()

                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.extraGray)
                    }
                }
                .zIndex(2)
                .padding()
            }
        }
        .animation(.default, value: text)
        .animation(.default, value: isFocused)
    }
}

struct TWTextField_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

struct TestView: View {
    @State var text = ""
    var body: some View {
        TWTextField(text: $text, placeholder: "학교이름")
    }
}
