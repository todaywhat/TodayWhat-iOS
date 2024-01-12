import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.ComposableArchitectureWrapper.rawValue,
    targets: [
        .implements(module: .shared(.ComposableArchitectureWrapper), product: .framework, dependencies: [
            .SPM.ComposableArchitecture
        ])
    ]
)
