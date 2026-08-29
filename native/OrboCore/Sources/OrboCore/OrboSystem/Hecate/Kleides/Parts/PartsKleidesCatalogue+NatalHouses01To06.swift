extension PartsKleidesCatalogue {
    static let natalHouses01To06: [PartCatalogueEntry] = [
        natalHouse(1, "life", "Life", ["Asc", "Sa", "Ju"], "Asc + Saturn - Jupiter", "Asc + Jupiter - Saturn", .reverse),
        natalHouse(1, "pillarOfHoroscope", "Pillar of horoscope, Nativities, permanence, constancy", ["Asc", "Sp", "F"], "Asc + Spirit - Fortune", "Asc + Fortune - Spirit", .reverse),
        natalHouse(1, "reasoningAndEloquence", "Reasoning and eloquence", ["Asc", "Ma", "Me"], "Asc + Mars - Mercury", "Asc + Mercury - Mars", .reverse),

        natalHouse(2, "property", "Property", ["Asc", "c2", "L2"], "Asc + cusp of 2nd - lord of 2nd", "Asc + lord of 2nd - cusp of 2nd", .reverse),
        natalHouse(2, "debt", "Debt", ["Asc", "Me", "Sa"], "Asc + Mercury - Saturn", "Asc + Saturn - Mercury", .reverse),
        natalHouse(2, "treasureTrove", "Treasure Trove", ["Asc", "Ve", "Me"], "Asc + Venus - Mercury", "Asc + Venus - Mercury", .same),

        natalHouse(3, "brothers", "Brothers", ["Asc", "Ju", "Sa"], "Asc + Jupiter - Saturn", "Asc + Jupiter - Saturn", .same),
        natalHouse(3, "numberOfBrothers", "Number of brothers", ["Asc", "Sa", "Me"], "Asc + Saturn - Mercury", "Asc + Saturn - Mercury", .same),
        natalHouse(3, "deathOfBrothersAndSisters", "Death of brothers & sisters", ["Asc", "Gemini10", "Su"], "Asc + 10 Gemini - Sun", "Asc + Sun - 10 Gemini", .reverse),

        natalHouse(4, "parents", "Parents", ["Asc", "Sa", "Su", "Ju"], "Asc + Saturn - Sun (or Jupiter)", "Asc + Sun (or Jupiter) - Saturn", .reverse, status: .partial),
        natalHouse(4, "deathOfParents", "Death of parents", ["Asc", "Ju", "Sa"], "Asc + Jupiter - Saturn", "Asc + Saturn - Jupiter", .reverse),
        natalHouse(4, "grandparents", "Grandparents", ["Asc", "Sa", "II"], "Asc + Saturn - II", "Asc + II - Saturn", .reverse, status: .partial),
        natalHouse(4, "ancestorsAndRelations", "Ancestors and relations", ["Asc", "Ma", "Sa"], "Asc + Mars - Saturn", "Asc + Saturn - Mars", .reverse, sourceOccurrenceCount: 2),
        natalHouse(4, "realEstateHermes", "Real estate a/t Hermes", ["Asc", "Mo", "Sa"], "Asc + Moon - Saturn", "Asc + Saturn - Moon", .reverse, tradition: "Hermes (as attributed by al-Biruni)"),
        natalHouse(4, "realEstatePersians", "Real estate a/t some Persians", ["Asc", "Ju", "Me"], "Asc + Jupiter - Mercury", "Asc + Mercury - Jupiter", .reverse, tradition: "some Persians (as attributed by al-Biruni)"),
        natalHouse(4, "agricultureTillage", "Agriculture, tillage", ["Asc", "Sa", "Ve"], "Asc + Saturn - Venus", "Asc + Saturn - Venus", .same),
        natalHouse(4, "issueOfAffairs", "Issue of affairs [end of matter]", ["Asc", "LastSyzygyLord", "Sa"], "Asc + Lord of last syzygy - Saturn", "Asc + Lord of last syzygy - Saturn", .same),

        natalHouse(5, "children", "Children", ["Asc", "Sa", "Ju", "Ve"], "Asc + Saturn - Jupiter (Venus)", "Asc + Jupiter (Venus) - Saturn", .reverse, status: .partial),
        natalHouse(5, "timeAndNumberOfSexes", "Time and number of sexes", ["Asc", "Ju", "Ma"], "Asc + Jupiter - Mars", "Asc + Jupiter - Mars", .same),
        natalHouse(5, "conditionOfMales", "Condition of males", ["Asc", "Ju", "Ma"], "Asc + Jupiter - Mars", "Asc + Jupiter - Mars", .same),
        natalHouse(5, "conditionOfFemales", "Condition of females", ["Asc", "Ve", "Mo"], "Asc + Venus - Moon", "Asc + Venus - Moon", .same),
        natalHouse(5, "expectedBirthSex", "Whether expected birth is male or female", ["Asc", "Mo", "MoonLord"], "Asc + Moon - lord of Moon", "Asc + lord of Moon - Moon", .reverse),

        natalHouse(6, "diseaseHermes", "Disease, defects, time of onset a/t Hermes", ["Asc", "Ma", "Sa"], "Asc + Mars - Saturn", "Asc + Saturn - Mars", .reverse, tradition: "Hermes (as attributed by al-Biruni)"),
        natalHouse(6, "diseaseAncients", "Disease, defects, time of onset a/t some of the ancients", ["Asc", "Ma", "Me"], "Asc + Mars - Mercury", "Asc + Mars - Mercury", .same, tradition: "some of the ancients (as attributed by al-Biruni)"),
        natalHouse(6, "captivity", "Captivity", ["Asc", "LordOfTimeDispositor", "LordOfTime"], "Asc + dispositor lord of time - lord of time", "Asc + dispositor lord of time - lord of time", .same),
        natalHouse(6, "slaves", "Slaves", ["Asc", "Mo", "Me"], "Asc + Moon - Mercury", "Asc + Moon - Mercury", .same),
    ]
}
