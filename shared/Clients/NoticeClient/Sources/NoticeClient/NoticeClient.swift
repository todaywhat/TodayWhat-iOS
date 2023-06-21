import Dependencies
import Entity
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import XCTestDynamicOverlay

public struct NoticeClient: Sendable {
    public var fetchEmergencyNotice: @Sendable () async throws -> EmegencyNotice?
}

extension NoticeClient: DependencyKey {
    public static let liveValue: NoticeClient = NoticeClient(
        fetchEmergencyNotice: {
            let notice: EmegencyNotice? = try await Firestore.firestore()
                .collection("notice")
                .getDocuments()
                .documents
                .compactMap { snapshot in
                    let data = snapshot.data()
                    guard let title = data["title"] as? String, let content = data["content"] as? String else {
                        return nil
                    }
                    return EmegencyNotice(title: title, content: content)
                }
                .first
            return notice
        }
    )
}

extension NoticeClient: TestDependencyKey {
    public static var testValue: NoticeClient = NoticeClient(
        fetchEmergencyNotice: unimplemented("noticeClient.fetchEmergencyNotice")
    )
}

public extension DependencyValues {
    var noticeClient: NoticeClient {
        get { self[NoticeClient.self] }
        set { self[NoticeClient.self] = newValue }
    }
}
