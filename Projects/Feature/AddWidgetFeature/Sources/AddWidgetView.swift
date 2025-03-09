import ComposableArchitecture
import ComposableArchitectureWrapper
import DesignSystem
import Lottie
import SwiftUI
import SwiftUIUtil
import TWLog

// swiftlint: disable
public struct AddWidgetView: View {
    let store: StoreOf<AddWidgetCore>
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewStore: ViewStoreOf<AddWidgetCore>

    public init(store: StoreOf<AddWidgetCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        contentView
            .twBottomSheet(
                isShowing: viewStore.binding(
                    get: { $0.selectedWidget != nil },
                    send: { .showWidgetGuide($0) }
                ),
                backgroundColor: .cardBackground,
                content: {
                    WidgetGuideView(widget: viewStore.selectedWidget) {
                        viewStore.send(.addWidgetComplete)
                    }
                }
            )
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewStore.availableWidgets, id: \.self) { widget in
                    widgetSection(
                        widget: widget
                    )
                }
            }
        }
        .background(Color.backgroundMain)
        .navigationTitle("위젯 추가")
        .navigationBarTitleDisplayMode(.inline)
        .twBackButton(dismiss: dismiss)
        .onAppear {
            viewStore.send(.onAppear)
        }
    }

    @ViewBuilder
    private func widgetSection(
        widget: WidgetReperesentation
    ) -> some View {
        Button {
            TWLog.event(ClickAddToWidgetTypeEventLog(widget: widget))
            viewStore.send(.selectWidget(widget))
        } label: {
            VStack(spacing: 0) {
                widgetPreview(for: widget)
                    .padding(.top, 24)

                VStack(spacing: 4) {
                    Text(widget.kind.title)
                        .twFont(.headline4)
                        .foregroundColor(.textPrimary)

                    Text(widget.family.title)
                        .twFont(.caption1)
                        .foregroundColor(.textSecondary)
                }
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func widgetPreview(for widget: WidgetReperesentation) -> some View {
        switch widget.kind {
        case .mealAndTimetable:
            MealAndTimetableView(family: widget.family)
        case .meal:
            MealView(family: widget.family)
        case .timetable:
            TimetableView(family: widget.family)
        }
    }
}

private struct WidgetGuideView: View {
    let widget: WidgetReperesentation?
    let onConfirm: () -> Void

    @State private var elapsedTime: Double = 0
    @State private var timerActive = true
    private let cycleTime: Double = 10.0

    var currentGuideText: String {
        let cyclicTime = elapsedTime.truncatingRemainder(dividingBy: cycleTime)

        if cyclicTime < 4.0 {
            return "1. 홈 화면에서 아무 곳이나 길게 눌러주세요."
        } else if cyclicTime < 6.5 {
            return "2. 왼쪽 위의 '+' 혹은 '편집'을 눌러주세요."
        } else {
            return """
            3. 리스트에서 오늘뭐임을 찾아 홈화면에 추가해주세요.
            ⚠️ 리스트에 오늘뭐임이 없다면 휴대폰을 재시동해주세요!
            """
        }
    }

    var body: some View {
        if widget != nil,
           let animation = LottieAnimation.named("add_home_screen_widget", bundle: DesignSystemResources.bundle) {
            VStack {
                LottieView {
                    .lottieAnimation(animation)
                }
                .looping()
                .frame(width: 300, height: 300)

                Text(currentGuideText)
                    .twFont(.headline4)
                    .foregroundColor(.textPrimary)
                    .lineLimit(nil)
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
                    .frame(height: 100, alignment: .top)
                    .padding(.horizontal, 16)
                    .animation(.easeInOut, value: currentGuideText)
                    .onReceive(
                        Timer.publish(
                            every: 0.5,
                            on: .main,
                            in: .common
                        ).autoconnect()
                    ) { _ in
                        if timerActive {
                            elapsedTime += 0.5
                        }
                    }

                Button {
                    onConfirm()
                } label: {
                    Text("확인")
                        .twFont(.headline4)
                        .foregroundColor(.extraWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.extraBlack)
                        .cornerRadius(12)
                }
                .padding([.bottom, .horizontal], 24)
            }
            .onDisappear {
                timerActive = false
            }
            .onAppear {
                timerActive = true
                elapsedTime = 0
            }
        }
    }
}
