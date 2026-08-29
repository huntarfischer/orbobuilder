extension PartsKleidesCatalogue {
    static let natalPlanetary: [PartCatalogueEntry] = [
        natalPage(
            "parts.natal.planetary.fortuneOrLunarHoroscope",
            sourceLabel: "Fortune or Lunar horoscope",
            division: .planetary,
            formulas: [
                sourceFormula(
                    ["Asc", "Mo", "Su"],
                    day: "Asc + Moon - Sun",
                    night: "Asc + Sun - Moon",
                    mark: .reverse
                ),
            ]
        ),
        natalPage(
            "parts.natal.planetary.daemonAndReligion",
            sourceLabel: "Daemon and religion",
            division: .planetary,
            formulas: [
                sourceFormula(
                    ["Asc", "Su", "Mo"],
                    day: "Asc + Sun - Moon",
                    night: "Asc + Moon - Sun",
                    mark: .reverse
                ),
            ]
        ),
        natalPage(
            "parts.natal.planetary.friendshipAndLove",
            sourceLabel: "Friendship and love",
            division: .planetary,
            formulas: [
                sourceFormula(
                    ["Asc", "Sp", "F"],
                    day: "Asc + Spirit - Fortune",
                    night: "Asc + Fortune - Spirit",
                    mark: .reverse
                ),
            ]
        ),
        natalPage(
            "parts.natal.planetary.despairPenuryFraud",
            sourceLabel: "Despair & penury & fraud",
            division: .planetary,
            formulas: [
                sourceFormula(
                    ["Asc", "F", "Sp"],
                    day: "Asc + Fortune - Spirit",
                    night: "Asc + Spirit - Fortune",
                    mark: .reverse
                ),
            ]
        ),
        natalPage(
            "parts.natal.planetary.captivityPrisonsEscape",
            sourceLabel: "Captivity, prisons and escape therefrom",
            division: .planetary,
            formulas: [
                sourceFormula(
                    ["Asc", "F", "Sa"],
                    day: "Asc + Fortune - Saturn",
                    night: "Asc + Saturn - Fortune",
                    mark: .reverse
                ),
            ]
        ),
        natalPage(
            "parts.natal.planetary.victoryTriumphAid",
            sourceLabel: "Victory, triumph & aid",
            division: .planetary,
            formulas: [
                sourceFormula(
                    ["Asc", "Ju", "Sp"],
                    day: "Asc + Jupiter - Spirit",
                    night: "Asc + Spirit - Jupiter",
                    mark: .reverse
                ),
            ]
        ),
        natalPage(
            "parts.natal.planetary.valourAndBravery",
            sourceLabel: "Valour and bravery",
            division: .planetary,
            formulas: [
                sourceFormula(
                    ["Asc", "F", "Ma"],
                    day: "Asc + Fortune - Mars",
                    night: "Asc + Mars - Fortune",
                    mark: .reverse
                ),
            ]
        ),
    ]
}
