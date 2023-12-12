import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.AllergySettingFeature.rawValue,
    targets: [
        .implements(module: .feature(.AllergySettingFeature), dependencies: [
            .feature(target: .BaseFeature),
            .shared(target: .LocalDatabaseClient),
            .shared(target: .Entity)
        ])
    ]
)
