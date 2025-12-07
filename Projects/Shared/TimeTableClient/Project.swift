import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.TimeTableClient.rawValue,
    targets: [
        .implements(module: .shared(.TimeTableClient), dependencies: [
            .shared(target: .ComposableArchitectureWrapper),
            .shared(target: .DateUtil),
            .shared(target: .EnumUtil),
            .shared(target: .ConstantUtil),
            .shared(target: .Entity),
            .shared(target: .NeisClient),
            .shared(target: .UserDefaultsClient),
            .shared(target: .LocalDatabaseClient)
        ])
    ]
)
