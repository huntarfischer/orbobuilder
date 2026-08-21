import Foundation
import OrboCore
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

private let secondsPerDay = 86_400.0
private let gregorianCalendar: Int32 = 1
private let plutoBody: Int32 = 9

private func normalize(_ value: Double) -> Double {
    var result = value.truncatingRemainder(dividingBy: 360)
    if result < 0 { result += 360 }
    return result
}

private func signedShortestDelta(from a: Double, to b: Double) -> Double {
    var delta = normalize(b) - normalize(a)
    if delta > 180 { delta -= 360 }
    if delta < -180 { delta += 360 }
    return delta
}

private struct PlutoState {
    let longitude: Double
    let speed: Double
}

private struct ZeroCrossing: Codable {
    let julianDayUT: Double
    let utc: String
    let motion: String
}

private struct Station {
    let julianDayUT: Double
    let longitude: Double
    let motionBefore: Int
    let motionAfter: Int
}

private struct ZeitgeistRow: Codable {
    let id: String
    let ordinal: Int
    let preShadowStartJulianDayUT: Double?
    let preShadowStartUTC: String?
    let preShadowFloorDegree: Double?
    let firstAriesIngressJulianDayUT: Double
    let firstAriesIngressUTC: String
    let finalPiscesEgressJulianDayUT: Double
    let finalPiscesEgressUTC: String
    let nextZeitgeistFirstAriesIngressJulianDayUT: Double
    let nextZeitgeistFirstAriesIngressUTC: String
    let transitionCrossings: [ZeroCrossing]
}

private struct ZeitgeistArtifact: Codable {
    let artifactFamily: String
    let astronomicalSource: String
    let astronomicalSourceVersion: String
    let calendar: String
    let yearNumbering: String
    let ownershipLaw: String
    let shadowLaw: String
    let preShadowLaw: String
    let numberingAnchor: String
    let rows: [ZeitgeistRow]
}

private typealias SweSetEphePath = @convention(c) (UnsafePointer<CChar>?) -> Void
private typealias SweCalcUT = @convention(c) (Double, Int32, Int32, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<CChar>?) -> Int32
private typealias SweVersion = @convention(c) (UnsafeMutablePointer<CChar>?) -> UnsafePointer<CChar>?
private typealias SweJulday = @convention(c) (Int32, Int32, Int32, Double, Int32) -> Double
private typealias SweRevjul = @convention(c) (Double, Int32, UnsafeMutablePointer<Int32>?, UnsafeMutablePointer<Int32>?, UnsafeMutablePointer<Int32>?, UnsafeMutablePointer<Double>?) -> Void

private final class Swiss {
    static let swieph: Int32 = 2
    static let moseph: Int32 = 4
    static let speed: Int32 = 256

    private let handle: UnsafeMutableRawPointer
    private let setEphePath: SweSetEphePath
    private let calcUT: SweCalcUT
    private let versionFunction: SweVersion
    private let juldayFunction: SweJulday
    private let revjulFunction: SweRevjul

    let version: String

    init(library: String, epheDirectory: String) throws {
        guard let handle = dlopen(library, RTLD_NOW | RTLD_LOCAL) else {
            throw NSError(domain: "ZeitgeistTableForgeTool.dlopen", code: 1, userInfo: [NSLocalizedDescriptionKey: String(cString: dlerror())])
        }
        self.handle = handle

        func symbol<T>(_ name: String, as type: T.Type) throws -> T {
            guard let pointer = dlsym(handle, name) else {
                throw NSError(domain: "ZeitgeistTableForgeTool.dlsym", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing Swiss symbol \(name)"])
            }
            return unsafeBitCast(pointer, to: type)
        }

        setEphePath = try symbol("swe_set_ephe_path", as: SweSetEphePath.self)
        calcUT = try symbol("swe_calc_ut", as: SweCalcUT.self)
        versionFunction = try symbol("swe_version", as: SweVersion.self)
        juldayFunction = try symbol("swe_julday", as: SweJulday.self)
        revjulFunction = try symbol("swe_revjul", as: SweRevjul.self)

        epheDirectory.withCString { setEphePath($0) }
        var versionBuffer = [CChar](repeating: 0, count: 128)
        _ = versionBuffer.withUnsafeMutableBufferPointer { versionFunction($0.baseAddress) }
        version = String(cString: versionBuffer)
    }

    deinit { dlclose(handle) }

    func julianDay(year: Int32, month: Int32, day: Int32, hour: Double = 0) -> Double {
        juldayFunction(year, month, day, hour, gregorianCalendar)
    }

    func state(at julianDay: Double) throws -> PlutoState {
        var values = [Double](repeating: 0, count: 6)
        var error = [CChar](repeating: 0, count: 256)
        let flags = Swiss.swieph | Swiss.speed
        let returned = values.withUnsafeMutableBufferPointer { valuesBuffer in
            error.withUnsafeMutableBufferPointer { errorBuffer in
                calcUT(julianDay, plutoBody, flags, valuesBuffer.baseAddress, errorBuffer.baseAddress)
            }
        }
        guard returned >= 0,
              (returned & Swiss.swieph) != 0,
              (returned & Swiss.moseph) == 0 else {
            throw NSError(domain: "ZeitgeistTableForgeTool.Swiss", code: Int(returned), userInfo: [NSLocalizedDescriptionKey: String(cString: error)])
        }
        return PlutoState(longitude: normalize(values[0]), speed: values[3])
    }

    func utcString(_ julianDay: Double) -> String {
        // Round only the human-facing rendering. JD UT remains the canonical occurrence coordinate.
        let rounded = (julianDay * secondsPerDay * 1000).rounded() / (secondsPerDay * 1000)
        var year: Int32 = 0
        var month: Int32 = 0
        var day: Int32 = 0
        var hourValue = 0.0
        revjulFunction(rounded, gregorianCalendar, &year, &month, &day, &hourValue)
        var totalMilliseconds = Int((hourValue * 3_600_000).rounded())
        if totalMilliseconds >= 86_400_000 {
            return utcString(rounded + 0.5 / secondsPerDay)
        }
        let hour = totalMilliseconds / 3_600_000
        totalMilliseconds %= 3_600_000
        let minute = totalMilliseconds / 60_000
        totalMilliseconds %= 60_000
        let second = totalMilliseconds / 1000
        let millisecond = totalMilliseconds % 1000
        let yearText: String
        if year >= 0 {
            yearText = String(format: "%04d", year)
        } else {
            yearText = "-" + String(format: "%04d", abs(year))
        }
        return String(format: "%@-%02d-%02dT%02d:%02d:%02d.%03dZ", yearText, month, day, hour, minute, second, millisecond)
    }
}

private func refineStation(_ swiss: Swiss, lo: Double, hi: Double) throws -> Double {
    var a = lo
    var b = hi
    var fa = try swiss.state(at: a).speed
    for _ in 0..<56 {
        let middle = (a + b) * 0.5
        let fm = try swiss.state(at: middle).speed
        if abs(fm) < 1e-13 { return middle }
        if fa * fm <= 0 {
            b = middle
        } else {
            a = middle
            fa = fm
        }
    }
    return (a + b) * 0.5
}

private func refineZeroCrossing(
    _ swiss: Swiss,
    targetUnwrapped: Double,
    loJD: Double,
    hiJD: Double,
    anchorLongitude: Double,
    anchorUnwrapped: Double
) throws -> Double {
    var a = loJD
    var b = hiJD
    func value(_ jd: Double) throws -> (f: Double, speed: Double) {
        let state = try swiss.state(at: jd)
        let unwrapped = anchorUnwrapped + signedShortestDelta(from: anchorLongitude, to: state.longitude)
        return (unwrapped - targetUnwrapped, state.speed)
    }
    var va = try value(a)
    var vb = try value(b)
    guard va.f * vb.f <= 0 else { return (a + b) * 0.5 }
    for _ in 0..<48 {
        let middle = (a + b) * 0.5
        let vm = try value(middle)
        if abs(vm.f) < 1e-12 { return middle }
        if va.f * vm.f <= 0 {
            b = middle
            vb = vm
        } else {
            a = middle
            va = vm
        }
        if abs(b - a) * secondsPerDay < 0.001 { break }
    }
    _ = vb
    return (a + b) * 0.5
}

private func emitZeroCrossings(
    swiss: Swiss,
    loJD: Double,
    hiJD: Double,
    loState: PlutoState,
    hiState: PlutoState,
    into output: inout [(jd: Double, motion: Int)]
) throws {
    let loUnwrapped = loState.longitude
    let hiUnwrapped = loUnwrapped + signedShortestDelta(from: loState.longitude, to: hiState.longitude)
    let delta = hiUnwrapped - loUnwrapped
    if abs(delta) < 1e-14 { return }

    if delta > 0 {
        let firstMultiple = Int(floor(loUnwrapped / 360)) + 1
        let lastMultiple = Int(floor(hiUnwrapped / 360))
        if firstMultiple <= lastMultiple {
            for multiple in firstMultiple...lastMultiple {
                let target = Double(multiple) * 360
                let jd = try refineZeroCrossing(swiss, targetUnwrapped: target, loJD: loJD, hiJD: hiJD, anchorLongitude: loState.longitude, anchorUnwrapped: loUnwrapped)
                if output.last.map({ abs($0.jd - jd) * secondsPerDay < 1 }) != true {
                    output.append((jd, 1))
                }
            }
        }
    } else {
        let firstMultiple = Int(ceil(loUnwrapped / 360)) - 1
        let lastMultiple = Int(ceil(hiUnwrapped / 360))
        if firstMultiple >= lastMultiple {
            for multiple in stride(from: firstMultiple, through: lastMultiple, by: -1) {
                let target = Double(multiple) * 360
                let jd = try refineZeroCrossing(swiss, targetUnwrapped: target, loJD: loJD, hiJD: hiJD, anchorLongitude: loState.longitude, anchorUnwrapped: loUnwrapped)
                if output.last.map({ abs($0.jd - jd) * secondsPerDay < 1 }) != true {
                    output.append((jd, -1))
                }
            }
        }
    }
}

private func scanPluto(
    swiss: Swiss,
    startJD: Double,
    endJD: Double
) throws -> (crossings: [(jd: Double, motion: Int)], stations: [Station]) {
    let stepDays = 10.0
    var crossings: [(jd: Double, motion: Int)] = []
    var stations: [Station] = []
    var loJD = startJD
    var loState = try swiss.state(at: loJD)

    while loJD < endJD {
        let hiJD = min(endJD, loJD + stepDays)
        let hiState = try swiss.state(at: hiJD)
        if loState.speed * hiState.speed < 0 {
            let stationJD = try refineStation(swiss, lo: loJD, hi: hiJD)
            let stationState = try swiss.state(at: stationJD)
            let before = loState.speed >= 0 ? 1 : -1
            let after = hiState.speed >= 0 ? 1 : -1
            stations.append(Station(julianDayUT: stationJD, longitude: stationState.longitude, motionBefore: before, motionAfter: after))
            if stationJD > loJD + 1e-10 {
                try emitZeroCrossings(swiss: swiss, loJD: loJD, hiJD: stationJD, loState: loState, hiState: stationState, into: &crossings)
            }
            if hiJD > stationJD + 1e-10 {
                try emitZeroCrossings(swiss: swiss, loJD: stationJD, hiJD: hiJD, loState: stationState, hiState: hiState, into: &crossings)
            }
        } else {
            try emitZeroCrossings(swiss: swiss, loJD: loJD, hiJD: hiJD, loState: loState, hiState: hiState, into: &crossings)
        }
        loJD = hiJD
        loState = hiState
    }

    crossings.sort { $0.jd < $1.jd }
    stations.sort { $0.julianDayUT < $1.julianDayUT }
    return (crossings, stations)
}

private func groupTransitionCrossings(_ crossings: [(jd: Double, motion: Int)]) -> [[(jd: Double, motion: Int)]] {
    let clusterGapDays = 20 * 365.25
    var result: [[(jd: Double, motion: Int)]] = []
    for crossing in crossings {
        if let last = result.last?.last, crossing.jd - last.jd <= clusterGapDays {
            result[result.count - 1].append(crossing)
        } else {
            result.append([crossing])
        }
    }
    return result.filter { cluster in
        cluster.first?.motion == 1 && cluster.last?.motion == 1
    }
}

private func refineTargetCrossing(
    swiss: Swiss,
    targetDegree: Double,
    loJD: Double,
    hiJD: Double
) throws -> Double {
    var a = loJD
    var b = hiJD
    var fa = signedShortestDelta(from: targetDegree, to: try swiss.state(at: a).longitude)
    for _ in 0..<52 {
        let middle = (a + b) * 0.5
        let fm = signedShortestDelta(from: targetDegree, to: try swiss.state(at: middle).longitude)
        if abs(fm) < 1e-12 { return middle }
        if fa * fm <= 0 {
            b = middle
        } else {
            a = middle
            fa = fm
        }
        if abs(b - a) * secondsPerDay < 0.001 { break }
    }
    return (a + b) * 0.5
}

private func priorDirectCrossing(
    swiss: Swiss,
    targetDegree: Double,
    beforeJD: Double
) throws -> Double? {
    let start = beforeJD - 10 * 365.25
    let step = 2.0
    var loJD = start
    var loState = try swiss.state(at: loJD)
    var loDelta = signedShortestDelta(from: targetDegree, to: loState.longitude)
    while loJD < beforeJD {
        let hiJD = min(beforeJD, loJD + step)
        let hiState = try swiss.state(at: hiJD)
        let hiDelta = signedShortestDelta(from: targetDegree, to: hiState.longitude)
        if loState.speed > 0, hiState.speed > 0, loDelta <= 0, hiDelta >= 0 {
            return try refineTargetCrossing(swiss: swiss, targetDegree: targetDegree, loJD: loJD, hiJD: hiJD)
        }
        loJD = hiJD
        loState = hiState
        loDelta = hiDelta
    }
    return nil
}

private func csvEscaped(_ value: String) -> String {
    if value.contains(",") || value.contains("\"") || value.contains("\n") {
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
    return value
}

private func makeCSV(_ rows: [ZeitgeistRow]) -> String {
    var lines = [
        "zeitgeist_id,ordinal,pre_shadow_start_jd_ut,pre_shadow_start_utc,pre_shadow_floor_degree,first_aries_ingress_jd_ut,first_aries_ingress_utc,final_pisces_egress_jd_ut,final_pisces_egress_utc,next_zeitgeist_first_aries_ingress_jd_ut,next_zeitgeist_first_aries_ingress_utc,transition_crossing_count"
    ]
    for row in rows {
        let values = [
            row.id,
            String(row.ordinal),
            row.preShadowStartJulianDayUT.map { String(format: "%.12f", $0) } ?? "",
            row.preShadowStartUTC ?? "",
            row.preShadowFloorDegree.map { String(format: "%.9f", $0) } ?? "",
            String(format: "%.12f", row.firstAriesIngressJulianDayUT),
            row.firstAriesIngressUTC,
            String(format: "%.12f", row.finalPiscesEgressJulianDayUT),
            row.finalPiscesEgressUTC,
            String(format: "%.12f", row.nextZeitgeistFirstAriesIngressJulianDayUT),
            row.nextZeitgeistFirstAriesIngressUTC,
            String(row.transitionCrossings.count),
        ].map(csvEscaped)
        lines.append(values.joined(separator: ","))
    }
    return lines.joined(separator: "\n") + "\n"
}

private struct Arguments {
    let library: String
    let epheDirectory: String
    let jsonOutput: String
    let csvOutput: String

    init() throws {
        var library: String?
        var epheDirectory: String?
        var jsonOutput: String?
        var csvOutput: String?
        var index = 1
        let args = CommandLine.arguments
        while index < args.count {
            guard index + 1 < args.count else {
                throw NSError(domain: "ZeitgeistTableForgeTool.args", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing value for \(args[index])"])
            }
            switch args[index] {
            case "--library": library = args[index + 1]
            case "--ephe-dir": epheDirectory = args[index + 1]
            case "--json": jsonOutput = args[index + 1]
            case "--csv": csvOutput = args[index + 1]
            default:
                throw NSError(domain: "ZeitgeistTableForgeTool.args", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown argument \(args[index])"])
            }
            index += 2
        }
        guard let library, let epheDirectory, let jsonOutput, let csvOutput else {
            throw NSError(domain: "ZeitgeistTableForgeTool.args", code: 3, userInfo: [NSLocalizedDescriptionKey: "usage: ZeitgeistTableForgeTool --library <lib> --ephe-dir <dir> --json <path> --csv <path>"])
        }
        self.library = library
        self.epheDirectory = epheDirectory
        self.jsonOutput = jsonOutput
        self.csvOutput = csvOutput
    }
}

private func run() throws {
    let arguments = try Arguments()
    let swiss = try Swiss(library: arguments.library, epheDirectory: arguments.epheDirectory)
    guard swiss.version == MundaneTimespineP22ForgeRecipe.canonicalAstronomicalSourceVersion else {
        throw NSError(domain: "ZeitgeistTableForgeTool.version", code: 1, userInfo: [NSLocalizedDescriptionKey: "Swiss version \(swiss.version) does not equal canonical \(MundaneTimespineP22ForgeRecipe.canonicalAstronomicalSourceVersion)"])
    }

    let scanStart = swiss.julianDay(year: -3600, month: 1, day: 1)
    let scanEnd = swiss.julianDay(year: 4300, month: 1, day: 1)
    let scan = try scanPluto(swiss: swiss, startJD: scanStart, endJD: scanEnd)
    let clusters = groupTransitionCrossings(scan.crossings)

    guard let z0ClusterIndex = clusters.firstIndex(where: { cluster in
        guard let first = cluster.first else { return false }
        let utc = swiss.utcString(first.jd)
        return utc.hasPrefix("-3531-") || utc.hasPrefix("-3532-") || utc.hasPrefix("-3530-")
    }) else {
        throw NSError(domain: "ZeitgeistTableForgeTool.numbering", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not locate the established Z0 Pluto Aries ingress near 3532 BCE."])
    }
    guard clusters.count >= z0ClusterIndex + 32 else {
        throw NSError(domain: "ZeitgeistTableForgeTool.numbering", code: 2, userInfo: [NSLocalizedDescriptionKey: "Insufficient Pluto ingress clusters to construct Z0-Z30 plus Z31 next-owner boundary."])
    }

    var rows: [ZeitgeistRow] = []
    rows.reserveCapacity(31)
    for ordinal in 0...30 {
        let cluster = clusters[z0ClusterIndex + ordinal]
        let nextCluster = clusters[z0ClusterIndex + ordinal + 1]
        guard let first = cluster.first(where: { $0.motion == 1 }),
              let final = cluster.last(where: { $0.motion == 1 }),
              let nextFirst = nextCluster.first(where: { $0.motion == 1 }) else {
            throw NSError(domain: "ZeitgeistTableForgeTool.transition", code: ordinal, userInfo: [NSLocalizedDescriptionKey: "Malformed transition cluster for Z\(ordinal)"])
        }

        var preShadowStart: Double?
        var shadowFloor: Double?
        if let returnToPisces = cluster.first(where: { $0.jd > first.jd && $0.motion == -1 }),
           let directStation = scan.stations.first(where: {
               $0.julianDayUT > returnToPisces.jd &&
               $0.julianDayUT < final.jd &&
               $0.motionBefore == -1 &&
               $0.motionAfter == 1
           }) {
            shadowFloor = directStation.longitude
            preShadowStart = try priorDirectCrossing(swiss: swiss, targetDegree: directStation.longitude, beforeJD: first.jd)
        }

        let crossingRows = cluster.map {
            ZeroCrossing(
                julianDayUT: $0.jd,
                utc: swiss.utcString($0.jd),
                motion: $0.motion == 1 ? "direct" : "retrograde"
            )
        }

        rows.append(ZeitgeistRow(
            id: "Z\(ordinal)",
            ordinal: ordinal,
            preShadowStartJulianDayUT: preShadowStart,
            preShadowStartUTC: preShadowStart.map(swiss.utcString),
            preShadowFloorDegree: shadowFloor,
            firstAriesIngressJulianDayUT: first.jd,
            firstAriesIngressUTC: swiss.utcString(first.jd),
            finalPiscesEgressJulianDayUT: final.jd,
            finalPiscesEgressUTC: swiss.utcString(final.jd),
            nextZeitgeistFirstAriesIngressJulianDayUT: nextFirst.jd,
            nextZeitgeistFirstAriesIngressUTC: swiss.utcString(nextFirst.jd),
            transitionCrossings: crossingRows
        ))
    }

    guard rows.count == 31 else {
        throw NSError(domain: "ZeitgeistTableForgeTool.rows", code: 1, userInfo: [NSLocalizedDescriptionKey: "Expected 31 Z rows."])
    }

    let artifact = ZeitgeistArtifact(
        artifactFamily: "Orbo Pluto Zeitgeist Z0-Z30 canonical boundary table",
        astronomicalSource: MundaneTimespineP22ForgeRecipe.astronomicalSource,
        astronomicalSourceVersion: swiss.version,
        calendar: "proleptic Gregorian UTC",
        yearNumbering: "astronomical year numbering; year 0 = 1 BCE",
        ownershipLaw: "A Zeitgeist owner begins at Pluto's first direct ingress into Aries and remains owner until the next Zeitgeist's first direct Aries ingress.",
        shadowLaw: "If Pluto returns to Pisces after the new owner begins, the previous Zeitgeist remains as Shadow until Pluto's final direct egress from Pisces into Aries.",
        preShadowLaw: "Zeitgeist pre-shadow begins at Pluto's earlier direct crossing of the later direct-station degree to which Pluto falls back after first Aries ingress.",
        numberingAnchor: "Z0 = established Pluto first-Aries-ingress generation near 3532 BCE; sequence validated forward to Z22/Z23.",
        rows: rows
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    var json = try encoder.encode(artifact)
    json.append(0x0a)
    try FileManager.default.createDirectory(at: URL(fileURLWithPath: arguments.jsonOutput).deletingLastPathComponent(), withIntermediateDirectories: true)
    try json.write(to: URL(fileURLWithPath: arguments.jsonOutput), options: .atomic)
    try makeCSV(rows).data(using: .utf8)!.write(to: URL(fileURLWithPath: arguments.csvOutput), options: .atomic)

    let z22 = rows[22]
    let z23 = rows[23]
    let oldStartDelta = (z22.firstAriesIngressJulianDayUT - MundaneTimespineP22.startJulianDay.value) * secondsPerDay
    let oldEndFromZ23First = (z23.firstAriesIngressJulianDayUT - MundaneTimespineP22.endJulianDay.value) * secondsPerDay
    let oldEndFromZ23Final = (z23.finalPiscesEgressJulianDayUT - MundaneTimespineP22.endJulianDay.value) * secondsPerDay

    print("ZEITGEIST TABLE Z0-Z30")
    print("source=\(artifact.astronomicalSource) / \(swiss.version)")
    print("rows=\(rows.count)")
    print("Z0 firstAriesIngress=\(rows[0].firstAriesIngressUTC)")
    print("Z22 firstAriesIngress=\(z22.firstAriesIngressUTC) oldP22StartDeltaSeconds=\(String(format: "%.3f", oldStartDelta))")
    print("Z23 firstAriesIngress=\(z23.firstAriesIngressUTC) oldP22EndDeltaSeconds=\(String(format: "%.3f", oldEndFromZ23First))")
    print("Z23 finalPiscesEgress=\(z23.finalPiscesEgressUTC) oldP22EndDeltaSeconds=\(String(format: "%.3f", oldEndFromZ23Final))")
    print("json=\(arguments.jsonOutput)")
    print("csv=\(arguments.csvOutput)")
}

do {
    try run()
} catch {
    fputs("ZeitgeistTableForgeTool error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
