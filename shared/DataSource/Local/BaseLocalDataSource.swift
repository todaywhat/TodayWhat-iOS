import GRDB

protocol BaseLocalDataSource {
    associatedtype Entity: FetchableRecord, MutablePersistableRecord
    init(_ dbWriter: any DatabaseWriter)
    var dbWriter: any DatabaseWriter { get }
    var dbReader: any DatabaseReader { get }
    var migrator: DatabaseMigrator { get }
    func save(_ entity: inout Entity) async throws
    func fetchAll() async throws -> [Entity]
    func deleteAll() async throws
}

extension BaseLocalDataSource {
    var dbReader: any DatabaseReader {
        dbWriter
    }

    func save(_ entity: inout Entity) async throws {
        entity = try await dbWriter.write { [entity] db in
            try entity.saved(db)
        }
    }

    func fetchAll() async throws -> [Entity] {
        try await dbWriter.write { db in
            try Entity.all().fetchAll(db)
        }
    }

    func deleteAll() async throws {
        _ = try await dbWriter.write { db in
            try Entity.deleteAll(db)
        }
    }
}
