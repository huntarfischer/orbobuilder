import CryptoKit
import Foundation
import OrboCore

enum P22CanonicalAssemblyError: Error, CustomStringConvertible {
    case missingInput(String)
    case inputByteCount(String, expected: Int, actual: Int)
    case inputSHA(String, expected: String, actual: String)
    case gzip(String)
    case malformedCSV(String)
    case rowCount(String, expected: Int, actual: Int)
    case invalidValue(String)
    case storageImage

    var description: String {
        switch self {
        case let .missingInput(path):
            return "Missing canonical P22 input: \(path)"
        case let .inputByteCount(path, expected, actual):
            return "Canonical P22 input byte count changed for \(path): expected \(expected), got \(actual)."
        case let .inputSHA(path, expected, actual):
            return "Canonical P22 input SHA-256 changed for \(path): expected \(expected), got \(actual)."
        case let .gzip(message):
            return "Could not stream canonical gzip input: \(message)"
        case let .malformedCSV(message):
            return "Malformed canonical P22 CSV: \(message)"
        case let .rowCount(path, expected, actual):
            return "Canonical P22 row count changed for \(path): expected \(expected), got \(actual)."
        case let .invalidValue(message):
            return "Invalid canonical P22 value: \(message)"
        case .storageImage:
            return "Canonical P22 inputs could not form a valid Timespine storage image."
        }
    }
}

struct P22CanonicalAssemblyProgress {
    let stage: String
    let detail: String
}

struct P22CanonicalAssembler {
    let dataDirectory: URL

    private static let decimalLocale = Locale(identifier: "en_US_POSIX")
    private static let p22StartJulianDayDecimal = Decimal(
        string: "2386637.079399706",
        locale: decimalLocale
    )!

    func assemble(
        progress: ((P22CanonicalAssemblyProgress) -> Void)? = nil
    ) throws -> MundaneTimespineStorageImage {
        progress?(.init(stage: "inputs", detail: "verifying frozen gzip identities"))
        try verifyCanonicalInputs()

        var occurrences: [MundaneBody: [MundaneTimespineStoredOccurrence]] = [:]
        for body in MundaneBody.canonicalOrder {
            progress?(.init(stage: "bodies", detail: body.displayName))
            occurrences[body] = try readBody(body)
        }

        progress?(.init(stage: "motion", detail: "stations"))
        let stations = try readStations()
        progress?(.init(stage: "motion", detail: "retrograde passages"))
        let passages = try readRetrogradePassages()

        var storedBodies: [MundaneTimespineStoredBody] = []
        storedBodies.reserveCapacity(MundaneBody.canonicalOrder.count)
        for body in MundaneBody.canonicalOrder {
            let profile = MundaneTimespineP22.profile(for: body)
            let ticksPerDegree = Int((1 / profile.celestialResolutionDegrees).rounded())
            guard let stored = MundaneTimespineStoredBody(
                body: body,
                ticksPerDegree: ticksPerDegree,
                markerBodies: profile.markerBodies,
                occurrences: occurrences[body] ?? [],
                stations: stations[body] ?? [],
                retrogradePassages: passages[body] ?? []
            ) else {
                throw P22CanonicalAssemblyError.invalidValue("stored body \(body.displayName)")
            }
            storedBodies.append(stored)
        }

        progress?(.init(stage: "events", detail: "exact major relationships"))
        var relationships = try readRelationships(
            input: requiredInput(.exactMajorRelationships)
        )
        progress?(.init(stage: "events", detail: "exact minor relationships"))
        relationships.append(contentsOf: try readRelationships(
            input: requiredInput(.exactMinorRelationships)
        ))
        guard relationships.count == MundaneTimespineP22CanonicalInputs.expectedRelationshipRows else {
            throw P22CanonicalAssemblyError.rowCount(
                "exact relationships",
                expected: MundaneTimespineP22CanonicalInputs.expectedRelationshipRows,
                actual: relationships.count
            )
        }

        progress?(.init(stage: "events", detail: "eclipses"))
        let eclipses = try readEclipses()

        guard let image = MundaneTimespineStorageImage(
            spanName: MundaneTimespineP22.spanName,
            astronomicalSource: MundaneTimespineP22CanonicalInputs.astronomicalSource,
            astronomicalSourceVersion: MundaneTimespineP22CanonicalInputs.astronomicalSourceVersion,
            supportedStart: MundaneTimespineP22.startJulianDay,
            supportedEnd: MundaneTimespineP22.endJulianDay,
            bodies: storedBodies,
            relationships: relationships,
            eclipses: eclipses
        ) else {
            throw P22CanonicalAssemblyError.storageImage
        }
        return image
    }

    private func verifyCanonicalInputs() throws {
        for input in MundaneTimespineP22CanonicalInputs.all {
            let url = dataDirectory.appendingPathComponent(input.relativePath)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw P22CanonicalAssemblyError.missingInput(input.relativePath)
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let actualBytes = (attributes[.size] as? NSNumber)?.intValue ?? -1
            guard actualBytes == input.compressedBytes else {
                throw P22CanonicalAssemblyError.inputByteCount(
                    input.relativePath,
                    expected: input.compressedBytes,
                    actual: actualBytes
                )
            }
            let actualSHA = try sha256(url)
            guard actualSHA == input.sha256 else {
                throw P22CanonicalAssemblyError.inputSHA(
                    input.relativePath,
                    expected: input.sha256,
                    actual: actualSHA
                )
            }
        }
    }

    private func readBody(_ body: MundaneBody) throws -> [MundaneTimespineStoredOccurrence] {
        let profile = MundaneTimespineP22.profile(for: body)
        let input = try bodyInput(body)
        let markerFields = profile.markerBodies.map { "\($0.constructionDataName)Degree" }
        let expectedHeader = [
            "focalCelestialTick",
            "focalCelestialDegrees",
            "celestialResolutionDegrees",
            "occurrence",
            "utOffsetSeconds",
            "utJulianDay",
            "sequenceDirection",
        ] + markerFields

        var rows: [MundaneTimespineStoredOccurrence] = []
        rows.reserveCapacity(profile.constructionRecordCount)
        let count = try streamCSV(input) { header, row, rowNumber in
            guard header == expectedHeader else {
                throw P22CanonicalAssemblyError.malformedCSV(
                    "\(input.relativePath) header changed: \(header.joined(separator: ","))"
                )
            }
            let tick = try int(row, "focalCelestialTick", rowNumber)
            let degrees = try double(row, "focalCelestialDegrees", rowNumber)
            let resolution = try double(row, "celestialResolutionDegrees", rowNumber)
            let offset = try int64(row, "utOffsetSeconds", rowNumber)
            _ = try double(row, "utJulianDay", rowNumber)
            let sequence = try sequenceDirection(required(row, "sequenceDirection", rowNumber))
            guard abs(resolution - profile.celestialResolutionDegrees) < 1e-12,
                  abs(degrees - Double(tick) * resolution) < 1e-7,
                  offset >= 0 else {
                throw P22CanonicalAssemblyError.invalidValue("\(input.relativePath) row \(rowNumber)")
            }
            let markers: [UInt16] = try markerFields.map { field in
                let value = try int(row, field, rowNumber)
                guard (0..<360).contains(value) else {
                    throw P22CanonicalAssemblyError.invalidValue("\(input.relativePath) row \(rowNumber) \(field)")
                }
                return UInt16(value)
            }
            rows.append(.assembled(
                celestialTick: tick,
                civicOffsetSeconds: offset,
                sequenceDirection: sequence,
                markerWholeDegrees: markers
            ))
        }
        try requireExpectedRows(input, actual: count)
        return rows
    }

    private func readStations() throws -> [MundaneBody: [MundaneTimespineStoredStation]] {
        let input = requiredInput(.stations)
        var byBody: [MundaneBody: [MundaneTimespineStoredStation]] = [:]
        let count = try streamCSV(input) { _, row, rowNumber in
            let body = try body(named: required(row, "body", rowNumber))
            let degrees = try double(row, "celestialTimeDegrees", rowNumber)
            let offset = try int64(row, "utOffsetSeconds", rowNumber)
            let after = try sequenceDirection(required(row, "sequenceAfter", rowNumber)).motion
            byBody[body, default: []].append(.assembled(
                celestialMicrodegrees: microdegrees(degrees),
                civicOffsetSeconds: offset,
                motionAfter: after
            ))
        }
        try requireExpectedRows(input, actual: count)
        return byBody
    }

    private func readRetrogradePassages() throws -> [MundaneBody: [MundaneTimespineStoredRetrogradePassage]] {
        let input = requiredInput(.retrogradePassages)
        var byBody: [MundaneBody: [MundaneTimespineStoredRetrogradePassage]] = [:]
        let count = try streamCSV(input) { _, row, rowNumber in
            let body = try body(named: required(row, "body", rowNumber))
            let startDegrees = try doubleAny(
                row,
                ["startCelestialTimeDegrees", "startCelestialDegrees"],
                rowNumber
            )
            let endDegrees = try doubleAny(
                row,
                ["endCelestialTimeDegrees", "endCelestialDegrees"],
                rowNumber
            )
            let startOffset = try int64Any(
                row,
                ["startOffsetSeconds", "startCivicTimeOffsetSeconds"],
                rowNumber
            )
            let endOffset = try int64Any(
                row,
                ["endOffsetSeconds", "endCivicTimeOffsetSeconds"],
                rowNumber
            )
            guard startOffset >= 0, endOffset >= startOffset else {
                throw P22CanonicalAssemblyError.invalidValue("\(input.relativePath) row \(rowNumber)")
            }
            byBody[body, default: []].append(.assembled(
                startCelestialMicrodegrees: microdegrees(startDegrees),
                endCelestialMicrodegrees: microdegrees(endDegrees),
                startCivicOffsetSeconds: startOffset,
                endCivicOffsetSeconds: endOffset
            ))
        }
        try requireExpectedRows(input, actual: count)
        return byBody
    }

    private func readRelationships(
        input: MundaneTimespineP22CanonicalInput
    ) throws -> [MundaneTimespineRelationshipEvent] {
        var events: [MundaneTimespineRelationshipEvent] = []
        events.reserveCapacity(input.expectedRows ?? 0)
        let count = try streamCSV(input) { header, row, rowNumber in
            let bodyA = try body(named: required(row, "bodyA", rowNumber))
            let bodyB = try body(named: required(row, "bodyB", rowNumber))
            let ringDegrees = try int(row, "ringDegrees", rowNumber)
            guard let mark = RingMark(rawValue: ringDegrees) else {
                throw P22CanonicalAssemblyError.invalidValue("\(input.relativePath) row \(rowNumber) ringDegrees")
            }
            let orientation = try relationshipOrientation(required(row, "orientation", rowNumber))
            let aDegrees = try double(row, "bodyACelestialTimeDegrees", rowNumber)
            let bDegrees = try double(row, "bodyBCelestialTimeDegrees", rowNumber)
            let jdText = try required(row, "civicTimeJulianDayUT", rowNumber)
            guard let sourceJD = Double(jdText), sourceJD.isFinite else {
                throw P22CanonicalAssemblyError.invalidValue(
                    "\(input.relativePath) row \(rowNumber) civicTimeJulianDayUT"
                )
            }

            var storageJD = sourceJD
            if header.contains("civicTimeOffsetSeconds") {
                let storedOffset = try int64(row, "civicTimeOffsetSeconds", rowNumber)
                let derivedOffset = try decimalRoundedP22Offset(
                    julianDayText: jdText,
                    rowNumber: rowNumber
                )
                guard storedOffset >= 0, storedOffset == derivedOffset else {
                    throw P22CanonicalAssemblyError.invalidValue("\(input.relativePath) row \(rowNumber) civic offset")
                }

                // The gzip keeps the sub-second astronomical JD for audit. ORBOTS civic time is the
                // admitted integer-second P22 coordinate. Normalize the storage event to that exact
                // persisted coordinate so later Double subtraction cannot move a half-second edge.
                storageJD = MundaneTimespineP22.startJulianDay.value + Double(storedOffset) / 86_400
            }

            let residual = header.contains("exactAspectResidualArcSeconds")
                ? try double(row, "exactAspectResidualArcSeconds", rowNumber)
                : 0
            guard residual >= 0 else {
                throw P22CanonicalAssemblyError.invalidValue(
                    "\(input.relativePath) row \(rowNumber) exact aspect residual"
                )
            }
            guard let julianDay = JulianDay(storageJD),
                  let event = MundaneTimespineRelationshipEvent(
                    bodyA: bodyA,
                    bodyB: bodyB,
                    mark: mark,
                    orientation: orientation,
                    bodyACelestialTimeDegrees: aDegrees,
                    bodyBCelestialTimeDegrees: bDegrees,
                    julianDay: julianDay,
                    exactAspectResidualArcSeconds: residual
                  ) else {
                throw P22CanonicalAssemblyError.invalidValue("\(input.relativePath) row \(rowNumber)")
            }
            events.append(event)
        }
        try requireExpectedRows(input, actual: count)
        return events
    }

    private func readEclipses() throws -> [MundaneTimespineEclipseEvent] {
        let input = requiredInput(.eclipses)
        var events: [MundaneTimespineEclipseEvent] = []
        events.reserveCapacity(input.expectedRows ?? 0)
        let count = try streamCSV(input) { _, row, rowNumber in
            let degree = try double(row, "eclipse_degree", rowNumber)
            let kind = try eclipseKind(required(row, "eclipse_kind", rowNumber))
            let type = try eclipseType(required(row, "eclipse_type", rowNumber))
            let phaseJDValue = try double(row, "phase_jd_ut", rowNumber)
            guard let phaseJD = JulianDay(phaseJDValue) else {
                throw P22CanonicalAssemblyError.invalidValue("\(input.relativePath) row \(rowNumber) phase_jd_ut")
            }
            let greatest = try optionalDouble(row["greatest_eclipse_jd_ut"]).flatMap(JulianDay.init)
            let magnitude = try optionalDouble(row["magnitude"])
            let secondary = try optionalDouble(row["secondary_magnitude"])
            let centrality = nilIfEmpty(row["centrality"])
            guard let event = MundaneTimespineEclipseEvent(
                kind: kind,
                type: type,
                eclipseDegree: degree,
                julianDay: phaseJD,
                greatestEclipseJulianDay: greatest,
                magnitude: magnitude,
                secondaryMagnitude: secondary,
                centrality: centrality
            ) else {
                throw P22CanonicalAssemblyError.invalidValue("\(input.relativePath) row \(rowNumber)")
            }
            events.append(event)
        }
        try requireExpectedRows(input, actual: count)
        return events
    }

    private func streamCSV(
        _ input: MundaneTimespineP22CanonicalInput,
        consume: ([String], [String: String], Int) throws -> Void
    ) throws -> Int {
        let url = dataDirectory.appendingPathComponent(input.relativePath)
        let reader = try GzipCSVLineReader(url: url)
        guard let headerLine = try reader.readLine() else {
            throw P22CanonicalAssemblyError.malformedCSV("empty \(input.relativePath)")
        }
        let header = csvFields(headerLine)
        guard !header.isEmpty else {
            throw P22CanonicalAssemblyError.malformedCSV("missing header \(input.relativePath)")
        }

        var count = 0
        while let line = try reader.readLine() {
            if line.isEmpty { continue }
            let fields = csvFields(line)
            guard fields.count == header.count else {
                throw P22CanonicalAssemblyError.malformedCSV(
                    "\(input.relativePath) row \(count + 2) has \(fields.count) fields; expected \(header.count)"
                )
            }
            var row: [String: String] = [:]
            row.reserveCapacity(header.count)
            for index in header.indices { row[header[index]] = fields[index] }
            count += 1
            try consume(header, row, count + 1)
        }
        try reader.finish()
        return count
    }

    private func requireExpectedRows(
        _ input: MundaneTimespineP22CanonicalInput,
        actual: Int
    ) throws {
        if let expected = input.expectedRows, expected != actual {
            throw P22CanonicalAssemblyError.rowCount(
                input.relativePath,
                expected: expected,
                actual: actual
            )
        }
    }

    private func bodyInput(_ body: MundaneBody) throws -> MundaneTimespineP22CanonicalInput {
        guard let input = MundaneTimespineP22CanonicalInputs.bodyInputs.first(where: {
            $0.relativePath == "body-tables/\(body.constructionBodyFileName)"
        }) else {
            throw P22CanonicalAssemblyError.missingInput(body.constructionBodyFileName)
        }
        return input
    }

    private func requiredInput(
        _ family: MundaneTimespineP22CanonicalInput.Family
    ) -> MundaneTimespineP22CanonicalInput {
        MundaneTimespineP22CanonicalInputs.all.first { $0.family == family }!
    }

    private func sha256(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            let chunk = try handle.read(upToCount: 1_048_576) ?? Data()
            if chunk.isEmpty { break }
            hasher.update(data: chunk)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private func csvFields(_ line: String) -> [String] {
        line.trimmingCharacters(in: CharacterSet(charactersIn: "\r"))
            .split(separator: ",", omittingEmptySubsequences: false)
            .map(String.init)
    }

    private func required(
        _ row: [String: String],
        _ key: String,
        _ rowNumber: Int
    ) throws -> String {
        guard let value = row[key], !value.isEmpty else {
            throw P22CanonicalAssemblyError.malformedCSV("row \(rowNumber) missing \(key)")
        }
        return value
    }

    private func int(_ row: [String: String], _ key: String, _ rowNumber: Int) throws -> Int {
        guard let value = Int(try required(row, key, rowNumber)) else {
            throw P22CanonicalAssemblyError.invalidValue("row \(rowNumber) \(key)")
        }
        return value
    }

    private func int64(_ row: [String: String], _ key: String, _ rowNumber: Int) throws -> Int64 {
        guard let value = Int64(try required(row, key, rowNumber)) else {
            throw P22CanonicalAssemblyError.invalidValue("row \(rowNumber) \(key)")
        }
        return value
    }

    private func int64Any(
        _ row: [String: String],
        _ keys: [String],
        _ rowNumber: Int
    ) throws -> Int64 {
        for key in keys {
            if let text = row[key], !text.isEmpty, let value = Int64(text) { return value }
        }
        throw P22CanonicalAssemblyError.invalidValue("row \(rowNumber) one of \(keys.joined(separator: "/"))")
    }

    private func double(_ row: [String: String], _ key: String, _ rowNumber: Int) throws -> Double {
        guard let value = Double(try required(row, key, rowNumber)), value.isFinite else {
            throw P22CanonicalAssemblyError.invalidValue("row \(rowNumber) \(key)")
        }
        return value
    }

    private func doubleAny(
        _ row: [String: String],
        _ keys: [String],
        _ rowNumber: Int
    ) throws -> Double {
        for key in keys {
            if let text = row[key], !text.isEmpty, let value = Double(text), value.isFinite { return value }
        }
        throw P22CanonicalAssemblyError.invalidValue("row \(rowNumber) one of \(keys.joined(separator: "/"))")
    }

    private func optionalDouble(_ text: String?) throws -> Double? {
        guard let text, !text.isEmpty else { return nil }
        guard let value = Double(text), value.isFinite else {
            throw P22CanonicalAssemblyError.invalidValue(text)
        }
        return value
    }

    private func decimalRoundedP22Offset(
        julianDayText: String,
        rowNumber: Int
    ) throws -> Int64 {
        guard let julianDay = Decimal(
            string: julianDayText,
            locale: Self.decimalLocale
        ) else {
            throw P22CanonicalAssemblyError.invalidValue(
                "row \(rowNumber) civicTimeJulianDayUT decimal"
            )
        }
        var seconds = (julianDay - Self.p22StartJulianDayDecimal) * Decimal(86_400)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &seconds, 0, .plain)
        let text = NSDecimalNumber(decimal: rounded).stringValue
        guard let offset = Int64(text) else {
            throw P22CanonicalAssemblyError.invalidValue(
                "row \(rowNumber) civicTimeOffsetSeconds decimal overflow"
            )
        }
        return offset
    }

    private func nilIfEmpty(_ text: String?) -> String? {
        guard let text, !text.isEmpty else { return nil }
        return text
    }

    private func body(named name: String) throws -> MundaneBody {
        if name == "NorthNode" || name == "True North Node" || name == "trueNorthNode" {
            return .trueNorthNode
        }
        if let body = MundaneBody.canonicalOrder.first(where: {
            $0.displayName == name || $0.constructionDataName == name
        }) {
            return body
        }
        throw P22CanonicalAssemblyError.invalidValue("unknown body \(name)")
    }

    private func sequenceDirection(_ value: String) throws -> MundaneCelestialSequenceDirection {
        switch value {
        case "increasing": return .increasing
        case "decreasing": return .decreasing
        default: throw P22CanonicalAssemblyError.invalidValue("sequence direction \(value)")
        }
    }

    private func relationshipOrientation(
        _ value: String
    ) throws -> MundaneTimespineRelationshipOrientation {
        if value == "same_degree" || value == "sameDegree" { return .sameDegree }
        if value == "opposite_degree" || value == "oppositeDegree" { return .oppositeDegree }
        if value.hasPrefix("bodyA_ahead") || value == "bodyAAhead" { return .bodyAAhead }
        if value.hasPrefix("bodyB_ahead") || value == "bodyBAhead" { return .bodyBAhead }
        throw P22CanonicalAssemblyError.invalidValue("relationship orientation \(value)")
    }

    private func eclipseKind(_ value: String) throws -> MundaneTimespineEclipseKind {
        switch value.lowercased() {
        case "solar": return .solar
        case "lunar": return .lunar
        default: throw P22CanonicalAssemblyError.invalidValue("eclipse kind \(value)")
        }
    }

    private func eclipseType(_ value: String) throws -> MundaneTimespineEclipseType {
        switch value.lowercased() {
        case "total": return .total
        case "annular": return .annular
        case "hybrid": return .hybrid
        case "partial": return .partial
        case "penumbral": return .penumbral
        default: throw P22CanonicalAssemblyError.invalidValue("eclipse type \(value)")
        }
    }

    private func microdegrees(_ degrees: Double) -> UInt32 {
        var normalized = degrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        let raw = UInt64((normalized * 1_000_000).rounded()) % 360_000_000
        return UInt32(raw)
    }
}

private final class GzipCSVLineReader {
    private let process = Process()
    private let outputPipe = Pipe()
    private let errorPipe = Pipe()
    private let handle: FileHandle
    private var buffer = Data()
    private var reachedEOF = false
    private var finished = false

    init(url: URL) throws {
        process.executableURL = URL(fileURLWithPath: "/usr/bin/gzip")
        process.arguments = ["-dc", url.path]
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        handle = outputPipe.fileHandleForReading
        do {
            try process.run()
        } catch {
            throw P22CanonicalAssemblyError.gzip("\(url.lastPathComponent): \(error)")
        }
    }

    deinit {
        if process.isRunning { process.terminate() }
        try? handle.close()
    }

    func readLine() throws -> String? {
        while true {
            if let newline = buffer.firstIndex(of: 0x0a) {
                let lineData = buffer.subdata(in: buffer.startIndex..<newline)
                buffer.removeSubrange(buffer.startIndex...newline)
                guard let line = String(data: lineData, encoding: .utf8) else {
                    throw P22CanonicalAssemblyError.gzip("non-UTF8 CSV")
                }
                return line
            }

            if reachedEOF {
                guard !buffer.isEmpty else { return nil }
                let lineData = buffer
                buffer.removeAll(keepingCapacity: false)
                guard let line = String(data: lineData, encoding: .utf8) else {
                    throw P22CanonicalAssemblyError.gzip("non-UTF8 CSV")
                }
                return line
            }

            let chunk = try handle.read(upToCount: 65_536) ?? Data()
            if chunk.isEmpty {
                reachedEOF = true
            } else {
                buffer.append(chunk)
            }
        }
    }

    func finish() throws {
        guard !finished else { return }
        process.waitUntilExit()
        finished = true
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: errorData, encoding: .utf8) ?? "gzip exit \(process.terminationStatus)"
            throw P22CanonicalAssemblyError.gzip(message.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}
