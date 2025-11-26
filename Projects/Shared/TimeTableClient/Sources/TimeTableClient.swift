import ConstantUtil
import DateUtil
import Dependencies
import Entity
import EnumUtil
import Foundation
import LocalDatabaseClient
import NeisClient
import UserDefaultsClient

public struct TimeTableClient: Sendable {
    public var fetchTimeTable: @Sendable (_ date: Date) async throws -> [TimeTable]
    public var fetchTimeTableRange: @Sendable (_ startAt: Date, _ endAt: Date) async throws -> [TimeTable]
}

private func formatDate(_ date: Date) -> String {
    let month = date.month < 10 ? "0\(date.month)" : "\(date.month)"
    let day = date.day < 10 ? "0\(date.day)" : "\(date.day)"
    return "\(date.year)\(month)\(day)"
}

extension TimeTableClient: DependencyKey {
    public static var liveValue: TimeTableClient = TimeTableClient(
        fetchTimeTable: { date in
            var date = date
            @Dependency(\.userDefaultsClient) var userDefaultsClient: UserDefaultsClient
            @Dependency(\.localDatabaseClient) var localDatabaseClient: LocalDatabaseClient

            if userDefaultsClient.getValue(.isSkipWeekend) as? Bool == true {
                if date.weekday == 7 {
                    date = date.adding(by: .day, value: 2)
                } else if date.weekday == 1 {
                    date = date.adding(by: .day, value: 1)
                }
            }

            let reqDate = formatDate(date)

            if let cachedEntity = try? localDatabaseClient.readRecordByColumn(
                record: TimeTableLocalEntity.self,
                column: "date",
                value: reqDate
            ) {
                let cachedTimeTables = cachedEntity.toTimeTables()

                if !cachedTimeTables.isEmpty {
                    Task.detached {
                        await syncTimeTableFromServer(date: date, reqDate: reqDate)
                    }
                    return cachedTimeTables
                }
            }

            let timeTables = await fetchTimeTableFromServer(date: date, reqDate: reqDate)

            let entity = TimeTableLocalEntity(date: reqDate, timeTables: timeTables)
            try? localDatabaseClient.save(record: entity)

            return timeTables
        },
        fetchTimeTableRange: { startAt, endAt in
            @Dependency(\.userDefaultsClient) var userDefaultsClient: UserDefaultsClient
            @Dependency(\.localDatabaseClient) var localDatabaseClient: LocalDatabaseClient

            guard
                let typeRaw = userDefaultsClient.getValue(.schoolType) as? String,
                let type = SchoolType(rawValue: typeRaw),
                let code = userDefaultsClient.getValue(.schoolCode) as? String,
                let orgCode = userDefaultsClient.getValue(.orgCode) as? String,
                let grade = userDefaultsClient.getValue(.grade) as? Int,
                let `class` = userDefaultsClient.getValue(.class) as? Int
            else {
                return []
            }
            let major = userDefaultsClient.getValue(.major) as? String

            let startReqDate = formatDate(startAt)
            let endReqDate = formatDate(endAt)

            var dateStrings: [String] = []
            let calendar = Calendar.autoupdatingCurrent
            var currentDate = calendar.startOfDay(for: startAt)
            let normalizedEnd = calendar.startOfDay(for: endAt)

            while currentDate <= normalizedEnd {
                dateStrings.append(formatDate(currentDate))
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = nextDate
            }

            var cachedTimeTables: [TimeTable] = []
            if let cachedEntities = try? localDatabaseClient.readRecordsByColumn(
                record: TimeTableLocalEntity.self,
                column: "date",
                values: dateStrings
            ) {
                cachedTimeTables = cachedEntities.flatMap { $0.toTimeTables() }
            }

            Task.detached {
                await syncTimeTableRangeFromServer(
                    startAt: startAt,
                    endAt: endAt,
                    type: type,
                    orgCode: orgCode,
                    code: code,
                    grade: grade,
                    classNum: `class`,
                    major: major
                )
            }

            if cachedTimeTables.isEmpty {
                return await fetchTimeTableRangeFromServer(
                    startAt: startAt,
                    endAt: endAt,
                    type: type,
                    orgCode: orgCode,
                    code: code,
                    grade: grade,
                    classNum: `class`,
                    major: major
                )
            }

            return cachedTimeTables
        }
    )
}

private func fetchTimeTableFromServer(date: Date, reqDate: String) async -> [TimeTable] {
    @Dependency(\.userDefaultsClient) var userDefaultsClient: UserDefaultsClient
    @Dependency(\.neisClient) var neisClient

    guard
        let typeRaw = userDefaultsClient.getValue(.schoolType) as? String,
        let type = SchoolType(rawValue: typeRaw),
        let code = userDefaultsClient.getValue(.schoolCode) as? String,
        let orgCode = userDefaultsClient.getValue(.orgCode) as? String,
        let grade = userDefaultsClient.getValue(.grade) as? Int,
        let `class` = userDefaultsClient.getValue(.class) as? Int
    else {
        return []
    }
    let major = userDefaultsClient.getValue(.major) as? String

    let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    let response: [SingleTimeTableResponseDTO]
    do {
        response = try await neisClient.fetchDataOnNeis(
            type.toSubURL(),
            queryItem: [
                .init(name: "KEY", value: key),
                .init(name: "Type", value: "json"),
                .init(name: "pIndex", value: "1"),
                .init(name: "pSize", value: "100"),
                .init(name: "ATPT_OFCDC_SC_CODE", value: orgCode),
                .init(name: "SD_SCHUL_CODE", value: code),
                .init(name: "DDDEP_NM", value: major),
                .init(name: "GRADE", value: "\(grade)"),
                .init(name: "CLASS_NM", value: "\(`class`)"),
                .init(name: "TI_FROM_YMD", value: reqDate),
                .init(name: "TI_TO_YMD", value: reqDate)
            ],
            key: type.toSubURL(),
            type: [SingleTimeTableResponseDTO].self
        )
    } catch {
        do {
            response = try await neisClient.fetchDataOnNeis(
                type.toSubURL(),
                queryItem: [
                    .init(name: "KEY", value: key),
                    .init(name: "Type", value: "json"),
                    .init(name: "pIndex", value: "1"),
                    .init(name: "pSize", value: "100"),
                    .init(name: "ATPT_OFCDC_SC_CODE", value: orgCode),
                    .init(name: "SD_SCHUL_CODE", value: code),
                    .init(name: "GRADE", value: "\(grade)"),
                    .init(name: "CLASS_NM", value: "\(`class`)"),
                    .init(name: "TI_FROM_YMD", value: reqDate),
                    .init(name: "TI_TO_YMD", value: reqDate)
                ],
                key: type.toSubURL(),
                type: [SingleTimeTableResponseDTO].self
            )
        } catch {
            response = []
        }
    }

    return response
        .map { $0.toDomain() }
        .uniqued()
}

private func syncTimeTableFromServer(date: Date, reqDate: String) async {
    @Dependency(\.localDatabaseClient) var localDatabaseClient: LocalDatabaseClient

    let timeTables = await fetchTimeTableFromServer(date: date, reqDate: reqDate)
    let entity = TimeTableLocalEntity(date: reqDate, timeTables: timeTables)

    try? localDatabaseClient.delete(record: TimeTableLocalEntity.self, key: entity.id)
    try? localDatabaseClient.save(record: entity)
}

private func fetchTimeTableRangeFromServer(
    startAt: Date,
    endAt: Date,
    type: SchoolType,
    orgCode: String,
    code: String,
    grade: Int,
    classNum: Int,
    major: String?
) async -> [TimeTable] {
    @Dependency(\.neisClient) var neisClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient: LocalDatabaseClient

    let startReqDate = formatDate(startAt)
    let endReqDate = formatDate(endAt)

    let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    let response: [SingleTimeTableResponseDTO]
    do {
        response = try await neisClient.fetchDataOnNeis(
            type.toSubURL(),
            queryItem: [
                .init(name: "KEY", value: key),
                .init(name: "Type", value: "json"),
                .init(name: "pIndex", value: "1"),
                .init(name: "pSize", value: "100"),
                .init(name: "ATPT_OFCDC_SC_CODE", value: orgCode),
                .init(name: "SD_SCHUL_CODE", value: code),
                .init(name: "DDDEP_NM", value: major),
                .init(name: "GRADE", value: "\(grade)"),
                .init(name: "CLASS_NM", value: "\(classNum)"),
                .init(name: "TI_FROM_YMD", value: startReqDate),
                .init(name: "TI_TO_YMD", value: endReqDate)
            ],
            key: type.toSubURL(),
            type: [SingleTimeTableResponseDTO].self
        )
    } catch {
        do {
            response = try await neisClient.fetchDataOnNeis(
                type.toSubURL(),
                queryItem: [
                    .init(name: "KEY", value: key),
                    .init(name: "Type", value: "json"),
                    .init(name: "pIndex", value: "1"),
                    .init(name: "pSize", value: "100"),
                    .init(name: "ATPT_OFCDC_SC_CODE", value: orgCode),
                    .init(name: "SD_SCHUL_CODE", value: code),
                    .init(name: "GRADE", value: "\(grade)"),
                    .init(name: "CLASS_NM", value: "\(classNum)"),
                    .init(name: "TI_FROM_YMD", value: startReqDate),
                    .init(name: "TI_TO_YMD", value: endReqDate)
                ],
                key: type.toSubURL(),
                type: [SingleTimeTableResponseDTO].self
            )
        } catch {
            response = []
        }
    }

    let timeTables = response.map { $0.toDomain() }.uniqued()

    let groupedByDate = Dictionary(grouping: timeTables, by: { $0.date })
    for (date, tables) in groupedByDate {
        guard let date = date else { continue }
        let dateString = formatDate(date)
        let entity = TimeTableLocalEntity(date: dateString, timeTables: tables)

        if let existing = try? localDatabaseClient.readRecordByColumn(
            record: TimeTableLocalEntity.self,
            column: "date",
            value: dateString
        ) {
            try? localDatabaseClient.delete(record: existing)
        }
        try? localDatabaseClient.save(record: entity)
    }

    return timeTables
}

private func syncTimeTableRangeFromServer(
    startAt: Date,
    endAt: Date,
    type: SchoolType,
    orgCode: String,
    code: String,
    grade: Int,
    classNum: Int,
    major: String?
) async {
    _ = await fetchTimeTableRangeFromServer(
        startAt: startAt,
        endAt: endAt,
        type: type,
        orgCode: orgCode,
        code: code,
        grade: grade,
        classNum: classNum,
        major: major
    )
}

private extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension TimeTableClient: TestDependencyKey {
    public static var testValue: TimeTableClient = TimeTableClient(
        fetchTimeTable: { _ in [] },
        fetchTimeTableRange: { _, _ in [] }
    )
}

public extension DependencyValues {
    var timeTableClient: TimeTableClient {
        get { self[TimeTableClient.self] }
        set { self[TimeTableClient.self] = newValue }
    }
}
