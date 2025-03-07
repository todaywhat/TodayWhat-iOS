import ProjectDescription

public extension TargetDependency {
    struct SPM {}
}

public extension TargetDependency.SPM {
    static let Nuke = TargetDependency.external(name: "NukeUI")
    static let ComposableArchitecture = TargetDependency.external(name: "ComposableArchitecture")
    static let GRDB = TargetDependency.external(name: "GRDB")
    static let SwiftyJSON = TargetDependency.external(name: "SwiftyJSON")
    static let Firestore = TargetDependency.external(name: "FirebaseFirestore")
    static let FirebaseAnalytics = TargetDependency.external(name: "FirebaseAnalytics")
    static let FirebaseCrashlytics = TargetDependency.external(name: "FirebaseCrashlytics")
    static let FirebaseRemoteConfig = TargetDependency.external(name: "FirebaseRemoteConfig")
    static let LaunchAtScreen = TargetDependency.external(name: "LaunchAtLogin")
    static let Lottie = TargetDependency.external(name: "Lottie")
}

public extension Package {
    
}
