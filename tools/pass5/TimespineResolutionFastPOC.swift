import Foundation
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

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

struct State { let longitude: Double }

func normalize(_ x: Double) -> Double {
    var r = x.truncatingRemainder(dividingBy: 360)
    if r < 0 { r += 360 }
    return r
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
    static let SWIEPH: Int32 = 2
    static let MOSEPH: Int32 = 4
    static let SPEED: Int32 = 256

    init(library: String, epheDir: String) throws {
        guard let h = dlopen(library, RTLD_NOW | RTLD_LOCAL) else { throw NSError(domain: "dlopen", code: 1) }
        handle = h
        func sym<T>(_ name: String, _ type: T.Type) throws -> T {
            guard let p = dlsym(h, name) else { throw NSError(domain: "dlsym", code: 2) }
            return unsafeBitCast(p, to: T.self)
        }
        let sp: SweSetEphePath = try sym("swe_set_ephe_path", SweSetEphePath.self)
        let cu: SweCalcUT = try sym("swe_calc_ut", SweCalcUT.self)
        let vf: SweVersion = try sym("swe_version", SweVersion.self)
        epheDir.withCString { sp($0) }
        var buf = [CChar](repeating: 0, count: 128)
        _ = buf.withUnsafeMutableBufferPointer { vf($0.baseAddress) }
        setPath = sp
        calcUT = cu
        versionFn = vf
        version = String(cString: buf)
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
            throw NSError(domain: "Swiss", code: Int(returned), userInfo: [NSLocalizedDescriptionKey: String(cString: err)])
        }
        return State(longitude: normalize(xx[0]))
    }
}

let saturnStartJD = 2439553.3967229538
let saturnEndJD = 2450180.8673149766
let sampleStepDays = 0.1
let highStep = 0.1

struct Bucket {
    let key: String
    let label: String
    let degrees: Double
    var relative = Data()
    var direct = Data()
    var count = 0
}

struct BodyResult: Codable {
    let body: String
    let lowRecords: Int
    let mediumRecords: Int
    let highRecords: Int
}

struct ResolutionResult: Codable {
    let label: String
    let degrees: Double
    let records: Int
    let relativeSecondsBytes: Int
    let directJulianDayBytes: Int
    let moonRecordShare: Double
    let byBody: [String: Int]
}

struct Summary: Codable {
    let status: String
    let swissVersion: String
    let astronomicalSource: String
    let saturnStartJulianDay: Double
    let saturnEndJulianDay: Double
    let durationDays: Double
    let sampleStepDays: Double
    let timingMethod: String
    let relativeRecordLayout: String
    let directRecordLayout: String
    let resolutions: [ResolutionResult]
}

func mod(_ value: Int, _ modulus: Int) -> Int {
    let r = value % modulus
    return r >= 0 ? r : r + modulus
}

func appendU16(_ value: UInt16, _ data: inout Data) {
    var v = value.littleEndian
    withUnsafeBytes(of: &v) { data.append(contentsOf: $0) }
}

func appendU32(_ value: UInt32, _ data: inout Data) {
    var v = value.littleEndian
    withUnsafeBytes(of: &v) { data.append(contentsOf: $0) }
}

func appendF64(_ value: Double, _ data: inout Data) {
    var v = value.bitPattern.littleEndian
    withUnsafeBytes(of: &v) { data.append(contentsOf: $0) }
}

func addRecord(jd: Double, tick: UInt16, to bucket: inout Bucket) {
    let seconds = UInt32(max(0, min(Double(UInt32.max), ((jd - saturnStartJD) * 86_400).rounded())))
    appendU32(seconds, &bucket.relative)
    appendU16(tick, &bucket.relative)
    appendF64(jd, &bucket.direct)
    appendU16(tick, &bucket.direct)
    bucket.count += 1
}

func parseArgs() -> (String, String, String)? {
    var library: String?, ephe: String?, output: String?
    var i = 1
    while i < CommandLine.arguments.count {
        switch CommandLine.arguments[i] {
        case "--library": i += 1; if i < CommandLine.arguments.count { library = CommandLine.arguments[i] }
        case "--ephe-dir": i += 1; if i < CommandLine.arguments.count { ephe = CommandLine.arguments[i] }
        case "--output-dir": i += 1; if i < CommandLine.arguments.count { output = CommandLine.arguments[i] }
        default: break
        }
        i += 1
    }
    if let library, let ephe, let output { return (library, ephe, output) }
    return nil
}

func process(_ body: Body, swiss: Swiss, root: URL) throws -> BodyResult {
    var low = Bucket(key: "low-1deg", label: "Low", degrees: 1.0)
    var medium = Bucket(key: "medium-0_5deg", label: "Medium", degrees: 0.5)
    var high = Bucket(key: "high-0_1deg", label: "High", degrees: 0.1)

    var previousJD = saturnStartJD
    var previousLongitude = try swiss.state(body, jd: previousJD).longitude
    var previousUnwrapped = previousLongitude
    var jd = saturnStartJD + sampleStepDays
    var samples = 1

    while true {
        let currentJD = min(jd, saturnEndJD)
        let currentLongitude = try swiss.state(body, jd: currentJD).longitude
        let currentUnwrapped = previousUnwrapped + signedShortestDelta(from: previousLongitude, to: currentLongitude)
        let delta = currentUnwrapped - previousUnwrapped

        if abs(delta) > 1e-14 {
            if delta > 0 {
                let first = Int(floor(previousUnwrapped / highStep)) + 1
                let last = Int(floor(currentUnwrapped / highStep))
                if first <= last {
                    for k in first...last {
                        let target = Double(k) * highStep
                        let f = (target - previousUnwrapped) / delta
                        let crossingJD = previousJD + f * (currentJD - previousJD)
                        let ht = mod(k, 3600)
                        addRecord(jd: crossingJD, tick: UInt16(ht), to: &high)
                        if ht % 5 == 0 { addRecord(jd: crossingJD, tick: UInt16(mod(k / 5, 720)), to: &medium) }
                        if ht % 10 == 0 { addRecord(jd: crossingJD, tick: UInt16(mod(k / 10, 360)), to: &low) }
                    }
                }
            } else {
                let first = Int(ceil(previousUnwrapped / highStep)) - 1
                let last = Int(ceil(currentUnwrapped / highStep))
                if first >= last {
                    for k in stride(from: first, through: last, by: -1) {
                        let target = Double(k) * highStep
                        let f = (target - previousUnwrapped) / delta
                        let crossingJD = previousJD + f * (currentJD - previousJD)
                        let ht = mod(k, 3600)
                        addRecord(jd: crossingJD, tick: UInt16(ht), to: &high)
                        if ht % 5 == 0 { addRecord(jd: crossingJD, tick: UInt16(mod(k / 5, 720)), to: &medium) }
                        if ht % 10 == 0 { addRecord(jd: crossingJD, tick: UInt16(mod(k / 10, 360)), to: &low) }
                    }
                }
            }
        }

        previousJD = currentJD
        previousLongitude = currentLongitude
        previousUnwrapped = currentUnwrapped
        samples += 1
        if currentJD >= saturnEndJD { break }
        jd += sampleStepDays
    }

    for bucket in [low, medium, high] {
        let dir = root.appendingPathComponent(bucket.key)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try bucket.relative.write(to: dir.appendingPathComponent("\(body.name).relative.bin"))
        try bucket.direct.write(to: dir.appendingPathComponent("\(body.name).direct-jd.bin"))
    }

    print("\(body.name): samples=\(samples) low=\(low.count) medium=\(medium.count) high=\(high.count)")
    return BodyResult(body: body.name, lowRecords: low.count, mediumRecords: medium.count, highRecords: high.count)
}

func main() throws {
    guard let (library, ephe, output) = parseArgs() else {
        fputs("usage: TimespineResolutionFastPOC --library <lib> --ephe-dir <dir> --output-dir <dir>\n", stderr)
        exit(2)
    }
    let swiss = try Swiss(library: library, epheDir: ephe)
    let root = URL(fileURLWithPath: output)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    var bodies: [BodyResult] = []
    for body in Body.allCases { bodies.append(try process(body, swiss: swiss, root: root)) }

    func resolution(label: String, degrees: Double, keyPath: KeyPath<BodyResult, Int>) -> ResolutionResult {
        let map = Dictionary(uniqueKeysWithValues: bodies.map { ($0.body, $0[keyPath: keyPath]) })
        let records = map.values.reduce(0, +)
        let moon = map["Moon"] ?? 0
        return ResolutionResult(
            label: label,
            degrees: degrees,
            records: records,
            relativeSecondsBytes: records * 6,
            directJulianDayBytes: records * 10,
            moonRecordShare: records == 0 ? 0 : Double(moon) / Double(records),
            byBody: map
        )
    }

    let summary = Summary(
        status: "Storage-resolution learning specimen; not canonical Timespine serialization",
        swissVersion: swiss.version,
        astronomicalSource: "Swiss Ephemeris; geocentric tropical apparent ecliptic longitude; UT",
        saturnStartJulianDay: saturnStartJD,
        saturnEndJulianDay: saturnEndJD,
        durationDays: saturnEndJD - saturnStartJD,
        sampleStepDays: sampleStepDays,
        timingMethod: "0.1-degree crossings linearly interpolated between 0.1-day Swiss samples; 0.5-degree and 1-degree tables are subsets. Intended to measure record count and storage size, not final crossing-time precision.",
        relativeRecordLayout: "6 bytes: UInt32 seconds since Saturn-bound start UT + UInt16 degree tick",
        directRecordLayout: "10 bytes: Float64 Julian Day UT + UInt16 degree tick",
        resolutions: [
            resolution(label: "Low", degrees: 1.0, keyPath: \.lowRecords),
            resolution(label: "Medium", degrees: 0.5, keyPath: \.mediumRecords),
            resolution(label: "High", degrees: 0.1, keyPath: \.highRecords)
        ]
    )

    let enc = JSONEncoder()
    enc.outputFormatting = [.prettyPrinted, .sortedKeys]
    try enc.encode(summary).write(to: root.appendingPathComponent("summary.json"))
    for r in summary.resolutions {
        let moonPct = r.moonRecordShare * 100
        print("TOTAL \(r.label) \(r.degrees) deg: records=\(r.records) relative=\(r.relativeSecondsBytes) direct=\(r.directJulianDayBytes) moon=\(String(format: "%.2f", moonPct))%")
    }
}

do { try main() } catch {
    fputs("TimespineResolutionFastPOC failed: \(error)\n", stderr)
    exit(1)
}
