import SwiftUI
import TWColor

public struct TWRadioButton: View {
    private var isChecked: Bool
    private var onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var primaryColor: Color {
        return if colorScheme == .light {
            Color.n30
        } else {
            Color.n20
        }
    }

    public init(
        isChecked: Bool,
        onTap: @escaping () -> Void = {}
    ) {
        self.isChecked = isChecked
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .stroke(isChecked ? primaryColor : .extraBlack, lineWidth: 1.72)
                    .frame(width: 20, height: 20)

                Circle()
                    .fill(isChecked ? Color.extraBlack : .clear)
                    .frame(width: 12, height: 12)
            }
        }

    }
}
