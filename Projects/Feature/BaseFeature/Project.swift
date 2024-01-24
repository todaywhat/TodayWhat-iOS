import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.BaseFeature.rawValue,
    targets: [
        .implements(
            module: .feature(.BaseFeature),
            product: .framework,
            dependencies: [
                .shared(target: .ComposableArchitectureWrapper),
                .shared(target: .SwiftUIUtil),
                .shared(target: .EnumUtil),
                .shared(target: .DateUtil),
                .shared(target: .FoundationUtil),
                .shared(target: .ConstantUtil),
                .shared(target: .TWLog),
                .userInterface(target: .DesignSystem)
            ]
        )
    ]
)
