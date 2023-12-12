import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.MealFeature.rawValue,
    targets: [
        .implements(module: .feature(.MealFeature), dependencies: [
            .feature(target: .BaseFeature),
            .shared(target: .MealClient),
            .shared(target: .UserDefaultsClient),
            .shared(target: .LocalDatabaseClient),
            .shared(target: .Entity)
        ])
    ]
)
