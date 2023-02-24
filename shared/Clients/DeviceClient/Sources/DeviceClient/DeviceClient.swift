import Dependencies
import SwiftUI
import XCTestDynamicOverlay

public struct DeviceClient {
    public var isPad: () -> Bool
    public var isPhone: () -> Bool
    public var isMac: () -> Bool
}

extension DeviceClient: DependencyKey {
    public static var liveValue: DeviceClient = DeviceClient(
        isPad: {
            UIDevice.current.userInterfaceIdiom == .pad
        },
        isPhone: {
            UIDevice.current.userInterfaceIdiom == .phone
        },
        isMac: {
            UIDevice.current.userInterfaceIdiom == .mac
        }
    )
}

extension DeviceClient: TestDependencyKey {
    public static var testValue: DeviceClient = DeviceClient(
        isPad: unimplemented("\(Self.self).isPad"),
        isPhone: unimplemented("\(Self.self).isPhone"),
        isMac: unimplemented("\(Self.self).isMac")
    )
}

public extension DependencyValues {
    var deviceClient: DeviceClient {
        get { self[DeviceClient.self] }
        set { self[DeviceClient.self] = newValue }
    }
}
