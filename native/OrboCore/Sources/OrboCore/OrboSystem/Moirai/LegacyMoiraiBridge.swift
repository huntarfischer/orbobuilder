/// Transitional downstream vocabulary retained only until Lachesis and Atropos
/// are rebuilt around Pattern + AstroDNA.
public struct ClothoThread: Hashable, Sendable {
    public let gene: AstroDNAGene
    public let exactState: RingFineState
    public let degreeAddress: DegreeAddress

    internal init(
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

    internal init(threads: [ClothoThread]) {
        self.threads = threads
    }
}

public struct MoiraiRecipeEntry: Hashable, Sendable {
    public let gene: AstroDNAGene
    public let exactState: RingFineState
    public let degreeAddress: DegreeAddress

    internal init(
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

    internal init(entries: [MoiraiRecipeEntry]) {
        self.entries = entries
    }
}

internal struct LegacyMoiraiOutput: Hashable, Sendable {
    let packet: ClothoSourcePacket
    let recipe: MoiraiRecipe
}

/// Temporary adapter for the existing Lachesis/Atropos implementation.
/// Canonical Clotho no longer creates these representations.
internal enum LegacyMoiraiBridge {
    static func gather(from natalAstroDNA: AstroDNA) -> LegacyMoiraiOutput {
        var threads: [ClothoThread] = []
        var recipeEntries: [MoiraiRecipeEntry] = []
        threads.reserveCapacity(AstroDNA.geneCount)
        recipeEntries.reserveCapacity(AstroDNA.geneCount)

        for gene in AstroDNAGene.canonicalOrder {
            let exactState = natalAstroDNA[gene]
            let degree = exactState.coarseState.degree
            guard let degreeAddress = DegreeAddress(rawValue: degree) else {
                preconditionFailure("Legacy Moirai bridge received an invalid whole-degree Ring address.")
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

        return LegacyMoiraiOutput(
            packet: ClothoSourcePacket(threads: threads),
            recipe: MoiraiRecipe(entries: recipeEntries)
        )
    }
}
