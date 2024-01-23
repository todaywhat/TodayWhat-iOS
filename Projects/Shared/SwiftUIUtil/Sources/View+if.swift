import SwiftUI

public extension View {
    func `if`(
        _ condition: Bool,
        transform: (Self) -> some View
    ) -> some View {
        Group {
            if condition { transform(self) } else { self }
        }
    }

    func `if`<T: View>(
        _ condition: Bool,
        true trueTransform: (Self) -> T,
        false falseTransform: (Self) -> T
    ) -> some View {
        Group {
            if condition { trueTransform(self) } else { falseTransform(self) }
        }
    }
}
