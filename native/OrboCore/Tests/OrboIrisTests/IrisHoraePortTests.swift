import XCTest
@testable import OrboCore
@testable import OrboIris

final class IrisHoraePortTests: XCTestCase {
    func testHoraeIrisPortCarriesResolvedOutputIntoIrisUnchanged() throws {
        let julianDay = try XCTUnwrap(JulianDay(2_000.5))
        let terra = try XCTUnwrap(TerraMarrowSample(
            turnDegrees: 100,
            tiltDegrees: 23.4,
            julianDay: julianDay
        ))
        let output = HoraeOutput(
            julianDay: julianDay,
            celestial: [],
            terra: terra
        )

        let port = Horae.signalForIris(output)
        let frame = IrisHoraeFrame(port: port)

        XCTAssertEqual(port.signal, output)
        XCTAssertEqual(frame.output, output)
        XCTAssertEqual(frame.julianDay, output.julianDay)
        XCTAssertEqual(frame.terra, output.terra)
    }
}
