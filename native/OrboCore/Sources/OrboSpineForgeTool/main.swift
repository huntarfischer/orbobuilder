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

private enum OrboSpineCelestialForgeCommandError: Error, CustomStringConvertible {
    case missingArgument(String)
    case swissLibrary(String)
    case swissSymbol(String)
    case swissCalculation(String)
    case swissVersionDrift(actual: String, expected: String)
    case missingEphemerisFile(String)
    case nonDE441EphemerisFile(String)
    case malformedProduct(String)
    case output(String)

    var description: String {
        switch self {
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
                throw OrboSpineCelestialForgeCommandError.missingArgument(key)
            }
            values[key] = raw[index + 1]
            index += 2
        }

        guard let library = values["--library"], !library.isEmpty else {
            throw OrboSpineCelestialForgeCommandError.missingArgument("--library")
        }
        guard let ephemeris = values["--ephe-dir"], !ephemeris.isEmpty else {
            throw OrboSpineCelestialForgeCommandError.missingArgument("--ephe-dir")
        }
        guard let output = values["--output-dir"], !output.isEmpty else {
            throw OrboSpineCelestialForgeCommandError.missingArgument("--output-dir")
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
            throw OrboSpineCelestialForgeCommandError.swissLibrary(message)
        }
        handle = opened

        func symbol<T>(_ name: String, as type: T.Type) throws -> T {
            guard let pointer = dlsym(opened, name) else {
                throw OrboSpineCelestialForgeCommandError.swissSymbol(name)
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
            throw OrboSpineCelestialForgeCommandError.swissCalculation(String(cString: errorBuffer))
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
    let supportFile: String
    let supportFileBytes: Int64
    let stationFile: String
    let stationFileBytes: Int64
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
            throw OrboSpineCelestialForgeCommandError.output("could not create \(url.path)")
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

private enum OrboSpineCelestialForgeCommand {
    private static let requiredDE441Files = [
        "seplm36.se1", "seplm30.se1", "seplm24.se1", "seplm18.se1", "seplm12.se1", "seplm06.se1",
        "sepl_00.se1", "sepl_06.se1", "sepl_12.se1", "sepl_18.se1", "sepl_24.se1",
        "semom36.se1", "semom30.se1", "semom24.se1", "semom18.se1", "semom12.se1", "semom06.se1",
        "semo_00.se1", "semo_06.se1", "semo_12.se1", "semo_18.se1", "semo_24.se1",
    ]

    static func run(_ raw: [String]) throws {
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
            throw OrboSpineCelestialForgeCommandError.swissVersionDrift(
                actual: reference.version,
                expected: expectedVersion
            )
        }

        try OrboSpineManufactureContract.validateZeitgeistBoundaries(reference: reference)
        let plan = OrboSpineManufactureContract.forgePlan(
            astronomicalSourceVersion: reference.version
        )

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

        var cursor = MundaneTimespineForge.makeCursor(plan: plan)
        var lastProgress = cursor.progress
        let progressStride = 250_000

        while !cursor.isComplete {
            let update = try cursor.step(reference: reference, segmentBudget: 25_000)
            let bodyChanged = update.currentBody != lastProgress.currentBody
            let crossedProgressStride = update.completedSegments / progressStride != lastProgress.completedSegments / progressStride
            if bodyChanged || crossedProgressStride || update.completedSegments == update.totalSegments {
                let percent = update.totalSegments == 0
                    ? 100.0
                    : Double(update.completedSegments) / Double(update.totalSegments) * 100.0
                let body = update.currentBody?.displayName ?? "complete"
                print(String(format: "forge %.2f%% / %d of %d segments / %@", percent, update.completedSegments, update.totalSegments, body))
            }
            lastProgress = update
        }

        let product = try cursor.product()
        try validate(product: product, swissVersion: reference.version)

        var bodyReports: [OrboSpineCelestialBodyReport] = []
        bodyReports.reserveCapacity(MundaneBody.canonicalOrder.count)

        for body in MundaneBody.canonicalOrder {
            guard let forged = product.body(body) else {
                throw OrboSpineCelestialForgeCommandError.malformedProduct("missing \(body.displayName)")
            }
            let slug = bodySlug(body)
            let supportName = "\(slug)-supports.csv"
            let stationName = "\(slug)-stations.csv"
            let supportURL = arguments.outputDirectory.appendingPathComponent(supportName)
            let stationURL = arguments.outputDirectory.appendingPathComponent(stationName)

            try writeSupports(forged, to: supportURL)
            try writeStations(forged, to: stationURL)

            let supportBytes = try fileSize(supportURL)
            let stationBytes = try fileSize(stationURL)
            bodyReports.append(
                OrboSpineCelestialBodyReport(
                    body: body.displayName,
                    supportDegrees: forged.celestialResolutionDegrees,
                    supportRows: forged.occurrences.count,
                    stationRows: forged.stations.count,
                    supportFile: supportName,
                    supportFileBytes: supportBytes,
                    stationFile: stationName,
                    stationFileBytes: stationBytes
                )
            )
            print("wrote \(body.displayName): \(forged.occurrences.count) supports / \(forged.stations.count) stations")
        }

        let manifest = OrboSpineCelestialManifest(
            identity: OrboSpineContract.identity,
            matterFormat: "directional-degree-csv",
            matterVersion: 1,
            astronomicalSource: product.astronomicalSource,
            astronomicalSourceVersion: product.astronomicalSourceVersion,
            supportedStartJulianDayUT: product.supportedStart.value,
            supportedEndJulianDayUT: product.supportedEnd.value,
            zeitgeists: OrboSpineManufactureContract.zeitgeists.map(OrboSpineZeitgeistReport.init),
            ephemerisFiles: ephemerisFiles,
            bodies: bodyReports,
            totalSupportRows: bodyReports.reduce(0) { $0 + $1.supportRows },
            totalStationRows: bodyReports.reduce(0) { $0 + $1.stationRows },
            runtimeStorage: "none / Pass D not begun"
        )
        try writeJSON(
            manifest,
            to: arguments.outputDirectory.appendingPathComponent("orbospine-celestial-manifest.json")
        )

        print("celestial matter complete")
        print("support rows: \(manifest.totalSupportRows)")
        print("station rows: \(manifest.totalStationRows)")
        print("manifest: \(arguments.outputDirectory.appendingPathComponent("orbospine-celestial-manifest.json").path)")
        print("status: C4 celestial matter forged; no runtime image, Ring, Terra, shell linkage, eclipse annotation, Dioscuri, or seal")
    }

    private static func validateDE441Directory(_ directory: URL) throws -> [OrboSpineEphemerisFileReport] {
        var reports: [OrboSpineEphemerisFileReport] = []
        reports.reserveCapacity(requiredDE441Files.count)

        for name in requiredDE441Files {
            let url = directory.appendingPathComponent(name)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw OrboSpineCelestialForgeCommandError.missingEphemerisFile(name)
            }

            let handle = try FileHandle(forReadingFrom: url)
            let head = try handle.read(upToCount: 512) ?? Data()
            try handle.close()
            guard String(decoding: head, as: UTF8.self).contains("DE441") else {
                throw OrboSpineCelestialForgeCommandError.nonDE441EphemerisFile(name)
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

    private static func validate(
        product: MundaneTimespineForgeProduct,
        swissVersion: String
    ) throws {
        guard product.spanName == "OrboSpine Z21-Z23",
              product.astronomicalSource == OrboSpineManufactureContract.astronomicalSource,
              product.astronomicalSourceVersion == swissVersion,
              product.supportedStart == OrboSpineManufactureContract.supportedStart,
              product.supportedEnd == OrboSpineManufactureContract.supportedEnd,
              product.bodies.map(\.body) == MundaneBody.canonicalOrder else {
            throw OrboSpineCelestialForgeCommandError.malformedProduct("product identity or span drift")
        }

        for body in product.bodies {
            guard body.markerBodies.isEmpty,
                  body.celestialResolutionDegrees == OrboSpineContract.supportDegrees(for: body.body) else {
                throw OrboSpineCelestialForgeCommandError.malformedProduct("\(body.body.displayName) support law drift")
            }
        }
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
                throw OrboSpineCelestialForgeCommandError.malformedProduct("invalid directional support for \(body.body.displayName)")
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
                throw OrboSpineCelestialForgeCommandError.malformedProduct("invalid station for \(body.body.displayName)")
            }
            try writer.append(
                "\(decimal(finalStation.physicalDegrees)),\(decimal(finalStation.directionalDegreeAfter.degrees)),\(finalStation.navigationCellAfter),\(finalStation.laneBefore.rawValue),\(finalStation.laneAfter.rawValue),\(decimal(finalStation.julianDay.value))\n"
            )
        }
        try writer.finish()
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

    private static func fileSize(_ url: URL) throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let value = attributes[.size] as? NSNumber else {
            throw OrboSpineCelestialForgeCommandError.output("missing file size for \(url.path)")
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

do {
    try OrboSpineCelestialForgeCommand.run(Array(CommandLine.arguments.dropFirst()))
} catch {
    let message = "OrboSpineForgeTool error: \(error)\n"
    FileHandle.standardError.write(Data(message.utf8))
    exit(EXIT_FAILURE)
}
