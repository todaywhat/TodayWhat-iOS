import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.MainFeature.rawValue,
    targets: [
        .implements(module: .feature(.MainFeature), dependencies: [
            .feature(target: .BaseFeature),
            .feature(target: .MealFeature),
            .feature(target: .NoticeFeature),
            .feature(target: .TimeTableFeature),
            .feature(target: .SettingsFeature),
            .shared(target: .FeatureFlagClient),
            .shared(target: .NoticeClient),
            .shared(target: .UserDefaultsClient),
            .shared(target: .ITunesClient),
            .shared(target: .Entity)
        ])
    ]
)
