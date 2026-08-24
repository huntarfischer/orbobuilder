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

    func testEveryHouseSignRulerComesFromCanonicalMater() throws {
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
                    Tympan.signRuler(of: house, rising: rising),
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

                let actual = Tympan.housesGoverned(by: governor, rising: rising)
                XCTAssertEqual(actual, expected)
                total += actual.count
                checked += 1
            }

            XCTAssertEqual(total, 12)
        }

        XCTAssertEqual(checked, 84)
    }

    func testTraditionalGovernanceLatticeIsCanonicalAndCompleteAcrossAllTwelveImprints() {
        for rising in Sign.canonicalOrder {
            let imprint = Tympan.imprint(for: rising)
            let lattice = imprint.traditionalGovernanceLattice

            XCTAssertEqual(lattice.count, 7)
            XCTAssertEqual(lattice.map(\.governor), Tympan.TraditionalGovernor.allCases)

            let governedHouses = lattice.flatMap(\.houses)
            XCTAssertEqual(governedHouses.count, 12)
            XCTAssertEqual(Set(governedHouses), Set(House.canonicalOrder))
            XCTAssertEqual(lattice.filter { $0.houses.count == 2 }.count, 5)
            XCTAssertEqual(lattice.filter { $0.houses.count == 1 }.count, 2)

            for group in lattice {
                XCTAssertEqual(
                    group.houses,
                    Tympan.housesGoverned(by: group.governor, rising: rising)
                )
            }
        }
    }

    func testScorpioImprintTraditionalGovernanceLatticeMatchesCanon() {
        let groups = Dictionary(
            uniqueKeysWithValues: Tympan.imprint(for: .scorpio)
                .traditionalGovernanceLattice
                .map { ($0.governor, $0.houses) }
        )

        XCTAssertEqual(groups[.mars] ?? [], [.first, .sixth])
        XCTAssertEqual(groups[.jupiter] ?? [], [.second, .fifth])
        XCTAssertEqual(groups[.saturn] ?? [], [.third, .fourth])
        XCTAssertEqual(groups[.venus] ?? [], [.seventh, .twelfth])
        XCTAssertEqual(groups[.mercury] ?? [], [.eighth, .eleventh])
        XCTAssertEqual(groups[.moon] ?? [], [.ninth])
        XCTAssertEqual(groups[.sun] ?? [], [.tenth])
    }

    func testTraditionalGovernorCountsStayOneForLightsTwoForTheOtherFive() {
        for rising in Sign.canonicalOrder {
            XCTAssertEqual(Tympan.housesGoverned(by: .sun, rising: rising).count, 1)
            XCTAssertEqual(Tympan.housesGoverned(by: .moon, rising: rising).count, 1)

            for governor in [
                Tympan.TraditionalGovernor.mercury,
                .venus,
                .mars,
                .jupiter,
                .saturn,
            ] {
                XCTAssertEqual(Tympan.housesGoverned(by: governor, rising: rising).count, 2)
            }
        }

        XCTAssertEqual(Tympan.housesGoverned(by: .mars, rising: .scorpio), [.first, .sixth])
        XCTAssertEqual(Tympan.housesGoverned(by: .mercury, rising: .scorpio), [.eighth, .eleventh])
    }

    func testModernGovernanceAugmentationIsCanonicalAndSeparateAcrossAllTwelveImprints() throws {
        let fixture = try fixture()
        XCTAssertEqual(fixture.modernCoRulers.count, 12)

        for sign in Sign.canonicalOrder {
            XCTAssertEqual(Tympan.modernRuler(of: sign), fixture.modernCoRulers[sign.rawValue])
        }

        for rising in Sign.canonicalOrder {
            let imprint = Tympan.imprint(for: rising)
            XCTAssertEqual(imprint.modernGovernance.count, 3)
            XCTAssertEqual(imprint.modernGovernance.map(\.governor), [.pluto, .uranus, .neptune])
            XCTAssertEqual(Set(imprint.modernGovernance.map(\.house)).count, 3)

            for relationship in imprint.modernGovernance {
                XCTAssertEqual(Tympan.sign(of: relationship.house, rising: rising), relationship.sign)
                XCTAssertEqual(
                    Tympan.modernGovernor(of: relationship.house, rising: rising),
                    relationship.governor
                )
                XCTAssertEqual(
                    imprint.housesModernlyGoverned(by: relationship.governor),
                    [relationship.house]
                )
                XCTAssertNil(Tympan.TraditionalGovernor(planet: relationship.governor))
            }

            for traditional in Planet.classicalSeven {
                XCTAssertEqual(imprint.housesModernlyGoverned(by: traditional), [])
            }
        }
    }

    func testScorpioImprintModernGovernanceMatchesCanon() {
        let imprint = Tympan.imprint(for: .scorpio)
        let governed = Dictionary(
            uniqueKeysWithValues: imprint.modernGovernance.map { ($0.governor, $0.house) }
        )

        XCTAssertEqual(governed[.pluto], .first)
        XCTAssertEqual(governed[.uranus], .fourth)
        XCTAssertEqual(governed[.neptune], .fifth)

        XCTAssertEqual(Tympan.modernGovernor(of: .first, rising: .scorpio), .pluto)
        XCTAssertEqual(Tympan.modernGovernor(of: .fourth, rising: .scorpio), .uranus)
        XCTAssertEqual(Tympan.modernGovernor(of: .fifth, rising: .scorpio), .neptune)
        XCTAssertNil(Tympan.modernGovernor(of: .seventh, rising: .scorpio))
    }

    func testCompleteHouseGovernanceReadsAgreeAcrossAll144Cells() {
        var checked = 0

        for rising in Sign.canonicalOrder {
            let imprint = Tympan.imprint(for: rising)
            XCTAssertEqual(imprint.houseGovernance.count, 12)
            XCTAssertEqual(imprint.houseGovernance.map(\.house), House.canonicalOrder)

            for house in House.canonicalOrder {
                let governance = Tympan.governance(of: house, rising: rising)
                XCTAssertEqual(governance, imprint.governance(of: house))
                XCTAssertEqual(governance.house, house)
                XCTAssertEqual(governance.sign, Tympan.sign(of: house, rising: rising))
                XCTAssertEqual(governance.traditionalGovernor.planet, Tympan.signRuler(of: house, rising: rising))
                XCTAssertEqual(
                    governance.traditionalGovernor,
                    Tympan.traditionalGovernor(of: house, rising: rising)
                )
                XCTAssertEqual(
                    governance.traditionalGovernedHouses,
                    Tympan.housesGoverned(by: governance.traditionalGovernor, rising: rising)
                )
                XCTAssertEqual(governance.modernGovernor, Tympan.modernRuler(of: governance.sign))
                checked += 1
            }
        }

        XCTAssertEqual(checked, 144)
    }

    func testScorpioHouseGovernanceReadsMatchCanon() {
        let first = Tympan.governance(of: .first, rising: .scorpio)
        XCTAssertEqual(first.sign, .scorpio)
        XCTAssertEqual(first.traditionalGovernor, .mars)
        XCTAssertEqual(first.traditionalGovernedHouses, [.first, .sixth])
        XCTAssertEqual(first.modernGovernor, .pluto)

        let fourth = Tympan.governance(of: .fourth, rising: .scorpio)
        XCTAssertEqual(fourth.sign, .aquarius)
        XCTAssertEqual(fourth.traditionalGovernor, .saturn)
        XCTAssertEqual(fourth.traditionalGovernedHouses, [.third, .fourth])
        XCTAssertEqual(fourth.modernGovernor, .uranus)

        let fifth = Tympan.governance(of: .fifth, rising: .scorpio)
        XCTAssertEqual(fifth.sign, .pisces)
        XCTAssertEqual(fifth.traditionalGovernor, .jupiter)
        XCTAssertEqual(fifth.traditionalGovernedHouses, [.second, .fifth])
        XCTAssertEqual(fifth.modernGovernor, .neptune)

        let seventh = Tympan.governance(of: .seventh, rising: .scorpio)
        XCTAssertEqual(seventh.sign, .taurus)
        XCTAssertEqual(seventh.traditionalGovernor, .venus)
        XCTAssertEqual(seventh.traditionalGovernedHouses, [.seventh, .twelfth])
        XCTAssertNil(seventh.modernGovernor)
    }

    func testImprintRecordCarriesTheStampedForwardAndReverseReads() {
        for rising in Sign.canonicalOrder {
            let imprint = Tympan.imprint(for: rising)
            XCTAssertEqual(imprint.risingSign, rising)
            XCTAssertEqual(imprint.houses.count, 12)

            for (index, record) in imprint.houses.enumerated() {
                XCTAssertEqual(record.house.rawValue, index + 1)
                XCTAssertEqual(record.sign, Tympan.sign(of: record.house, rising: rising))
                XCTAssertEqual(record.signRuler, Tympan.signRuler(of: record.house, rising: rising))
                XCTAssertEqual(
                    record.modernGovernor,
                    Tympan.modernGovernor(of: record.house, rising: rising)
                )
            }

            for governor in Tympan.TraditionalGovernor.allCases {
                XCTAssertEqual(
                    imprint.housesGoverned(by: governor),
                    Tympan.housesGoverned(by: governor, rising: rising)
                )
            }
            for planet in Planet.canonicalOrder {
                XCTAssertEqual(
                    imprint.housesModernlyGoverned(by: planet),
                    Tympan.housesModernlyGoverned(by: planet, rising: rising)
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
