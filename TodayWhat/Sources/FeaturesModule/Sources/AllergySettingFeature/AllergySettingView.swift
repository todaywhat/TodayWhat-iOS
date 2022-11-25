import ComposableArchitecture
import SwiftUI
import EnumUtil
import TWColor
import SwiftUIUtil

public struct AllergySettingView: View {
    private let store: StoreOf<AllergySettingCore>
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 9), count: 2)
    @Environment(\.dismiss) var dismiss
    
    public init(store: StoreOf<AllergySettingCore>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(AllergyType.allCases, id: \.hashValue) { allergy in
                    ZStack {
                        Color.lightGray
                            .cornerRadius(8)

                        Text(allergy.rawValue)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.extraGray)
                    }
                    .frame(height: 88)
                }
            }
            .padding(.horizontal, 16)
        }
        .twBackButton(dismiss: dismiss)
    }
}
