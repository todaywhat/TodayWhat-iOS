import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.AppRouteClient.rawValue,
    targets: [
        .implements(module: .shared(.AppRouteClient), dependencies: [])
    ]
)
