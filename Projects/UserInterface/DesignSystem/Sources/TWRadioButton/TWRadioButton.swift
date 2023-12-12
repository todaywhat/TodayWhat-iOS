import SwiftUI

public struct TWRadioButton: View {
    private var isChecked: Bool
    private var onTap: () -> Void

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
                    .stroke(isChecked ? Color.textPrimary : .unselectedPrimary, lineWidth: 1.72)
                    .frame(width: 20, height: 20)

                Circle()
                    .fill(isChecked ? Color.textPrimary : .clear)
                    .frame(width: 12, height: 12)
            }
        }

    }
}
