import Foundation

public protocol EventLog {
    var name: String { get }
    var params: [String: String] { get }
}

public extension EventLog {
    var params: [String: String] { [:] }
}
