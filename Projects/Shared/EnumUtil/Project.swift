import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.EnumUtil.rawValue,
    targets: [
        .implements(module: .shared(.EnumUtil), product: .framework)
    ]
)
