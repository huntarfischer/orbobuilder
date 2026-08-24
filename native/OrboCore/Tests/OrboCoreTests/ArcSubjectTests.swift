import XCTest
@testable import OrboCore

final class ArcSubjectTests: XCTestCase {
    func testGenericSubjectsPreserveIdentityAndProvenanceWithoutChangingGeometry() throws {
        let coordinate = try XCTUnwrap(ArcCoordinate(degree: 27, minute: 14, second: 9))
        let expected = Arc.cast(coordinate)

        let subjects = [
            ArcSubject(identity: "venus", provenance: "planet-shaped", coordinate: coordinate),
            ArcSubject(identity: "asc", provenance: "angle-shaped", coordinate: coordinate),
            ArcSubject(identity: "fortune", provenance: "lot-shaped", coordinate: coordinate),
            ArcSubject(identity: "square-moon-target", provenance: "ring-target-shaped", coordinate: coordinate),
        ]

        let casts = Arc.cast(subjects)

        XCTAssertEqual(casts.count, subjects.count)
        XCTAssertEqual(casts.map(\.subject), subjects)
        XCTAssertTrue(casts.allSatisfy { $0.field == expected })
    }

    func testSingleSubjectCastMatchesRawCoordinateCastExactly() throws {
        let coordinate = try XCTUnwrap(ArcCoordinate(degree: 311, minute: 59, second: 59))
        let subject = ArcSubject(
            identity: "arbitrary-coordinate-bearing-fact",
            provenance: "future-pass",
            coordinate: coordinate
        )

        let result = Arc.cast(subject)

        XCTAssertEqual(result.subject, subject)
        XCTAssertEqual(result.field, Arc.cast(coordinate))
        XCTAssertEqual(result.field.anchor, coordinate)
    }

    func testSubjectCompositionMatchesRawCoordinateCompositionExactly() throws {
        let firstCoordinate = try XCTUnwrap(ArcCoordinate(degree: 350, minute: 10, second: 3))
        let secondCoordinate = try XCTUnwrap(ArcCoordinate(degree: 12, minute: 40, second: 44))

        let first = ArcSubject(
            identity: "first",
            provenance: "planet-shaped",
            coordinate: firstCoordinate
        )
        let second = ArcSubject(
            identity: "second",
            provenance: "ring-target-shaped",
            coordinate: secondCoordinate
        )

        let result = Arc.compose(first, second)

        XCTAssertEqual(result.first, first)
        XCTAssertEqual(result.second, second)
        XCTAssertEqual(result.composite, Arc.compose(firstCoordinate, secondCoordinate))
    }

    func testSubjectCompositionPreservesTheSeamWithoutSemanticBranching() throws {
        let zero = try XCTUnwrap(ArcCoordinate(degree: 0))
        let opposition = try XCTUnwrap(ArcCoordinate(degree: 180))

        let first = ArcSubject(identity: "lot", provenance: "lot-shaped", coordinate: zero)
        let second = ArcSubject(identity: "angle", provenance: "angle-shaped", coordinate: opposition)

        let result = Arc.compose(first, second)

        guard case let .seam(seam) = result.composite else {
            return XCTFail("Generic subject composition must preserve Arc's exact Seam law.")
        }

        XCTAssertEqual(Set([seam.minusPole.degree, seam.plusPole.degree]), Set([90, 270]))
        XCTAssertEqual(result.first.identity, "lot")
        XCTAssertEqual(result.second.identity, "angle")
    }

    func testDifferentProvenanceNeverChangesTheProjectedArcGrid() throws {
        let coordinate = try XCTUnwrap(ArcCoordinate(degree: 277, minute: 34, second: 17))
        let subjects = [
            ArcSubject(identity: "p", provenance: "planet-shaped", coordinate: coordinate),
            ArcSubject(identity: "a", provenance: "angle-shaped", coordinate: coordinate),
            ArcSubject(identity: "l", provenance: "lot-shaped", coordinate: coordinate),
            ArcSubject(identity: "r", provenance: "ring-target-shaped", coordinate: coordinate),
        ]

        let casts = Arc.cast(subjects)
        let expectedGrid = Arc.project(coordinate)

        for cast in casts {
            XCTAssertEqual(Arc.project(cast.field), expectedGrid)
        }
    }
}
