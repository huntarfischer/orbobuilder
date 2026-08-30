import XCTest
@testable import OrboCore

final class PythiaPassATests: XCTestCase {
    func testPythiaExistsAndGovernsTimingTechniques() {
        XCTAssertEqual(Pythia.governedDomain, .timingTechniques)
    }
}
