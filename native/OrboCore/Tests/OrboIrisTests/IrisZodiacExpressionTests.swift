import XCTest
import OrboCore
@testable import OrboIris

final class IrisZodiacExpressionTests: XCTestCase {
    func testCanonicalRimUsesAllTwelveOrboSignsWithoutChangingTheirDegrees() {
        let sectors = IrisZodiacRimSector.canonical

        XCTAssertEqual(sectors.count, 12)
        XCTAssertEqual(sectors.map(\.sign), Sign.canonicalOrder)
        XCTAssertEqual(sectors.first?.startDegrees, 0.0)
        XCTAssertEqual(sectors.first?.endDegrees, 30.0)
        XCTAssertEqual(sectors.last?.startDegrees, 330.0)
        XCTAssertEqual(sectors.last?.endDegrees, 360.0)

        for pair in zip(sectors, sectors.dropFirst()) {
            XCTAssertEqual(pair.0.endDegrees, pair.1.startDegrees)
        }
    }

    func testElementFamiliesKeepThreeRelatedSignShades() {
        XCTAssertEqual(
            Sign.canonicalOrder.map { IrisZodiacAppearance(sign: $0).family },
            [.fire, .earth, .air, .water, .fire, .earth,
             .air, .water, .fire, .earth, .air, .water]
        )

        XCTAssertEqual(IrisZodiacAppearance(sign: .aries).shade, .light)
        XCTAssertEqual(IrisZodiacAppearance(sign: .leo).shade, .middle)
        XCTAssertEqual(IrisZodiacAppearance(sign: .sagittarius).shade, .deep)

        XCTAssertEqual(IrisZodiacAppearance(sign: .taurus).shade, .light)
        XCTAssertEqual(IrisZodiacAppearance(sign: .virgo).shade, .middle)
        XCTAssertEqual(IrisZodiacAppearance(sign: .capricorn).shade, .deep)
    }

    func testMercuryChangesFromLightFireToLightEarthAtThirtyDegrees() throws {
        let ariesSource = coordinate(.mercury, 29.999, .direct)
        let taurusSource = coordinate(.mercury, 30.0, .direct)

        let aries = IrisZodiacPlacement(source: ariesSource)
        let taurus = IrisZodiacPlacement(source: taurusSource)

        XCTAssertEqual(aries.source, ariesSource)
        XCTAssertEqual(taurus.source, taurusSource)

        XCTAssertEqual(aries.longitude, CelestialLongitude(29.999))
        XCTAssertEqual(aries.sign, .aries)
        XCTAssertEqual(aries.appearance.family, .fire)
        XCTAssertEqual(aries.appearance.shade, .light)

        XCTAssertEqual(taurus.longitude, CelestialLongitude(30.0))
        XCTAssertEqual(taurus.sign, .taurus)
        XCTAssertEqual(taurus.degreeInSign.value, 0.0, accuracy: 1e-10)
        XCTAssertEqual(taurus.appearance.family, .earth)
        XCTAssertEqual(taurus.appearance.shade, .light)
    }

    func testPlacementReadoutUsesCanonicalSignDegreeAndMotion() {
        let source = coordinate(.mercury, 29.5, .retrograde)
        let placement = IrisZodiacPlacement(source: source)

        XCTAssertEqual(placement.source, source)
        XCTAssertEqual(placement.displayText, "Mercury 29°30′ Aries ℞")
    }

    private func coordinate(
        _ body: MundaneBody,
        _ physicalDegrees: Double,
        _ motion: Motion
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: motion
            )!,
            julianDay: JulianDay(2_461_000.5)!
        )
    }
}
