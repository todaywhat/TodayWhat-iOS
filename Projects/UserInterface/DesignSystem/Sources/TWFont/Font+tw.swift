import SwiftUI

public extension View {
    func twFont(
        _ style: Font.TWFontSystem,
        color: Color
    ) -> some View {
        self
            .font(.tw(style))
            .foregroundColor(color)
    }

    func twFont(
        _ style: Font.TWFontSystem
    ) -> some View {
        self
            .font(.tw(style))
    }
}

public extension Font {
    enum TWFontSystem: TWFontable {
        case headline1
        case headline2
        case headline3
        case headline4
        case body1
        case body2
        case body3
        case caption1
    }

    static func tw(_ style: TWFontSystem) -> Font {
        return style.font
    }
}

public extension Font.TWFontSystem {
    var font: Font {
        switch self {
        case .headline1:
            return Font.custom(DesignSystemFontFamily.Suit.bold.name, size: 28)

        case .headline2:
            return Font.custom(DesignSystemFontFamily.Suit.bold.name, size: 24)

        case .headline3:
            return Font.custom(DesignSystemFontFamily.Suit.bold.name, size: 18)

        case .headline4:
            return Font.custom(DesignSystemFontFamily.Suit.bold.name, size: 16)

        case .body1:
            return Font.custom(DesignSystemFontFamily.Suit.medium.name, size: 16)

        case .body2:
            return Font.custom(DesignSystemFontFamily.Suit.medium.name, size: 14)

        case .body3:
            return Font.custom(DesignSystemFontFamily.Suit.bold.name, size: 14)

        case .caption1:
            return Font.custom(DesignSystemFontFamily.Suit.medium.name, size: 12)
        }
    }
}
