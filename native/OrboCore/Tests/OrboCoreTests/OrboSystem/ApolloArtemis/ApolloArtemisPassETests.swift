import XCTest
@testable import OrboCore

final class ApolloArtemisPassETests: XCTestCase {
    func testOrboSummonsApolloWithoutTakingAegisGovernance() {
        let orbo = Orbo()
        let governor = orbo.summonApollo()

        XCTAssertEqual(governor.governedInstrument, .aegis)
        XCTAssertEqual(Apollo.governedInstrument, .aegis)
    }

    func testOrboSummonsArtemisWithoutTakingLunarPaneGovernance() {
        let orbo = Orbo()
        let governor = orbo.summonArtemis()

        XCTAssertEqual(governor.governedInstrument, .lunarPane)
        XCTAssertEqual(Artemis.governedInstrument, .lunarPane)
    }

    func testHermesHasCanonicalAddressesForBothTwins() {
        XCTAssertEqual(Apollo.address, HermesAddress(rawValue: "orbo.apollo"))
        XCTAssertEqual(Artemis.address, HermesAddress(rawValue: "orbo.artemis"))
        XCTAssertNotEqual(Apollo.address, Artemis.address)
    }

    func testTwinAddressabilityDoesNotCreateAParcelAcceptanceContract() throws {
        let registry = HermesMessengerRouteRegistry()
        let unspecifiedKind = try XCTUnwrap(
            HermesParcelKind(rawValue: "orbo.unspecified-twin-parcel.v1")
        )

        XCTAssertFalse(registry.finalAddressee(Apollo.address, accepts: unspecifiedKind))
        XCTAssertFalse(registry.finalAddressee(Artemis.address, accepts: unspecifiedKind))
    }

    func testPriorLightAndIrisPortLawsRemainIntact() {
        let astrolabeSubject = Apollo.placeOnAstrolabe(identity: "native")
        let lunarSubject = Apollo.presentToArtemis(astrolabeSubject)

        XCTAssertEqual(lunarSubject, astrolabeSubject)
        XCTAssertEqual(Apollo.signalForIris(astrolabeSubject).signal.subject, astrolabeSubject)
        XCTAssertEqual(Artemis.signalForIris(lunarSubject).signal.subject, astrolabeSubject)
    }
}
