import SwiftUI
import TWColor

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
                    .stroke(isChecked ? Color.extraPrimary : .lightGray, lineWidth: 1.72)
                    .frame(width: 20, height: 20)

                Circle()
                    .fill(isChecked ? Color.extraPrimary : .clear)
                    .frame(width: 12, height: 12)
            }
        }

    }
}
