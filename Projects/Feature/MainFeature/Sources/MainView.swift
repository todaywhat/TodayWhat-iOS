import ComposableArchitecture
import DesignSystem
import FirebaseRemoteConfig
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
    @Environment(\.calendar) var calendar
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @RemoteConfigProperty(key: "enable_weekly", fallback: false) private var enableWeeklyView

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
                            if enableWeeklyView {
                                IfLetStore(
                                    store.scope(
                                        state: \.weeklyMealCore,
                                        action: MainCore.Action.weeklyMealCore
                                    )
                                ) { store in
                                    WeeklyMealView(store: store)
                                }
                            } else {
                                IfLetStore(
                                    store.scope(state: \.mealCore, action: MainCore.Action.mealCore)
                                ) { store in
                                    MealView(store: store)
                                }
                            }
                        }
                        .tag(0)

                        VStack {
                            if enableWeeklyView {
                                IfLetStore(
                                    store.scope(
                                        state: \.weeklyTimeTableCore,
                                        action: MainCore.Action.weeklyTimeTableCore
                                    )
                                ) { store in
                                    WeeklyTimeTableView(store: store)
                                }
                            } else {
                                IfLetStore(
                                    store.scope(state: \.timeTableCore, action: MainCore.Action.timeTableCore)
                                ) { store in
                                    TimeTableView(store: store)
                                }
                            }
                        }
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .background {
                        if enableWeeklyView {
                            Color.backgroundSecondary
                                .ignoresSafeArea()
                        }
                    }

                    if viewStore.isShowingReviewToast {
                        ReviewToast {
                            viewStore.send(.requestReview)
                            TWLog.event(ClickReviewEventLog())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                        .animation(.default, value: viewStore.isShowingReviewToast)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
                                viewStore.send(.hideReviewToast, animation: .default)
                            }
                        }
                    }
                }
            }
            .background(Color.backgroundMain)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                }

                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        let isWeeklyModeEnabled = enableWeeklyView
                        let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false
                        let isSkipAfterDinner = userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true
                        let datePolicy = DatePolicy(isSkipWeekend: isSkipWeekend, isSkipAfterDinner: isSkipAfterDinner)

                        let today = Date()
                        if isWeeklyModeEnabled {
                            let currentWeekStart = datePolicy.startOfWeek(for: today)
                            let previousWeek = datePolicy.previousWeekStart(from: currentWeekStart)
                            let nextWeek = datePolicy.nextWeekStart(from: currentWeekStart)
                            ForEach([previousWeek, currentWeekStart, nextWeek], id: \.timeIntervalSince1970) { weekStart in
                                let normalizedWeekStart = datePolicy.startOfWeek(for: weekStart)
                                Button {
                                    let tense: SelectDateTenseEventLog.Tense
                                    if calendar.isDate(normalizedWeekStart, inSameDayAs: currentWeekStart) {
                                        tense = .present
                                    } else if normalizedWeekStart > currentWeekStart {
                                        tense = .future
                                    } else {
                                        tense = .past
                                    }

                                    TWLog.event(SelectDateTenseEventLog(tense: tense))
                                    _ = viewStore.send(.dateSelected(normalizedWeekStart))
                                } label: {
                                    let labelText = datePolicy.weekDisplayText(for: normalizedWeekStart, baseDate: today)
                                    let isSelected = calendar.isDate(
                                        datePolicy.startOfWeek(for: viewStore.displayDate),
                                        inSameDayAs: normalizedWeekStart
                                    )
                                    if isSelected {
                                        Label {
                                            Text(labelText)
                                                .twFont(.body1)
                                                .foregroundStyle(Color.extraWhite)
                                                .animation(.easeInOut(duration: 0.2), value: viewStore.displayDate)
                                        } icon: {
                                            Image(systemName: "checkmark")
                                        }
                                    } else {
                                        Text(labelText)
                                            .twFont(.body1)
                                            .foregroundStyle(Color.extraBlack)
                                            .animation(.easeInOut(duration: 0.2), value: viewStore.displayDate)
                                    }
                                }
                                .accessibilityLabel("\(datePolicy.weekDisplayText(for: normalizedWeekStart, baseDate: today)) 선택")
                                .accessibilityHint("주 변경")
                            }
                        } else {
                            let yesterday = datePolicy.previousDay(from: today)
                            let tomorrow = datePolicy.nextDay(from: today)

                            ForEach([yesterday, today, tomorrow], id: \.timeIntervalSince1970) { date in
                                Button {
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
                                } label: {
                                    if calendar.isDate(viewStore.displayDate, inSameDayAs: date) {
                                        Label {
                                            Text(datePolicy.displayText(for: date, baseDate: today))
                                                .twFont(.body1)
                                                .foregroundStyle(
                                                    calendar.isDate(viewStore.displayDate, inSameDayAs: date)
                                                        ? Color.extraWhite
                                                        : Color.extraBlack
                                                )
                                                .animation(.easeInOut(duration: 0.2), value: viewStore.displayDate)
                                        } icon: {
                                            Image(systemName: "checkmark")
                                        }

                                    } else {
                                        Text(datePolicy.displayText(for: date, baseDate: today))
                                            .twFont(.body1)
                                            .foregroundStyle(
                                                calendar.isDate(viewStore.displayDate, inSameDayAs: date)
                                                    ? Color.extraWhite
                                                    : Color.extraBlack
                                            )
                                            .animation(.easeInOut(duration: 0.2), value: viewStore.displayDate)
                                    }
                                }
                                .accessibilityLabel("\(datePolicy.displayText(for: date, baseDate: today)) 선택")
                                .accessibilityHint("날짜 변경")
                            }
                        }
                    } label: {
                        HStack(spacing: 0) {
                            Text(viewStore.displayTitle)
                                .twFont(.headline3)
                                .foregroundStyle(Color.extraBlack)

                            Image.triangleDown
                                .renderingMode(.template)
                                .foregroundStyle(Color.textPrimary)
                                .rotationEffect(.degrees(0))
                        }
                    }
                    .accessibilityLabel("날짜 선택")
                    .accessibilityHint("클릭하여 날짜를 선택할 수 있습니다")
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
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
                viewStore.send(.weeklyModeUpdated(weeklyEnabled: enableWeeklyView))
            }
            .onChange(of: enableWeeklyView, perform: { _ in
                TWLog.setUserProperty(property: .enableWeeklyView, value: enableWeeklyView.description)
                viewStore.send(.weeklyModeUpdated(weeklyEnabled: enableWeeklyView))
            })
            .onLoad {
                viewStore.send(.onLoad)
                viewStore.send(.weeklyModeUpdated(weeklyEnabled: enableWeeklyView))
            }
            .background {
                navigationLinks
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("급식 & 시간표")
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
