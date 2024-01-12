import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.MealClient.rawValue,
    targets: [
        .implements(module: .shared(.MealClient), dependencies: [
            .shared(target: .ComposableArchitectureWrapper),
            .shared(target: .NeisClient),
            .shared(target: .UserDefaultsClient),
            .shared(target: .DateUtil),
            .shared(target: .EnumUtil),
            .shared(target: .Entity)
        ])
    ]
)
