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
            return if isEnabled {
                Color.extraBlack
            } else {
                Color.n30
            }
        }

        var foreground: Color {
            return if isEnabled {
                Color.extraWhite
            } else {
                Color.n20
            }
        }

        var body: some View {
            configuration.label
                .font(.system(size: 14))
                .foregroundColor(foreground)
                .background(background)
                .cornerRadius(8)
        }
    }

    struct WideButton: View {
        let configuration: ButtonStyle.Configuration
        @Environment(\.isEnabled) var isEnabled
        @Environment(\.colorScheme) var colorScheme

        var background: Color {
            return if isEnabled {
                Color.extraBlack
            } else {
                Color.unselectedSecondary
            }
        }

        var foreground: Color {
            return if isEnabled {
                Color.extraWhite
            } else {
                Color.unselectedPrimary
            }
        }

        var body: some View {
            configuration.label
                .font(.system(size: 14))
                .foregroundColor(foreground)
                .background(background)
        }
    }
}
