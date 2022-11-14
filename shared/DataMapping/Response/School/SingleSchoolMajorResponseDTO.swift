import Foundation

struct SingleSchoolMajorResponseDTO: Decodable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name = "DDDEP_NM"
    }
}

extension SingleSchoolMajorResponseDTO {
    func toDomain() -> String {
        name
    }
}
