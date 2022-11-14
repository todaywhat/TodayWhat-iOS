import SwiftUI

struct TWButton: View {
    private var title: String
    private var style: TWButtonStyle.Style
    private var action: () -> Void

    init(
        title: String,
        style: TWButtonStyle.Style = .cta,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.vertical, 18)

                Spacer()
            }
        }
        .buttonStyle(TWButtonStyle(style: style))
    }
}

struct TWButton_Previews: PreviewProvider {
    static var previews: some View {
        TWButton(title: "") {}
    }
}
