import ComposableArchitecture
import DesignSystem
import FirebaseRemoteConfig
import SwiftUI

struct SchoolInfoCardView: View {
    let store: StoreOf<MainCore>
    @ObservedObject var viewStore: ViewStoreOf<MainCore>
    @RemoteConfigProperty(key: "enable_weekly", fallback: false) private var enableWeeklyView

    init(store: StoreOf<MainCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewStore.school)
                        .twFont(.headline4, color: .extraBlack)

                    let gradeClassString = "\(viewStore.grade)학년 \(viewStore.class)반"
                    let dateString = "\(viewStore.displayDate.toString())"
                    if enableWeeklyView {
                        Text(gradeClassString)
                            .twFont(.body2, color: .textSecondary)
                            .accessibilitySortPriority(3)
                    } else {
                        Text("\(gradeClassString) • \(dateString)")
                            .twFont(.body2, color: .textSecondary)
                            .accessibilitySortPriority(3)
                    }
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
        .cornerRadius(16)
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
