import XCTest
@testable import OrboCore

final class ArcTests: XCTestCase {
    func testExactAddressSpacesAreIntegerBacked() {
        XCTAssertEqual(Arc.degrees, 360)
        XCTAssertEqual(Arc.arcsecondsPerDegree, 3_600)
        XCTAssertEqual(Arc.inputStates, 1_296_000)
        XCTAssertEqual(Arc.halfCircleArcseconds, 648_000)
        XCTAssertEqual(Arc.quarterCircleArcseconds, 324_000)
        XCTAssertEqual(Arc.outputTicks, 2_592_000)
        XCTAssertEqual(Arc.quarterCircleTicks, 648_000)

        XCTAssertNil(ArcCoordinate(-1))
        XCTAssertNil(ArcCoordinate(Arc.inputStates))
        XCTAssertNotNil(ArcCoordinate(Arc.inputStates - 1))
        XCTAssertNil(ArcPosition(-1))
        XCTAssertNil(ArcPosition(Arc.outputTicks))
        XCTAssertNotNil(ArcPosition(Arc.outputTicks - 1))

        XCTAssertNil(ArcCoordinate(degree: 360))
        XCTAssertNil(ArcCoordinate(degree: 0, minute: 60))
        XCTAssertNil(ArcCoordinate(degree: 0, second: 60))
    }

    func testCastCreatesTheCompletePlusMinusNinetyDegreeField() throws {
        let anchor = try XCTUnwrap(ArcCoordinate(degree: 277, minute: 34, second: 17))
        let field = Arc.cast(anchor)

        XCTAssertEqual(field.center.rawValue, anchor.arcsecond * 2)
        XCTAssertEqual(field.center.degree, 277)
        XCTAssertEqual(field.center.minute, 34)
        XCTAssertEqual(field.center.second, 17)
        XCTAssertEqual(field.center.halfSecond, 0)

        XCTAssertEqual(field.plusPole.rawValue, Arc.normalizedOutputTick(field.center.rawValue + Arc.quarterCircleTicks))
        XCTAssertEqual(field.minusPole.rawValue, Arc.normalizedOutputTick(field.center.rawValue - Arc.quarterCircleTicks))
        XCTAssertTrue(field.contains(field.center))
        XCTAssertTrue(field.contains(field.plusPole))
        XCTAssertTrue(field.contains(field.minusPole))

        let justBeyondPlus = try XCTUnwrap(ArcPosition(Arc.normalizedOutputTick(field.plusPole.rawValue + 1)))
        let justBeyondMinus = try XCTUnwrap(ArcPosition(Arc.normalizedOutputTick(field.minusPole.rawValue - 1)))
        XCTAssertFalse(field.contains(justBeyondPlus))
        XCTAssertFalse(field.contains(justBeyondMinus))

        let oppositeCenter = try XCTUnwrap(
            ArcPosition(Arc.normalizedOutputTick(field.center.rawValue + Arc.inputStates))
        )
        XCTAssertFalse(field.contains(oppositeCenter))
    }

    func testComposePreservesConjunctionAndHalfLifeInBothDirections() throws {
        let zero = try XCTUnwrap(ArcCoordinate(degree: 0))

        XCTAssertEqual(
            Arc.compose(zero, zero),
            .position(try XCTUnwrap(ArcPosition(0)))
        )

        let sixty = try XCTUnwrap(ArcCoordinate(degree: 60))
        let oneTwenty = try XCTUnwrap(ArcCoordinate(degree: 120))
        let threeHundred = try XCTUnwrap(ArcCoordinate(degree: 300))
        let twoForty = try XCTUnwrap(ArcCoordinate(degree: 240))

        XCTAssertEqual(
            Arc.compose(zero, sixty),
            .position(try XCTUnwrap(ArcPosition(30 * Arc.arcsecondsPerDegree * 2)))
        )
        XCTAssertEqual(
            Arc.compose(zero, oneTwenty),
            .position(try XCTUnwrap(ArcPosition(60 * Arc.arcsecondsPerDegree * 2)))
        )
        XCTAssertEqual(
            Arc.compose(zero, threeHundred),
            .position(try XCTUnwrap(ArcPosition(330 * Arc.arcsecondsPerDegree * 2)))
        )
        XCTAssertEqual(
            Arc.compose(zero, twoForty),
            .position(try XCTUnwrap(ArcPosition(300 * Arc.arcsecondsPerDegree * 2)))
        )
    }

    func testOddArcsecondDisplacementProducesExactHalfArcsecond() throws {
        let anchor = try XCTUnwrap(ArcCoordinate(0))
        let partner = try XCTUnwrap(ArcCoordinate(1))

        guard case let .position(position) = Arc.compose(anchor, partner) else {
            return XCTFail("One-arcsecond displacement must not be a Seam.")
        }

        XCTAssertEqual(position.rawValue, 1)
        XCTAssertFalse(position.isWholeArcsecond)
        XCTAssertNil(position.wholeArcsecond)
        XCTAssertEqual(position.degree, 0)
        XCTAssertEqual(position.minute, 0)
        XCTAssertEqual(position.second, 0)
        XCTAssertEqual(position.halfSecond, 1)
    }

    func testExactOppositionIsTheTwoPoleSeam() throws {
        let zero = try XCTUnwrap(ArcCoordinate(degree: 0))
        let opposition = try XCTUnwrap(ArcCoordinate(degree: 180))

        guard case let .seam(seam) = Arc.compose(zero, opposition) else {
            return XCTFail("Exact opposition must return the Seam.")
        }

        XCTAssertEqual(seam.plusPole.degree, 90)
        XCTAssertEqual(seam.minusPole.degree, 270)
        XCTAssertEqual(seam.plusPole.minute, 0)
        XCTAssertEqual(seam.minusPole.minute, 0)
        XCTAssertEqual(seam.plusPole.second, 0)
        XCTAssertEqual(seam.minusPole.second, 0)
        XCTAssertEqual(seam.plusPole.halfSecond, 0)
        XCTAssertEqual(seam.minusPole.halfSecond, 0)

        guard case let .seam(reverse) = Arc.compose(opposition, zero) else {
            return XCTFail("Opposition must remain a Seam when input order reverses.")
        }

        XCTAssertEqual(Set([seam.minusPole, seam.plusPole]), Set([reverse.minusPole, reverse.plusPole]))
    }

    func testCompositionIsRotationallySymmetric() throws {
        let anchor = try XCTUnwrap(ArcCoordinate(degree: 17, minute: 11, second: 5))
        let partner = try XCTUnwrap(ArcCoordinate(degree: 116, minute: 42, second: 12))
        let rotation = 73 * Arc.arcsecondsPerDegree + 19 * 60 + 23

        let rotatedAnchor = try XCTUnwrap(ArcCoordinate(Arc.normalizedInputArcsecond(anchor.arcsecond + rotation)))
        let rotatedPartner = try XCTUnwrap(ArcCoordinate(Arc.normalizedInputArcsecond(partner.arcsecond + rotation)))

        guard case let .position(original) = Arc.compose(anchor, partner),
              case let .position(rotated) = Arc.compose(rotatedAnchor, rotatedPartner)
        else {
            return XCTFail("Fixture must remain away from the Seam.")
        }

        XCTAssertEqual(
            rotated.rawValue,
            Arc.normalizedOutputTick(original.rawValue + rotation * 2)
        )
    }

    func testComposeIsSymmetricAwayFromTheSeam() throws {
        let a = try XCTUnwrap(ArcCoordinate(degree: 350, minute: 10, second: 3))
        let b = try XCTUnwrap(ArcCoordinate(degree: 12, minute: 40, second: 44))

        XCTAssertEqual(Arc.compose(a, b), Arc.compose(b, a))
    }

    func testCastContainsEveryPossibleCompositionAcrossTheWholeInputCircle() throws {
        let anchor = try XCTUnwrap(ArcCoordinate(degree: 277, minute: 34, second: 17))
        let field = Arc.cast(anchor)
        var ordinaryCount = 0
        var seamCount = 0

        for rawPartner in 0..<Arc.inputStates {
            let partner = ArcCoordinate(rawPartner)!
            switch Arc.compose(anchor, partner) {
            case let .position(position):
                ordinaryCount += 1
                XCTAssertTrue(field.contains(position))
            case let .seam(seam):
                seamCount += 1
                XCTAssertEqual(Set([seam.minusPole, seam.plusPole]), Set([field.minusPole, field.plusPole]))
                XCTAssertTrue(field.contains(seam.minusPole))
                XCTAssertTrue(field.contains(seam.plusPole))
            }
        }

        XCTAssertEqual(ordinaryCount, Arc.inputStates - 1)
        XCTAssertEqual(seamCount, 1)
    }

    func testArcCoreHasNoNatalOrTemporalPrerequisite() throws {
        let arbitraryCoordinate = try XCTUnwrap(ArcCoordinate(degree: 211, minute: 5, second: 9))
        let anotherCoordinate = try XCTUnwrap(ArcCoordinate(degree: 19, minute: 48, second: 31))

        XCTAssertEqual(Arc.cast(arbitraryCoordinate).anchor, arbitraryCoordinate)
        XCTAssertNotNil(Arc.compose(arbitraryCoordinate, anotherCoordinate))
    }
}
