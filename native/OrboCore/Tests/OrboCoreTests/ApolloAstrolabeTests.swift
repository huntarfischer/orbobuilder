import XCTest
@testable import OrboCore

final class ApolloAstrolabeTests: XCTestCase {
    func testTabulaDestinationsPreservePrototypeOrder() {
        XCTAssertEqual(ApolloTabulaDestination.allCases.map(\.title), [
            "Natal", "Here · Now", "Planets", "Moon", "Image", "Aspects",
            "Ledger", "Timing", "Almanac", "Gears", "Archive", "Composite",
        ])
        XCTAssertEqual(ApolloTabulaDestination.allCases.map(\.glyph), [
            "♈︎", "♉︎", "♊︎", "♋︎", "♌︎", "♍︎", "♎︎", "♏︎", "♐︎", "♑︎", "♒︎", "♓︎",
        ])
    }

    func testPrototypeGeometryIsOneSharedBody() {
        let geometry = ApolloAstrolabeGeometry.prototype
        XCTAssertEqual(geometry.rimRadius, 0.5)
        XCTAssertGreaterThan(geometry.rimRadius, geometry.destinationInnerRadius)
        XCTAssertGreaterThan(geometry.destinationInnerRadius, geometry.inscriptionInnerRadius)
        XCTAssertGreaterThan(geometry.inscriptionInnerRadius, geometry.socketRadius)
        XCTAssertGreaterThan(geometry.thicknessRatio, 0)
    }

    func testMaterialRecipeRemainsPresentationNeutral() {
        let stone = ApolloAstrolabeMaterial.prototypeVioletStone
        XCTAssertEqual(stone.name, "Prototype violet stone")
        XCTAssertGreaterThan(stone.accent.red, stone.face.red)
        XCTAssertGreaterThan(stone.engraving.alpha, 0)
    }

    func testPhysicalTurnExposesOnlyTheDeviceSurface() {
        XCTAssertEqual(ApolloAstrolabe.exposure(at: 0), .init(aegis: 1, edge: 0, tabula: 0))
        XCTAssertEqual(ApolloAstrolabe.exposure(at: 90).edge, 1, accuracy: 0.000_001)
        XCTAssertEqual(ApolloAstrolabe.exposure(at: 180).tabula, 1, accuracy: 0.000_001)
        XCTAssertEqual(ApolloAstrolabe.exposure(at: 270).edge, 1, accuracy: 0.000_001)
    }

    func testWorkshopRotationSettlesAtPhysicalDetents() {
        XCTAssertEqual(ApolloAstrolabe.nearestDetent(to: 17), 0)
        XCTAssertEqual(ApolloAstrolabe.nearestDetent(to: 78), 90)
        XCTAssertEqual(ApolloAstrolabe.nearestDetent(to: 194), 180)
        XCTAssertEqual(ApolloAstrolabe.nearestDetent(to: 344), 360)
    }
}
