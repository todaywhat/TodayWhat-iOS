import ComposableArchitecture
import DesignSystem
import Entity
import SwiftUI

public struct TimeTableView: View {
    let store: StoreOf<TimeTableCore>
    @ObservedObject var viewStore: ViewStoreOf<TimeTableCore>

    public init(store: StoreOf<TimeTableCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        let currentMonth: Int = Date().month
        let isEmpty: Bool = viewStore.timeTableList.isEmpty && !viewStore.isLoading
        ScrollView {
            if isEmpty {
                Text("오늘 시간표를 찾을 수 없어요!")
                    .padding(.top, 16)
                    .foregroundColor(.textSecondary)
                    .accessibilityLabel("시간표를 찾을 수 없습니다")
                    .accessibilitySortPriority(1)

                if currentMonth == 3 || currentMonth == 9 {
                    Text("학기 초에는 neis에 정규시간표가\n 등록되어있지 않을 수도 있어요.")
                        .multilineTextAlignment(.center)
                        .padding(.top, 14)
                        .foregroundColor(.textSecondary)
                        .accessibilityLabel("학기 초에는 정규시간표가 등록되어 있지 않을 수 있습니다")
                        .accessibilitySortPriority(2)
                }
            }

            ZStack {
                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(.automatic)
                        .padding(.top, 16)
                        .accessibilityLabel("시간표를 불러오는 중입니다")
                        .accessibilitySortPriority(1)
                }

                LazyVStack(spacing: 8) {
                    Spacer()
                        .frame(height: 16)

                    ForEach(viewStore.timeTableList, id: \.self) { timeTable in
                        timeTableRow(timeTable: timeTable)
                            .padding(.horizontal, 16)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onLoad {
            viewStore.send(.onLoad)
        }
        .onAppear {
            viewStore.send(.onAppear, animation: .default)
        }
        .refreshable {
            viewStore.send(.refresh, animation: .default)
        }
    }

    @ViewBuilder
    private func timeTableRow(timeTable: TimeTable) -> some View {
        let perioText: String = "\(timeTable.perio)교시"
        let contentText: String = timeTable.content
        let accessibilityText: String = "\(timeTable.perio)교시 \(contentText)"
        HStack(spacing: 8) {
            Text(perioText)
                .twFont(.caption1, color: .textPrimary)

            Divider()
                .foregroundColor(.unselectedSecondary)
                .frame(height: 18)
                .accessibilityHidden(true)

            Text(contentText)
                .twFont(.headline4, color: .textPrimary)
                .padding(.leading, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background {
            Color.cardBackground
        }
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilitySortPriority(2)
    }
}
