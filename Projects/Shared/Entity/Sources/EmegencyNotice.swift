import Foundation

public struct EmegencyNotice: Equatable {
    public let title: String
    public let content: String

    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}
