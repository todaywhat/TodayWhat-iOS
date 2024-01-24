import FirebaseWrapper
import TWLog

public struct PageShowedEventLog: EventLog {
    public let name: String = "page_showed"
    public let params: [String: Any]

    public init(pageName: String) {
        self.params = EventLogParameterBuilder()
            .set(key: "page_name", value: pageName)
            .build()
    }
}
