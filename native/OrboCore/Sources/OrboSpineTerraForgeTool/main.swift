import CryptoKit
import Foundation
import OrboCore
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

private typealias TerraSweSidtime = @convention(c) (Double) -> Double
private typealias TerraSweCalcUT = @convention(c) (
    Double,
    Int32,
    Int32,
    UnsafeMutablePointer<Double>?,
    UnsafeMutablePointer<CChar>?
) -> Int32
private typealias TerraSweVersion = @convention(c) (UnsafeMutablePointer<CChar>?) -> UnsafePointer<CChar>?

enum OrboSpineTerraForgeError: Error, CustomStringConvertible {
    case releaseBuildRequired
    case missingArgument(String)
    case swissLibrary(String)
    case swissSymbol(String)
    case swissVersionDrift(actual: String, expected: String)
    case swissCalculation(String)
    case malformed(String)
    case output(String)

    var description: String {
        switch self {
        case .releaseBuildRequired:
            return "Canonical Terra Marrow manufacture requires a release build."
        case let .missingArgument(name):
            return "Missing required argument: \(name)"
        case let .swissLibrary(message):
            return "Swiss Ephemeris library error: \(message)"
        case let .swissSymbol(name):
            return "Missing Swiss Ephemeris symbol: \(name)"
        case let .swissVersionDrift(actual, expected):
            return "Swiss C version drift: \(actual) != \(expected)"
        case let .swissCalculation(message):
            return "Swiss Ephemeris Terra calculation failed: \(message)"
        case let .malformed(message):
            return "Malformed Terra Marrow manufacture: \(message)"
        case let .output(message):
            return "Terra Marrow output error: \(message)"
        }
    }
}

private struct TerraForgeArguments {
    let libraryPath: String
    let outputDirectory: URL

    init(_ raw: [String]) throws {
        var values: [String: String] = [:]
        var index = 0
        while index < raw.count {
            let key = raw[index]
            guard key.hasPrefix("--"), index + 1 < raw.count else {
                throw OrboSpineTerraForgeError.missingArgument(key)
            }
            values[key] = raw[index + 1]
            index += 2
        }

        guard let library = values["--library"], !library.isEmpty else {
            throw OrboSpineTerraForgeError.missingArgument("--library")
        }
        guard let output = values["--output-dir"], !output.isEmpty else {
            throw OrboSpineTerraForgeError.missingArgument("--output-dir")
        }

        libraryPath = library
        outputDirectory = URL(fileURLWithPath: output, isDirectory: true)
    }
}

private final class TerraSwissReference {
    private let handle: UnsafeMutableRawPointer
    private let sidtime: TerraSweSidtime
    private let calculateUT: TerraSweCalcUT
    let version: String

    private static let eclipticAndNutationBody: Int32 = -1

    init(libraryPath: String) throws {
        guard let opened = dlopen(libraryPath, RTLD_NOW | RTLD_LOCAL) else {
            let message = dlerror().map { String(cString: $0) } ?? "unknown dlopen failure"
            throw OrboSpineTerraForgeError.swissLibrary(message)
        }
        handle = opened

        func symbol<T>(_ name: String, as type: T.Type) throws -> T {
            guard let pointer = dlsym(opened, name) else {
                throw OrboSpineTerraForgeError.swissSymbol(name)
            }
            return unsafeBitCast(pointer, to: T.self)
        }

        sidtime = try symbol("swe_sidtime", as: TerraSweSidtime.self)
        calculateUT = try symbol("swe_calc_ut", as: TerraSweCalcUT.self)
        let versionFunction: TerraSweVersion = try symbol("swe_version", as: TerraSweVersion.self)

        var buffer = [CChar](repeating: 0, count: 128)
        _ = buffer.withUnsafeMutableBufferPointer { versionFunction($0.baseAddress) }
        version = String(cString: buffer)
    }

    deinit {
        dlclose(handle)
    }

    func sample(at julianDayUT: Double) throws -> TerraMarrowSample {
        var turn = (sidtime(julianDayUT) * 15).truncatingRemainder(dividingBy: 360)
        if turn < 0 { turn += 360 }
        if turn >= 360 { turn = 0 }

        var values = [Double](repeating: 0, count: 6)
        var errorBuffer = [CChar](repeating: 0, count: 256)
        let returned = values.withUnsafeMutableBufferPointer { output in
            errorBuffer.withUnsafeMutableBufferPointer { error in
                calculateUT(
                    julianDayUT,
                    Self.eclipticAndNutationBody,
                    0,
                    output.baseAddress,
                    error.baseAddress
                )
            }
        }

        guard returned >= 0,
              let julianDay = JulianDay(julianDayUT),
              let sample = TerraMarrowSample(
                turnDegrees: turn,
                tiltDegrees: values[0],
                julianDay: julianDay
              ) else {
            let message = String(cString: errorBuffer)
            throw OrboSpineTerraForgeError.swissCalculation(
                message.isEmpty ? "invalid turn/tilt at JD \(julianDayUT)" : message
            )
        }
        return sample
    }
}

private enum TerraSampleKind: String {
    case support
    case endGuard = "end_guard"
    case seamExactLongTerm = "seam_exact_long_term"
    case seamRightShortTerm = "seam_right_short_term"
    case seamLeftShortTerm = "seam_left_short_term"
}

private struct TerraSeed {
    let julianDayUT: Double
    let kind: TerraSampleKind
}

private struct TerraSpanReport: Codable {
    let zeitgeist: String
    let startJulianDayUT: Double
    let endJulianDayUT: Double
    let startUTC: String
    let endUTC: String
    let file: String
    let rows: Int
    let supportRows: Int
    let seamRows: Int
    let boundaryGuardRows: Int
    let bytes: Int64
    let sha256: String
}

private struct TerraSeamReport: Codable {
    let year: Int
    let julianDayUT: Double
    let boundaryOwnership: String
    let adjacentSide: String
    let adjacentJulianDayUT: Double
    let signedTurnJumpArcSeconds: Double
    let signedTiltJumpArcSeconds: Double
}

private struct TerraManifest: Codable {
    let identity: String
    let matter: String
    let matterFormat: String
    let matterVersion: Int
    let span: String
    let supportedStartJulianDayUT: Double
    let supportedEndJulianDayUT: Double
    let supportIntervalSeconds: Int
    let refinementLaw: String
    let turnLaw: String
    let tiltLaw: String
    let sourceModelSeamLaw: String
    let swissRepository: String
    let swissCommit: String
    let swissVersion: String
    let swissLibrarySHA256: String
    let de441Dependency: String
    let spans: [TerraSpanReport]
    let sourceModelSeams: [TerraSeamReport]
    let totalRows: Int
    let runtimeStorage: String
    let status: String
}

private final class TerraBufferedCSVWriter {
    private let handle: FileHandle
    private var buffer = Data()
    private let flushThreshold = 1_048_576

    init(url: URL) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        guard fileManager.createFile(atPath: url.path, contents: nil) else {
            throw OrboSpineTerraForgeError.output("could not create \(url.path)")
        }
        handle = try FileHandle(forWritingTo: url)
        try append("jd_ut,turn_degrees,tilt_degrees,sample_kind\n")
    }

    func append(_ line: String) throws {
        buffer.append(contentsOf: line.utf8)
        if buffer.count >= flushThreshold {
            try flush()
        }
    }

    func finish() throws {
        try flush()
        try handle.close()
    }

    private func flush() throws {
        guard !buffer.isEmpty else { return }
        try handle.write(contentsOf: buffer)
        buffer.removeAll(keepingCapacity: true)
    }
}

enum OrboSpineTerraForge {
    private static let matterVersion = 1
    private static let sixHoursDays = 0.25
    private static let swissRepository = "https://github.com/huntarfischer/swisseph.git"
    private static let swissCommit = "3fd0f956d73898b91cc4f67cf18b21af656d1342"

    // Swiss Ephemeris 2.10.03 swephlib.c SIDT_LTERM_T0 / SIDT_LTERM_T1.
    // The default long-term sidereal model owns the exact boundary instants;
    // the short-term branch is used strictly between them.
    private static let siderealSeam1850 = 2_396_758.5
    private static let siderealSeam2050 = 2_469_807.5

    private static let expectedRows: [Int: Int] = [
        21: 357_863,
        22: 356_734,
        23: 357_905,
    ]

    static func run(_ raw: [String]) throws {
        #if DEBUG
        throw OrboSpineTerraForgeError.releaseBuildRequired
        #else
        let arguments = try TerraForgeArguments(raw)
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: arguments.outputDirectory, withIntermediateDirectories: true)

        let libraryURL = URL(fileURLWithPath: arguments.libraryPath).standardizedFileURL
        guard fileManager.fileExists(atPath: libraryURL.path) else {
            throw OrboSpineTerraForgeError.swissLibrary("library file not found at \(libraryURL.path)")
        }

        let librarySHA256 = try sha256(libraryURL)
        let reference = try TerraSwissReference(libraryPath: libraryURL.path)
        let expectedVersion = OrboSpineManufactureContract.canonicalAstronomicalSourceVersion
        guard reference.version == expectedVersion else {
            throw OrboSpineTerraForgeError.swissVersionDrift(actual: reference.version, expected: expectedVersion)
        }

        try validateSourceSeamsInsideBone()

        print("ORBO FORGE / TERRA MARROW")
        print("Swiss Ephemeris: \(reference.version)")
        print("Swiss source commit: \(swissCommit)")
        print("Swiss library SHA-256: \(librarySHA256)")
        print("span: Z21 -> Z22 -> Z23")
        print("support: 6 hours")
        print("turn: swe_sidtime(UT) * 15")
        print("tilt: swe_calc_ut(SE_ECL_NUT)[0] true obliquity")
        print("sidereal seams: 1850 / 2050 preserved one-sided; no interpolation across")

        var spanReports: [TerraSpanReport] = []
        for span in OrboSpineManufactureContract.zeitgeists {
            spanReports.append(
                try forgeSpan(span, reference: reference, outputRoot: arguments.outputDirectory)
            )
        }

        let seamReports = try manufactureSeamReports(reference: reference)
        let totalRows = spanReports.reduce(0) { $0 + $1.rows }
        guard totalRows == 1_072_502 else {
            throw OrboSpineTerraForgeError.malformed("Terra row total \(totalRows) != 1072502")
        }

        let manifest = TerraManifest(
            identity: OrboSpineContract.identity,
            matter: "Terra Marrow",
            matterFormat: "terra-marrow-csv",
            matterVersion: matterVersion,
            span: "Z21-Z23",
            supportedStartJulianDayUT: OrboSpineManufactureContract.supportedStart.value,
            supportedEndJulianDayUT: OrboSpineManufactureContract.supportedEnd.value,
            supportIntervalSeconds: TerraMarrowContract.supportIntervalSeconds,
            refinementLaw: TerraMarrowContract.refinementLaw.rawValue,
            turnLaw: "normalize(swe_sidtime(jd_ut) * 15 degrees) in [0,360)",
            tiltLaw: "swe_calc_ut(jd_ut, SE_ECL_NUT, 0)[0] true ecliptic obliquity",
            sourceModelSeamLaw: "Swiss default long-term sidereal branch owns JD 2396758.5 and 2469807.5 exactly; short-term branch is strictly between; one-sided samples prevent interpolation through either discontinuity",
            swissRepository: swissRepository,
            swissCommit: swissCommit,
            swissVersion: reference.version,
            swissLibrarySHA256: librarySHA256,
            de441Dependency: "none; Terra Marrow is Swiss Earth-orientation/frame data, not a DE441 celestial tract",
            spans: spanReports,
            sourceModelSeams: seamReports,
            totalRows: totalRows,
            runtimeStorage: "none / Pass D",
            status: "C5 Terra Marrow forged; runtime interpolation/indexing, Dioscuri certification, adversarial proof, and final seal remain pending"
        )

        let manifestURL = arguments.outputDirectory.appendingPathComponent("terra-marrow-manifest.json")
        try writeJSON(manifest, to: manifestURL)

        print("Terra Marrow complete")
        print("rows: \(totalRows)")
        for seam in seamReports {
            print(String(
                format: "seam %d: turn jump %.6f arcsec / tilt jump %.6f arcsec",
                seam.year,
                seam.signedTurnJumpArcSeconds,
                seam.signedTiltJumpArcSeconds
            ))
        }
        print("manifest: \(manifestURL.path)")
        print("status: Terra Marrow forged into OrboSpine build")
        #endif
    }

    private static func forgeSpan(
        _ span: OrboSpineZeitgeistSpan,
        reference: TerraSwissReference,
        outputRoot: URL
    ) throws -> TerraSpanReport {
        let ordinal = span.shell.ordinal
        let directory = outputRoot.appendingPathComponent("z\(ordinal)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let finalURL = directory.appendingPathComponent("terra-marrow.csv")
        let temporaryURL = directory.appendingPathComponent(".terra-marrow.csv.tmp")
        let seeds = try makeSeeds(for: span)

        guard seeds.count == expectedRows[ordinal] else {
            throw OrboSpineTerraForgeError.malformed(
                "Z\(ordinal) row plan \(seeds.count) != \(expectedRows[ordinal] ?? -1)"
            )
        }

        print("forge Terra Z\(ordinal): \(seeds.count) rows")
        let writer = try TerraBufferedCSVWriter(url: temporaryURL)
        var previousJD = -Double.infinity
        var supportRows = 0
        var seamRows = 0
        var guardRows = 0

        for (index, seed) in seeds.enumerated() {
            guard seed.julianDayUT > previousJD else {
                throw OrboSpineTerraForgeError.malformed("Z\(ordinal) non-monotonic JD at row \(index + 1)")
            }
            previousJD = seed.julianDayUT

            let sample = try reference.sample(at: seed.julianDayUT)
            try writer.append(
                "\(format(sample.julianDay.value)),\(format(sample.turnDegrees)),\(format(sample.tiltDegrees)),\(seed.kind.rawValue)\n"
            )

            switch seed.kind {
            case .support: supportRows += 1
            case .endGuard: guardRows += 1
            case .seamExactLongTerm, .seamRightShortTerm, .seamLeftShortTerm: seamRows += 1
            }

            if (index + 1) % 100_000 == 0 {
                print("  Terra Z\(ordinal): \(index + 1) / \(seeds.count)")
            }
        }
        try writer.finish()

        guard guardRows == 1,
              abs(seeds[0].julianDayUT - span.start.value) < 1e-12,
              abs(seeds[seeds.count - 1].julianDayUT - span.end.value) < 1e-12,
              seeds[seeds.count - 1].kind == .endGuard else {
            throw OrboSpineTerraForgeError.malformed("Z\(ordinal) boundary support contract failed")
        }
        if ordinal == 22 {
            guard seamRows == 4 else {
                throw OrboSpineTerraForgeError.malformed("Z22 seam row count \(seamRows) != 4")
            }
        } else if seamRows != 0 {
            throw OrboSpineTerraForgeError.malformed("Z\(ordinal) unexpectedly contains seam rows")
        }

        try installAtomically(temporaryURL, at: finalURL)
        let hash = try sha256(finalURL)
        let bytes = try fileSize(finalURL)

        print("  wrote Terra Z\(ordinal): \(seeds.count) rows")
        print("  SHA-256: \(hash)")

        return TerraSpanReport(
            zeitgeist: "Z\(ordinal)",
            startJulianDayUT: span.start.value,
            endJulianDayUT: span.end.value,
            startUTC: span.startUTC,
            endUTC: span.endUTC,
            file: "z\(ordinal)/terra-marrow.csv",
            rows: seeds.count,
            supportRows: supportRows,
            seamRows: seamRows,
            boundaryGuardRows: guardRows,
            bytes: bytes,
            sha256: hash
        )
    }

    private static func makeSeeds(for span: OrboSpineZeitgeistSpan) throws -> [TerraSeed] {
        var seeds: [TerraSeed] = []
        var index = 0
        while true {
            let jd = span.start.value + Double(index) * sixHoursDays
            if jd >= span.end.value { break }
            seeds.append(TerraSeed(julianDayUT: jd, kind: .support))
            index += 1
        }
        seeds.append(TerraSeed(julianDayUT: span.end.value, kind: .endGuard))

        if span.shell.ordinal == 22 {
            upsertSpecial(
                TerraSeed(julianDayUT: siderealSeam1850, kind: .seamExactLongTerm),
                into: &seeds
            )
            upsertSpecial(
                TerraSeed(julianDayUT: siderealSeam1850.nextUp, kind: .seamRightShortTerm),
                into: &seeds
            )
            upsertSpecial(
                TerraSeed(julianDayUT: siderealSeam2050.nextDown, kind: .seamLeftShortTerm),
                into: &seeds
            )
            upsertSpecial(
                TerraSeed(julianDayUT: siderealSeam2050, kind: .seamExactLongTerm),
                into: &seeds
            )
        }

        seeds.sort { left, right in
            left.julianDayUT < right.julianDayUT
        }
        return seeds
    }

    private static func upsertSpecial(_ special: TerraSeed, into seeds: inout [TerraSeed]) {
        if let index = seeds.firstIndex(where: { $0.julianDayUT == special.julianDayUT }) {
            seeds[index] = special
        } else {
            seeds.append(special)
        }
    }

    private static func validateSourceSeamsInsideBone() throws {
        let z22 = OrboSpineManufactureContract.z22
        guard siderealSeam1850 > z22.start.value,
              siderealSeam1850 < siderealSeam2050,
              siderealSeam2050 < z22.end.value else {
            throw OrboSpineTerraForgeError.malformed("Swiss sidereal seams do not lie inside Z22")
        }
    }

    private static func manufactureSeamReports(reference: TerraSwissReference) throws -> [TerraSeamReport] {
        let exact1850 = try reference.sample(at: siderealSeam1850)
        let right1850 = try reference.sample(at: siderealSeam1850.nextUp)
        let left2050 = try reference.sample(at: siderealSeam2050.nextDown)
        let exact2050 = try reference.sample(at: siderealSeam2050)

        return [
            TerraSeamReport(
                year: 1850,
                julianDayUT: siderealSeam1850,
                boundaryOwnership: "long-term branch at exact boundary",
                adjacentSide: "right / short-term",
                adjacentJulianDayUT: siderealSeam1850.nextUp,
                signedTurnJumpArcSeconds: angularDifferenceDegrees(
                    from: exact1850.turnDegrees,
                    to: right1850.turnDegrees
                ) * 3600,
                signedTiltJumpArcSeconds: (right1850.tiltDegrees - exact1850.tiltDegrees) * 3600
            ),
            TerraSeamReport(
                year: 2050,
                julianDayUT: siderealSeam2050,
                boundaryOwnership: "long-term branch at exact boundary",
                adjacentSide: "left / short-term",
                adjacentJulianDayUT: siderealSeam2050.nextDown,
                signedTurnJumpArcSeconds: angularDifferenceDegrees(
                    from: left2050.turnDegrees,
                    to: exact2050.turnDegrees
                ) * 3600,
                signedTiltJumpArcSeconds: (exact2050.tiltDegrees - left2050.tiltDegrees) * 3600
            ),
        ]
    }

    private static func angularDifferenceDegrees(from start: Double, to end: Double) -> Double {
        var difference = (end - start).truncatingRemainder(dividingBy: 360)
        if difference > 180 { difference -= 360 }
        if difference <= -180 { difference += 360 }
        return difference
    }

    private static func format(_ value: Double) -> String {
        String(format: "%.15f", value)
    }

    private static func fileSize(_ url: URL) throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let number = attributes[.size] as? NSNumber else {
            throw OrboSpineTerraForgeError.output("could not read size of \(url.path)")
        }
        return number.int64Value
    }

    private static func sha256(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            let data = try handle.read(upToCount: 1_048_576) ?? Data()
            if data.isEmpty { break }
            hasher.update(data: data)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private static func installAtomically(_ temporary: URL, at final: URL) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: final.path) {
            _ = try fileManager.replaceItemAt(final, withItemAt: temporary)
        } else {
            try fileManager.moveItem(at: temporary, to: final)
        }
    }

    private static func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(value)
        let temporary = url.deletingLastPathComponent().appendingPathComponent(".\(url.lastPathComponent).tmp")
        try data.write(to: temporary, options: .atomic)
        try installAtomically(temporary, at: url)
    }
}

do {
    try OrboSpineTerraForge.run(Array(CommandLine.arguments.dropFirst()))
} catch {
    let message = "OrboSpineTerraForgeTool error: \(error)\n"
    FileHandle.standardError.write(Data(message.utf8))
    exit(EXIT_FAILURE)
}
