import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.TWLog.rawValue,
    targets: [
        .implements(module: .shared(.TWLog), product: .framework, dependencies: [
            .shared(target: .FirebaseWrapper)
        ])
    ]
)
