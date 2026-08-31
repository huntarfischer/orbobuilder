import XCTest
@testable import OrboCore

final class NatalSpineActIBeat3ClothoBoundsTests: XCTestCase {
    func testClothoBuildsFiniteLifeDomainAroundNatal() throws {
        let hestia = try NatalSpineTestFixture.litHestia()
        let truth = try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)

        XCTAssertEqual(bounds.subjectID, truth.subjectID)
        XCTAssertEqual(bounds.natal, truth.tempus.absoluteInstant)
        XCTAssertLessThan(bounds.start.unixSecondsSince1970, bounds.natal.unixSecondsSince1970)
        XCTAssertLessThan(bounds.natal.unixSecondsSince1970, bounds.end.unixSecondsSince1970)
    }

    func testBoundsUseExactGregorianAnniversaries() throws {
        let hestia = try NatalSpineTestFixture.litHestia()
        let truth = try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)

        XCTAssertEqual(bounds.start, try anniversary(year: 1989))
        XCTAssertEqual(bounds.end, try anniversary(year: 2090))
    }

    func testBoundsProjectToHalfOpenBoneAndRejectOutsideInstants() throws {
        let hestia = try NatalSpineTestFixture.litHestia()
        let truth = try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)
        let before = AbsoluteInstant(unixSecondsSince1970: bounds.start.unixSecondsSince1970 - 1)!
        let inside = AbsoluteInstant(unixSecondsSince1970: bounds.end.unixSecondsSince1970 - 1)!

        XCTAssertEqual(bounds.bone.start, bounds.start.julianDay)
        XCTAssertEqual(bounds.bone.end, bounds.end.julianDay)
        XCTAssertFalse(bounds.contains(before))
        XCTAssertTrue(bounds.contains(bounds.start))
        XCTAssertTrue(bounds.contains(bounds.natal))
        XCTAssertTrue(bounds.contains(inside))
        XCTAssertFalse(bounds.contains(bounds.end))
    }

    func testSameTruthProducesSameBounds() throws {
        let hestia = try NatalSpineTestFixture.litHestia()
        let truth = try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        XCTAssertEqual(try Clotho.boundNatalSpine(truth), try Clotho.boundNatalSpine(truth))
    }

    private func anniversary(year: Int) throws -> AbsoluteInstant {
        let date = CivilDate(year: year, month: 5, day: 17)!
        let zone = TimezoneIdentifier(rawValue: "America/Chicago")!
        let result = CivilTime.resolve(date: date, time: NatalSpineTestFixture.birthTime, in: zone)
        guard case let .resolved(match) = result else {
            throw TestError.unresolved
        }
        return match.instant
    }

    private enum TestError: Error {
        case unresolved
    }
}
