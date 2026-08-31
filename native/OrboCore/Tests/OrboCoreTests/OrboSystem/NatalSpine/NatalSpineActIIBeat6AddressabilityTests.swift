import XCTest
@testable import OrboCore

final class NatalSpineActIIBeat6AddressabilityTests: XCTestCase {
    func testUTAndCelestialTimeResolveTheSameForgedOceanusMatter() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let candidate = try makeCandidate(for: commission)
        let source = try XCTUnwrap(commission.schematics.oceanus.realizations.first)

        let byUT = try candidate.address(
            of: source.mundaneBody,
            at: source.occurrence.julianDay
        )
        let byCelestial = try candidate.addresses(
            of: source.mundaneBody,
            at: source.occurrence.directionalDegree
        )
        let matching = try XCTUnwrap(
            byCelestial.first {
                abs($0.coordinate.julianDay.value - source.occurrence.julianDay.value) <= 1e-9
            }
        )

        XCTAssertEqual(byUT, matching)
        XCTAssertEqual(byUT.coordinate, source.occurrence)
        XCTAssertEqual(byUT.oceanusSourceRows, [0])
        XCTAssertFalse(byUT.rheaSourceRows.isEmpty)
    }

    func testRepeatedCelestialOccurrenceRemainsDistinctByUT() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let candidate = try makeCandidate(for: commission)
        let source = try XCTUnwrap(commission.schematics.oceanus.realizations.first)

        let addresses = try candidate.addresses(
            of: source.mundaneBody,
            at: source.occurrence.directionalDegree
        )

        XCTAssertGreaterThanOrEqual(addresses.count, 2)
        let julianDays = addresses.map { $0.coordinate.julianDay.value }
        XCTAssertEqual(Set(julianDays).count, julianDays.count)
        XCTAssertTrue(julianDays.contains { abs($0 - source.occurrence.julianDay.value) <= 1e-9 })
    }

    func testUTAddressUsesTheSameChildLocateChronology() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let substrate = navigableSubstrate(for: commission)
        let candidate = try makeCandidate(for: commission, substrate: substrate)
        let source = try XCTUnwrap(commission.schematics.oceanus.realizations.first)
        let directLocate = try XCTUnwrap(
            OrboSpineLocate(
                bone: substrate.bounds.bone,
                celestialSupports: substrate.supports,
                stations: substrate.stations,
                boundaryAnchors: substrate.boundaryAnchors
            )
        )

        let expected = try directLocate.coordinate(
            of: source.mundaneBody,
            at: source.occurrence.julianDay
        )
        let actual = try candidate.address(
            of: source.mundaneBody,
            at: source.occurrence.julianDay
        )

        XCTAssertEqual(actual.coordinate, expected)
    }

    func testEndExclusiveCannotBeAddressed() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let candidate = try makeCandidate(for: commission)

        XCTAssertThrowsError(
            try candidate.address(
                of: .sun,
                at: commission.schematics.bounds.bone.end
            )
        ) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
    }

    private func makeCandidate(
        for commission: NatalSpineForgeCommission,
        substrate: NatalSpineCelestialSubstrate? = nil
    ) throws -> NatalSpineCandidate {
        let child = substrate ?? navigableSubstrate(for: commission)
        let themis = try Hephaestus.forgeNatalSpineThemis(
            for: commission,
            on: child
        )
        let oceanus = try Hephaestus.forgeNatalSpineOceanus(on: themis)
        let rhea = try Hephaestus.forgeNatalSpineRhea(on: oceanus)
        return try Hephaestus.forgeNatalSpineAddressability(on: rhea)
    }

    /// A deterministic two-cycle child tract for each mundane body. The Sun's
    /// first repeated target is pinned to the certified Oceanus fixture event,
    /// proving that the same forged event is reachable from both directions.
    private func navigableSubstrate(
        for commission: NatalSpineForgeCommission
    ) -> NatalSpineCelestialSubstrate {
        let bone = commission.schematics.bounds.bone
        let event = commission.schematics.oceanus.realizations.first!
        let pivot = event.occurrence.julianDay
        let remaining = bone.end.value - pivot.value

        var supports: [OrboSpineCelestialCoordinate] = []
        var anchors: [OrboSpineBoundaryAnchor] = []

        for body in MundaneBody.canonicalOrder {
            let step = OrboSpineContract.supportDegrees(for: body)
            let count = Int((360.0 / step).rounded())
            let target = body == event.mundaneBody
                ? event.occurrence.directionalDegree.physicalDegrees
                : 0.0
            let before = normalize(target - step)

            supports.append(
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: OrboSpineDirectionalDegree(
                        physicalDegrees: before,
                        motion: .direct
                    )!,
                    julianDay: bone.start
                )
            )
            supports.append(
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: OrboSpineDirectionalDegree(
                        physicalDegrees: target,
                        motion: .direct
                    )!,
                    julianDay: pivot
                )
            )

            let totalSteps = count * 2
            for index in 1..<totalSteps {
                let fraction = Double(index) / Double(totalSteps)
                let day = JulianDay(pivot.value + remaining * fraction)!
                let physical = normalize(target + Double(index) * step)
                supports.append(
                    OrboSpineCelestialCoordinate(
                        body: body,
                        directionalDegree: OrboSpineDirectionalDegree(
                            physicalDegrees: physical,
                            motion: .direct
                        )!,
                        julianDay: day
                    )
                )
            }

            anchors.append(
                OrboSpineBoundaryAnchor(
                    body: body,
                    boundary: .start,
                    julianDay: bone.start,
                    physicalDegrees: before,
                    motion: .direct
                )!
            )
            anchors.append(
                OrboSpineBoundaryAnchor(
                    body: body,
                    boundary: .endExclusive,
                    julianDay: bone.end,
                    physicalDegrees: target,
                    motion: .direct
                )!
            )
        }

        return NatalSpineCelestialSubstrate(
            subjectID: commission.subjectID,
            bounds: commission.schematics.bounds,
            supports: supports,
            stations: [],
            boundaryAnchors: anchors,
            parentProvenance: OrboSpineRuntimeProvenance(
                candidateManifestSHA256: String(repeating: "c", count: 64),
                astronomicalAuthority: "canonical-parent",
                astronomicalSourceVersion: "addressability-fixture"
            )!
        )!
    }

    private func normalize(_ degrees: Double) -> Double {
        let value = degrees.truncatingRemainder(dividingBy: 360.0)
        return value >= 0 ? value : value + 360.0
    }
}
