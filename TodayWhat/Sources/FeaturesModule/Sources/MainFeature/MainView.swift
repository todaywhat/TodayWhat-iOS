import ComposableArchitecture
import SwiftUI
import TWColor
import TWImage
import MealFeature
import TimeTableFeature
import SettingsFeature

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
            VStack(spacing: 0) {
                schoolInfoCardView()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

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
                        .foregroundColor(.extraPrimary)
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
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private func schoolInfoCardView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewStore.school)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.darkGray)

                    let gradeClassString = "\(viewStore.grade)학년 \(viewStore.class)반"
                    let dateString = "\(Date().toString())"
                    Text("\(gradeClassString) • \(dateString)")
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
                get: \.isNavigateSettings,
                send: MainCore.Action.settingsDismissed
            )
        ) {
            IfLetStore(
                store.scope(
                    state: \.settingsCore,
                    action: MainCore.Action.settingsCore
                )
            ) { store in
                SettingsView(store: store)
            }
        } label: {
            EmptyView()
        }
    }
}

private extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 EEEE"
        formatter.locale = Locale(identifier: "ko_kr")
        return formatter.string(from: self)
    }
}
