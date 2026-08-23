import XCTest
@testable import OrboCore

final class HallStage2Tests: XCTestCase {
    private func sealedResident(
        subject: String,
        degree: Int
    ) throws -> HallResident {
        let subjectID = try XCTUnwrap(HermesSubjectID(rawValue: subject))
        let rawValue = degree * Ring.arcsecondsPerDegree
        let rawSequence = Array(repeating: rawValue, count: AstroDNA.geneCount)
        let astroDNA = try XCTUnwrap(AstroDNA(rawSequence: rawSequence))
        let output = Clotho.gather(from: astroDNA)
        let grid = Lachesis.allot(output.packet, into: DegreeGrid())
        let tapestry = try Atropos.inspect(recipe: output.recipe, grid: grid).get()

        return HallResident(
            subjectID: subjectID,
            astroDNA: astroDNA,
            tapestry: tapestry
        )
    }

    func testFreshHallIsEmpty() {
        let hall = Hall()

        XCTAssertTrue(hall.residents.isEmpty)
    }

    func testDifferentSavedSubjectsMayBeAdmitted() throws {
        var hall = Hall()
        let first = try sealedResident(subject: "saved.one", degree: 1)
        let second = try sealedResident(subject: "saved.two", degree: 2)

        try hall.admit(first)
        try hall.admit(second)

        XCTAssertEqual(hall.residents, [first, second])
    }

    func testAdmissionPreservesSubjectAstroDNAAndExactTapestry() throws {
        var hall = Hall()
        let resident = try sealedResident(subject: "saved.one", degree: 3)

        try hall.admit(resident)
        let stored = try XCTUnwrap(hall.resident(for: resident.subjectID))

        XCTAssertEqual(stored.subjectID, resident.subjectID)
        XCTAssertEqual(stored.astroDNA, resident.astroDNA)
        XCTAssertEqual(stored.tapestry, resident.tapestry)
        XCTAssertEqual(stored, resident)
    }

    func testDuplicateSubjectIsRejected() throws {
        var hall = Hall()
        let first = try sealedResident(subject: "saved.one", degree: 4)
        let duplicate = try sealedResident(subject: "saved.one", degree: 5)

        try hall.admit(first)

        XCTAssertThrowsError(try hall.admit(duplicate)) { error in
            XCTAssertEqual(error as? Hall.Failure, .duplicateSubject)
        }
    }

    func testRejectedDuplicateLeavesExistingResidentUnchanged() throws {
        var hall = Hall()
        let first = try sealedResident(subject: "saved.one", degree: 6)
        let duplicate = try sealedResident(subject: "saved.one", degree: 7)

        try hall.admit(first)
        XCTAssertThrowsError(try hall.admit(duplicate))

        XCTAssertEqual(hall.residents, [first])
        XCTAssertEqual(hall.resident(for: first.subjectID), first)
    }

    func testAdmittingAnotherResidentDoesNotAlterExistingResident() throws {
        var hall = Hall()
        let first = try sealedResident(subject: "saved.one", degree: 8)
        let second = try sealedResident(subject: "saved.two", degree: 9)

        try hall.admit(first)
        try hall.admit(second)

        XCTAssertEqual(hall.resident(for: first.subjectID), first)
        XCTAssertEqual(hall.resident(for: second.subjectID), second)
    }

    func testResidentCanBeRetrievedBySubjectID() throws {
        var hall = Hall()
        let resident = try sealedResident(subject: "saved.one", degree: 10)
        let missing = try XCTUnwrap(HermesSubjectID(rawValue: "saved.missing"))

        try hall.admit(resident)

        XCTAssertEqual(hall.resident(for: resident.subjectID), resident)
        XCTAssertNil(hall.resident(for: missing))
    }
}
