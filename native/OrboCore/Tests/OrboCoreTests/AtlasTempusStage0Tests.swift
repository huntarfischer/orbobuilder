import XCTest
@testable import OrboCore

final class AtlasTempusStage0Tests: XCTestCase {
    func testTempusHoldsAbsoluteInstantAndProvenance() {
        let instant = AbsoluteInstant(unixSecondsSince1970: 0)!
        let provenance = TempusProvenance(
            source: .timeZoneDatabase,
            timeZoneDataVersion: "stage-0"
        )
        let tempus = Tempus(
            absoluteInstant: instant,
            provenance: provenance
        )

        XCTAssertEqual(tempus.absoluteInstant, instant)
        XCTAssertEqual(tempus.provenance, provenance)
    }

    func testNewEngravingBeginsWithoutTempus() {
        XCTAssertNil(makeEngraving().tempus)
    }

    func testResolvingTempusPreservesEveryOtherEngravingField() throws {
        let unresolved = makeEngraving()
        let before = try found(Atlas().resolve(unresolved))
        let tempus = Tempus(
            absoluteInstant: AbsoluteInstant(unixSecondsSince1970: 0)!,
            provenance: TempusProvenance(
                source: .timeZoneDatabase,
                timeZoneDataVersion: "stage-0"
            )
        )

        let after = before.resolving(tempus: tempus)

        XCTAssertEqual(after.tempus, tempus)
        XCTAssertEqual(after.subjectID, before.subjectID)
        XCTAssertEqual(after.name, before.name)
        XCTAssertEqual(after.birthDate, before.birthDate)
        XCTAssertEqual(after.birthTime, before.birthTime)
        XCTAssertEqual(after.birthLocation, before.birthLocation)
        XCTAssertEqual(after.topos, before.topos)
        XCTAssertEqual(after.astroDNA, before.astroDNA)
        XCTAssertEqual(after.tapestry, before.tapestry)
        XCTAssertEqual(after.engraved, before.engraved)
    }

    private func makeEngraving() -> Engraving {
        Engraving(
            subjectID: HermesSubjectID(rawValue: "atlas-tempus-stage-0")!,
            name: "Stage Zero",
            birthDate: CivilDate(year: 1985, month: 4, day: 10)!,
            birthTime: CivilClockTime(hour: 20, minute: 16)!,
            birthLocation: "Madison, WI"
        )
    }

    private func found(
        _ resolution: EngravingToposResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Engraving {
        guard case let .found(engraving) = resolution else {
            XCTFail("Expected found resolution, got \(resolution)", file: file, line: line)
            throw TestError.unexpectedResolution
        }
        return engraving
    }

    private enum TestError: Error {
        case unexpectedResolution
    }
}
