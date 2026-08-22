import CryptoKit
import Foundation
import OrboCore

private enum MotionForgeError: Error, CustomStringConvertible {
    case malformed(String)
    case mismatch(String)
    case missing(String)

    var description: String {
        switch self {
        case let .malformed(message): return "Malformed C7 motion input: \(message)"
        case let .mismatch(message): return "C7 motion mismatch: \(message)"
        case let .missing(message): return "Missing C7 motion input: \(message)"
        }
    }
}

private struct Arguments {
    let buildRoot: URL

    init(_ raw: [String]) throws {
        guard raw.count == 2, raw[0] == "--build-root" else {
            throw MotionForgeError.malformed("usage: --build-root <tools/pass5/orbospine-build>")
        }
        buildRoot = URL(fileURLWithPath: raw[1], isDirectory: true).standardizedFileURL
    }
}

private struct CelestialBodyReference: Decodable {
    let body: String
    let stationRows: Int
    let stationFile: String
    let stationSHA256: String
}

private struct CelestialManifestReference: Decodable {
    let identity: String
    let supportedStartJulianDayUT: Double
    let supportedEndJulianDayUT: Double
    let totalStationRows: Int
    let bodies: [CelestialBodyReference]
}

private struct MotionBodyReport: Codable {
    let body: String
    let stationRows: Int
    let passageRows: Int
    let startsClipped: Bool
    let endsClipped: Bool
    let sourceStationFile: String
    let sourceStationSHA256: String
}

private struct MotionManifest: Codable {
    let identity: String
    let matterFormat: String
    let matterVersion: Int
    let source: String
    let sourceCelestialManifest: String
    let sourceCelestialManifestSHA256: String
    let supportedStartJulianDayUT: Double
    let supportedEndJulianDayUT: Double
    let sourceStationRows: Int
    let totalPassageRows: Int
    let passageFile: String
    let passageFileBytes: Int64
    let passageSHA256: String
    let bodies: [MotionBodyReport]
}

private enum MotionForge {
    private static let celestialManifestRelative = "celestial/orbospine-celestial-manifest.json"
    private static let motionDirectoryName = "motion"
    private static let passageFileName = "retrograde-passages.csv"
    private static let manifestFileName = "orbospine-motion-manifest.json"
    private static let stationHeader = "physical_degree,directional_degree_after,navigation_cell_after,lane_before,lane_after,jd_ut"
    private static let passageHeader = "body,start_jd_ut,end_jd_ut,start_station_physical_degree,end_station_physical_degree,start_boundary,end_boundary\n"

    static func run(_ raw: [String]) throws {
        let arguments = try Arguments(raw)
        let root = arguments.buildRoot
        let celestialManifestURL = root.appendingPathComponent(celestialManifestRelative)
        guard FileManager.default.fileExists(atPath: celestialManifestURL.path) else {
            throw MotionForgeError.missing(celestialManifestRelative)
        }

        let celestialData = try Data(contentsOf: celestialManifestURL)
        let celestial = try JSONDecoder().decode(CelestialManifestReference.self, from: celestialData)
        guard celestial.identity == OrboSpineContract.identity else {
            throw MotionForgeError.mismatch("celestial identity \(celestial.identity)")
        }
        guard same(celestial.supportedStartJulianDayUT, OrboSpineSchematic.supportedStart.value),
              same(celestial.supportedEndJulianDayUT, OrboSpineSchematic.supportedEnd.value) else {
            throw MotionForgeError.mismatch("celestial span is not canonical Z21-Z23")
        }
        guard celestial.totalStationRows == 52_679 else {
            throw MotionForgeError.mismatch("source station rows \(celestial.totalStationRows) != 52679")
        }
        guard celestial.bodies.count == MundaneBody.canonicalOrder.count else {
            throw MotionForgeError.mismatch("celestial manifest does not contain exactly the Eleven")
        }

        let span = try requireSpan()
        let motionDirectory = root.appendingPathComponent(motionDirectoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: motionDirectory, withIntermediateDirectories: true)
        let finalPassageURL = motionDirectory.appendingPathComponent(passageFileName)
        let temporaryPassageURL = motionDirectory.appendingPathComponent(".\(passageFileName).tmp")

        var output = passageHeader
        var bodyReports: [MotionBodyReport] = []
        var totalPassages = 0
        var observedStationRows = 0

        for body in MundaneBody.canonicalOrder {
            guard let declared = celestial.bodies.first(where: { $0.body == body.displayName }) else {
                throw MotionForgeError.missing("celestial body report for \(body.displayName)")
            }

            let stationRelative = "celestial/\(declared.stationFile)"
            let stationURL = root.appendingPathComponent(stationRelative)
            guard FileManager.default.fileExists(atPath: stationURL.path) else {
                throw MotionForgeError.missing(stationRelative)
            }
            let stationHash = try sha256(stationURL)
            guard stationHash == declared.stationSHA256 else {
                throw MotionForgeError.mismatch("\(body.displayName) station SHA-256 drift")
            }

            let stations = try loadStations(body: body, url: stationURL)
            guard stations.count == declared.stationRows else {
                throw MotionForgeError.mismatch(
                    "\(body.displayName) station rows \(stations.count) != declared \(declared.stationRows)"
                )
            }
            observedStationRows += stations.count

            guard let passages = OrboSpineMotionBody.retrogradePassages(
                body: body,
                stations: stations,
                span: span
            ) else {
                throw MotionForgeError.mismatch("\(body.displayName) station topology does not derive clean motion")
            }

            for passage in passages {
                output += [
                    body.displayName,
                    decimal(passage.start.value),
                    decimal(passage.end.value),
                    passage.startStationPhysicalDegrees.map(decimal) ?? "",
                    passage.endStationPhysicalDegrees.map(decimal) ?? "",
                    passage.startBoundary.rawValue,
                    passage.endBoundary.rawValue,
                ].joined(separator: ",") + "\n"
            }

            bodyReports.append(MotionBodyReport(
                body: body.displayName,
                stationRows: stations.count,
                passageRows: passages.count,
                startsClipped: passages.first?.startBoundary == .spineStart,
                endsClipped: passages.last?.endBoundary == .spineEnd,
                sourceStationFile: declared.stationFile,
                sourceStationSHA256: declared.stationSHA256
            ))
            totalPassages += passages.count
        }

        guard observedStationRows == celestial.totalStationRows else {
            throw MotionForgeError.mismatch("observed station total \(observedStationRows) != declared \(celestial.totalStationRows)")
        }

        try Data(output.utf8).write(to: temporaryPassageURL, options: .atomic)
        try installAtomically(temporaryPassageURL, at: finalPassageURL)
        let passageHash = try sha256(finalPassageURL)
        let passageBytes = try fileSize(finalPassageURL)

        let manifest = MotionManifest(
            identity: OrboSpineContract.identity,
            matterFormat: "retrograde-passage-csv",
            matterVersion: 1,
            source: "final C4 exact station topology",
            sourceCelestialManifest: celestialManifestRelative,
            sourceCelestialManifestSHA256: try sha256(celestialManifestURL),
            supportedStartJulianDayUT: span.start.value,
            supportedEndJulianDayUT: span.end.value,
            sourceStationRows: observedStationRows,
            totalPassageRows: totalPassages,
            passageFile: passageFileName,
            passageFileBytes: passageBytes,
            passageSHA256: passageHash,
            bodies: bodyReports
        )
        let manifestURL = motionDirectory.appendingPathComponent(manifestFileName)
        try writeJSON(manifest, to: manifestURL)

        print("ORBOSPINE C7 / MOTION BODY")
        print("PASS source stations: \(observedStationRows)")
        print("PASS retrograde passages: \(totalPassages)")
        print("PASS span: one continuous Z21-Z23 body / no artificial Z splits")
        print("motion table: \(finalPassageURL.path)")
        print("motion SHA-256: \(passageHash)")
        print("motion manifest: \(manifestURL.path)")
        print("C7 MOTION BODY: COMPLETE")
    }

    private static func requireSpan() throws -> OrboSpineBoneSpan {
        guard let span = OrboSpineBoneSpan(
            start: OrboSpineSchematic.supportedStart,
            end: OrboSpineSchematic.supportedEnd
        ) else {
            throw MotionForgeError.mismatch("canonical Bone span is invalid")
        }
        return span
    }

    private static func loadStations(body: MundaneBody, url: URL) throws -> [OrboSpineStation] {
        let text = try String(contentsOf: url, encoding: .utf8)
        let lines = text.split(whereSeparator: \.isNewline)
        guard let first = lines.first, String(first) == stationHeader else {
            throw MotionForgeError.malformed("unexpected station header for \(body.displayName)")
        }

        var stations: [OrboSpineStation] = []
        stations.reserveCapacity(max(lines.count - 1, 0))

        for (lineNumber, rawLine) in lines.dropFirst().enumerated() {
            let fields = rawLine.split(separator: ",", omittingEmptySubsequences: false)
            guard fields.count == 6,
                  let physical = Double(fields[0]),
                  let declaredDirectional = Double(fields[1]),
                  let declaredCell = Int(fields[2]),
                  let laneBefore = Motion(rawValue: String(fields[3])),
                  let laneAfter = Motion(rawValue: String(fields[4])),
                  let jdValue = Double(fields[5]),
                  let jd = JulianDay(jdValue),
                  let station = OrboSpineStation(
                    body: body,
                    physicalDegrees: physical,
                    julianDay: jd,
                    laneBefore: laneBefore,
                    laneAfter: laneAfter
                  ) else {
                throw MotionForgeError.malformed("\(body.displayName) station row \(lineNumber + 2)")
            }

            guard same(station.directionalDegreeAfter.degrees, declaredDirectional),
                  station.navigationCellAfter == declaredCell else {
                throw MotionForgeError.mismatch("\(body.displayName) station directional projection drift at row \(lineNumber + 2)")
            }
            stations.append(station)
        }

        return stations
    }

    private static func installAtomically(_ temporary: URL, at final: URL) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: final.path) {
            _ = try fileManager.replaceItemAt(final, withItemAt: temporary)
        } else {
            try fileManager.moveItem(at: temporary, to: final)
        }
    }

    private static func sha256(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            let chunk = try handle.read(upToCount: 1_048_576) ?? Data()
            if chunk.isEmpty { break }
            hasher.update(data: chunk)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private static func fileSize(_ url: URL) throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let value = attributes[.size] as? NSNumber else {
            throw MotionForgeError.malformed("missing file size for \(url.path)")
        }
        return value.int64Value
    }

    private static func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try encoder.encode(value).write(to: url, options: .atomic)
    }

    private static func decimal(_ value: Double) -> String {
        String(format: "%.17g", locale: Locale(identifier: "en_US_POSIX"), value)
    }

    private static func same(_ lhs: Double, _ rhs: Double) -> Bool {
        abs(lhs - rhs) < 1e-12
    }
}

do {
    try MotionForge.run(Array(CommandLine.arguments.dropFirst()))
} catch {
    let message = "OrboSpineMotionForgeTool error: \(error)\n"
    FileHandle.standardError.write(Data(message.utf8))
    exit(EXIT_FAILURE)
}
