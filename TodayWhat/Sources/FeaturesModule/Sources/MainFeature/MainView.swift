import ComposableArchitecture
import SwiftUI
import TWColor
import TWImage
import MealFeature
import TimeTableFeature
import SettingsFeature
import NoticeFeature
import TopTabbar

public struct MainView: View {
    let store: StoreOf<MainCore>
    @ObservedObject var viewStore: ViewStoreOf<MainCore>
    @Environment(\.openURL) var openURL
    
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

                ZStack(alignment: .bottomTrailing) {
                    TabView(
                        selection: viewStore.binding(
                            get: \.currentTab,
                            send: MainCore.Action.tabChanged
                        ).animation(.default)
                    ) {
                        VStack {
                            IfLetStore(
                                store.scope(state: \.mealCore, action: MainCore.Action.mealCore)
                            ) { store in
                                MealView(store: store)
                            }
                        }
                        .tag(0)

                        VStack {
                            IfLetStore(
                                store.scope(state: \.timeTableCore, action: MainCore.Action.timeTableCore)
                            ) { store in
                                TimeTableView(store: store)
                            }
                        }
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    if viewStore.isExistNewVersion {
                        Button {
                            let url = URL(
                                string: "https://apps.apple.com/app/id1629567018"
                            ) ?? URL(string: "https://google.com")!
                            openURL(url)
                        } label: {
                            Circle()
                                .frame(width: 56, height: 56)
                                .foregroundColor(.extraPrimary)
                                .overlay {
                                    Image(systemName: "arrow.down.to.line")
                                        .foregroundColor(.background)
                                }
                        }
                        .padding([.bottom, .trailing], 16)
                    }
                }
            }
            .background(Color.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ONMI")
                        .font(.custom("Fraunces9pt-Black", size: 32))
                        .foregroundColor(.extraPrimary)
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewStore.send(.noticeButtonDidTap)
                    } label: {
                        Image("BellBadge")
                            .renderingMode(.original)
                    }

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
                    let dateString = "\(viewStore.displayDate.toString())"
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

        NavigationLink(
            isActive: viewStore.binding(
                get: { $0.noticeCore != nil },
                send: MainCore.Action.noticeDismissed
            )
        ) {
            IfLetStore(
                store.scope(
                    state: \.noticeCore,
                    action: MainCore.Action.noticeCore
                )
            ) { store in
                NoticeView(store: store)
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
