import XCTest
@testable import OrboCore

final class HecateLinkTests: XCTestCase {
    func testHecateReceivesTheExactDoorThreeLinkSet() throws {
        let mundaneSun = try address("mundane-timespine", "sun@2451545")
        let natalSun = try address("natal-spine", "sun")
        let doorIII = try XCTUnwrap(SpineLinkSet(members: [mundaneSun, natalSun]))

        let hecate = HecateLink(link: doorIII)

        XCTAssertEqual(hecate.link, doorIII)
        XCTAssertEqual(SpineLinkSet.port, .link)
    }

    func testHecatePreservesNWayMemberOrderAcrossSpines() throws {
        let mundaneSun = try address("mundane-timespine", "sun@2451545")
        let natalMoon = try address("natal-spine", "moon")
        let synchronicAscendant = try address(
            "synchronic-spine",
            "ascendant@2451545"
        )
        let doorIII = try XCTUnwrap(
            SpineLinkSet(members: [mundaneSun, natalMoon, synchronicAscendant])
        )

        let hecate = HecateLink(link: doorIII)

        XCTAssertEqual(
            hecate.members,
            [mundaneSun, natalMoon, synchronicAscendant]
        )
        XCTAssertEqual(hecate.members.count, 3)
    }

    private func address(
        _ spine: String,
        _ member: String
    ) throws -> SpineLinkAddress {
        try XCTUnwrap(
            SpineLinkAddress(
                spineIdentity: spine,
                memberIdentity: member
            )
        )
    }
}
