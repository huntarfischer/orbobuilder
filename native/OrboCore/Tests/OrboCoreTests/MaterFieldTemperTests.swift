import XCTest
@testable import OrboCore

final class MaterFieldTemperTests: XCTestCase {
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

    func testCompleteFieldResolvesTenCanonicalPlanetTempersInCanonicalOrder() {
        let placements = completePlacements()
        let field = Mater.resolveField(placements)

        XCTAssertEqual(field.placements, placements)
        XCTAssertEqual(field.tempers.count, Planet.canonicalOrder.count)
        XCTAssertEqual(field.tempers.map(\.planet), Planet.canonicalOrder)
        XCTAssertEqual(field.byPlanet.count, Planet.canonicalOrder.count)

        for planet in Planet.canonicalOrder {
            let resolved = field.temper(for: planet)
            XCTAssertEqual(resolved.temper, Mater.temper(of: planet, in: placements[planet]!))
            XCTAssertEqual(resolved.dispositorCapable, planet.isClassical)
            XCTAssertEqual(resolved.bearer, Mater.domicileRuler(of: placements[planet]!))
        }
    }

    func testDomicileIsRegisteredAsOneCycleWithUniformKeeperShape() {
        let field = Mater.resolveField(completePlacements())
        let mars = field.temper(for: .mars)

        XCTAssertEqual(mars.dispositorPath, [.mars])
        XCTAssertEqual(mars.terminalKind, .domicile)
        XCTAssertEqual(mars.keeper.kind, .domicile)
        XCTAssertEqual(mars.keeper.id, "Mars")
        XCTAssertEqual(mars.cycleMembership?.members, [.mars])
        XCTAssertEqual(mars.cycleMembership?.length, 1)
        XCTAssertEqual(mars.cycleMembership?.kind, .domicile)
    }

    func testDomicileMutualReceptionIsBothTwoCycleAndImmediateBooleanCondition() {
        let field = Mater.resolveField(
            completePlacements(overriding: [
                .mars: .taurus,
                .venus: .aries,
            ])
        )

        let mars = field.temper(for: .mars)
        let venus = field.temper(for: .venus)

        XCTAssertEqual(mars.dispositorPath, [.mars, .venus])
        XCTAssertEqual(venus.dispositorPath, [.venus, .mars])
        XCTAssertEqual(mars.terminalKind, .mutualReception)
        XCTAssertEqual(venus.terminalKind, .mutualReception)
        XCTAssertEqual(mars.keeper.id, "Mars+Venus")
        XCTAssertEqual(venus.keeper.id, "Mars+Venus")

        XCTAssertTrue(mars.mutualReception)
        XCTAssertEqual(mars.mutualReceptionWith, [.venus])
        XCTAssertEqual(mars.mutualReceptionKinds, [.domicile])

        XCTAssertTrue(venus.mutualReception)
        XCTAssertEqual(venus.mutualReceptionWith, [.mars])
        XCTAssertEqual(venus.mutualReceptionKinds, [.domicile])

        XCTAssertTrue(field.mutualReceptions.contains {
            $0.a == .venus && $0.b == .mars && $0.kind == .domicile
        })
    }

    func testExaltationMutualReceptionSetsTheSameBooleanWithoutCreatingADomicileCycle() {
        let field = Mater.resolveField(
            completePlacements(overriding: [
                .sun: .libra,
                .saturn: .aries,
            ])
        )

        let sun = field.temper(for: .sun)
        let saturn = field.temper(for: .saturn)

        XCTAssertTrue(sun.mutualReception)
        XCTAssertEqual(sun.mutualReceptionWith, [.saturn])
        XCTAssertEqual(sun.mutualReceptionKinds, [.exaltation])

        XCTAssertTrue(saturn.mutualReception)
        XCTAssertEqual(saturn.mutualReceptionWith, [.sun])
        XCTAssertEqual(saturn.mutualReceptionKinds, [.exaltation])

        XCTAssertNotEqual(sun.terminalKind, .mutualReception)
        XCTAssertNotEqual(saturn.terminalKind, .mutualReception)
    }

    func testThreePlanetDispositorLoopIsRegisteredOnceAndReferencedByEveryMember() {
        let field = Mater.resolveField(
            completePlacements(overriding: [
                .mercury: .aries,
                .mars: .sagittarius,
                .jupiter: .gemini,
            ])
        )

        let expectedMembers: Set<Planet> = [.mercury, .mars, .jupiter]
        let loops = field.cycles.filter { $0.kind == .dispositorLoop }
        XCTAssertEqual(loops.count, 1)
        XCTAssertEqual(Set(loops[0].members), expectedMembers)
        XCTAssertEqual(loops[0].length, 3)

        for planet in expectedMembers {
            let resolved = field.temper(for: planet)
            XCTAssertEqual(resolved.terminalKind, .dispositorLoop)
            XCTAssertEqual(resolved.keeper.id, loops[0].id)
            XCTAssertEqual(resolved.cycleMembership, loops[0])
        }
    }

    func testImmediateDependentsAndTransitiveDescendantsAreRecordedWithoutRewalking() {
        let field = Mater.resolveField(
            completePlacements(overriding: [
                .pluto: .taurus,
                .venus: .aries,
                .mars: .capricorn,
                .saturn: .capricorn,
            ])
        )

        XCTAssertEqual(field.temper(for: .pluto).dispositorPath, [.pluto, .venus, .mars, .saturn])
        XCTAssertTrue(field.temper(for: .venus).immediateDependents.contains(.pluto))
        XCTAssertTrue(field.temper(for: .mars).immediateDependents.contains(.venus))
        XCTAssertTrue(field.temper(for: .saturn).immediateDependents.contains(.mars))

        XCTAssertTrue(field.temper(for: .venus).transitiveDescendants.contains(.pluto))
        XCTAssertTrue(field.temper(for: .mars).transitiveDescendants.contains(.pluto))
        XCTAssertTrue(field.temper(for: .saturn).transitiveDescendants.contains(.pluto))
        XCTAssertTrue(field.temper(for: .saturn).transitiveDescendants.contains(.venus))
        XCTAssertTrue(field.temper(for: .saturn).transitiveDescendants.contains(.mars))
    }

    func testModernPlanetsRemainLeavesOnTheTraditionalDispositorBackbone() {
        let field = Mater.resolveField(
            completePlacements(overriding: [
                .pluto: .scorpio,
                .uranus: .aquarius,
                .neptune: .pisces,
            ])
        )

        for planet in [Planet.pluto, .uranus, .neptune] {
            let resolved = field.temper(for: planet)
            XCTAssertFalse(resolved.dispositorCapable)
            XCTAssertTrue(resolved.bearer.isClassical)
            XCTAssertNotEqual(resolved.bearer, planet)
            XCTAssertEqual(resolved.dispositorPath.first, planet)
            XCTAssertTrue(resolved.dispositorPath.dropFirst().allSatisfy(\.isClassical))
        }
    }
}
