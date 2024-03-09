import Foundation

public struct TutorialEntity: Equatable {
    public let id: String
    public let index: Int
    public let thumbnailImageURL: String
    public let title: String

    public init(id: String, index: Int, thumbnailImageURL: String, title: String) {
        self.id = id
        self.index = index
        self.thumbnailImageURL = thumbnailImageURL
        self.title = title
    }
}
