import Foundation

public struct School: Equatable, Hashable {
    public let orgCode: String
    public let schoolCode: String
    public let name: String
    public let location: String
    public let schoolType: SchoolType

    public init(
        orgCode: String,
        schoolCode: String,
        name: String,
        location: String,
        schoolType: SchoolType
    ) {
        self.orgCode = orgCode
        self.schoolCode = schoolCode
        self.name = name
        self.location = location
        self.schoolType = schoolType
    }
}
