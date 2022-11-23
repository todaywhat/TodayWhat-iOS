import ComposableArchitecture
import SwiftUI
import TWColor
import TWImage

public struct MainView: View {
    let store: StoreOf<MainCore>
    @State var tab = 0
    @ObservedObject var viewStore: ViewStoreOf<MainCore>
    
    public init(store: StoreOf<MainCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        NavigationView {
            VStack {
                schoolInfoCardView()
                    .padding(16)

                TopTabbarView(
                    currentTab: viewStore.binding(
                        get: \.currentTab,
                        send: MainCore.Action.tabChanged
                    ),
                    items: ["급식", "시간표"]
                )

                TabView(
                    selection: viewStore.binding(
                        get: \.currentTab,
                        send: MainCore.Action.tabChanged
                    ).animation(.default)
                ) {
                    Text("급식")
                        .tag(0)

                    Text("시간표")
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color.background)
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
            .onAppear {
                viewStore.send(.onAppear, animation: .default)
            }
        }
    }

    @ViewBuilder
    private func schoolInfoCardView() -> some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewStore.school)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.darkGray)

                    Text("\(viewStore.grade)학년 \(viewStore.class)반")
                        .font(.system(size: 14))
                        .foregroundColor(.extraGray)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 25.5)
        }
        .frame(maxWidth: .infinity)
        .background {
            Color.veryLightGray
        }
        .cornerRadius(8)
    }
}
