import ComposableArchitecture
import SwiftUI

public struct WhatsNewView: View {
    private let store: StoreOf<WhatsNewCore>
    
    public init(store: StoreOf<WhatsNewCore>) {
        self.store = store
    }

    public var body: some View {
        Text("A")
    }
}
