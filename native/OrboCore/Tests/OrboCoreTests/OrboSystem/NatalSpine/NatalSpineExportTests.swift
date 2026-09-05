import Foundation
import XCTest
@testable import OrboCore

final class NatalSpineExportTests: XCTestCase {
    func testRangesAreExplicitClampedAndCalendarYearBased() throws {
        let (_, runtime) = try mountedFixture()
        let anchor = runtime.bounds.natal.julianDay
        let oneYear = try Chronos.resolvedNatalRange(
            .nextYears(1, anchor: anchor),
            within: runtime.bounds
        )
        let days = oneYear.endExclusive.value - oneYear.start.value
        XCTAssertTrue(days == 365 || days == 366)

        let beyondEnd = ChronosInterval(
            start: runtime.bounds.natal.julianDay,
            endExclusive: JulianDay(runtime.bounds.bone.end.value + 500)!
        )!
        let clamped = try Chronos.resolvedNatalRange(
            .custom(beyondEnd),
            within: runtime.bounds
        )
        XCTAssertEqual(clamped.endExclusive, runtime.bounds.bone.end)

        XCTAssertThrowsError(
            try Chronos.resolvedNatalRange(
                .nextYears(1, anchor: runtime.bounds.bone.end),
                within: runtime.bounds
            )
        )
    }

    func testExportIncludesExactEventsNotHouseOccupancySpans() throws {
        let (_, runtime) = try mountedFixture()
        let index = Chronos.indexNatalSpine(runtime)
        let answer = try Chronos.natalSpineExportAnswer(
            using: index,
            range: .entireSpine
        )

        XCTAssertFalse(answer.hits.isEmpty)
        XCTAssertTrue(answer.hits.allSatisfy { $0.address.endExclusive == nil })
        XCTAssertTrue(answer.hits.allSatisfy {
            switch $0.fact {
            case .natalRingRealization, .natalHouseCrossing: return true
            default: return false
            }
        })
        XCTAssertFalse(answer.hits.contains {
            if case .natalHousePassage = $0.fact { return true }
            return false
        })
    }

    func testCSVTXTAndICSShareTheSameRangedFacts() throws {
        let (_, runtime) = try mountedFixture()
        let index = Chronos.indexNatalSpine(runtime)
        let answer = try Chronos.natalSpineExportAnswer(
            using: index,
            range: .entireSpine
        )

        guard case let .csv(csv) = Chronos.express(
            answer,
            as: ChronosExpressionRequest(format: .csv)!
        ), case let .text(text) = Chronos.express(
            answer,
            as: ChronosExpressionRequest(format: .txt)!
        ), case let .iCalendar(ics) = Chronos.express(
            answer,
            as: ChronosExpressionRequest(format: .iCalendar)!
        ) else { return XCTFail("Expected all three Natal export formats") }

        XCTAssertEqual(csv.components(separatedBy: "\n").count - 1, answer.hits.count)
        XCTAssertTrue(text.contains("hits=\(answer.hits.count)"))
        XCTAssertEqual(ics.components(separatedBy: "BEGIN:VEVENT").count - 1, answer.hits.count)
        XCTAssertTrue(ics.contains("DESCRIPTION:"))
        XCTAssertTrue(ics.contains("RING\\n") || ics.contains("TYMPAN\\n"))
        XCTAssertTrue(ics.contains("MATER\\n"))
        XCTAssertTrue(ics.contains("ORBO\\n"))
        XCTAssertFalse(ics.contains("DTEND:"))
        XCTAssertTrue(ics.components(separatedBy: "\r\n").allSatisfy {
            $0.lengthOfBytes(using: .utf8) <= 75
        })
    }

    func testOverlappingExportsKeepStableUIDs() throws {
        let (_, runtime) = try mountedFixture()
        let index = Chronos.indexNatalSpine(runtime)
        let all = try Chronos.natalSpineExportAnswer(using: index, range: .entireSpine)
        let first = try XCTUnwrap(all.hits.first)
        let window = ChronosInterval(
            start: JulianDay(first.address.start.value - 1)!,
            endExclusive: JulianDay(first.address.start.value + 1)!
        )!
        let overlap = try Chronos.natalSpineExportAnswer(using: index, range: .custom(window))
        let overlappingUIDs = Set(overlap.hits.compactMap { $0.eventContext?.stableUID })
        let allUIDs = Set(all.hits.compactMap { $0.eventContext?.stableUID })

        XCTAssertFalse(overlappingUIDs.isEmpty)
        XCTAssertTrue(overlappingUIDs.isSubset(of: allUIDs))
        XCTAssertEqual(allUIDs.count, all.hits.count)
    }

    private func mountedFixture() throws -> (SealedNatalSpine, NatalSpineRuntime) {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("NatalSpineExportTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("fixture.natalspine")
        let receipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: url)
        let runtime = try NatalSpineRuntime.mount(
            from: url,
            expectedSHA256: receipt.sha256,
            expectedParentSpineIdentity: receipt.parentSpineIdentity
        )
        return (sealed, runtime)
    }
}
