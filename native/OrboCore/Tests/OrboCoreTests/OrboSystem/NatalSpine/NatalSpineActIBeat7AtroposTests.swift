import XCTest
@testable import OrboCore

final class NatalSpineActIBeat7AtroposTests: XCTestCase {
    func testAtroposCertifiesExactThreeTableSchematicWithoutMergingIt() throws {
        let fixture = try makeValidFixture()

        let result = Atropos.inspectNatalSpineSchematics(
            bounds: fixture.bounds,
            themis: fixture.themis,
            oceanus: fixture.oceanus,
            rhea: fixture.rhea
        )

        guard case let .success(package) = result else {
            return XCTFail("Expected Atropos to certify lawful Natal Spine schematics")
        }
        XCTAssertEqual(package.subjectID, fixture.bounds.subjectID)
        XCTAssertEqual(package.bounds, fixture.bounds)
        XCTAssertEqual(package.themis, fixture.themis)
        XCTAssertEqual(package.oceanus, fixture.oceanus)
        XCTAssertEqual(package.rhea, fixture.rhea)
    }

    func testAtroposRejectsAlteredTitanSubject() throws {
        let fixture = try makeValidFixture()
        let foreign = HermesSubjectID(rawValue: "natal-spine.foreign")!
        let altered = NatalSpineThemisTable(
            subjectID: foreign,
            bounds: fixture.bounds,
            spans: fixture.themis.spans
        )

        XCTAssertEqual(
            failure(
                Atropos.inspectNatalSpineSchematics(
                    bounds: fixture.bounds,
                    themis: altered,
                    oceanus: fixture.oceanus,
                    rhea: fixture.rhea
                )
            ),
            .subjectMismatch
        )
    }

    func testAtroposRejectsAlteredBounds() throws {
        let fixture = try makeValidFixture()
        let laterEnd = AbsoluteInstant(
            unixSecondsSince1970: fixture.bounds.end.unixSecondsSince1970 + 86_400
        )!
        let alteredBounds = NatalSpineBounds(
            subjectID: fixture.bounds.subjectID,
            start: fixture.bounds.start,
            natal: fixture.bounds.natal,
            end: laterEnd
        )!
        let altered = NatalSpineOceanusTable(
            subjectID: fixture.oceanus.subjectID,
            bounds: alteredBounds,
            bodies: fixture.oceanus.bodies
        )

        XCTAssertEqual(
            failure(
                Atropos.inspectNatalSpineSchematics(
                    bounds: fixture.bounds,
                    themis: fixture.themis,
                    oceanus: altered,
                    rhea: fixture.rhea
                )
            ),
            .boundsMismatch
        )
    }

    func testAtroposRejectsFalseThemisDeclaredCount() throws {
        let fixture = try makeValidFixture()
        let altered = NatalSpineThemisTable(
            subjectID: fixture.themis.subjectID,
            bounds: fixture.themis.bounds,
            spans: fixture.themis.spans,
            declaredCount: fixture.themis.spans.count + 1
        )

        XCTAssertEqual(
            failure(
                Atropos.inspectNatalSpineSchematics(
                    bounds: fixture.bounds,
                    themis: altered,
                    oceanus: fixture.oceanus,
                    rhea: fixture.rhea
                )
            ),
            .themisCountMismatch
        )
    }

    func testAtroposRejectsBrokenThemisCoverage() throws {
        let fixture = try makeValidFixture()
        var spans = fixture.themis.spans
        let sunIndex = try XCTUnwrap(spans.firstIndex(where: { $0.body == .sun }))
        spans.remove(at: sunIndex)
        let altered = NatalSpineThemisTable(
            subjectID: fixture.themis.subjectID,
            bounds: fixture.themis.bounds,
            spans: spans
        )

        XCTAssertEqual(
            failure(
                Atropos.inspectNatalSpineSchematics(
                    bounds: fixture.bounds,
                    themis: altered,
                    oceanus: fixture.oceanus,
                    rhea: fixture.rhea
                )
            ),
            .themisInvalidCoverage(.sun)
        )
    }

    func testAtroposRejectsFalseOceanusBodyAndTotalCounts() throws {
        let fixture = try makeValidFixture()
        var bodyTables = fixture.oceanus.bodies
        let sunIndex = try XCTUnwrap(bodyTables.firstIndex(where: { $0.body == .sun }))
        bodyTables[sunIndex] = NatalSpineOceanusBodyTable(
            body: .sun,
            realizations: bodyTables[sunIndex].realizations,
            declaredCount: 1
        )
        let alteredBodyCount = NatalSpineOceanusTable(
            subjectID: fixture.oceanus.subjectID,
            bounds: fixture.oceanus.bounds,
            bodies: bodyTables
        )

        XCTAssertEqual(
            failure(
                Atropos.inspectNatalSpineSchematics(
                    bounds: fixture.bounds,
                    themis: fixture.themis,
                    oceanus: alteredBodyCount,
                    rhea: fixture.rhea
                )
            ),
            .oceanusBodyCountMismatch(.sun)
        )

        let alteredTotal = NatalSpineOceanusTable(
            subjectID: fixture.oceanus.subjectID,
            bounds: fixture.oceanus.bounds,
            bodies: fixture.oceanus.bodies,
            declaredCount: 1
        )
        XCTAssertEqual(
            failure(
                Atropos.inspectNatalSpineSchematics(
                    bounds: fixture.bounds,
                    themis: fixture.themis,
                    oceanus: alteredTotal,
                    rhea: fixture.rhea
                )
            ),
            .oceanusCountMismatch
        )
    }

    func testAtroposRejectsOrphanRheaQualification() throws {
        let fixture = try makeValidFixture(includeLawfulRhea: false)
        let orphanDay = JulianDay(fixture.bounds.bone.start.value + 7)!
        let orphan = NatalSpineHouseCrossing(
            body: .sun,
            fromHouse: House(rawValue: 1)!,
            toHouse: House(rawValue: 2)!,
            occurrence: orphanDay
        )!
        let field = Rhea.bear(sampleLongitudes(), sect: .day)
        let qualification = NatalSpineMaterQualification(
            source: .houseCrossing(orphan),
            temper: field.temper(for: .sun)
        )!
        let altered = NatalSpineRheaTable(
            subjectID: fixture.rhea.subjectID,
            bounds: fixture.rhea.bounds,
            qualifications: [qualification]
        )

        XCTAssertEqual(
            failure(
                Atropos.inspectNatalSpineSchematics(
                    bounds: fixture.bounds,
                    themis: fixture.themis,
                    oceanus: fixture.oceanus,
                    rhea: altered
                )
            ),
            .rheaOrphanQualification
        )
    }

    func testAtroposRejectsFalseRheaDeclaredCount() throws {
        let fixture = try makeValidFixture()
        let altered = NatalSpineRheaTable(
            subjectID: fixture.rhea.subjectID,
            bounds: fixture.rhea.bounds,
            qualifications: fixture.rhea.qualifications,
            declaredCount: fixture.rhea.qualifications.count + 1
        )

        XCTAssertEqual(
            failure(
                Atropos.inspectNatalSpineSchematics(
                    bounds: fixture.bounds,
                    themis: fixture.themis,
                    oceanus: fixture.oceanus,
                    rhea: altered
                )
            ),
            .rheaCountMismatch
        )
    }

    private struct Fixture {
        let bounds: NatalSpineBounds
        let themis: NatalSpineThemisTable
        let oceanus: NatalSpineOceanusTable
        let rhea: NatalSpineRheaTable
    }

    private func makeValidFixture(includeLawfulRhea: Bool = true) throws -> Fixture {
        let truth = try NatalSpineTestFixture
            .litHestia()
            .natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)
        let crossingDay = JulianDay(bounds.bone.start.value + 10)!

        var spans: [NatalSpineHouseSpan] = []
        for body in MundaneBody.canonicalOrder {
            if body == .sun {
                spans.append(
                    NatalSpineHouseSpan(
                        body: body,
                        house: House(rawValue: 1)!,
                        start: bounds.bone.start,
                        end: crossingDay
                    )!
                )
                spans.append(
                    NatalSpineHouseSpan(
                        body: body,
                        house: House(rawValue: 2)!,
                        start: crossingDay,
                        end: bounds.bone.end
                    )!
                )
            } else {
                spans.append(
                    NatalSpineHouseSpan(
                        body: body,
                        house: House(rawValue: 1)!,
                        start: bounds.bone.start,
                        end: bounds.bone.end
                    )!
                )
            }
        }
        let themis = NatalSpineThemisTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            spans: spans
        )

        let bodies = MundaneBody.canonicalOrder.map {
            NatalSpineOceanusBodyTable(body: $0, realizations: [])
        }
        let oceanus = NatalSpineOceanusTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            bodies: bodies
        )

        var qualifications: [NatalSpineMaterQualification] = []
        if includeLawfulRhea {
            let crossing = NatalSpineHouseCrossing(
                body: .sun,
                fromHouse: House(rawValue: 1)!,
                toHouse: House(rawValue: 2)!,
                occurrence: crossingDay
            )!
            qualifications.append(
                NatalSpineMaterQualification(
                    source: .houseCrossing(crossing),
                    temper: Rhea.bear(sampleLongitudes(), sect: truth.sect).temper(for: .sun)
                )!
            )
        }
        let rhea = NatalSpineRheaTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            qualifications: qualifications
        )

        return Fixture(bounds: bounds, themis: themis, oceanus: oceanus, rhea: rhea)
    }

    private func sampleLongitudes() -> [Planet: CelestialLongitude] {
        Dictionary(uniqueKeysWithValues: Planet.canonicalOrder.enumerated().map { index, planet in
            (planet, CelestialLongitude(Double(index * 31 + 5))!)
        })
    }

    private func failure(
        _ result: Result<AtroposNatalSpineSchematicsPackage, AtroposNatalSpineFailure>
    ) -> AtroposNatalSpineFailure? {
        guard case let .failure(error) = result else { return nil }
        return error
    }
}
