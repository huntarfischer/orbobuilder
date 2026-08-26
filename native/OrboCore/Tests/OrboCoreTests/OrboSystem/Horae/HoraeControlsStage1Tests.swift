import XCTest
@testable import OrboCore

final class HoraeControlsStage1Tests: XCTestCase {
    func testControlReadoutTravelsInsideSingleHoraeOutput() throws {
        let julianDay = try XCTUnwrap(JulianDay(2_460_000.123456789))
        let directionalDegree = try XCTUnwrap(OrboSpineDirectionalDegree(379.987654321))
        let address = HoraeAddress(
            body: .mercury,
            directionalDegree: directionalDegree,
            julianDay: julianDay
        )
        let controlState = try XCTUnwrap(HoraeControlState(
            address: address,
            bodyRole: .pinned,
            directionalDegreeRole: .driven,
            julianDayRole: .resolved
        ))
        let coordinate = OrboSpineCelestialCoordinate(
            body: .mercury,
            directionalDegree: directionalDegree,
            julianDay: julianDay
        )
        let terra = try XCTUnwrap(TerraMarrowSample(
            turnDegrees: 100,
            tiltDegrees: 23.4,
            julianDay: julianDay
        ))

        let output = HoraeOutput(
            julianDay: julianDay,
            celestial: [coordinate],
            terra: terra,
            controlState: controlState
        )

        XCTAssertEqual(output.controlState, controlState)
        XCTAssertEqual(output.controlState?.address.body, .mercury)
        XCTAssertEqual(output.controlState?.address.directionalDegree, directionalDegree)
        XCTAssertEqual(output.controlState?.address.julianDay, julianDay)
        XCTAssertEqual(output.controlState?.bodyRole, .pinned)
        XCTAssertEqual(output.controlState?.directionalDegreeRole, .driven)
        XCTAssertEqual(output.controlState?.julianDayRole, .resolved)
        XCTAssertEqual(output.julianDay, julianDay)
        XCTAssertEqual(output.celestial, [coordinate])
        XCTAssertEqual(output.terra, terra)
    }

    func testControlStateRequiresExactlyOneDrivenCoordinate() throws {
        let address = HoraeAddress(
            body: .venus,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(112.08)),
            julianDay: try XCTUnwrap(JulianDay(2_461_274.53))
        )

        XCTAssertNil(HoraeControlState(
            address: address,
            bodyRole: .resolved,
            directionalDegreeRole: .pinned,
            julianDayRole: .resolved
        ))
        XCTAssertNil(HoraeControlState(
            address: address,
            bodyRole: .driven,
            directionalDegreeRole: .driven,
            julianDayRole: .resolved
        ))
        XCTAssertNotNil(HoraeControlState(
            address: address,
            bodyRole: .driven,
            directionalDegreeRole: .pinned,
            julianDayRole: .pinned
        ))
    }

    func testExistingHoraeOutputNeedsNoControlState() throws {
        let julianDay = try XCTUnwrap(JulianDay(2_451_545.0))
        let directionalDegree = try XCTUnwrap(OrboSpineDirectionalDegree(10.25))
        let coordinate = OrboSpineCelestialCoordinate(
            body: .sun,
            directionalDegree: directionalDegree,
            julianDay: julianDay
        )
        let terra = try XCTUnwrap(TerraMarrowSample(
            turnDegrees: 280.46061837,
            tiltDegrees: 23.4392911,
            julianDay: julianDay
        ))

        let output = HoraeOutput(
            julianDay: julianDay,
            celestial: [coordinate],
            terra: terra
        )

        XCTAssertNil(output.controlState)
        XCTAssertEqual(output.julianDay, julianDay)
        XCTAssertEqual(output.celestial, [coordinate])
        XCTAssertEqual(output.terra, terra)
    }
}
