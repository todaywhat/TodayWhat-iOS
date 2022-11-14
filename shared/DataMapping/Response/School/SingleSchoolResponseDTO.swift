import Foundation

struct SingleSchoolResponseDTO: Decodable {
    let orgCode: String
    let schoolCode: String
    let name: String
    let location: String
    let schoolKind: String
    
    enum CodingKeys: String, CodingKey {
        case orgCode = "ATPT_OFCDC_SC_CODE"
        case schoolCode = "SD_SCHUL_CODE"
        case name = "SCHUL_NM"
        case location = "ORG_RDNMA"
        case schoolKind = "SCHUL_KND_SC_NM"
    }
}

extension SingleSchoolResponseDTO {
    func toDomain() -> School {
        School(
            orgCode: orgCode,
            schoolCode: schoolCode,
            name: name,
            location: location,
            schoolType: SchoolKind(rawValue: schoolKind)?.toType() ?? SchoolType.high
        )
    }
}
