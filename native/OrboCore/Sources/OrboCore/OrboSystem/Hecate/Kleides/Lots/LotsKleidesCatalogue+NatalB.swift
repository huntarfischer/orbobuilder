extension LotsKleidesCatalogue {
    static let natalB: [Kleis] = [
        page("Valour and bravery", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ma", "F", "Sect"], "Asc + F - Ma", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes", status: .complete),
        ]),
        page("Life", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ju", "Sa", "Sect"], "Asc + Sa - Ju", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — First house", status: .complete),
        ]),
        page("Pillar of horoscope; permanence; constancy", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "F", "Sp", "Sect"], "Asc + Sp - F", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — First house", status: .complete),
        ]),
        page("Reasoning and eloquence", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Me", "Ma", "Sect"], "Asc + Ma - Me", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — First house", status: .complete),
        ]),
        page("Property", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "c2", "L2", "Sect"], "Asc + c2 - L2", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Second house", status: .complete),
        ]),
        page("Debt", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Me", "Sa", "Sect"], "Asc + Me - Sa", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Second house", status: .complete),
        ]),
        page("Treasure trove", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Me", "Ve"], "Asc + Ve - Me", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Second house", status: .complete),
        ]),
        page("Number of brothers", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Me", "Sa"], "Asc + Sa - Me", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Third house", status: .complete),
        ]),
        page("Death of brothers and sisters", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Su", "Sect"], "Asc + 10° Gemini - Su", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Third house", status: .complete),
        ]),
        page("Parents", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Su", "Sa", "Sect"], "Asc + Sa - Su", "al-Bīrūnī / Abū Maʿshar", .reverse, condition: "source table gives two alternatives", source: "Report: al-Bīrūnī/Abū Maʿshar — Fourth house", status: .complete),
            formula(["Asc", "Ju", "Sa", "Sect"], "Asc + Sa - Ju", "al-Bīrūnī / Abū Maʿshar", .reverse, condition: "source table gives two alternatives", source: "Report: al-Bīrūnī/Abū Maʿshar — Fourth house", status: .complete),
        ]),
        page("Death of parents", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ju", "Sa", "Sect"], "Asc + Ju - Sa", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Fourth house", status: .complete),
        ]),
        page("Grandparents", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Sa", "II", "Sect"], "Asc + Sa - II", "al-Bīrūnī / Abū Maʿshar", .reverse, condition: "symbol II is not defined in the report", source: "Report: al-Bīrūnī/Abū Maʿshar — Fourth house", status: .partial),
        ]),
        page("Ancestors and relations", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ma", "Sa", "Sect"], "Asc + Ma - Sa", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Fourth house", status: .complete),
        ]),
        page("Real estate according to Hermes", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Mo", "Sa", "Sect"], "Asc + Mo - Sa", "al-Bīrūnī / Abū Maʿshar; Hermes attribution", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Fourth house", status: .complete),
        ]),
        page("Real estate according to some Persians", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Me", "Ju", "Sect"], "Asc + Ju - Me", "al-Bīrūnī / Abū Maʿshar; Persian attribution", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Fourth house", status: .complete),
        ]),
        page("Agriculture, tillage", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ve", "Sa"], "Asc + Sa - Ve", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Fourth house", status: .complete),
        ]),
        page("Issue of affairs; end of matter", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Sa", "LSy"], "Asc + LSy - Sa", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Fourth house", status: .complete),
        ]),
        page("Time and number of sexes", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ma", "Ju"], "Asc + Ju - Ma", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Fifth house", status: .complete),
        ]),
        page("Condition of males", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ma", "Ju"], "Asc + Ju - Ma", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Fifth house", status: .complete),
        ]),
        page("Condition of females", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Mo", "Ve"], "Asc + Ve - Mo", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Fifth house", status: .complete),
        ]),
        page("Whether expected birth is male or female", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Mo", "lord(Mo)", "Sect"], "Asc + Mo - lord(Mo)", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Fifth house", status: .complete),
        ]),
        page("Disease, defects, onset according to Hermes", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ma", "Sa", "Sect"], "Asc + Ma - Sa", "al-Bīrūnī / Abū Maʿshar; Hermes attribution", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Sixth house", status: .complete),
        ]),
        page("Disease according to some ancients", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Me", "Ma"], "Asc + Ma - Me", "al-Bīrūnī / Abū Maʿshar; ancient attribution", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Sixth house", status: .complete),
        ]),
        page("Captivity (sixth-house)", aliases: ["Captivity"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "LT", "dispositor(LT)"], "Asc + dispositor(LT) - LT", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Sixth house", status: .complete),
        ]),
        page("Slaves", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Mo", "Me"], "Asc + Mo - Me", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Sixth house", status: .complete),
        ]),
        page("Trickery and deception of men and women", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Su", "Ve"], "Asc + Ve - Su", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Seventh house", status: .complete),
        ]),
        page("Intercourse (men)", aliases: ["Intercourse"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Su", "Ve"], "Asc + Ve - Su", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Seventh house", status: .complete),
        ]),
        page("Misconduct by women", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Mo", "Ma"], "Asc + Ma - Mo", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Seventh house", status: .complete),
        ]),
    ]
}
