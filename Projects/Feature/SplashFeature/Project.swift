import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.SplashFeature.rawValue,
    targets: [
        .implements(module: .feature(.SplashFeature), dependencies: [
            .feature(target: .BaseFeature),
            .shared(target: .MealClient),
            .shared(target: .UserDefaultsClient),
            .shared(target: .LocalDatabaseClient)
        ])
    ]
)
