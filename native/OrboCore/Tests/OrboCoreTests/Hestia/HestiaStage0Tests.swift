import XCTest
@testable import OrboCore

final class HestiaStage0Tests: XCTestCase {
    private func sealedTapestry() throws -> AtroposPackage {
        let rawSequence = Array(repeating: 0, count: AstroDNA.geneCount)
        let natalAstroDNA = try XCTUnwrap(AstroDNA(rawSequence: rawSequence))
        let output = Clotho.gather(from: natalAstroDNA)
        let grid = Lachesis.allot(output.packet, into: DegreeGrid())
        return try Atropos.inspect(recipe: output.recipe, grid: grid).get()
    }

    func testHearthResidentPreservesSubjectAndExactTapestry() throws {
        let subjectID = try XCTUnwrap(HermesSubjectID(rawValue: "native"))
        let tapestry = try sealedTapestry()

        let resident = HearthResident(
            subjectID: subjectID,
            tapestry: tapestry
        )

        XCTAssertEqual(resident.subjectID, subjectID)
        XCTAssertEqual(resident.tapestry, tapestry)
    }

    func testHallResidentPreservesSubjectAndExactTapestry() throws {
        let subjectID = try XCTUnwrap(HermesSubjectID(rawValue: "saved-person"))
        let tapestry = try sealedTapestry()

        let resident = HallResident(
            subjectID: subjectID,
            tapestry: tapestry
        )

        XCTAssertEqual(resident.subjectID, subjectID)
        XCTAssertEqual(resident.tapestry, tapestry)
    }
}
