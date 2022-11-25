import ComposableArchitecture
import SwiftUI
import TWColor
import TWImage
import MealFeature
import TimeTableFeature
import SchoolSettingFeature

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
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                TopTabbarView(
                    currentTab: viewStore.binding(
                        get: \.currentTab,
                        send: MainCore.Action.tabChanged
                    ),
                    items: ["급식", "시간표"]
                )
                .padding(.top, 32)

                TabView(
                    selection: viewStore.binding(
                        get: \.currentTab,
                        send: MainCore.Action.tabChanged
                    ).animation(.default)
                ) {
                    IfLetStore(
                        store.scope(state: \.mealCore, action: MainCore.Action.mealCore)
                    ) { store in
                        MealView(store: store)
                    }
                    .tag(0)

                    IfLetStore(
                        store.scope(state: \.timeTableCore, action: MainCore.Action.timeTableCore)
                    ) { store in
                        TimeTableView(store: store)
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ONMI")
                        .font(.custom("Fraunces9pt-Black", size: 32))
                        .foregroundColor(.extraGray)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewStore.send(.settingButtonDidTap)
                    } label: {
                        Image.gear
                            .renderingMode(.original)
                    }

                }
            }
            .onAppear {
                viewStore.send(.onAppear, animation: .default)
            }
            .confirmationDialog(
                store.scope(state: \.confirmationDialog),
                dismiss: .confirmationDialogDismissed
            )
        }
    }

    @ViewBuilder
    private func schoolInfoCardView() -> some View {
        ZStack(alignment: .bottomTrailing) {
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
            .zIndex(1)

            HStack {
                Spacer()
                
                if viewStore.currentTab == 0 {
                    Image.meal
                        .transition(
                            .move(edge: .top).combined(with: .opacity)
                        )
                } else {
                    Image.book
                        .transition(
                            .move(edge: .bottom).combined(with: .opacity)
                        )
                }
            }
            .padding(.trailing, 10)
            .zIndex(0)
        }
        .frame(maxWidth: .infinity)
        .background {
            Color.veryLightGray
        }
        .background {
            navigationLinks
        }
        .cornerRadius(8)
    }

    @ViewBuilder
    var navigationLinks: some View {
        NavigationLink(
            isActive: viewStore.binding(
                get: \.isNavigateSchoolSetting,
                send: MainCore.Action.schoolSettingDismissed
            )
        ) {
            IfLetStore(
                store.scope(
                    state: \.schoolSettingCore, action: MainCore.Action.schoolSettingCore)
            ) { store in
                SchoolSettingView(store: store, isNavigationPushed: true)
            }
        } label: {
            EmptyView()
        }
    }
}
