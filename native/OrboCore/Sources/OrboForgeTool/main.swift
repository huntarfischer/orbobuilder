import Foundation
import OrboCore

enum OrboForgeToolError: Error, CustomStringConvertible {
    case missingArgument(String)
    case invalidArgument(String)
    case malformedSampleStream
    case malformedStationFile
    case sampleCount(expected: Int, actual: Int)

    var description: String {
        switch self {
        case let .missingArgument(name): return "Missing required argument: \(name)"
        case let .invalidArgument(value): return "Invalid argument: \(value)"
        case .malformedSampleStream: return "Swiss sample stream must contain longitude/speed Float64 pairs."
        case .malformedStationFile: return "Station chronology file is malformed."
        case let .sampleCount(expected, actual): return "Sample stream cardinality mismatch: expected \(expected), actual \(actual)."
        }
    }
}

private final class SequentialSwissSampleReference: @unchecked Sendable, ForgeEphemerisReference {
    private let values: [Double]
    private(set) var consumedCount = 0

    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        guard data.count.isMultiple(of: 16) else { throw OrboForgeToolError.malformedSampleStream }
        let bytes = [UInt8](data)
        var decoded: [Double] = []
        decoded.reserveCapacity(bytes.count / 8)
        var offset = 0
        while offset < bytes.count {
            var bits: UInt64 = 0
            for byteOffset in 0..<8 { bits |= UInt64(bytes[offset + byteOffset]) << UInt64(byteOffset * 8) }
            let value = Double(bitPattern: bits)
            guard value.isFinite else { throw OrboForgeToolError.malformedSampleStream }
            decoded.append(value)
            offset += 8
        }
        values = decoded
    }

    var sampleCount: Int { values.count / 2 }

    func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneCelestialState {
        let index = consumedCount * 2
        guard index + 1 < values.count,
              let longitude = CelestialLongitude(values[index]),
              let state = MundaneCelestialState(
                longitude: longitude,
                longitudinalSpeedDegreesPerDay: values[index + 1]
              ) else { throw OrboForgeToolError.malformedSampleStream }
        consumedCount += 1
        return state
    }
}

private struct StationFile: Decodable {
    struct BodyRecord: Decodable {
        struct StationRecord: Decodable {
            let julianDay: Double
            let motionAfter: String
        }
        let body: String
        let initialMotion: String
        let stations: [StationRecord]
    }
    let bodies: [BodyRecord]
}

private struct Arguments {
    let samples: URL
    let stations: URL
    let outputDirectory: URL
    let version: String
    let source: String
    let sourceVersion: String
    let startJulianDay: JulianDay
    let endJulianDay: JulianDay

    init(_ raw: [String]) throws {
        var values: [String: String] = [:]
        var index = 0
        while index < raw.count {
            let key = raw[index]
            guard key.hasPrefix("--"), index + 1 < raw.count else { throw OrboForgeToolError.invalidArgument(key) }
            values[key] = raw[index + 1]
            index += 2
        }
        func require(_ key: String) throws -> String {
            guard let value = values[key], !value.isEmpty else { throw OrboForgeToolError.missingArgument(key) }
            return value
        }
        let startRaw = try require("--start-jd")
        let endRaw = try require("--end-jd")
        guard let startValue = Double(startRaw), let endValue = Double(endRaw),
              let start = JulianDay(startValue), let end = JulianDay(endValue), start.value < end.value else {
            throw OrboForgeToolError.invalidArgument("Julian Day range")
        }
        samples = URL(fileURLWithPath: try require("--samples"))
        stations = URL(fileURLWithPath: try require("--stations"))
        outputDirectory = URL(fileURLWithPath: try require("--output-dir"), isDirectory: true)
        version = try require("--version")
        source = try require("--source")
        sourceVersion = try require("--source-version")
        startJulianDay = start
        endJulianDay = end
    }
}

@main
struct OrboForgeTool {
    static func main() throws {
        let arguments = try Arguments(Array(CommandLine.arguments.dropFirst()))
        let motionChronologies = try loadMotionChronologies(arguments.stations)
        guard let plan = MundaneTimespineForgePlan(
            version: arguments.version,
            astronomicalSource: arguments.source,
            astronomicalSourceVersion: arguments.sourceVersion,
            supportedStart: arguments.startJulianDay,
            supportedEnd: arguments.endJulianDay,
            profiles: MundaneTimespineForge.candidateProfiles,
            motionChronologies: motionChronologies
        ) else { throw OrboForgeToolError.invalidArgument("Forge plan") }

        let reference = try SequentialSwissSampleReference(url: arguments.samples)
        let expected = MundaneTimespineForge.expectedSampleCount(for: plan)
        guard reference.sampleCount == expected else {
            throw OrboForgeToolError.sampleCount(expected: expected, actual: reference.sampleCount)
        }

        var cursor = MundaneTimespineForge.makeCursor(plan: plan)
        while !cursor.isComplete { _ = try cursor.step(reference: reference, sampleBudget: 8_192) }
        let product = try cursor.product()
        guard reference.consumedCount == expected else {
            throw OrboForgeToolError.sampleCount(expected: expected, actual: reference.consumedCount)
        }

        let artifacts = product.encodedArtifacts()
        try FileManager.default.createDirectory(at: arguments.outputDirectory, withIntermediateDirectories: true)
        try artifacts.manifest.write(to: arguments.outputDirectory.appendingPathComponent("mundane-timespine-v1.json"), options: .atomic)
        for body in MundaneBody.canonicalOrder {
            guard let data = artifacts.data(for: body) else { continue }
            try data.write(to: arguments.outputDirectory.appendingPathComponent(body.artifactFileName), options: .atomic)
        }

        print("Mundane Timespine v1 candidate")
        print("codec: \(product.metadata.codec)")
        print("representation: \(MundaneTimespine.representation)")
        print("body files: \(artifacts.bodyArtifacts.count)")
        print("total bytes: \(artifacts.totalBytes)")
        print("manifest sha256: \(artifacts.manifestChecksum)")
        print("samples consumed: \(reference.consumedCount)")
        print("stations: \(motionChronologies.values.reduce(0) { $0 + $1.stations.count })")
    }

    private static func loadMotionChronologies(_ url: URL) throws -> [MundaneBody: MundaneMotionChronology] {
        let file = try JSONDecoder().decode(StationFile.self, from: Data(contentsOf: url))
        var result: [MundaneBody: MundaneMotionChronology] = [:]
        for body in MundaneBody.canonicalOrder {
            guard let record = file.bodies.first(where: { $0.body == body.displayName }),
                  let initial = Motion(rawValue: record.initialMotion) else { throw OrboForgeToolError.malformedStationFile }
            let stations: [MundaneStation] = try record.stations.map {
                guard let jd = JulianDay($0.julianDay), let motionAfter = Motion(rawValue: $0.motionAfter) else {
                    throw OrboForgeToolError.malformedStationFile
                }
                return MundaneStation(julianDay: jd, motionAfter: motionAfter)
            }
            guard let chronology = MundaneMotionChronology(initialMotion: initial, stations: stations) else {
                throw OrboForgeToolError.malformedStationFile
            }
            result[body] = chronology
        }
        return result
    }
}
