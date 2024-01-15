import Foundation

public protocol EventLog {
    var name: String { get }
    var params: [String: Any] { get }
}
