import SwiftUI
import TWColor

public struct LabelledDivider: View {

    private let label: String
    private let horizontalPadding: CGFloat
    private let color: Color

    public init(
        label: String,
        horizontalPadding: CGFloat = 8,
        color: Color = .extraGray
    ) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }

    public var body: some View {
        HStack {
            line
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(color)
                .padding(horizontalPadding)
            line
        }
    }

    var line: some View {
        VStack { Divider().background(color).frame(height: 1) }
    }
}
