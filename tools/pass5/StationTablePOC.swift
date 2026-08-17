import Foundation
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

enum POCError: Error, CustomStringConvertible {
    case usage(String)
    case dl(String)
    case swiss(String)

    var description: String {
        switch self {
        case .usage(let s), .dl(let s), .swiss(let s): return s
        }
    }
}

enum Body: Int32, CaseIterable {
    case sun = 0
    case moon = 1
    case mercury = 2
    case venus = 3
    case mars = 4
    case jupiter = 5
    case saturn = 6

    var name: String {
        switch self {
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .mercury: return "Mercury"
        case .venus: return "Venus"
        case .mars: return "Mars"
        case .jupiter: return "Jupiter"
        case .saturn: return "Saturn"
        }
    }
}

struct State {
    let longitude: Double
    let speed: Double
}

func normalize(_ x: Double) -> Double {
    var r = x.truncatingRemainder(dividingBy: 360)
    if r < 0 { r += 360 }
    return r == 0 ? 0 : r
}

typealias SweSetEphePath = @convention(c) (UnsafePointer<CChar>?) -> Void
typealias SweCalcUT = @convention(c) (Double, Int32, Int32, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<CChar>?) -> Int32

typealias SweVersion = @convention(c) (UnsafeMutablePointer<CChar>?) -> UnsafePointer<CChar>?

final class Swiss {
    private let handle: UnsafeMutableRawPointer
    private let setPath: SweSetEphePath
    private let calcUT: SweCalcUT
    private let versionFn: SweVersion
    let version: String

    static let SEFLG_SWIEPH: Int32 = 2
    static let SEFLG_MOSEPH: Int32 = 4
    static let SEFLG_SPEED: Int32 = 256

    init(library: String, epheDir: String) throws {
        guard let h = dlopen(library, RTLD_NOW | RTLD_LOCAL) else {
            throw POCError.dl("Could not open Swiss library: \(String(cString: dlerror()))")
        }
        handle = h
        func symbol<T>(_ name: String, as: T.Type) throws -> T {
            guard let s = dlsym(h, name) else { throw POCError.dl("Missing Swiss symbol \(name)") }
            return unsafeBitCast(s, to: T.self)
        }
        let localSetPath: SweSetEphePath = try symbol("swe_set_ephe_path", as: SweSetEphePath.self)
        let localCalcUT: SweCalcUT = try symbol("swe_calc_ut", as: SweCalcUT.self)
        let localVersionFn: SweVersion = try symbol("swe_version", as: SweVersion.self)
        var vbuf = [CChar](repeating: 0, count: 256)
        _ = vbuf.withUnsafeMutableBufferPointer { localVersionFn($0.baseAddress) }
        let localVersion = String(cString: vbuf)
        epheDir.withCString { localSetPath($0) }
        setPath = localSetPath
        calcUT = localCalcUT
        versionFn = localVersionFn
        version = localVersion
    }

    deinit { dlclose(handle) }

    func state(_ body: Body, jd: Double) throws -> State {
        var xx = [Double](repeating: 0, count: 6)
        var err = [CChar](repeating: 0, count: 256)
        let flags = Swiss.SEFLG_SWIEPH | Swiss.SEFLG_SPEED
        let returned = xx.withUnsafeMutableBufferPointer { xp in
            err.withUnsafeMutableBufferPointer { ep in
                calcUT(jd, body.rawValue, flags, xp.baseAddress, ep.baseAddress)
            }
        }
        if returned < 0 {
            throw POCError.swiss("swe_calc_ut failed for \(body.name) @ \(jd): \(String(cString: err))")
        }
        if (returned & Swiss.SEFLG_SWIEPH) == 0 || (returned & Swiss.SEFLG_MOSEPH) != 0 {
            throw POCError.swiss("Swiss-file mode required for \(body.name) @ \(jd); flags=\(returned)")
        }
        return State(longitude: normalize(xx[0]), speed: xx[3])
    }
}

struct Station: Codable {
    let body: String
    let kind: String
    let julianDayUT: Double
    let utOffsetSeconds: UInt32
    let longitude: Double
    let wholeDegree: Int
    let directionBefore: String
    let directionAfter: String
}

struct BodySummary: Codable {
    let body: String
    let stationCount: Int
    let packedBytesAt0_01Degree: Int
    let packedBytesAt0_001Degree: Int
}

struct Output: Codable {
    let status: String
    let astronomicalSource: String
    let swissVersion: String
    let saturnStartJulianDayUT: Double
    let saturnEndJulianDayUT: Double
    let samplingStepDays: Double
    let stations: [Station]
    let byBody: [BodySummary]
    let totalStations: Int
    let packedBytesAt0_01Degree: Int
    let packedBytesAt0_001Degree: Int
}

let saturnStartJD = 2439553.3967229538
let saturnEndJD = 2450180.8673149766
let scanStepDays = 0.25

func direction(_ speed: Double) -> String { speed < 0 ? "retrograde" : "direct" }

func parseArgs() throws -> (library: String, epheDir: String, output: String) {
    var library: String?
    var epheDir: String?
    var output: String?
    var i = 1
    let args = CommandLine.arguments
    while i < args.count {
        switch args[i] {
        case "--library":
            i += 1; if i < args.count { library = args[i] }
        case "--ephe-dir":
            i += 1; if i < args.count { epheDir = args[i] }
        case "--output":
            i += 1; if i < args.count { output = args[i] }
        default: break
        }
        i += 1
    }
    guard let l = library, let e = epheDir, let o = output else {
        throw POCError.usage("Usage: StationTablePOC --library <libswe> --ephe-dir <dir> --output <json>")
    }
    return (l, e, o)
}

func refineStation(body: Body, lo initialLo: Double, hi initialHi: Double, swiss: Swiss) throws -> Double {
    var lo = initialLo
    var hi = initialHi
    var slo = try swiss.state(body, jd: lo).speed
    for _ in 0..<64 {
        let mid = (lo + hi) / 2
        let smid = try swiss.state(body, jd: mid).speed
        if abs(smid) < 1e-12 { return mid }
        if (slo < 0 && smid < 0) || (slo >= 0 && smid >= 0) {
            lo = mid
            slo = smid
        } else {
            hi = mid
        }
    }
    return (lo + hi) / 2
}

func findStations(body: Body, swiss: Swiss) throws -> [Station] {
    var result: [Station] = []
    var previousJD = saturnStartJD
    var previous = try swiss.state(body, jd: previousJD)
    var jd = previousJD + scanStepDays

    while previousJD < saturnEndJD {
        let currentJD = min(jd, saturnEndJD)
        let current = try swiss.state(body, jd: currentJD)
        let signChanged = (previous.speed < 0 && current.speed >= 0) || (previous.speed >= 0 && current.speed < 0)
        if signChanged {
            let stationJD = try refineStation(body: body, lo: previousJD, hi: currentJD, swiss: swiss)
            let stationState = try swiss.state(body, jd: stationJD)
            let epsilon = 1.0 / 1440.0
            let before = try swiss.state(body, jd: max(saturnStartJD, stationJD - epsilon))
            let after = try swiss.state(body, jd: min(saturnEndJD, stationJD + epsilon))
            let beforeDirection = direction(before.speed)
            let afterDirection = direction(after.speed)
            let kind = beforeDirection == "direct" && afterDirection == "retrograde" ? "station_retrograde" : "station_direct"
            let offset = UInt32(max(0, min(Double(UInt32.max), ((stationJD - saturnStartJD) * 86400.0).rounded())))
            result.append(Station(
                body: body.name,
                kind: kind,
                julianDayUT: stationJD,
                utOffsetSeconds: offset,
                longitude: stationState.longitude,
                wholeDegree: Int(floor(stationState.longitude)),
                directionBefore: beforeDirection,
                directionAfter: afterDirection
            ))
        }
        previousJD = currentJD
        previous = current
        if currentJD >= saturnEndJD { break }
        jd += scanStepDays
    }
    return result
}

func main() throws {
    let args = try parseArgs()
    let swiss = try Swiss(library: args.library, epheDir: args.epheDir)
    var allStations: [Station] = []
    var summaries: [BodySummary] = []

    for body in Body.allCases {
        let stations = try findStations(body: body, swiss: swiss)
        allStations.append(contentsOf: stations)
        summaries.append(BodySummary(
            body: body.name,
            stationCount: stations.count,
            packedBytesAt0_01Degree: stations.count * 6,
            packedBytesAt0_001Degree: stations.count * 7
        ))
        print("\(body.name): \(stations.count) stations")
    }

    allStations.sort { $0.julianDayUT < $1.julianDayUT }
    let output = Output(
        status: "Construction-time station table learning specimen; intended to remove routine runtime Ephemeris queries around direction changes",
        astronomicalSource: "Swiss Ephemeris; geocentric tropical apparent ecliptic longitude and signed longitudinal speed; UT",
        swissVersion: swiss.version,
        saturnStartJulianDayUT: saturnStartJD,
        saturnEndJulianDayUT: saturnEndJD,
        samplingStepDays: scanStepDays,
        stations: allStations,
        byBody: summaries,
        totalStations: allStations.count,
        packedBytesAt0_01Degree: allStations.count * 6,
        packedBytesAt0_001Degree: allStations.count * 7
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(output)
    try data.write(to: URL(fileURLWithPath: args.output))

    print("TOTAL stations: \(allStations.count)")
    print("Packed estimate @0.01°: \(allStations.count * 6) bytes")
    print("Packed estimate @0.001°: \(allStations.count * 7) bytes")
}

do {
    try main()
} catch {
    fputs("StationTablePOC failed: \(error)\n", stderr)
    exit(1)
}
