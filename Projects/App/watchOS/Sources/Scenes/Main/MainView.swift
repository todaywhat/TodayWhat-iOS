import Entity
import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @State var isPresentedOption = false
    private let mainColor: Color = Color("Main")
    private let subColor: Color = Color("Sub")

    var body: some View {
        let currentDate: Date = Date()

        ScrollView {
            Button {
                Task {
                    await viewModel.loadData()
                }
            } label: {
                Label {
                    Text("새로고침")
                } icon: {
                    Image(systemName: "arrow.clockwise")
                }
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
            .padding(.bottom, 4)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(mainColor)
            }

            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.part.display)
                        .font(.system(size: 16))

                    Text(currentDate, format: .dateTime.year().month().day())
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }

                Text("옵션변경")
                    .font(.system(size: 14))
                    .foregroundColor(subColor)
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(mainColor)
            .cornerRadius(8)
            .onTapGesture {
                isPresentedOption.toggle()
            }

            let isTimeTable: Bool = viewModel.part == .timeTable
            let isWeekend: Bool = {
                let weekday: Int = Date().weekday
                return weekday == 7 || weekday == 1
            }()

            if !isTimeTable && viewModel.meal == nil {
                Text("등록된 정보를 찾지 못했어요 😥")
            } else if isTimeTable && viewModel.timeTables.isEmpty {
                if isWeekend {
                    Text("오늘은 주말이에요! 🛏️")
                } else {
                    Text("등록된 정보를 찾지 못했어요 😥")
                }
            }

            LazyVStack(spacing: 4) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.automatic)
                }

                if isTimeTable {
                    ForEach(viewModel.timeTables, id: \.hashValue) { timetable in
                        VStack(alignment: .leading) {
                            timetableView(timetable)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(mainColor)
                        .cornerRadius(8)
                    }
                } else {
                    ForEach(viewModel.currentMeal, id: \.self) { meal in
                        VStack(alignment: .leading) {
                            mealView(meal)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(mainColor)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            Task {
                await viewModel.loadData()
            }
        }
        .sheet(isPresented: $isPresentedOption) {
            PartSelectView(selectedPart: viewModel.part) { part in
                viewModel.part = part
            }
        }
        .navigationTitle("오늘 뭐임")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func mealView(_ meal: String) -> some View {
        Text(mealDisplay(meal: meal))
            .font(.system(size: 16))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .multilineTextAlignment(.leading)
    }

    @ViewBuilder
    func timetableView(_ timetable: TimeTable) -> some View {
        let perioText: String = "\(timetable.perio)교시"

        VStack(alignment: .leading, spacing: 0) {
            Text(timetable.content)
                .font(.system(size: 14, weight: .medium))

            Text(perioText)
                .foregroundColor(self.subColor)
                .font(.system(size: 14))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }

    private func mealDisplay(meal: String) -> String {
        return meal.replacingOccurrences(of: "[0-9.() ]", with: "", options: [.regularExpression])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
