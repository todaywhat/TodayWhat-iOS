import DeviceUtil
import Foundation
import FoundationUtil
import UIKit

public final class EventLogParameterBuilder {
    private var params: [String: Any]

    public init() {
        let currentDate = Date()
        let os = "iOS \(UIDevice.current.systemVersion)"
        let device = Device.current.description
        let grade = UserDefaults.app.string(forKey: UserDefaultsKeys.grade.rawValue) ?? ""
        let schoolType = UserDefaults.app.string(forKey: UserDefaultsKeys.schoolType.rawValue) ?? ""
        let timestamp = currentDate.timeIntervalSince1970
        let dateString = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: currentDate)
        }()

        self.params = [
            "os": os,
            "device": device,
            "grade": grade,
            "school_type": schoolType,
            "timestamp": timestamp,
            "date": dateString
        ]
    }

    public func set(key: String, value: Any) -> EventLogParameterBuilder {
        self.params[key] = value
        return self
    }

    public func set(_ dict: [String: Any]) -> EventLogParameterBuilder {
        self.params.merge(dict) { _, new in new }
        return self
    }

    public func build() -> [String: Any] {
        params
    }
}
