import Foundation
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

private let spanStartJD = 2_297_171.740867775
private let spanEndJD = 2_565_295.0945935287
private let scanStepDays = 2.0
private let residualGateArcSeconds = 0.001

private enum Phase: String, Codable, CaseIterable {
    case new
    case full

    var angle: Double { self == .new ? 0.0 : 180.0 }
    var order: Int { self == .new ? 0 : 1 }
}

private enum Body: Int32 {
    case sun = 0
    case moon = 1
}

private struct State {
    let longitude: Double
    let speed: Double
}

private struct LunationRow {
    let phase: Phase
    let degree: Double
    let julianDayUT: Double
    let utc: String
    let residualArcSeconds: Double
}

private struct Summary: Codable {
    let artifactFamily: String
    let span: String
    let startJulianDayUT: Double
    let endJulianDayUTExclusive: Double
    let rowSchema: [String]
    let tableOrder: String
    let degreeLaw: String
    let phaseLaw: [String: String]
    let astronomicalSource: String
    let swissVersion: String
    let swissCommit: String
    let scanStepDays: Double
    let residualGateArcSeconds: Double
    let maximumResidualArcSeconds: Double
    let rows: Int
    let newRows: Int
    let fullRows: Int
    let firstJulianDayUT: Double
    let lastJulianDayUT: Double
    let minimumDegree: Double
    let maximumDegree: Double
    let chronologicalAlternation: Bool
    let duplicateOccurrences: Int
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
    let swissCommit: String
    let csv: String
    let summary: String

    init(_ raw: [String]) throws {
        var values: [String: String] = [:]
        var i = 0
        while i < raw.count {
            let key = raw[i]
            guard key.hasPrefix("--"), i + 1 < raw.count else {
                throw ForgeFailure.usage("Usage: lunation-forge --library PATH --ephe PATH --swiss-commit SHA --csv PATH --summary PATH")
            }
            values[key] = raw[i + 1]
            i += 2
        }
        guard let library = values["--library"],
              let ephe = values["--ephe"],
              let swissCommit = values["--swiss-commit"], !swissCommit.isEmpty,
              let csv = values["--csv"],
              let summary = values["--summary"] else {
            throw ForgeFailure.usage("Missing required Lunation Forge argument.")
        }
        self.library = library
        self.ephe = ephe
        self.swissCommit = swissCommit
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
private typealias SweRevJul = @convention(c) (
    Double,
    Int32,
    UnsafeMutablePointer<Int32>?,
    UnsafeMutablePointer<Int32>?,
    UnsafeMutablePointer<Int32>?,
    UnsafeMutablePointer<Double>?
) -> Void

private final class Swiss {
    static let SWIEPH: Int32 = 2
    static let MOSEPH: Int32 = 4
    static let SPEED: Int32 = 256

    private let handle: UnsafeMutableRawPointer
    private let calcUT: SweCalcUT
    private let revJul: SweRevJul
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
        revJul = try symbol("swe_revjul", SweRevJul.self)
        let versionFn: SweVersion = try symbol("swe_version", SweVersion.self)

        epheDir.withCString { setPath($0) }
        var buffer = [CChar](repeating: 0, count: 128)
        _ = buffer.withUnsafeMutableBufferPointer { versionFn($0.baseAddress) }
        version = String(cString: buffer)
    }

    deinit { dlclose(handle) }

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
            throw ForgeFailure.validation("Swiss Ephemeris fallback detected at JD \(jd). Lunation manufacture requires DE441 Swiss-file mode.")
        }
        return State(longitude: normalize(values[0]), speed: values[3])
    }

    func utcString(for jd: Double) -> String {
        var year: Int32 = 0
        var month: Int32 = 0
        var day: Int32 = 0
        var hour = 0.0
        revJul(jd, 1, &year, &month, &day, &hour)
        let totalMilliseconds = Int(round(hour * 3_600_000.0))
        if totalMilliseconds >= 86_400_000 {
            return utcString(for: jd + 0.5 / 86_400_000.0)
        }
        let hh = totalMilliseconds / 3_600_000
        let rem1 = totalMilliseconds % 3_600_000
        let mm = rem1 / 60_000
        let rem2 = rem1 % 60_000
        let ss = rem2 / 1_000
        let ms = rem2 % 1_000
        let yearString = year <= 0 ? String(format: "-%04d", abs(year)) : String(format: "%04d", year)
        return String(format: "%@-%02d-%02dT%02d:%02d:%02d.%03dZ", yearString, month, day, hh, mm, ss, ms)
    }
}

private func normalize(_ value: Double) -> Double {
    var result = value.truncatingRemainder(dividingBy: 360.0)
    if result < 0 { result += 360.0 }
    return result == 360.0 ? 0.0 : result
}

private func signedAngle(_ value: Double) -> Double {
    var result = normalize(value)
    if result > 180.0 { result -= 360.0 }
    return result
}

private func separation(swiss: Swiss, jd: Double) throws -> Double {
    let sun = try swiss.state(.sun, jd: jd)
    let moon = try swiss.state(.moon, jd: jd)
    return normalize(moon.longitude - sun.longitude)
}

private func unwrap(_ normalizedValue: Double, near target: Double) -> Double {
    normalizedValue + 360.0 * ((target - normalizedValue) / 360.0).rounded()
}

private func refinePhase(swiss: Swiss, lo initialLo: Double, hi initialHi: Double, target: Double) throws -> Double {
    var lo = initialLo
    var hi = initialHi
    let flo = unwrap(try separation(swiss: swiss, jd: lo), near: target) - target
    let fhi = unwrap(try separation(swiss: swiss, jd: hi), near: target) - target

    guard flo <= 0.0, fhi >= 0.0 else {
        throw ForgeFailure.validation("Lunation phase was not bracketed for target \(target): [\(flo), \(fhi)].")
    }

    for _ in 0..<64 {
        let mid = (lo + hi) / 2.0
        let fm = unwrap(try separation(swiss: swiss, jd: mid), near: target) - target
        if abs(fm) < 1e-13 { return mid }
        if fm >= 0.0 {
            hi = mid
        } else {
            lo = mid
        }
    }
    return (lo + hi) / 2.0
}

private func enumerateLunations(swiss: Swiss) throws -> [LunationRow] {
    var rows: [LunationRow] = []
    var t0 = spanStartJD
    var sep0 = try separation(swiss: swiss, jd: t0)
    var unwrapped0 = sep0

    let ratio = unwrapped0 / 180.0
    var nextTarget: Double
    if abs(ratio - ratio.rounded()) < 1e-12 {
        nextTarget = ratio.rounded() * 180.0
    } else {
        nextTarget = ceil(ratio) * 180.0
    }

    while t0 < spanEndJD {
        let t1 = min(spanEndJD, t0 + scanStepDays)
        let sep1 = try separation(swiss: swiss, jd: t1)
        let delta = signedAngle(sep1 - sep0)
        guard delta > 0.0, delta < 90.0 else {
            throw ForgeFailure.validation("Unexpected Sun-Moon elongation step at JD \(t0): \(delta) degrees over \(t1 - t0) days.")
        }
        let unwrapped1 = unwrapped0 + delta

        while nextTarget <= unwrapped1 + 1e-12 {
            if nextTarget >= unwrapped0 - 1e-12 {
                let phase: Phase = Int((nextTarget / 180.0).rounded()) % 2 == 0 ? .new : .full
                let jd = try refinePhase(swiss: swiss, lo: t0, hi: t1, target: nextTarget)
                if jd >= spanStartJD, jd < spanEndJD {
                    let sun = try swiss.state(.sun, jd: jd)
                    let moon = try swiss.state(.moon, jd: jd)
                    let residualDegrees = signedAngle(normalize(moon.longitude - sun.longitude) - phase.angle)
                    let residualArcSeconds = abs(residualDegrees) * 3_600.0
                    guard residualArcSeconds <= residualGateArcSeconds else {
                        throw ForgeFailure.validation("Lunation residual gate failed at JD \(jd): \(residualArcSeconds) arcseconds.")
                    }
                    rows.append(LunationRow(
                        phase: phase,
                        degree: normalize(moon.longitude),
                        julianDayUT: jd,
                        utc: swiss.utcString(for: jd),
                        residualArcSeconds: residualArcSeconds
                    ))
                }
            }
            nextTarget += 180.0
        }

        t0 = t1
        sep0 = sep1
        unwrapped0 = unwrapped1
    }
    return rows
}

private func validate(_ rows: [LunationRow]) throws -> (chronologicalAlternation: Bool, duplicates: Int) {
    guard !rows.isEmpty else { throw ForgeFailure.validation("Lunation table is empty.") }
    guard rows.allSatisfy({ $0.degree >= 0.0 && $0.degree < 360.0 }) else {
        throw ForgeFailure.validation("Lunation table contains a degree outside 0 <= x < 360.")
    }
    guard rows.allSatisfy({ $0.julianDayUT >= spanStartJD && $0.julianDayUT < spanEndJD }) else {
        throw ForgeFailure.validation("Lunation table contains an occurrence outside the Z21-Z23 half-open span.")
    }

    let chronological = rows.sorted { $0.julianDayUT < $1.julianDayUT }
    for i in 1..<chronological.count {
        guard chronological[i - 1].phase != chronological[i].phase else {
            throw ForgeFailure.validation("Chronological lunation traversal does not strictly alternate new/full.")
        }
    }

    var identities = Set<String>()
    var duplicates = 0
    for row in chronological {
        let identity = "\(row.phase.rawValue)|\(String(format: "%.9f", row.julianDayUT))"
        if !identities.insert(identity).inserted { duplicates += 1 }
    }
    guard duplicates == 0 else {
        throw ForgeFailure.validation("Lunation table contains \(duplicates) duplicate occurrences.")
    }

    let newCount = rows.filter { $0.phase == .new }.count
    let fullCount = rows.filter { $0.phase == .full }.count
    guard abs(newCount - fullCount) <= 1 else {
        throw ForgeFailure.validation("New/full row counts diverge unexpectedly: \(newCount) vs \(fullCount).")
    }
    return (true, duplicates)
}

private func ordered(_ rows: [LunationRow]) -> [LunationRow] {
    rows.sorted {
        if $0.phase.order != $1.phase.order { return $0.phase.order < $1.phase.order }
        if abs($0.degree - $1.degree) > 1e-12 { return $0.degree < $1.degree }
        return $0.julianDayUT < $1.julianDayUT
    }
}

private func writeCSV(_ rows: [LunationRow], to path: String) throws {
    var lines = ["phase,degree,ut"]
    lines.reserveCapacity(rows.count + 1)
    for row in rows {
        lines.append("\(row.phase.rawValue),\(String(format: "%.11f", row.degree)),\(row.utc)")
    }
    let url = URL(fileURLWithPath: path)
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try (lines.joined(separator: "\n") + "\n").write(to: url, atomically: true, encoding: .utf8)
}

private func writeSummary(_ rows: [LunationRow], validation: (chronologicalAlternation: Bool, duplicates: Int), swiss: Swiss, arguments: Arguments) throws {
    let chronological = rows.sorted { $0.julianDayUT < $1.julianDayUT }
    guard let first = chronological.first,
          let last = chronological.last,
          let minDegree = rows.map(\.degree).min(),
          let maxDegree = rows.map(\.degree).max(),
          let maxResidual = rows.map(\.residualArcSeconds).max() else {
        throw ForgeFailure.validation("Cannot summarize an empty lunation table.")
    }
    let summary = Summary(
        artifactFamily: "Orbo celestial-forward lunation table",
        span: "Z21-Z23",
        startJulianDayUT: spanStartJD,
        endJulianDayUTExclusive: spanEndJD,
        rowSchema: ["phase", "degree", "ut"],
        tableOrder: "phase (new, full), degree ascending, UT ascending",
        degreeLaw: "Moon geocentric tropical apparent ecliptic longitude at exact phase, normalized 0 <= x < 360",
        phaseLaw: ["new": "exact Sun-Moon conjunction", "full": "exact Sun-Moon opposition"],
        astronomicalSource: "Swiss Ephemeris DE441; geocentric tropical apparent ecliptic longitude; UT",
        swissVersion: swiss.version,
        swissCommit: arguments.swissCommit,
        scanStepDays: scanStepDays,
        residualGateArcSeconds: residualGateArcSeconds,
        maximumResidualArcSeconds: maxResidual,
        rows: rows.count,
        newRows: rows.filter { $0.phase == .new }.count,
        fullRows: rows.filter { $0.phase == .full }.count,
        firstJulianDayUT: first.julianDayUT,
        lastJulianDayUT: last.julianDayUT,
        minimumDegree: minDegree,
        maximumDegree: maxDegree,
        chronologicalAlternation: validation.chronologicalAlternation,
        duplicateOccurrences: validation.duplicates
    )
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(summary)
    let url = URL(fileURLWithPath: arguments.summary)
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url, options: .atomic)
}

@main
private enum LunationForgeMain {
    static func main() {
        do {
            let arguments = try Arguments(Array(CommandLine.arguments.dropFirst()))
            let swiss = try Swiss(library: arguments.library, epheDir: arguments.ephe)
            guard swiss.version == "2.10.03" else {
                throw ForgeFailure.validation("Swiss version drift: \(swiss.version) != 2.10.03")
            }
            let rawRows = try enumerateLunations(swiss: swiss)
            let validation = try validate(rawRows)
            let rows = ordered(rawRows)
            try writeCSV(rows, to: arguments.csv)
            try writeSummary(rawRows, validation: validation, swiss: swiss, arguments: arguments)
            print("Forged \(rows.count) Z21-Z23 lunations: \(rows.filter { $0.phase == .new }.count) new, \(rows.filter { $0.phase == .full }.count) full.")
            print("Canonical row: phase,degree,ut. Degree is Moon longitude on 0 <= x < 360.")
        } catch {
            fputs("Lunation Forge failed: \(error)\n", stderr)
            exit(1)
        }
    }
}
