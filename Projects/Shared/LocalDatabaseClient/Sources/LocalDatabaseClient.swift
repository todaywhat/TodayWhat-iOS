import ComposableArchitecture
import ConstantUtil
import Foundation
import GRDB

// swiftlint: disable identifier_name
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

    public func delete(
        record: (some FetchableRecord & PersistableRecord).Type,
        key: some DatabaseValueConvertible
    ) throws {
        try dbQueue.write { db in
            _ = try record.deleteOne(db, key: key)
        }
    }

    public func deleteAll(
        record: (some FetchableRecord & PersistableRecord).Type
    ) throws {
        try dbQueue.write { db in
            _ = try record.deleteAll(db)
        }
    }
}

public extension LocalDatabaseClient {
    // swiftlint: disable force_try
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
        #elseif os(iOS)
        url = AppGroup.group.containerURL
        #elseif os(watchOS)
        url = try! FileManager.default.url(
            for: .documentDirectory,
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
        #endif

        if #available(iOS 16, macOS 13.0, watchOS 9.0, *) {
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

        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
            url.append(path: "TodayWhat.sqlite")
        } else {
            url.appendPathComponent("TodayWhat.sqlite")
        }
        var dir = ""

        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
            dir = url.path()
        } else {
            dir = url.path
        }

        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
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

    // swiftlint: enable force_try

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
            try db.create(table: "allergyLocalEntity") { table in
                table.column("id", .text).primaryKey(onConflict: .replace).notNull()
                table.column("allergy", .text).notNull()
            }
        }

        migrator.registerMigration("v1.1.0") { db in
            try db.create(table: "schoolMajorLocalEntity") { table in
                table.column("id", .text).primaryKey(onConflict: .replace).notNull()
                table.column("major", .text).notNull()
            }

            try db.create(table: "modifiedTimeTableLocalEntity") { table in
                table.column("id", .text).primaryKey(onConflict: .replace).notNull()
                table.column("weekday", .integer).notNull().defaults(to: 1)
                table.column("perio", .integer).notNull().defaults(to: 1)
                table.column("content", .text).notNull().defaults(to: "")
            }
        }
    }
}

extension LocalDatabaseClient: TestDependencyKey {
    public static var testValue: LocalDatabaseClient = LocalDatabaseClient { _ in }
}

public extension DependencyValues {
    var localDatabaseClient: LocalDatabaseClient {
        get { self[LocalDatabaseClient.self] }
        set { self[LocalDatabaseClient.self] = newValue }
    }
}

// swiftlint: enable identifier_name
