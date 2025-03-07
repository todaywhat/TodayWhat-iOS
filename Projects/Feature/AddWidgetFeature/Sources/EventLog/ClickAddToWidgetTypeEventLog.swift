//
//  ClickAddToWidgetTypeEventLog.swift
//  AddWidgetFeature
//
//  Created by 최형우 on 3/7/25.
//  Copyright © 2025 baegteun. All rights reserved.
//

import Foundation
import TWLog

public struct ClickAddToWidgetTypeEventLog: EventLog {
    public let name: String = "click_add_to_widget_type"
    public let params: [String: String]

    public init(widget: WidgetReperesentation) {
        let kindString: String
        switch widget.kind {
        case .mealAndTimetable:
            kindString = "meal_and_timetable"
        case .meal:
            kindString = "meal"
        case .timetable:
            kindString = "timetable"
        }

        let familyString: String
        switch widget.family {
        case .systemMedium:
            familyString = "medium"
        case .systemSmall:
            familyString = "small"
        case .systemLarge:
            familyString = "large"
        case .controlCenter:
            familyString = "control_center"
        case .accessory:
            familyString = "lock_screen"
        default:
            assertionFailure("failed to convert widget family")
            familyString = ""
        }

        self.params = ["widget": "\(kindString)_\(familyString)"]
    }
}
