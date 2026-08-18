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

private enum OrboForgeToolError: Error, CustomStringConvertible {
    case missingArgument(String)
    case invalidSwissBody(MundaneBody)
    case swissLibrary(String)
    case swissSymbol(String)
    case swissCalculation(String)

    var description: String {
        switch self {
        case let .missingArgument(name): return "Missing required argument: \(name)"
        case let .invalidSwissBody(body): return "No Swiss Ephemeris body id for \(body.displayName)."
        case let .swissLibrary(message): return "Swiss Ephemeris library error: \(message)"
        case let .swissSymbol(name): return "Missing Swiss Ephemeris symbol: \(name)"
        case let .swissCalculation(message): return "Swiss Ephemeris calculation failed: \(message)"
        }
    }
}

private final class SwissEphemerisForgeReference: @unchecked Sendable, ForgeEphemerisReference {
    private let handle: UnsafeMutableRawPointer
    private let calculateUT: SweCalcUT
    let version: String

    private static let swissEphemerisFlag: Int32 = 2
    private static let moshierFlag: Int32 = 4
    private static let speedFlag: Int32 = 256

    init(libraryPath: String, ephemerisDirectory: String) throws {
        guard let opened = dlopen(libraryPath, RTLD_NOW | RTLD_LOCAL) else {
            let message = dlerror().map { String(cString: $0) } ?? "unknown dlopen failure"
            throw OrboForgeToolError.swissLibrary(message)
        }
        handle = opened

        func symbol<T>(_ name: String, as type: T.Type) throws -> T {
            guard let pointer = dlsym(opened, name) else { throw OrboForgeToolError.swissSymbol(name) }
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
            throw OrboForgeToolError.swissCalculation(String(cString: errorBuffer))
        }
        return state
    }
}

private struct Arguments {
    let libraryPath: String
    let ephemerisDirectory: String

    init(_ raw: [String]) throws {
        var values: [String: String] = [:]
        var index = 0
        while index < raw.count {
            let key = raw[index]
            guard key.hasPrefix("--"), index + 1 < raw.count else {
                throw OrboForgeToolError.missingArgument(key)
            }
            values[key] = raw[index + 1]
            index += 2
        }
        guard let library = values["--library"], !library.isEmpty else {
            throw OrboForgeToolError.missingArgument("--library")
        }
        guard let ephemeris = values["--ephe-dir"], !ephemeris.isEmpty else {
            throw OrboForgeToolError.missingArgument("--ephe-dir")
        }
        libraryPath = library
        ephemerisDirectory = ephemeris
    }
}

@main
private struct OrboForgeTool {
    static func main() throws {
        let arguments = try Arguments(Array(CommandLine.arguments.dropFirst()))
        let reference = try SwissEphemerisForgeReference(
            libraryPath: arguments.libraryPath,
            ephemerisDirectory: arguments.ephemerisDirectory
        )

        print("ORBO FORGE")
        print("manufacturer: native Swift")
        print("span: \(MundaneTimespineP22.spanName)")
        print("Swiss Ephemeris: \(reference.version)")
        print("body clocks: \(MundaneBody.canonicalOrder.count)")
        print("manufacturing law: celestial coordinate occurrence <-> civic UT")

        let product = try MundaneTimespineForge.manufactureP22(
            astronomicalSourceVersion: reference.version,
            reference: reference
        )

        print("forged occurrences: \(product.totalOccurrenceCount)")
        print("stations: \(product.totalStationCount)")
        print("retrograde passages: \(product.totalRetrogradePassageCount)")
        print("status: P22 manufacture complete; final packed serialization remains a separate Pass 5 mating surface")
    }
}
