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
        XCTAssertEqual(geometry.rimRadius, 0.493)
        XCTAssertEqual(geometry.destinationInnerRadius, 0.385)
        XCTAssertEqual(geometry.inscriptionInnerRadius, 0.332)
        XCTAssertEqual(geometry.socketInnerRadius, 0.264)
        XCTAssertEqual(geometry.socketOuterRadius, 0.329)
        XCTAssertEqual(geometry.zodiacGlyphRadius, 0.4375)
        XCTAssertGreaterThan(geometry.rimRadius, geometry.destinationInnerRadius)
        XCTAssertGreaterThan(geometry.destinationInnerRadius, geometry.inscriptionInnerRadius)
        XCTAssertGreaterThan(geometry.inscriptionInnerRadius, geometry.socketOuterRadius)
        XCTAssertGreaterThan(geometry.socketOuterRadius, geometry.socketInnerRadius)
        XCTAssertGreaterThan(geometry.thicknessRatio, 0)
    }

    func testGeminiTabulaPreservesPrototypeSocketAndChipLaws() {
        var tabula = ApolloTabula()
        XCTAssertNil(tabula.destination)
        tabula.select(.planets)
        XCTAssertEqual(tabula.destination, .planets)
        XCTAssertEqual(tabula.bodyMode, .planets)
        XCTAssertEqual(tabula.bodyChips.map(\.name), [
            "Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter",
            "Saturn", "Uranus", "Neptune", "Pluto",
        ])
        XCTAssertEqual(tabula.bodyChips.first { $0.name == "Mars" }?.angleDegrees, 195)
        XCTAssertEqual(tabula.bodyChips.first { $0.name == "Saturn" }?.angleDegrees, 465)

        tabula.select(.objects)
        XCTAssertEqual(tabula.bodyChips.map(\.name), ["Chiron", "Ceres", "Pallas", "Juno", "Vesta"])
        XCTAssertEqual(tabula.bodyChips.map(\.angleDegrees), [180, 252, 324, 396, 468])

        tabula.select(.points)
        XCTAssertEqual(tabula.bodyChips.map(\.name), ["Nodes", "Lilith", "Vertex"])
        XCTAssertEqual(tabula.bodyChips.map(\.enabled), [true, false, false])
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
