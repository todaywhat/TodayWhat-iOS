import ComposableArchitecture
import GRDB
import ConstantUtil
import Foundation

public struct LocalDatabaseClient {
    private let dbQueue: DatabaseQueue
    private var migrator = DatabaseMigrator()

    public func save(record: some FetchableRecord & PersistableRecord) throws {
        try dbQueue.write { db in
            try record.insert(db)
        }
    }

    public func save(records: [some FetchableRecord & PersistableRecord]) throws {
        try dbQueue.write { db in
            try records.forEach { record in
                try record.insert(db)
            }
        }
    }

    public func readRecords<Record: FetchableRecord & PersistableRecord>(
        as record: Record.Type,
        ordered: [SQLOrderingTerm] = []
    ) throws -> [Record] {
        try dbQueue.write { db in
            try record.order(ordered).fetchAll(db)
        }
    }

    public func readRecord<Record: FetchableRecord & PersistableRecord>(
        record: Record.Type,
        at key: some DatabaseValueConvertible
    ) throws -> Record? {
        try dbQueue.read { db in
            try record.fetchOne(db, key: key)
        }
    }

    public func updateRecord<Record: FetchableRecord & PersistableRecord>(
        record: Record.Type,
        at key: any DatabaseValueConvertible,
        transform: (inout Record) -> Void
    ) throws {
        try dbQueue.write { db in
            if var value = try record.fetchOne(db, key: key) {
                try value.updateChanges(db) {
                    transform(&$0)
                }
            }
        }
    }

    public func delete(
        record: some FetchableRecord & PersistableRecord
    ) throws {
        try dbQueue.write { db in
            _ = try record.delete(db)
        }
    }

    public func delete<Record: FetchableRecord & PersistableRecord>(
        record: Record.Type,
        key: some DatabaseValueConvertible
    ) throws {
        try dbQueue.write { db in
            _ = try record.deleteOne(db, key: key)
        }
    }

    public func deleteAll<Record: FetchableRecord & PersistableRecord>(
        record: Record.Type
    ) throws {
        try dbQueue.write { db in
            _ = try record.deleteAll(db)
        }
    }
}

public extension LocalDatabaseClient {
    init(migrate: (inout DatabaseMigrator) -> Void) {
        var url: URL
        #if os(macOS)
        url = try! FileManager.default.url(
               for: .applicationSupportDirectory,
               in: .userDomainMask,
               appropriateFor: nil,
               create: true
           ).appendingPathComponent(
               "unprotected",
               isDirectory: true
           )

        try? FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: false,
            attributes: [
                FileAttributeKey.protectionKey: URLFileProtection.none
            ]
        )
        #else
        url = AppGroup.group.containerURL
        #endif        

        if #available(iOS 16, macOS 13.0, *) {
            url.append(path: "TodayWhat")
        } else {
            url.appendPathComponent("TodayWhat")
        }

        try? FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: false,
            attributes: [
                FileAttributeKey.protectionKey: URLFileProtection.none
            ]
        )

        if #available(iOS 16.0, macOS 13.0, *) {
            url.append(path: "TodayWhat.sqlite")
        } else {
            url.appendPathComponent("TodayWhat.sqlite")
        }
        var dir = ""

        if #available(iOS 16.0, macOS 13.0, *) {
            dir = url.path()
        } else {
            dir = url.path
        }

        if #available(iOS 16.0, macOS 13.0, *) {
            dir.replace("%20", with: " ")
        } else {
            dir = dir.replacingOccurrences(of: "%20", with: " ")
        }

        do {
            dbQueue = try DatabaseQueue(path: dir)
        } catch {
            fatalError()
        }
        migrate(&migrator)
        try? migrator.migrate(dbQueue)
    }

    private func unprotectedDirectory() throws -> URL {
        let url = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent(
            "unprotected",
            isDirectory: true
        )
        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: false,
                attributes: [
                    FileAttributeKey.protectionKey: URLFileProtection.none
                ]
            )
        }
        return url
    }
}

extension LocalDatabaseClient: DependencyKey {
    public static var liveValue: LocalDatabaseClient = LocalDatabaseClient { migrator in
#if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        migrator.registerMigration("v1.0.0") { db in
            try db.create(table: "allergyLocalEntity") { t in
                t.column("id", .text).primaryKey(onConflict: .replace).notNull()
                t.column("allergy", .text).notNull()
            }
        }

        migrator.registerMigration("v1.1.0") { db in
            try db.create(table: "schoolMajorLocalEntity") { t in
                t.column("id", .text).primaryKey(onConflict: .replace).notNull()
                t.column("major", .text).notNull()
            }

            try db.create(table: "modifiedTimeTableLocalEntity") { t in
                t.column("id", .text).primaryKey(onConflict: .replace).notNull()
                t.column("weekday", .integer).notNull().defaults(to: 1)
                t.column("perio", .integer).notNull().defaults(to: 1)
                t.column("content", .text).notNull().defaults(to: "")
            }
        }
    }
}

extension LocalDatabaseClient: TestDependencyKey {
    public static var testValue: LocalDatabaseClient = LocalDatabaseClient { _ in }
}

extension DependencyValues {
    public var localDatabaseClient: LocalDatabaseClient {
        get { self[LocalDatabaseClient.self] }
        set { self[LocalDatabaseClient.self] = newValue }
    }
}
