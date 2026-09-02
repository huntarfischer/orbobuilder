import XCTest
@testable import OrboCore
@testable import OrboIris

final class HecateHomerPortTests: XCTestCase {
    func testCanonicalHecateInquiryTravelsThroughHomerAndIrisUnchanged() throws {
        let inquiry = try XCTUnwrap(Hecate.inquire(KleisID(rawValue: "Fortune")!))

        let homerPort = Hecate.signalForHomer(inquiry)
        let irisPort = Homer.POV(homerPort)
        let frame = IrisHomerFrame(port: irisPort)

        XCTAssertEqual(homerPort.pointOfView, inquiry)
        XCTAssertEqual(irisPort.signal, inquiry)
        XCTAssertEqual(frame.pointOfView, inquiry)
    }

    func testHomerPathPreservesHecateFormulaAndProvenanceMatterExactly() throws {
        let inquiry = try XCTUnwrap(
            Hecate.inquire(KleisID(rawValue: "parts.natal.house07.sonsInLaw")!)
        )
        let frame = IrisHomerFrame(port: Homer.POV(Hecate.signalForHomer(inquiry)))
        let formula = try XCTUnwrap(frame.pointOfView.formulas.first)

        XCTAssertEqual(frame.pointOfView.kleis, inquiry.kleis)
        XCTAssertEqual(frame.pointOfView.sourceLabel, inquiry.sourceLabel)
        XCTAssertEqual(frame.pointOfView.natalDivision, inquiry.natalDivision)
        XCTAssertEqual(frame.pointOfView.houseCategory, inquiry.houseCategory)
        XCTAssertEqual(formula, inquiry.formulas.first)
        XCTAssertEqual(formula.dayCalculation, "Asc + Venus - Saturn")
        XCTAssertEqual(formula.nightCalculation, "Asc + Saturn - Venus")
        XCTAssertEqual(formula.sourceSectMark, .reverse)
    }

    func testSuccessiveHecatePOVsRemainIndependentSnapshots() throws {
        let fortune = try XCTUnwrap(Hecate.inquire(KleisID(rawValue: "Fortune")!))
        let spirit = try XCTUnwrap(Hecate.inquire(KleisID(rawValue: "Spirit")!))

        let fortuneFrame = IrisHomerFrame(port: Homer.POV(Hecate.signalForHomer(fortune)))
        let spiritFrame = IrisHomerFrame(port: Homer.POV(Hecate.signalForHomer(spirit)))

        XCTAssertEqual(fortuneFrame.pointOfView.kleis.id.rawValue, "Fortune")
        XCTAssertEqual(spiritFrame.pointOfView.kleis.id.rawValue, "Spirit")
        XCTAssertNotEqual(fortuneFrame.pointOfView, spiritFrame.pointOfView)
    }

    func testHecateAuthorsTheAnswerBeforeHomerReceivesIt() throws {
        let inquiry = try XCTUnwrap(Hecate.inquire(KleisID(rawValue: "Fortune")!))

        let port = Hecate.signalForHomer(inquiry)

        XCTAssertEqual(port.pointOfView, inquiry)
        XCTAssertEqual(port.pointOfView.kleis.id.rawValue, "Fortune")
        XCTAssertEqual(port.pointOfView.kleis.family, .lots)
        XCTAssertEqual(port.pointOfView.kleis.context, .natal)
    }
}
