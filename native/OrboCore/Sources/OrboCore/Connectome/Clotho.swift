public struct ClothoThread: Hashable, Sendable {
    public let gene: AstroDNAGene
    public let exactState: RingFineState
    public let degreeAddress: DegreeAddress

    fileprivate init(
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
    public let threads: [ClothoThread]

    fileprivate init(threads: [ClothoThread]) {
        self.threads = threads
    }
}

public enum Clotho {
    public static func gather(from natalAstroDNA: AstroDNA) -> ClothoSourcePacket {
        let threads = AstroDNAGene.canonicalOrder.map { gene in
            let exactState = natalAstroDNA[gene]
            let degree = exactState.coarseState.degree
            guard let degreeAddress = DegreeAddress(rawValue: degree) else {
                preconditionFailure("Clotho received an invalid whole-degree Ring address.")
            }

            return ClothoThread(
                gene: gene,
                exactState: exactState,
                degreeAddress: degreeAddress
            )
        }

        return ClothoSourcePacket(threads: threads)
    }
}
