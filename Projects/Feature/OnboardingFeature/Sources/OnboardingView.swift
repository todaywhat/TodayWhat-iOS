import ComposableArchitecture
import DesignSystem
import Entity
import Lottie
import SchoolSettingFeature
import SwiftUI

public struct OnboardingView<SiriSection: View>: View {
  private let store: StoreOf<OnboardingCore>
  private let siriSection: SiriSection
  @State private var isWidgetGuidePresented = false
  @State private var hasSeenWidgetGuide = false
  @State private var showPageContent = false

  public init(store: StoreOf<OnboardingCore>, @ViewBuilder siriSection: () -> SiriSection) {
    self.store = store
    self.siriSection = siriSection()
  }

  public var body: some View {
    navigationContainer {
      WithViewStore(store, observe: { $0 }) { viewStore in
        let pageRail = GeometryReader { proxy in
          HStack(spacing: 0) {
            schoolPage(pageWidth: proxy.size.width)
              .frame(width: proxy.size.width)

            onboardingPage(
              title: "오늘 급식, 바로 확인해요",
              message: "입력한 학교 정보를 바탕으로 점심 메뉴를 바로 보여드릴게요.",
              pageWidth: proxy.size.width
            ) {
              mealPreview(viewStore: viewStore)
            }
            .frame(width: proxy.size.width)

            onboardingPage(
              title: "오늘 시간표도 한눈에",
              message: "수업 순서를 빠르게 확인하고 하루를 더 가볍게 시작해보세요.",
              pageWidth: proxy.size.width
            ) {
              timetablePreview(viewStore: viewStore)
            }
            .frame(width: proxy.size.width)

            onboardingPage(
              title: "위젯으로 더 빠르게",
              message: "홈 화면에서 오늘 급식을 앱 열지 않고도 바로 볼 수 있어요.",
              pageWidth: proxy.size.width
            ) {
              widgetPreview(viewStore: viewStore)
            }
            .frame(width: proxy.size.width)

            onboardingPage(
              title: "애플 생태계 어디서나",
              message: "Siri, Apple Watch, Mac, iPad에서도 오늘뭐임을 자연스럽게 이어서 사용할 수 있어요.",
              pageWidth: proxy.size.width
            ) {
              ecosystemPreview
            }
            .frame(width: proxy.size.width)
          }
          .frame(
            width: proxy.size.width * CGFloat(OnboardingCore.Step.allCases.count),
            alignment: .leading
          )
          .offset(x: -proxy.size.width * CGFloat(viewStore.step.rawValue))
          .animation(
            .interactiveSpring(response: 0.34, dampingFraction: 0.86),
            value: viewStore.step
          )
        }

        let content = VStack(spacing: 0) {
          pageRail
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundMain.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
          showPageContent = true
          viewStore.send(.onAppear)
        }
        .onChange(of: viewStore.step) { _ in
          showPageContent = false
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showPageContent = true
          }
        }
        //                .toolbar(.hidden, for: .navigationBar)

        if #available(iOS 26.0, *) {
          content
            .safeAreaBar(edge: .top) {
              topBar(viewStore: viewStore)
            }
            .safeAreaBar(edge: .bottom) {
              bottomCTA(viewStore: viewStore)
            }
        } else {
          content
            .safeAreaInset(edge: .top) {
              topBar(viewStore: viewStore)
            }
            .safeAreaInset(edge: .bottom) {
              bottomCTA(viewStore: viewStore)
            }
        }
      }
    }
  }

  @ViewBuilder
  private func navigationContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View
  {
    if #available(iOS 16.0, *) {
      NavigationStack {
        content()
      }
    } else {
      NavigationView {
        content()
      }
      .navigationViewStyle(.stack)
    }
  }

  private func schoolPage(pageWidth: CGFloat) -> some View {
    SchoolSettingView(
      store: store.scope(state: \.schoolSettingCore, action: \.schoolSettingCore),
      progressText: nil,
      hidesInternalButton: true
    )
    .frame(width: pageWidth)
  }

  private func onboardingPage(
    title: String,
    message: String,
    pageWidth: CGFloat,
    @ViewBuilder content: () -> some View
  ) -> some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 24) {
        VStack(alignment: .leading, spacing: 8) {
          Text(title)
            .twFont(.headline2, color: .extraBlack)
            .accessibilityAddTraits(.isHeader)

          Text(message)
            .twFont(.body2, color: .textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }

        content()
      }
      .padding(.horizontal, 20)
      .padding(.top, 8)
      .padding(.bottom, 40)
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    .frame(width: pageWidth)
    .frame(maxHeight: .infinity, alignment: .top)
    .scrollClipDisabledIfAvailable()
  }

  private func topBar(viewStore: ViewStore<OnboardingCore.State, OnboardingCore.Action>)
    -> some View
  {
    HStack(spacing: 12) {
      if viewStore.step != .school {
        let button = Button {
          viewStore.send(.backButtonDidTap, animation: .default)
        } label: {
          Image(systemName: "chevron.left")
            .frame(width: 36, height: 36)
            .contentShape(Circle())
        }
        .frame(width: 44, height: 44)
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityLabel("이전")

        if #available(iOS 26.0, *) {
          button
            .glassEffect(.regular.interactive(), in: .circle)
        } else {
          button
        }
      }

      progressSection(step: viewStore.step)
        .frame(minHeight: 44)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 8)
  }

  @ViewBuilder
  private func bottomCTA(viewStore: ViewStore<OnboardingCore.State, OnboardingCore.Action>)
    -> some View
  {
    if let buttonTitle = buttonTitle(for: viewStore) {
      let button = TWButton(title: buttonTitle, style: .wide) {
        switch viewStore.step {
        case .school:
          viewStore.send(.schoolSettingCore(.nextButtonDidTap), animation: .default)
        case .widget:
          if hasSeenWidgetGuide {
            viewStore.send(.nextButtonDidTap, animation: .default)
          } else {
            hasSeenWidgetGuide = true
            isWidgetGuidePresented = true
          }
        default:
          viewStore.send(.nextButtonDidTap, animation: .default)
        }
      }
      .disabled(isBottomCTADisabled(viewStore: viewStore))
      .padding(.horizontal, 20)
      .padding(.top, 8)
      .padding(.bottom, 8)

      if #available(iOS 16.0, *) {
        button
          .contentTransition(.numericText())
          .animation(.default, value: buttonTitle)
      } else {
        button
      }
    }
  }

  private func buttonTitle(for viewStore: ViewStore<OnboardingCore.State, OnboardingCore.Action>) -> String? {
    switch viewStore.step {
    case .school:
      return isBottomCTADisabled(viewStore: viewStore) ? nil : viewStore.schoolSettingCore.nextButtonTitle
    case .meal:
      return "시간표 보기"
    case .timetable:
      return "위젯 보기"
    case .widget:
      return "추가하기"
    case .ecosystem:
      return "시작하기"
    }
  }

  private func isBottomCTADisabled(viewStore: ViewStore<OnboardingCore.State, OnboardingCore.Action>) -> Bool {
    switch viewStore.step {
    case .school:
      return viewStore.schoolSettingCore.class.isEmpty
        || viewStore.schoolSettingCore.grade.isEmpty
        || viewStore.schoolSettingCore.isFocusedSchool
        || viewStore.schoolSettingCore.school.isEmpty
    case .meal, .timetable, .widget, .ecosystem:
      return false
    }
  }

  private func progressSection(step: OnboardingCore.Step) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      let text = Text("\(step.index) / \(step.totalCount)")
        .twFont(.caption1, color: .textSecondary)

      if #available(iOS 16.0, *) {
        text
          .contentTransition(.numericText())
          .animation(.default, value: step)
      } else {
        text
      }

      GeometryReader { proxy in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(Color.cardBackgroundSecondary)
            .frame(height: 8)

          Capsule()
            .fill(Color.extraBlack)
            .frame(
              width: proxy.size.width * (Double(step.index) / Double(step.totalCount)),
              height: 8
            )
        }
      }
      .frame(height: 8)
    }
  }

  private func mealPreview(viewStore: ViewStore<OnboardingCore.State, OnboardingCore.Action>)
    -> some View
  {
    VStack(spacing: 20) {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(viewStore.schoolName.isEmpty ? "오늘의 점심" : "\(viewStore.schoolName) 점심")
              .twFont(.headline4, color: .extraBlack)
              .staggered(showPageContent, order: 0)
            Text("앱을 열자마자 가장 먼저 보이는 핵심 정보예요")
              .twFont(.caption1, color: .textSecondary)
              .staggered(showPageContent, order: 1)
          }
          Spacer()
          Text("급식")
            .twFont(.caption1, color: .extraWhite)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.extraBlack)
            .clipShape(Capsule())
            .staggered(showPageContent, order: 2)
        }

        if viewStore.isMealLoading {
          HStack {
            Spacer()
            ProgressView()
            Spacer()
          }
          .padding(.vertical, 24)
        } else {
          let meals = mealLines(from: viewStore.meal)
          VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(meals.enumerated()), id: \.offset) { index, line in
              HStack(alignment: .top, spacing: 10) {
                Circle()
                  .fill(Color.extraBlack)
                  .frame(width: 6, height: 6)
                  .padding(.top, 7)
                Text(line)
                  .twFont(.body2, color: .textPrimary)
                  .fixedSize(horizontal: false, vertical: true)
              }
              .staggered(showPageContent, order: 3 + index)
            }
          }
        }
      }
      .padding(24)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .background(Color.cardBackground, in: .rect(cornerRadius: 28))

      if viewStore.mealUsesFallback {
        infoFootnote(text: "해당 날짜의 실제 급식 정보가 아직 없어서 예시 메뉴를 보여드리고 있어요.")
          .staggered(showPageContent, order: 8)
      }
    }
  }

  private func timetablePreview(viewStore: ViewStore<OnboardingCore.State, OnboardingCore.Action>)
    -> some View
  {
    VStack(spacing: 20) {
      VStack(alignment: .leading, spacing: 18) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("오늘 시간표")
              .twFont(.headline4, color: .extraBlack)
              .staggered(showPageContent, order: 0)
            Text("등교 전에도 빠르게 확인할 수 있어요")
              .twFont(.caption1, color: .textSecondary)
              .staggered(showPageContent, order: 1)
          }
          Spacer()
          Text("시간표")
            .twFont(.caption1, color: .extraWhite)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.extraBlack)
            .clipShape(Capsule())
            .staggered(showPageContent, order: 2)
        }

        if viewStore.isTimeTableLoading {
          HStack {
            Spacer()
            ProgressView()
            Spacer()
          }
          .padding(.vertical, 24)
        } else {
          let lines = timetableLines(from: viewStore.timeTables)
          VStack(spacing: 10) {
            ForEach(Array(lines.enumerated()), id: \.element.0) { index, item in
              HStack(spacing: 12) {
                Text("\(item.0)교시")
                  .twFont(.body3, color: .textSecondary)
                  .frame(width: 42, alignment: .leading)

                Text(item.1)
                  .twFont(.body2, color: .textPrimary)
                  .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                  .font(.system(size: 12, weight: .semibold))
                  .foregroundColor(.unselectedPrimary)
              }
              .padding(.horizontal, 16)
              .padding(.vertical, 14)
              .background(Color.backgroundMain)
              .clipShape(RoundedRectangle(cornerRadius: 16))
              .staggered(showPageContent, order: 3 + index)
            }
          }
          .padding(.top, 2)
        }
      }
      .padding(24)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .background(Color.cardBackground, in: .rect(cornerRadius: 28))

      if viewStore.timeTableUsesFallback {
        infoFootnote(text: "해당 날짜의 실제 시간표 정보가 아직 없어서 예시 시간표를 보여드리고 있어요.")
          .staggered(showPageContent, order: 9)
      }
    }
  }

  private func widgetPreview(viewStore: ViewStore<OnboardingCore.State, OnboardingCore.Action>)
    -> some View
  {
    VStack(spacing: 20) {
      VStack(alignment: .leading, spacing: 10) {
        HStack {
          Text(viewStore.schoolName.isEmpty ? "오늘뭐임" : viewStore.schoolName)
            .twFont(.caption1, color: .extraWhite)
            .lineLimit(1)
          Spacer()
          Image(systemName: "sparkles")
            .foregroundColor(.extraWhite)
        }

        Text("점심")
          .twFont(.headline4, color: .extraWhite)

        VStack(alignment: .leading, spacing: 6) {
          ForEach(mealLines(from: viewStore.meal).prefix(4), id: \.self) { line in
            Text(line)
          }
        }
        .twFont(.body3, color: .extraWhite)
        .lineLimit(1)
      }
      .padding(22)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .aspectRatio(360.0 / 170.0, contentMode: .fit)
      .background(Color.extraBlack, in: .rect(cornerRadius: 30))
      .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
      .staggered(showPageContent, order: 0)

      guideRow(number: 1, text: "홈 화면 빈 공간을 길게 눌러 편집 모드로 들어가요")
        .staggered(showPageContent, order: 2)
      guideRow(number: 2, text: "왼쪽 위 + 버튼을 누른 뒤 ‘오늘뭐임’을 검색해요")
        .staggered(showPageContent, order: 3)
      guideRow(number: 3, text: "급식 위젯을 선택해서 홈 화면에 추가하면 끝이에요")
        .staggered(showPageContent, order: 4)

      if viewStore.mealUsesFallback {
        infoFootnote(text: "위젯 미리보기는 현재 예시 급식 데이터로 보여주고 있어요.")
          .staggered(showPageContent, order: 5)
      }
    }
    .sheet(isPresented: $isWidgetGuidePresented) {
      viewStore.send(.nextButtonDidTap, animation: .default)
    } content: {
      widgetGuideSheet
    }
  }

  @ViewBuilder
  private var widgetGuideSheet: some View {
    if #available(iOS 16.0, *) {
      WidgetGuideSheetView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    } else {
      WidgetGuideSheetView()
    }
  }

  private var ecosystemPreview: some View {
    VStack(spacing: 20) {
      LazyVGrid(
        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
        spacing: 12
      ) {
        ecosystemCard(symbol: siriSymbolName, title: "Siri", message: "말로 급식과 시간표를 빠르게 확인")
          .staggered(showPageContent, order: 0)
        ecosystemCard(symbol: "applewatch", title: "Apple Watch", message: "손목에서 바로 오늘 정보 확인")
          .staggered(showPageContent, order: 1)
        ecosystemCard(symbol: "laptopcomputer", title: "Mac", message: "공부 중에도 데스크에서 자연스럽게")
          .staggered(showPageContent, order: 2)
        ecosystemCard(symbol: "ipad.landscape", title: "iPad", message: "큰 화면에서도 편하게 이어보기")
          .staggered(showPageContent, order: 3)
      }

      siriSection
        .staggered(showPageContent, order: 4)
    }
  }

  private var siriSymbolName: String {
    if #available(iOS 26.0, *) {
      return "siri"
    } else {
      return "waveform"
    }
  }

  private func ecosystemCard(symbol: String, title: String, message: String) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Image(systemName: symbol)
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(.extraBlack)
        .frame(width: 42, height: 42)
        .background(Color.backgroundMain)
        .clipShape(RoundedRectangle(cornerRadius: 12))

      Text(title)
        .twFont(.headline4, color: .extraBlack)

      Text(message)
        .twFont(.body3, color: .textSecondary)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
    .padding(18)
    .background(Color.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 22))
  }

  private func infoFootnote(text: String) -> some View {
    Text(text)
      .twFont(.caption1, color: .textSecondary)
      .frame(maxWidth: .infinity, alignment: .center)
      .multilineTextAlignment(.center)
      .padding(.horizontal, 12)
  }

  private func guideRow(number: Int, text: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Text("\(number)")
        .twFont(.caption1, color: .extraWhite)
        .frame(width: 24, height: 24)
        .background(Color.extraBlack.opacity(0.75))
        .overlay {
          Circle().stroke(Color.extraWhite.opacity(0.2), lineWidth: 1)
        }
        .clipShape(Circle())

      Text(text)
        .twFont(.body3, color: .textPrimary)
        .fixedSize(horizontal: false, vertical: true)

      Spacer(minLength: 0)
    }
    .padding(14)
    .background(Color.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 18))
  }

  private func mealLines(from meal: Meal?) -> [String] {
    let lunch = meal?.lunch.meals.filter { !$0.isEmpty }
    if let lunch, !lunch.isEmpty {
      return Array(lunch.prefix(5))
    }
    return ["찹쌀밥", "돈까스", "양배추샐러드", "우동국물", "요구르트"]
  }

  private func timetableLines(from timeTables: [TimeTable]) -> [(Int, String)] {
    let lines =
      timeTables
      .filter { !$0.content.isEmpty }
      .sorted { $0.perio < $1.perio }
      .prefix(6)
      .map { ($0.perio, $0.content) }

    if lines.isEmpty {
      return [
        (1, "국어"),
        (2, "수학"),
        (3, "영어"),
        (4, "과학"),
        (5, "체육"),
      ]
    }

    return Array(lines)
  }
}

extension View {
  @ViewBuilder
  fileprivate func scrollClipDisabledIfAvailable() -> some View {
    if #available(iOS 17.0, *) {
      self.scrollClipDisabled()
    } else {
      self
    }
  }

  fileprivate func staggered(_ show: Bool, order: Int) -> some View {
    self
      .opacity(show ? 1 : 0)
      .animation(
        show ? .easeOut(duration: 0.3).delay(Double(order) * 0.07) : nil,
        value: show
      )
  }
}

extension OnboardingView where SiriSection == EmptyView {
  public init(store: StoreOf<OnboardingCore>) {
    self.store = store
    self.siriSection = EmptyView()
  }
}

private struct WidgetGuideSheetView: View {
  @State private var elapsedTime: Double = 0
  @State private var timerActive = true
  @State private var showDismissButton = false
  @Environment(\.dismiss) private var dismiss
  private let cycleTime: Double = 10.0

  private var currentGuideText: String {
    let cyclicTime = elapsedTime.truncatingRemainder(dividingBy: cycleTime)

    if cyclicTime < 4.0 {
      return "1. 홈 화면에서 아무 곳이나 길게 눌러주세요."
    } else if cyclicTime < 6.5 {
      return "2. 왼쪽 위의 '+' 혹은 '편집'을 눌러주세요."
    } else {
      return "3. 오늘뭐임을 찾아 홈 화면에 추가해주세요."
    }
  }

  var body: some View {
    VStack(spacing: 16) {
      if let animation = LottieAnimation.named(
        "add_home_screen_widget",
        bundle: DesignSystemResources.bundle
      ) {
        LottieView {
          .lottieAnimation(animation)
        }
        .looping()
        .frame(height: 260)
        .padding(.top, 40)
      }

      Text(currentGuideText)
        .twFont(.headline4, color: .textPrimary)
        .lineSpacing(5)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .animation(.easeInOut, value: currentGuideText)
        .onReceive(
          Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
        ) { _ in
          if timerActive {
            elapsedTime += 0.5
          }
        }

      if showDismissButton {
        TWButton(title: "확인했어요", style: .wide) {
          dismiss()
        }
        .padding(.top, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }

      Spacer(minLength: 0)
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 20)
    .background(Color.backgroundMain)
    .onDisappear {
      timerActive = false
    }
    .onAppear {
      timerActive = true
      elapsedTime = 0
      showDismissButton = false

      DispatchQueue.main.asyncAfter(deadline: .now() + cycleTime) {
        guard timerActive else { return }
        timerActive = false
        withAnimation(.easeOut(duration: 0.25)) {
          showDismissButton = true
        }
      }
    }
  }
}
