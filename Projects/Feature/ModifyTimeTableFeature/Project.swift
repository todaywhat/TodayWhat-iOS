import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.ModifyTimeTableFeature.rawValue,
    targets: [
        .implements(module: .feature(.ModifyTimeTableFeature), dependencies: [
            .feature(target: .BaseFeature),
            .shared(target: .TimeTableClient),
            .shared(target: .Entity),
            .shared(target: .LocalDatabaseClient)
        ])
    ]
)
