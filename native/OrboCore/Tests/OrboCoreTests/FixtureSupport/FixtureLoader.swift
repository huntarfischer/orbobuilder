import Foundation

enum FixtureKind: String {
    case golden = "Golden"
    case parity = "Parity"
}

enum FixtureError: Error, Equatable {
    case missing(kind: FixtureKind, name: String, fileExtension: String)
}

enum FixtureLoader {
    static func data(
        named name: String,
        kind: FixtureKind,
        fileExtension: String = "json"
    ) throws -> Data {
        let subdirectory = "Fixtures/\(kind.rawValue)"

        guard let url = Bundle.module.url(
            forResource: name,
            withExtension: fileExtension,
            subdirectory: subdirectory
        ) else {
            throw FixtureError.missing(
                kind: kind,
                name: name,
                fileExtension: fileExtension
            )
        }

        return try Data(contentsOf: url)
    }

    static func decode<T: Decodable>(
        _ type: T.Type,
        named name: String,
        kind: FixtureKind,
        fileExtension: String = "json"
    ) throws -> T {
        let data = try data(
            named: name,
            kind: kind,
            fileExtension: fileExtension
        )
        return try JSONDecoder().decode(type, from: data)
    }
}
