import ComposableArchitecture
import DesignSystem
import FirebaseRemoteConfig
import MealFeature
import NoticeFeature
import SettingsFeature
import SwiftUI
import TimeTableFeature
import UIKit
import TipKit
import TWLog

public struct MainView: View {
    let store: StoreOf<MainCore>
    @ObservedObject var viewStore: ViewStoreOf<MainCore>
    @Environment(\.openURL) var openURL
    @Environment(\.calendar) var calendar
    @Environment(\.accessibilityReduceMotion) var reduceMotion
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
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityLabel({
                        let school: String = viewStore.school
                        let grade: String = viewStore.grade
                        let cls: String = viewStore.class
                        return "\(school) \(grade)학년 \(cls)반"
                    }())
                    .accessibilityHint({
                        let dateStr: String = viewStore.displayDate.toString()
                        return "\(dateStr) 입니다. 현재 학교 정보를 표시하고 있습니다."
                    }())

                TopTabbarView(
                    currentTab: viewStore.binding(
                        get: \.currentTab,
                        send: MainCore.Action.tabTapped
                    ),
                    items: ["급식", "시간표"]
                )
                .padding(.top, 32)

                ZStack(alignment: .bottomTrailing) {
                    TabView(
                        selection: viewStore.binding(
                            get: \.currentTab,
                            send: MainCore.Action.tabSwiped
                        ).animation(.default)
                    ) {
                        VStack {
                            IfLetStore(
                                store.scope(
                                    state: \.weeklyMealCore,
                                    action: MainCore.Action.weeklyMealCore
                                )
                            ) { store in
                                WeeklyMealView(store: store)
                            }
                        }
                        .tag(0)

                        VStack {
                            IfLetStore(
                                store.scope(
                                    state: \.weeklyTimeTableCore,
                                    action: MainCore.Action.weeklyTimeTableCore
                                )
                            ) { store in
                                WeeklyTimeTableView(store: store)
                            }
                        }
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .background {
                        Color.backgroundSecondary
                            .ignoresSafeArea()
                    }
                    .onChange(of: viewStore.currentTab) { newTab in
                        let tabName = newTab == 0 ? "급식" : "시간표"
                        UIAccessibility.post(
                            notification: .announcement,
                            argument: "\(tabName) 탭"
                        )
                    }

                    if viewStore.isShowingReviewToast {
                        ReviewToast(
                            onTap: {
                                viewStore.send(.requestReview)
                                TWLog.event(ClickReviewEventLog())
                            },
                            onDismiss: {
                                viewStore.send(.hideReviewToast, animation: .default)
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                        .animation(
                            reduceMotion ? .none : .default,
                            value: viewStore.isShowingReviewToast
                        )
                        .transition(
                            reduceMotion
                                ? .opacity
                                : .move(edge: .bottom).combined(with: .opacity)
                        )
                        .onAppear {
                            UIAccessibility.post(
                                notification: .announcement,
                                argument: "앱 리뷰 요청이 표시되었습니다"
                            )
                            guard !UIAccessibility.isVoiceOverRunning else { return }
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
                        let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false
                        let isSkipAfterDinner = userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true
                        let datePolicy = DatePolicy(isSkipWeekend: isSkipWeekend, isSkipAfterDinner: isSkipAfterDinner)

                        let today = Date()
                        let currentWeekStart = datePolicy.startOfWeek(for: today)
                        let previousWeek = datePolicy.previousWeekStart(from: currentWeekStart)
                        let nextWeek = datePolicy.nextWeekStart(from: currentWeekStart)
                        let displayDateWeekStart: Date = datePolicy.startOfWeek(for: viewStore.displayDate)
                        let weekStarts: [Date] = [previousWeek, currentWeekStart, nextWeek]
                        ForEach(weekStarts, id: \.timeIntervalSince1970) { weekStart in
                            let normalizedWeekStart: Date = datePolicy.startOfWeek(for: weekStart)
                            let labelText: String = datePolicy.weekDisplayText(for: normalizedWeekStart, baseDate: today)
                            let isSelected: Bool = calendar.isDate(displayDateWeekStart, inSameDayAs: normalizedWeekStart)
                            let accessibilityText: String = "\(labelText) 선택"
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
                            .accessibilityLabel(accessibilityText)
                            .accessibilityHint("주 변경")
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
                    .accessibilityRemoveTraits(.isButton)
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
            }
            .onLoad {
                viewStore.send(.onLoad)
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
    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM월 dd일 EEEE"
        f.locale = Locale(identifier: "ko_kr")
        return f
    }()

    func toString() -> String {
        Self.displayFormatter.string(from: self)
    }
}
