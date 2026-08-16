import Foundation
import OrboCore

enum OrboForgeToolError: Error, CustomStringConvertible {
    case missingArgument(String)
    case invalidArgument(String)
    case malformedSampleStream
    case unusedSamples(expected: Int, consumed: Int)

    var description: String {
        switch self {
        case let .missingArgument(name):
            return "Missing required argument: \(name)"
        case let .invalidArgument(value):
            return "Invalid argument: \(value)"
        case .malformedSampleStream:
            return "Swiss sample stream is not a whole sequence of little-endian Float64 values."
        case let .unusedSamples(expected, consumed):
            return "Sample stream cardinality mismatch: expected \(expected), consumed \(consumed)."
        }
    }
}

private final class SequentialSwissSampleReference: @unchecked Sendable, ForgeEphemerisReference {
    private let samples: [Double]
    private(set) var consumedCount = 0

    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        guard data.count.isMultiple(of: MemoryLayout<UInt64>.size) else {
            throw OrboForgeToolError.malformedSampleStream
        }

        let bytes = [UInt8](data)
        var values: [Double] = []
        values.reserveCapacity(bytes.count / 8)

        var offset = 0
        while offset < bytes.count {
            var bits: UInt64 = 0
            for byteOffset in 0..<8 {
                bits |= UInt64(bytes[offset + byteOffset]) << UInt64(byteOffset * 8)
            }
            let value = Double(bitPattern: bits)
            guard value.isFinite else {
                throw OrboForgeToolError.malformedSampleStream
            }
            values.append(value)
            offset += 8
        }
        self.samples = values
    }

    var sampleCount: Int {
        samples.count
    }

    func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneCelestialState {
        guard consumedCount < samples.count,
              let longitude = CelestialLongitude(samples[consumedCount]),
              let state = MundaneCelestialState(
                longitude: longitude,
                longitudinalSpeedDegreesPerDay: 0
              ) else {
            throw OrboForgeToolError.malformedSampleStream
        }
        consumedCount += 1
        return state
    }
}

private struct Arguments {
    let samples: URL
    let output: URL
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
            guard key.hasPrefix("--"), index + 1 < raw.count else {
                throw OrboForgeToolError.invalidArgument(key)
            }
            values[key] = raw[index + 1]
            index += 2
        }

        func require(_ key: String) throws -> String {
            guard let value = values[key], !value.isEmpty else {
                throw OrboForgeToolError.missingArgument(key)
            }
            return value
        }

        let samplesPath = try require("--samples")
        let outputPath = try require("--output")
        let version = try require("--version")
        let source = try require("--source")
        let sourceVersion = try require("--source-version")
        let startRaw = try require("--start-jd")
        let endRaw = try require("--end-jd")

        guard let startValue = Double(startRaw),
              let endValue = Double(endRaw),
              let start = JulianDay(startValue),
              let end = JulianDay(endValue),
              start.value < end.value else {
            throw OrboForgeToolError.invalidArgument("Julian Day range")
        }

        self.samples = URL(fileURLWithPath: samplesPath)
        self.output = URL(fileURLWithPath: outputPath)
        self.version = version
        self.source = source
        self.sourceVersion = sourceVersion
        self.startJulianDay = start
        self.endJulianDay = end
    }
}

private func expectedSampleCount(
    start: JulianDay,
    end: JulianDay,
    profiles: [MundaneTimespineProfile]
) -> Int {
    let span = end.value - start.value
    return profiles.reduce(0) { total, profile in
        let segments = Int(ceil(span / profile.segmentDays))
        return total + segments * (profile.polynomialDegree + 1)
    }
}

@main
struct OrboForgeTool {
    static func main() throws {
        let arguments = try Arguments(Array(CommandLine.arguments.dropFirst()))
        let profiles = MundaneTimespineForge.candidateProfiles
        let reference = try SequentialSwissSampleReference(url: arguments.samples)
        let expected = expectedSampleCount(
            start: arguments.startJulianDay,
            end: arguments.endJulianDay,
            profiles: profiles
        )
        guard reference.sampleCount == expected else {
            throw OrboForgeToolError.unusedSamples(
                expected: expected,
                consumed: reference.sampleCount
            )
        }

        guard let plan = MundaneTimespineForgePlan(
            version: arguments.version,
            astronomicalSource: arguments.source,
            astronomicalSourceVersion: arguments.sourceVersion,
            supportedStart: arguments.startJulianDay,
            supportedEnd: arguments.endJulianDay,
            profiles: profiles
        ) else {
            throw OrboForgeToolError.invalidArgument("Forge plan")
        }

        var cursor = MundaneTimespineForge.makeCursor(plan: plan)
        var lastPrintedPercent = -1
        while !cursor.isComplete {
            let progress = try cursor.step(reference: reference, segmentBudget: 2_048)
            let percent = Int((progress.fractionComplete * 100).rounded(.down))
            if percent != lastPrintedPercent, percent.isMultiple(of: 5) {
                let body = progress.currentBody?.displayName ?? "complete"
                print("Forge \(percent)% / \(body)")
                lastPrintedPercent = percent
            }
        }

        let product = try cursor.product()
        guard reference.consumedCount == expected else {
            throw OrboForgeToolError.unusedSamples(
                expected: expected,
                consumed: reference.consumedCount
            )
        }

        let artifact = product.encodedArtifact()
        try FileManager.default.createDirectory(
            at: arguments.output.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try artifact.write(to: arguments.output, options: .atomic)

        print("Mundane Timespine artifact")
        print("version: \(product.metadata.version)")
        print("codec: \(product.metadata.codec)")
        print("AstroDNA codec: \(product.metadata.astroDNACodec)")
        print("source: \(product.metadata.astronomicalSource)")
        print("source version: \(product.metadata.astronomicalSourceVersion)")
        print("range: \(product.supportedRangeDescription)")
        print("bytes: \(artifact.count)")
        print("sha256: \(product.checksum)")
        print("samples consumed: \(reference.consumedCount)")
    }
}
