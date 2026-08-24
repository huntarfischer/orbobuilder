import XCTest
@testable import OrboCore

final class TympanTests: XCTestCase {
    private struct ParityFixture: Decodable {
        let id: String
        let houseFrames: [[Int]]
        let signFrames: [[Int]]
        let traditionalRulers: [Planet]
        let modernCoRulers: [Planet?]
        let flipHouses: Int
    }

    private func fixture() throws -> ParityFixture {
        try FixtureLoader.decode(ParityFixture.self, named: "tympan-parity", kind: .parity)
    }

    func testPrototypeParityFixtureCoversAllTwelveImprintsBothDirections() throws {
        let fixture = try fixture()
        XCTAssertEqual(fixture.id, "tympan-prototype-parity-v1")
        XCTAssertEqual(fixture.houseFrames.count, 12)
        XCTAssertEqual(fixture.signFrames.count, 12)

        for ascIndex in 0..<12 {
            let rising = try XCTUnwrap(Sign(rawValue: ascIndex))
            XCTAssertEqual(fixture.houseFrames[ascIndex].count, 12)
            XCTAssertEqual(fixture.signFrames[ascIndex].count, 12)

            for signIndex in 0..<12 {
                let sign = try XCTUnwrap(Sign(rawValue: signIndex))
                XCTAssertEqual(
                    Tympan.house(of: sign, rising: rising).rawValue,
                    fixture.houseFrames[ascIndex][signIndex]
                )
            }

            for houseOrdinal in 1...12 {
                let house = try XCTUnwrap(House(rawValue: houseOrdinal))
                XCTAssertEqual(
                    Tympan.sign(of: house, rising: rising).rawValue,
                    fixture.signFrames[ascIndex][houseOrdinal - 1]
                )
            }
        }
    }

    func testCanonicalImprintsExposeAllTwelveRisingSignsInOrder() {
        XCTAssertEqual(Tympan.imprints.count, 12)
        XCTAssertEqual(Tympan.imprints.map(\.risingSign), Sign.canonicalOrder)
    }

    func testEveryImprintAnchorsItsRisingSignInHouseOneAndRoundTripsAll144Cells() {
        var checked = 0

        for rising in Sign.canonicalOrder {
            XCTAssertEqual(Tympan.house(of: rising, rising: rising), .first)

            var seen = Set<House>()
            for sign in Sign.canonicalOrder {
                let house = Tympan.house(of: sign, rising: rising)
                seen.insert(house)
                XCTAssertEqual(Tympan.sign(of: house, rising: rising), sign)
                checked += 1
            }
            XCTAssertEqual(seen, Set(House.canonicalOrder))
        }

        XCTAssertEqual(checked, 144)
    }

    func testHouseOfLongitudeReadsOnlyTheTwoResolvedSigns() throws {
        let body = try XCTUnwrap(CelestialLongitude(215.4))
        let ascendant = try XCTUnwrap(CelestialLongitude(187.2))
        XCTAssertEqual(body.sign, .scorpio)
        XCTAssertEqual(ascendant.sign, .libra)
        XCTAssertEqual(Tympan.house(of: body, ascendant: ascendant), .second)

        let zero = try XCTUnwrap(CelestialLongitude(0))
        XCTAssertEqual(Tympan.house(of: zero, ascendant: zero), .first)
    }

    func testEveryHouseRulerComesFromCanonicalMater() throws {
        let fixture = try fixture()
        XCTAssertEqual(fixture.traditionalRulers.count, 12)

        for sign in Sign.canonicalOrder {
            XCTAssertEqual(Mater.domicileRuler(of: sign), fixture.traditionalRulers[sign.rawValue])
        }

        var checked = 0
        for rising in Sign.canonicalOrder {
            for house in House.canonicalOrder {
                let sign = Tympan.sign(of: house, rising: rising)
                XCTAssertEqual(
                    Tympan.ruler(of: house, rising: rising),
                    Mater.domicileRuler(of: sign)
                )
                checked += 1
            }
        }
        XCTAssertEqual(checked, 144)
    }

    func testAll84TraditionalReverseGovernanceReadsMatchTheForwardDie() {
        var checked = 0

        for rising in Sign.canonicalOrder {
            var total = 0

            for governor in Tympan.TraditionalGovernor.allCases {
                let expected = Sign.canonicalOrder
                    .filter { Mater.domicileRuler(of: $0) == governor.planet }
                    .map { Tympan.house(of: $0, rising: rising) }
                    .sorted { $0.rawValue < $1.rawValue }

                let actual = Tympan.housesRuled(by: governor, rising: rising)
                XCTAssertEqual(actual, expected)
                total += actual.count
                checked += 1
            }

            XCTAssertEqual(total, 12)
        }

        XCTAssertEqual(checked, 84)
    }

    func testTraditionalGovernorCountsStayOneForLightsTwoForTheOtherFive() {
        for rising in Sign.canonicalOrder {
            XCTAssertEqual(Tympan.housesRuled(by: .sun, rising: rising).count, 1)
            XCTAssertEqual(Tympan.housesRuled(by: .moon, rising: rising).count, 1)

            for governor in [
                Tympan.TraditionalGovernor.mercury,
                .venus,
                .mars,
                .jupiter,
                .saturn,
            ] {
                XCTAssertEqual(Tympan.housesRuled(by: governor, rising: rising).count, 2)
            }
        }

        XCTAssertEqual(Tympan.housesRuled(by: .mars, rising: .scorpio), [.first, .sixth])
        XCTAssertEqual(Tympan.housesRuled(by: .mercury, rising: .scorpio), [.eighth, .eleventh])
    }

    func testModernCoRulershipIsSeparateAndExact() throws {
        let fixture = try fixture()
        XCTAssertEqual(fixture.modernCoRulers.count, 12)

        for sign in Sign.canonicalOrder {
            XCTAssertEqual(Tympan.coRuler(of: sign), fixture.modernCoRulers[sign.rawValue])
        }

        for rising in Sign.canonicalOrder {
            XCTAssertEqual(Tympan.housesCoRuled(by: .pluto, rising: rising).count, 1)
            XCTAssertEqual(Tympan.housesCoRuled(by: .uranus, rising: rising).count, 1)
            XCTAssertEqual(Tympan.housesCoRuled(by: .neptune, rising: rising).count, 1)

            for traditional in Planet.classicalSeven {
                XCTAssertEqual(Tympan.housesCoRuled(by: traditional, rising: rising), [])
            }
        }

        XCTAssertEqual(Tympan.housesCoRuled(by: .pluto, rising: .scorpio), [.first])
        XCTAssertEqual(Tympan.housesCoRuled(by: .uranus, rising: .scorpio), [.fourth])
        XCTAssertEqual(Tympan.housesCoRuled(by: .neptune, rising: .scorpio), [.fifth])

        XCTAssertNil(Tympan.TraditionalGovernor(planet: .pluto))
        XCTAssertNil(Tympan.TraditionalGovernor(planet: .uranus))
        XCTAssertNil(Tympan.TraditionalGovernor(planet: .neptune))
    }

    func testImprintRecordCarriesTheStampedForwardAndReverseReads() {
        for rising in Sign.canonicalOrder {
            let imprint = Tympan.imprint(for: rising)
            XCTAssertEqual(imprint.risingSign, rising)
            XCTAssertEqual(imprint.houses.count, 12)

            for (index, record) in imprint.houses.enumerated() {
                XCTAssertEqual(record.house.rawValue, index + 1)
                XCTAssertEqual(record.sign, Tympan.sign(of: record.house, rising: rising))
                XCTAssertEqual(record.ruler, Tympan.ruler(of: record.house, rising: rising))
                XCTAssertEqual(record.coRuler, Tympan.coRuler(of: record.house, rising: rising))
            }

            for governor in Tympan.TraditionalGovernor.allCases {
                XCTAssertEqual(
                    imprint.housesRuled(by: governor),
                    Tympan.housesRuled(by: governor, rising: rising)
                )
            }
            for planet in Planet.canonicalOrder {
                XCTAssertEqual(
                    imprint.housesCoRuled(by: planet),
                    Tympan.housesCoRuled(by: planet, rising: rising)
                )
            }
        }
    }

    func testFlipLawMovesExactlySixHousesAndIsAnInvolution() throws {
        let fixture = try fixture()
        XCTAssertEqual(Tympan.flipHouses, fixture.flipHouses)
        XCTAssertEqual(Tympan.flipHouses, 6)

        for house in House.canonicalOrder {
            let flipped = Tympan.opposite(of: house)
            let distance = abs(flipped.rawValue - house.rawValue)
            XCTAssertEqual(min(distance, 12 - distance), 6)
            XCTAssertEqual(Tympan.opposite(of: flipped), house)
        }

        XCTAssertEqual(Tympan.opposite(of: .first), .seventh)
        XCTAssertEqual(Tympan.opposite(of: .eighth), .second)
    }

    func testNativeTypesClosePrototypeMalformedAddressPathsBeforeTympanReads() {
        XCTAssertNil(Sign(rawValue: -1))
        XCTAssertNil(Sign(rawValue: 12))
        XCTAssertNil(Sign(rawValue: 37))

        XCTAssertNil(House(rawValue: 0))
        XCTAssertNil(House(rawValue: 13))

        XCTAssertNil(Tympan.TraditionalGovernor(planet: .uranus))
        XCTAssertNil(Tympan.TraditionalGovernor(planet: .neptune))
        XCTAssertNil(Tympan.TraditionalGovernor(planet: .pluto))

        XCTAssertNotNil(Tympan.TraditionalGovernor(planet: .mars))
        XCTAssertNotNil(Tympan.TraditionalGovernor(planet: .saturn))
    }
}
