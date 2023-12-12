import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.SchoolSettingFeature.rawValue,
    targets: [
        .implements(module: .feature(.SchoolSettingFeature), dependencies: [
            .feature(target: .BaseFeature),
            .feature(target: .SchoolMajorSheetFeature),
            .shared(target: .NoticeClient),
            .shared(target: .SchoolClient),
            .shared(target: .UserDefaultsClient),
            .shared(target: .Entity)
        ])
    ]
)
