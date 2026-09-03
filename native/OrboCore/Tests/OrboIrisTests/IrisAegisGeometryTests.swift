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

    func testClosestMoonWinsOverLaterPaintedUranusAndNatalDoesNotScrub() {
        let moon = AstrolabePlacement(gene: .moon, longitude: CelestialLongitude(65)!, motion: .direct, house: nil, condition: nil)
        let uranus = AstrolabePlacement(gene: .uranus, longitude: CelestialLongitude(69)!, motion: .direct, house: nil, condition: nil)
        let geometry = IrisAegisGeometry(diameter: 400, horizon: 12)
        let sky = [moon, uranus]
        let offsets = IrisAegisGeometry.trackOffsets(sky)
        let touch = geometry.point(longitude: moon.longitude.degrees, radius: 150 - (offsets[.moon] ?? 0))
        XCTAssertEqual(geometry.placement(at: touch, sky: sky, natal: [])?.gene, .moon)
        let reversedOffsets = IrisAegisGeometry.trackOffsets(Array(sky.reversed()))
        let reversedTouch = geometry.point(longitude: moon.longitude.degrees, radius: 150 - (reversedOffsets[.moon] ?? 0))
        XCTAssertEqual(geometry.placement(at: reversedTouch, sky: Array(sky.reversed()), natal: [])?.gene, .moon)
        let natalTouch = geometry.point(longitude: 65, radius: 120)
        XCTAssertEqual(geometry.placement(at: natalTouch, sky: sky, natal: [moon])?.kind, .natal)
        XCTAssertNil(geometry.placement(at: .zero, sky: sky, natal: []))
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
