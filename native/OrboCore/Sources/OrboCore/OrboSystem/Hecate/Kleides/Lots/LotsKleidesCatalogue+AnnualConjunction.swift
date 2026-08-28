extension LotsKleidesCatalogue {
    static let annualConjunction: [Kleis] = [
        page("Sultan's Lot", context: .annualConjunction, l1: false, l2: false, formulas: [
            formula(["Ju", "MC", "MC(return)"], "Ju + MC(return) - MC or (Sun)", "al-Bīrūnī / Abū Maʿshar", .same, condition: "source gives 'Ju + MC(return) - MC or (Sun)'", source: "Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions", status: .partial),
            formula(["Asc", "degree(conjunction)", "Asc(conjunction)"], "Asc + degree(conjunction) - degree(Asc of conjunction)", "al-Bīrūnī / Abū Maʿshar", .same, condition: "alternative Sultan's Lot formula", source: "Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions", status: .complete),
        ]),
        page("Victory (annual/conjunction)", aliases: ["Victory"], context: .annualConjunction, l1: false, l2: false, formulas: [
            formula(["Asc", "Su", "Desc", "L7"], "Asc + L7 or Desc-degree - Su", "al-Bīrūnī / Abū Maʿshar", .same, condition: "source gives 'L7 or Desc-degree' as alternative operand", source: "Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions", status: .partial),
        ]),
        page("Battle", context: .annualConjunction, l1: false, l2: false, formulas: [
            formula(["Mo", "Ma", "Lot of Victory"], "degree(Lot of Victory) + Mo - Ma", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions", status: .complete),
            formula(["Asc", "Mo", "Ma"], "Asc + Mo - Ma", "al-Bīrūnī / Abū Maʿshar; Umar attribution", .same, condition: "alternate Battle formula", source: "Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions", status: .complete),
            formula(["Asc", "Mo", "Sa"], "Asc + Mo - Sa", "al-Bīrūnī / Abū Maʿshar; al-Furkhan attribution", .same, condition: "alternate Battle formula", source: "Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions", status: .complete),
        ]),
        page("Truce between armies", context: .annualConjunction, l1: false, l2: false, formulas: [
            formula(["Asc", "Mo", "Me"], "Asc + Me - Mo", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions", status: .complete),
        ]),
        page("Conquest", context: .annualConjunction, l1: false, l2: false, formulas: [
            formula(["Asc", "Su", "Ma"], "Asc + Ma - Su", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions", status: .complete),
        ]),
        page("Triumph", context: .annualConjunction, l1: false, l2: false, formulas: [
            formula(["Asc", "Ju", "F", "Sect"], "Asc + Ju - F", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions", status: .complete),
        ]),
        page("First conjunction", context: .annualConjunction, l1: false, l2: false, formulas: [
            formula(["Asc", "degree(conjunction)", "Asc(year conjunction)"], "Asc + degree(conjunction) - Asc(year conjunction)", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions", status: .complete),
        ]),
        page("Second conjunction", context: .annualConjunction, l1: false, l2: false, formulas: [
            formula(["Asc", "degree(conjunction)", "Asc(conjunction)"], "Asc + degree(conjunction) - Asc(conjunction)", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions", status: .complete),
        ]),
    ]
}
