import Dependencies
import DateUtil
import Entity
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import XCTestDynamicOverlay

public struct NoticeClient: Sendable {
    public var fetchEmergencyNotice: @Sendable () async throws -> EmegencyNotice?
    public var fetchNoticeList: @Sendable () async throws -> [Notice]
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
        },
        fetchNoticeList: {
            let noticeList: [Notice] = try await Firestore.firestore()
                .collection("noticeList")
                .getDocuments()
                .documents
                .compactMap { (snapshot) -> Notice? in
                    let data = snapshot.data()
                    guard let title = data["title"] as? String,
                            let content = data["content"] as? String,
                            let createdAt = data["createdAt"] as? String
                    else {
                        return nil
                    }
                    return Notice(
                        id: snapshot.documentID,
                        title: title,
                        content: content,
                        createdAt: createdAt
                            .toDateCustomFormat(format: "yyyy-MM-dd")
                    )
                }
                .sorted { $0.createdAt < $1.createdAt}
            return noticeList
        }
    )
}

extension NoticeClient: TestDependencyKey {
    public static var testValue: NoticeClient = NoticeClient(
        fetchEmergencyNotice: unimplemented("noticeClient.fetchEmergencyNotice"),
        fetchNoticeList: unimplemented("noticeClient.fetchNoticeList")
    )
}

public extension DependencyValues {
    var noticeClient: NoticeClient {
        get { self[NoticeClient.self] }
        set { self[NoticeClient.self] = newValue }
    }
}
