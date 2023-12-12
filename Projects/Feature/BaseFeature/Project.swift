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
                .SPM.ComposableArchitecture,
                .shared(target: .SwiftUIUtil),
                .shared(target: .EnumUtil),
                .shared(target: .DateUtil),
                .shared(target: .FoundationUtil),
                .shared(target: .ConstantUtil),
                .userInterface(target: .DesignSystem)
            ]
        )
    ]
)
