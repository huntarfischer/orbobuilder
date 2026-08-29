import XCTest
@testable import OrboCore

final class ApolloArtemisPassBTests: XCTestCase {
    func testApolloMayAskHoraeForSuppliedMomentWithoutChangingHerTruth() throws {
        let horae = try XCTUnwrap(makeHorae())
        let target = try XCTUnwrap(JulianDay(2_500_000.25))
        let expected = try horae.seek(to: target)

        let received = try Apollo.askHorae(at: target, using: horae)

        XCTAssertEqual(received, expected)
        XCTAssertEqual(received.julianDay, target)
    }

    func testApolloPreservesHoraeFailureWithoutInventingAnotherMoment() throws {
        let horae = try XCTUnwrap(makeHorae())
        let outside = try XCTUnwrap(JulianDay(2_500_001.0))

        XCTAssertThrowsError(try Apollo.askHorae(at: outside, using: horae)) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
    }

    func testArtemisMayAskHecateAndReceivesHerExactInquiry() throws {
        let fortuneID = try XCTUnwrap(KleisID(rawValue: "Fortune"))
        let expected = try XCTUnwrap(Hecate.inquire(fortuneID))

        let received = try XCTUnwrap(Artemis.askHecate(fortuneID))

        XCTAssertEqual(received, expected)
    }

    func testArtemisDoesNotInventUnknownHecateTruth() throws {
        let unknown = try XCTUnwrap(KleisID(rawValue: "parts.unknown"))

        XCTAssertNil(Artemis.askHecate(unknown))
    }

    func testPassATwinIdentityRemainsExactAfterNeighborSeamsExist() {
        let onAstrolabe = Apollo.placeOnAstrolabe(identity: "subject-x")

        XCTAssertEqual(Apollo.presentToArtemis(onAstrolabe), onAstrolabe)
    }

    private func makeHorae() throws -> Horae? {
        let start = try XCTUnwrap(JulianDay(2_500_000.0))
        let midpoint = try XCTUnwrap(JulianDay(2_500_000.5))
        let end = try XCTUnwrap(JulianDay(2_500_001.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let firstPhysical = Double(index) * 20.0
            let secondPhysical = firstPhysical + OrboSpineContract.supportDegrees(for: body) * 0.5

            supports.append(
                coordinate(body, physicalDegrees: firstPhysical, at: start)
            )
            supports.append(
                coordinate(body, physicalDegrees: secondPhysical, at: midpoint)
            )
        }

        let terra = [
            try XCTUnwrap(
                TerraMarrowSample(
                    turnDegrees: 100.0,
                    tiltDegrees: 23.4,
                    julianDay: start
                )
            ),
            try XCTUnwrap(
                TerraMarrowSample(
                    turnDegrees: 110.0,
                    tiltDegrees: 23.5,
                    julianDay: end
                )
            ),
        ]

        let locate = try XCTUnwrap(
            OrboSpineLocate(
                bone: bone,
                celestialSupports: supports,
                terraSamples: terra
            )
        )
        return Horae(locate: locate)
    }

    private func coordinate(
        _ body: MundaneBody,
        physicalDegrees: Double,
        at julianDay: JulianDay
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: .direct
            )!,
            julianDay: julianDay
        )
    }
}
