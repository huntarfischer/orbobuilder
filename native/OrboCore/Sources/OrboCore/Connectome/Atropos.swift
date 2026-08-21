public enum AtroposFailure: Error, Hashable, Sendable {
    case nonCanonicalGrid
    case invalidRecipeCount(Int)
    case invalidAllottedThreadCount(Int)
    case missingGene(AstroDNAGene)
    case duplicateGene(AstroDNAGene)
    case exactStateMismatch(AstroDNAGene)
    case degreeAddressMismatch(AstroDNAGene)
    case wrongCell(
        gene: AstroDNAGene,
        expected: DegreeAddress,
        actual: DegreeAddress
    )
}

public struct AtroposPackage: Hashable, Sendable {
    public let grid: DegreeGrid

    fileprivate init(grid: DegreeGrid) {
        self.grid = grid
    }
}

/// Atropos is the quality-control and sealing authority for the Moirai.
///
/// She compares the allotted DegreeGrid against the MoiraiRecipe Clotho
/// registered when the threads were created. She does not recalculate,
/// reinterpret, repair, or re-allot the work.
public enum Atropos {
    public static func inspect(
        recipe: MoiraiRecipe,
        grid: DegreeGrid
    ) -> Result<AtroposPackage, AtroposFailure> {
        guard grid.cells.count == DegreeAddress.count,
              grid.cells.map(\.address) == DegreeAddress.canonicalOrder else {
            return .failure(.nonCanonicalGrid)
        }

        guard recipe.entries.count == AstroDNA.geneCount else {
            return .failure(.invalidRecipeCount(recipe.entries.count))
        }

        let recipeGenes = recipe.entries.map(\.gene)
        if let duplicate = firstDuplicateGene(in: recipeGenes) {
            return .failure(.duplicateGene(duplicate))
        }

        for gene in AstroDNAGene.canonicalOrder where !recipeGenes.contains(gene) {
            return .failure(.missingGene(gene))
        }

        let allotted = grid.cells.flatMap(\.threads)
        guard allotted.count == AstroDNA.geneCount else {
            return .failure(.invalidAllottedThreadCount(allotted.count))
        }

        let allottedGenes = allotted.map(\.gene)
        if let duplicate = firstDuplicateGene(in: allottedGenes) {
            return .failure(.duplicateGene(duplicate))
        }

        for gene in AstroDNAGene.canonicalOrder where !allottedGenes.contains(gene) {
            return .failure(.missingGene(gene))
        }

        let recipeByGene = Dictionary(
            uniqueKeysWithValues: recipe.entries.map { ($0.gene, $0) }
        )
        let allottedByGene = Dictionary(
            uniqueKeysWithValues: allotted.map { ($0.gene, $0) }
        )

        for gene in AstroDNAGene.canonicalOrder {
            guard let expected = recipeByGene[gene],
                  let actual = allottedByGene[gene] else {
                return .failure(.missingGene(gene))
            }

            guard actual.exactState == expected.exactState else {
                return .failure(.exactStateMismatch(gene))
            }

            guard actual.degreeAddress == expected.degreeAddress else {
                return .failure(.degreeAddressMismatch(gene))
            }

            guard let containingCell = grid.cells.first(where: {
                $0.threads.contains(actual)
            }) else {
                return .failure(.missingGene(gene))
            }

            guard containingCell.address == expected.degreeAddress else {
                return .failure(
                    .wrongCell(
                        gene: gene,
                        expected: expected.degreeAddress,
                        actual: containingCell.address
                    )
                )
            }
        }

        return .success(AtroposPackage(grid: grid))
    }

    private static func firstDuplicateGene(
        in genes: [AstroDNAGene]
    ) -> AstroDNAGene? {
        var seen: Set<AstroDNAGene> = []
        for gene in genes {
            if !seen.insert(gene).inserted {
                return gene
            }
        }
        return nil
    }
}
