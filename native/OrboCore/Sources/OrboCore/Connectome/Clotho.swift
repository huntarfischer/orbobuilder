public struct ClothoNatalFact: Hashable, Sendable {
    public let gene: AstroDNAGene
    public let exactState: RingFineState
    public let degreeAddress: DegreeAddress

    public init(
        gene: AstroDNAGene,
        exactState: RingFineState,
        degreeAddress: DegreeAddress
    ) {
        self.gene = gene
        self.exactState = exactState
        self.degreeAddress = degreeAddress
    }
}

public struct ClothoSourcePacket: Hashable, Sendable {
    public let natalFacts: [ClothoNatalFact]

    public init(natalFacts: [ClothoNatalFact]) {
        self.natalFacts = natalFacts
    }
}

public enum Clotho {
    public static func gather(from natalAstroDNA: AstroDNA) -> ClothoSourcePacket {
        let natalFacts = AstroDNAGene.canonicalOrder.map { gene in
            let exactState = natalAstroDNA[gene]
            let degree = exactState.coarseState.degree
            guard let degreeAddress = DegreeAddress(rawValue: degree) else {
                preconditionFailure("Clotho received an invalid whole-degree Ring address.")
            }

            return ClothoNatalFact(
                gene: gene,
                exactState: exactState,
                degreeAddress: degreeAddress
            )
        }

        return ClothoSourcePacket(natalFacts: natalFacts)
    }
}
