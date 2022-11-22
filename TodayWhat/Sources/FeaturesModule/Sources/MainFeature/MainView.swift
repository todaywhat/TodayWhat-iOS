import ComposableArchitecture
import SwiftUI
import TWColor
import TWImage

public struct MainView: View {
    let store: StoreOf<MainCore>
    @ObservedObject var viewStore: ViewStoreOf<MainCore>
    
    public init(store: StoreOf<MainCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        NavigationView {
            VStack {
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ONMI")
                        .font(.custom("Fraunces72pt-Black", size: 32))
                        .foregroundColor(.extraGray)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {

                    } label: {
                        Image.gear
                            .renderingMode(.original)
                    }

                }
            }
        }
    }
}
