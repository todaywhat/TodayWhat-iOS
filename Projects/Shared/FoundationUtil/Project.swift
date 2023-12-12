import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.FoundationUtil.rawValue,
    targets: [
        .implements(module: .shared(.FoundationUtil), product: .framework, dependencies: [
            .shared(target: .ConstantUtil)
        ])
    ]
)
