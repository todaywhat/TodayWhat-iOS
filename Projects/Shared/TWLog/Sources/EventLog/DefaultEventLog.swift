import Foundation

public struct DefaultEventLog: EventLog {
    public let name: String
    public let params: [String: Any]

    public init(name: String, params: [String: Any]) {
        self.name = name
        self.params = params
    }
}
