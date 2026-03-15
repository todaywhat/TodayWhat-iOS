import SwiftUI

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
            let contentView = configuration.label
                .twFont(.headline4, color: foreground)

            if #available(iOS 26.0, watchOS 26.0, *) {
                contentView
                    .glassEffect(.clear.tint(background).interactive(), in: .rect(cornerRadius: 8))
            } else {
                contentView
                    .background(background, in: .rect(cornerRadius: 8))
            }
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
            let contentView = configuration.label
                .twFont(.headline4, color: foreground)

            if #available(iOS 26.0, watchOS 26.0, *) {
                contentView
                    .glassEffect(.clear.tint(background).interactive(), in: .rect)
            } else {
                contentView
                    .background(background)
            }
        }
    }
}
