import SwiftUI

public struct LabelledDivider: View {
    private let label: String
    private let subLabel: String
    private let horizontalPadding: CGFloat
    private let color: Color

    public init(
        label: String,
        subLabel: String,
        horizontalPadding: CGFloat = 8,
        color: Color = .textSecondary
    ) {
        self.label = label
        self.subLabel = subLabel
        self.horizontalPadding = horizontalPadding
        self.color = color
    }

    public var body: some View {
        HStack {
            Text(label)
                .twFont(.body2, color: color)
                .padding(horizontalPadding)

            Spacer()

            Text(subLabel)
                .twFont(.body2, color: color)
                .padding(horizontalPadding)
        }
    }
}
