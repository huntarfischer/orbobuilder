import XCTest
@testable import OrboCore

final class SpineLinkTests: XCTestCase {
    func testLinkRequiresAtLeastTwoAddressableMembers() throws {
        let one = try XCTUnwrap(SpineLinkAddress(spineIdentity: "OrboSpine", memberIdentity: "one"))

        XCTAssertNil(SpineLinkSet(members: []))
        XCTAssertNil(SpineLinkSet(members: [one]))
    }

    func testLinkIsNWayAndPreservesMemberOrderAcrossSpines() throws {
        let first = try XCTUnwrap(SpineLinkAddress(spineIdentity: "OrboSpine", memberIdentity: "coordinate-a"))
        let second = try XCTUnwrap(SpineLinkAddress(spineIdentity: "NatalSpine-A", memberIdentity: "frame-b"))
        let third = try XCTUnwrap(SpineLinkAddress(spineIdentity: "NatalSpine-B", memberIdentity: "temporal-set-c"))

        let pair = try XCTUnwrap(SpineLinkSet(members: [first, second]))
        XCTAssertEqual(pair.members, [first, second])

        let nWay = try XCTUnwrap(SpineLinkSet(members: [first, second, third]))
        XCTAssertEqual(SpineLinkSet.port, .link)
        XCTAssertEqual(nWay.members, [first, second, third])
    }

    func testLinkAddressRejectsBlankSpineOrMemberIdentity() {
        XCTAssertNil(SpineLinkAddress(spineIdentity: "", memberIdentity: "member"))
        XCTAssertNil(SpineLinkAddress(spineIdentity: "OrboSpine", memberIdentity: "   "))
    }
}
