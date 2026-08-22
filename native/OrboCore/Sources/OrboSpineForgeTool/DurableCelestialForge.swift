import CryptoKit
import Foundation
import OrboCore
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

private typealias OrboSpineSweSetEphePath = @convention(c) (UnsafePointer<CChar>?) -> Void
private typealias OrboSpineSweCalcUT = @convention(c) (Double, Int32, Int32, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<CChar>?) -> Int32
private typealias OrboSpineSweVersion = @convention(c) (UnsafeMutablePointer<CChar>?) -> UnsafePointer<CChar>?

enum OrboSpineCelestialForgeError: Error, CustomStringConvertible {
    case releaseBuildRequired
    case missingArgument(String)
    case swissLibrary(String)
    case swissSymbol(String)
    case swissCalculation(String)
    case swissVersionDrift(actual: String, expected: String)
    case missingEphemerisFile(String)
    case nonDE441EphemerisFile(String)
    case malformedProduct(String)
    case checkpoint(String)
    case output(String)

    var description: String {
        switch self {
        case .releaseBuildRequired:
            return "Canonical OrboSpine manufacture requires a release build."
        case let .missingArgument(name):
            return "Missing required argument: \(name)"
        case let .swissLibrary(message):
            return "Swiss Ephemeris library error: \(message)"
        case let .swissSymbol(name):
            return "Missing Swiss Ephemeris symbol: \(name)"
        case let .swissCalculation(message):
            return "Swiss Ephemeris calculation failed: \(message)"
        case let .swissVersionDrift(actual, expected):
            return "Swiss C version drift: \(actual) != \(expected)"
        case let .missingEphemerisFile(name):
            return "Missing required DE441 Swiss file: \(name)"
        case let .nonDE441EphemerisFile(name):
            return "\(name) is not a DE441-generation Swiss file."
        case let .malformedProduct(message):
            return "Malformed OrboSpine celestial manufacture: \(message)"
        case let .checkpoint(message):
            return "OrboSpine celestial checkpoint error: \(message)"
        case let .output(message):
            return "OrboSpine celestial output error: \(message)"
        }
    }
}

private struct OrboSpineCelestialForgeArguments {
    let libraryPath: String
    let ephemerisDirectory: URL
    let outputDirectory: URL

    init(_ raw: [String]) throws {
        var values: [String: String] = [:]
        var index = 0
        while index < raw.count {
            let key = raw[index]
            guard key.hasPrefix("--"), index + 1 < raw.count else {
                throw OrboSpineCelestialForgeError.missingArgument(key)
            }
            values[key] = raw[index + 1]
            index += 2
        }

        guard let library = values["--library"], !library.isEmpty else {
            throw OrboSpineCelestialForgeError.missingArgument("--library")
        }
        guard let ephemeris = values["--ephe-dir"], !ephemeris.isEmpty else {
            throw OrboSpineCelestialForgeError.missingArgument("--ephe-dir")
        }
        guard let output = values["--output-dir"], !output.isEmpty else {
            throw OrboSpineCelestialForgeError.missingArgument("--output-dir")
        }

        libraryPath = library
        ephemerisDirectory = URL(fileURLWithPath: ephemeris, isDirectory: true)
        outputDirectory = URL(fileURLWithPath: output, isDirectory: true)
    }
}

private final class OrboSpineSwissReference: @unchecked Sendable, ForgeEphemerisReference {
    private let handle: UnsafeMutableRawPointer
    private let calculateUT: OrboSpineSweCalcUT
    let version: String

    private static let swissEphemerisFlag: Int32 = 2
    private static let moshierFlag: Int32 = 4
    private static let speedFlag: Int32 = 256

    init(libraryPath: String, ephemerisDirectory: URL) throws {
        guard let opened = dlopen(libraryPath, RTLD_NOW | RTLD_LOCAL) else {
            let message = dlerror().map { String(cString: $0) } ?? "unknown dlopen failure"
            throw OrboSpineCelestialForgeError.swissLibrary(message)
        }
        handle = opened

        func symbol<T>(_ name: String, as type: T.Type) throws -> T {
            guard let pointer = dlsym(opened, name) else {
                throw OrboSpineCelestialForgeError.swissSymbol(name)
            }
            return unsafeBitCast(pointer, to: T.self)
        }

        let setPath: OrboSpineSweSetEphePath = try symbol("swe_set_ephe_path", as: OrboSpineSweSetEphePath.self)
        calculateUT = try symbol("swe_calc_ut", as: OrboSpineSweCalcUT.self)
        let versionFunction: OrboSpineSweVersion = try symbol("swe_version", as: OrboSpineSweVersion.self)

        ephemerisDirectory.path.withCString { setPath($0) }
        var buffer = [CChar](repeating: 0, count: 128)
        _ = buffer.withUnsafeMutableBufferPointer { versionFunction($0.baseAddress) }
        version = String(cString: buffer)
    }

    deinit { dlclose(handle) }

    func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneForgeState {
        let swissBody: Int32
        switch body {
        case .sun: swissBody = 0
        case .moon: swissBody = 1
        case .mercury: swissBody = 2
        case .venus: swissBody = 3
        case .mars: swissBody = 4
        case .jupiter: swissBody = 5
        case .saturn: swissBody = 6
        case .uranus: swissBody = 7
        case .neptune: swissBody = 8
        case .pluto: swissBody = 9
        case .trueNorthNode: swissBody = 11
        }

        var values = [Double](repeating: 0, count: 6)
        var errorBuffer = [CChar](repeating: 0, count: 256)
        let flags = Self.swissEphemerisFlag | Self.speedFlag
        let returned = values.withUnsafeMutableBufferPointer { output in
            errorBuffer.withUnsafeMutableBufferPointer { error in
                calculateUT(julianDay.value, swissBody, flags, output.baseAddress, error.baseAddress)
            }
        }

        guard returned >= 0,
              (returned & Self.swissEphemerisFlag) != 0,
              (returned & Self.moshierFlag) == 0,
              let state = MundaneForgeState(
                longitudeDegrees: values[0],
                longitudinalSpeedDegreesPerDay: values[3]
              ) else {
            throw OrboSpineCelestialForgeError.swissCalculation(String(cString: errorBuffer))
        }
        return state
    }
}

private struct OrboSpineEphemerisFileReport: Codable {
    let name: String
    let bytes: Int64
}

private struct OrboSpineZeitgeistReport: Codable {
    let shell: String
    let startJulianDayUT: Double
    let endJulianDayUT: Double
    let startUTC: String
    let endUTC: String

    init(_ value: OrboSpineZeitgeistSpan) {
        shell = value.shell.description
        startJulianDayUT = value.start.value
        endJulianDayUT = value.end.value
        startUTC = value.startUTC
        endUTC = value.endUTC
    }
}

private struct OrboSpineCelestialBodyReport: Codable {
    let body: String
    let supportDegrees: Double
    let supportRows: Int
    let stationRows: Int
    let astronomicalSourceVersion: String
    let supportedStartJulianDayUT: Double
    let supportedEndJulianDayUT: Double
    let supportFile: String
    let supportFileBytes: Int64
    let supportSHA256: String
    let stationFile: String
    let stationFileBytes: Int64
    let stationSHA256: String
}

private struct OrboSpineCelestialCheckpoint: Codable {
    let identity: String
    let checkpointVersion: Int
    let matterFormat: String
    let matterVersion: Int
    let astronomicalSource: String
    let astronomicalSourceVersion: String
    let supportedStartJulianDayUT: Double
    let supportedEndJulianDayUT: Double
    var completedBodies: [OrboSpineCelestialBodyReport]
}

private struct OrboSpineCelestialManifest: Codable {
    let identity: String
    let matterFormat: String
    let matterVersion: Int
    let astronomicalSource: String
    let astronomicalSourceVersion: String
    let supportedStartJulianDayUT: Double
    let supportedEndJulianDayUT: Double
    let zeitgeists: [OrboSpineZeitgeistReport]
    let ephemerisFiles: [OrboSpineEphemerisFileReport]
    let bodies: [OrboSpineCelestialBodyReport]
    let totalSupportRows: Int
    let totalStationRows: Int
    let checkpointFile: String
    let runtimeStorage: String
}

private final class OrboSpineBufferedCSVWriter {
    private let handle: FileHandle
    private var buffer = Data()
    private let flushThreshold = 1_048_576

    init(url: URL, header: String) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        guard fileManager.createFile(atPath: url.path, contents: nil) else {
            throw OrboSpineCelestialForgeError.output("could not create \(url.path)")
        }
        handle = try FileHandle(forWritingTo: url)
        try append(header)
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

enum OrboSpineDurableCelestialForge {
    private static let checkpointFileName = "orbospine-celestial-checkpoint.json"
    private static let manifestFileName = "orbospine-celestial-manifest.json"
    private static let matterFormat = "directional-degree-csv"
    private static let matterVersion = 1
    private static let checkpointVersion = 1

    private static let requiredDE441Files = [
        "seplm36.se1", "seplm30.se1", "seplm24.se1", "seplm18.se1", "seplm12.se1", "seplm06.se1",
        "sepl_00.se1", "sepl_06.se1", "sepl_12.se1", "sepl_18.se1", "sepl_24.se1",
        "semom36.se1", "semom30.se1", "semom24.se1", "semom18.se1", "semom12.se1", "semom06.se1",
        "semo_00.se1", "semo_06.se1", "semo_12.se1", "semo_18.se1", "semo_24.se1",
    ]

    static func run(_ raw: [String]) throws {
        #if DEBUG
        throw OrboSpineCelestialForgeError.releaseBuildRequired
        #else
        let arguments = try OrboSpineCelestialForgeArguments(raw)
        try FileManager.default.createDirectory(
            at: arguments.outputDirectory,
            withIntermediateDirectories: true
        )

        let ephemerisFiles = try validateDE441Directory(arguments.ephemerisDirectory)
        let reference = try OrboSpineSwissReference(
            libraryPath: arguments.libraryPath,
            ephemerisDirectory: arguments.ephemerisDirectory
        )
        let expectedVersion = OrboSpineManufactureContract.canonicalAstronomicalSourceVersion
        guard reference.version == expectedVersion else {
            throw OrboSpineCelestialForgeError.swissVersionDrift(
                actual: reference.version,
                expected: expectedVersion
            )
        }

        try OrboSpineManufactureContract.validateZeitgeistBoundaries(reference: reference)

        print("ORBO FORGE / ORBOSPINE CELESTIAL MATTER")
        print("authority: \(OrboSpineManufactureContract.astronomicalSource)")
        print("Swiss Ephemeris: \(reference.version)")
        print("span: Z21 -> Z22 -> Z23")
        print("start: \(OrboSpineManufactureContract.z21.startUTC)")
        print("end exclusive: \(OrboSpineManufactureContract.z23.endUTC)")
        print("canonical bodies: \(MundaneBody.canonicalOrder.count)")
        print("runtime storage: none / Pass D")
        print("DE441 file gate: \(ephemerisFiles.count) files verified")
        print("Zeitgeist fence gate: 4 / 4 direct Pluto 0 Aries")
        print("durability: one continuous Z21-Z23 tract per body / atomic files / SHA-256 checkpoint")

        let checkpointURL = arguments.outputDirectory.appendingPathComponent(checkpointFileName)
        var checkpoint = try loadOrCreateCheckpoint(
            at: checkpointURL,
            swissVersion: reference.version
        )
        try validateCheckpoint(
            checkpoint,
            outputDirectory: arguments.outputDirectory,
            swissVersion: reference.version
        )
        print("resume gate: \(checkpoint.completedBodies.count) / \(MundaneBody.canonicalOrder.count) bodies verified")

        for body in MundaneBody.canonicalOrder {
            if checkpoint.completedBodies.contains(where: { $0.body == body.displayName }) {
                print("skip \(body.displayName): checkpointed files verified")
                continue
            }

            let report = try forgeBody(
                body,
                reference: reference,
                outputDirectory: arguments.outputDirectory
            )
            checkpoint.completedBodies.append(report)
            try writeJSON(checkpoint, to: checkpointURL)
            try validateCheckpoint(
                checkpoint,
                outputDirectory: arguments.outputDirectory,
                swissVersion: reference.version
            )
            print("checkpoint \(body.displayName): \(checkpoint.completedBodies.count) / \(MundaneBody.canonicalOrder.count) durable")
        }

        try validateCheckpoint(
            checkpoint,
            outputDirectory: arguments.outputDirectory,
            swissVersion: reference.version
        )
        guard checkpoint.completedBodies.count == MundaneBody.canonicalOrder.count else {
            throw OrboSpineCelestialForgeError.checkpoint("manufacture ended before all Eleven bodies were durable")
        }

        let manifest = OrboSpineCelestialManifest(
            identity: OrboSpineContract.identity,
            matterFormat: matterFormat,
            matterVersion: matterVersion,
            astronomicalSource: OrboSpineManufactureContract.astronomicalSource,
            astronomicalSourceVersion: reference.version,
            supportedStartJulianDayUT: OrboSpineManufactureContract.supportedStart.value,
            supportedEndJulianDayUT: OrboSpineManufactureContract.supportedEnd.value,
            zeitgeists: OrboSpineManufactureContract.zeitgeists.map(OrboSpineZeitgeistReport.init),
            ephemerisFiles: ephemerisFiles,
            bodies: checkpoint.completedBodies,
            totalSupportRows: checkpoint.completedBodies.reduce(0) { $0 + $1.supportRows },
            totalStationRows: checkpoint.completedBodies.reduce(0) { $0 + $1.stationRows },
            checkpointFile: checkpointFileName,
            runtimeStorage: "none / Pass D not begun"
        )
        let manifestURL = arguments.outputDirectory.appendingPathComponent(manifestFileName)
        try writeJSON(manifest, to: manifestURL)

        print("celestial matter complete")
        print("support rows: \(manifest.totalSupportRows)")
        print("station rows: \(manifest.totalStationRows)")
        print("checkpoint retained: \(checkpointURL.path)")
        print("manifest: \(manifestURL.path)")
        print("status: C4 celestial matter forged; no runtime image, Ring, Terra, shell linkage, eclipse annotation, Dioscuri, or seal")
        #endif
    }

    private static func forgeBody(
        _ body: MundaneBody,
        reference: OrboSpineSwissReference,
        outputDirectory: URL
    ) throws -> OrboSpineCelestialBodyReport {
        let plan = OrboSpineManufactureContract.forgePlan(
            for: body,
            astronomicalSourceVersion: reference.version
        )
        var cursor = MundaneTimespineForge.makeCursor(plan: plan)
        var lastCompleted = 0
        let progressStride = 250_000

        print("forge \(body.displayName): begin continuous Z21-Z23 tract")
        while !cursor.isComplete {
            let update = try cursor.step(reference: reference, segmentBudget: 25_000)
            let crossedStride = update.completedSegments / progressStride != lastCompleted / progressStride
            if crossedStride || update.completedSegments == update.totalSegments {
                let percent = update.totalSegments == 0
                    ? 100.0
                    : Double(update.completedSegments) / Double(update.totalSegments) * 100.0
                print(String(
                    format: "forge %@ %.2f%% / %d of %d segments",
                    body.displayName,
                    percent,
                    update.completedSegments,
                    update.totalSegments
                ))
            }
            lastCompleted = update.completedSegments
        }

        let product = try cursor.product()
        let forged = try validateSingleBodyProduct(product, expectedBody: body, swissVersion: reference.version)
        let slug = bodySlug(body)
        let supportName = "\(slug)-supports.csv"
        let stationName = "\(slug)-stations.csv"
        let supportURL = outputDirectory.appendingPathComponent(supportName)
        let stationURL = outputDirectory.appendingPathComponent(stationName)
        let supportTemp = temporaryURL(for: supportURL)
        let stationTemp = temporaryURL(for: stationURL)

        defer {
            try? FileManager.default.removeItem(at: supportTemp)
            try? FileManager.default.removeItem(at: stationTemp)
        }

        try writeSupports(forged, to: supportTemp)
        try writeStations(forged, to: stationTemp)

        let supportBytes = try fileSize(supportTemp)
        let stationBytes = try fileSize(stationTemp)
        let supportHash = try sha256(supportTemp)
        let stationHash = try sha256(stationTemp)

        try installAtomically(supportTemp, at: supportURL)
        try installAtomically(stationTemp, at: stationURL)

        let report = OrboSpineCelestialBodyReport(
            body: body.displayName,
            supportDegrees: forged.celestialResolutionDegrees,
            supportRows: forged.occurrences.count,
            stationRows: forged.stations.count,
            astronomicalSourceVersion: reference.version,
            supportedStartJulianDayUT: product.supportedStart.value,
            supportedEndJulianDayUT: product.supportedEnd.value,
            supportFile: supportName,
            supportFileBytes: supportBytes,
            supportSHA256: supportHash,
            stationFile: stationName,
            stationFileBytes: stationBytes,
            stationSHA256: stationHash
        )
        try validateBodyReport(report, expectedBody: body, outputDirectory: outputDirectory, swissVersion: reference.version)

        print("wrote \(body.displayName): \(report.supportRows) supports / \(report.stationRows) stations")
        print("  supports SHA-256: \(report.supportSHA256)")
        print("  stations SHA-256: \(report.stationSHA256)")
        return report
    }

    private static func loadOrCreateCheckpoint(
        at url: URL,
        swissVersion: String
    ) throws -> OrboSpineCelestialCheckpoint {
        if FileManager.default.fileExists(atPath: url.path) {
            let data = try Data(contentsOf: url)
            do {
                return try JSONDecoder().decode(OrboSpineCelestialCheckpoint.self, from: data)
            } catch {
                throw OrboSpineCelestialForgeError.checkpoint("cannot decode \(url.path): \(error)")
            }
        }

        let checkpoint = OrboSpineCelestialCheckpoint(
            identity: OrboSpineContract.identity,
            checkpointVersion: checkpointVersion,
            matterFormat: matterFormat,
            matterVersion: matterVersion,
            astronomicalSource: OrboSpineManufactureContract.astronomicalSource,
            astronomicalSourceVersion: swissVersion,
            supportedStartJulianDayUT: OrboSpineManufactureContract.supportedStart.value,
            supportedEndJulianDayUT: OrboSpineManufactureContract.supportedEnd.value,
            completedBodies: []
        )
        try writeJSON(checkpoint, to: url)
        return checkpoint
    }

    private static func validateCheckpoint(
        _ checkpoint: OrboSpineCelestialCheckpoint,
        outputDirectory: URL,
        swissVersion: String
    ) throws {
        guard checkpoint.identity == OrboSpineContract.identity,
              checkpoint.checkpointVersion == checkpointVersion,
              checkpoint.matterFormat == matterFormat,
              checkpoint.matterVersion == matterVersion,
              checkpoint.astronomicalSource == OrboSpineManufactureContract.astronomicalSource,
              checkpoint.astronomicalSourceVersion == swissVersion,
              same(checkpoint.supportedStartJulianDayUT, OrboSpineManufactureContract.supportedStart.value),
              same(checkpoint.supportedEndJulianDayUT, OrboSpineManufactureContract.supportedEnd.value),
              checkpoint.completedBodies.count <= MundaneBody.canonicalOrder.count else {
            throw OrboSpineCelestialForgeError.checkpoint("identity, source, span, or version drift")
        }

        for (index, report) in checkpoint.completedBodies.enumerated() {
            let expectedBody = MundaneBody.canonicalOrder[index]
            try validateBodyReport(
                report,
                expectedBody: expectedBody,
                outputDirectory: outputDirectory,
                swissVersion: swissVersion
            )
        }
    }

    private static func validateBodyReport(
        _ report: OrboSpineCelestialBodyReport,
        expectedBody: MundaneBody,
        outputDirectory: URL,
        swissVersion: String
    ) throws {
        let slug = bodySlug(expectedBody)
        guard report.body == expectedBody.displayName,
              report.supportDegrees == OrboSpineContract.supportDegrees(for: expectedBody),
              report.supportRows > 0,
              report.stationRows >= 0,
              report.astronomicalSourceVersion == swissVersion,
              same(report.supportedStartJulianDayUT, OrboSpineManufactureContract.supportedStart.value),
              same(report.supportedEndJulianDayUT, OrboSpineManufactureContract.supportedEnd.value),
              report.supportFile == "\(slug)-supports.csv",
              report.stationFile == "\(slug)-stations.csv" else {
            throw OrboSpineCelestialForgeError.checkpoint("\(expectedBody.displayName) report contract drift")
        }

        let supportURL = outputDirectory.appendingPathComponent(report.supportFile)
        let stationURL = outputDirectory.appendingPathComponent(report.stationFile)
        guard FileManager.default.fileExists(atPath: supportURL.path),
              FileManager.default.fileExists(atPath: stationURL.path),
              try fileSize(supportURL) == report.supportFileBytes,
              try fileSize(stationURL) == report.stationFileBytes,
              try sha256(supportURL) == report.supportSHA256,
              try sha256(stationURL) == report.stationSHA256 else {
            throw OrboSpineCelestialForgeError.checkpoint("\(expectedBody.displayName) durable files do not match checkpoint")
        }
    }

    private static func validateSingleBodyProduct(
        _ product: MundaneTimespineForgeProduct,
        expectedBody: MundaneBody,
        swissVersion: String
    ) throws -> MundaneTimespineForgedBody {
        guard product.spanName == "OrboSpine Z21-Z23 / \(expectedBody.displayName)",
              product.astronomicalSource == OrboSpineManufactureContract.astronomicalSource,
              product.astronomicalSourceVersion == swissVersion,
              product.supportedStart == OrboSpineManufactureContract.supportedStart,
              product.supportedEnd == OrboSpineManufactureContract.supportedEnd,
              product.bodies.count == 1,
              let body = product.bodies.first,
              body.body == expectedBody,
              body.markerBodies.isEmpty,
              body.celestialResolutionDegrees == OrboSpineContract.supportDegrees(for: expectedBody) else {
            throw OrboSpineCelestialForgeError.malformedProduct("\(expectedBody.displayName) product identity, span, or support drift")
        }
        return body
    }

    private static func validateDE441Directory(_ directory: URL) throws -> [OrboSpineEphemerisFileReport] {
        var reports: [OrboSpineEphemerisFileReport] = []
        reports.reserveCapacity(requiredDE441Files.count)

        for name in requiredDE441Files {
            let url = directory.appendingPathComponent(name)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw OrboSpineCelestialForgeError.missingEphemerisFile(name)
            }

            let handle = try FileHandle(forReadingFrom: url)
            let head = try handle.read(upToCount: 512) ?? Data()
            try handle.close()
            guard String(decoding: head, as: UTF8.self).contains("DE441") else {
                throw OrboSpineCelestialForgeError.nonDE441EphemerisFile(name)
            }
            reports.append(
                OrboSpineEphemerisFileReport(
                    name: name,
                    bytes: try fileSize(url)
                )
            )
        }
        return reports
    }

    private static func writeSupports(
        _ body: MundaneTimespineForgedBody,
        to url: URL
    ) throws {
        let writer = try OrboSpineBufferedCSVWriter(
            url: url,
            header: "directional_degree,physical_degree,navigation_cell,motion,jd_ut,civic_offset_seconds\n"
        )
        for occurrence in body.occurrences {
            let motion = occurrence.sequenceDirection.motion
            guard let directional = OrboSpineDirectionalDegree(
                physicalDegrees: occurrence.focalCelestialDegrees,
                motion: motion
            ) else {
                throw OrboSpineCelestialForgeError.malformedProduct("invalid directional support for \(body.body.displayName)")
            }
            try writer.append(
                "\(decimal(directional.degrees)),\(decimal(directional.physicalDegrees)),\(directional.navigationCell),\(motion.rawValue),\(decimal(occurrence.julianDay.value)),\(occurrence.civicOffsetSeconds)\n"
            )
        }
        try writer.finish()
    }

    private static func writeStations(
        _ body: MundaneTimespineForgedBody,
        to url: URL
    ) throws {
        let writer = try OrboSpineBufferedCSVWriter(
            url: url,
            header: "physical_degree,directional_degree_after,navigation_cell_after,lane_before,lane_after,jd_ut\n"
        )
        for station in body.stations {
            guard let finalStation = OrboSpineStation(
                body: body.body,
                physicalDegrees: station.celestialTimeDegrees,
                julianDay: station.julianDay,
                laneBefore: station.sequenceBefore.motion,
                laneAfter: station.sequenceAfter.motion
            ) else {
                throw OrboSpineCelestialForgeError.malformedProduct("invalid station for \(body.body.displayName)")
            }
            try writer.append(
                "\(decimal(finalStation.physicalDegrees)),\(decimal(finalStation.directionalDegreeAfter.degrees)),\(finalStation.navigationCellAfter),\(finalStation.laneBefore.rawValue),\(finalStation.laneAfter.rawValue),\(decimal(finalStation.julianDay.value))\n"
            )
        }
        try writer.finish()
    }

    private static func installAtomically(_ temporary: URL, at final: URL) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: final.path) {
            _ = try fileManager.replaceItemAt(final, withItemAt: temporary)
        } else {
            try fileManager.moveItem(at: temporary, to: final)
        }
    }

    private static func temporaryURL(for final: URL) -> URL {
        final.deletingLastPathComponent().appendingPathComponent(
            ".\(final.lastPathComponent).\(UUID().uuidString).tmp"
        )
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

    private static func bodySlug(_ body: MundaneBody) -> String {
        switch body {
        case .sun: return "sun"
        case .moon: return "moon"
        case .mercury: return "mercury"
        case .venus: return "venus"
        case .mars: return "mars"
        case .jupiter: return "jupiter"
        case .saturn: return "saturn"
        case .uranus: return "uranus"
        case .neptune: return "neptune"
        case .pluto: return "pluto"
        case .trueNorthNode: return "true-north-node"
        }
    }

    private static func decimal(_ value: Double) -> String {
        String(format: "%.17g", locale: Locale(identifier: "en_US_POSIX"), value)
    }

    private static func same(_ lhs: Double, _ rhs: Double) -> Bool {
        abs(lhs - rhs) < 1e-12
    }

    private static func fileSize(_ url: URL) throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let value = attributes[.size] as? NSNumber else {
            throw OrboSpineCelestialForgeError.output("missing file size for \(url.path)")
        }
        return value.int64Value
    }

    private static func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }
}
