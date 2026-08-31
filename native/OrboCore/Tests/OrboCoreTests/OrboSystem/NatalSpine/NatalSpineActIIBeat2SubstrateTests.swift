import XCTest
@testable import OrboCore

final class NatalSpineActIIBeat2SubstrateTests: XCTestCase {
    private struct SourceStub: NatalSpineForgeTimespineSource {
        let sourceBone: OrboSpineBoneSpan
        let childBone: OrboSpineBoneSpan
        let sourceStations: [OrboSpineStation]
        let sourceProvenance: OrboSpineRuntimeProvenance

        func coordinate(
            of body: MundaneBody,
            at julianDay: JulianDay
        ) throws -> OrboSpineCelestialCoordinate {
            let physical = (Double(body.rawValue) * 17.0 + julianDay.value.truncatingRemainder(dividingBy: 30.0))
                .truncatingRemainder(dividingBy: 360.0)
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: OrboSpineDirectionalDegree(
                    physicalDegrees: physical,
                    motion: .direct
                )!,
                julianDay: julianDay
            )
        }

        func occurrences(
            of body: MundaneBody,
            at directionalDegree: OrboSpineDirectionalDegree
        ) throws -> [OrboSpineCelestialCoordinate] {
            guard directionalDegree.motion == .direct else { return [] }
            let span = childBone.end.value - childBone.start.value
            let first = JulianDay(childBone.start.value + span * 0.25)!
            let second = JulianDay(childBone.start.value + span * 0.75)!
            return [
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: directionalDegree,
                    julianDay: first
                ),
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: directionalDegree,
                    julianDay: second
                ),
            ]
        }
    }

    func testHephaestusBuildsBoundedChildMatterFromParentTimespineOnly() throws {
        let commission = try forgeCommission()
        let bounds = commission.schematics.bounds
        let source = source(for: bounds)

        let substrate = try Hephaestus.forgeNatalSpineSubstrate(
            for: commission,
            from: source
        )

        XCTAssertEqual(substrate.subjectID, commission.subjectID)
        XCTAssertEqual(substrate.bounds, bounds)
        XCTAssertEqual(substrate.parentProvenance, source.sourceProvenance)
        XCTAssertEqual(Set(substrate.supports.map(\.body)), Set(MundaneBody.canonicalOrder))
        XCTAssertTrue(substrate.supports.allSatisfy { bounds.bone.contains($0.julianDay) })
        XCTAssertEqual(substrate.boundaryAnchors.count, MundaneBody.canonicalOrder.count * 2)
        XCTAssertEqual(
            substrate.boundaryAnchors.filter { $0.boundary == .start }.count,
            MundaneBody.canonicalOrder.count
        )
        XCTAssertEqual(
            substrate.boundaryAnchors.filter { $0.boundary == .endExclusive }.count,
            MundaneBody.canonicalOrder.count
        )
        XCTAssertEqual(substrate.stations.count, 1)
        XCTAssertTrue(bounds.bone.contains(try XCTUnwrap(substrate.stations.first).julianDay))
    }

    func testSubstrateRetainsCanonicalSupportResolutionByBody() throws {
        let commission = try forgeCommission()
        let substrate = try Hephaestus.forgeNatalSpineSubstrate(
            for: commission,
            from: source(for: commission.schematics.bounds)
        )

        for body in MundaneBody.canonicalOrder {
            let bodySupports = substrate.supports.filter { $0.body == body }
            let expectedTargets = Int((360.0 / OrboSpineContract.supportDegrees(for: body)).rounded())
            XCTAssertEqual(bodySupports.count, expectedTargets * 2)
        }
    }

    func testHephaestusRejectsLifeDomainOutsideParentOrboSpine() throws {
        let commission = try forgeCommission()
        let bounds = commission.schematics.bounds
        let tooShortParent = OrboSpineBoneSpan(
            start: bounds.bone.start,
            end: JulianDay(bounds.bone.end.value - 1)!
        )!
        let source = SourceStub(
            sourceBone: tooShortParent,
            childBone: bounds.bone,
            sourceStations: [],
            sourceProvenance: provenance()
        )

        XCTAssertThrowsError(
            try Hephaestus.forgeNatalSpineSubstrate(for: commission, from: source)
        ) { error in
            XCTAssertEqual(error as? NatalSpineSubstrateFailure, .outsideParentBone)
        }
    }

    private func source(for bounds: NatalSpineBounds) -> SourceStub {
        let sourceBone = OrboSpineBoneSpan(
            start: JulianDay(bounds.bone.start.value - 10)!,
            end: JulianDay(bounds.bone.end.value + 10)!
        )!
        let insideStation = OrboSpineStation(
            body: .mercury,
            physicalDegrees: 20,
            julianDay: JulianDay(bounds.bone.start.value + 20)!,
            laneBefore: .direct,
            laneAfter: .retrograde
        )!
        let outsideStation = OrboSpineStation(
            body: .mercury,
            physicalDegrees: 21,
            julianDay: JulianDay(bounds.bone.end.value + 5)!,
            laneBefore: .retrograde,
            laneAfter: .direct
        )!
        return SourceStub(
            sourceBone: sourceBone,
            childBone: bounds.bone,
            sourceStations: [insideStation, outsideStation],
            sourceProvenance: provenance()
        )
    }

    private func provenance() -> OrboSpineRuntimeProvenance {
        OrboSpineRuntimeProvenance(
            candidateManifestSHA256: String(repeating: "a", count: 64),
            astronomicalAuthority: "canonical-parent",
            astronomicalSourceVersion: "test"
        )!
    }

    private func forgeCommission() throws -> NatalSpineForgeCommission {
        let hestia = try NatalSpineTestFixture.litHestia()
        let truth = try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)
        let themis = NatalSpineThemisTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            spans: MundaneBody.canonicalOrder.map {
                NatalSpineHouseSpan(
                    body: $0,
                    house: House(rawValue: 1)!,
                    start: bounds.bone.start,
                    end: bounds.bone.end
                )!
            }
        )
        let oceanus = NatalSpineOceanusTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            bodies: MundaneBody.canonicalOrder.map {
                NatalSpineOceanusBodyTable(body: $0, realizations: [])
            }
        )
        let rhea = NatalSpineRheaTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            qualifications: []
        )
        let certified = try Atropos.inspectNatalSpineSchematics(
            bounds: bounds,
            themis: themis,
            oceanus: oceanus,
            rhea: rhea
        ).get()
        let package = HermesPackage(
            packageID: HermesPackageID(),
            subjectID: truth.subjectID,
            sender: OrboOnboarding.orboAddress,
            kind: NatalSpineCommission.packageKind,
            addresses: NatalSpineCommission.itinerary,
            contents: certified
        )!
        return try Hephaestus.receiveNatalSpineSchematics(package)
    }
}
