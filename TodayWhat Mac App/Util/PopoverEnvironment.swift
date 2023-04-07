import Combine
import SwiftUI

struct PopoverOpenEnvironment: EnvironmentKey {
    static var defaultValue: AnyPublisher<Void, Never> = Just(())
        .ignoreOutput()
        .eraseToAnyPublisher()
}

extension EnvironmentValues {
    var popoverOpen: AnyPublisher<Void, Never> {
        get { self[PopoverOpenEnvironment.self] }
        set { self[PopoverOpenEnvironment.self] = newValue }
    }
}
