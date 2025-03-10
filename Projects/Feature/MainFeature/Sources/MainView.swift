import ComposableArchitecture
import DesignSystem
import MealFeature
import NoticeFeature
import SettingsFeature
import SwiftUI
import TimeTableFeature
import TipKit
import TWLog

public struct MainView: View {
    let store: StoreOf<MainCore>
    @ObservedObject var viewStore: ViewStoreOf<MainCore>
    @Environment(\.openURL) var openURL
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    public init(store: StoreOf<MainCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SchoolInfoCardView(store: store)
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

                    VStack {
                        if viewStore.isShowingReviewToast {
                            ReviewToast {
                                viewStore.send(.requestReview)
                                TWLog.event(ClickReviewEventLog())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.bottom, viewStore.isExistNewVersion ? 72 : 16)
                            .animation(.default, value: viewStore.isShowingReviewToast)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    viewStore.send(.hideReviewToast)
                                }
                            }
                        }

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
            }
            .background(Color.backgroundMain)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewStore.send(.toggleDatePicker(true))
                        TWLog.event(ClickDateTensePickerEventLog())
                    } label: {
                        HStack(spacing: 0) {
                            Text(viewStore.displayTitle)
                                .twFont(.headline3)
                                .foregroundColor(.extraBlack)

                            Image.triangleDown
                                .renderingMode(.template)
                                .foregroundStyle(Color.textPrimary)
                                .rotationEffect(.degrees(viewStore.isDatePickerPresented ? 180.0 : 0))
                                .animation(.easeInOut, value: viewStore.isDatePickerPresented)
                        }
                    }
                    .accessibilityLabel("날짜 선택")
                    .accessibilityHint("클릭하여 날짜를 선택할 수 있습니다")
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
            .overlay {
                if viewStore.isDatePickerPresented {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewStore.send(.toggleDatePicker(false))
                        }
                }
            }
            .overlay(alignment: .top) {
                if viewStore.isDatePickerPresented {
                    DateTensePickerView(displayDate: viewStore.displayDate) { date in
                        let calendar = Calendar.current
                        let today = Date()
                        let tense: SelectDateTenseEventLog.Tense

                        if calendar.isDate(date, inSameDayAs: today) {
                            tense = .present
                        } else if date > today {
                            tense = .future
                        } else {
                            tense = .past
                        }

                        TWLog.event(SelectDateTenseEventLog(tense: tense))

                        _ = viewStore.send(.dateSelected(date))
                        _ = viewStore.send(.toggleDatePicker(false))
                    }
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(), value: viewStore.isDatePickerPresented)
            .onAppear {
                viewStore.send(.onAppear, animation: .default)
            }
            .onLoad {
                viewStore.send(.onLoad)
            }
            .background {
                navigationLinks
            }
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private var navigationLinks: some View {
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
