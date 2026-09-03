import XCTest
@testable import OrboCore
@testable import OrboIris

final class IrisAegisGeometryTests: XCTestCase {
    func testGraduationsStayFixedWhenTheHorizonChanges() {
        let first = IrisAegisGeometry(diameter: 400, horizon: 12)
        let later = IrisAegisGeometry(diameter: 400, horizon: 29)
        for degree in stride(from: 0.0, to: 360.0, by: 10) {
            XCTAssertEqual(first.graduation(degree: degree, radius: 190), later.graduation(degree: degree, radius: 190))
        }
        XCTAssertNotEqual(first.point(longitude: 15, radius: 180), later.point(longitude: 15, radius: 180))
    }

    func testReteStaggerKeepsSourcePositionsIncludingAcrossZodiacSeam() {
        let placements = [
            AstrolabePlacement(gene: .mercury, longitude: CelestialLongitude(359)!, motion: .retrograde, house: nil, condition: nil),
            AstrolabePlacement(gene: .venus, longitude: CelestialLongitude(1)!, motion: .direct, house: nil, condition: nil),
            AstrolabePlacement(gene: .mars, longitude: CelestialLongitude(40)!, motion: .direct, house: nil, condition: nil)
        ]
        let offsets = IrisAegisGeometry.trackOffsets(placements)
        XCTAssertNotEqual(offsets[.mercury], offsets[.venus])
        XCTAssertEqual(offsets[.mars], 0)
        XCTAssertEqual(placements.map(\.longitude.degrees), [359, 1, 40])
    }

    func testPrototypeArtworkDecodesFromTheIrisBundle() {
        XCTAssertNotNil(IrisAstrolabeArtwork.logo)
        XCTAssertNotNil(IrisAstrolabeArtwork.companion)
    }

    func testHorizonRendersAtLeftAndOppositionAtRight() {
        let geometry = IrisAegisGeometry(diameter: 400, horizon: 221.5)
        let asc = geometry.point(longitude: 221.5, radius: 180)
        let descendant = geometry.point(longitude: 41.5, radius: 180)
        XCTAssertEqual(asc.x, 20, accuracy: 1e-9)
        XCTAssertEqual(asc.y, 200, accuracy: 1e-9)
        XCTAssertEqual(descendant.x, 380, accuracy: 1e-9)
        XCTAssertEqual(descendant.y, 200, accuracy: 1e-9)
    }

    func testZodiacalOrientationAndDisplayFormattingPreserveSourcePrecision() {
        let geometry = IrisAegisGeometry(diameter: 400, horizon: nil)
        let cancer = geometry.point(longitude: 90, radius: 180)
        XCTAssertEqual(cancer.x, 200, accuracy: 1e-9)
        XCTAssertEqual(cancer.y, 380, accuracy: 1e-9)
        let position = CelestialLongitude(21 + 9.0 / 60 + 42.0 / 3600)!
        XCTAssertEqual(IrisAstrolabeStyle.position(position), "21°9′")
        XCTAssertEqual(position.degrees, 21 + 9.0 / 60 + 42.0 / 3600)
    }
}
