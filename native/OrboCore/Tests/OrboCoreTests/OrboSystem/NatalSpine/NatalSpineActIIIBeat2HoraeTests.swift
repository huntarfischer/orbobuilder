import XCTest
@testable import OrboCore

final class NatalSpineActIIIBeat2HoraeTests: XCTestCase {
    func testStartIsReachableWithoutChangingSpineMatter() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let before = spine
        let position = try Horae.locateNatalSpine(
            spine,
            at: spine.bounds.start.julianDay
        )

        XCTAssertEqual(position.julianDay, spine.bounds.start.julianDay)
        XCTAssertEqual(position.addresses.count, MundaneBody.canonicalOrder.count)
        XCTAssertEqual(position.addresses.map(\.coordinate.body), MundaneBody.canonicalOrder)
        XCTAssertEqual(spine, before)
    }

    func testNatalInstantIsReachable() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let position = try Horae.locateNatalSpine(
            spine,
            at: spine.bounds.natal.julianDay
        )

        XCTAssertEqual(position.julianDay, spine.bounds.natal.julianDay)
        XCTAssertEqual(position.addresses.count, MundaneBody.canonicalOrder.count)
    }

    func testEndIsExclusiveAndLastInteriorInstantIsLawful() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let lastInterior = JulianDay(
            spine.bounds.end.julianDay.value - (1.0 / 86_400.0)
        )!

        XCTAssertNoThrow(try Horae.locateNatalSpine(spine, at: lastInterior))
        XCTAssertThrowsError(
            try Horae.locateNatalSpine(spine, at: spine.bounds.end.julianDay)
        ) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
    }

    func testArbitraryInteriorUTNavigationUsesForgedAddresses() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let interior = JulianDay(spine.bounds.bone.start.value + 5)!
        let position = try Horae.locateNatalSpine(spine, at: interior)

        for address in position.addresses {
            let direct = try spine.candidate.address(
                of: address.coordinate.body,
                at: interior
            )
            XCTAssertEqual(address, direct)
        }
    }

    func testCelestialTimeNavigationReturnsTheSameUnderlyingOccurrence() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let interior = JulianDay(spine.bounds.bone.start.value + 1)!
        let address = try spine.candidate.address(of: .sun, at: interior)
        let occurrences = try Horae.locateNatalSpine(
            spine,
            body: .sun,
            at: address.coordinate.directionalDegree
        )

        XCTAssertTrue(
            occurrences.contains { occurrence in
                abs(occurrence.coordinate.julianDay.value - interior.value) <= 1e-9
                    && occurrence.coordinate.directionalDegree == address.coordinate.directionalDegree
            }
        )
    }

    func testFiniteBoundsAreEnforcedOnBothSides() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let beforeStart = JulianDay(spine.bounds.bone.start.value - 1)!
        let afterEnd = JulianDay(spine.bounds.bone.end.value + 1)!

        XCTAssertThrowsError(try Horae.locateNatalSpine(spine, at: beforeStart)) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
        XCTAssertThrowsError(try Horae.locateNatalSpine(spine, at: afterEnd)) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
    }

    func testTraversalCanBeginFromHermesDeliveredSealedSpine() throws {
        var state = try NatalSpineActIIIFixture.inHermesCustodyAfterHephaestus()
        let address = try state.courier.deliverNext(
            ticketID: state.ticketID,
            occurredAt: NatalSpineActIIIFixture.instant(1_920_000_300)
        )
        let spine = try Horae.receiveNatalSpine(state.package, deliveredTo: address)
        let position = try Horae.locateNatalSpine(
            spine,
            at: spine.bounds.natal.julianDay
        )

        XCTAssertEqual(position.addresses.count, MundaneBody.canonicalOrder.count)
    }
}
