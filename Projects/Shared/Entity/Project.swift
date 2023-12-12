import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.Entity.rawValue,
    targets: [
        .implements(module: .shared(.Entity), product: .framework, dependencies: [
           .SPM.GRDB,
           .shared(target: .EnumUtil)
        ])
    ]
)
