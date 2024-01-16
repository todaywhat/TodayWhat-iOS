import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.DeviceUtil.rawValue,
    targets: [
        .implements(module: .shared(.DeviceUtil), product: .framework)
    ]
)
