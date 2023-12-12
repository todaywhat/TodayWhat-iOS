import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.DateUtil.rawValue,
    targets: [
        .implements(module: .shared(.DateUtil), product: .framework)
    ]
)
