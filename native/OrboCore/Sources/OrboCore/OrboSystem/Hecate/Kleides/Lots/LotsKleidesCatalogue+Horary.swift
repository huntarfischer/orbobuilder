extension LotsKleidesCatalogue {
    static let horary: [Kleis] = [
        page("Secrets", context: .horary, l1: false, l2: false, formulas: [
            formula(["Asc", "c10", "LA"], "Asc + c10 - LA", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Horary lots", status: .complete),
        ]),
        page("Urgent wish", context: .horary, l1: false, l2: false, formulas: [
            formula(["Asc", "LA", "LH", "Sect"], "Asc + LA - LH", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Horary lots", status: .complete),
        ]),
        page("Time of attainment", context: .horary, l1: false, l2: false, formulas: [
            formula(["Asc", "L10", "LH", "Sect"], "Asc + L10 - LH", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Horary lots", status: .complete),
        ]),
        page("Information true or not", context: .horary, l1: false, l2: false, formulas: [
            formula(["Asc", "Mo", "Me", "Sect"], "Asc + Mo - Me", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Horary lots", status: .complete),
        ]),
        page("Injury to business", context: .horary, l1: false, l2: false, formulas: [
            formula(["Asc", "F", "LA"], "Asc + F - LA", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Horary lots", status: .complete),
        ]),
        page("Freedmen and servants", context: .horary, l1: false, l2: false, formulas: [
            formula(["Me", "Ju", "Sa"], "Me + Sa - Ju", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Horary lots", status: .complete),
        ]),
        page("Lords and masters", context: .horary, l1: false, l2: false, formulas: [
            formula(["Mo", "Ju", "Sa"], "Mo + Sa - Ju", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Horary lots", status: .complete),
        ]),
        page("Marriage (horary)", aliases: ["Marriage"], context: .horary, l1: false, l2: false, formulas: [
            formula(["Asc", "Ve", "c7"], "Asc + c7 - Ve", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Horary lots", status: .complete),
        ]),
        page("Time for action", context: .horary, l1: false, l2: false, formulas: [
            formula(["Asc", "Su", "Ju"], "Asc + Ju - Su", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Horary lots", status: .complete),
        ]),
        page("Time occupied therein", context: .horary, l1: false, l2: false, formulas: [
            formula(["Asc", "Su", "Sa"], "Asc + Sa - Su", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Horary lots", status: .complete),
        ]),
        page("Dismissal or resignation", context: .horary, l1: false, l2: false, formulas: [
            formula(["Su", "Ju"], "Ju + Ju - Su", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Horary lots", status: .complete),
        ]),
    ]
}
