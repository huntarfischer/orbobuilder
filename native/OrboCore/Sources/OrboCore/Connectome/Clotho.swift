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

    internal init(
        restoringGene gene: AstroDNAGene,
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

public struct MoiraiRecipeEntry: Hashable, Sendable {
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

public struct MoiraiRecipe: Hashable, Sendable {
    public let entries: [MoiraiRecipeEntry]

    fileprivate init(entries: [MoiraiRecipeEntry]) {
        self.entries = entries
    }
}

public struct ClothoOutput: Hashable, Sendable {
    public let packet: ClothoSourcePacket
    public let recipe: MoiraiRecipe

    fileprivate init(packet: ClothoSourcePacket, recipe: MoiraiRecipe) {
        self.packet = packet
        self.recipe = recipe
    }
}

public enum Clotho {
    public static func gather(from natalAstroDNA: AstroDNA) -> ClothoOutput {
        var threads: [ClothoThread] = []
        var recipeEntries: [MoiraiRecipeEntry] = []
        threads.reserveCapacity(AstroDNA.geneCount)
        recipeEntries.reserveCapacity(AstroDNA.geneCount)

        for gene in AstroDNAGene.canonicalOrder {
            let exactState = natalAstroDNA[gene]
            let degree = exactState.coarseState.degree
            guard let degreeAddress = DegreeAddress(rawValue: degree) else {
                preconditionFailure("Clotho received an invalid whole-degree Ring address.")
            }

            threads.append(
                ClothoThread(
                    gene: gene,
                    exactState: exactState,
                    degreeAddress: degreeAddress
                )
            )
            recipeEntries.append(
                MoiraiRecipeEntry(
                    gene: gene,
                    exactState: exactState,
                    degreeAddress: degreeAddress
                )
            )
        }

        return ClothoOutput(
            packet: ClothoSourcePacket(threads: threads),
            recipe: MoiraiRecipe(entries: recipeEntries)
        )
    }
}
