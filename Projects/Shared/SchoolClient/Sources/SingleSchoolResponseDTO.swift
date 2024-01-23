import Entity
import EnumUtil
import Foundation

public struct SingleSchoolResponseDTO: Decodable {
    public let orgCode: String
    public let schoolCode: String
    public let name: String
    public let location: String
    public let schoolKind: String

    public init(
        orgCode: String,
        schoolCode: String,
        name: String,
        location: String,
        schoolKind: String
    ) {
        self.orgCode = orgCode
        self.schoolCode = schoolCode
        self.name = name
        self.location = location
        self.schoolKind = schoolKind
    }

    enum CodingKeys: String, CodingKey {
        case orgCode = "ATPT_OFCDC_SC_CODE"
        case schoolCode = "SD_SCHUL_CODE"
        case name = "SCHUL_NM"
        case location = "ORG_RDNMA"
        case schoolKind = "SCHUL_KND_SC_NM"
    }
}

public extension SingleSchoolResponseDTO {
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
