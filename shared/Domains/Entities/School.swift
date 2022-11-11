import Foundation

struct School: Equatable, Hashable {
    let orgCode: String
    let schoolCode: String
    let name: String
    let location: String
    let schoolType: SchoolType
}
