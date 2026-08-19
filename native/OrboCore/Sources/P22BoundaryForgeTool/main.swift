import Foundation
import OrboCore
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

private typealias SweSetEphePath = @convention(c) (UnsafePointer<CChar>?) -> Void
private typealias SweCalcUT = @convention(c) (Double, Int32, Int32, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<CChar>?) -> Int32
private typealias SweVersion = @convention(c) (UnsafeMutablePointer<CChar>?) -> UnsafePointer<CChar>?

private enum BoundaryForgeError: Error, CustomStringConvertible {
    case missingArgument(String)
    case swissLibrary(String)
    case swissSymbol(String)
    case swissCalculation(String)
    case invalidSwissBody(MundaneBody)
    case sourceVersion(expected: String, actual: String)
    case p22BoundaryMismatch

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
        case let .invalidSwissBody(body):
            return "No Swiss Ephemeris body id for \(body.displayName)."
        case let .sourceVersion(expected, actual):
            return "Swiss Ephemeris version changed: expected \(expected), got \(actual)."
        case .p22BoundaryMismatch:
            return "Stored P22/P23 bounds no longer validate as direct Pluto 0 Aries crossings."
        }
    }
}

private final class SwissBoundaryReference {
    private let handle: UnsafeMutableRawPointer
    private let calculateUT: SweCalcUT
    let version: String

    private static let swissEphemerisFlag: Int32 = 2
    private static let moshierFlag: Int32 = 4
    private static let speedFlag: Int32 = 256

    init(libraryPath: String, ephemerisDirectory: String) throws {
        guard let opened = dlopen(libraryPath, RTLD_NOW | RTLD_LOCAL) else {
            let message = dlerror().map { String(cString: $0) } ?? "unknown dlopen failure"
            throw BoundaryForgeError.swissLibrary(message)
        }
        handle = opened

        func symbol<T>(_ name: String, as type: T.Type) throws -> T {
            guard let pointer = dlsym(opened, name) else {
                throw BoundaryForgeError.swissSymbol(name)
            }
            return unsafeBitCast(pointer, to: T.self)
        }

        let setPath: SweSetEphePath = try symbol("swe_set_ephe_path", as: SweSetEphePath.self)
        let calc: SweCalcUT = try symbol("swe_calc_ut", as: SweCalcUT.self)
        let versionFunction: SweVersion = try symbol("swe_version", as: SweVersion.self)
        ephemerisDirectory.withCString { setPath($0) }
        calculateUT = calc

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
            throw BoundaryForgeError.swissCalculation(String(cString: errorBuffer))
        }
        return state
    }
}

private struct Arguments {
    let libraryPath: String
    let ephemerisDirectory: String
    let outputURL: URL

    init(_ raw: [String]) throws {
        var values: [String: String] = [:]
        var index = 0
        while index < raw.count {
            let key = raw[index]
            guard key.hasPrefix("--"), index + 1 < raw.count else {
                throw BoundaryForgeError.missingArgument(key)
            }
            values[key] = raw[index + 1]
            index += 2
        }
        guard let library = values["--library"], !library.isEmpty else {
            throw BoundaryForgeError.missingArgument("--library")
        }
        guard let ephemeris = values["--ephe-dir"], !ephemeris.isEmpty else {
            throw BoundaryForgeError.missingArgument("--ephe-dir")
        }
        guard let output = values["--output"], !output.isEmpty else {
            throw BoundaryForgeError.missingArgument("--output")
        }
        libraryPath = library
        ephemerisDirectory = ephemeris
        outputURL = URL(fileURLWithPath: output)
    }
}

private struct BoundaryStateRecord: Codable {
    let body: String
    let startCelestialMicrodegrees: UInt32
    let startMotion: String
    let endCelestialMicrodegrees: UInt32
    let endMotion: String
}

private struct BoundaryStateArtifact: Codable {
    let artifactFamily: String
    let astronomicalSource: String
    let astronomicalSourceVersion: String
    let spanName: String
    let startJulianDayUT: String
    let endJulianDayUT: String
    let bodies: [BoundaryStateRecord]
}

private func microdegrees(_ degrees: Double) -> UInt32 {
    var normalized = degrees.truncatingRemainder(dividingBy: 360)
    if normalized < 0 { normalized += 360 }
    let raw = UInt64((normalized * Double(MundaneTimespineStorageFormat.microdegreesPerDegree)).rounded())
        % MundaneTimespineStorageFormat.circleMicrodegrees
    return UInt32(raw)
}

private func motionName(_ state: MundaneForgeState) -> String {
    state.longitudinalSpeedDegreesPerDay < 0 ? "retrograde" : "direct"
}

private func distanceFromZeroAries(_ longitude: Double) -> Double {
    min(longitude, 360 - longitude)
}

private func run() throws {
    let arguments = try Arguments(Array(CommandLine.arguments.dropFirst()))
    let reference = try SwissBoundaryReference(
        libraryPath: arguments.libraryPath,
        ephemerisDirectory: arguments.ephemerisDirectory
    )
    guard reference.version == MundaneTimespineP22ForgeRecipe.canonicalAstronomicalSourceVersion else {
        throw BoundaryForgeError.sourceVersion(
            expected: MundaneTimespineP22ForgeRecipe.canonicalAstronomicalSourceVersion,
            actual: reference.version
        )
    }

    let plutoStart = try reference.state(of: .pluto, at: MundaneTimespineP22.startJulianDay)
    let plutoEnd = try reference.state(of: .pluto, at: MundaneTimespineP22.endJulianDay)
    guard distanceFromZeroAries(plutoStart.longitudeDegrees) < 0.0001,
          plutoStart.longitudinalSpeedDegreesPerDay > 0,
          distanceFromZeroAries(plutoEnd.longitudeDegrees) < 0.0001,
          plutoEnd.longitudinalSpeedDegreesPerDay > 0 else {
        throw BoundaryForgeError.p22BoundaryMismatch
    }

    var records: [BoundaryStateRecord] = []
    records.reserveCapacity(MundaneBody.canonicalOrder.count)
    for body in MundaneBody.canonicalOrder {
        let start = try reference.state(of: body, at: MundaneTimespineP22.startJulianDay)
        let end = try reference.state(of: body, at: MundaneTimespineP22.endJulianDay)
        records.append(BoundaryStateRecord(
            body: body.constructionDataName,
            startCelestialMicrodegrees: microdegrees(start.longitudeDegrees),
            startMotion: motionName(start),
            endCelestialMicrodegrees: microdegrees(end.longitudeDegrees),
            endMotion: motionName(end)
        ))
        print(
            "boundary \(body.displayName): start \(microdegrees(start.longitudeDegrees)) \(motionName(start)) / "
            + "end \(microdegrees(end.longitudeDegrees)) \(motionName(end))"
        )
    }

    let artifact = BoundaryStateArtifact(
        artifactFamily: "p22-body-boundary-states-v1",
        astronomicalSource: MundaneTimespineP22ForgeRecipe.astronomicalSource,
        astronomicalSourceVersion: reference.version,
        spanName: MundaneTimespineP22.spanName,
        startJulianDayUT: "2386637.079399706",
        endJulianDayUT: "2475819.1417904524",
        bodies: records
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    let data = try encoder.encode(artifact)
    try FileManager.default.createDirectory(
        at: arguments.outputURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try data.write(to: arguments.outputURL, options: .atomic)
    print("boundary artifact: \(arguments.outputURL.path)")
    print("boundary artifact bytes: \(data.count)")
}

do {
    try run()
} catch {
    let message = "P22BoundaryForgeTool error: \(error)\n"
    FileHandle.standardError.write(Data(message.utf8))
    exit(EXIT_FAILURE)
}
