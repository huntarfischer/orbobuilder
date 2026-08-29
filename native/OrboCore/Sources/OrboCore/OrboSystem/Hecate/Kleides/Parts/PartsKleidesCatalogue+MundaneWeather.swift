extension PartsKleidesCatalogue {
    static let mundaneWeather: [PartCatalogueEntry] = [
        nonNatalPage(
            "parts.mundaneWeather.earth",
            sourceLabel: "Earth",
            context: .mundaneWeather,
            formulas: [
                sourceFormula(["Asc", "Ju", "Sa"], day: "Asc + Jupiter - Saturn", night: "Asc + Jupiter - Saturn", mark: .same),
            ]
        ),
        nonNatalPage(
            "parts.mundaneWeather.water",
            sourceLabel: "Water",
            context: .mundaneWeather,
            formulas: [
                sourceFormula(["Asc", "Ve", "Mo"], day: "Asc + Venus - Moon", night: "Asc + Venus - Moon", mark: .same),
            ]
        ),
        nonNatalPage(
            "parts.mundaneWeather.airAndWind",
            sourceLabel: "Air and Wind",
            context: .mundaneWeather,
            formulas: [
                sourceFormula(["Asc", "dispositor(Me)", "Me"], day: "Asc + dispositor of Mercury - Mercury", night: "Asc + dispositor of Mercury - Mercury", mark: .same),
            ]
        ),
        nonNatalPage(
            "parts.mundaneWeather.fire",
            sourceLabel: "Fire",
            context: .mundaneWeather,
            formulas: [
                sourceFormula(["Asc", "Ma", "Su"], day: "Asc + Mars - Sun", night: "Asc + Mars - Sun", mark: .same),
            ]
        ),
        nonNatalPage(
            "parts.mundaneWeather.clouds",
            sourceLabel: "Clouds",
            context: .mundaneWeather,
            formulas: [
                sourceFormula(["Asc", "Sa", "Ma"], day: "Asc + Saturn - Mars", night: "Asc + Mars - Saturn", mark: .reverse),
            ]
        ),
        nonNatalPage(
            "parts.mundaneWeather.rains",
            sourceLabel: "Rains",
            context: .mundaneWeather,
            formulas: [
                sourceFormula(["Asc", "Ve", "Mo"], day: "Asc + Venus - Moon", night: "Asc + Moon - Venus", mark: .reverse),
            ]
        ),
        nonNatalPage(
            "parts.mundaneWeather.cold",
            sourceLabel: "Cold",
            context: .mundaneWeather,
            formulas: [
                sourceFormula(["Asc", "Sa", "Me"], day: "Asc + Saturn - Mercury", night: "Asc + Mercury - Saturn", mark: .reverse),
            ]
        ),
        nonNatalPage(
            "parts.mundaneWeather.floods",
            sourceLabel: "Floods",
            context: .mundaneWeather,
            formulas: [
                sourceFormula(
                    ["Mo", "Su", "Sa", "Moon-rise"],
                    day: "Moon + Sun - Saturn",
                    night: "Moon + Sun - Saturn",
                    mark: .unmarked,
                    conditions: ["Cast chart at Moon-rise"]
                ),
            ]
        ),
    ]
}
