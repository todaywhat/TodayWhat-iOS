import Entity
import SwiftUI

struct TimeTableView: View {
    let timetables: [TimeTable]

    init(timetables: [TimeTable]) {
        self.timetables = timetables
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(timetables, id: \.hashValue) { timetable in
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(timetable.perio)교시")
                            .bold()

                        Text(timetable.content)
                    }
                }

                Spacer()

                HStack {
                    Spacer()

                    Text("🔄 새로고침 cmd + r")
                        .font(.caption2)
                }
            }
            .padding(8)

            Spacer()
        }
    }
}

struct TimeTableView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableView(
            timetables: [
                .init(perio: 1, content: "C# 프로그래밍"),
                .init(perio: 2, content: "앱 프로그래밍")
            ]
        )
    }
}
