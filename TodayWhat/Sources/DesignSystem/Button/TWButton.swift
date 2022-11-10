import SwiftUI

struct TWButton: View {
    var title: String
    var action: () -> Void

    public init(
        title: String,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()

                Text(title)
                    .padding(.vertical, 18)

                Spacer()
            }
        }
        .buttonStyle(TWButtonStyle())
    }
}

struct TWButton_Previews: PreviewProvider {
    static var previews: some View {
        TWButton(title: "") {}
    }
}
