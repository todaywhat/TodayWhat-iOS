import ComposableArchitecture
import SwiftUI

public struct OnboardingView: View {
    private let store: StoreOf<OnboardingCore>
    
    public init(store: StoreOf<OnboardingCore>) {
        self.store = store
    }

    public var body: some View {
        Text("A")
    }
}
