import XCTest
@testable import OrboCore

final class HecateLinkTests: XCTestCase {
    func testHecateReadsOnlyLinksContainingRequestedAddressInSourceOrder() {
        let requested = address("mundane-timespine", "sun@2451545")
        let moon = address("mundane-timespine", "moon@2451545")
        let venus = address("mundane-timespine", "venus@2451545")
        let natalSun = address("natal-spine", "sun")

        let first = link("sun-moon", [requested, moon])
        let unrelated = link("venus-natal-sun", [venus, natalSun])
        let third = link("sun-venus-natal", [requested, venus, natalSun])
        let doorIII = SpineLinkSet(links: [first, unrelated, third])

        let hecate = HecateLink(link: doorIII)

        XCTAssertEqual(hecate.links(containing: requested), [first, third])
    }

    func testHecatePreservesOneNWayDoorThreeRelationExactly() {
        let mundaneSun = address("mundane-timespine", "sun@2451545")
        let natalMoon = address("natal-spine", "moon")
        let synchronicAscendant = address("synchronic-spine", "ascendant@2451545")
        let relation = link(
            "three-way-relation",
            [mundaneSun, natalMoon, synchronicAscendant]
        )
        let hecate = HecateLink(link: SpineLinkSet(links: [relation]))

        let answer = hecate.links(containing: natalMoon)

        XCTAssertEqual(answer, [relation])
        XCTAssertEqual(answer.first?.members, relation.members)
        XCTAssertEqual(answer.first?.members.count, 3)
    }

    func testHecateReturnsEmptyWhenDoorThreeContainsNoRelationForAddress() {
        let existingA = address("mundane-timespine", "mercury@2451545")
        let existingB = address("natal-spine", "mercury")
        let absent = address("synchronic-spine", "mercury@2451545")
        let hecate = HecateLink(
            link: SpineLinkSet(links: [link("mercury-relation", [existingA, existingB])])
        )

        XCTAssertEqual(hecate.links(containing: absent), [])
    }

    private func address(_ spine: String, _ member: String) -> SpineLinkAddress {
        SpineLinkAddress(spineIdentity: spine, memberIdentity: member)!
    }

    private func link(_ identity: String, _ members: [SpineLinkAddress]) -> SpineLink {
        SpineLink(identity: identity, members: members)!
    }
}
