import XCTest
@testable import OrboCore

final class NatalSpineActIBeat6RheaTests: XCTestCase {
    private struct PortStub: NatalSpineTimespinePort {
        func coordinate(
            of body: MundaneBody,
            at julianDay: JulianDay
        ) throws -> OrboSpineCelestialCoordinate {
            let degrees = (Double(body.rawValue) * 31.0 + 5.0).truncatingRemainder(dividingBy: 360)
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: OrboSpineDirectionalDegree(
                    physicalDegrees: degrees,
                    motion: .direct
                )!,
                julianDay: julianDay
            )
        }

        func occurrences(
            of body: MundaneBody,
            at directionalDegree: OrboSpineDirectionalDegree
        ) throws -> [OrboSpineCelestialCoordinate] {
            []
        }
    }

    func testRheaQualifiesExistingThemisAndOceanusFactsThroughCanonicalMater() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let crossingDay = JulianDay(bounds.bone.start.value + 10)!
        let ringDay = JulianDay(bounds.bone.start.value + 20)!
        let themis = makeThemisTable(bounds: bounds, crossingDay: crossingDay)
        let oceanus = try makeOceanusTable(truth: truth, bounds: bounds, ringDay: ringDay)
        let port = PortStub()

        let table = try Rhea.qualifyNatalSpine(
            native: truth,
            bounds: bounds,
            themis: themis,
            oceanus: oceanus,
            through: port
        )

        XCTAssertEqual(table.subjectID, truth.subjectID)
        XCTAssertEqual(table.bounds, bounds)
        XCTAssertEqual(table.declaredCount, table.qualifications.count)
        XCTAssertEqual(table.qualifications.count, 2)

        guard case let .houseCrossing(crossing) = table.qualifications[0].source else {
            return XCTFail("Expected Themis crossing first")
        }
        XCTAssertEqual(crossing.body, .sun)
        XCTAssertEqual(crossing.fromHouse.rawValue, 1)
        XCTAssertEqual(crossing.toHouse.rawValue, 2)
        XCTAssertEqual(crossing.occurrence, crossingDay)

        guard case let .ringRealization(realization) = table.qualifications[1].source else {
            return XCTFail("Expected Oceanus realization second")
        }
        XCTAssertEqual(realization.mundaneBody, .sun)
        XCTAssertEqual(realization.occurrence.julianDay, ringDay)

        let expectedCrossing = Rhea.bear(
            try longitudes(at: crossingDay, through: port),
            sect: truth.sect
        ).temper(for: .sun)
        let expectedRing = Rhea.bear(
            try longitudes(at: ringDay, through: port),
            sect: truth.sect
        ).temper(for: .sun)

        XCTAssertEqual(table.qualifications[0].temper, expectedCrossing)
        XCTAssertEqual(table.qualifications[1].temper, expectedRing)
        XCTAssertEqual(table.qualifications[0].temper.sectDay, truth.sect == .day)
        XCTAssertEqual(table.qualifications[0].temper.sectNight, truth.sect == .night)
    }

    func testRheaDoesNotInventMaterForTrueNodeFacts() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let crossingDay = JulianDay(bounds.bone.start.value + 10)!
        let nodeCrossing = JulianDay(bounds.bone.start.value + 12)!
        let themis = makeThemisTable(
            bounds: bounds,
            crossingDay: crossingDay,
            nodeCrossingDay: nodeCrossing
        )
        let oceanus = try makeOceanusTable(
            truth: truth,
            bounds: bounds,
            ringDay: JulianDay(bounds.bone.start.value + 20)!,
            includeNode: true
        )

        let table = try Rhea.qualifyNatalSpine(
            native: truth,
            bounds: bounds,
            themis: themis,
            oceanus: oceanus,
            through: PortStub()
        )

        XCTAssertFalse(table.qualifications.contains { $0.source.body == .trueNorthNode })
        XCTAssertTrue(table.qualifications.allSatisfy { $0.source.body.planet != nil })
    }

    func testRheaRejectsBrokenThemisAdjacencyInsteadOfInventingCrossing() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let start = bounds.bone.start
        let aEnd = JulianDay(start.value + 5)!
        let bStart = JulianDay(start.value + 6)!
        let end = JulianDay(start.value + 10)!
        let spans = [
            NatalSpineHouseSpan(body: .sun, house: House(rawValue: 1)!, start: start, end: aEnd)!,
            NatalSpineHouseSpan(body: .sun, house: House(rawValue: 2)!, start: bStart, end: end)!,
        ]
        let themis = NatalSpineThemisTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            spans: spans
        )
        let oceanus = NatalSpineOceanusTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            bodies: []
        )

        XCTAssertThrowsError(
            try Rhea.qualifyNatalSpine(
                native: truth,
                bounds: bounds,
                themis: themis,
                oceanus: oceanus,
                through: PortStub()
            )
        ) { error in
            XCTAssertEqual(error as? NatalSpineRheaFailure, .malformedThemisTable)
        }
    }

    func testRheaRejectsForeignTitanTables() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let foreign = HermesSubjectID(rawValue: "natal-spine.foreign")!
        let themis = NatalSpineThemisTable(
            subjectID: foreign,
            bounds: bounds,
            spans: []
        )
        let oceanus = NatalSpineOceanusTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            bodies: []
        )

        XCTAssertThrowsError(
            try Rhea.qualifyNatalSpine(
                native: truth,
                bounds: bounds,
                themis: themis,
                oceanus: oceanus,
                through: PortStub()
            )
        ) { error in
            XCTAssertEqual(error as? NatalSpineRheaFailure, .subjectMismatch)
        }
    }

    private func nativeTruth() throws -> NatalSpineNativeTruth {
        let hestia = try NatalSpineTestFixture.litHestia()
        return try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
    }

    private func makeThemisTable(
        bounds: NatalSpineBounds,
        crossingDay: JulianDay,
        nodeCrossingDay: JulianDay? = nil
    ) -> NatalSpineThemisTable {
        var spans: [NatalSpineHouseSpan] = [
            NatalSpineHouseSpan(
                body: .sun,
                house: House(rawValue: 1)!,
                start: bounds.bone.start,
                end: crossingDay
            )!,
            NatalSpineHouseSpan(
                body: .sun,
                house: House(rawValue: 2)!,
                start: crossingDay,
                end: bounds.bone.end
            )!,
        ]

        if let nodeCrossingDay {
            spans.append(
                NatalSpineHouseSpan(
                    body: .trueNorthNode,
                    house: House(rawValue: 3)!,
                    start: bounds.bone.start,
                    end: nodeCrossingDay
                )!
            )
            spans.append(
                NatalSpineHouseSpan(
                    body: .trueNorthNode,
                    house: House(rawValue: 4)!,
                    start: nodeCrossingDay,
                    end: bounds.bone.end
                )!
            )
        }

        return NatalSpineThemisTable(
            subjectID: bounds.subjectID,
            bounds: bounds,
            spans: spans
        )
    }

    private func makeOceanusTable(
        truth: NatalSpineNativeTruth,
        bounds: NatalSpineBounds,
        ringDay: JulianDay,
        includeNode: Bool = false
    ) throws -> NatalSpineOceanusTable {
        let ringValue = try XCTUnwrap(
            truth.tapestry.tapestry.degrees.flatMap(\.ring.values).first
        )
        let targetDegrees = Double(ringValue.targetArcsecond) / Double(Ring.arcsecondsPerDegree)
        let sunOccurrence = OrboSpineCelestialCoordinate(
            body: .sun,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: targetDegrees,
                motion: .direct
            )!,
            julianDay: ringDay
        )
        let sunRealization = try XCTUnwrap(
            NatalSpineRingRealization(
                mundaneBody: .sun,
                natalGene: ringValue.gene,
                natalSource: ringValue.source,
                relation: ringValue.mark,
                targetArcsecond: ringValue.targetArcsecond,
                occurrence: sunOccurrence
            )
        )
        var bodies = [NatalSpineOceanusBodyTable(body: .sun, realizations: [sunRealization])]

        if includeNode {
            let nodeDay = JulianDay(ringDay.value + 1)!
            let nodeOccurrence = OrboSpineCelestialCoordinate(
                body: .trueNorthNode,
                directionalDegree: OrboSpineDirectionalDegree(
                    physicalDegrees: targetDegrees,
                    motion: .retrograde
                )!,
                julianDay: nodeDay
            )
            let nodeRealization = try XCTUnwrap(
                NatalSpineRingRealization(
                    mundaneBody: .trueNorthNode,
                    natalGene: ringValue.gene,
                    natalSource: ringValue.source,
                    relation: ringValue.mark,
                    targetArcsecond: ringValue.targetArcsecond,
                    occurrence: nodeOccurrence
                )
            )
            bodies.append(
                NatalSpineOceanusBodyTable(
                    body: .trueNorthNode,
                    realizations: [nodeRealization]
                )
            )
        }

        return NatalSpineOceanusTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            bodies: bodies
        )
    }

    private func longitudes(
        at julianDay: JulianDay,
        through port: PortStub
    ) throws -> [Planet: CelestialLongitude] {
        Dictionary(uniqueKeysWithValues: try MundaneBody.canonicalOrder.compactMap { body in
            guard let planet = body.planet else { return nil }
            let coordinate = try port.coordinate(of: body, at: julianDay)
            return (
                planet,
                CelestialLongitude(coordinate.directionalDegree.physicalDegrees)!
            )
        })
    }
}
