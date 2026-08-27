import XCTest
@testable import OrboCore

final class ChronosStage5Tests: XCTestCase {
    func testNativeExpressionReturnsTheExactResolvedAnswer() throws {
        let answer = stationAnswer([2_451_545, 2_451_546])
        let request = try XCTUnwrap(ChronosExpressionRequest(format: .native))

        guard case let .native(expressed) = Chronos.express(answer, as: request) else {
            return XCTFail("Expected native Chronos expression")
        }

        XCTAssertEqual(expressed, answer)
        XCTAssertEqual(
            Mirror(reflecting: request).children.compactMap(\.label),
            ["format", "projection", "timezone"]
        )
    }

    func testProjectionExposesOnlyRequestedRelevantFactualFields() throws {
        let answer = stationAnswer([2_451_545])
        let projection = try XCTUnwrap(ChronosProjection(
            fields: [.fact, .body, .directionalState]
        ))
        let request = try XCTUnwrap(ChronosExpressionRequest(
            format: .csv,
            projection: projection
        ))

        guard case let .csv(csv) = Chronos.express(answer, as: request) else {
            return XCTFail("Expected CSV expression")
        }

        let lines = csv.components(separatedBy: "\n")
        XCTAssertEqual(lines.first, "fact,body")
        XCTAssertEqual(lines.count, 2)
        XCTAssertTrue(lines[1].contains("Mercury station"))
        XCTAssertTrue(lines[1].contains("Mercury"))
        XCTAssertFalse(csv.contains("directional_state"))
        XCTAssertFalse(csv.contains("start_ut"))
    }

    func testOptionalCivicRenderingKeepsExactJulianDayIdentity() throws {
        let answer = stationAnswer([2_451_545])
        let timezone = try XCTUnwrap(TimezoneIdentifier("America/Chicago"))
        let projection = try XCTUnwrap(ChronosProjection(fields: [.startUT, .fact]))
        let request = try XCTUnwrap(ChronosExpressionRequest(
            format: .txt,
            projection: projection,
            timezone: timezone
        ))

        guard case let .text(text) = Chronos.express(answer, as: request) else {
            return XCTFail("Expected TXT expression")
        }

        XCTAssertTrue(text.contains("JD 2451545.0"))
        XCTAssertTrue(text.contains("2000-01-01T06:00:00.000-06:00"))
        XCTAssertTrue(text.contains("Mercury station"))
    }

    func testTXTAndCSVAreOrderedExpressionsOfTheSameHits() throws {
        let answer = stationAnswer([2_451_545, 2_451_546])
        let projection = try XCTUnwrap(ChronosProjection(
            fields: [.startUT, .fact, .source]
        ))
        let txtRequest = try XCTUnwrap(ChronosExpressionRequest(
            format: .txt,
            projection: projection
        ))
        let csvRequest = try XCTUnwrap(ChronosExpressionRequest(
            format: .csv,
            projection: projection
        ))

        guard case let .text(text) = Chronos.express(answer, as: txtRequest),
              case let .csv(csv) = Chronos.express(answer, as: csvRequest) else {
            return XCTFail("Expected TXT and CSV expressions")
        }

        XCTAssertTrue(text.contains("hits=2"))
        XCTAssertLessThan(
            try XCTUnwrap(text.range(of: "JD 2451545.0")?.lowerBound),
            try XCTUnwrap(text.range(of: "JD 2451546.0")?.lowerBound)
        )
        let csvLines = csv.components(separatedBy: "\n")
        XCTAssertEqual(csvLines.count, 3)
        XCTAssertTrue(csvLines[1].contains("JD 2451545.0"))
        XCTAssertTrue(csvLines[2].contains("JD 2451546.0"))
    }

    func testPDFIsAPrintableFactualExpressionOfTheAnswer() throws {
        let answer = stationAnswer([2_451_545])
        let request = try XCTUnwrap(ChronosExpressionRequest(format: .pdf))

        guard case let .pdf(data) = Chronos.express(answer, as: request),
              let text = String(data: data, encoding: .utf8) else {
            return XCTFail("Expected textual PDF data")
        }

        XCTAssertTrue(text.hasPrefix("%PDF-1.4"))
        XCTAssertTrue(text.contains("Chronos chronology"))
        XCTAssertTrue(text.contains("Mercury station"))
        XCTAssertTrue(text.contains("JD 2451545.0"))
        XCTAssertTrue(text.contains("xref"))
        XCTAssertTrue(text.contains("%%EOF"))
    }

    func testICalendarPreservesMomentAndIntervalTemporalIdentityWithoutHiddenNow() throws {
        let shell = try XCTUnwrap(OrboSpineShellID(family: .wave, ordinal: 12))
        let interval = try XCTUnwrap(ChronosInterval(
            start: try jd(2_451_546),
            endExclusive: try jd(2_451_556)
        ))
        let answer = ChronosAnswer(hits: [
            ChronosHit(
                address: .moment(try jd(2_451_545)),
                fact: .station(body: .mercury),
                source: ChronosSourceReference(rawValue: "library:stations")
            ),
            ChronosHit(
                address: .interval(interval),
                fact: .shell(shell),
                source: ChronosSourceReference(rawValue: "library:wave")
            ),
        ])
        let request = try XCTUnwrap(ChronosExpressionRequest(format: .iCalendar))

        guard case let .iCalendar(calendar) = Chronos.express(answer, as: request) else {
            return XCTFail("Expected iCalendar expression")
        }

        XCTAssertTrue(calendar.contains("BEGIN:VCALENDAR\r\n"))
        XCTAssertEqual(calendar.components(separatedBy: "BEGIN:VEVENT").count - 1, 2)
        XCTAssertTrue(calendar.contains("DTSTART:20000101T120000Z"))
        XCTAssertTrue(calendar.contains("DTEND:20000112T120000Z"))
        XCTAssertTrue(calendar.contains("SUMMARY:Mercury station"))
        XCTAssertTrue(calendar.contains("SUMMARY:Wave W12"))
        XCTAssertTrue(calendar.contains("X-ORBO-JULIAN-DAY:2451545.0"))
        XCTAssertTrue(calendar.contains("X-ORBO-END-JULIAN-DAY:2451556.0"))
        XCTAssertTrue(calendar.contains("DTSTAMP:20000101T120000Z"))
    }

    func testEmptyAnswerRemainsLawfulAcrossExpressionFormats() throws {
        let answer = ChronosAnswer(hits: [])
        let txt = try expression(answer, format: .txt)
        let csv = try expression(answer, format: .csv)
        let calendar = try expression(answer, format: .iCalendar)

        guard case let .text(text) = txt,
              case let .csv(csvText) = csv,
              case let .iCalendar(ics) = calendar else {
            return XCTFail("Expected empty TXT, CSV, and iCalendar expressions")
        }

        XCTAssertTrue(text.contains("hits=0"))
        XCTAssertEqual(csvText.components(separatedBy: "\n").count, 1)
        XCTAssertFalse(ics.contains("BEGIN:VEVENT"))
        XCTAssertTrue(ics.contains("END:VCALENDAR"))
    }

    func testExpressionsIntroduceNoInterpretiveVocabulary() throws {
        let answer = stationAnswer([2_451_545])
        var corpus = ""
        for format in [
            ChronosExpressionFormat.txt,
            .csv,
            .pdf,
            .iCalendar,
        ] {
            switch try expression(answer, format: format) {
            case let .text(value), let .csv(value), let .iCalendar(value):
                corpus += value
            case let .pdf(data):
                corpus += String(data: data, encoding: .utf8) ?? ""
            case .native:
                break
            }
        }

        let lower = corpus.lowercased()
        for forbidden in [
            "important",
            "powerful",
            "favorable",
            "meaning",
            "prediction",
            "recommendation",
        ] {
            XCTAssertFalse(lower.contains(forbidden), "Found forbidden semantic field: \(forbidden)")
        }
    }

    private func stationAnswer(_ values: [Double]) -> ChronosAnswer {
        ChronosAnswer(hits: values.map { value in
            ChronosHit(
                address: .moment(JulianDay(value)!),
                fact: .station(body: .mercury),
                source: ChronosSourceReference(rawValue: "library:stations")
            )
        })
    }

    private func expression(
        _ answer: ChronosAnswer,
        format: ChronosExpressionFormat
    ) throws -> ChronosExpression {
        let request = try XCTUnwrap(ChronosExpressionRequest(format: format))
        return Chronos.express(answer, as: request)
    }

    private func jd(_ value: Double) throws -> JulianDay {
        try XCTUnwrap(JulianDay(value))
    }
}
