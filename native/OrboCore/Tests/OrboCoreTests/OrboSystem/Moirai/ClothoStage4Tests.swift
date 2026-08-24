import XCTest
@testable import OrboCore

final class ClothoStage4Tests: XCTestCase {
    private struct NatalPosition {
        let degree: Int
        let minute: Int
        let second: Int
        let retrograde: Bool

        var rawValue: Int {
            var value = degree * Ring.arcsecondsPerDegree + minute * 60 + second
            if retrograde {
                value += Ring.arcseconds
            }
            return value
        }
    }

    private struct PortISpy: ClothoPortI {
        struct Call: Equatable {
            let subjectID: HermesSubjectID
            let birthDate: CivilDate
            let birthTime: CivilClockTime
            let topos: Topos
        }

        var nodes: [AstroDNAGene: RingFineState]
        var calls: [Call] = []

        mutating func natalTap(
            subjectID: HermesSubjectID,
            birthDate: CivilDate,
            birthTime: CivilClockTime,
            topos: Topos
        ) throws -> [AstroDNAGene: RingFineState] {
            calls.append(
                Call(
                    subjectID: subjectID,
                    birthDate: birthDate,
                    birthTime: birthTime,
                    topos: topos
                )
            )
            return nodes
        }
    }

    private let subjectID = HermesSubjectID(rawValue: "subject.native")!
    private let birthDate = CivilDate(year: 1985, month: 4, day: 10)!
    private let birthTime = CivilClockTime(hour: 20, minute: 16)!

    private let natalPositions: [AstroDNAGene: NatalPosition] = [
        .ascendant: NatalPosition(degree: 221, minute: 29, second: 37, retrograde: false),
        .moon: NatalPosition(degree: 277, minute: 34, second: 12, retrograde: false),
        .sun: NatalPosition(degree: 21, minute: 8, second: 19, retrograde: false),
        .mercury: NatalPosition(degree: 8, minute: 20, second: 41, retrograde: true),
        .venus: NatalPosition(degree: 9, minute: 49, second: 22, retrograde: true),
        .mars: NatalPosition(degree: 49, minute: 16, second: 5, retrograde: false),
        .jupiter: NatalPosition(degree: 312, minute: 33, second: 44, retrograde: false),
        .saturn: NatalPosition(degree: 237, minute: 9, second: 17, retrograde: true),
        .uranus: NatalPosition(degree: 257, minute: 49, second: 31, retrograde: true),
        .neptune: NatalPosition(degree: 273, minute: 36, second: 26, retrograde: true),
        .pluto: NatalPosition(degree: 213, minute: 42, second: 14, retrograde: true),
        .northNode: NatalPosition(degree: 49, minute: 50, second: 53, retrograde: true),
    ]

    func testClothoChoosesEngravingPatternAndMakesOneNatalTap() throws {
        let engraving = try resolvedEngraving()
        let expectedTopos = try XCTUnwrap(engraving.topos)
        var portI = PortISpy(nodes: try nodeStates())

        let output = try Clotho.spin(engraving, through: &portI)

        XCTAssertEqual(output.pattern, .engraving)
        XCTAssertEqual(output.pattern.spanYears, 100)
        XCTAssertEqual(portI.calls.count, 1)
        XCTAssertEqual(portI.calls.first?.subjectID, subjectID)
        XCTAssertEqual(portI.calls.first?.birthDate, birthDate)
        XCTAssertEqual(portI.calls.first?.birthTime, birthTime)
        XCTAssertEqual(portI.calls.first?.topos, expectedTopos)
    }

    func testClothoSpinsTwelveNatalNodesIntoAstroDNAAndResolvesOnlyAstroDNA() throws {
        let engraving = try resolvedEngraving()
        let originalTopos = try XCTUnwrap(engraving.topos)
        var portI = PortISpy(nodes: try nodeStates())

        let output = try Clotho.spin(engraving, through: &portI)
        let resolvedDNA = try XCTUnwrap(output.engraving.astroDNA)

        XCTAssertEqual(output.threads, resolvedDNA)
        XCTAssertEqual(output.threads.sequence.count, AstroDNA.geneCount)
        XCTAssertEqual(output.engraving.subjectID, engraving.subjectID)
        XCTAssertEqual(output.engraving.name, engraving.name)
        XCTAssertEqual(output.engraving.birthDate, engraving.birthDate)
        XCTAssertEqual(output.engraving.birthTime, engraving.birthTime)
        XCTAssertEqual(output.engraving.birthLocation, engraving.birthLocation)
        XCTAssertEqual(output.engraving.topos, originalTopos)
        XCTAssertNil(output.engraving.tapestry)
        XCTAssertFalse(output.engraving.engraved)

        for gene in AstroDNAGene.canonicalOrder {
            XCTAssertEqual(output.threads[gene], portI.nodes[gene])
        }
    }

    func testClothoPreservesArcsecondPrecisionAndRetrogradeState() throws {
        let engraving = try resolvedEngraving()
        var portI = PortISpy(nodes: try nodeStates())

        let output = try Clotho.spin(engraving, through: &portI)

        XCTAssertEqual(output.threads[.ascendant].dms.second, 37)
        XCTAssertEqual(output.threads[.mercury].dms.second, 41)
        XCTAssertTrue(output.threads[.mercury].isRetrograde)
        XCTAssertTrue(output.threads[.northNode].isRetrograde)
    }

    func testClothoRefusesEngravingWithoutToposBeforeTappingPortI() throws {
        let engraving = unfinishedEngraving()
        var portI = PortISpy(nodes: try nodeStates())

        XCTAssertThrowsError(try Clotho.spin(engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .unresolvedTopos)
        }
        XCTAssertTrue(portI.calls.isEmpty)
    }

    func testClothoRefusesToOverwriteResolvedAstroDNABeforeAnotherTap() throws {
        let engraving = try resolvedEngraving()
        var portI = PortISpy(nodes: try nodeStates())
        let first = try Clotho.spin(engraving, through: &portI)

        XCTAssertThrowsError(try Clotho.spin(first.engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .astroDNAAlreadyResolved)
        }
        XCTAssertEqual(portI.calls.count, 1)
    }

    func testClothoRejectsIncompleteNatalNodeSet() throws {
        let engraving = try resolvedEngraving()
        var nodes = try nodeStates()
        nodes.removeValue(forKey: .pluto)
        var portI = PortISpy(nodes: nodes)

        XCTAssertThrowsError(try Clotho.spin(engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .missingNatalGene(.pluto))
        }
        XCTAssertEqual(portI.calls.count, 1)
    }

    func testClothoRejectsNodeStatesThatCannotFormValidAstroDNA() throws {
        let engraving = try resolvedEngraving()
        var nodes = try nodeStates()
        let ascendant = try XCTUnwrap(natalPositions[.ascendant])
        nodes[.ascendant] = try XCTUnwrap(RingFineState(ascendant.rawValue + Ring.arcseconds))
        var portI = PortISpy(nodes: nodes)

        XCTAssertThrowsError(try Clotho.spin(engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .invalidAstroDNA)
        }
        XCTAssertEqual(portI.calls.count, 1)
    }

    private func unfinishedEngraving() -> Engraving {
        OrboOnboarding.complete(
            subjectID: subjectID,
            name: "Ean",
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: "Madison, WI"
        ).contents
    }

    private func resolvedEngraving() throws -> Engraving {
        let engraving = unfinishedEngraving()
        guard case let .found(topos) = Atlas().resolve(engraving.birthLocation) else {
            XCTFail("Expected Atlas to resolve Madison")
            throw TestError.unexpectedAtlasResolution
        }
        return engraving.resolving(topos: topos)
    }

    private func nodeStates(
        overrides: [AstroDNAGene: NatalPosition] = [:]
    ) throws -> [AstroDNAGene: RingFineState] {
        Dictionary(
            uniqueKeysWithValues: try AstroDNAGene.canonicalOrder.map { gene in
                let position = try XCTUnwrap(overrides[gene] ?? natalPositions[gene])
                let state = try XCTUnwrap(RingFineState(position.rawValue))
                return (gene, state)
            }
        )
    }

    private enum TestError: Error {
        case unexpectedAtlasResolution
    }
}
