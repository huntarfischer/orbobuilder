import XCTest
@testable import OrboCore
@testable import OrboIris

final class HomerThreePortSystemTests: XCTestCase {
    func testHecateHoraeAndOrboShareOneHomerRelayWithoutErasure() throws {
        let hecateInquiry = try XCTUnwrap(
            Hecate.inquire(KleisID(rawValue: "Fortune")!)
        )
        let hecateFrame = IrisHomerFrame(
            port: Homer.POV(Hecate.signalForHomer(hecateInquiry))
        )

        let horae = try makeHorae()
        let requestedJulianDay = JulianDay(2_000.5)!
        let horaeOutput = try horae.seek(to: requestedJulianDay)
        let horaeFrame = IrisHomerFrame(
            port: Homer.POV(Horae.signalForHomer(horaeOutput))
        )

        let orbo = Orbo()
        let orboFrame = IrisHomerFrame(
            port: Homer.POV(orbo.signalForHomer())
        )

        XCTAssertEqual(hecateFrame.pointOfView, hecateInquiry)
        XCTAssertEqual(horaeFrame.pointOfView, horaeOutput)
        XCTAssertEqual(orboFrame.pointOfView.frontOfHouse, .resting)
        XCTAssertEqual(orboFrame.pointOfView.backOfHouse, .idle)
    }

    private func makeHorae() throws -> Horae {
        let bone = try XCTUnwrap(
            OrboSpineBoneSpan(
                start: JulianDay(2_000)!,
                end: JulianDay(2_002)!
            )
        )

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let base = 20.0 + Double(index * 25)
            let delta = OrboSpineContract.supportDegrees(for: body)
            supports.append(
                coordinate(
                    body: body,
                    degrees: base,
                    julianDay: JulianDay(2_000)!
                )
            )
            supports.append(
                coordinate(
                    body: body,
                    degrees: base + delta,
                    julianDay: JulianDay(2_001)!
                )
            )
        }

        let terra = [
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 100,
                tiltDegrees: 23.4,
                julianDay: bone.start
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 102,
                tiltDegrees: 23.5,
                julianDay: bone.end
            )),
        ]

        let locate = try XCTUnwrap(
            OrboSpineLocate(
                bone: bone,
                celestialSupports: supports,
                terraSamples: terra
            )
        )
        return Horae(locate: locate)
    }

    private func coordinate(
        body: MundaneBody,
        degrees: Double,
        julianDay: JulianDay
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: degrees,
                motion: .direct
            )!,
            julianDay: julianDay
        )
    }
}
