import ComposableArchitecture
import Entity
import SwiftUI
import TWColor

public struct TimeTableView: View {
    let store: StoreOf<TimeTableCore>
    @ObservedObject var viewStore: ViewStoreOf<TimeTableCore>
    
    public init(store: StoreOf<TimeTableCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        ScrollView {
            if viewStore.timeTableList.isEmpty && !viewStore.isLoading {
                Text("오늘 시간표를 찾을 수 없어요!")
                    .padding(.top, 16)
                    .foregroundColor(.textSecondary)

                if Date().month == 3 {
                    Text("3월 초중반에는 neis에 정규시간표가\n 등록되어있지 않을 수도 있어요.")
                        .multilineTextAlignment(.center)
                        .padding(.top, 14)
                        .foregroundColor(.textSecondary)
                }
            }

            ZStack {
                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(.automatic)
                        .padding(.top, 16)
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
        .onAppear {
            viewStore.send(.onAppear, animation: .default)
        }
        .refreshable {
            viewStore.send(.refresh, animation: .default)
        }
    }

    @ViewBuilder
    private func timeTableRow(timeTable: TimeTable) -> some View {
        HStack(spacing: 8) {
            Text("\(timeTable.perio)교시")
                .font(.system(size: 12))
                .foregroundColor(.textPrimary)

            Divider()
                .foregroundColor(.unselectedSecondary)
                .frame(height: 18)

            Text(timeTable.content)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
                .padding(.leading, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background {
            Color.cardBackground
        }
        .cornerRadius(4)
    }
}
