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
    case io(String)

    var description: String {
        switch self {
        case .usage(let s), .dl(let s), .swiss(let s), .io(let s): return s
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

struct State {
    let longitude: Double
    let speed: Double
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

struct ResolutionSpec: Codable {
    let key: String
    let label: String
    let degrees: Double
    let highTickDivisor: Int
}

let resolutions: [ResolutionSpec] = [
    .init(key: "low-1deg", label: "Low", degrees: 1.0, highTickDivisor: 10),
    .init(key: "medium-0_5deg", label: "Medium", degrees: 0.5, highTickDivisor: 5),
    .init(key: "high-0_1deg", label: "High", degrees: 0.1, highTickDivisor: 1),
]

// Fixed testing ground established by the earlier Swift specimen.
let saturnStartJD = 2439553.3967229538
let saturnEndJD = 2450180.8673149766
let sampleStepDays = 0.05 // 72 minutes. Used to size tables, not declared canonical timing precision.
let highStepDegrees = 0.1

struct BodySummary: Codable {
    let body: String
    let records: Int
    let relativeSecondsBytes: Int
    let directJulianDayBytes: Int
}

struct ResolutionSummary: Codable {
    let key: String
    let label: String
    let degrees: Double
    let records: Int
    let relativeSecondsBytes: Int
    let directJulianDayBytes: Int
    let moonRecordShare: Double
    let byBody: [BodySummary]
}

struct Summary: Codable {
    let status: String
    let astronomicalSource: String
    let swissVersion: String
    let saturnStartJulianDay: Double
    let saturnEndJulianDay: Double
    let durationDays: Double
    let samplingStepDays: Double
    let timingMethod: String
    let storedRecordMeaning: String
    let relativeRecordLayout: String
    let directRecordLayout: String
    let resolutions: [ResolutionSummary]
}

struct OutputBuffers {
    var relative = Data()
    var direct = Data()
    var count = 0
}

func positiveModulo(_ value: Int, _ modulus: Int) -> Int {
    let r = value % modulus
    return r >= 0 ? r : r + modulus
}

func appendUInt16LE(_ value: UInt16, to data: inout Data) {
    var v = value.littleEndian
    withUnsafeBytes(of: &v) { data.append(contentsOf: $0) }
}

func appendUInt32LE(_ value: UInt32, to data: inout Data) {
    var v = value.littleEndian
    withUnsafeBytes(of: &v) { data.append(contentsOf: $0) }
}

func appendDoubleLE(_ value: Double, to data: inout Data) {
    var bits = value.bitPattern.littleEndian
    withUnsafeBytes(of: &bits) { data.append(contentsOf: $0) }
}

func makeDirectory(_ url: URL) throws {
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
}

func parseArgs() throws -> (library: String, epheDir: String, outputDir: String) {
    var library: String?
    var ephe: String?
    var output: String?
    var i = 1
    let args = CommandLine.arguments
    while i < args.count {
        switch args[i] {
        case "--library":
            i += 1
            if i < args.count { library = args[i] }
        case "--ephe-dir":
            i += 1
            if i < args.count { ephe = args[i] }
        case "--output-dir":
            i += 1
            if i < args.count { output = args[i] }
        default:
            break
        }
        i += 1
    }
    guard let l = library, let e = ephe, let o = output else {
        throw POCError.usage("Usage: TimespineResolutionPOC --library <libswe> --ephe-dir <dir> --output-dir <dir>")
    }
    return (l, e, o)
}

func writeSampleCSV(outputRoot: URL, body: Body, resolution: ResolutionSpec, relativeData: Data, maxRows: Int = 120) throws {
    let recordSize = 6
    let rows = min(maxRows, relativeData.count / recordSize)
    var csv = "ut_offset_seconds,degree_value\n"
    for i in 0..<rows {
        let base = i * recordSize
        let seconds: UInt32 = relativeData[base..<(base + 4)].withUnsafeBytes { raw in
            UInt32(littleEndian: raw.loadUnaligned(as: UInt32.self))
        }
        let tick: UInt16 = relativeData[(base + 4)..<(base + 6)].withUnsafeBytes { raw in
            UInt16(littleEndian: raw.loadUnaligned(as: UInt16.self))
        }
        let degree = Double(tick) * resolution.degrees
        csv += "\(seconds),\(String(format: \"%.3f\", degree))\n"
    }
    let sampleDir = outputRoot.appendingPathComponent("samples")
    try makeDirectory(sampleDir)
    try csv.data(using: .utf8)!.write(to: sampleDir.appendingPathComponent("\(resolution.key)-\(body.name).csv"))
}

func processBody(_ body: Body, swiss: Swiss, outputRoot: URL) throws -> [String: BodySummary] {
    print("Sampling \(body.name)...")
    var buffers: [String: OutputBuffers] = Dictionary(uniqueKeysWithValues: resolutions.map { ($0.key, OutputBuffers()) })

    var previousJD = saturnStartJD
    let firstState = try swiss.state(body, jd: previousJD)
    var previousLongitude = firstState.longitude
    var previousUnwrapped = firstState.longitude

    var jd = saturnStartJD + sampleStepDays
    var sampleCounter = 0

    while true {
        let currentJD = min(jd, saturnEndJD)
        let currentState = try swiss.state(body, jd: currentJD)
        let delta = signedShortestDelta(from: previousLongitude, to: currentState.longitude)
        let currentUnwrapped = previousUnwrapped + delta

        if abs(delta) > 1e-12 {
            let increasing = currentUnwrapped > previousUnwrapped
            let firstK: Int
            let lastK: Int

            if increasing {
                firstK = Int(floor(previousUnwrapped / highStepDegrees)) + 1
                lastK = Int(floor(currentUnwrapped / highStepDegrees))
            } else {
                firstK = Int(ceil(previousUnwrapped / highStepDegrees)) - 1
                lastK = Int(ceil(currentUnwrapped / highStepDegrees))
            }

            if increasing ? (firstK <= lastK) : (firstK >= lastK) {
                let sequence: AnySequence<Int>
                if increasing {
                    sequence = AnySequence(firstK...lastK)
                } else {
                    sequence = AnySequence(stride(from: firstK, through: lastK, by: -1))
                }

                for highK in sequence {
                    let target = Double(highK) * highStepDegrees
                    let fraction = (target - previousUnwrapped) / (currentUnwrapped - previousUnwrapped)
                    if fraction < -1e-10 || fraction > 1.0000000001 { continue }
                    let crossingJD = previousJD + fraction * (currentJD - previousJD)
                    let secondsFromStartDouble = (crossingJD - saturnStartJD) * 86_400.0
                    let secondsFromStart = UInt32(max(0, min(Double(UInt32.max), secondsFromStartDouble.rounded())))
                    let highTick = positiveModulo(highK, 3600)

                    for spec in resolutions where highTick % spec.highTickDivisor == 0 {
                        var entry = buffers[spec.key]!
                        let tickCount = Int(round(360.0 / spec.degrees))
                        let tick = UInt16(positiveModulo(highK / spec.highTickDivisor, tickCount))

                        // 6-byte Saturn-relative form: UInt32 seconds from Saturn-bound start + UInt16 degree tick.
                        appendUInt32LE(secondsFromStart, to: &entry.relative)
                        appendUInt16LE(tick, to: &entry.relative)

                        // 10-byte direct form: Float64 Julian Day UT + UInt16 degree tick.
                        appendDoubleLE(crossingJD, to: &entry.direct)
                        appendUInt16LE(tick, to: &entry.direct)
                        entry.count += 1
                        buffers[spec.key] = entry
                    }
                }
            }
        }

        previousJD = currentJD
        previousLongitude = currentState.longitude
        previousUnwrapped = currentUnwrapped
        sampleCounter += 1

        if currentJD >= saturnEndJD { break }
        jd += sampleStepDays
    }

    print("  samples: \(sampleCounter + 1)")

    var result: [String: BodySummary] = [:]
    for spec in resolutions {
        guard let entry = buffers[spec.key] else { continue }
        let dir = outputRoot.appendingPathComponent(spec.key)
        try makeDirectory(dir)
        try entry.relative.write(to: dir.appendingPathComponent("\(body.name).relative.bin"))
        try entry.direct.write(to: dir.appendingPathComponent("\(body.name).direct-jd.bin"))
        try writeSampleCSV(outputRoot: outputRoot, body: body, resolution: spec, relativeData: entry.relative)

        result[spec.key] = BodySummary(
            body: body.name,
            records: entry.count,
            relativeSecondsBytes: entry.relative.count,
            directJulianDayBytes: entry.direct.count
        )
        print("  \(spec.label) \(spec.degrees)°: \(entry.count) records; relative=\(entry.relative.count) bytes direct=\(entry.direct.count) bytes")
    }

    return result
}

func main() throws {
    let args = try parseArgs()
    let swiss = try Swiss(library: args.library, epheDir: args.epheDir)
    let outputRoot = URL(fileURLWithPath: args.outputDir)
    try makeDirectory(outputRoot)

    var byResolution: [String: [BodySummary]] = Dictionary(uniqueKeysWithValues: resolutions.map { ($0.key, []) })

    for body in Body.allCases {
        let summaries = try processBody(body, swiss: swiss, outputRoot: outputRoot)
        for spec in resolutions {
            if let s = summaries[spec.key] { byResolution[spec.key, default: []].append(s) }
        }
    }

    let resolutionSummaries: [ResolutionSummary] = resolutions.map { spec in
        let bodies = byResolution[spec.key, default: []]
        let records = bodies.reduce(0) { $0 + $1.records }
        let relativeBytes = bodies.reduce(0) { $0 + $1.relativeSecondsBytes }
        let directBytes = bodies.reduce(0) { $0 + $1.directJulianDayBytes }
        let moonRecords = bodies.first(where: { $0.body == "Moon" })?.records ?? 0
        return ResolutionSummary(
            key: spec.key,
            label: spec.label,
            degrees: spec.degrees,
            records: records,
            relativeSecondsBytes: relativeBytes,
            directJulianDayBytes: directBytes,
            moonRecordShare: records == 0 ? 0 : Double(moonRecords) / Double(records),
            byBody: bodies
        )
    }

    let summary = Summary(
        status: "Storage-resolution learning specimen; not canonical Timespine serialization",
        astronomicalSource: "Swiss Ephemeris, geocentric tropical apparent ecliptic longitude, UT",
        swissVersion: swiss.version,
        saturnStartJulianDay: saturnStartJD,
        saturnEndJulianDay: saturnEndJD,
        durationDays: saturnEndJD - saturnStartJD,
        samplingStepDays: sampleStepDays,
        timingMethod: "0.1-degree crossings are linearly interpolated between 0.05-day Swiss samples. 0.5-degree and 1-degree tables are exact subsets of that crossing stream. This POC is for record counts and storage sizing, not final crossing-time precision.",
        storedRecordMeaning: "Each record binds one zodiacal longitude boundary value to one UT within the fixed Saturn-bound period.",
        relativeRecordLayout: "6 bytes/record: UInt32 whole seconds since Saturn-bound start UT + UInt16 angular tick",
        directRecordLayout: "10 bytes/record: Float64 Julian Day UT + UInt16 angular tick",
        resolutions: resolutionSummaries
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let json = try encoder.encode(summary)
    try json.write(to: outputRoot.appendingPathComponent("summary.json"))

    print("\n=== TOTALS ===")
    for s in resolutionSummaries {
        print("\(s.label) \(s.degrees)°: records=\(s.records) relativeBytes=\(s.relativeSecondsBytes) directBytes=\(s.directJulianDayBytes) moonShare=\(String(format: \"%.2f%%\", s.moonRecordShare * 100))")
    }
}

do {
    try main()
} catch {
    fputs("TimespineResolutionPOC failed: \(error)\n", stderr)
    exit(1)
}
