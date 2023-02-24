import Dependencies
import SwiftUI

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
