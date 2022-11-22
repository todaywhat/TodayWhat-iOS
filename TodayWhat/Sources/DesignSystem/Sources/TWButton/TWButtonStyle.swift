import SwiftUI
import TWColor

public struct TWButtonStyle: ButtonStyle {
    public enum Style {
        case cta
        case wide
    }
    private var style: Style

    init(style: Style) {
        self.style = style
    }

    public func makeBody(configuration: Configuration) -> some View {
        switch style {
        case .cta:
            CTAButton(configuration: configuration)

        case .wide:
            WideButton(configuration: configuration)
        }
    }
}

private extension TWButtonStyle {
    struct CTAButton: View {
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

    struct WideButton: View {
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
        }
    }
}
