import XCTest
@testable import OrboCore

final class ClothoStage1Tests: XCTestCase {
    private func natalDNA(ascendantLongitude: Int) throws -> AstroDNA {
        var sequence = Array(repeating: 0, count: AstroDNA.geneCount)
        sequence[AstroDNAGene.ascendant.ordinal] = ascendantLongitude * Ring.arcsecondsPerDegree
        return try XCTUnwrap(AstroDNA(rawSequence: sequence))
    }

    func testClothoTakesNatalAstroDNAAsInput() throws {
        let dna = try natalDNA(225)
        let packet = Clotho.gather(from: dna)
        XCTAssertEqual(packet.risingSign, .scorpio)
    }

    func testClothoGathersOnlyTheRisingSignForMVP() throws {
        let dna = try natalDNA(15)
        let packet = Clotho.gather(from: dna)
        let data = try JSONEncoder().encode(packet)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(Set(object.keys), Set(["risingSign"]))
    }

    func testSameNatalAstroDNAProducesSamePacket() throws {
        let dna = try natalDNA(121)
        XCTAssertEqual(Clotho.gather(from: dna), Clotho.gather(from: dna))
    }

    func testDifferentAscendantSignsProduceDifferentPackets() throws {
        let aries = Clotho.gather(from: try natalDNA(0))
        let taurus = Clotho.gather(from: try natalDNA(30))
        XCTAssertNotEqual(aries, taurus)
        XCTAssertEqual(aries.risingSign, .aries)
        XCTAssertEqual(taurus.risingSign, .taurus)
    }

    func testAscendantDegreeWithinSignDoesNotChangeMVPSourceFact() throws {
        let earlyScorpio = Clotho.gather(from: try natalDNA(210))
        let lateScorpio = Clotho.gather(from: try natalDNA(239))
        XCTAssertEqual(earlyScorpio, lateScorpio)
        XCTAssertEqual(earlyScorpio.risingSign, .scorpio)
    }

    func testSourcePacketRoundTripsWithoutNatalAstroDNA() throws {
        let packet = Clotho.gather(from: try natalDNA(270))
        let data = try JSONEncoder().encode(packet)
        let decoded = try JSONDecoder().decode(ClothoSourcePacket.self, from: data)
        XCTAssertEqual(decoded, packet)
        XCTAssertEqual(decoded.risingSign, .capricorn)
    }
}
