extension PartsKleidesCatalogue {
    static let annualConjunction: [PartCatalogueEntry] = [
        nonNatalPage(
            "parts.annualConjunction.sultansLot",
            sourceLabel: "The Sultan's Lot",
            context: .annualConjunction,
            formulas: [
                sourceFormula(
                    ["Ju", "MC(return)", "MC"],
                    day: "Jupiter + MC of the return chart - MC",
                    night: "Jupiter + MC of the return chart - MC",
                    mark: .same,
                    status: .partial
                ),
                sourceFormula(
                    ["Ju", "MC(return)", "Su"],
                    day: "Jupiter + MC of the return chart - Sun",
                    night: "Jupiter + MC of the return chart - Sun",
                    mark: .same,
                    status: .partial
                ),
                sourceFormula(
                    ["Asc", "degree(conjunction)", "Asc(conjunction)"],
                    day: "Asc + Degree conj. - Deg. Asc. Conj.",
                    night: "Asc + Degree conj. - Deg. Asc. Conj.",
                    mark: .same
                ),
            ]
        ),
        nonNatalPage(
            "parts.annualConjunction.victory",
            sourceLabel: "Victory",
            context: .annualConjunction,
            formulas: [
                sourceFormula(
                    ["Asc", "L7", "Su"],
                    day: "Asc + Lord of 7th - Sun",
                    night: "Asc + Lord of 7th - Sun",
                    mark: .same,
                    status: .partial
                ),
                sourceFormula(
                    ["Asc", "Desc", "Su"],
                    day: "Asc + degree of desc - Sun",
                    night: "Asc + degree of desc - Sun",
                    mark: .same,
                    status: .partial
                ),
            ]
        ),
        nonNatalPage(
            "parts.annualConjunction.battle",
            sourceLabel: "Battle",
            context: .annualConjunction,
            formulas: [
                sourceFormula(
                    ["Lot of Victory", "Mo", "Ma"],
                    day: "Degree of Lot of Victory - Moon - Mars",
                    night: "Degree of Lot of Victory - Moon - Mars",
                    mark: .same
                ),
                sourceFormula(
                    ["Asc", "Mo", "Ma"],
                    day: "Asc + Moon - Mars",
                    night: "Asc + Moon - Mars",
                    mark: .same,
                    tradition: "Umar (as attributed by al-Biruni)"
                ),
                sourceFormula(
                    ["Asc", "Mo", "Sa"],
                    day: "Asc + Moon - Saturn",
                    night: "Asc + Moon - Saturn",
                    mark: .same,
                    tradition: "Al Furkhan (as attributed by al-Biruni)"
                ),
            ]
        ),
        nonNatalPage(
            "parts.annualConjunction.truceBetweenArmies",
            sourceLabel: "Truce between Armies",
            context: .annualConjunction,
            formulas: [
                sourceFormula(
                    ["Asc", "Me", "Mo"],
                    day: "Asc + Mercury - Moon",
                    night: "Asc + Mercury - Moon",
                    mark: .same
                ),
            ]
        ),
        nonNatalPage(
            "parts.annualConjunction.conquest",
            sourceLabel: "Conquest",
            context: .annualConjunction,
            formulas: [
                sourceFormula(
                    ["Asc", "Ma", "Su"],
                    day: "Asc + Mars - Sun",
                    night: "Asc + Mars - Sun",
                    mark: .same
                ),
            ]
        ),
        nonNatalPage(
            "parts.annualConjunction.triumph",
            sourceLabel: "Triumph",
            context: .annualConjunction,
            formulas: [
                sourceFormula(
                    ["Asc", "Ju", "F"],
                    day: "Asc + Jupiter - Fortune",
                    night: "Asc + Fortune - Jupiter",
                    mark: .reverse
                ),
            ]
        ),
        nonNatalPage(
            "parts.annualConjunction.firstConjunction",
            sourceLabel: "Of 1st conjunction",
            context: .annualConjunction,
            formulas: [
                sourceFormula(
                    ["Asc", "degree(conjunction)", "Asc(year conjunction)"],
                    day: "Asc + Degree conj. - Ascen. Year conj.",
                    night: "Asc + Degree conj. - Ascen. Year conj.",
                    mark: .same
                ),
            ]
        ),
        nonNatalPage(
            "parts.annualConjunction.secondConjunction",
            sourceLabel: "Of 2nd conjunction",
            context: .annualConjunction,
            formulas: [
                sourceFormula(
                    ["Asc", "degree(conjunction)", "Asc(conjunction)"],
                    day: "Asc + Degree conj. - Ascen. Conj.",
                    night: "Asc + Degree conj. - Ascen. Conj.",
                    mark: .same
                ),
            ]
        ),
    ]
}
