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

enum Body: Int32, CaseIterable, Codable {
    case sun = 0, moon = 1, mercury = 2, venus = 3, mars = 4, jupiter = 5, saturn = 6

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
    var r = x.truncatingRemainder(dividingBy: 360.0)
    if r < 0 { r += 360.0 }
    return r
}

func signedShortestDelta(from a: Double, to b: Double) -> Double {
    var d = normalize(b) - normalize(a)
    if d > 180 { d -= 360 }
    if d < -180 { d += 360 }
    return d
}

func circularErrorDegrees(_ a: Double, _ b: Double) -> Double {
    abs(signedShortestDelta(from: a, to: b))
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

    static let SWIEPH: Int32 = 2
    static let MOSEPH: Int32 = 4
    static let SPEED: Int32 = 256

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
        epheDir.withCString { localSetPath($0) }
        var vbuf = [CChar](repeating: 0, count: 128)
        _ = vbuf.withUnsafeMutableBufferPointer { localVersionFn($0.baseAddress) }
        setPath = localSetPath
        calcUT = localCalcUT
        versionFn = localVersionFn
        version = String(cString: vbuf)
    }

    deinit { dlclose(handle) }

    func state(_ body: Body, jd: Double) throws -> State {
        var xx = [Double](repeating: 0, count: 6)
        var err = [CChar](repeating: 0, count: 256)
        let flags = Swiss.SWIEPH | Swiss.SPEED
        let returned = xx.withUnsafeMutableBufferPointer { xp in
            err.withUnsafeMutableBufferPointer { ep in
                calcUT(jd, body.rawValue, flags, xp.baseAddress, ep.baseAddress)
            }
        }
        if returned < 0 || (returned & Swiss.SWIEPH) == 0 || (returned & Swiss.MOSEPH) != 0 {
            throw POCError.swiss("Swiss calculation failed for \(body.name) @ \(jd): \(String(cString: err)); flags=\(returned)")
        }
        return State(longitude: normalize(xx[0]), speed: xx[3])
    }
}

struct AspectTarget {
    let orientedDegrees: Double
    let aspect: String
    let ringDegrees: Int
    let orientation: String
}

let aspectTargets: [AspectTarget] = [
    AspectTarget(orientedDegrees: 0, aspect: "conjunction", ringDegrees: 0, orientation: "same_degree"),
    AspectTarget(orientedDegrees: 60, aspect: "sextile", ringDegrees: 60, orientation: "bodyA_ahead_60"),
    AspectTarget(orientedDegrees: 90, aspect: "square", ringDegrees: 90, orientation: "bodyA_ahead_90"),
    AspectTarget(orientedDegrees: 120, aspect: "trine", ringDegrees: 120, orientation: "bodyA_ahead_120"),
    AspectTarget(orientedDegrees: 180, aspect: "opposition", ringDegrees: 180, orientation: "opposite_degree"),
    AspectTarget(orientedDegrees: 240, aspect: "trine", ringDegrees: 120, orientation: "bodyB_ahead_120"),
    AspectTarget(orientedDegrees: 270, aspect: "square", ringDegrees: 90, orientation: "bodyB_ahead_90"),
    AspectTarget(orientedDegrees: 300, aspect: "sextile", ringDegrees: 60, orientation: "bodyB_ahead_60"),
]

struct PairKey: Hashable {
    let a: Body
    let b: Body
}

struct PairProgress {
    var previousRaw: Double
    var previousUnwrapped: Double
}

struct CelestialTime: Codable {
    let longitudeDegrees: Double
    let wholeDegree: Int
    let tenthDegreeTick: Int
}

struct CivicTime: Codable {
    let julianDayUT: Double
    let utOffsetSeconds: UInt32
}

struct TransitEvent: Codable {
    let bodyA: String
    let bodyB: String
    let aspect: String
    let ringDegrees: Int
    let orientation: String
    let bodyACelestialTime: CelestialTime
    let bodyBCelestialTime: CelestialTime
    let civicTime: CivicTime
    let exactAspectResidualArcSeconds: Double
}

struct PairSummary: Codable {
    let pair: String
    let events: Int
}

struct MarkerResolutionSummary: Codable {
    let resolutionDegrees: Double
    let events: Int
    let uniqueKeys: Int
    let repeatedKeys: Int
    let rowsInRepeatedKeys: Int
}

struct Summary: Codable {
    let status: String
    let framing: String
    let astronomicalSource: String
    let swissVersion: String
    let saturnStartJulianDayUT: Double
    let saturnEndJulianDayUT: Double
    let durationDays: Double
    let scanStepDays: Double
    let exactTransitEvents: Int
    let structuralCrossConnections: Int
    let byAspect: [String: Int]
    let byPair: [PairSummary]
    let eventsInvolvingMoon: Int
    let moonEventShare: Double
    let averageEventsPerDay: Double
    let averageStructuralCrossConnectionsPerDay: Double
    let flatRecordBytesAt8PerEvent: Int
    let explicitTwoCelestialTimesBytesAt10PerEvent: Int
    let groupedRecordBytesAt6PerEvent: Int
    let markerIdentity: [MarkerResolutionSummary]
    let visualization: String
}

struct PathPoint {
    let body: Body
    let jd: Double
    let longitude: Double
}

let saturnStartJD = 2439553.3967229538
let saturnEndJD = 2450180.8673149766
let scanStepDays = 0.1
let pathSampleEvery = 20  // every 2 days at the current scan step

func celestialTime(_ longitude: Double) -> CelestialTime {
    let lon = normalize(longitude)
    return CelestialTime(
        longitudeDegrees: lon,
        wholeDegree: Int(floor(lon)),
        tenthDegreeTick: Int(floor(lon * 10.0 + 1e-9)) % 3600
    )
}

func civicTime(_ jd: Double) -> CivicTime {
    let seconds = UInt32(max(0, min(Double(UInt32.max), ((jd - saturnStartJD) * 86_400.0).rounded())))
    return CivicTime(julianDayUT: jd, utOffsetSeconds: seconds)
}

func parseArgs() throws -> (library: String, epheDir: String, outputDir: String) {
    var library: String?
    var epheDir: String?
    var outputDir: String?
    var i = 1
    let args = CommandLine.arguments
    while i < args.count {
        switch args[i] {
        case "--library": i += 1; if i < args.count { library = args[i] }
        case "--ephe-dir": i += 1; if i < args.count { epheDir = args[i] }
        case "--output-dir": i += 1; if i < args.count { outputDir = args[i] }
        default: break
        }
        i += 1
    }
    guard let l = library, let e = epheDir, let o = outputDir else {
        throw POCError.usage("Usage: ExactMundaneTransitPOC --library <libswe> --ephe-dir <dir> --output-dir <dir>")
    }
    return (l, e, o)
}

func pairKeys() -> [PairKey] {
    var pairs: [PairKey] = []
    let bodies = Body.allCases
    for i in 0..<(bodies.count - 1) {
        for j in (i + 1)..<bodies.count {
            pairs.append(PairKey(a: bodies[i], b: bodies[j]))
        }
    }
    return pairs
}

func stateMap(_ swiss: Swiss, jd: Double) throws -> [Body: State] {
    var result: [Body: State] = [:]
    for body in Body.allCases { result[body] = try swiss.state(body, jd: jd) }
    return result
}

func relativeUnwrappedNear(bodyA: Body, bodyB: Body, jd: Double, target: Double, swiss: Swiss) throws -> Double {
    let a = try swiss.state(bodyA, jd: jd).longitude
    let b = try swiss.state(bodyB, jd: jd).longitude
    let raw = normalize(a - b)
    return raw + 360.0 * round((target - raw) / 360.0)
}

func refineTransit(pair: PairKey, target: Double, lo initialLo: Double, hi initialHi: Double, swiss: Swiss) throws -> Double {
    var lo = initialLo
    var hi = initialHi
    var glo = try relativeUnwrappedNear(bodyA: pair.a, bodyB: pair.b, jd: lo, target: target, swiss: swiss) - target
    var ghi = try relativeUnwrappedNear(bodyA: pair.a, bodyB: pair.b, jd: hi, target: target, swiss: swiss) - target

    if abs(glo) < 1e-12 { return lo }
    if abs(ghi) < 1e-12 { return hi }
    if glo * ghi > 0 {
        // The scan bracket should contain a crossing. Linear fallback keeps the POC explicit
        // rather than silently dropping the event if floating wrap choice lands badly.
        return lo + (hi - lo) * abs(glo) / (abs(glo) + abs(ghi))
    }

    for _ in 0..<56 {
        let mid = (lo + hi) / 2.0
        let gm = try relativeUnwrappedNear(bodyA: pair.a, bodyB: pair.b, jd: mid, target: target, swiss: swiss) - target
        if abs(gm) < 1e-11 || (hi - lo) < 1e-10 { return mid }
        if glo * gm <= 0 {
            hi = mid
            ghi = gm
        } else {
            lo = mid
            glo = gm
        }
    }
    return (lo + hi) / 2.0
}

func targetCrossings(previous: Double, current: Double, target: AspectTarget) -> [Double] {
    var result: [Double] = []
    let base = target.orientedDegrees
    if current > previous {
        let first = Int(floor((previous - base) / 360.0)) + 1
        let last = Int(floor((current - base) / 360.0))
        if first <= last {
            for k in first...last { result.append(base + Double(k) * 360.0) }
        }
    } else if current < previous {
        let first = Int(ceil((previous - base) / 360.0)) - 1
        let last = Int(ceil((current - base) / 360.0))
        if first >= last {
            for k in stride(from: first, through: last, by: -1) { result.append(base + Double(k) * 360.0) }
        }
    }
    return result
}

func findTarget(_ absoluteTarget: Double) -> AspectTarget {
    let oriented = normalize(absoluteTarget)
    return aspectTargets.min(by: { abs($0.orientedDegrees - oriented) < abs($1.orientedDegrees - oriented) })!
}

func csvEscape(_ value: String) -> String {
    if value.contains(",") || value.contains("\"") || value.contains("\n") {
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
    return value
}

func writeCSV(events: [TransitEvent], to url: URL) throws {
    var out = "bodyA,bodyB,aspect,ringDegrees,orientation,bodyACelestialTimeDegrees,bodyBCelestialTimeDegrees,civicTimeJulianDayUT,civicTimeOffsetSeconds,exactAspectResidualArcSeconds\n"
    for e in events {
        out += [
            e.bodyA, e.bodyB, e.aspect, String(e.ringDegrees), e.orientation,
            String(format: "%.9f", e.bodyACelestialTime.longitudeDegrees),
            String(format: "%.9f", e.bodyBCelestialTime.longitudeDegrees),
            String(format: "%.12f", e.civicTime.julianDayUT),
            String(e.civicTime.utOffsetSeconds),
            String(format: "%.6f", e.exactAspectResidualArcSeconds),
        ].map(csvEscape).joined(separator: ",") + "\n"
    }
    try out.write(to: url, atomically: true, encoding: .utf8)
}

func markerSummary(events: [TransitEvent], resolution: Double) -> MarkerResolutionSummary {
    var counts: [String: Int] = [:]
    for e in events {
        let tick = Int(floor(e.bodyACelestialTime.longitudeDegrees / resolution + 1e-9))
        let key = "\(e.bodyA)|\(e.bodyB)|\(e.aspect)|\(e.orientation)|\(tick)"
        counts[key, default: 0] += 1
    }
    let repeated = counts.values.filter { $0 > 1 }
    return MarkerResolutionSummary(
        resolutionDegrees: resolution,
        events: events.count,
        uniqueKeys: counts.values.filter { $0 == 1 }.count,
        repeatedKeys: repeated.count,
        rowsInRepeatedKeys: repeated.reduce(0, +)
    )
}

func project(longitude: Double, jd: Double, body: Body, width: Double, height: Double) -> (Double, Double) {
    let theta = longitude * Double.pi / 180.0
    let radius = 215.0 + Double(body.rawValue) * 11.0
    let x3 = radius * cos(theta)
    let y3 = radius * sin(theta)
    let z = (jd - saturnStartJD) / (saturnEndJD - saturnStartJD)
    let x = width / 2.0 + x3 + 0.42 * y3
    let y = 70.0 + z * (height - 140.0) + 0.20 * y3
    return (x, y)
}

func svgFor(events: [TransitEvent], paths: [Body: [PathPoint]], structuralOnly: Bool) -> String {
    let width = 1400.0
    let height = 2400.0
    let included = structuralOnly ? Set(["square", "trine", "opposition"]) : Set(["conjunction", "sextile", "square", "trine", "opposition"])
    var out = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"1400\" height=\"2400\" viewBox=\"0 0 1400 2400\">\n"
    out += "<rect width=\"1400\" height=\"2400\" fill=\"white\"/>\n"
    out += "<text x=\"40\" y=\"38\" font-family=\"Helvetica,Arial,sans-serif\" font-size=\"22\">Saturn vertebra: planetary celestial-time paths + exact mundane transit cross-connections</text>\n"
    out += "<text x=\"40\" y=\"62\" font-family=\"Helvetica,Arial,sans-serif\" font-size=\"14\">Time runs top to bottom. Zodiacal longitude wraps around the projected cylinder. Exact aspects join two planetary paths at the same civic UT.</text>\n"

    let bodyByName = Dictionary(uniqueKeysWithValues: Body.allCases.map { ($0.name, $0) })
    for e in events where included.contains(e.aspect) {
        guard let a = bodyByName[e.bodyA], let b = bodyByName[e.bodyB] else { continue }
        let p1 = project(longitude: e.bodyACelestialTime.longitudeDegrees, jd: e.civicTime.julianDayUT, body: a, width: width, height: height)
        let p2 = project(longitude: e.bodyBCelestialTime.longitudeDegrees, jd: e.civicTime.julianDayUT, body: b, width: width, height: height)
        let opacity: Double
        let lineWidth: Double
        switch e.aspect {
        case "opposition": opacity = 0.16; lineWidth = 0.55
        case "square": opacity = 0.13; lineWidth = 0.45
        case "trine": opacity = 0.11; lineWidth = 0.40
        case "sextile": opacity = 0.07; lineWidth = 0.35
        default: opacity = 0.09; lineWidth = 0.35
        }
        out += String(format: "<line x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\" stroke=\"black\" stroke-opacity=\"%.3f\" stroke-width=\"%.2f\"/>\n", p1.0, p1.1, p2.0, p2.1, opacity, lineWidth)
    }

    let dashPatterns = ["", "6 3", "2 3", "8 3 2 3", "12 4", "3 2", "10 2 2 2"]
    for body in Body.allCases {
        guard let pts = paths[body], !pts.isEmpty else { continue }
        var d = ""
        for (i, p) in pts.enumerated() {
            let q = project(longitude: p.longitude, jd: p.jd, body: body, width: width, height: height)
            d += String(format: "%@%.2f %.2f ", i == 0 ? "M" : "L", q.0, q.1)
        }
        let dash = dashPatterns[Int(body.rawValue)]
        let dashAttr = dash.isEmpty ? "" : " stroke-dasharray=\"\(dash)\""
        out += "<path d=\"\(d)\" fill=\"none\" stroke=\"black\" stroke-width=\"1.25\" stroke-opacity=\"0.72\"\(dashAttr)/>\n"
    }

    var legendY = 94
    for body in Body.allCases {
        out += "<text x=\"1120\" y=\"\(legendY)\" font-family=\"Helvetica,Arial,sans-serif\" font-size=\"12\">\(body.name)</text>\n"
        legendY += 17
    }
    out += "</svg>\n"
    return out
}

func main() throws {
    let args = try parseArgs()
    let swiss = try Swiss(library: args.library, epheDir: args.epheDir)
    let outputDir = URL(fileURLWithPath: args.outputDir)
    try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

    let pairs = pairKeys()
    let initialStates = try stateMap(swiss, jd: saturnStartJD)
    var progress: [PairKey: PairProgress] = [:]
    for pair in pairs {
        let raw = normalize(initialStates[pair.a]!.longitude - initialStates[pair.b]!.longitude)
        progress[pair] = PairProgress(previousRaw: raw, previousUnwrapped: raw)
    }

    var paths: [Body: [PathPoint]] = [:]
    for body in Body.allCases {
        paths[body] = [PathPoint(body: body, jd: saturnStartJD, longitude: initialStates[body]!.longitude)]
    }

    var events: [TransitEvent] = []
    var previousJD = saturnStartJD
    var sampleIndex = 0
    var jd = saturnStartJD + scanStepDays

    while previousJD < saturnEndJD {
        let currentJD = min(jd, saturnEndJD)
        let states = try stateMap(swiss, jd: currentJD)
        sampleIndex += 1

        if sampleIndex % pathSampleEvery == 0 || currentJD >= saturnEndJD {
            for body in Body.allCases {
                paths[body, default: []].append(PathPoint(body: body, jd: currentJD, longitude: states[body]!.longitude))
            }
        }

        for pair in pairs {
            guard var p = progress[pair] else { continue }
            let currentRaw = normalize(states[pair.a]!.longitude - states[pair.b]!.longitude)
            let currentUnwrapped = p.previousUnwrapped + signedShortestDelta(from: p.previousRaw, to: currentRaw)

            for targetDef in aspectTargets {
                let crossings = targetCrossings(previous: p.previousUnwrapped, current: currentUnwrapped, target: targetDef)
                for absoluteTarget in crossings {
                    let exactJD = try refineTransit(pair: pair, target: absoluteTarget, lo: previousJD, hi: currentJD, swiss: swiss)
                    let aState = try swiss.state(pair.a, jd: exactJD)
                    let bState = try swiss.state(pair.b, jd: exactJD)
                    let actualOriented = normalize(aState.longitude - bState.longitude)
                    let expected = normalize(absoluteTarget)
                    let residual = circularErrorDegrees(actualOriented, expected) * 3600.0
                    let resolvedDef = findTarget(absoluteTarget)
                    events.append(TransitEvent(
                        bodyA: pair.a.name,
                        bodyB: pair.b.name,
                        aspect: resolvedDef.aspect,
                        ringDegrees: resolvedDef.ringDegrees,
                        orientation: resolvedDef.orientation,
                        bodyACelestialTime: celestialTime(aState.longitude),
                        bodyBCelestialTime: celestialTime(bState.longitude),
                        civicTime: civicTime(exactJD),
                        exactAspectResidualArcSeconds: residual
                    ))
                }
            }

            p.previousRaw = currentRaw
            p.previousUnwrapped = currentUnwrapped
            progress[pair] = p
        }

        previousJD = currentJD
        if currentJD >= saturnEndJD { break }
        jd += scanStepDays
    }

    events.sort { lhs, rhs in
        if lhs.civicTime.julianDayUT != rhs.civicTime.julianDayUT { return lhs.civicTime.julianDayUT < rhs.civicTime.julianDayUT }
        if lhs.bodyA != rhs.bodyA { return lhs.bodyA < rhs.bodyA }
        if lhs.bodyB != rhs.bodyB { return lhs.bodyB < rhs.bodyB }
        return lhs.aspect < rhs.aspect
    }

    // Defensive de-duplication for exact hits landing on scan boundaries.
    var deduped: [TransitEvent] = []
    for e in events {
        if let last = deduped.last,
           last.bodyA == e.bodyA,
           last.bodyB == e.bodyB,
           last.aspect == e.aspect,
           last.orientation == e.orientation,
           abs(last.civicTime.julianDayUT - e.civicTime.julianDayUT) < 1e-7 {
            continue
        }
        deduped.append(e)
    }
    events = deduped

    var aspectCounts: [String: Int] = [:]
    var pairCounts: [String: Int] = [:]
    var moonEvents = 0
    var structural = 0
    for e in events {
        aspectCounts[e.aspect, default: 0] += 1
        let pair = "\(e.bodyA)-\(e.bodyB)"
        pairCounts[pair, default: 0] += 1
        if e.bodyA == "Moon" || e.bodyB == "Moon" { moonEvents += 1 }
        if e.aspect == "square" || e.aspect == "trine" || e.aspect == "opposition" { structural += 1 }
    }

    try writeCSV(events: events, to: outputDir.appendingPathComponent("exact-mundane-transits.csv"))

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    try encoder.encode(events).write(to: outputDir.appendingPathComponent("exact-mundane-transits.json"))

    let allSVG = svgFor(events: events, paths: paths, structuralOnly: false)
    try allSVG.write(to: outputDir.appendingPathComponent("slinky-all-exact-aspects.svg"), atomically: true, encoding: .utf8)
    let structuralSVG = svgFor(events: events, paths: paths, structuralOnly: true)
    try structuralSVG.write(to: outputDir.appendingPathComponent("slinky-square-trine-opposition.svg"), atomically: true, encoding: .utf8)

    let duration = saturnEndJD - saturnStartJD
    let summary = Summary(
        status: "Construction-time exact mundane transit lattice learning specimen",
        framing: "Each exact transit is a cross-connection between two planetary celestial-time paths at one civic UT. The Ring relationship is exact (0-degree orb); the two celestial times and their shared civic time are recorded.",
        astronomicalSource: "Swiss Ephemeris; geocentric tropical apparent ecliptic longitude; UT; exact Ptolemaic aspects 0/60/90/120/180 degrees",
        swissVersion: swiss.version,
        saturnStartJulianDayUT: saturnStartJD,
        saturnEndJulianDayUT: saturnEndJD,
        durationDays: duration,
        scanStepDays: scanStepDays,
        exactTransitEvents: events.count,
        structuralCrossConnections: structural,
        byAspect: aspectCounts,
        byPair: pairCounts.sorted { $0.key < $1.key }.map { PairSummary(pair: $0.key, events: $0.value) },
        eventsInvolvingMoon: moonEvents,
        moonEventShare: events.isEmpty ? 0 : Double(moonEvents) / Double(events.count),
        averageEventsPerDay: Double(events.count) / duration,
        averageStructuralCrossConnectionsPerDay: Double(structural) / duration,
        flatRecordBytesAt8PerEvent: events.count * 8,
        explicitTwoCelestialTimesBytesAt10PerEvent: events.count * 10,
        groupedRecordBytesAt6PerEvent: events.count * 6,
        markerIdentity: [markerSummary(events: events, resolution: 1.0), markerSummary(events: events, resolution: 0.1)],
        visualization: "Two SVG projections are emitted. Planetary celestial-time paths wrap through the Saturn vertebra; exact transit events are chords joining the two paths at their shared civic UT. One SVG shows all exact major aspects; one isolates square/trine/opposition cross-bracing."
    )
    try encoder.encode(summary).write(to: outputDir.appendingPathComponent("summary.json"))

    print("Exact mundane transit events: \(events.count)")
    print("Structural square/trine/opposition cross-connections: \(structural)")
    print("Moon-involving events: \(moonEvents) (\(String(format: "%.2f", summary.moonEventShare * 100))%)")
    print("Grouped 6-byte estimate: \(summary.groupedRecordBytesAt6PerEvent) bytes")
    print("Aspect counts: \(aspectCounts)")
}

do {
    try main()
} catch {
    fputs("ExactMundaneTransitPOC failed: \(error)\n", stderr)
    exit(1)
}
