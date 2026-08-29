extension PartsKleidesCatalogue {
    static let horary: [PartCatalogueEntry] = [
        nonNatalPage("parts.horary.secrets", sourceLabel: "Secrets", context: .horary, formulas: [sourceFormula(["Asc", "C10", "LordAsc"], day: "Asc + Cusp of 10th - Lord of Asc", night: "Asc + Cusp of 10th - Lord of Asc", mark: .same)]),
        nonNatalPage("parts.horary.urgentWish", sourceLabel: "Urgent wish", context: .horary, formulas: [sourceFormula(["Asc", "LordAsc", "LordHour"], day: "Asc + Lord of Asc - Lord of hour", night: "Asc + Lord of hour - Lord of Asc", mark: .reverse)]),
        nonNatalPage("parts.horary.timeOfAttainment", sourceLabel: "Time of attainment", context: .horary, formulas: [sourceFormula(["Asc", "L10", "LordHour"], day: "Asc + Lord of 10th - Lord of hour", night: "Asc + Lord of hour - Lord of 10th", mark: .reverse)]),
        nonNatalPage("parts.horary.informationTrueOrNot", sourceLabel: "Information true or not", context: .horary, formulas: [sourceFormula(["Asc", "Mo", "Me"], day: "Asc + Moon - Mercury", night: "Asc + Mercury - Moon", mark: .reverse)]),
        nonNatalPage("parts.horary.injuryToBusiness", sourceLabel: "Injury to business", context: .horary, formulas: [sourceFormula(["Asc", "F", "LordAsc"], day: "Asc + Fortune - Lord of Asc", night: "Asc + Fortune - Lord of Asc", mark: .same)]),
        nonNatalPage("parts.horary.freedmenAndServants", sourceLabel: "Freedmen and servants", context: .horary, formulas: [sourceFormula(["Me", "Sa", "Ju"], day: "Mercury + Saturn - Jupiter", night: "Mercury + Saturn - Jupiter", mark: .same)]),
        nonNatalPage("parts.horary.lordsAndMasters", sourceLabel: "Lords and masters", context: .horary, formulas: [sourceFormula(["Mo", "Sa", "Ju"], day: "Moon - Saturn - Jupiter", night: "Moon - Saturn - Jupiter", mark: .same)]),
        nonNatalPage("parts.horary.marriage", sourceLabel: "Marriage", context: .horary, formulas: [sourceFormula(["Asc", "C7", "Ve"], day: "Asc + Cusp 7th - Venus", night: "Asc + Cusp 7th - Venus", mark: .same)]),
        nonNatalPage("parts.horary.timeForAction", sourceLabel: "Time for action", context: .horary, formulas: [sourceFormula(["Asc", "Ju", "Su"], day: "Asc + Jupiter - Sun", night: "Asc + Jupiter - Sun", mark: .same)]),
        nonNatalPage("parts.horary.timeOccupiedTherein", sourceLabel: "Time occupied therein", context: .horary, formulas: [sourceFormula(["Asc", "Sa", "Su"], day: "Asc + Saturn - Sun", night: "Asc + Saturn - Sun", mark: .same)]),
        nonNatalPage("parts.horary.dismissalOrResignation", sourceLabel: "Dismissal or resignation", context: .horary, formulas: [sourceFormula(["Ju", "Su"], day: "Jupiter + Jupiter - Sun", night: "Jupiter + Jupiter - Sun", mark: .same)]),
        nonNatalPage("parts.horary.timeThereof", sourceLabel: "Time thereof", context: .horary, formulas: [sourceFormula(["C10", "F", "LordAffair"], day: "Cusp 10th + Fortune - Lord of the affair", night: "Cusp 10th + Fortune - Lord of the affair", mark: .same)]),
        nonNatalPage("parts.horary.lifeOrDeathOfAbsentPerson", sourceLabel: "Life or death of absent person", context: .horary, formulas: [sourceFormula(["Asc", "Ma", "Mo"], day: "Asc + Mars - Moon", night: "Asc + Mars - Moon", mark: .same)]),
        nonNatalPage("parts.horary.lostAnimal", sourceLabel: "Lost animal", context: .horary, formulas: [sourceFormula(["Asc", "Ma", "Su"], day: "Asc + Mars - Sun", night: "Asc + Mars - Sun", mark: .same)]),
        nonNatalPage("parts.horary.lawsuit", sourceLabel: "Lawsuit", context: .horary, formulas: [sourceFormula(["Asc", "Me", "Ma"], day: "Asc + Mercury - Mars", night: "Asc + Mercury - Mars", mark: .same)]),
        nonNatalPage("parts.horary.successfulIssue", sourceLabel: "Successful issue [outcome]", context: .horary, formulas: [sourceFormula(["Asc", "Ju", "Su"], day: "Asc + Jupiter - Sun", night: "Asc + Jupiter - Sun", mark: .same)]),
        nonNatalPage("parts.horary.decapitation", sourceLabel: "Decapitation", context: .horary, formulas: [sourceFormula(["C8", "Ma", "Mo"], day: "Cusp 8th + Mars - Moon", night: "Cusp 8th + Mars - Moon", mark: .same)]),
        nonNatalPage("parts.horary.torture", sourceLabel: "Torture", context: .horary, formulas: [sourceFormula(["C9", "Sa", "Mo"], day: "Cusp 9th + Saturn - Moon", night: "Cusp 9th + Saturn - Moon", mark: .same)]),
    ]
}
