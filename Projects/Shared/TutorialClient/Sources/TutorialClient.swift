import Dependencies
import FirebaseFirestore
import Foundation

public struct TutorialClient: Sendable {
    public var fetchTutorialList: @Sendable () async throws -> [TutorialEntity]
}

extension TutorialClient: DependencyKey {
    public static var liveValue: TutorialClient = TutorialClient(
        fetchTutorialList: {
            let tutorialList: [TutorialEntity] = try await Firestore.firestore()
                .collection("tutorialList")
                .getDocuments()
                .documents
                .compactMap { snapshot in
                    let data = snapshot.data()
                    guard let index = data["index"] as? Int,
                          let thumbnailImageURL = data["thumbnailImageURL"] as? String,
                          let title = data["title"] as? String
                    else {
                        return nil
                    }
                    return TutorialEntity(
                        id: snapshot.documentID,
                        index: index,
                        thumbnailImageURL: thumbnailImageURL,
                        title: title
                    )
                }
                .sorted { $0.index > $1.index }
            return []
        }
    )
}

extension TutorialClient: TestDependencyKey {
    public static var testValue: TutorialClient = TutorialClient(
        fetchTutorialList: unimplemented("tutorialClient.fetchTutorialList")
    )
}

public extension DependencyValues {
    var tutorialClient: TutorialClient {
        get { self[TutorialClient.self] }
        set { self[TutorialClient.self] = newValue }
    }
}
