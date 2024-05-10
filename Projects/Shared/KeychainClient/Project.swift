import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.KeychainClient.rawValue,
    targets: [
        .implements(module: .shared(.KeychainClient), dependencies: [
            .shared(target: .ComposableArchitectureWrapper)
        ])
    ]
)
