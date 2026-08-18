import Foundation
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

private let p22StartJD = 2_386_637.079399706
private let p22EndJD = 2_475_819.1417904524
private let secondsPerDay = 86_400.0
private let signNames = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces",
]

private enum EclipseKind: String, Codable, CaseIterable {
    case solar
    case lunar

    var orientationBody: Body { self == .solar ? .sun : .moon }
}

private enum Body: Int32 {
    case sun = 0
    case moon = 1
}

private enum EclipseType: String, Codable {
    case total
    case annular
    case partial
    case hybrid
    case penumbral
}

private struct RawEclipse {
    let kind: EclipseKind
    let type: EclipseType
    let centrality: String?
    let greatestJulianDayUT: Double
}

private struct State {
    let longitude: Double
    let speed: Double
}

private struct EclipseRow: Codable {
    let eclipseDegree: Double
    let sign: String
    let degreeInSign: Double
    let orientationBody: String
    let kind: EclipseKind
    let type: EclipseType
    let centrality: String?
    let civicOffsetSeconds: Int64
    let phaseJulianDayUT: Double
    let phaseUTC: String
    let greatestEclipseJulianDayUT: Double
    let greatestEclipseUTC: String
}

private struct Summary: Codable {
    let spanName: String
    let startJulianDayUT: Double
    let endJulianDayUTExclusive: Double
    let primaryOrientation: String
    let celestialLaw: [String: String]
    let secondaryBinding: String
    let tableOrder: String
    let astronomicalSource: String
    let swissVersion: String
    let sourceCommit: String
    let ephemerisFiles: [String]
    let rowCount: Int
    let solarCount: Int
    let lunarCount: Int
    let countsByType: [String: Int]
    let minimumEclipseDegree: Double
    let maximumEclipseDegree: Double
}

private enum ForgeFailure: Error, CustomStringConvertible {
    case usage(String)
    case swiss(String)
    case validation(String)

    var description: String {
        switch self {
        case .usage(let message), .swiss(let message), .validation(let message):
            return message
        }
    }
}

private struct Arguments {
    let library: String
    let ephe: String
    let sourceSHA: String
    let csv: String
    let summary: String

    init(_ raw: [String]) throws {
        var values: [String: String] = [:]
        var index = 0
        while index < raw.count {
            let key = raw[index]
            guard key.hasPrefix("--"), index + 1 < raw.count else {
                throw ForgeFailure.usage(
                    "Usage: eclipse-forge --library PATH --ephe PATH --source-sha SHA --csv PATH --summary PATH"
                )
            }
            values[key] = raw[index + 1]
            index += 2
        }
        guard let library = values["--library"],
              let ephe = values["--ephe"],
              let sourceSHA = values["--source-sha"],
              let csv = values["--csv"],
              let summary = values["--summary"],
              !sourceSHA.isEmpty else {
            throw ForgeFailure.usage("Missing required Forge argument.")
        }
        self.library = library
        self.ephe = ephe
        self.sourceSHA = sourceSHA
        self.csv = csv
        self.summary = summary
    }
}

private typealias SweSetEphePath = @convention(c) (UnsafePointer<CChar>?) -> Void
private typealias SweCalcUT = @convention(c) (
    Double,
    Int32,
    Int32,
    UnsafeMutablePointer<Double>?,
    UnsafeMutablePointer<CChar>?
) -> Int32
private typealias SweVersion = @convention(c) (UnsafeMutablePointer<CChar>?) -> UnsafePointer<CChar>?
private typealias SweEclipseWhen = @convention(c) (
    Double,
    Int32,
    Int32,
    UnsafeMutablePointer<Double>?,
    Int32,
    UnsafeMutablePointer<CChar>?
) -> Int32

private final class Swiss {
    static let SWIEPH: Int32 = 2
    static let MOSEPH: Int32 = 4
    static let SPEED: Int32 = 256

    static let ECL_CENTRAL: Int32 = 1
    static let ECL_NONCENTRAL: Int32 = 2
    static let ECL_TOTAL: Int32 = 4
    static let ECL_ANNULAR: Int32 = 8
    static let ECL_PARTIAL: Int32 = 16
    static let ECL_ANNULAR_TOTAL: Int32 = 32
    static let ECL_PENUMBRAL: Int32 = 64

    private let handle: UnsafeMutableRawPointer
    private let calcUT: SweCalcUT
    private let solarWhen: SweEclipseWhen
    private let lunarWhen: SweEclipseWhen
    let version: String

    init(library: String, epheDir: String) throws {
        guard let handle = dlopen(library, RTLD_NOW | RTLD_LOCAL) else {
            throw ForgeFailure.swiss("Could not load Swiss Ephemeris library: \(String(cString: dlerror()))")
        }
        self.handle = handle

        func symbol<T>(_ name: String, _ type: T.Type) throws -> T {
            guard let pointer = dlsym(handle, name) else {
                throw ForgeFailure.swiss("Swiss Ephemeris symbol not found: \(name)")
            }
            return unsafeBitCast(pointer, to: T.self)
        }

        let setPath: SweSetEphePath = try symbol("swe_set_ephe_path", SweSetEphePath.self)
        calcUT = try symbol("swe_calc_ut", SweCalcUT.self)
        solarWhen = try symbol("swe_sol_eclipse_when_glob", SweEclipseWhen.self)
        lunarWhen = try symbol("swe_lun_eclipse_when", SweEclipseWhen.self)
        let versionFn: SweVersion = try symbol("swe_version", SweVersion.self)

        epheDir.withCString { setPath($0) }
        var versionBuffer = [CChar](repeating: 0, count: 128)
        _ = versionBuffer.withUnsafeMutableBufferPointer { versionFn($0.baseAddress) }
        version = String(cString: versionBuffer)
    }

    deinit {
        dlclose(handle)
    }

    func state(_ body: Body, jd: Double) throws -> State {
        var values = [Double](repeating: 0.0, count: 6)
        var error = [CChar](repeating: 0, count: 256)
        let flags = Swiss.SWIEPH | Swiss.SPEED
        let returned = values.withUnsafeMutableBufferPointer { valueBuffer in
            error.withUnsafeMutableBufferPointer { errorBuffer in
                calcUT(jd, body.rawValue, flags, valueBuffer.baseAddress, errorBuffer.baseAddress)
            }
        }
        guard returned >= 0 else {
            throw ForgeFailure.swiss("Swiss position failure at JD \(jd): \(String(cString: error))")
        }
        guard (returned & Swiss.SWIEPH) != 0, (returned & Swiss.MOSEPH) == 0 else {
            throw ForgeFailure.validation(
                "Swiss Ephemeris fallback detected at JD \(jd). P22 eclipse manufacture requires the repository DE441 files."
            )
        }
        return State(longitude: normalize(values[0]), speed: values[3])
    }

    func nextEclipse(kind: EclipseKind, after startJD: Double) throws -> RawEclipse {
        var times = [Double](repeating: 0.0, count: 10)
        var error = [CChar](repeating: 0, count: 256)
        let function = kind == .solar ? solarWhen : lunarWhen
        let returned = times.withUnsafeMutableBufferPointer { timeBuffer in
            error.withUnsafeMutableBufferPointer { errorBuffer in
                function(
                    startJD,
                    Swiss.SWIEPH,
                    0,
                    timeBuffer.baseAddress,
                    0,
                    errorBuffer.baseAddress
                )
            }
        }
        guard returned >= 0 else {
            throw ForgeFailure.swiss("Swiss eclipse search failure after JD \(startJD): \(String(cString: error))")
        }
        guard times[0].isFinite, times[0] > startJD else {
            throw ForgeFailure.validation("Swiss eclipse search did not advance after JD \(startJD).")
        }
        return RawEclipse(
            kind: kind,
            type: try classify(returned, kind: kind),
            centrality: kind == .solar ? classifyCentrality(returned) : nil,
            greatestJulianDayUT: times[0]
        )
    }
}

private func normalize(_ value: Double) -> Double {
    var result = value.truncatingRemainder(dividingBy: 360.0)
    if result < 0 { result += 360.0 }
    return result
}

private func signedAngle(_ value: Double) -> Double {
    var result = normalize(value)
    if result > 180.0 { result -= 360.0 }
    return result
}

private func classify(_ flags: Int32, kind: EclipseKind) throws -> EclipseType {
    switch kind {
    case .solar:
        if (flags & Swiss.ECL_ANNULAR_TOTAL) != 0 { return .hybrid }
        if (flags & Swiss.ECL_TOTAL) != 0 { return .total }
        if (flags & Swiss.ECL_ANNULAR) != 0 { return .annular }
        if (flags & Swiss.ECL_PARTIAL) != 0 { return .partial }
    case .lunar:
        if (flags & Swiss.ECL_TOTAL) != 0 { return .total }
        if (flags & Swiss.ECL_PARTIAL) != 0 { return .partial }
        if (flags & Swiss.ECL_PENUMBRAL) != 0 { return .penumbral }
    }
    throw ForgeFailure.validation("Unknown Swiss eclipse type flags \(flags) for \(kind.rawValue).")
}

private func classifyCentrality(_ flags: Int32) -> String? {
    if (flags & Swiss.ECL_CENTRAL) != 0 { return "central" }
    if (flags & Swiss.ECL_NONCENTRAL) != 0 { return "noncentral" }
    return nil
}

private func enumerateEclipses(kind: EclipseKind, swiss: Swiss) throws -> [RawEclipse] {
    var result: [RawEclipse] = []
    var cursor = p22StartJD - 2.0
    while true {
        let eclipse = try swiss.nextEclipse(kind: kind, after: cursor)
        if eclipse.greatestJulianDayUT >= p22EndJD + 2.0 { break }
        if eclipse.greatestJulianDayUT >= p22StartJD - 2.0 {
            result.append(eclipse)
        }
        cursor = eclipse.greatestJulianDayUT + 1.0
        guard result.count < 2_000 else {
            throw ForgeFailure.validation("Eclipse enumeration exceeded the P22 safety bound.")
        }
    }
    return result
}

private func phaseResidual(kind: EclipseKind, sun: State, moon: State) -> Double {
    let separation = normalize(moon.longitude - sun.longitude)
    switch kind {
    case .solar:
        return signedAngle(separation)
    case .lunar:
        return signedAngle(separation - 180.0)
    }
}

private func refineSyzygy(kind: EclipseKind, near greatestJD: Double, swiss: Swiss) throws -> Double {
    var jd = greatestJD
    for _ in 0..<12 {
        let sun = try swiss.state(.sun, jd: jd)
        let moon = try swiss.state(.moon, jd: jd)
        let residual = phaseResidual(kind: kind, sun: sun, moon: moon)
        if abs(residual) < 1e-11 { return jd }
        let relativeSpeed = moon.speed - sun.speed
        guard abs(relativeSpeed) > 1e-8 else {
            throw ForgeFailure.validation("Syzygy relative speed collapsed near JD \(jd).")
        }
        var correction = residual / relativeSpeed
        correction = max(-0.75, min(0.75, correction))
        jd -= correction
    }

    let sun = try swiss.state(.sun, jd: jd)
    let moon = try swiss.state(.moon, jd: jd)
    let residual = phaseResidual(kind: kind, sun: sun, moon: moon)
    guard abs(residual) < 1e-8 else {
        throw ForgeFailure.validation("Syzygy did not converge near greatest eclipse JD \(greatestJD); residual \(residual) degrees.")
    }
    return jd
}

private func utcString(for jd: Double) -> String {
    let unixSeconds = (jd - 2_440_587.5) * secondsPerDay
    let date = Date(timeIntervalSince1970: unixSeconds)
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    return formatter.string(from: date)
}

private func makeRows(raw: [RawEclipse], swiss: Swiss) throws -> [EclipseRow] {
    var seen: Set<String> = []
    var rows: [EclipseRow] = []
    rows.reserveCapacity(raw.count)

    for event in raw {
        let phaseJD = try refineSyzygy(kind: event.kind, near: event.greatestJulianDayUT, swiss: swiss)
        guard phaseJD >= p22StartJD, phaseJD < p22EndJD else { continue }

        let sun = try swiss.state(.sun, jd: phaseJD)
        let moon = try swiss.state(.moon, jd: phaseJD)
        let residual = phaseResidual(kind: event.kind, sun: sun, moon: moon)
        guard abs(residual) < 1e-8 else {
            throw ForgeFailure.validation("Celestial eclipse law failed at JD \(phaseJD): residual \(residual) degrees.")
        }

        let eclipseDegree = event.kind == .solar ? sun.longitude : moon.longitude
        let signIndex = Int(floor(eclipseDegree / 30.0))
        guard signNames.indices.contains(signIndex) else {
            throw ForgeFailure.validation("Could not orient eclipse degree \(eclipseDegree) on zodiac.")
        }

        let identity = "\(event.kind.rawValue)|\(String(format: "%.9f", phaseJD))"
        guard seen.insert(identity).inserted else {
            throw ForgeFailure.validation("Duplicate eclipse occurrence: \(identity)")
        }

        rows.append(EclipseRow(
            eclipseDegree: eclipseDegree,
            sign: signNames[signIndex],
            degreeInSign: eclipseDegree - Double(signIndex * 30),
            orientationBody: event.kind.orientationBody == .sun ? "Sun" : "Moon",
            kind: event.kind,
            type: event.type,
            centrality: event.centrality,
            civicOffsetSeconds: Int64(((phaseJD - p22StartJD) * secondsPerDay).rounded()),
            phaseJulianDayUT: phaseJD,
            phaseUTC: utcString(for: phaseJD),
            greatestEclipseJulianDayUT: event.greatestJulianDayUT,
            greatestEclipseUTC: utcString(for: event.greatestJulianDayUT)
        ))
    }

    rows.sort {
        if abs($0.eclipseDegree - $1.eclipseDegree) > 1e-12 {
            return $0.eclipseDegree < $1.eclipseDegree
        }
        return $0.phaseJulianDayUT < $1.phaseJulianDayUT
    }
    return rows
}

private func csvEscaped(_ value: String) -> String {
    if value.contains(",") || value.contains("\"") || value.contains("\n") {
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
    return value
}

private func writeCSV(_ rows: [EclipseRow], to path: String) throws {
    var lines = [
        "eclipse_degree,sign,degree_in_sign,orientation_body,eclipse_kind,eclipse_type,centrality,civic_offset_seconds,phase_julian_day_ut,phase_utc,greatest_eclipse_julian_day_ut,greatest_eclipse_utc"
    ]
    lines.reserveCapacity(rows.count + 1)

    for row in rows {
        let fields = [
            String(format: "%.11f", row.eclipseDegree),
            row.sign,
            String(format: "%.11f", row.degreeInSign),
            row.orientationBody,
            row.kind.rawValue,
            row.type.rawValue,
            row.centrality ?? "",
            String(row.civicOffsetSeconds),
            String(format: "%.9f", row.phaseJulianDayUT),
            row.phaseUTC,
            String(format: "%.9f", row.greatestEclipseJulianDayUT),
            row.greatestEclipseUTC,
        ].map(csvEscaped)
        lines.append(fields.joined(separator: ","))
    }

    let url = URL(fileURLWithPath: path)
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try (lines.joined(separator: "\n") + "\n").write(to: url, atomically: true, encoding: .utf8)
}

private func writeSummary(_ rows: [EclipseRow], swiss: Swiss, arguments: Arguments) throws {
    guard let minDegree = rows.map(\.eclipseDegree).min(),
          let maxDegree = rows.map(\.eclipseDegree).max() else {
        throw ForgeFailure.validation("Cannot summarize an empty eclipse table.")
    }

    let solar = rows.filter { $0.kind == .solar }.count
    let lunar = rows.filter { $0.kind == .lunar }.count
    var counts: [String: Int] = [:]
    for row in rows {
        counts["\(row.kind.rawValue).\(row.type.rawValue)", default: 0] += 1
    }

    let summary = Summary(
        spanName: "P22 Pluto Zeitgeist",
        startJulianDayUT: p22StartJD,
        endJulianDayUTExclusive: p22EndJD,
        primaryOrientation: "eclipse zodiacal degree at exact syzygy; Sun degree for solar eclipses, Moon degree for lunar eclipses",
        celestialLaw: [
            "solar": "Sun conjunct Moon",
            "lunar": "Moon opposite Sun",
        ],
        secondaryBinding: "exact syzygy civic UT / Julian Day; greatest eclipse retained as event metadata",
        tableOrder: "eclipse_degree ascending, then phase_julian_day_ut ascending",
        astronomicalSource: "Swiss Ephemeris DE441 repository files; geocentric tropical ecliptic longitude; UT",
        swissVersion: swiss.version,
        sourceCommit: arguments.sourceSHA,
        ephemerisFiles: ["sepl_18.se1", "semo_18.se1"],
        rowCount: rows.count,
        solarCount: solar,
        lunarCount: lunar,
        countsByType: counts,
        minimumEclipseDegree: minDegree,
        maximumEclipseDegree: maxDegree
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(summary)
    let url = URL(fileURLWithPath: arguments.summary)
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url, options: .atomic)
    try FileHandle(forWritingTo: url).seekToEnd()
}

private func validate(_ rows: [EclipseRow]) throws {
    guard !rows.isEmpty else { throw ForgeFailure.validation("P22 eclipse table is empty.") }
    guard rows.allSatisfy({ $0.eclipseDegree >= 0 && $0.eclipseDegree < 360 }) else {
        throw ForgeFailure.validation("P22 eclipse table contains an invalid zodiac degree.")
    }
    guard rows.allSatisfy({ $0.phaseJulianDayUT >= p22StartJD && $0.phaseJulianDayUT < p22EndJD }) else {
        throw ForgeFailure.validation("P22 eclipse table contains an occurrence outside the half-open P22 span.")
    }
    for index in 1..<rows.count {
        let previous = rows[index - 1]
        let current = rows[index]
        guard previous.eclipseDegree < current.eclipseDegree ||
              (abs(previous.eclipseDegree - current.eclipseDegree) <= 1e-12 && previous.phaseJulianDayUT <= current.phaseJulianDayUT) else {
            throw ForgeFailure.validation("P22 eclipse table is not celestial-degree-first.")
        }
    }
}

@main
private enum EclipseForgeMain {
    static func main() {
        do {
            let arguments = try Arguments(Array(CommandLine.arguments.dropFirst()))
            let swiss = try Swiss(library: arguments.library, epheDir: arguments.ephe)
            let solar = try enumerateEclipses(kind: .solar, swiss: swiss)
            let lunar = try enumerateEclipses(kind: .lunar, swiss: swiss)
            let rows = try makeRows(raw: solar + lunar, swiss: swiss)
            try validate(rows)
            try writeCSV(rows, to: arguments.csv)
            try writeSummary(rows, swiss: swiss, arguments: arguments)
            print("Forged \(rows.count) P22 eclipse occurrences: \(rows.filter { $0.kind == .solar }.count) solar, \(rows.filter { $0.kind == .lunar }.count) lunar.")
            print("Primary orientation: celestial eclipse degree. Civic UT binds each occurrence.")
        } catch {
            fputs("Eclipse Forge failed: \(error)\n", stderr)
            exit(1)
        }
    }
}
