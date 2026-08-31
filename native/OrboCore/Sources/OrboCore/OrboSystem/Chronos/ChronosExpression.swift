import Foundation

public enum ChronosProjectionField: String, CaseIterable, Hashable, Sendable {
    case startUT = "start_ut"
    case endUT = "end_ut"
    case fact
    case body
    case directionalState = "directional_state"
    case source
}

/// Ordered factual fields exposed by textual/tabular Chronos expressions.
/// Projection changes representation only. It never changes the ChronosAnswer.
public struct ChronosProjection: Hashable, Sendable {
    public let fields: [ChronosProjectionField]

    public init?(fields: [ChronosProjectionField]) {
        guard !fields.isEmpty else { return nil }
        var seen = Set<ChronosProjectionField>()
        self.fields = fields.filter { seen.insert($0).inserted }
    }

    public static let allFactual = ChronosProjection(
        fields: ChronosProjectionField.allCases
    )!
}

public enum ChronosExpressionFormat: String, CaseIterable, Hashable, Sendable {
    case native
    case txt
    case csv
    case pdf
    case iCalendar = "ics"
}

/// Expression is downstream of a resolved answer. It has no predicate, source authority,
/// or query capability, so an exporter cannot rediscover temporal truth.
public struct ChronosExpressionRequest: Hashable, Sendable {
    public let format: ChronosExpressionFormat
    public let projection: ChronosProjection
    public let timezone: TimezoneIdentifier?

    public init?(
        format: ChronosExpressionFormat,
        projection: ChronosProjection = .allFactual,
        timezone: TimezoneIdentifier? = nil
    ) {
        if let timezone, TimeZone(identifier: timezone.rawValue) == nil {
            return nil
        }
        self.format = format
        self.projection = projection
        self.timezone = timezone
    }
}

public enum ChronosExpression: Equatable, Sendable {
    case native(ChronosAnswer)
    case text(String)
    case csv(String)
    case pdf(Data)
    case iCalendar(String)
}

/// Stage 5 expression of already-resolved Chronos truth.
///
/// Every non-native format is rendered from the supplied immutable ChronosAnswer.
/// No expression path receives CivilTime, Horae, Library, Locate, or a ChronosQuery.
public extension Chronos {
    static func express(
        _ answer: ChronosAnswer,
        as request: ChronosExpressionRequest
    ) -> ChronosExpression {
        switch request.format {
        case .native:
            return .native(answer)

        case .txt:
            let table = projectedTable(
                answer,
                projection: request.projection,
                timezone: request.timezone
            )
            return .text(renderTXT(table))

        case .csv:
            let table = projectedTable(
                answer,
                projection: request.projection,
                timezone: request.timezone
            )
            return .csv(renderCSV(table))

        case .pdf:
            let table = projectedTable(
                answer,
                projection: request.projection,
                timezone: request.timezone
            )
            return .pdf(renderPDF(table))

        case .iCalendar:
            return .iCalendar(renderICalendar(answer, projection: request.projection))
        }
    }
}

private extension Chronos {
    struct ProjectedTable {
        let fields: [ChronosProjectionField]
        let rows: [[String]]
        let hitCount: Int
    }

    static func projectedTable(
        _ answer: ChronosAnswer,
        projection: ChronosProjection,
        timezone: TimezoneIdentifier?
    ) -> ProjectedTable {
        let relevant: Set<ChronosProjectionField>
        if answer.hits.isEmpty {
            relevant = Set(projection.fields)
        } else {
            relevant = Set(answer.hits.flatMap { relevantFields(for: $0.fact) })
        }
        let fields = projection.fields.filter { relevant.contains($0) }
        let rows = answer.hits.map { hit in
            fields.map { field in
                projectedValue(field, from: hit, timezone: timezone)
            }
        }
        return ProjectedTable(fields: fields, rows: rows, hitCount: answer.hits.count)
    }

    static func relevantFields(
        for fact: ChronosFactIdentity
    ) -> [ChronosProjectionField] {
        switch fact {
        case .civilMoment:
            return [.startUT, .fact, .source]
        case .bodyState:
            return [.startUT, .fact, .body, .directionalState, .source]
        case .station:
            return [.startUT, .fact, .body, .source]
        case .shell:
            return [.startUT, .endUT, .fact, .source]
        case .natalHousePassage:
            return [.startUT, .endUT, .fact, .body, .source]
        case .natalRingRealization, .natalHouseCrossing, .natalMaterCondition:
            return [.startUT, .fact, .body, .source]
        }
    }

    static func projectedValue(
        _ field: ChronosProjectionField,
        from hit: ChronosHit,
        timezone: TimezoneIdentifier?
    ) -> String {
        switch field {
        case .startUT:
            return temporalText(hit.address.start, timezone: timezone)
        case .endUT:
            guard let end = hit.address.endExclusive else { return "" }
            return temporalText(end, timezone: timezone)
        case .fact:
            return factualLabel(hit.fact)
        case .body:
            return body(from: hit.fact)?.displayName ?? ""
        case .directionalState:
            guard case let .bodyState(_, degree) = hit.fact else { return "" }
            return directionalStateText(degree)
        case .source:
            return hit.source?.rawValue ?? ""
        }
    }

    static func temporalText(
        _ julianDay: JulianDay,
        timezone: TimezoneIdentifier?
    ) -> String {
        let exact = "JD \(julianDay.value)"
        guard let timezone else { return exact }
        return "\(exact) [\(civilText(julianDay, timezone: timezone))]"
    }

    static func civilText(
        _ julianDay: JulianDay,
        timezone: TimezoneIdentifier
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: timezone.rawValue)!
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter.string(from: AbsoluteInstant(julianDay: julianDay)!.foundationDate)
    }

    static func body(from fact: ChronosFactIdentity) -> MundaneBody? {
        switch fact {
        case .civilMoment, .shell:
            return nil
        case let .bodyState(body, _), let .station(body):
            return body
        case let .natalHousePassage(body, _):
            return body
        case let .natalRingRealization(mundaneBody, _, _):
            return mundaneBody
        case let .natalHouseCrossing(body, _, _):
            return body
        case let .natalMaterCondition(_, body):
            return body
        }
    }

    static func factualLabel(_ fact: ChronosFactIdentity) -> String {
        switch fact {
        case let .civilMoment(date, time, timezone):
            return String(
                format: "Civil moment %04d-%02d-%02d %02d:%02d:%02d %@",
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
                time.second,
                timezone.rawValue
            )

        case let .bodyState(body, degree):
            return "\(body.displayName) state \(directionalStateText(degree))"

        case let .station(body):
            return "\(body.displayName) station"

        case let .shell(id):
            return "\(shellFamilyName(id.family)) \(id.description)"

        case let .natalHousePassage(body, house):
            return "\(body.displayName) passage through native House \(house.rawValue)"

        case let .natalRingRealization(mundaneBody, natalGene, relation):
            let body = mundaneBody?.displayName ?? "Any body"
            let target = natalGene?.displayName ?? "any natal target"
            let relation = relation.map { String(describing: $0) } ?? "any relation"
            return "\(body) \(relation) \(target)"

        case let .natalHouseCrossing(body, fromHouse, toHouse):
            let body = body?.displayName ?? "Any body"
            let from = fromHouse.map { String($0.rawValue) } ?? "any house"
            let to = toHouse.map { String($0.rawValue) } ?? "any house"
            return "\(body) native House \(from) to House \(to) crossing"

        case let .natalMaterCondition(condition, body):
            let body = body?.displayName ?? "Any body"
            return "\(body) Mater condition \(condition.rawValue)"
        }
    }

    static func directionalStateText(
        _ degree: OrboSpineDirectionalDegree
    ) -> String {
        "\(degree.physicalDegrees) deg \(degree.motion == .retrograde ? "retrograde" : "direct")"
    }

    static func shellFamilyName(_ family: OrboSpineShellFamily) -> String {
        switch family {
        case .frame: return "Frame"
        case .revolt: return "Revolt"
        case .wave: return "Wave"
        case .zeitgeist: return "Zeitgeist"
        }
    }

    static func renderTXT(_ table: ProjectedTable) -> String {
        var lines = ["Chronos chronology", "hits=\(table.hitCount)"]
        guard !table.fields.isEmpty else { return lines.joined(separator: "\n") }
        lines.append(table.fields.map(\.rawValue).joined(separator: " | "))
        lines.append(contentsOf: table.rows.map { $0.joined(separator: " | ") })
        return lines.joined(separator: "\n")
    }

    static func renderCSV(_ table: ProjectedTable) -> String {
        guard !table.fields.isEmpty else { return "" }
        let header = table.fields.map { csvEscape($0.rawValue) }.joined(separator: ",")
        let rows = table.rows.map { row in
            row.map(csvEscape).joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n")
    }

    static func csvEscape(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"") || value.contains("\n") else {
            return value
        }
        return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }

    static func renderPDF(_ table: ProjectedTable) -> Data {
        var lines = ["Chronos chronology", "hits=\(table.hitCount)"]
        if !table.fields.isEmpty {
            lines.append(table.fields.map(\.rawValue).joined(separator: " | "))
            lines.append(contentsOf: table.rows.map { $0.joined(separator: " | ") })
        }
        return makePDF(lines: lines.flatMap { wrapASCII($0, width: 92) })
    }

    static func wrapASCII(_ value: String, width: Int) -> [String] {
        let sanitized = ascii(value)
        guard sanitized.count > width else { return [sanitized] }

        var result: [String] = []
        var line = ""
        for word in sanitized.split(separator: " ", omittingEmptySubsequences: false) {
            let token = String(word)
            if line.isEmpty {
                line = token
            } else if line.count + 1 + token.count <= width {
                line += " " + token
            } else {
                result.append(line)
                line = token
            }
        }
        if !line.isEmpty { result.append(line) }
        return result.isEmpty ? [""] : result
    }

    static func ascii(_ value: String) -> String {
        String(value.unicodeScalars.map { scalar in
            (32...126).contains(Int(scalar.value)) ? Character(String(scalar)) : "?"
        })
    }

    static func makePDF(lines: [String]) -> Data {
        let pageCapacity = 48
        let pages: [[String]]
        if lines.isEmpty {
            pages = [[""]]
        } else {
            pages = stride(from: 0, to: lines.count, by: pageCapacity).map { start in
                Array(lines[start..<min(start + pageCapacity, lines.count)])
            }
        }

        let pageCount = pages.count
        let pageObjectStart = 3
        let contentObjectStart = pageObjectStart + pageCount
        let fontObject = contentObjectStart + pageCount
        let objectCount = fontObject
        var objects = Array(repeating: "", count: objectCount + 1)

        objects[1] = "<< /Type /Catalog /Pages 2 0 R >>"
        let kids = (0..<pageCount)
            .map { "\(pageObjectStart + $0) 0 R" }
            .joined(separator: " ")
        objects[2] = "<< /Type /Pages /Kids [\(kids)] /Count \(pageCount) >>"

        for index in 0..<pageCount {
            let pageObject = pageObjectStart + index
            let contentObject = contentObjectStart + index
            objects[pageObject] = "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 \(fontObject) 0 R >> >> /Contents \(contentObject) 0 R >>"

            var stream = "BT\n/F1 9 Tf\n50 750 Td\n11 TL\n"
            for line in pages[index] {
                stream += "(\(pdfEscape(ascii(line)))) Tj\nT*\n"
            }
            stream += "ET"
            let length = stream.data(using: .utf8)!.count
            objects[contentObject] = "<< /Length \(length) >>\nstream\n\(stream)\nendstream"
        }

        objects[fontObject] = "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"

        var data = Data()
        appendPDF("%PDF-1.4\n", to: &data)
        var offsets = Array(repeating: 0, count: objectCount + 1)
        for object in 1...objectCount {
            offsets[object] = data.count
            appendPDF("\(object) 0 obj\n\(objects[object])\nendobj\n", to: &data)
        }

        let xrefOffset = data.count
        appendPDF("xref\n0 \(objectCount + 1)\n", to: &data)
        appendPDF("0000000000 65535 f \n", to: &data)
        for object in 1...objectCount {
            appendPDF(String(format: "%010d 00000 n \n", offsets[object]), to: &data)
        }
        appendPDF(
            "trailer\n<< /Size \(objectCount + 1) /Root 1 0 R >>\nstartxref\n\(xrefOffset)\n%%EOF\n",
            to: &data
        )
        return data
    }

    static func appendPDF(_ string: String, to data: inout Data) {
        data.append(string.data(using: .utf8)!)
    }

    static func pdfEscape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "(", with: "\\(")
            .replacingOccurrences(of: ")", with: "\\)")
    }

    static func renderICalendar(
        _ answer: ChronosAnswer,
        projection: ChronosProjection
    ) -> String {
        var lines = [
            "BEGIN:VCALENDAR",
            "VERSION:2.0",
            "PRODID:-//Orbo//Chronos//EN",
            "CALSCALE:GREGORIAN",
            "METHOD:PUBLISH",
        ]
        let projected = Set(projection.fields)

        for (index, hit) in answer.hits.enumerated() {
            let start = hit.address.start
            let startStamp = iCalendarUTC(start)
            let uidValue = String(start.value)
                .replacingOccurrences(of: ".", with: "-")
                .replacingOccurrences(of: "+", with: "p")
                .replacingOccurrences(of: "-", with: "m")

            lines.append("BEGIN:VEVENT")
            lines.append("UID:chronos-\(index)-\(uidValue)@orbo")
            // Deterministic and free of hidden current-time state.
            lines.append("DTSTAMP:\(startStamp)")
            lines.append("DTSTART:\(startStamp)")
            if let end = hit.address.endExclusive {
                lines.append("DTEND:\(iCalendarUTC(end))")
                lines.append("X-ORBO-END-JULIAN-DAY:\(end.value)")
            }
            lines.append("SUMMARY:\(iCalendarEscape(factualLabel(hit.fact)))")
            lines.append("X-ORBO-JULIAN-DAY:\(start.value)")

            if projected.contains(.body), let body = body(from: hit.fact) {
                lines.append("X-ORBO-BODY:\(iCalendarEscape(body.displayName))")
            }
            if projected.contains(.directionalState),
               case let .bodyState(_, degree) = hit.fact {
                lines.append("X-ORBO-DIRECTIONAL-STATE:\(iCalendarEscape(directionalStateText(degree)))")
            }
            if projected.contains(.source), let source = hit.source {
                lines.append("X-ORBO-SOURCE:\(iCalendarEscape(source.rawValue))")
            }
            lines.append("END:VEVENT")
        }

        lines.append("END:VCALENDAR")
        return lines.joined(separator: "\r\n") + "\r\n"
    }

    static func iCalendarUTC(_ julianDay: JulianDay) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)!
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return formatter.string(from: AbsoluteInstant(julianDay: julianDay)!.foundationDate)
    }

    static func iCalendarEscape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}
