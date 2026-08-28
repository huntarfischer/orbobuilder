import XCTest
@testable import OrboCore

final class LachesisStage8D0Tests: XCTestCase {
    func testFreshTapestryContainsExactly360Degrees() {
        let tapestry = Tapestry()

        XCTAssertEqual(tapestry.degrees.count, DegreeAddress.count)
    }

    func testFreshTapestryUsesCanonicalDegreeAddresses() {
        let tapestry = Tapestry()
        let addresses = tapestry.degrees.map(\.address)

        XCTAssertEqual(addresses, DegreeAddress.canonicalOrder)
        XCTAssertEqual(Set(addresses).count, DegreeAddress.count)
    }

    func testEveryDegreeCarriesAllFiveDistinctSubsections() {
        let degree = Tapestry().degrees[0]

        XCTAssertTrue(degree.placement.isEmpty)
        XCTAssertTrue(degree.tympan.isEmpty)
        XCTAssertTrue(degree.mater.isEmpty)
        XCTAssertTrue(degree.ring.isEmpty)
        XCTAssertTrue(degree.arc.isEmpty)
    }

    func testEveryFreshSubsectionIsEmptyAcrossAll360Degrees() {
        let tapestry = Tapestry()

        XCTAssertTrue(tapestry.degrees.allSatisfy { degree in
            degree.placement.isEmpty
                && degree.tympan.isEmpty
                && degree.mater.isEmpty
                && degree.ring.isEmpty
                && degree.arc.isEmpty
        })
    }

    func testFreshTapestryConstructionIsDeterministic() {
        XCTAssertEqual(Tapestry(), Tapestry())
    }
}
