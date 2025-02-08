import ComposableArchitecture
import DesignSystem
import SwiftUI

struct DateTensePickerView: View {
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Namespace private var animation
    private let displayDate: Date
    private let onSelectDate: (Date) -> Void

    init(displayDate: Date, onSelectDate: @escaping (Date) -> Void) {
        self.displayDate = displayDate
        self.onSelectDate = onSelectDate
    }

    public var body: some View {
        let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false
        let isSkipAfterDinner = userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true
        let datePolicy = DatePolicy(isSkipWeekend: isSkipWeekend, isSkipAfterDinner: isSkipAfterDinner)

        let today = Date()
        let yesterday = datePolicy.previousDay(from: today)
        let tomorrow = datePolicy.nextDay(from: today)

        let calendar = Calendar.current

        HStack(spacing: 10) {
            ForEach([yesterday, today, tomorrow], id: \.timeIntervalSince1970) { date in
                Button {
                    onSelectDate(date)
                } label: {
                    ZStack {
                        if calendar.isDate(displayDate, inSameDayAs: date) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.extraBlack)
                                .matchedGeometryEffect(id: "SELECTED-TENSE", in: animation)
                        }

                        Text(datePolicy.displayText(for: date, baseDate: today))
                            .twFont(.body1)
                            .foregroundStyle(
                                calendar.isDate(displayDate, inSameDayAs: date)
                                    ? Color.extraWhite
                                    : Color.extraBlack
                            )
                            .animation(.easeInOut(duration: 0.2), value: displayDate)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(height: 72)
        .background(Color.backgroundSecondary)
        .cornerRadius(8)
    }
}
