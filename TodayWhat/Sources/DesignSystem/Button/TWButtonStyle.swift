import SwiftUI

struct TWButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        DefaultButton(configuration: configuration)
    }
}

private extension TWButtonStyle {
    struct DefaultButton: View {
        let configuration: ButtonStyle.Configuration
        @Environment(\.isEnabled) var isEnabled

        var background: Color {
            if isEnabled {
                return configuration.isPressed ?
                    .black :
                    .extraPrimary
            } else {
                return .extraGray
            }
        }
        var body: some View {
            configuration.label
                .font(.system(size: 14))
                .foregroundColor(.veryLightGray)
                .background(background)
                .cornerRadius(8)
        }
    }
}
