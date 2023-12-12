import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.ConstantUtil.rawValue,
    targets: [
        .implements(module: .shared(.ConstantUtil), product: .framework)
    ]
)
