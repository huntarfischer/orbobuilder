import XCTest
@testable import OrboCore

final class NatalSpineActIIBeat7DioscuriTests: XCTestCase {
    func testDioscuriApproveExactCandidate() throws {
        let candidate = try NatalSpineActIIFixture.addressableCandidate()
        let approval = try Dioscuri.inspectNatalSpine(
            candidate,
            against: candidate.commission.schematics,
            parentProvenance: candidate.substrate.parentProvenance
        ).get()

        XCTAssertEqual(approval.candidate.subjectID, candidate.subjectID)
        XCTAssertEqual(approval.candidate.bounds, candidate.bounds)
        XCTAssertEqual(approval.parentProvenance, candidate.substrate.parentProvenance)
    }

    func testRemovedThemisSpanIsRejected() throws {
        let baseline = try baselineMatter()
        let altered = matter(baseline, themis: Array(baseline.themis.dropLast()))
        XCTAssertEqual(inspect(altered), .themisCountMismatch)
    }

    func testMovedThemisBoundaryIsRejectedAtItsRow() throws {
        let baseline = try baselineMatter()
        var themis = baseline.themis
        let source = themis[0]
        let movedEnd = JulianDay(source.span.end.value - 0.25)!
        let moved = NatalSpineHouseSpan(
            body: source.span.body,
            house: source.span.house,
            start: source.span.start,
            end: movedEnd
        )!
        themis[0] = NatalSpineForgedThemisSpan(sourceRow: 0, span: moved)!
        XCTAssertEqual(inspect(matter(baseline, themis: themis)), .themisRowMismatch(0))
    }

    func testRemovedOceanusEventIsRejected() throws {
        let baseline = try baselineMatter()
        XCTAssertEqual(inspect(matter(baseline, oceanus: [])), .oceanusCountMismatch)
    }

    func testChangedNatalTargetIsRejected() throws {
        let baseline = try baselineMatter()
        var oceanus = baseline.oceanus
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
        XCTAssertEqual(inspect(matter(baseline, oceanus: oceanus)), .oceanusRowMismatch(0))
    }

    func testChangedRingRelationIsRejected() throws {
        let baseline = try baselineMatter()
        var oceanus = baseline.oceanus
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
        XCTAssertEqual(inspect(matter(baseline, oceanus: oceanus)), .oceanusRowMismatch(0))
    }

    func testMovedUTIsRejected() throws {
        let baseline = try baselineMatter()
        var oceanus = baseline.oceanus
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
        XCTAssertEqual(inspect(matter(baseline, oceanus: oceanus)), .oceanusRowMismatch(0))
    }

    func testChangedCelestialCoordinateIsRejected() throws {
        let baseline = try baselineMatter()
        var oceanus = baseline.oceanus
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
        XCTAssertEqual(inspect(matter(baseline, oceanus: oceanus)), .oceanusRowMismatch(0))
    }

    func testRemovedRheaQualificationIsRejected() throws {
        let baseline = try baselineMatter()
        XCTAssertEqual(
            inspect(matter(baseline, rhea: Array(baseline.rhea.dropLast()))),
            .rheaCountMismatch
        )
    }

    func testMisattachedRheaQualificationIsRejected() throws {
        let baseline = try baselineMatter()
        var rhea = baseline.rhea
        let source = rhea[0]
        rhea[0] = NatalSpineForgedRheaQualification(
            sourceRow: source.sourceRow,
            fact: .oceanusRealization(sourceRow: 0),
            qualification: source.qualification
        )!
        XCTAssertEqual(inspect(matter(baseline, rhea: rhea)), .rheaFactMismatch(0))
    }

    func testChangedNativeIdentityIsRejected() throws {
        let baseline = try baselineMatter()
        let foreign = HermesSubjectID(rawValue: "natal-spine.foreign")!
        XCTAssertEqual(inspect(matter(baseline, subjectID: foreign)), .subjectMismatch)
    }

    func testChangedClothoBoundsAreRejected() throws {
        let baseline = try baselineMatter()
        let alteredEnd = AbsoluteInstant(
            unixSecondsSince1970: baseline.bounds.end.unixSecondsSince1970 - 86_400
        )!
        let alteredBounds = NatalSpineBounds(
            subjectID: baseline.subjectID,
            start: baseline.bounds.start,
            natal: baseline.bounds.natal,
            end: alteredEnd
        )!
        XCTAssertEqual(inspect(matter(baseline, bounds: alteredBounds)), .boundsMismatch)
    }

    func testBrokenParentProvenanceIsRejected() throws {
        let baseline = try baselineMatter()
        let alteredProvenance = OrboSpineRuntimeProvenance(
            candidateManifestSHA256: String(repeating: "e", count: 64),
            astronomicalAuthority: baseline.substrate.parentProvenance.astronomicalAuthority,
            astronomicalSourceVersion: baseline.substrate.parentProvenance.astronomicalSourceVersion
        )!
        let alteredSubstrate = NatalSpineCelestialSubstrate(
            subjectID: baseline.substrate.subjectID,
            bounds: baseline.substrate.bounds,
            supports: baseline.substrate.supports,
            stations: baseline.substrate.stations,
            boundaryAnchors: baseline.substrate.boundaryAnchors,
            parentProvenance: alteredProvenance
        )!
        XCTAssertEqual(inspect(matter(baseline, substrate: alteredSubstrate)), .provenanceMismatch)
    }

    func testInventedExtraMatterIsRejected() throws {
        let baseline = try baselineMatter()
        var oceanus = baseline.oceanus
        let invented = NatalSpineForgedOceanusRealization(
            sourceRow: oceanus.count,
            realization: oceanus[0].realization
        )!
        oceanus.append(invented)
        XCTAssertEqual(inspect(matter(baseline, oceanus: oceanus)), .oceanusCountMismatch)
    }

    private func baselineMatter() throws -> NatalSpineDioscuriMatter {
        NatalSpineDioscuriMatter(candidate: try NatalSpineActIIFixture.addressableCandidate())
    }

    private func inspect(_ matter: NatalSpineDioscuriMatter) -> NatalSpineDioscuriFailure? {
        let schematics = try! NatalSpineActIIFixture.forgeCommission().schematics
        switch Dioscuri.inspectNatalSpine(
            matter,
            against: schematics,
            parentProvenance: schematicsParentProvenance
        ) {
        case .success:
            return nil
        case let .failure(failure):
            return failure
        }
    }

    private var schematicsParentProvenance: OrboSpineRuntimeProvenance {
        OrboSpineRuntimeProvenance(
            candidateManifestSHA256: String(repeating: "d", count: 64),
            astronomicalAuthority: "canonical-parent",
            astronomicalSourceVersion: "verification-fixture"
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
