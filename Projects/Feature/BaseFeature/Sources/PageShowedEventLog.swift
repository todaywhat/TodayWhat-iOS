import FirebaseWrapper
import TWLog

public struct PageShowedEventLog: EventLog {
    public let name: String = "page_showed"
    public let params: [String: String]

    public init(pageName: String) {
        self.params = [
            "page_name": pageName
        ]
    }
}
