import Foundation

private let p22StartJD = 2_386_637.079399706
private let p22EndJD = 2_475_819.1417904524
private let signNames = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces",
]

private enum EclipseKind: String, Codable, CaseIterable {
    case solar
    case lunar

    var orientationBody: String { self == .solar ? "Sun" : "Moon" }
    var swetestMode: String { self == .solar ? "-solecl" : "-lunecl" }
    var planetSelector: String { self == .solar ? "-p0" : "-p1" }
}

private struct RawEclipse {
    let kind: EclipseKind
    let type: String
    let julianDayUT: Double
    let sarosSeries: Int
    let sarosMember: Int
    let magnitude: Double
    let secondaryMagnitude: Double?
}

private struct EclipseRow: Codable {
    let eclipseDegree: Double
    let sign: String
    let degreeInSign: Double
    let orientationBody: String
    let kind: EclipseKind
    let type: String
    let civicOffsetSeconds: Int64
    let julianDayUT: Double
    let utc: String
    let sarosSeries: Int
    let sarosMember: Int
    let magnitude: Double
    let secondaryMagnitude: Double?
}

private struct Summary: Codable {
    let spanName: String
    let startJulianDayUT: Double
    let endJulianDayUTExclusive: Double
    let primaryOrientation: String
    let secondaryBinding: String
    let tableOrder: String
    let astronomicalSource: String
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
    case commandFailed(String)
    case malformedOutput(String)
    case validation(String)

    var description: String {
        switch self {
        case .usage(let message), .commandFailed(let message), .malformedOutput(let message), .validation(let message):
            return message
        }
    }
}

private struct Arguments {
    let swetest: String
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
                throw ForgeFailure.usage("Usage: main.swift --swetest PATH --ephe PATH --source-sha SHA --csv PATH --summary PATH")
            }
            values[key] = raw[index + 1]
            index += 2
        }
        guard let swetest = values["--swetest"],
              let ephe = values["--ephe"],
              let sourceSHA = values["--source-sha"],
              let csv = values["--csv"],
              let summary = values["--summary"],
              !sourceSHA.isEmpty else {
            throw ForgeFailure.usage("Missing required Forge argument.")
        }
        self.swetest = swetest
        self.ephe = ephe
        self.sourceSHA = sourceSHA
        self.csv = csv
        self.summary = summary
    }
}

private func run(_ executable: String, _ arguments: [String]) throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments

    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr

    try process.run()
    process.waitUntilExit()

    let outData = stdout.fileHandleForReading.readDataToEndOfFile()
    let errData = stderr.fileHandleForReading.readDataToEndOfFile()
    let out = String(data: outData, encoding: .utf8) ?? ""
    let err = String(data: errData, encoding: .utf8) ?? ""

    guard process.terminationStatus == 0 else {
        throw ForgeFailure.commandFailed("Command failed (\(process.terminationStatus)): \(executable) \(arguments.joined(separator: " "))\n\(err)\n\(out)")
    }
    let lower = (out + "\n" + err).lowercased()
    if lower.contains("error") || lower.contains("file not found") {
        throw ForgeFailure.commandFailed("Swiss Ephemeris reported an error:\n\(err)\n\(out)")
    }
    return out
}

private func eclipseType(from descriptor: String, kind: EclipseKind) throws -> String {
    let lower = descriptor.lowercased()
    switch kind {
    case .solar:
        if lower.hasPrefix("ann-tot") { return "hybrid" }
        if lower.hasPrefix("total") { return "total" }
        if lower.hasPrefix("annular") { return "annular" }
        if lower.hasPrefix("partial") { return "partial" }
    case .lunar:
        if lower.hasPrefix("total") { return "total" }
        if lower.hasPrefix("penumb.") { return "penumbral" }
        if lower.hasPrefix("partial") { return "partial" }
    }
    throw ForgeFailure.malformedOutput("Unknown \(kind.rawValue) eclipse type: \(descriptor)")
}

private func parseSaros(_ field: String) throws -> (Int, Int) {
    let text = field.replacingOccurrences(of: "saros", with: "", options: [.caseInsensitive]).trimmingCharacters(in: .whitespaces)
    let parts = text.split(separator: "/")
    guard parts.count == 2,
          let series = Int(parts[0].trimmingCharacters(in: .whitespaces)),
          let member = Int(parts[1].trimmingCharacters(in: .whitespaces)) else {
        throw ForgeFailure.malformedOutput("Malformed Saros field: \(field)")
    }
    return (series, member)
}

private func parseMagnitudeField(_ field: String, kind: EclipseKind) throws -> (Double, Double?) {
    let parts = field.split(separator: "/").map { $0.trimmingCharacters(in: .whitespaces) }
    guard let first = parts.first, let magnitude = Double(first) else {
        throw ForgeFailure.malformedOutput("Malformed magnitude field: \(field)")
    }
    switch kind {
    case .solar:
        return (magnitude, nil)
    case .lunar:
        let secondary = parts.count > 1 ? Double(parts[1]) : nil
        return (magnitude, secondary)
    }
}

private func parseEclipses(_ output: String, kind: EclipseKind) throws -> [RawEclipse] {
    var rows: [RawEclipse] = []
    for rawLine in output.split(whereSeparator: \.isNewline) {
        let line = String(rawLine)
        let lower = line.lowercased()
        let isEventLine: Bool
        switch kind {
        case .solar: isEventLine = lower.contains(" solar\t")
        case .lunar: isEventLine = lower.contains("lunar eclipse\t")
        }
        guard isEventLine else { continue }

        let fields = line.split(separator: "\t", omittingEmptySubsequences: false).map {
            String($0).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard fields.count >= 6,
              let jdField = fields.last,
              let jd = Double(jdField),
              let sarosIndex = fields.firstIndex(where: { $0.lowercased().hasPrefix("saros ") }),
              sarosIndex > 0 else {
            throw ForgeFailure.malformedOutput("Malformed Swiss eclipse row: \(line)")
        }

        let type = try eclipseType(from: fields[0], kind: kind)
        let (series, member) = try parseSaros(fields[sarosIndex])
        let (magnitude, secondary) = try parseMagnitudeField(fields[sarosIndex - 1], kind: kind)
        rows.append(RawEclipse(
            kind: kind,
            type: type,
            julianDayUT: jd,
            sarosSeries: series,
            sarosMember: member,
            magnitude: magnitude,
            secondaryMagnitude: secondary
        ))
    }
    guard !rows.isEmpty else {
        throw ForgeFailure.malformedOutput("Swiss Ephemeris returned no \(kind.rawValue) eclipse event rows.")
    }
    return rows
}

private func enumerateEclipses(kind: EclipseKind, arguments: Arguments) throws -> [RawEclipse] {
    let output = try run(arguments.swetest, [
        "-bj\(String(format: "%.9f", p22StartJD))",
        "-ut",
        "-eswe",
        "-edir\(arguments.ephe)",
        kind.swetestMode,
        "-n800",
        "-head",
    ])
    let all = try parseEclipses(output, kind: kind)
    guard all.contains(where: { $0.julianDayUT >= p22EndJD }) else {
        throw ForgeFailure.validation("Swiss \(kind.rawValue) enumeration did not run beyond the P22 exclusive end; completeness is unproven.")
    }
    return all.filter { $0.julianDayUT >= p22StartJD && $0.julianDayUT < p22EndJD }
}

private func longitude(at jd: Double, kind: EclipseKind, arguments: Arguments) throws -> Double {
    let output = try run(arguments.swetest, [
        "-bj\(String(format: "%.9f", jd))",
        "-ut",
        "-eswe",
        "-edir\(arguments.ephe)",
        kind.planetSelector,
        "-fl",
        "-ep",
        "-head",
    ])
    for rawLine in output.split(whereSeparator: \.isNewline) {
        let text = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
        if let value = Double(text), value.isFinite {
            var normalized = value.truncatingRemainder(dividingBy: 360)
            if normalized < 0 { normalized += 360 }
            guard normalized >= 0, normalized < 360 else {
                throw ForgeFailure.malformedOutput("Swiss longitude outside zodiac: \(value)")
            }
            return normalized
        }
    }
    throw ForgeFailure.malformedOutput("Could not parse \(kind.orientationBody) longitude at JD \(jd):\n\(output)")
}

private func utcString(for jd: Double) -> String {
    let unixSeconds = (jd - 2_440_587.5) * 86_400
    let date = Date(timeIntervalSince1970: unixSeconds)
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    return formatter.string(from: date)
}

private func makeRows(raw: [RawEclipse], arguments: Arguments) throws -> [EclipseRow] {
    var seen: Set<String> = []
    var rows: [EclipseRow] = []
    rows.reserveCapacity(raw.count)

    for event in raw {
        let identity = "\(event.kind.rawValue)|\(String(format: "%.6f", event.julianDayUT))"
        guard seen.insert(identity).inserted else {
            throw ForgeFailure.validation("Duplicate eclipse occurrence: \(identity)")
        }
        let degree = try longitude(at: event.julianDayUT, kind: event.kind, arguments: arguments)
        let signIndex = Int(floor(degree / 30.0))
        guard signNames.indices.contains(signIndex) else {
            throw ForgeFailure.validation("Could not orient eclipse degree \(degree) on zodiac.")
        }
        let offset = Int64(((event.julianDayUT - p22StartJD) * 86_400).rounded())
        rows.append(EclipseRow(
            eclipseDegree: degree,
            sign: signNames[signIndex],
            degreeInSign: degree - Double(signIndex * 30),
            orientationBody: event.kind.orientationBody,
            kind: event.kind,
            type: event.type,
            civicOffsetSeconds: offset,
            julianDayUT: event.julianDayUT,
            utc: utcString(for: event.julianDayUT),
            sarosSeries: event.sarosSeries,
            sarosMember: event.sarosMember,
            magnitude: event.magnitude,
            secondaryMagnitude: event.secondaryMagnitude
        ))
    }

    rows.sort {
        if abs($0.eclipseDegree - $1.eclipseDegree) > 1e-12 { return $0.eclipseDegree < $1.eclipseDegree }
        return $0.julianDayUT < $1.julianDayUT
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
    var lines = ["eclipse_degree,sign,degree_in_sign,orientation_body,eclipse_kind,eclipse_type,civic_offset_seconds,julian_day_ut,utc,saros_series,saros_member,magnitude,secondary_magnitude"]
    lines.reserveCapacity(rows.count + 1)
    for row in rows {
        let fields = [
            String(format: "%.11f", row.eclipseDegree),
            row.sign,
            String(format: "%.11f", row.degreeInSign),
            row.orientationBody,
            row.kind.rawValue,
            row.type,
            String(row.civicOffsetSeconds),
            String(format: "%.6f", row.julianDayUT),
            row.utc,
            String(row.sarosSeries),
            String(row.sarosMember),
            String(format: "%.6f", row.magnitude),
            row.secondaryMagnitude.map { String(format: "%.6f", $0) } ?? "",
        ].map(csvEscaped)
        lines.append(fields.joined(separator: ","))
    }
    let url = URL(fileURLWithPath: path)
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try (lines.joined(separator: "\n") + "\n").write(to: url, atomically: true, encoding: .utf8)
}

private func writeSummary(_ rows: [EclipseRow], arguments: Arguments) throws {
    guard let minDegree = rows.map(\.eclipseDegree).min(), let maxDegree = rows.map(\.eclipseDegree).max() else {
        throw ForgeFailure.validation("Cannot summarize an empty eclipse table.")
    }
    let solar = rows.filter { $0.kind == .solar }.count
    let lunar = rows.filter { $0.kind == .lunar }.count
    var counts: [String: Int] = [:]
    for row in rows { counts["\(row.kind.rawValue).\(row.type)", default: 0] += 1 }

    let summary = Summary(
        spanName: "P22 Pluto Zeitgeist",
        startJulianDayUT: p22StartJD,
        endJulianDayUTExclusive: p22EndJD,
        primaryOrientation: "eclipse zodiacal degree (Sun for solar eclipses; Moon for lunar eclipses)",
        secondaryBinding: "civic UT / Julian Day occurrence",
        tableOrder: "eclipse_degree ascending, then julian_day_ut ascending",
        astronomicalSource: "Swiss Ephemeris; geocentric tropical apparent ecliptic longitude; UT",
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
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    var data = try encoder.encode(summary)
    data.append(0x0A)
    let url = URL(fileURLWithPath: arguments.summary)
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url, options: .atomic)
}

private func validate(_ rows: [EclipseRow]) throws {
    guard rows.count > 800 else { throw ForgeFailure.validation("P22 eclipse table unexpectedly sparse: \(rows.count) rows") }
    let solar = rows.filter { $0.kind == .solar }
    let lunar = rows.filter { $0.kind == .lunar }
    guard solar.count > 400, lunar.count > 400 else {
        throw ForgeFailure.validation("P22 eclipse populations unexpectedly sparse: solar \(solar.count), lunar \(lunar.count)")
    }
    let solarTypes = Set(["total", "annular", "hybrid", "partial"])
    let lunarTypes = Set(["total", "partial", "penumbral"])
    for (index, row) in rows.enumerated() {
        guard row.julianDayUT >= p22StartJD, row.julianDayUT < p22EndJD else {
            throw ForgeFailure.validation("Eclipse outside P22 at row \(index)")
        }
        guard row.eclipseDegree >= 0, row.eclipseDegree < 360 else {
            throw ForgeFailure.validation("Eclipse degree outside zodiac at row \(index)")
        }
        guard row.civicOffsetSeconds >= 0 else {
            throw ForgeFailure.validation("Negative P22 civic offset at row \(index)")
        }
        switch row.kind {
        case .solar:
            guard row.orientationBody == "Sun", solarTypes.contains(row.type) else {
                throw ForgeFailure.validation("Malformed solar row at \(index)")
            }
        case .lunar:
            guard row.orientationBody == "Moon", lunarTypes.contains(row.type) else {
                throw ForgeFailure.validation("Malformed lunar row at \(index)")
            }
        }
        if index > 0 {
            let prior = rows[index - 1]
            guard prior.eclipseDegree < row.eclipseDegree ||
                    (abs(prior.eclipseDegree - row.eclipseDegree) <= 1e-12 && prior.julianDayUT <= row.julianDayUT) else {
                throw ForgeFailure.validation("Eclipse table is not celestial-degree first at row \(index)")
            }
        }
    }
}

do {
    let arguments = try Arguments(Array(CommandLine.arguments.dropFirst()))
    for file in ["sepl_18.se1", "semo_18.se1"] {
        let path = URL(fileURLWithPath: arguments.ephe).appendingPathComponent(file).path
        guard FileManager.default.fileExists(atPath: path) else {
            throw ForgeFailure.validation("Required Swiss ephemeris file missing: \(path)")
        }
    }

    let solar = try enumerateEclipses(kind: .solar, arguments: arguments)
    let lunar = try enumerateEclipses(kind: .lunar, arguments: arguments)
    let rows = try makeRows(raw: solar + lunar, arguments: arguments)
    try validate(rows)
    try writeCSV(rows, to: arguments.csv)
    try writeSummary(rows, arguments: arguments)

    let counts = Dictionary(grouping: rows, by: { $0.kind }).mapValues(\.count)
    print("Forged P22 eclipse table: \(rows.count) rows")
    print("Solar: \(counts[.solar, default: 0])  Lunar: \(counts[.lunar, default: 0])")
    print("Primary order: eclipse degree, then civic occurrence")
} catch {
    fputs("Eclipse Forge failed: \(error)\n", stderr)
    exit(1)
}
