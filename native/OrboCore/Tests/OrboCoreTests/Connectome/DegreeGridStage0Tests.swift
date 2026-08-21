import XCTest
@testable import OrboCore

final class DegreeGridStage0Tests: XCTestCase {
    func testDegreeAddressAcceptsOnlyZeroThrough359() {
        XCTAssertNil(DegreeAddress(rawValue: -1))
        XCTAssertNotNil(DegreeAddress(rawValue: 0))
        XCTAssertNotNil(DegreeAddress(rawValue: 359))
        XCTAssertNil(DegreeAddress(rawValue: 360))
    }

    func testCanonicalOrderIsExactlyZeroThrough359() {
        let addresses = DegreeAddress.canonicalOrder
        XCTAssertEqual(addresses.count, 360)
        XCTAssertEqual(addresses.map(\.rawValue), Array(0..<360))
        XCTAssertEqual(Set(addresses).count, 360)
    }

    func testDegreeGridContainsExactlyOneCellAtEveryAddress() {
        let grid = DegreeGrid()
        XCTAssertEqual(grid.cells.count, 360)
        XCTAssertEqual(grid.cells.map(\.address), DegreeAddress.canonicalOrder)
        XCTAssertEqual(Set(grid.cells.map(\.address)).count, 360)
    }

    func testDegreeCellStartsWithOnlyItsAddressAndNoThreads() {
        let cell = DegreeCell(address: DegreeAddress(rawValue: 127)!)
        XCTAssertEqual(cell.address.rawValue, 127)
        XCTAssertTrue(cell.threads.isEmpty)
    }

    func testFreshDegreeGridHasNoAllottedThreads() {
        let grid = DegreeGrid()
        XCTAssertTrue(grid.cells.allSatisfy { $0.threads.isEmpty })
    }
}
