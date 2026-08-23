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

    func testRingOwnsExactlyOneTemplateForEveryDegree() throws {
        XCTAssertEqual(Ring.templates.count, Ring.degrees)
        XCTAssertEqual(Ring.templates.map(\.sourceDegree), Array(0..<Ring.degrees))
        XCTAssertEqual(try XCTUnwrap(Ring.template(forDegree: 7)).sourceDegree, 7)
        XCTAssertNil(Ring.template(forDegree: -1))
        XCTAssertNil(Ring.template(forDegree: 360))
    }

    func testTemplateSevenCoversAll360CellsAndMarksCanonicalTargets() throws {
        let template = try XCTUnwrap(Ring.template(forDegree: 7))
        XCTAssertEqual(template.cells.count, Ring.degrees)
        XCTAssertEqual(template.cells.map(\.degree), Array(0..<Ring.degrees))

        XCTAssertEqual(template[7]?.mark, .conjunction)
        XCTAssertEqual(template[37]?.mark, .semisextile)
        XCTAssertEqual(template[337]?.mark, .semisextile)
        XCTAssertEqual(template[97]?.mark, .square)
        XCTAssertEqual(template[277]?.mark, .square)
        XCTAssertEqual(template[187]?.mark, .opposition)
        XCTAssertNil(template[98]?.mark)
    }

    func testEveryTemplateCellMatchesExistingRingGeometry() {
        for template in Ring.templates {
            let source = RingState(unchecked: template.sourceDegree)
            for cell in template.cells {
                let target = RingState(unchecked: cell.degree)
                XCTAssertEqual(
                    cell.mark,
                    Ring.relation(between: source, and: target),
                    "template \(template.sourceDegree), cell \(cell.degree)"
                )
            }
        }
    }
}
