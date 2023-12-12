import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.FirebaseWrapper.rawValue,
    targets: [
        .implements(module: .shared(.FirebaseWrapper), product: .framework, dependencies: [
            .SPM.FirebaseAnalytics,
            .SPM.FirebaseCrashlytics,
            .SPM.Firestore
        ])
    ]
)
