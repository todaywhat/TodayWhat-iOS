import Foundation
import ProjectDescription

public struct ProjectEnvironment {
    public let name: String
    public let organizationName: String
    public let destinations: Destinations
    public let deploymentTargets: DeploymentTargets
    public let baseSetting: SettingsDictionary
}

public let env = ProjectEnvironment(
    name: "TodayWhat",
    organizationName: "baegteun",
    destinations: [.iPhone, .iPad, .mac, .appleWatch],
    deploymentTargets: .multiplatform(iOS: "16.0", macOS: "12.0", watchOS: "9.0"),
    baseSetting: [:]
)
