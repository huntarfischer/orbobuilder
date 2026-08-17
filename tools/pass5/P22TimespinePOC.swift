import Foundation
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

enum Body: Int32, CaseIterable, Codable, Hashable {
    case sun = 0, moon = 1, mercury = 2, venus = 3, mars = 4, jupiter = 5, saturn = 6
    case uranus = 7, neptune = 8, pluto = 9, trueNode = 11

    var name: String {
        switch self {
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .mercury: return "Mercury"
        case .venus: return "Venus"
        case .mars: return "Mars"
        case .jupiter: return "Jupiter"
        case .saturn: return "Saturn"
        case .uranus: return "Uranus"
        case .neptune: return "Neptune"
        case .pluto: return "Pluto"
        case .trueNode: return "NorthNode"
        }
    }

    var selectedResolution: Double {
        switch self {
        case .sun, .moon, .mercury, .venus, .mars: return 1.0
        case .jupiter, .saturn, .uranus, .neptune, .pluto, .trueNode: return 0.1
        }
    }

    var sampleStepDays: Double {
        switch self {
        case .moon: return 0.05
        case .mercury, .trueNode: return 0.10
        case .sun, .venus: return 0.20
        case .mars: return 0.25
        case .jupiter: return 0.25
        case .saturn: return 0.50
        case .uranus, .neptune, .pluto: return 1.0
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
    if d > 180.0 { d -= 360.0 }
    if d < -180.0 { d += 360.0 }
    return d
}

func mod(_ value: Int, _ modulus: Int) -> Int {
    let r = value % modulus
    return r >= 0 ? r : r + modulus
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
            throw NSError(domain: "dlopen", code: 1, userInfo: [NSLocalizedDescriptionKey: String(cString: dlerror())])
        }
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
        var xx = [Double](repeating: 0.0, count: 6)
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
        return State(longitude: normalize(xx[0]), speed: xx[3])
    }
}

let p22StartJD = 2386637.079399706
let p23StartJD = 2475819.1417904524
let secondsPerDay = 86_400.0

struct Crossing {
    let jd: Double
    let tick: Int
    let direction: Int
}

struct Station {
    let body: Body
    let jd: Double
    let longitude: Double
    let beforeDirection: Int
    let afterDirection: Int
}

struct BodyData {
    var baseline: [Crossing] = []
    var selected: [Crossing] = []
    var stations: [Station] = []
}

func directionName(_ d: Int) -> String { d >= 0 ? "increasing" : "decreasing" }

func refineStation(_ swiss: Swiss, body: Body, lo: Double, hi: Double) throws -> Double {
    var a = lo
    var b = hi
    var fa = try swiss.state(body, jd: a).speed
    for _ in 0..<52 {
        let m = (a + b) * 0.5
        let fm = try swiss.state(body, jd: m).speed
        if fa == 0 { return a }
        if fa * fm <= 0 {
            b = m
        } else {
            a = m
            fa = fm
        }
    }
    return (a + b) * 0.5
}

func refineCrossing(
    _ swiss: Swiss,
    body: Body,
    targetUnwrapped: Double,
    loJD: Double,
    hiJD: Double,
    anchorLongitude: Double,
    anchorUnwrapped: Double
) throws -> Double {
    var a = loJD
    var b = hiJD
    func value(_ jd: Double) throws -> (f: Double, speed: Double) {
        let s = try swiss.state(body, jd: jd)
        let u = anchorUnwrapped + signedShortestDelta(from: anchorLongitude, to: s.longitude)
        return (u - targetUnwrapped, s.speed)
    }
    var va = try value(a)
    let vb = try value(b)
    if abs(va.f) < 1e-12 { return a }
    if abs(vb.f) < 1e-12 { return b }
    guard va.f * vb.f <= 0 else { return (a + b) * 0.5 }

    var x = a + (b - a) * abs(va.f) / max(1e-18, abs(va.f) + abs(vb.f))
    for _ in 0..<8 {
        let vx = try value(x)
        if abs(vx.f) < 1e-10 { return x }
        if va.f * vx.f <= 0 {
            b = x
        } else {
            a = x
            va = vx
        }
        if abs(vx.speed) > 1e-8 {
            let nx = x - vx.f / vx.speed
            if nx > a && nx < b {
                x = nx
                continue
            }
        }
        x = (a + b) * 0.5
    }

    for _ in 0..<24 {
        let m = (a + b) * 0.5
        let vm = try value(m)
        if abs(vm.f) < 1e-10 { return m }
        if va.f * vm.f <= 0 {
            b = m
        } else {
            a = m
            va = vm
        }
    }
    return (a + b) * 0.5
}

func emitMonotonicCrossings(
    swiss: Swiss,
    body: Body,
    resolution: Double,
    loJD: Double,
    hiJD: Double,
    loState: State,
    hiState: State,
    into out: inout [Crossing]
) throws {
    let loU = loState.longitude
    let hiU = loU + signedShortestDelta(from: loState.longitude, to: hiState.longitude)
    let delta = hiU - loU
    if abs(delta) < 1e-14 { return }
    let direction = delta > 0 ? 1 : -1
    let scale = Int(round(1.0 / resolution))
    if direction > 0 {
        let first = Int(floor(loU / resolution)) + 1
        let last = Int(floor(hiU / resolution))
        if first <= last {
            for k in first...last {
                let target = Double(k) * resolution
                let jd = try refineCrossing(swiss, body: body, targetUnwrapped: target, loJD: loJD, hiJD: hiJD, anchorLongitude: loState.longitude, anchorUnwrapped: loU)
                if jd >= p22StartJD - 1e-9 && jd < p23StartJD - 1e-9 {
                    let tick = mod(k, 360 * scale)
                    if out.last.map({ $0.tick == tick && abs($0.jd - jd) * secondsPerDay < 0.25 }) != true {
                        out.append(Crossing(jd: jd, tick: tick, direction: 1))
                    }
                }
            }
        }
    } else {
        let first = Int(ceil(loU / resolution)) - 1
        let last = Int(ceil(hiU / resolution))
        if first >= last {
            for k in stride(from: first, through: last, by: -1) {
                let target = Double(k) * resolution
                let jd = try refineCrossing(swiss, body: body, targetUnwrapped: target, loJD: loJD, hiJD: hiJD, anchorLongitude: loState.longitude, anchorUnwrapped: loU)
                if jd >= p22StartJD - 1e-9 && jd < p23StartJD - 1e-9 {
                    let tick = mod(k, 360 * scale)
                    if out.last.map({ $0.tick == tick && abs($0.jd - jd) * secondsPerDay < 0.25 }) != true {
                        out.append(Crossing(jd: jd, tick: tick, direction: -1))
                    }
                }
            }
        }
    }
}

func processSegment(
    swiss: Swiss,
    body: Body,
    resolution: Double,
    loJD: Double,
    hiJD: Double,
    loState: State,
    hiState: State,
    crossings: inout [Crossing],
    stations: inout [Station]
) throws {
    if loState.speed * hiState.speed < 0 {
        let stationJD = try refineStation(swiss, body: body, lo: loJD, hi: hiJD)
        let stationState = try swiss.state(body, jd: stationJD)
        let before = loState.speed >= 0 ? 1 : -1
        let after = hiState.speed >= 0 ? 1 : -1
        if stations.last.map({ $0.body == body && abs($0.jd - stationJD) * secondsPerDay < 1.0 }) != true {
            stations.append(Station(body: body, jd: stationJD, longitude: stationState.longitude, beforeDirection: before, afterDirection: after))
        }
        if stationJD - loJD > 1e-10 {
            try emitMonotonicCrossings(swiss: swiss, body: body, resolution: resolution, loJD: loJD, hiJD: stationJD, loState: loState, hiState: stationState, into: &crossings)
        }
        if hiJD - stationJD > 1e-10 {
            try emitMonotonicCrossings(swiss: swiss, body: body, resolution: resolution, loJD: stationJD, hiJD: hiJD, loState: stationState, hiState: hiState, into: &crossings)
        }
    } else {
        try emitMonotonicCrossings(swiss: swiss, body: body, resolution: resolution, loJD: loJD, hiJD: hiJD, loState: loState, hiState: hiState, into: &crossings)
    }
}

func generateBody(_ body: Body, swiss: Swiss) throws -> BodyData {
    var data = BodyData()
    let resolution = body.selectedResolution
    let step = body.sampleStepDays
    var loJD = p22StartJD
    var loState = try swiss.state(body, jd: loJD)
    let startScaled = loState.longitude / resolution
    let startK = Int(round(startScaled))
    if abs(startScaled - Double(startK)) < 1e-7 {
        let scale = Int(round(1.0 / resolution))
        data.selected.append(Crossing(jd: p22StartJD, tick: mod(startK, 360 * scale), direction: loState.speed >= 0 ? 1 : -1))
    }
    var nextJD = loJD + step

    while loJD < p23StartJD {
        let hiJD = min(nextJD, p23StartJD)
        let hiState = try swiss.state(body, jd: hiJD)
        try processSegment(swiss: swiss, body: body, resolution: resolution, loJD: loJD, hiJD: hiJD, loState: loState, hiState: hiState, crossings: &data.selected, stations: &data.stations)
        loJD = hiJD
        loState = hiState
        nextJD += step
        if hiJD >= p23StartJD { break }
    }

    data.selected.sort { $0.jd < $1.jd }
    data.stations.sort { $0.jd < $1.jd }
    if abs(resolution - 1.0) < 1e-12 {
        data.baseline = data.selected
    } else {
        data.baseline = data.selected.compactMap { row in
            if row.tick % 10 == 0 {
                return Crossing(jd: row.jd, tick: row.tick / 10, direction: row.direction)
            }
            return nil
        }
    }
    return data
}

func cellBeforeFirst(_ rows: [Crossing]) -> Int {
    guard let first = rows.first else { return 0 }
    return first.direction > 0 ? mod(first.tick - 1, 360) : first.tick
}

func cellAfter(_ crossing: Crossing) -> Int {
    crossing.direction > 0 ? crossing.tick : mod(crossing.tick - 1, 360)
}

func simultaneousWholeDegreeCells(focalRows: [Crossing], markerRows: [Crossing]) -> [UInt16] {
    var values = [UInt16]()
    values.reserveCapacity(focalRows.count)
    var j = -1
    let before = cellBeforeFirst(markerRows)
    for row in focalRows {
        while j + 1 < markerRows.count && markerRows[j + 1].jd <= row.jd + 1e-12 {
            j += 1
        }
        let cell = j < 0 ? before : cellAfter(markerRows[j])
        values.append(UInt16(cell))
    }
    return values
}

func collisionStats(ticks: [UInt16], markerArrays: [[UInt16]]) -> (repeatedKeys: Int, repeatedRows: Int, collisionExcess: Int) {
    var counts = [UInt64: Int](minimumCapacity: ticks.count)
    for i in 0..<ticks.count {
        var key = UInt64(ticks[i])
        for arr in markerArrays {
            key = (key << 9) | UInt64(arr[i])
        }
        counts[key, default: 0] += 1
    }
    var repeatedKeys = 0
    var repeatedRows = 0
    var excess = 0
    for n in counts.values where n > 1 {
        repeatedKeys += 1
        repeatedRows += n
        excess += n - 1
    }
    return (repeatedKeys, repeatedRows, excess)
}

struct MarkerAuditResult: Codable {
    let sunAloneRepeatedKeys: Int?
    let sunAloneRepeatedRows: Int?
    let singleMarkerWinners: [String]
    let selectedMarkers: [String]
    let selectedRepeatedKeys: Int
    let sunFirst: Bool
    let markerCount: Int
}

let markerPriority: [Body] = [.sun, .pluto, .neptune, .uranus, .saturn, .jupiter, .trueNode, .mars, .venus, .mercury, .moon]

func markerAudit(focal: Body, selectedRows: [Crossing], allData: [Body: BodyData]) -> (MarkerAuditResult, [Body: [UInt16]]) {
    let ticks = selectedRows.map { UInt16($0.tick) }
    var arrays: [Body: [UInt16]] = [:]
    for marker in Body.allCases where marker != focal {
        arrays[marker] = simultaneousWholeDegreeCells(focalRows: selectedRows, markerRows: allData[marker]!.baseline)
    }

    var singleWinners: [Body] = []
    for marker in markerPriority where marker != focal {
        if let arr = arrays[marker] {
            let s = collisionStats(ticks: ticks, markerArrays: [arr])
            if s.repeatedKeys == 0 { singleWinners.append(marker) }
        }
    }

    if focal != .sun, let sun = arrays[.sun] {
        let sunStats = collisionStats(ticks: ticks, markerArrays: [sun])
        if sunStats.repeatedKeys == 0 {
            return (MarkerAuditResult(sunAloneRepeatedKeys: 0, sunAloneRepeatedRows: 0, singleMarkerWinners: singleWinners.map(\.name), selectedMarkers: [Body.sun.name], selectedRepeatedKeys: 0, sunFirst: true, markerCount: 1), arrays)
        }
        var sameSizeWinners: [[Body]] = []
        for marker in markerPriority where marker != focal && marker != .sun {
            guard let arr = arrays[marker] else { continue }
            let s = collisionStats(ticks: ticks, markerArrays: [sun, arr])
            if s.repeatedKeys == 0 { sameSizeWinners.append([.sun, marker]) }
        }
        if let winner = sameSizeWinners.first {
            return (MarkerAuditResult(sunAloneRepeatedKeys: sunStats.repeatedKeys, sunAloneRepeatedRows: sunStats.repeatedRows, singleMarkerWinners: singleWinners.map(\.name), selectedMarkers: winner.map(\.name), selectedRepeatedKeys: 0, sunFirst: true, markerCount: 2), arrays)
        }
        let candidates = markerPriority.filter { $0 != focal && $0 != .sun }
        for a in 0..<candidates.count {
            for b in (a + 1)..<candidates.count {
                let m1 = candidates[a], m2 = candidates[b]
                guard let a1 = arrays[m1], let a2 = arrays[m2] else { continue }
                let s = collisionStats(ticks: ticks, markerArrays: [sun, a1, a2])
                if s.repeatedKeys == 0 {
                    return (MarkerAuditResult(sunAloneRepeatedKeys: sunStats.repeatedKeys, sunAloneRepeatedRows: sunStats.repeatedRows, singleMarkerWinners: singleWinners.map(\.name), selectedMarkers: [Body.sun.name, m1.name, m2.name], selectedRepeatedKeys: 0, sunFirst: true, markerCount: 3), arrays)
                }
            }
        }
        fatalError("No Sun-first marker set of size <= 3 resolved \(focal.name)")
    }

    if let winner = singleWinners.first, let arr = arrays[winner] {
        let s = collisionStats(ticks: ticks, markerArrays: [arr])
        return (MarkerAuditResult(sunAloneRepeatedKeys: nil, sunAloneRepeatedRows: nil, singleMarkerWinners: singleWinners.map(\.name), selectedMarkers: [winner.name], selectedRepeatedKeys: s.repeatedKeys, sunFirst: false, markerCount: 1), arrays)
    }
    let candidates = markerPriority.filter { $0 != focal }
    for a in 0..<candidates.count {
        for b in (a + 1)..<candidates.count {
            let m1 = candidates[a], m2 = candidates[b]
            guard let a1 = arrays[m1], let a2 = arrays[m2] else { continue }
            let s = collisionStats(ticks: ticks, markerArrays: [a1, a2])
            if s.repeatedKeys == 0 {
                return (MarkerAuditResult(sunAloneRepeatedKeys: nil, sunAloneRepeatedRows: nil, singleMarkerWinners: singleWinners.map(\.name), selectedMarkers: [m1.name, m2.name], selectedRepeatedKeys: 0, sunFirst: false, markerCount: 2), arrays)
            }
        }
    }
    for a in 0..<candidates.count {
        for b in (a + 1)..<candidates.count {
            for c in (b + 1)..<candidates.count {
                let m1 = candidates[a], m2 = candidates[b], m3 = candidates[c]
                guard let a1 = arrays[m1], let a2 = arrays[m2], let a3 = arrays[m3] else { continue }
                let s = collisionStats(ticks: ticks, markerArrays: [a1, a2, a3])
                if s.repeatedKeys == 0 {
                    return (MarkerAuditResult(sunAloneRepeatedKeys: nil, sunAloneRepeatedRows: nil, singleMarkerWinners: singleWinners.map(\.name), selectedMarkers: [m1.name, m2.name, m3.name], selectedRepeatedKeys: 0, sunFirst: false, markerCount: 3), arrays)
                }
            }
        }
    }
    fatalError("No marker set of size <= 3 resolved Sun")
}

func writeBodyCSV(url: URL, body: Body, rows: [Crossing], audit: MarkerAuditResult, arrays: [Body: [UInt16]]) throws {
    _ = FileManager.default.createFile(atPath: url.path, contents: nil)
    let handle = try FileHandle(forWritingTo: url)
    defer { try? handle.close() }
    let selectedBodies = audit.selectedMarkers.compactMap { name in Body.allCases.first { $0.name == name } }
    var header = "focalCelestialTick,focalCelestialDegrees,celestialResolutionDegrees,occurrence,utOffsetSeconds,utJulianDay,sequenceDirection"
    for marker in selectedBodies { header += ",\(marker.name)Degree" }
    header += "\n"
    handle.write(header.data(using: .utf8)!)

    var occurrence: [Int: Int] = [:]
    var chunk = ""
    chunk.reserveCapacity(1_000_000)
    for i in 0..<rows.count {
        let row = rows[i]
        occurrence[row.tick, default: 0] += 1
        let degrees = Double(row.tick) * body.selectedResolution
        let offset = Int64(round((row.jd - p22StartJD) * secondsPerDay))
        chunk += "\(row.tick),\(String(format: "%.1f", degrees)),\(String(format: "%.1f", body.selectedResolution)),\(occurrence[row.tick]!),\(offset),\(String(format: "%.12f", row.jd)),\(directionName(row.direction))"
        for marker in selectedBodies { chunk += ",\(arrays[marker]![i])" }
        chunk += "\n"
        if chunk.utf8.count >= 1_000_000 {
            handle.write(chunk.data(using: .utf8)!)
            chunk.removeAll(keepingCapacity: true)
        }
    }
    if !chunk.isEmpty { handle.write(chunk.data(using: .utf8)!) }
}

struct BodySummary: Codable {
    let body: String
    let selectedResolutionDegrees: Double
    let selectedRecords: Int
    let wholeDegreeRecords: Int
    let stationCount: Int
    let retrogradePassages: Int
    let retrogradeSelectedCrossings: Int
    let wholeDegreeMarkerAudit: MarkerAuditResult
    let selectedResolutionMarkerAudit: MarkerAuditResult
    let candidatePackedBytes: Int
}

struct Summary: Codable {
    let status: String
    let swissVersion: String
    let astronomicalSource: String
    let spanName: String
    let startJulianDayUT: Double
    let endJulianDayUT: Double
    let startUTC: String
    let endUTC: String
    let durationDays: Double
    let durationYears: Double
    let civicOffsetBitsRequired: Int
    let nodeRepresentation: String
    let bodyTables: [BodySummary]
    let totalSelectedBodyRecords: Int
    let candidatePackedBodyBytesTotal: Int
    let totalStations: Int
    let totalRetrogradePassages: Int
    let notes: [String]
}

func isoFromJD(_ jd: Double) -> String {
    let unix = (jd - 2440587.5) * secondsPerDay
    let date = Date(timeIntervalSince1970: unix)
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return fmt.string(from: date)
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

func main() throws {
    guard let (library, ephe, output) = parseArgs() else {
        fputs("usage: P22TimespinePOC --library <lib> --ephe-dir <dir> --output-dir <dir>\n", stderr)
        exit(2)
    }
    let swiss = try Swiss(library: library, epheDir: ephe)
    let root = URL(fileURLWithPath: output)
    let bodiesDir = root.appendingPathComponent("body-tables")
    try FileManager.default.createDirectory(at: bodiesDir, withIntermediateDirectories: true)

    let pStart = try swiss.state(.pluto, jd: p22StartJD)
    let pEnd = try swiss.state(.pluto, jd: p23StartJD)
    guard min(pStart.longitude, 360.0 - pStart.longitude) < 0.0001, pStart.speed > 0,
          min(pEnd.longitude, 360.0 - pEnd.longitude) < 0.0001, pEnd.speed > 0 else {
        throw NSError(domain: "P22Boundary", code: 1, userInfo: [NSLocalizedDescriptionKey: "Stored P22/P23 boundaries no longer validate as direct Pluto 0 Aries crossings"])
    }

    var allData: [Body: BodyData] = [:]
    for body in Body.allCases {
        let data = try generateBody(body, swiss: swiss)
        allData[body] = data
        print("GENERATED \(body.name): selected=\(data.selected.count) whole=\(data.baseline.count) stations=\(data.stations.count)")
    }

    var allStations: [Station] = []
    var bodySummaries: [BodySummary] = []
    var totalRetroPassages = 0

    var stationCSV = "body,celestialTimeDegrees,utOffsetSeconds,utJulianDay,sequenceBefore,sequenceAfter,userFacingStation\n"
    var retroCSV = "body,startCelestialTimeDegrees,endCelestialTimeDegrees,startOffsetSeconds,endOffsetSeconds,startJulianDay,endJulianDay,userFacingMotion\n"
    var retroCrossCSV = "body,focalCelestialTick,focalCelestialDegrees,celestialResolutionDegrees,utOffsetSeconds,utJulianDay\n"

    for body in Body.allCases {
        let data = allData[body]!
        allStations.append(contentsOf: data.stations)
        for station in data.stations {
            let offset = Int64(round((station.jd - p22StartJD) * secondsPerDay))
            let label = station.afterDirection < 0 ? "station_retrograde" : "station_direct"
            stationCSV += "\(body.name),\(String(format: "%.9f", station.longitude)),\(offset),\(String(format: "%.12f", station.jd)),\(directionName(station.beforeDirection)),\(directionName(station.afterDirection)),\(label)\n"
        }

        let bounds = [p22StartJD] + data.stations.map(\.jd) + [p23StartJD]
        var passages = 0
        for i in 0..<(bounds.count - 1) {
            let a = bounds[i], b = bounds[i + 1]
            if b - a < 1e-10 { continue }
            let mid = (a + b) * 0.5
            let state = try swiss.state(body, jd: mid)
            if state.speed < 0 {
                passages += 1
                let sa = try swiss.state(body, jd: a).longitude
                let sb = try swiss.state(body, jd: b).longitude
                let ao = Int64(round((a - p22StartJD) * secondsPerDay))
                let bo = Int64(round((b - p22StartJD) * secondsPerDay))
                retroCSV += "\(body.name),\(String(format: "%.9f", sa)),\(String(format: "%.9f", sb)),\(ao),\(bo),\(String(format: "%.12f", a)),\(String(format: "%.12f", b)),retrograde\n"
            }
        }
        totalRetroPassages += passages

        let retroRows = data.selected.filter { $0.direction < 0 }
        for row in retroRows {
            let offset = Int64(round((row.jd - p22StartJD) * secondsPerDay))
            retroCrossCSV += "\(body.name),\(row.tick),\(String(format: "%.1f", Double(row.tick) * body.selectedResolution)),\(String(format: "%.1f", body.selectedResolution)),\(offset),\(String(format: "%.12f", row.jd))\n"
        }

        let (wholeAudit, _) = markerAudit(focal: body, selectedRows: data.baseline, allData: allData)
        let (selectedAudit, arrays) = markerAudit(focal: body, selectedRows: data.selected, allData: allData)
        try writeBodyCSV(url: bodiesDir.appendingPathComponent("\(body.name).csv"), body: body, rows: data.selected, audit: selectedAudit, arrays: arrays)

        let focalBits = body.selectedResolution < 1.0 ? 12 : 9
        let bitsPerRecord = 33 + focalBits + 9 * selectedAudit.markerCount
        let packedBytes = Int(ceil(Double(data.selected.count * bitsPerRecord) / 8.0))
        bodySummaries.append(BodySummary(
            body: body.name,
            selectedResolutionDegrees: body.selectedResolution,
            selectedRecords: data.selected.count,
            wholeDegreeRecords: data.baseline.count,
            stationCount: data.stations.count,
            retrogradePassages: passages,
            retrogradeSelectedCrossings: retroRows.count,
            wholeDegreeMarkerAudit: wholeAudit,
            selectedResolutionMarkerAudit: selectedAudit,
            candidatePackedBytes: packedBytes
        ))
        print("AUDIT \(body.name): wholeSun=\(String(describing: wholeAudit.sunAloneRepeatedKeys)) selectedMarkers=\(selectedAudit.selectedMarkers) packed=\(packedBytes)")
    }

    try stationCSV.write(to: root.appendingPathComponent("station-table.csv"), atomically: true, encoding: .utf8)
    try retroCSV.write(to: root.appendingPathComponent("retrograde-passages.csv"), atomically: true, encoding: .utf8)
    try retroCrossCSV.write(to: root.appendingPathComponent("retrograde-crossings.csv"), atomically: true, encoding: .utf8)

    let durationSeconds = (p23StartJD - p22StartJD) * secondsPerDay
    let offsetBits = Int(ceil(log2(durationSeconds + 1.0)))
    let summary = Summary(
        status: "P22 eleven-body Mundane Timespine learning build; major/minor aspects and eclipses intentionally excluded",
        swissVersion: swiss.version,
        astronomicalSource: "Swiss Ephemeris DE441; geocentric tropical apparent ecliptic longitude; UT",
        spanName: "P22 Pluto Zeitgeist",
        startJulianDayUT: p22StartJD,
        endJulianDayUT: p23StartJD,
        startUTC: isoFromJD(p22StartJD),
        endUTC: isoFromJD(p23StartJD),
        durationDays: p23StartJD - p22StartJD,
        durationYears: (p23StartJD - p22StartJD) / 365.2425,
        civicOffsetBitsRequired: offsetBits,
        nodeRepresentation: "True North Node body table. Code stores increasing/decreasing celestial-time sequence; user-facing direct/retrograde terminology is retained. South Node is derived at +180 degrees.",
        bodyTables: bodySummaries,
        totalSelectedBodyRecords: bodySummaries.reduce(0) { $0 + $1.selectedRecords },
        candidatePackedBodyBytesTotal: bodySummaries.reduce(0) { $0 + $1.candidatePackedBytes },
        totalStations: allStations.count,
        totalRetrogradePassages: totalRetroPassages,
        notes: [
            "All body tables share one civic coordinate: integer seconds since the P22 Pluto 0 Aries boundary.",
            "Sun-first marker audit is run twice: at whole-degree resolution for direct comparison with the earlier pair tests, and at each body's selected candidate storage resolution.",
            "For non-Sun tables, the selected marker rule keeps Sun as the first companion and adds the smallest additional whole-degree marker set only when Sun alone repeats across P22.",
            "Sun cannot mark itself, so the Sun table selects the smallest non-repeating companion set from the other bodies.",
            "Selected candidate resolution is 1 degree for Sun through Mars and 0.1 degree for Jupiter, Saturn, Uranus, Neptune, Pluto, and the True North Node. This encodes the observed inverse relationship between celestial speed and economical angular fidelity.",
            "Crossing times are root-refined within station-bounded monotonic sample intervals. Stations are speed-zero turns located by bisection.",
            "This build is a candidate P22 body substrate, not final production serialization."
        ]
    )
    let enc = JSONEncoder()
    enc.outputFormatting = [.prettyPrinted, .sortedKeys]
    try enc.encode(summary).write(to: root.appendingPathComponent("summary.json"))
    print(String(data: try enc.encode(summary), encoding: .utf8)!)
}

do {
    try main()
} catch {
    fputs("P22TimespinePOC failed: \(error)\n", stderr)
    exit(1)
}
