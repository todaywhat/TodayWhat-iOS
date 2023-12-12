import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.SchoolClient.rawValue,
    targets: [
        .implements(module: .shared(.SchoolClient), dependencies: [
            .SPM.ComposableArchitecture,
            .shared(target: .Entity),
            .shared(target: .EnumUtil),
            .shared(target: .NeisClient)
        ])
    ]
)
