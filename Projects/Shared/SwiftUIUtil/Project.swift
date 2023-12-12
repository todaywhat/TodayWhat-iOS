import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.SwiftUIUtil.rawValue,
    targets: [
        .implements(module: .shared(.SwiftUIUtil), product: .framework)
    ]
)
