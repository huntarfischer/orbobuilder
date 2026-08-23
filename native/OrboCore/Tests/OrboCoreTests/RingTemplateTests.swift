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

    func testFineApplicationCarriesMinutesAndSecondsThroughEveryMarkedCell() throws {
        let template = try XCTUnwrap(Ring.template(forDegree: 7))
        let sourceArcsecond = 7 * Ring.arcsecondsPerDegree + 34 * 60 + 12
        let source = try XCTUnwrap(RingFineState(sourceArcsecond))
        let marks = try XCTUnwrap(template.exactMarks(for: source))

        XCTAssertEqual(marks.count, 20)
        XCTAssertTrue(marks.allSatisfy { $0.dms.minute == 34 && $0.dms.second == 12 })

        XCTAssertTrue(marks.contains { $0.mark == .conjunction && $0.dms == RingDMS(degree: 7, minute: 34, second: 12) })
        XCTAssertTrue(marks.contains { $0.mark == .square && $0.dms == RingDMS(degree: 97, minute: 34, second: 12) })
        XCTAssertTrue(marks.contains { $0.mark == .square && $0.dms == RingDMS(degree: 277, minute: 34, second: 12) })
        XCTAssertTrue(marks.contains { $0.mark == .opposition && $0.dms == RingDMS(degree: 187, minute: 34, second: 12) })
    }

    func testFineApplicationWrapsAtTheEndOfTheCircle() throws {
        let template = try XCTUnwrap(Ring.template(forDegree: 359))
        let sourceArcsecond = 359 * Ring.arcsecondsPerDegree + 59 * 60 + 59
        let source = try XCTUnwrap(RingFineState(sourceArcsecond))
        let marks = try XCTUnwrap(template.exactMarks(for: source))

        XCTAssertTrue(marks.contains { $0.mark == .conjunction && $0.dms == RingDMS(degree: 359, minute: 59, second: 59) })
        XCTAssertTrue(marks.contains { $0.mark == .semisextile && $0.dms == RingDMS(degree: 29, minute: 59, second: 59) })
        XCTAssertTrue(marks.contains { $0.mark == .square && $0.dms == RingDMS(degree: 89, minute: 59, second: 59) })
        XCTAssertTrue(marks.contains { $0.mark == .opposition && $0.dms == RingDMS(degree: 179, minute: 59, second: 59) })
    }

    func testFineApplicationRejectsWrongTemplateAndIgnoresMotionForGeometry() throws {
        let template = try XCTUnwrap(Ring.template(forDegree: 7))
        let offset = 34 * 60 + 12
        let direct = try XCTUnwrap(RingFineState(7 * Ring.arcsecondsPerDegree + offset))
        let retrograde = try XCTUnwrap(RingFineState(Ring.arcseconds + 7 * Ring.arcsecondsPerDegree + offset))
        let wrongDegree = try XCTUnwrap(RingFineState(8 * Ring.arcsecondsPerDegree + offset))

        XCTAssertEqual(template.exactMarks(for: direct), template.exactMarks(for: retrograde))
        XCTAssertNil(template.exactMarks(for: wrongDegree))
    }

    func testVenusObjectTemplatePreservesIdentitySourceAndMotion() throws {
        let template = try XCTUnwrap(Ring.template(forDegree: 7))
        let offset = 34 * 60 + 12
        let source = try XCTUnwrap(
            RingFineState(Ring.arcseconds + 7 * Ring.arcsecondsPerDegree + offset)
        )
        let object = try XCTUnwrap(template.objectTemplate(for: .venus, source: source))

        XCTAssertEqual(object.name, "VenusRingTemplate")
        XCTAssertEqual(object.gene, .venus)
        XCTAssertEqual(object.source, source)
        XCTAssertEqual(object.sourceDMS, RingDMS(degree: 7, minute: 34, second: 12))
        XCTAssertEqual(object.motion, .retrograde)
        XCTAssertEqual(object.template.sourceDegree, 7)
        XCTAssertEqual(object.marks, try XCTUnwrap(template.exactMarks(for: source)))
    }

    func testObjectTemplateNameUsesCanonicalAstroDNAGeneIdentity() throws {
        let template = try XCTUnwrap(Ring.template(forDegree: 7))
        let source = try XCTUnwrap(RingFineState(7 * Ring.arcsecondsPerDegree))

        XCTAssertEqual(
            try XCTUnwrap(template.objectTemplate(for: .venus, source: source)).name,
            "VenusRingTemplate"
        )
        XCTAssertEqual(
            try XCTUnwrap(template.objectTemplate(for: .northNode, source: source)).name,
            "NorthNodeRingTemplate"
        )
    }

    func testObjectTemplateRejectsSourceFromAnotherDegree() throws {
        let template = try XCTUnwrap(Ring.template(forDegree: 7))
        let source = try XCTUnwrap(RingFineState(8 * Ring.arcsecondsPerDegree + 1))

        XCTAssertNil(template.objectTemplate(for: .venus, source: source))
    }
}
