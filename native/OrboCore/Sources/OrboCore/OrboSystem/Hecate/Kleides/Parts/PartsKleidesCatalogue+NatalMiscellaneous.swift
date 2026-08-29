extension PartsKleidesCatalogue {
    static let natalMiscellaneous: [PartCatalogueEntry] = [
        natalPage(
            "parts.natal.miscellaneous.hailaj",
            sourceLabel: "Hailaj [Hyleg, 'life-giver']",
            division: .miscellaneous,
            formulas: [sourceFormula(["Asc", "Mo", "PreviousSyzygyDegree"], day: "Asc + Moon - degree of previous syzygy", night: "Asc + Moon - degree of previous syzygy", mark: .same)]
        ),
        natalPage(
            "parts.natal.miscellaneous.debilitatedBodies",
            sourceLabel: "Debilitated bodies",
            division: .miscellaneous,
            formulas: [sourceFormula(["Asc", "Ma", "F"], day: "Asc + Mars - Fortune", night: "Asc + Fortune - Mars", mark: .reverse)]
        ),
        natalPage(
            "parts.natal.miscellaneous.horsemanshipBravery",
            sourceLabel: "Horsemanship, bravery",
            division: .miscellaneous,
            formulas: [sourceFormula(["Asc", "Mo", "Sa"], day: "Asc + Moon - Saturn", night: "Asc + Saturn - Moon", mark: .reverse)]
        ),
        natalPage(
            "parts.natal.miscellaneous.boldnessViolenceMurder",
            sourceLabel: "Boldness, violence and murder",
            division: .miscellaneous,
            formulas: [sourceFormula(["Asc", "Mo", "LordAsc"], day: "Asc + Moon - Lord of Asc", night: "Asc + Lord of Asc - Moon", mark: .reverse)]
        ),
        natalPage(
            "parts.natal.miscellaneous.trickeryAndDeceit",
            sourceLabel: "Trickery and deceit",
            division: .miscellaneous,
            formulas: [sourceFormula(["Asc", "Sp", "Me"], day: "Asc + Spirit - Mercury", night: "Asc + Mercury - Spirit", mark: .reverse)]
        ),
        natalPage(
            "parts.natal.miscellaneous.necessityAndWish",
            sourceLabel: "Necessity and wish",
            division: .miscellaneous,
            formulas: [sourceFormula(["Asc", "Ma", "Sa"], day: "Asc + Mars - Saturn", night: "Asc + Mars - Saturn", mark: .same)]
        ),
        natalPage(
            "parts.natal.miscellaneous.requirementsNecessitiesEgyptians",
            sourceLabel: "Requirements and necessities a/t Egyptians",
            division: .miscellaneous,
            formulas: [sourceFormula(["Asc", "c3", "Ma"], day: "Asc + Cusp of 3rd - Mars", night: "Asc + Cusp of 3rd - Mars", mark: .same)]
        ),
        natalPage(
            "parts.natal.miscellaneous.realisationNeedsDesires",
            sourceLabel: "Realisation of needs and desires",
            division: .miscellaneous,
            formulas: [sourceFormula(["Asc", "Me", "F"], day: "Asc + Mercury - Fortune", night: "Asc + Mercury - Fortune", mark: .same)]
        ),
        natalPage(
            "parts.natal.miscellaneous.retribution",
            sourceLabel: "Retribution",
            division: .miscellaneous,
            formulas: [sourceFormula(["Asc", "Su", "Ma"], day: "Asc + Sun - Mars", night: "Asc + Mars - Sun", mark: .reverse)]
        ),
        natalPage(
            "parts.natal.miscellaneous.rectitude",
            sourceLabel: "Rectitude",
            division: .miscellaneous,
            formulas: [sourceFormula(["Asc", "Ma", "Me"], day: "Asc + Mars - Mercury", night: "Asc + Mercury - Mars", mark: .reverse)]
        ),
    ]
}
