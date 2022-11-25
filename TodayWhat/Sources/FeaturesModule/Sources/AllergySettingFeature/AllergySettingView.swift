import ComposableArchitecture
import SwiftUI

public struct AllergySettingView: View {
    private let store: StoreOf<AllergySettingCore>
    
    public init(store: StoreOf<AllergySettingCore>) {
        self.store = store
    }

    public var body: some View {
        Text("A")
    }
}
