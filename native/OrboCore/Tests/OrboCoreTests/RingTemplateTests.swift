import XCTest
@testable import OrboCore

final class RingTemplateTests: XCTestCase {
    func testTemplateSevenRepresentsItsHalfOpenDegreeInterval() throws {
        let template = try XCTUnwrap(RingTemplate(7))
        XCTAssertEqual(template.sourceDegree, 7)
        XCTAssertEqual(template.interval, 7..<8)
    }

    func testTemplateAcceptsOnlyRingDegrees() {
        XCTAssertNotNil(RingTemplate(0))
        XCTAssertNotNil(RingTemplate(359))
        XCTAssertNil(RingTemplate(-1))
        XCTAssertNil(RingTemplate(360))
    }
}
