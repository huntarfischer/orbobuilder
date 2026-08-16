import Foundation

public enum GeoplacementResolution: Equatable, Sendable {
    case found(Place)
    case ambiguous([Place])
    case notFound
}

public enum GeoplacementAtlas {
    public static let version = "1"
    public static let sourceDescription = "Orbo cities.js: city-timezones cityMapping.json (MIT) plus hand-curated major cities; coordinates rounded to 2 decimals"
    public static let expectedRecordCount = 7_358

    private static let records: [Place] = {
        do {
            let loaded = try GeoplacementResourceLoader.load()
            precondition(
                loaded.count == expectedRecordCount,
                "Geoplacement Atlas v1 expected \(expectedRecordCount) records, found \(loaded.count)."
            )
            return loaded
        } catch {
            preconditionFailure("Unable to load Geoplacement Atlas v1: \(error)")
        }
    }()

    private static let index = GeoplacementIndex(records: records)

    public static var count: Int { records.count }

    public static func search(_ query: String, limit: Int = 50) -> [Place] {
        index.search(query, limit: limit)
    }

    public static func resolve(_ name: String) -> GeoplacementResolution {
        index.resolve(name)
    }
}

internal struct GeoplacementIndex {
    private struct IndexedPlace {
        let place: Place
        let normalizedName: String
    }

    private let records: [IndexedPlace]
    private let exact: [String: [Place]]

    init(records: [Place]) {
        var exact: [String: [Place]] = [:]
        var indexed: [IndexedPlace] = []
        indexed.reserveCapacity(records.count)

        for place in records {
            let normalized = Self.normalize(place.canonicalName)
            indexed.append(IndexedPlace(place: place, normalizedName: normalized))
            exact[normalized, default: []].append(place)
        }

        self.records = indexed
        self.exact = exact
    }

    func resolve(_ name: String) -> GeoplacementResolution {
        let query = Self.normalize(name)
        guard !query.isEmpty else { return .notFound }

        if let exactMatches = exact[query] {
            return Self.resolution(for: Self.unique(exactMatches))
        }

        let prefix = query + ","
        let prefixMatches = Self.unique(
            records.lazy
                .filter { $0.normalizedName.hasPrefix(prefix) }
                .map(\.place)
        )

        return Self.resolution(for: prefixMatches)
    }

    func search(_ query: String, limit: Int) -> [Place] {
        guard limit > 0 else { return [] }
        let normalized = Self.normalize(query)
        guard !normalized.isEmpty else { return [] }

        var results: [Place] = []
        results.reserveCapacity(min(limit, 50))
        var seen: Set<Place> = []

        for record in records where record.normalizedName.contains(normalized) {
            if seen.insert(record.place).inserted {
                results.append(record.place)
                if results.count == limit { break }
            }
        }

        return results
    }

    private static func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func unique<S: Sequence>(_ places: S) -> [Place] where S.Element == Place {
        var seen: Set<Place> = []
        var result: [Place] = []
        for place in places where seen.insert(place).inserted {
            result.append(place)
        }
        return result
    }

    private static func resolution(for matches: [Place]) -> GeoplacementResolution {
        switch matches.count {
        case 0: return .notFound
        case 1: return .found(matches[0])
        default: return .ambiguous(matches)
        }
    }
}

private enum GeoplacementResourceLoader {
    enum LoaderError: Error, CustomStringConvertible {
        case resourceMissing
        case malformedRecord(line: Int, text: String)
        case invalidLatitude(line: Int, value: Double)
        case invalidLongitude(line: Int, value: Double)
        case invalidTimezone(line: Int, value: String)
        case invalidPlace(line: Int, value: String)
        case invalidEscape(line: Int, value: String)

        var description: String {
            switch self {
            case .resourceMissing:
                return "geoplacement-atlas-v1.js is missing from the OrboCore resource bundle"
            case let .malformedRecord(line, text):
                return "malformed Atlas record at line \(line): \(text)"
            case let .invalidLatitude(line, value):
                return "invalid latitude \(value) at line \(line)"
            case let .invalidLongitude(line, value):
                return "invalid longitude \(value) at line \(line)"
            case let .invalidTimezone(line, value):
                return "invalid timezone identifier \(value) at line \(line)"
            case let .invalidPlace(line, value):
                return "invalid place name \(value) at line \(line)"
            case let .invalidEscape(line, value):
                return "invalid JavaScript string escape at line \(line): \(value)"
            }
        }
    }

    private static let recordPattern = try! NSRegularExpression(
        pattern: #"^\s*\{\s*n:\s*'((?:\\.|[^'])*)',\s*la:\s*(-?(?:\d+(?:\.\d*)?|\.\d+)),\s*lo:\s*(-?(?:\d+(?:\.\d*)?|\.\d+)),\s*tz:\s*'((?:\\.|[^'])*)'\s*\},?\s*$"#
    )

    static func load() throws -> [Place] {
        guard let url = Bundle.module.url(
            forResource: "geoplacement-atlas-v1",
            withExtension: "js"
        ) else {
            throw LoaderError.resourceMissing
        }

        let source = try String(contentsOf: url, encoding: .utf8)
        let lines = source.split(separator: "\n", omittingEmptySubsequences: false)
        var places: [Place] = []
        places.reserveCapacity(GeoplacementAtlas.expectedRecordCount)

        for (offset, rawLine) in lines.enumerated() {
            let lineNumber = offset + 1
            let text = String(rawLine)
            let trimmed = text.trimmingCharacters(in: .whitespaces)

            guard trimmed.hasPrefix("{") else { continue }

            let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
            guard
                let match = recordPattern.firstMatch(in: text, range: nsRange),
                match.numberOfRanges == 5,
                let nameRange = Range(match.range(at: 1), in: text),
                let latitudeRange = Range(match.range(at: 2), in: text),
                let longitudeRange = Range(match.range(at: 3), in: text),
                let timezoneRange = Range(match.range(at: 4), in: text),
                let latitudeRaw = Double(text[latitudeRange]),
                let longitudeRaw = Double(text[longitudeRange])
            else {
                throw LoaderError.malformedRecord(line: lineNumber, text: text)
            }

            let rawName = String(text[nameRange])
            let rawTimezone = String(text[timezoneRange])
            let name = try unescape(rawName, line: lineNumber)
            let timezoneName = try unescape(rawTimezone, line: lineNumber)

            guard let latitude = Latitude(latitudeRaw) else {
                throw LoaderError.invalidLatitude(line: lineNumber, value: latitudeRaw)
            }
            guard let longitude = GeographicLongitude(longitudeRaw) else {
                throw LoaderError.invalidLongitude(line: lineNumber, value: longitudeRaw)
            }
            guard let timezone = TimezoneIdentifier(timezoneName) else {
                throw LoaderError.invalidTimezone(line: lineNumber, value: timezoneName)
            }
            guard let place = Place(
                canonicalName: name,
                latitude: latitude,
                longitude: longitude,
                timezone: timezone
            ) else {
                throw LoaderError.invalidPlace(line: lineNumber, value: name)
            }

            places.append(place)
        }

        return places
    }

    private static func unescape(_ source: String, line: Int) throws -> String {
        let scalars = Array(source.unicodeScalars)
        var result = String.UnicodeScalarView()
        var index = 0

        while index < scalars.count {
            let scalar = scalars[index]
            guard scalar == "\\" else {
                result.append(scalar)
                index += 1
                continue
            }

            guard index + 1 < scalars.count else {
                throw LoaderError.invalidEscape(line: line, value: source)
            }

            let escaped = scalars[index + 1]
            switch escaped {
            case "'", "\"", "\\", "/":
                result.append(escaped)
                index += 2
            case "b":
                result.append("\u{0008}")
                index += 2
            case "f":
                result.append("\u{000C}")
                index += 2
            case "n":
                result.append("\n")
                index += 2
            case "r":
                result.append("\r")
                index += 2
            case "t":
                result.append("\t")
                index += 2
            case "u":
                guard index + 5 < scalars.count else {
                    throw LoaderError.invalidEscape(line: line, value: source)
                }
                let hex = String(String.UnicodeScalarView(scalars[(index + 2)...(index + 5)]))
                guard
                    let value = UInt32(hex, radix: 16),
                    let decoded = UnicodeScalar(value)
                else {
                    throw LoaderError.invalidEscape(line: line, value: source)
                }
                result.append(decoded)
                index += 6
            default:
                throw LoaderError.invalidEscape(line: line, value: source)
            }
        }

        return String(result)
    }
}
