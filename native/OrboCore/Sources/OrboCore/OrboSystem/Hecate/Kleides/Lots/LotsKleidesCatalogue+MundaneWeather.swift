extension LotsKleidesCatalogue {
    static let mundaneWeather: [Kleis] = [
        page("Earth", context: .mundaneWeather, l1: false, l2: false, formulas: [
            formula(["Asc", "Ju", "Sa"], "Asc + Ju - Sa", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions", status: .complete),
        ]),
        page("Water", context: .mundaneWeather, l1: false, l2: false, formulas: [
            formula(["Asc", "Mo", "Ve"], "Asc + Ve - Mo", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions", status: .complete),
        ]),
        page("Air and wind", context: .mundaneWeather, l1: false, l2: false, formulas: [
            formula(["Asc", "Me", "dispositor(Me)"], "Asc + dispositor(Me) - Me", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions", status: .complete),
        ]),
        page("Fire", context: .mundaneWeather, l1: false, l2: false, formulas: [
            formula(["Asc", "Su", "Ma"], "Asc + Ma - Su", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions", status: .complete),
        ]),
        page("Clouds", context: .mundaneWeather, l1: false, l2: false, formulas: [
            formula(["Asc", "Ma", "Sa", "Sect"], "Asc + Sa - Ma", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions", status: .complete),
        ]),
        page("Rains", context: .mundaneWeather, l1: false, l2: false, formulas: [
            formula(["Asc", "Mo", "Ve", "Sect"], "Asc + Ve - Mo", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions", status: .complete),
        ]),
        page("Cold", context: .mundaneWeather, l1: false, l2: false, formulas: [
            formula(["Asc", "Me", "Sa", "Sect"], "Asc + Sa - Me", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions", status: .complete),
        ]),
        page("Floods", context: .mundaneWeather, l1: false, l2: false, formulas: [
            formula(["Su", "Mo", "Sa", "Moon-rise"], "Mo + Su - Sa cast at Moon-rise", "al-Bīrūnī / Abū Maʿshar", .none, condition: "cast at Moon-rise", source: "Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions", status: .complete),
        ]),
    ]
}
