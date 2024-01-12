import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.NeisClient.rawValue,
    targets: [
        .implements(module: .shared(.NeisClient), dependencies: [
            .SPM.SwiftyJSON,
            .shared(target: .ComposableArchitectureWrapper),
            .shared(target: .ConstantUtil)
        ])
    ]
)
