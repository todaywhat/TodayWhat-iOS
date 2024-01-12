import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.SchoolClient.rawValue,
    targets: [
        .implements(module: .shared(.SchoolClient), dependencies: [
            .shared(target: .ComposableArchitectureWrapper),
            .shared(target: .Entity),
            .shared(target: .EnumUtil),
            .shared(target: .NeisClient)
        ])
    ]
)
