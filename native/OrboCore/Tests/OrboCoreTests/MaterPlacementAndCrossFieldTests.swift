import XCTest
@testable import OrboCore

final class MaterPlacementAndCrossFieldTests: XCTestCase {
    private func completePlacements(
        overriding overrides: [Planet: Sign] = [:]
    ) -> [Planet: Sign] {
        var placements: [Planet: Sign] = [
            .sun: .leo,
            .moon: .cancer,
            .mercury: .virgo,
            .venus: .libra,
            .mars: .aries,
            .jupiter: .sagittarius,
            .saturn: .capricorn,
            .uranus: .gemini,
            .neptune: .taurus,
            .pluto: .aquarius,
        ]
        for (planet, sign) in overrides {
            placements[planet] = sign
        }
        return placements
    }

    private func field(
        overriding overrides: [Planet: Sign] = [:]
    ) -> Mater.Field {
        Mater.resolveField(completePlacements(overriding: overrides))
    }

    func testPlacementConsumesLibraImprintAndRecordsTraditionalAndModernGovernorDestinations() {
        let resolvedField = field(overriding: [
            .venus: .leo,
            .pluto: .aquarius,
        ])
        let imprint = Tympan.imprint(for: .libra)
        let placement = Mater.resolvePlacement(field: resolvedField, in: imprint)

        XCTAssertEqual(placement.risingSign, .libra)
        XCTAssertEqual(placement.houses.count, 12)
        XCTAssertEqual(placement.houses.map(\.house), House.canonicalOrder)
        XCTAssertEqual(placement.byHouse.count, 12)

        let first = placement.placement(for: .first)
        XCTAssertEqual(first.sign, .libra)
        XCTAssertEqual(first.traditionalGovernor, .venus)
        XCTAssertEqual(first.traditionalGovernorHouse, .eleventh)

        let eighth = placement.placement(for: .eighth)
        XCTAssertEqual(eighth.sign, .taurus)
        XCTAssertEqual(eighth.traditionalGovernor, .venus)
        XCTAssertEqual(eighth.traditionalGovernorHouse, .eleventh)

        let second = placement.placement(for: .second)
        XCTAssertEqual(second.sign, .scorpio)
        XCTAssertEqual(second.traditionalGovernor, .mars)
        XCTAssertEqual(second.modernGovernor, .pluto)
        XCTAssertEqual(second.modernGovernorHouse, .fifth)
    }

    func testOwnHouseIsRegisteredAsAOneCycleWithUniformKeeperShape() {
        let placement = Mater.resolvePlacement(
            field: field(),
            in: Tympan.imprint(for: .aries)
        )
        let first = placement.placement(for: .first)

        XCTAssertEqual(first.traditionalGovernor, .mars)
        XCTAssertEqual(first.traditionalGovernorHouse, .first)
        XCTAssertEqual(first.routingPath, [.first])
        XCTAssertEqual(first.terminalKind, .ownHouse)
        XCTAssertEqual(first.keeper.kind, .ownHouse)
        XCTAssertEqual(first.keeper.id, "1")
        XCTAssertEqual(first.cycleMembership?.members, [.first])
        XCTAssertEqual(first.cycleMembership?.length, 1)
    }

    func testTwoHouseExchangeIsRegisteredOnceAndReferencedByBothCycleMembers() {
        let placement = Mater.resolvePlacement(
            field: field(overriding: [
                .mars: .taurus,
                .venus: .aries,
            ]),
            in: Tympan.imprint(for: .aries)
        )

        let first = placement.placement(for: .first)
        let second = placement.placement(for: .second)

        XCTAssertEqual(first.routingPath, [.first, .second])
        XCTAssertEqual(second.routingPath, [.second, .first])
        XCTAssertEqual(first.terminalKind, .houseExchange)
        XCTAssertEqual(second.terminalKind, .houseExchange)
        XCTAssertEqual(first.keeper.id, "1+2")
        XCTAssertEqual(second.keeper.id, "1+2")
        XCTAssertEqual(first.cycleMembership?.members, [.first, .second])
        XCTAssertEqual(second.cycleMembership, first.cycleMembership)

        XCTAssertEqual(
            placement.cycles.filter { $0.kind == .houseExchange && $0.id == "1+2" }.count,
            1
        )
    }

    func testThreeHouseRoutingLoopIsRegisteredWithoutConfusingItWithReception() {
        let placement = Mater.resolvePlacement(
            field: field(overriding: [
                .mars: .taurus,
                .venus: .sagittarius,
                .jupiter: .aries,
            ]),
            in: Tympan.imprint(for: .aries)
        )

        let loop = try! XCTUnwrap(
            placement.cycles.first { cycle in
                cycle.kind == .routingLoop
                    && Set(cycle.members) == Set([House.first, .second, .ninth])
            }
        )

        XCTAssertEqual(loop.length, 3)
        XCTAssertEqual(placement.placement(for: .first).cycleMembership, loop)
        XCTAssertEqual(placement.placement(for: .second).cycleMembership, loop)
        XCTAssertEqual(placement.placement(for: .ninth).cycleMembership, loop)
    }

    func testCrossFieldHandoffsAreOneStepInBothDirections() {
        let a = field(overriding: [.venus: .aries])
        let b = field(overriding: [.mars: .capricorn])
        let cross = Mater.resolveCrossField(a, b)

        XCTAssertEqual(cross.handoffs.count, Planet.canonicalOrder.count * 2)

        let aVenus = try! XCTUnwrap(
            cross.handoffs.first { $0.from == .a && $0.planet == .venus }
        )
        XCTAssertEqual(aVenus.bearer, .mars)
        XCTAssertEqual(aVenus.landsInOtherField, .capricorn)

        let bMars = try! XCTUnwrap(
            cross.handoffs.first { $0.from == .b && $0.planet == .mars }
        )
        XCTAssertEqual(bMars.bearer, .saturn)
        XCTAssertEqual(bMars.landsInOtherField, a.placements[.saturn])
    }

    func testCrossFieldDomicileMutualReceptionIsRecordedBetweenDifferentFields() {
        let a = field(overriding: [.venus: .aries])
        let b = field(overriding: [.mars: .taurus])
        let cross = Mater.resolveCrossField(a, b)

        XCTAssertTrue(cross.receptions.contains { reception in
            reception.a == .venus
                && reception.b == .mars
                && reception.direction == .mutual
                && reception.kind == .domicile
        })
        XCTAssertTrue(cross.receptions.allSatisfy { $0.a != $0.b })
    }

    func testCrossFieldPreservesAtHomeExclusion() {
        let a = field(overriding: [.mars: .aries])
        let b = field(overriding: [.sun: .libra])
        let cross = Mater.resolveCrossField(a, b)

        XCTAssertFalse(cross.receptions.contains { reception in
            reception.a == .mars && reception.b == .sun
        })
    }
}
