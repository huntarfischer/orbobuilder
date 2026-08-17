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

let signs = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
]

func sequence(_ speed: Double) -> String { speed < 0 ? "decreasing" : "increasing" }

struct CelestialTime: Codable {
    let longitudeDegrees: Double
    let wholeDegree: Int
    let sign: String
    let degreeWithinSign: Double
}

func celestialTime(_ longitude: Double) -> CelestialTime {
    let lon = normalize(longitude)
    let whole = Int(floor(lon))
    return CelestialTime(
        longitudeDegrees: lon,
        wholeDegree: whole,
        sign: signs[whole / 30],
        degreeWithinSign: lon - Double((whole / 30) * 30)
    )
}

struct CivicTime: Codable {
    let julianDayUT: Double
    let utOffsetSeconds: UInt32
}

func civicTime(_ jd: Double) -> CivicTime {
    let seconds = UInt32(max(0, min(Double(UInt32.max), ((jd - saturnStartJD) * 86_400.0).rounded())))
    return CivicTime(julianDayUT: jd, utOffsetSeconds: seconds)
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

struct CelestialTurn: Codable {
    let body: String
    let celestialTime: CelestialTime
    let civicTime: CivicTime
    let sequenceBefore: String
    let sequenceAfter: String
    let turn: String
}

struct VertebraBoundary: Codable {
    let body: String
    let boundary: String
    let celestialTime: CelestialTime
    let civicTime: CivicTime
    let sequence: String
}

struct BodySummary: Codable {
    let body: String
    let celestialTurnCount: Int
    let packedBytesAt0_01Degree: Int
    let packedBytesAt0_001Degree: Int
}

struct Output: Codable {
    let status: String
    let framing: String
    let constructionMethod: String
    let astronomicalSource: String
    let swissVersion: String
    let saturnStartJulianDayUT: Double
    let saturnEndJulianDayUT: Double
    let scanStepDays: Double
    let vertebraBoundaries: [VertebraBoundary]
    let celestialTurns: [CelestialTurn]
    let byBody: [BodySummary]
    let totalCelestialTurns: Int
    let packedBytesAt0_01Degree: Int
    let packedBytesAt0_001Degree: Int
}

let saturnStartJD = 2439553.3967229538
let saturnEndJD = 2450180.8673149766
let scanStepDays = 0.25

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

func refineTurn(body: Body, lo initialLo: Double, hi initialHi: Double, swiss: Swiss) throws -> Double {
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

func findCelestialTurns(body: Body, swiss: Swiss) throws -> [CelestialTurn] {
    var result: [CelestialTurn] = []
    var previousJD = saturnStartJD
    var previous = try swiss.state(body, jd: previousJD)
    var jd = previousJD + scanStepDays

    while previousJD < saturnEndJD {
        let currentJD = min(jd, saturnEndJD)
        let current = try swiss.state(body, jd: currentJD)
        let signChanged = (previous.speed < 0 && current.speed >= 0) || (previous.speed >= 0 && current.speed < 0)
        if signChanged {
            let turnJD = try refineTurn(body: body, lo: previousJD, hi: currentJD, swiss: swiss)
            let turnState = try swiss.state(body, jd: turnJD)
            let epsilon = 1.0 / 1440.0
            let before = try swiss.state(body, jd: max(saturnStartJD, turnJD - epsilon))
            let after = try swiss.state(body, jd: min(saturnEndJD, turnJD + epsilon))
            let beforeSequence = sequence(before.speed)
            let afterSequence = sequence(after.speed)
            let turn = beforeSequence == "increasing" && afterSequence == "decreasing"
                ? "increasing_to_decreasing"
                : "decreasing_to_increasing"
            result.append(CelestialTurn(
                body: body.name,
                celestialTime: celestialTime(turnState.longitude),
                civicTime: civicTime(turnJD),
                sequenceBefore: beforeSequence,
                sequenceAfter: afterSequence,
                turn: turn
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
    var allTurns: [CelestialTurn] = []
    var boundaries: [VertebraBoundary] = []
    var summaries: [BodySummary] = []

    for body in Body.allCases {
        let startState = try swiss.state(body, jd: saturnStartJD)
        let endState = try swiss.state(body, jd: saturnEndJD)
        boundaries.append(VertebraBoundary(
            body: body.name,
            boundary: "start",
            celestialTime: celestialTime(startState.longitude),
            civicTime: civicTime(saturnStartJD),
            sequence: sequence(startState.speed)
        ))
        boundaries.append(VertebraBoundary(
            body: body.name,
            boundary: "end",
            celestialTime: celestialTime(endState.longitude),
            civicTime: civicTime(saturnEndJD),
            sequence: sequence(endState.speed)
        ))

        let turns = try findCelestialTurns(body: body, swiss: swiss)
        allTurns.append(contentsOf: turns)
        summaries.append(BodySummary(
            body: body.name,
            celestialTurnCount: turns.count,
            packedBytesAt0_01Degree: turns.count * 6,
            packedBytesAt0_001Degree: turns.count * 7
        ))
        print("\(body.name): \(turns.count) celestial-time turns")
    }

    allTurns.sort { $0.civicTime.julianDayUT < $1.civicTime.julianDayUT }
    let output = Output(
        status: "Construction-time celestial-turn table learning specimen",
        framing: "A station is stored as a turn in a body's celestial-time sequence. Civic UT is the corresponding civil-time coordinate, not the primary frame.",
        constructionMethod: "Swiss signed longitudinal speed is used only to locate the exact zero-speed turn during construction; the stored Timespine fact is celestial-time position + civic UT + sequence before/after.",
        astronomicalSource: "Swiss Ephemeris; geocentric tropical apparent ecliptic longitude and signed longitudinal speed; UT",
        swissVersion: swiss.version,
        saturnStartJulianDayUT: saturnStartJD,
        saturnEndJulianDayUT: saturnEndJD,
        scanStepDays: scanStepDays,
        vertebraBoundaries: boundaries,
        celestialTurns: allTurns,
        byBody: summaries,
        totalCelestialTurns: allTurns.count,
        packedBytesAt0_01Degree: allTurns.count * 6,
        packedBytesAt0_001Degree: allTurns.count * 7
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    try encoder.encode(output).write(to: URL(fileURLWithPath: args.output))

    print("TOTAL celestial-time turns: \(allTurns.count)")
    print("Packed estimate @0.01°: \(allTurns.count * 6) bytes")
    print("Packed estimate @0.001°: \(allTurns.count * 7) bytes")
}

do {
    try main()
} catch {
    fputs("StationTablePOC failed: \(error)\n", stderr)
    exit(1)
}
