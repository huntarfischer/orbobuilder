import XCTest
@testable import OrboCore

// Canonical live-data proof for the manufactured Aion runtime index.
final class AionCanonicalTests: XCTestCase {
    func testCanonicalIndexResolves1985IntoZeitgeist22Scorpio() throws {
        let aion = try Aion.canonical()
        let state = try aion.resolve(at: JulianDay(2_446_165.5)!)

        XCTAssertEqual(state.shellAddress, "F186.R65.W32.Z22")
        XCTAssertEqual(state.zeitgeist.shellSignID, "Z22.08")
        XCTAssertEqual(state.zeitgeist.sign, .scorpio)
    }

    func testCanonicalIndexMovesNeptuneIntoW33AriesAtExactBoundary() throws {
        let aion = try Aion.canonical()
        let boundary = JulianDay(2_460_764.9985714555)!
        let state = try aion.resolve(at: boundary)

        XCTAssertEqual(state.shellAddress, "F187.R66.W33.Z22")
        XCTAssertEqual(state.wave.shellSignID, "W33.01")
        XCTAssertEqual(state.wave.sign, .aries)
        XCTAssertEqual(state.wave.segmentStart.value, boundary.value, accuracy: 1e-9)
    }
}
