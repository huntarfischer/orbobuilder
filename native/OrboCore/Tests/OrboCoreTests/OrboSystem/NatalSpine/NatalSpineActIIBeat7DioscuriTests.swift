import XCTest
@testable import OrboCore

final class NatalSpineActIIBeat7DioscuriTests: XCTestCase {
    private struct Baseline {
        let matter: NatalSpineDioscuriMatter
        let parent: NatalSpineActIIFixture.ParentSource
    }

    func testDioscuriApproveExactCandidate() throws {
        let candidate = try NatalSpineActIIFixture.addressableCandidate()
        let parent = NatalSpineActIIFixture.parentSource(for: candidate.commission)
        let approval = try Dioscuri.inspectNatalSpine(
            candidate,
            against: candidate.commission.schematics,
            parent: parent
        ).get()

        XCTAssertEqual(approval.candidate.subjectID, candidate.subjectID)
        XCTAssertEqual(approval.candidate.bounds, candidate.bounds)
        XCTAssertEqual(approval.parentProvenance, candidate.substrate.parentProvenance)
    }

    func testRemovedParentSupportIsRejected() throws {
        let baseline = try baseline()
        var supports = baseline.matter.substrate.supports
        let removed = supports.removeFirst()
        let altered = substrate(baseline.matter.substrate, supports: supports)

        XCTAssertEqual(
            inspect(matter(baseline.matter, substrate: altered), parent: baseline.parent),
            .celestialSupportMismatch(removed.body)
        )
    }

    func testMovedParentSupportIsRejected() throws {
        let baseline = try baseline()
        var supports = baseline.matter.substrate.supports
        let source = supports[0]
        supports[0] = OrboSpineCelestialCoordinate(
            body: source.body,
            directionalDegree: source.directionalDegree,
            julianDay: JulianDay(source.julianDay.value + 0.25)!
        )
        let altered = substrate(baseline.matter.substrate, supports: supports)

        XCTAssertEqual(
            inspect(matter(baseline.matter, substrate: altered), parent: baseline.parent),
            .celestialSupportMismatch(source.body)
        )
    }

    func testInventedParentSupportIsRejected() throws {
        let baseline = try baseline()
        var supports = baseline.matter.substrate.supports
        let invented = supports[0]
        supports.append(invented)
        let altered = substrate(baseline.matter.substrate, supports: supports)

        XCTAssertEqual(
            inspect(matter(baseline.matter, substrate: altered), parent: baseline.parent),
            .celestialSupportMismatch(invented.body)
        )
    }

    func testMissingParentStationIsRejected() throws {
        let baseline = try baseline()
        let station = OrboSpineStation(
            body: .mercury,
            physicalDegrees: 20,
            julianDay: JulianDay(baseline.matter.bounds.bone.start.value + 30)!,
            laneBefore: .direct,
            laneAfter: .retrograde
        )!
        let parent = NatalSpineActIIFixture.parentSource(
            for: baseline.parent.commission,
            stations: [station]
        )

        XCTAssertEqual(inspect(baseline.matter, parent: parent), .stationMismatch)
    }

    func testChangedBoundaryAnchorIsRejected() throws {
        let baseline = try baseline()
        var anchors = baseline.matter.substrate.boundaryAnchors
        let source = anchors[0]
        let shifted = (source.physicalDegrees + 1).truncatingRemainder(dividingBy: 360)
        anchors[0] = OrboSpineBoundaryAnchor(
            body: source.body,
            boundary: source.boundary,
            julianDay: source.julianDay,
            physicalDegrees: shifted,
            motion: source.motion
        )!
        let altered = substrate(baseline.matter.substrate, boundaryAnchors: anchors)

        XCTAssertEqual(
            inspect(matter(baseline.matter, substrate: altered), parent: baseline.parent),
            .boundaryAnchorMismatch(source.body)
        )
    }

    func testParentBoneThatDoesNotContainChildIsRejected() throws {
        let baseline = try baseline()
        let tooShort = OrboSpineBoneSpan(
            start: baseline.matter.bounds.bone.start,
            end: baseline.matter.bounds.bone.end
        )!
        let parent = NatalSpineActIIFixture.parentSource(
            for: baseline.parent.commission,
            bone: tooShort
        )

        XCTAssertEqual(inspect(baseline.matter, parent: parent), .parentBoneMismatch)
    }

    func testRemovedThemisSpanIsRejected() throws {
        let baseline = try baseline()
        let altered = matter(
            baseline.matter,
            themis: Array(baseline.matter.themis.dropLast())
        )
        XCTAssertEqual(inspect(altered, parent: baseline.parent), .themisCountMismatch)
    }

    func testMovedThemisBoundaryIsRejectedAtItsRow() throws {
        let baseline = try baseline()
        var themis = baseline.matter.themis
        let source = themis[0]
        let movedEnd = JulianDay(source.span.end.value - 0.25)!
        let moved = NatalSpineHouseSpan(
            body: source.span.body,
            house: source.span.house,
            start: source.span.start,
            end: movedEnd
        )!
        themis[0] = NatalSpineForgedThemisSpan(sourceRow: 0, span: moved)!
        XCTAssertEqual(
            inspect(matter(baseline.matter, themis: themis), parent: baseline.parent),
            .themisRowMismatch(0)
        )
    }

    func testRemovedOceanusEventIsRejected() throws {
        let baseline = try baseline()
        XCTAssertEqual(
            inspect(matter(baseline.matter, oceanus: []), parent: baseline.parent),
            .oceanusCountMismatch
        )
    }

    func testChangedNatalTargetIsRejected() throws {
        let baseline = try baseline()
        var oceanus = baseline.matter.oceanus
        let source = oceanus[0].realization
        let otherGene = AstroDNAGene.canonicalOrder.first { $0 != source.natalGene }!
        let altered = NatalSpineRingRealization(
            mundaneBody: source.mundaneBody,
            natalGene: otherGene,
            natalSource: source.natalSource,
            relation: source.relation,
            targetArcsecond: source.targetArcsecond,
            occurrence: source.occurrence
        )!
        oceanus[0] = NatalSpineForgedOceanusRealization(sourceRow: 0, realization: altered)!
        XCTAssertEqual(
            inspect(matter(baseline.matter, oceanus: oceanus), parent: baseline.parent),
            .oceanusRowMismatch(0)
        )
    }

    func testChangedRingRelationIsRejected() throws {
        let baseline = try baseline()
        var oceanus = baseline.matter.oceanus
        let source = oceanus[0].realization
        let otherRelation = RingMark.allCases.first { $0 != source.relation }!
        let altered = NatalSpineRingRealization(
            mundaneBody: source.mundaneBody,
            natalGene: source.natalGene,
            natalSource: source.natalSource,
            relation: otherRelation,
            targetArcsecond: source.targetArcsecond,
            occurrence: source.occurrence
        )!
        oceanus[0] = NatalSpineForgedOceanusRealization(sourceRow: 0, realization: altered)!
        XCTAssertEqual(
            inspect(matter(baseline.matter, oceanus: oceanus), parent: baseline.parent),
            .oceanusRowMismatch(0)
        )
    }

    func testMovedUTIsRejected() throws {
        let baseline = try baseline()
        var oceanus = baseline.matter.oceanus
        let source = oceanus[0].realization
        let movedCoordinate = OrboSpineCelestialCoordinate(
            body: source.mundaneBody,
            directionalDegree: source.occurrence.directionalDegree,
            julianDay: JulianDay(source.occurrence.julianDay.value + 0.1)!
        )
        let altered = NatalSpineRingRealization(
            mundaneBody: source.mundaneBody,
            natalGene: source.natalGene,
            natalSource: source.natalSource,
            relation: source.relation,
            targetArcsecond: source.targetArcsecond,
            occurrence: movedCoordinate
        )!
        oceanus[0] = NatalSpineForgedOceanusRealization(sourceRow: 0, realization: altered)!
        XCTAssertEqual(
            inspect(matter(baseline.matter, oceanus: oceanus), parent: baseline.parent),
            .oceanusRowMismatch(0)
        )
    }

    func testChangedCelestialCoordinateIsRejected() throws {
        let baseline = try baseline()
        var oceanus = baseline.matter.oceanus
        let source = oceanus[0].realization
        let shiftedArcsecond = source.targetArcsecond + 1 < Ring.arcseconds
            ? source.targetArcsecond + 1
            : source.targetArcsecond - 1
        let shiftedCoordinate = OrboSpineCelestialCoordinate(
            body: source.mundaneBody,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: Double(shiftedArcsecond) / Double(Ring.arcsecondsPerDegree),
                motion: source.occurrence.directionalDegree.motion
            )!,
            julianDay: source.occurrence.julianDay
        )
        let altered = NatalSpineRingRealization(
            mundaneBody: source.mundaneBody,
            natalGene: source.natalGene,
            natalSource: source.natalSource,
            relation: source.relation,
            targetArcsecond: shiftedArcsecond,
            occurrence: shiftedCoordinate
        )!
        oceanus[0] = NatalSpineForgedOceanusRealization(sourceRow: 0, realization: altered)!
        XCTAssertEqual(
            inspect(matter(baseline.matter, oceanus: oceanus), parent: baseline.parent),
            .oceanusRowMismatch(0)
        )
    }

    func testRemovedRheaQualificationIsRejected() throws {
        let baseline = try baseline()
        XCTAssertEqual(
            inspect(
                matter(
                    baseline.matter,
                    rhea: Array(baseline.matter.rhea.dropLast())
                ),
                parent: baseline.parent
            ),
            .rheaCountMismatch
        )
    }

    func testMisattachedRheaQualificationIsRejected() throws {
        let baseline = try baseline()
        var rhea = baseline.matter.rhea
        let source = rhea[0]
        rhea[0] = NatalSpineForgedRheaQualification(
            sourceRow: source.sourceRow,
            fact: .oceanusRealization(sourceRow: 0),
            qualification: source.qualification
        )!
        XCTAssertEqual(
            inspect(matter(baseline.matter, rhea: rhea), parent: baseline.parent),
            .rheaFactMismatch(0)
        )
    }

    func testChangedNativeIdentityIsRejected() throws {
        let baseline = try baseline()
        let foreign = HermesSubjectID(rawValue: "natal-spine.foreign")!
        XCTAssertEqual(
            inspect(matter(baseline.matter, subjectID: foreign), parent: baseline.parent),
            .subjectMismatch
        )
    }

    func testChangedClothoBoundsAreRejected() throws {
        let baseline = try baseline()
        let alteredEnd = AbsoluteInstant(
            unixSecondsSince1970: baseline.matter.bounds.end.unixSecondsSince1970 - 86_400
        )!
        let alteredBounds = NatalSpineBounds(
            subjectID: baseline.matter.subjectID,
            start: baseline.matter.bounds.start,
            natal: baseline.matter.bounds.natal,
            end: alteredEnd
        )!
        XCTAssertEqual(
            inspect(matter(baseline.matter, bounds: alteredBounds), parent: baseline.parent),
            .boundsMismatch
        )
    }

    func testBrokenParentProvenanceIsRejected() throws {
        let baseline = try baseline()
        let alteredProvenance = OrboSpineRuntimeProvenance(
            candidateManifestSHA256: String(repeating: "e", count: 64),
            astronomicalAuthority: baseline.matter.substrate.parentProvenance.astronomicalAuthority,
            astronomicalSourceVersion: baseline.matter.substrate.parentProvenance.astronomicalSourceVersion
        )!
        let alteredSubstrate = substrate(
            baseline.matter.substrate,
            parentProvenance: alteredProvenance
        )
        XCTAssertEqual(
            inspect(
                matter(baseline.matter, substrate: alteredSubstrate),
                parent: baseline.parent
            ),
            .provenanceMismatch
        )
    }

    func testInventedExtraMatterIsRejected() throws {
        let baseline = try baseline()
        var oceanus = baseline.matter.oceanus
        let invented = NatalSpineForgedOceanusRealization(
            sourceRow: oceanus.count,
            realization: oceanus[0].realization
        )!
        oceanus.append(invented)
        XCTAssertEqual(
            inspect(matter(baseline.matter, oceanus: oceanus), parent: baseline.parent),
            .oceanusCountMismatch
        )
    }

    private func baseline() throws -> Baseline {
        let candidate = try NatalSpineActIIFixture.addressableCandidate()
        return Baseline(
            matter: NatalSpineDioscuriMatter(candidate: candidate),
            parent: NatalSpineActIIFixture.parentSource(for: candidate.commission)
        )
    }

    private func inspect(
        _ matter: NatalSpineDioscuriMatter,
        parent: NatalSpineActIIFixture.ParentSource
    ) -> NatalSpineDioscuriFailure? {
        let schematics = try! NatalSpineActIIFixture.forgeCommission().schematics
        switch Dioscuri.inspectNatalSpine(
            matter,
            against: schematics,
            parent: parent
        ) {
        case .success:
            return nil
        case let .failure(failure):
            return failure
        }
    }

    private func substrate(
        _ baseline: NatalSpineCelestialSubstrate,
        supports: [OrboSpineCelestialCoordinate]? = nil,
        stations: [OrboSpineStation]? = nil,
        boundaryAnchors: [OrboSpineBoundaryAnchor]? = nil,
        parentProvenance: OrboSpineRuntimeProvenance? = nil
    ) -> NatalSpineCelestialSubstrate {
        NatalSpineCelestialSubstrate(
            subjectID: baseline.subjectID,
            bounds: baseline.bounds,
            supports: supports ?? baseline.supports,
            stations: stations ?? baseline.stations,
            boundaryAnchors: boundaryAnchors ?? baseline.boundaryAnchors,
            parentProvenance: parentProvenance ?? baseline.parentProvenance
        )!
    }

    private func matter(
        _ baseline: NatalSpineDioscuriMatter,
        subjectID: HermesSubjectID? = nil,
        bounds: NatalSpineBounds? = nil,
        substrate: NatalSpineCelestialSubstrate? = nil,
        themis: [NatalSpineForgedThemisSpan]? = nil,
        oceanus: [NatalSpineForgedOceanusRealization]? = nil,
        rhea: [NatalSpineForgedRheaQualification]? = nil
    ) -> NatalSpineDioscuriMatter {
        NatalSpineDioscuriMatter(
            subjectID: subjectID ?? baseline.subjectID,
            bounds: bounds ?? baseline.bounds,
            substrate: substrate ?? baseline.substrate,
            themis: themis ?? baseline.themis,
            oceanus: oceanus ?? baseline.oceanus,
            rhea: rhea ?? baseline.rhea
        )
    }
}
