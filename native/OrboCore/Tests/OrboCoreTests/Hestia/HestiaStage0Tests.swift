import XCTest
@testable import OrboCore

final class HestiaStage0Tests: XCTestCase {
    private func sealedTapestry() throws -> (AstroDNA, AtroposPackage) {
        let rawSequence = Array(repeating: 0, count: AstroDNA.geneCount)
        let natalAstroDNA = try XCTUnwrap(AstroDNA(rawSequence: rawSequence))
        let output = Clotho.gather(from: natalAstroDNA)
        let grid = Lachesis.allot(output.packet, into: DegreeGrid())
        let tapestry = try Atropos.inspect(recipe: output.recipe, grid: grid).get()
        return (natalAstroDNA, tapestry)
    }

    func testHearthResidentPreservesSubjectAstroDNAAndExactTapestry() throws {
        let subjectID = try XCTUnwrap(HermesSubjectID(rawValue: "native"))
        let (astroDNA, tapestry) = try sealedTapestry()

        let resident = HearthResident(
            subjectID: subjectID,
            astroDNA: astroDNA,
            tapestry: tapestry
        )

        XCTAssertEqual(resident.subjectID, subjectID)
        XCTAssertEqual(resident.astroDNA, astroDNA)
        XCTAssertEqual(resident.tapestry, tapestry)
    }

    func testHallResidentPreservesSubjectAndExactTapestry() throws {
        let subjectID = try XCTUnwrap(HermesSubjectID(rawValue: "saved-person"))
        let (_, tapestry) = try sealedTapestry()

        let resident = HallResident(
            subjectID: subjectID,
            tapestry: tapestry
        )

        XCTAssertEqual(resident.subjectID, subjectID)
        XCTAssertEqual(resident.tapestry, tapestry)
    }
}
