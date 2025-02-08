import ComposableArchitecture
import DesignSystem
import MealFeature
import NoticeFeature
import SettingsFeature
import SwiftUI
import TimeTableFeature

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
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(viewStore.school) \(viewStore.grade)학년 \(viewStore.class)반")
                    .accessibilityHint("\(viewStore.displayDate.toString()) 입니다. 현재 학교 정보를 표시하고 있습니다.")

                TopTabbarView(
                    currentTab: viewStore.binding(
                        get: \.currentTab,
                        send: MainCore.Action.tabTapped
                    ),
                    items: ["급식", "시간표"]
                )
                .padding(.top, 32)
                .accessibilityLabel("메뉴 탭")
                .accessibilityHint("급식과 시간표 중 원하는 메뉴를 선택할 수 있습니다.")

                ZStack(alignment: .bottomTrailing) {
                    TabView(
                        selection: viewStore.binding(
                            get: \.currentTab,
                            send: MainCore.Action.tabSwiped
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
                                .foregroundColor(.extraBlack)
                                .overlay {
                                    Image(systemName: "arrow.down.to.line")
                                        .foregroundColor(.extraWhite)
                                        .accessibilityHidden(true)
                                }
                        }
                        .padding([.bottom, .trailing], 16)
                        .accessibilityLabel("새 버전 업데이트")
                        .accessibilityHint("앱스토어로 이동하여 새 버전을 설치할 수 있습니다")
                    }
                }
            }
            .background(Color.backgroundMain)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(viewStore.displayTitle)
                        .twFont(.headline3)
                        .foregroundColor(.extraBlack)
                        .accessibilityHidden(true)
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewStore.send(.noticeButtonDidTap)
                    } label: {
                        Image.bellBadge
                            .renderingMode(.original)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("알림")
                    .accessibilityHint("알림 목록을 확인할 수 있습니다")

                    Button {
                        viewStore.send(.settingButtonDidTap)
                    } label: {
                        Image.gear
                            .renderingMode(.original)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("설정")
                    .accessibilityHint("앱 설정을 변경할 수 있습니다")
                }
            }
            .onAppear {
                viewStore.send(.onAppear, animation: .default)
            }
            .onLoad {
                viewStore.send(.onLoad)
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
                        .twFont(.headline4, color: .extraBlack)

                    let gradeClassString = "\(viewStore.grade)학년 \(viewStore.class)반"
                    let dateString = "\(viewStore.displayDate.toString())"
                    Text("\(gradeClassString) • \(dateString)")
                        .twFont(.body2, color: .textSecondary)
                        .accessibilitySortPriority(3)
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
                        .accessibilityHidden(true)
                } else {
                    Image.book
                        .transition(
                            .move(edge: .bottom).combined(with: .opacity)
                        )
                        .accessibilityHidden(true)
                }
            }
            .padding(.trailing, 10)
            .zIndex(0)
        }
        .frame(maxWidth: .infinity)
        .background {
            Color.cardBackground
        }
        .background {
            navigationLinks
        }
        .cornerRadius(16)
    }

    @ViewBuilder
    var navigationLinks: some View {
        NavigationLinkStore(
            store.scope(state: \.$settingsCore, action: \.settingsCore),
            onTap: {},
            destination: { store in
                SettingsView(store: store)
            },
            label: { EmptyView() }
        )
        NavigationLinkStore(
            store.scope(state: \.$noticeCore, action: \.noticeCore),
            onTap: {},
            destination: { store in
                NoticeView(store: store)
            },
            label: { EmptyView() }
        )
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
