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
    case solve(String)
    case io(String)

    var description: String {
        switch self {
        case .usage(let s), .dl(let s), .swiss(let s), .solve(let s), .io(let s): return s
        }
    }
}

enum Body: Int32, CaseIterable, Codable {
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

struct State: Codable {
    let longitude: Double
    let speed: Double
    var motion: String { speed < 0 ? "retrograde" : "direct" }
    var degreeCell: Int { Int(floor(normalize(longitude))) }
}

func normalize(_ x: Double) -> Double {
    var r = x.truncatingRemainder(dividingBy: 360)
    if r < 0 { r += 360 }
    return r == 0 ? 0 : r
}

func signedShortestDelta(from a: Double, to b: Double) -> Double {
    var d = normalize(b) - normalize(a)
    if d > 180 { d -= 360 }
    if d < -180 { d += 360 }
    return d
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

struct Sample {
    let jd: Double
    let longitude: Double
    let unwrapped: Double
    let speed: Double
}

struct RevolutionBoundary: Codable {
    let ordinal: Int
    let julianDay: Double
    let unwrappedLongitude: Double
    let rawLongitude: Double
}

struct Revolution: Codable {
    let ordinal: Int
    let startJulianDay: Double
    let endJulianDay: Double
}

struct PassSnapshot: Codable {
    struct BodySnapshot: Codable {
        let longitude: Double
        let degreeCell: Int
        let motion: String
        let excludedDegreeCells: Int
    }
    let body: String
    let zodiacDegree: Int
    let julianDay: Double
    let motion: String
    let sky: [String: BodySnapshot]
    let differsFromOtherPassesBy: [String]
}

struct POCOutput: Codable {
    struct Focus: Codable {
        let sunStartJulianDay: Double
        let sunEndJulianDay: Double
    }
    struct SaturnVertebra: Codable {
        let startJulianDay: Double
        let endJulianDay: Double
        let durationDays: Double
    }
    struct BodyRevolutions: Codable {
        let body: String
        let revolutionCount: Int
        let revolutions: [Revolution]
    }
    let status: String
    let governingIdea: String
    let astronomicalSource: String
    let swissVersion: String
    let focus: Focus
    let saturnVertebra: SaturnVertebra
    let bodyRevolutions: [BodyRevolutions]
    let mercury8AriesWithinSaturnVertebra: [PassSnapshot]
    let focalMercuryDegreeWithMostPasses: Int
    let focalMercuryRepeatedPasses: [PassSnapshot]
    let learning: [String]
}

func gregorianJD(year: Int, month: Int, day: Int, hour: Double = 0) -> Double {
    var y = year
    var m = month
    if m <= 2 { y -= 1; m += 12 }
    let a = Int(floor(Double(y) / 100.0))
    let b = 2 - a + Int(floor(Double(a) / 4.0))
    let jd0 = floor(365.25 * Double(y + 4716)) + floor(30.6001 * Double(m + 1)) + Double(day + b) - 1524.5
    return jd0 + hour / 24.0
}

func sampleBody(_ body: Body, from start: Double, to end: Double, step: Double, swiss: Swiss) throws -> [Sample] {
    precondition(step > 0 && start < end)
    var result: [Sample] = []
    var jd = start
    let first = try swiss.state(body, jd: jd)
    var unwrapped = first.longitude
    result.append(Sample(jd: jd, longitude: first.longitude, unwrapped: unwrapped, speed: first.speed))
    var previousLongitude = first.longitude
    while jd + step < end {
        jd += step
        let s = try swiss.state(body, jd: jd)
        unwrapped += signedShortestDelta(from: previousLongitude, to: s.longitude)
        result.append(Sample(jd: jd, longitude: s.longitude, unwrapped: unwrapped, speed: s.speed))
        previousLongitude = s.longitude
    }
    if result.last!.jd < end {
        jd = end
        let s = try swiss.state(body, jd: jd)
        unwrapped += signedShortestDelta(from: previousLongitude, to: s.longitude)
        result.append(Sample(jd: jd, longitude: s.longitude, unwrapped: unwrapped, speed: s.speed))
    }
    return result
}

func interpolateCrossing(_ a: Sample, _ b: Sample, target: Double, body: Body, swiss: Swiss) throws -> Double {
    var lo = a.jd
    var hi = b.jd
    let startUnwrapped = a.unwrapped
    for _ in 0..<55 {
        let mid = (lo + hi) / 2
        let state = try swiss.state(body, jd: mid)
        let midUnwrapped = startUnwrapped + signedShortestDelta(from: a.longitude, to: state.longitude)
        if midUnwrapped < target { lo = mid } else { hi = mid }
    }
    return (lo + hi) / 2
}

func revolutionBoundaries(samples: [Sample], body: Body, swiss: Swiss) throws -> [RevolutionBoundary] {
    guard samples.count >= 2 else { return [] }
    var boundaries: [RevolutionBoundary] = []
    var highestMultiple = Int(floor(samples[0].unwrapped / 360.0))
    for i in 1..<samples.count {
        let a = samples[i - 1]
        let b = samples[i]
        if b.unwrapped <= a.unwrapped { continue }
        while Double(highestMultiple + 1) * 360.0 <= b.unwrapped + 1e-10 {
            let target = Double(highestMultiple + 1) * 360.0
            if target >= a.unwrapped - 1e-10 {
                let jd = try interpolateCrossing(a, b, target: target, body: body, swiss: swiss)
                let state = try swiss.state(body, jd: jd)
                boundaries.append(.init(ordinal: highestMultiple + 1, julianDay: jd, unwrappedLongitude: target, rawLongitude: state.longitude))
            }
            highestMultiple += 1
        }
    }
    return boundaries
}

func revolutions(from boundaries: [RevolutionBoundary]) -> [Revolution] {
    guard boundaries.count >= 2 else { return [] }
    return zip(boundaries, boundaries.dropFirst()).map { a, b in
        Revolution(ordinal: a.ordinal, startJulianDay: a.julianDay, endJulianDay: b.julianDay)
    }
}

func findSolarFocus(year: Int, swiss: Swiss) throws -> (Double, Double) {
    let scanStart = gregorianJD(year: year - 1, month: 1, day: 1)
    let scanEnd = gregorianJD(year: year + 2, month: 1, day: 1)
    let samples = try sampleBody(.sun, from: scanStart, to: scanEnd, step: 1.0, swiss: swiss)
    let bounds = try revolutionBoundaries(samples: samples, body: .sun, swiss: swiss)
    let targetJD = gregorianJD(year: year, month: 3, day: 20)
    guard let startIndex = bounds.indices.min(by: { abs(bounds[$0].julianDay - targetJD) < abs(bounds[$1].julianDay - targetJD) }),
          startIndex + 1 < bounds.count else { throw POCError.solve("Could not resolve focal Sun revolution") }
    return (bounds[startIndex].julianDay, bounds[startIndex + 1].julianDay)
}

func crossingJDs(body: Body, degree: Int, samples: [Sample], swiss: Swiss, within range: ClosedRange<Double>) throws -> [Double] {
    guard degree >= 0 && degree < 360 else { return [] }
    var hits: [Double] = []
    for i in 1..<samples.count {
        let a = samples[i - 1]
        let b = samples[i]
        if b.jd < range.lowerBound || a.jd > range.upperBound { continue }
        let low = min(a.unwrapped, b.unwrapped)
        let high = max(a.unwrapped, b.unwrapped)
        let center = Int(floor(a.unwrapped / 360.0))
        for k in (center - 2)...(center + 2) {
            let target = Double(degree + k * 360)
            if target < low - 1e-10 || target > high + 1e-10 { continue }
            if abs(b.unwrapped - a.unwrapped) < 1e-12 { continue }
            var lo = a.jd
            var hi = b.jd
            let increasing = b.unwrapped > a.unwrapped
            for _ in 0..<55 {
                let mid = (lo + hi) / 2
                let state = try swiss.state(body, jd: mid)
                let midUnwrapped = a.unwrapped + signedShortestDelta(from: a.longitude, to: state.longitude)
                if increasing {
                    if midUnwrapped < target { lo = mid } else { hi = mid }
                } else {
                    if midUnwrapped > target { lo = mid } else { hi = mid }
                }
            }
            let hit = (lo + hi) / 2
            if hit >= range.lowerBound - 1e-8 && hit <= range.upperBound + 1e-8,
               !hits.contains(where: { abs($0 - hit) < 1e-7 }) {
                hits.append(hit)
            }
        }
    }
    return hits.sorted()
}

func rawSnapshots(body: Body, degree: Int, hitJDs: [Double], swiss: Swiss) throws -> [(jd: Double, motion: String, sky: [Body: State])] {
    var result: [(Double, String, [Body: State])] = []
    for jd in hitJDs {
        var sky: [Body: State] = [:]
        for b in Body.allCases { sky[b] = try swiss.state(b, jd: jd) }
        let motion = sky[body]!.motion
        result.append((jd, motion, sky))
    }
    return result
}

func passSnapshots(body: Body, degree: Int, hitJDs: [Double], swiss: Swiss) throws -> [PassSnapshot] {
    let raw = try rawSnapshots(body: body, degree: degree, hitJDs: hitJDs, swiss: swiss)
    var output: [PassSnapshot] = []
    for (index, item) in raw.enumerated() {
        var skyOut: [String: PassSnapshot.BodySnapshot] = [:]
        for b in Body.allCases {
            let s = item.sky[b]!
            skyOut[b.name] = .init(longitude: s.longitude, degreeCell: s.degreeCell, motion: s.motion, excludedDegreeCells: 359)
        }
        var differing: [String] = []
        for b in Body.allCases where b != body {
            let here = item.sky[b]!.degreeCell
            let differsFromEveryOther = raw.enumerated().filter { $0.offset != index }.allSatisfy { $0.element.sky[b]!.degreeCell != here }
            if differsFromEveryOther { differing.append(b.name) }
        }
        output.append(.init(body: body.name, zodiacDegree: degree, julianDay: item.jd, motion: item.motion, sky: skyOut, differsFromOtherPassesBy: differing))
    }
    return output
}

func parseArgs() throws -> (library: String, epheDir: String, output: String) {
    var library: String?
    var ephe: String?
    var output: String?
    var i = 1
    let args = CommandLine.arguments
    while i < args.count {
        switch args[i] {
        case "--library": i += 1; if i < args.count { library = args[i] }
        case "--ephe-dir": i += 1; if i < args.count { ephe = args[i] }
        case "--output": i += 1; if i < args.count { output = args[i] }
        default: break
        }
        i += 1
    }
    guard let l = library, let e = ephe, let o = output else {
        throw POCError.usage("usage: CelestialWebPOC --library <libswe> --ephe-dir <dir> --output <json>")
    }
    return (l, e, o)
}

func main() throws {
    let args = try parseArgs()
    let swiss = try Swiss(library: args.library, epheDir: args.epheDir)
    let focus = try findSolarFocus(year: 1985, swiss: swiss)

    let wideStart = gregorianJD(year: 1955, month: 1, day: 1)
    let wideEnd = gregorianJD(year: 2005, month: 1, day: 1)
    let saturnSamplesWide = try sampleBody(.saturn, from: wideStart, to: wideEnd, step: 1.0, swiss: swiss)
    let saturnBounds = try revolutionBoundaries(samples: saturnSamplesWide, body: .saturn, swiss: swiss)
    let saturnRevs = revolutions(from: saturnBounds)
    guard let vertebra = saturnRevs.first(where: { $0.startJulianDay <= focus.0 && $0.endJulianDay >= focus.1 }) else {
        throw POCError.solve("No Saturn 0-Aries-to-0-Aries vertebra contains the 1985 solar revolution")
    }

    let guardDays = 40.0
    let analysisStart = vertebra.startJulianDay - guardDays
    let analysisEnd = vertebra.endJulianDay + guardDays

    var samplesByBody: [Body: [Sample]] = [:]
    var bodyRevs: [POCOutput.BodyRevolutions] = []
    for body in Body.allCases {
        let step = body == .moon ? 0.125 : 0.5
        let samples = try sampleBody(body, from: analysisStart, to: analysisEnd, step: step, swiss: swiss)
        samplesByBody[body] = samples
        let bounds = try revolutionBoundaries(samples: samples, body: body, swiss: swiss)
        let all = revolutions(from: bounds)
        let overlapping = all.filter { $0.endJulianDay > vertebra.startJulianDay && $0.startJulianDay < vertebra.endJulianDay }
        bodyRevs.append(.init(body: body.name, revolutionCount: overlapping.count, revolutions: overlapping))
    }

    let mercurySamples = samplesByBody[.mercury]!
    let mercury8Hits = try crossingJDs(body: .mercury, degree: 8, samples: mercurySamples, swiss: swiss, within: vertebra.startJulianDay...vertebra.endJulianDay)
    let mercury8 = try passSnapshots(body: .mercury, degree: 8, hitJDs: mercury8Hits, swiss: swiss)

    var bestDegree = 0
    var bestHits: [Double] = []
    for degree in 0..<360 {
        let hits = try crossingJDs(body: .mercury, degree: degree, samples: mercurySamples, swiss: swiss, within: focus.0...focus.1)
        if hits.count > bestHits.count {
            bestDegree = degree
            bestHits = hits
        }
    }
    let focalRepeated = try passSnapshots(body: .mercury, degree: bestDegree, hitJDs: bestHits, swiss: swiss)

    let output = POCOutput(
        status: "learning specimen; no production ownership or representation canonized",
        governingIdea: "A Saturn 0-Aries-to-0-Aries revolution is a vertebra. Inner-body revolutions are overlapping flat slinky loops through the same nonrepeating whole-sky chronology. Positive location implies 359 absent degree-cells per body without storing explicit negatives.",
        astronomicalSource: "Swiss Ephemeris; geocentric tropical apparent longitude with signed speed",
        swissVersion: swiss.version,
        focus: .init(sunStartJulianDay: focus.0, sunEndJulianDay: focus.1),
        saturnVertebra: .init(startJulianDay: vertebra.startJulianDay, endJulianDay: vertebra.endJulianDay, durationDays: vertebra.endJulianDay - vertebra.startJulianDay),
        bodyRevolutions: bodyRevs,
        mercury8AriesWithinSaturnVertebra: mercury8,
        focalMercuryDegreeWithMostPasses: bestDegree,
        focalMercuryRepeatedPasses: focalRepeated,
        learning: [
            "A repeated Mercury degree is a repeated coordinate, not a repeated celestial state.",
            "Every occurrence is identified by the simultaneous Sun-through-Saturn coordinates.",
            "Where a body is implicitly specifies where it is not: one occupied degree-cell excludes the other 359.",
            "Retrograde loops create repeated raw-degree passes inside a revolution without creating a new revolution boundary.",
            "Revolution boundaries are successive record-forward unwrapped 0-Aries crossings, preserving the flat-slinky 0-to-360 geometry."
        ]
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    let data = try encoder.encode(output) + Data([0x0a])
    do { try data.write(to: URL(fileURLWithPath: args.output)) }
    catch { throw POCError.io("Could not write \(args.output): \(error)") }

    print("Swift Saturn-vertebra POC")
    print("Swiss \(swiss.version)")
    print(String(format: "Saturn vertebra %.9f -> %.9f (%.2f days)", vertebra.startJulianDay, vertebra.endJulianDay, vertebra.endJulianDay - vertebra.startJulianDay))
    for b in bodyRevs { print("\(b.body): \(b.revolutionCount) overlapping revolutions") }
    print("Mercury 8 Aries passes inside Saturn vertebra: \(mercury8.count)")
    print("Most-repeated Mercury integer degree inside focal solar loop: \(bestDegree) with \(bestHits.count) passes")
    for (i, pass) in focalRepeated.enumerated() {
        let sun = pass.sky["Sun"]!
        let venus = pass.sky["Venus"]!
        let mars = pass.sky["Mars"]!
        let jupiter = pass.sky["Jupiter"]!
        let saturn = pass.sky["Saturn"]!
        print(String(format: "  pass %d JD %.9f Mercury %@ | Sun %.3f Venus %.3f Mars %.3f Jupiter %.3f Saturn %.3f", i + 1, pass.julianDay, pass.motion, sun.longitude, venus.longitude, mars.longitude, jupiter.longitude, saturn.longitude))
    }
}

do {
    try main()
} catch {
    fputs("SATURN VERTEBRA POC FAILURE: \(error)\n", stderr)
    exit(1)
}
