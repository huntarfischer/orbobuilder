import XCTest
@testable import OrboCore

final class ClothoStage8ATests: XCTestCase {
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
        var nodes: [AstroDNAGene: RingFineState]
        var callCount = 0

        mutating func queryNatalState(
            birthDate: CivilDate,
            birthTime: CivilClockTime,
            topos: Topos
        ) throws -> [AstroDNAGene: RingFineState] {
            callCount += 1
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

    func testClothoCarriesTheCanonicalHecateAstroDNACastForward() throws {
        let nodes = try nodeStates()
        let expectedAstroDNA = try Hecate.castAstroDNA(using: nodes)
        var portI = PortISpy(nodes: nodes)

        let output = try Clotho.spin(try resolvedEngraving(), through: &portI)

        XCTAssertEqual(portI.callCount, 1)
        XCTAssertEqual(output.packet.pattern, .engraving)
        XCTAssertEqual(output.packet.astroDNA, expectedAstroDNA)
        XCTAssertEqual(output.engraving.astroDNA, expectedAstroDNA)
    }

    func testClothoMapsFailedHecateAstroDNACastToExistingFailure() throws {
        var nodes = try nodeStates()
        let ascendant = try XCTUnwrap(natalPositions[.ascendant])
        nodes[.ascendant] = try XCTUnwrap(
            RingFineState(ascendant.rawValue + Ring.arcseconds)
        )

        XCTAssertThrowsError(try Hecate.castAstroDNA(using: nodes))

        var portI = PortISpy(nodes: nodes)
        XCTAssertThrowsError(try Clotho.spin(try resolvedEngraving(), through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .invalidAstroDNA)
        }
        XCTAssertEqual(portI.callCount, 1)
    }

    private func resolvedEngraving() throws -> Engraving {
        let engraving = OrboOnboarding.complete(
            subjectID: subjectID,
            name: "Ean",
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: "Madison, WI"
        ).contents

        guard case let .found(topos) = Atlas().resolve(engraving.birthLocation) else {
            XCTFail("Expected Atlas to resolve Madison")
            throw TestError.unexpectedAtlasResolution
        }
        return engraving.resolving(topos: topos)
    }

    private func nodeStates() throws -> [AstroDNAGene: RingFineState] {
        Dictionary(
            uniqueKeysWithValues: try AstroDNAGene.canonicalOrder.map { gene in
                let position = try XCTUnwrap(natalPositions[gene])
                let state = try XCTUnwrap(RingFineState(position.rawValue))
                return (gene, state)
            }
        )
    }

    private enum TestError: Error {
        case unexpectedAtlasResolution
    }
}
