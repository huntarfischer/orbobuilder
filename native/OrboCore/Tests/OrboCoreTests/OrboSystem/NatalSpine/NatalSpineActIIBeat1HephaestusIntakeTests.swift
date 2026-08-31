import XCTest
@testable import OrboCore

final class NatalSpineActIIBeat1HephaestusIntakeTests: XCTestCase {
    func testHephaestusAcceptsAtroposCertifiedSchematicsUnderOriginalEnvelope() throws {
        let package = try certifiedPackage()

        let intake = try Hephaestus.receiveNatalSpineSchematics(package)

        XCTAssertEqual(intake.packageID, package.packageID)
        XCTAssertEqual(intake.subjectID, package.subjectID)
        XCTAssertEqual(intake.schematics, package.contents)
    }

    func testHephaestusRejectsWrongEnvelopeKindOrJourney() throws {
        let package = try certifiedPackage()
        let wrongKind = HermesPackage(
            packageID: package.packageID,
            subjectID: package.subjectID,
            sender: package.sender,
            kind: HermesPackageKind(rawValue: "orbo.not-natal-spine")!,
            addresses: package.addresses,
            contents: package.contents
        )!
        XCTAssertThrowsError(try Hephaestus.receiveNatalSpineSchematics(wrongKind)) { error in
            XCTAssertEqual(error as? NatalSpineHephaestusFailure, .unexpectedPackage)
        }

        let wrongJourney = HermesPackage(
            packageID: package.packageID,
            subjectID: package.subjectID,
            sender: package.sender,
            kind: package.kind,
            addresses: [NatalSpineCommission.hephaestusAddress],
            contents: package.contents
        )!
        XCTAssertThrowsError(try Hephaestus.receiveNatalSpineSchematics(wrongJourney)) { error in
            XCTAssertEqual(error as? NatalSpineHephaestusFailure, .unexpectedPackage)
        }
    }

    func testHephaestusRejectsCertifiedSchematicsForDifferentEnvelopeSubject() throws {
        let package = try certifiedPackage()
        let foreign = HermesSubjectID(rawValue: "natal-spine.foreign")!
        let altered = HermesPackage(
            packageID: package.packageID,
            subjectID: foreign,
            sender: package.sender,
            kind: package.kind,
            addresses: package.addresses,
            contents: package.contents
        )!

        XCTAssertThrowsError(try Hephaestus.receiveNatalSpineSchematics(altered)) { error in
            XCTAssertEqual(error as? NatalSpineHephaestusFailure, .subjectMismatch)
        }
    }

    func testCertifiedIntakeCarriesAllThreeSeparateTitanTablesAndExactBounds() throws {
        let package = try certifiedPackage()
        let intake = try Hephaestus.receiveNatalSpineSchematics(package)

        XCTAssertEqual(intake.schematics.themis.bounds, intake.schematics.bounds)
        XCTAssertEqual(intake.schematics.oceanus.bounds, intake.schematics.bounds)
        XCTAssertEqual(intake.schematics.rhea.bounds, intake.schematics.bounds)
        XCTAssertFalse(intake.schematics.themis.spans.isEmpty)
        XCTAssertEqual(intake.schematics.oceanus.bodies.map(\.body), MundaneBody.canonicalOrder)
        XCTAssertEqual(intake.schematics.rhea.declaredCount, 0)
    }

    private func certifiedPackage() throws -> HermesPackage<AtroposNatalSpineSchematicsPackage> {
        let hestia = try NatalSpineTestFixture.litHestia()
        let truth = try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)
        let spans = MundaneBody.canonicalOrder.map {
            NatalSpineHouseSpan(
                body: $0,
                house: House(rawValue: 1)!,
                start: bounds.bone.start,
                end: bounds.bone.end
            )!
        }
        let themis = NatalSpineThemisTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            spans: spans
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
        return HermesPackage(
            packageID: HermesPackageID(),
            subjectID: truth.subjectID,
            sender: OrboOnboarding.orboAddress,
            kind: NatalSpineCommission.packageKind,
            addresses: NatalSpineCommission.itinerary,
            contents: certified
        )!
    }
}
