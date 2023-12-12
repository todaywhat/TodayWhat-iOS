import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.RootFeature.rawValue,
    targets: [
        .implements(module: .feature(.RootFeature), dependencies: [
            .feature(target: .BaseFeature),
            .feature(target: .SchoolSettingFeature),
            .feature(target: .MainFeature),
            .feature(target: .SplashFeature),
            .shared(target: .UserDefaultsClient)
        ])
    ]
)
