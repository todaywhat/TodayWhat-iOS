import Foundation

public struct SingleSchoolMajorResponseDTO: Decodable {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    enum CodingKeys: String, CodingKey {
        case name = "DDDEP_NM"
    }
}

public extension SingleSchoolMajorResponseDTO {
    func toDomain() -> String {
        name
    }
}
