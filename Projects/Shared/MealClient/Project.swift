import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.MealClient.rawValue,
    targets: [
        .implements(module: .shared(.MealClient), dependencies: [
            .SPM.ComposableArchitecture,
            .shared(target: .NeisClient),
            .shared(target: .UserDefaultsClient),
            .shared(target: .DateUtil),
            .shared(target: .EnumUtil),
            .shared(target: .Entity)
        ])
    ]
)
