import XCTest
@testable import OrboCore

final class DegreeAddressTests: XCTestCase {
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
}
