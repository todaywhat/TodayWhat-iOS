import SwiftUI
import WidgetKit

extension View {
    @ViewBuilder
    func widgetAccentableIfAvailable() -> some View {
        if #available(iOSApplicationExtension 16.0, *) {
            self.widgetAccentable()
        } else {
            self
        }
    }
}
