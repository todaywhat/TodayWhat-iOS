import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.TimeTableFeature.rawValue,
    targets: [
        .implements(module: .feature(.TimeTableFeature), dependencies: [
            .feature(target: .BaseFeature),
            .shared(target: .Entity),
            .shared(target: .LocalDatabaseClient),
            .shared(target: .TimeTableClient),
            .shared(target: .UserDefaultsClient)
        ])
    ]
)
