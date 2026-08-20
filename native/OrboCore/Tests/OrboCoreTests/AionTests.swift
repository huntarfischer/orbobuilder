import XCTest
@testable import OrboCore

final class AionTests: XCTestCase {
    func testResolveUsesIndependentShellSignClocks() throws {
        let aion = Aion(index: try makeIndex())
        let state = try aion.resolve(at: JulianDay(120)!)

        XCTAssertEqual(state.frame.shellSignID, "F1.01")
        XCTAssertEqual(state.revolt.shellSignID, "R2.01")
        XCTAssertEqual(state.wave.shellSignID, "W3.03")
        XCTAssertEqual(state.zeitgeist.shellSignID, "Z4.01")
        XCTAssertEqual(state.shellAddress, "F1.R2.W3.Z4")
        XCTAssertEqual(state.shellSignAddress, "F1.01.R2.01.W3.03.Z4.01")
        XCTAssertEqual(state.wave.sign, .gemini)
        XCTAssertEqual(state.wave.progress, 0.2, accuracy: 1e-12)
    }

    func testHalfOpenBoundaryMovesToNextSegment() throws {
        let first = segment(
            family: .frame,
            shellOrdinal: 1,
            sign: .aries,
            start: 100,
            end: 150,
            crossings: [(100, .direct)]
        )
        let second = segment(
            family: .frame,
            shellOrdinal: 1,
            sign: .taurus,
            start: 150,
            end: 200,
            crossings: [(150, .direct)]
        )
        let index = try AionIndex(
            supportedStart: JulianDay(100)!,
            supportedEnd: JulianDay(200)!,
            rowsByFamily: [
                .frame: [first, second],
                .revolt: [segment(family: .revolt, shellOrdinal: 2, sign: .aries, start: 100, end: 200, crossings: [(100, .direct)])],
                .wave: [segment(family: .wave, shellOrdinal: 3, sign: .aries, start: 100, end: 200, crossings: [(100, .direct)])],
                .zeitgeist: [segment(family: .zeitgeist, shellOrdinal: 4, sign: .aries, start: 100, end: 200, crossings: [(100, .direct)])],
            ]
        )
        let state = try Aion(index: index).resolve(at: JulianDay(150)!)
        XCTAssertEqual(state.frame.shellSignID, "F1.02")
    }

    func testAstroDNAVerificationAcceptsRetrogradeRecrossWithoutRenumbering() throws {
        let aion = Aion(index: try makeIndex())
        let dna = makeAstroDNA(
            saturn: .aries,
            uranus: .aries,
            neptune: .taurus,
            pluto: .aries
        )

        let verification = try aion.verify(dna, at: JulianDay(140)!)

        XCTAssertTrue(verification.passed)
        let wave = verification.families.first { $0.family == .wave }!
        XCTAssertEqual(wave.shellSignID, "W3.03")
        XCTAssertEqual(wave.ownershipSign, .gemini)
        XCTAssertEqual(wave.expectedPhysicalSign, .taurus)
        XCTAssertEqual(wave.astroDNAPhysicalSign, .taurus)
        XCTAssertEqual(wave.transitionState, .retrogradeRecross)
    }

    func testAstroDNAVerificationRejectsNaiveOwnershipSignDuringRecross() throws {
        let aion = Aion(index: try makeIndex())
        let dna = makeAstroDNA(
            saturn: .aries,
            uranus: .aries,
            neptune: .gemini,
            pluto: .aries
        )

        let verification = try aion.verify(dna, at: JulianDay(140)!)

        XCTAssertFalse(verification.passed)
        let wave = verification.families.first { $0.family == .wave }!
        XCTAssertFalse(wave.matches)
        XCTAssertEqual(wave.expectedPhysicalSign, .taurus)
    }

    func testUnsupportedJulianDayFailsExplicitly() throws {
        let aion = Aion(index: try makeIndex())
        XCTAssertThrowsError(try aion.resolve(at: JulianDay(200)!)) { error in
            XCTAssertEqual(error as? AionError, .unsupportedJulianDay(200))
        }
    }

    private func makeIndex() throws -> AionIndex {
        try AionIndex(
            supportedStart: JulianDay(100)!,
            supportedEnd: JulianDay(200)!,
            rowsByFamily: [
                .frame: [segment(family: .frame, shellOrdinal: 1, sign: .aries, start: 100, end: 200, crossings: [(100, .direct)])],
                .revolt: [segment(family: .revolt, shellOrdinal: 2, sign: .aries, start: 100, end: 200, crossings: [(100, .direct)])],
                .wave: [segment(
                    family: .wave,
                    shellOrdinal: 3,
                    sign: .gemini,
                    start: 100,
                    end: 200,
                    crossings: [(100, .direct), (130, .retrograde), (150, .direct)]
                )],
                .zeitgeist: [segment(family: .zeitgeist, shellOrdinal: 4, sign: .aries, start: 100, end: 200, crossings: [(100, .direct)])],
            ]
        )
    }

    private func segment(
        family: AionFamily,
        shellOrdinal: Int,
        sign: Sign,
        start: Double,
        end: Double,
        crossings: [(Double, AionCrossingMotion)]
    ) -> AionSegment {
        let signOrdinal = sign.rawValue + 1
        let shellID = "\(family.rawValue)\(shellOrdinal)"
        return AionSegment(
            family: family,
            shellID: shellID,
            shellOrdinal: shellOrdinal,
            shellSignID: "\(shellID).\(String(format: "%02d", signOrdinal))",
            sign: sign,
            signOrdinal: signOrdinal,
            start: JulianDay(start)!,
            end: JulianDay(end)!,
            crossings: crossings.map {
                AionCrossing(julianDay: JulianDay($0.0)!, motion: $0.1)
            }
        )!
    }

    private func makeAstroDNA(
        saturn: Sign,
        uranus: Sign,
        neptune: Sign,
        pluto: Sign
    ) -> AstroDNA {
        var states = AstroDNAGene.canonicalOrder.map { gene -> RingFineState in
            let sign: Sign
            switch gene {
            case .saturn: sign = saturn
            case .uranus: sign = uranus
            case .neptune: sign = neptune
            case .pluto: sign = pluto
            default: sign = .aries
            }
            let longitude = CelestialLongitude(Double(sign.rawValue * 30) + 5)!
            return Ring.fineState(of: longitude, motion: .direct)
        }
        // Keep the variable-gene motion policy legal while proving that Aion's
        // Shell.sign check is about physical sign, not a fabricated motion rule.
        states[AstroDNAGene.neptune.ordinal] = Ring.fineState(
            of: CelestialLongitude(Double(neptune.rawValue * 30) + 5)!,
            motion: .retrograde
        )
        return AstroDNA(sequence: states)!
    }
}
