import XCTest
@testable import OrboCore

final class AstroDNAContractTests: XCTestCase {
    private struct ParityFixture: Decodable {
        let codec: Int
        let geneOrder: [String]
        let motionPolicies: [String]
        let ringFineStates: Int
        let ringArcseconds: Int
        let sampleSequence: [Int]
        let sampleDegreeSequence: [Int]
        let sampleSequenceString: String
        let sampleDegreeSequenceString: String
    }

    private func fixture() throws -> ParityFixture {
        try FixtureLoader.decode(ParityFixture.self, named: "astrodna-contract", kind: .parity)
    }

    private func sampleDNA() throws -> AstroDNA {
        let fixture = try fixture()
        return try XCTUnwrap(AstroDNA(rawSequence: fixture.sampleSequence))
    }

    func testContractFixturePinsCodecOrderAndRingAddressSpace() throws {
        let fixture = try fixture()
        XCTAssertEqual(AstroDNA.codec, fixture.codec)
        XCTAssertEqual(AstroDNA.geneCount, 12)
        XCTAssertEqual(AstroDNAGene.canonicalOrder.map(\.rawValue), fixture.geneOrder)
        XCTAssertEqual(AstroDNAGene.canonicalOrder.map { $0.motionPolicy.rawValue }, fixture.motionPolicies)
        XCTAssertEqual(Ring.fineStates, fixture.ringFineStates)
        XCTAssertEqual(Ring.arcseconds, fixture.ringArcseconds)
    }

    func testCanonicalGeneOrderIsExplicitAndComplete() {
        XCTAssertEqual(AstroDNAGene.canonicalOrder.count, 12)
        XCTAssertEqual(Set(AstroDNAGene.canonicalOrder).count, 12)
        XCTAssertEqual(AstroDNAGene.canonicalOrder.first, .ascendant)
        XCTAssertEqual(AstroDNAGene.canonicalOrder[1], .moon)
        XCTAssertEqual(AstroDNAGene.canonicalOrder[2], .sun)
        XCTAssertEqual(AstroDNAGene.canonicalOrder.last, .northNode)
        XCTAssertEqual(AstroDNAGene.northNode.rawValue, "Node")
        XCTAssertEqual(AstroDNAGene.northNode.displayName, "North Node")
        XCTAssertEqual(AstroDNAGene.northNode.motionPolicy, .variable)
    }

    func testCodec4IdentityPreservesTheTwelveRingFineStatesExactly() throws {
        let fixture = try fixture()
        let dna = try sampleDNA()
        XCTAssertEqual(dna.rawSequence, fixture.sampleSequence)
        XCTAssertEqual(dna.sequence.map(\.rawValue), fixture.sampleSequence)
        XCTAssertEqual(dna.sequenceString, fixture.sampleSequenceString)

        for gene in AstroDNAGene.canonicalOrder {
            XCTAssertEqual(dna[gene].rawValue, fixture.sampleSequence[gene.ordinal])
        }
    }

    func testWholeDegreeProjectionIsDerivedFromEachGeneAndMatchesCodec2Cut() throws {
        let fixture = try fixture()
        let dna = try sampleDNA()
        XCTAssertEqual(dna.degreeSequence.map(\.rawValue), fixture.sampleDegreeSequence)
        XCTAssertEqual(dna.degreeSequenceString, fixture.sampleDegreeSequenceString)

        for gene in AstroDNAGene.canonicalOrder {
            XCTAssertEqual(dna[gene].coarseState, dna.degreeSequence[gene.ordinal])
        }
    }

    func testContractRejectsWrongCardinalityAndMalformedRingFineAddresses() throws {
        let fixture = try fixture()
        XCTAssertNil(AstroDNA(rawSequence: Array(fixture.sampleSequence.dropLast())))
        XCTAssertNil(AstroDNA(rawSequence: fixture.sampleSequence + [0]))

        var negative = fixture.sampleSequence
        negative[4] = -1
        XCTAssertNil(AstroDNA(rawSequence: negative))

        var tooHigh = fixture.sampleSequence
        tooHigh[4] = Ring.fineStates
        XCTAssertNil(AstroDNA(rawSequence: tooHigh))
    }

    func testMotionIdentityEnforcesFixedDirectAndVariablePoliciesIncludingTrueNorthNode() throws {
        let fixture = try fixture()
        let dna = try sampleDNA()

        XCTAssertEqual(dna.motion(of: .ascendant), .direct)
        XCTAssertEqual(dna.motion(of: .moon), .direct)
        XCTAssertEqual(dna.motion(of: .sun), .direct)
        XCTAssertEqual(dna.motion(of: .northNode), .retrograde)
        XCTAssertEqual(dna.motion(of: .mercury), .retrograde)
        XCTAssertEqual(dna.motion(of: .venus), .direct)

        var badAscendant = fixture.sampleSequence
        badAscendant[AstroDNAGene.ascendant.ordinal] += Ring.arcseconds
        XCTAssertNil(AstroDNA(rawSequence: badAscendant))

        var badMoon = fixture.sampleSequence
        badMoon[AstroDNAGene.moon.ordinal] += Ring.arcseconds
        XCTAssertNil(AstroDNA(rawSequence: badMoon))

        var badSun = fixture.sampleSequence
        badSun[AstroDNAGene.sun.ordinal] += Ring.arcseconds
        XCTAssertNil(AstroDNA(rawSequence: badSun))

        var directNode = fixture.sampleSequence
        directNode[AstroDNAGene.northNode.ordinal] -= Ring.arcseconds
        let directNodeDNA = try XCTUnwrap(AstroDNA(rawSequence: directNode))
        XCTAssertEqual(directNodeDNA.motion(of: .northNode), .direct)
        XCTAssertEqual(directNodeDNA.longitude(of: .northNode), dna.longitude(of: .northNode))
    }

    func testLongitudeSignAndDegreeAreProjectionsOfTheGeneNotStoredPeers() throws {
        let dna = try sampleDNA()

        for gene in AstroDNAGene.canonicalOrder {
            let state = dna[gene]
            let longitude = dna.longitude(of: gene)
            XCTAssertEqual(
                longitude.degrees,
                Double(state.arcsecond) / Double(Ring.arcsecondsPerDegree),
                accuracy: 1e-12
            )
            XCTAssertEqual(dna.sign(of: gene), longitude.sign)
            XCTAssertEqual(dna.degreeInSign(of: gene), longitude.degreeInSign)
        }
    }

    func testSouthNodeIsDerivedOppositionAndNeverAThirteenthGene() throws {
        let dna = try sampleDNA()
        let north = dna.longitude(of: .northNode).degrees
        let expectedSouth = CelestialLongitude(north + 180)!
        XCTAssertEqual(dna.southNodeLongitude, expectedSouth)
        XCTAssertEqual(AstroDNAGene.canonicalOrder.count, 12)
        XCTAssertFalse(AstroDNAGene.canonicalOrder.map(\.rawValue).contains("SNode"))
    }

    func testCodecIsStampedAndSerializationContainsOnlyIdentity() throws {
        let dna = try sampleDNA()
        let data = try JSONEncoder().encode(dna)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(Set(object.keys), Set(["codec", "sequence"]))
        XCTAssertEqual(object["codec"] as? Int, 4)
        XCTAssertEqual(object["sequence"] as? [Int], dna.rawSequence)
        XCTAssertEqual(try JSONDecoder().decode(AstroDNA.self, from: data), dna)

        let badCodec = "{\"codec\":3,\"sequence\":\(dna.rawSequence)}".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(AstroDNA.self, from: badCodec))
    }

    func testReturnedSequencesAreValueCopiesAndCannotMutateGenome() throws {
        let dna = try sampleDNA()
        let original = dna.rawSequence
        var copy = dna.sequence
        copy.removeLast()
        XCTAssertEqual(copy.count, 11)
        XCTAssertEqual(dna.rawSequence, original)
        XCTAssertEqual(dna.sequence.count, 12)
    }
}
