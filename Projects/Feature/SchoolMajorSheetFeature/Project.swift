import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.SchoolMajorSheetFeature.rawValue,
    targets: [
        .implements(module: .feature(.SchoolMajorSheetFeature), dependencies: [
            .feature(target: .BaseFeature),
            .shared(target: .LocalDatabaseClient)
        ])
    ]
)
