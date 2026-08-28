extension LotsKleidesCatalogue {
    static let natalA: [Kleis] = [
        page("Fortune", aliases: ["Lot of Fortune", "Lot of the Moon", "Pars Fortunae", "Tychē", "Part of Fortune", "Lunar horoscope"], context: .natal, l1: true, l2: true, formulas: [
            KleisFormula(
                requiredResources: resources(["Asc", "Mo", "Su", "Sect"]),
                formula: "Asc + Mo - Su",
                tradition: "Mainstream Hellenistic / Valens",
                sectRule: .reverse,
                isOrboDefault: true,
                sources: ["Report: Foundational Hellenistic"],
                status: .complete
            )!,
            formula(["Asc", "Mo", "Su"], "Asc + Mo - Su", "Ptolemy", .same, source: "Report: Foundational Hellenistic", status: .complete),
            formula(["Asc", "Su", "Mo", "Sect"], "Asc + Mo - Su", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes", status: .complete),
        ]),
        page("Spirit", aliases: ["Lot of Spirit", "Daimon", "Lot of the Sun", "Pars Daemonis", "Daemon and religion"], context: .natal, l1: true, l2: true, formulas: [
            KleisFormula(
                requiredResources: resources(["Asc", "Su", "Mo", "Sect"]),
                formula: "Asc + Su - Mo",
                tradition: "Hellenistic mainstream",
                sectRule: .reverse,
                isOrboDefault: true,
                sources: ["Report: Foundational Hellenistic"],
                status: .complete
            )!,
            formula(["Asc", "Su", "Mo", "Sect"], "Asc + Su - Mo", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes", status: .complete),
        ]),
        page("Valens Eros", aliases: ["Eros", "Love", "Valens Love"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Sp", "F", "Sect"], "Asc + Sp - F", "Valens", .reverse, source: "Report: Foundational Hellenistic", status: .complete),
        ]),
        page("Valens Necessity", aliases: ["Necessity", "Anankē"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "F", "Sp", "Sect"], "Asc + F - Sp", "Valens", .reverse, source: "Report: Foundational Hellenistic", status: .complete),
        ]),
        page("Eros", aliases: ["Planetary Love (Venus)", "Planetary Love", "Lot of Venus"], context: .natal, l1: true, l2: true, formulas: [
            KleisFormula(
                requiredResources: resources(["Asc", "Ve", "Sp", "Sect"]),
                formula: "Asc + Ve - Sp",
                tradition: "Pauline/Hermetic",
                sectRule: .reverse,
                isOrboDefault: true,
                sources: [
                    "Legacy Orbo engines: astrodna.js / zr.js",
                    "Report: Foundational Hellenistic — planetary Love/Venus identity only; exact formula not supplied",
                ],
                status: .complete
            )!,
        ]),
        page("Necessity", aliases: ["Planetary Necessity (Mercury)", "Planetary Necessity", "Lot of Mercury"], context: .natal, l1: true, l2: true, formulas: [
            KleisFormula(
                requiredResources: resources(["Asc", "F", "Me", "Sect"]),
                formula: "Asc + F - Me",
                tradition: "Pauline/Hermetic",
                sectRule: .reverse,
                isOrboDefault: true,
                sources: [
                    "Legacy Orbo engines: astrodna.js / zr.js",
                    "Report: Foundational Hellenistic — planetary Necessity/Mercury identity only; exact formula not supplied",
                ],
                status: .complete
            )!,
        ]),
        page("Basis", aliases: ["Foundation"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Love", "Necessity", "Horizon"], "choose whichever of Love or Necessity is below horizon", "Valens", .none, condition: "same principle by day/night", source: "Report: Foundational Hellenistic", status: .complete),
        ]),
        page("Exaltation", aliases: ["Hypsoma / Exaltation lot"], context: .natal, l1: false, l2: false, formulas: [
            formula(["unresolved"], "source-dependent", "Valens / related", .unresolved, condition: "Report does not give a stable formula", source: "Report: Foundational Hellenistic", status: .unresolved),
        ]),
        page("Affliction", aliases: ["Chronic Illness", "Injury", "Crisis-Producing Place", "Accusation"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ma", "Sa", "Sect"], "Asc + Ma - Sa", "Dorotheus / Valens", .reverse, source: "Report: Foundational Hellenistic", status: .complete),
        ]),
        page("Father", aliases: ["Pars Patris"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Sa", "Su", "Sect"], "Asc + Sa - Su", "Dorotheus / Valens / Paulus", .reverse, condition: "ordinary formula", source: "Report: Foundational Hellenistic", status: .complete),
            formula(["Asc", "Ju", "Ma", "Sa solar condition"], "Asc + Ju - Ma", "Dorotheus / Paulus", .same, condition: "combust-Saturn / Saturn-under-beams override", source: "Report: Foundational Hellenistic", status: .complete),
        ]),
        page("Mother", aliases: ["Pars Matris", "Mothers"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Mo", "Ve", "Sect"], "Asc + Mo - Ve", "Dorotheus / Paulus", .reverse, source: "Report: Foundational Hellenistic", status: .complete),
            formula(["Asc", "Mo", "Ve", "Sect"], "Asc + Mo - Ve", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Tenth house", status: .complete),
        ]),
        page("Siblings", aliases: ["Brothers", "Pars Fratrum"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ju", "Sa"], "Asc + Ju - Sa", "Paulus / Dorothean line", .same, condition: "primary sibling lot", source: "Report: Foundational Hellenistic", status: .complete),
            formula(["Asc", "Ju", "Sa", "Sect"], "Asc + Ju - Sa", "Valens / Maternus tradition", .reverse, condition: "primary sibling lot", source: "Report: Foundational Hellenistic", status: .complete),
            formula(["Asc", "Ju", "Me", "Sect"], "Asc + Ju - Me", "Dorotheus", .reverse, condition: "secondary sibling lot", source: "Report: Foundational Hellenistic", status: .complete),
            formula(["Asc", "Ju", "Sa"], "Asc + Ju - Sa", "al-Bīrūnī / Abū Maʿshar", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Third house", status: .complete),
        ]),
        page("Children", aliases: ["Pars Filiorum"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Sa", "Ju"], "Asc + Sa - Ju", "Dorotheus / Paulus", .same, condition: "Paulus/non-reversing line", source: "Report: Foundational Hellenistic", status: .complete),
            formula(["Asc", "Sa", "Ju", "Sect"], "Asc + Sa - Ju", "Medieval / Arabic practice", .reverse, condition: "reversing line", source: "Report: Foundational Hellenistic", status: .complete),
            formula(["Asc", "Ve", "Ju", "Sa", "Sect"], "Asc + Sa - Ju or (Ve)", "al-Bīrūnī / Abū Maʿshar", .reverse, condition: "source gives 'Asc + Sa - Ju or (Ve)'; alternate is not fully specified", source: "Report: al-Bīrūnī/Abū Maʿshar — Fifth house", status: .partial),
        ]),
        page("Sons", aliases: ["male children"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Me", "Ju"], "Asc + Me - Ju", "Valens", .same, source: "Report: Foundational Hellenistic", status: .complete),
        ]),
        page("Daughters", aliases: ["female children"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ve", "Ju"], "Asc + Ve - Ju", "Valens", .same, source: "Report: Foundational Hellenistic", status: .complete),
        ]),
        page("Marriage", aliases: ["general marriage"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ve", "Ju", "Sect"], "Asc + Ve - Ju", "Valens", .reverse, condition: "general marriage lot", source: "Report: Foundational Hellenistic", status: .complete),
        ]),
        page("Marriage-Bringer (male, Valens)", aliases: ["wife lot in Valens", "Marriage of men according to Valens"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ve", "Su"], "Asc + Ve - Su", "Valens", .unresolved, condition: "night formula described as probably same", source: "Report: Foundational Hellenistic", status: .partial),
            formula(["Asc", "Su", "Ve"], "Asc + Ve - Su", "al-Bīrūnī / Abū Maʿshar; Valens attribution", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Seventh house", status: .complete),
        ]),
        page("Marriage-Bringer (female, Valens)", aliases: ["husband lot in Valens", "Marriage of women according to Valens"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ma", "Mo"], "Asc + Ma - Mo", "Valens", .unresolved, condition: "night formula described as probably same", source: "Report: Foundational Hellenistic", status: .partial),
            formula(["Asc", "Mo", "Ma"], "Asc + Ma - Mo", "al-Bīrūnī / Abū Maʿshar; Valens attribution", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Seventh house", status: .complete),
        ]),
        page("Marriage (male, Hermes/Dorotheus-Paulus)", aliases: ["wife lot", "Marriage of men according to Hermes"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ve", "Sa"], "Asc + Ve - Sa", "Dorotheus / Paulus", .same, condition: "wife lot / male nativity", source: "Report: Foundational Hellenistic", status: .complete),
            formula(["Asc", "Ve", "Sa"], "Asc + Ve - Sa", "al-Bīrūnī / Abū Maʿshar; Hermes attribution", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Seventh house", status: .complete),
        ]),
        page("Marriage (female, Hermes/Dorotheus-Paulus)", aliases: ["husband lot", "Marriage of women according to Hermes"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Sa", "Ve"], "Asc + Sa - Ve", "Dorotheus / Paulus", .same, condition: "husband lot / female nativity", source: "Report: Foundational Hellenistic", status: .complete),
            formula(["Asc", "Ve", "Sa"], "Asc + Sa - Ve", "al-Bīrūnī / Abū Maʿshar; Hermes attribution", .same, source: "Report: al-Bīrūnī/Abū Maʿshar — Seventh house", status: .complete),
        ]),
        page("Pleasure and Wedding", aliases: ["Dorothean marriage lot"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "c7", "Ve"], "Asc + c7 - Ve", "Dorotheus", .same, source: "Report: Foundational Hellenistic", status: .complete),
        ]),
        page("Wedding by luminaries", aliases: ["projected from Venus or Mars"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Ma", "Mo", "Su"], "Ma + Mo - Su", "Dorotheus", .same, condition: "men", source: "Report: Foundational Hellenistic", status: .complete),
            formula(["Ve", "Mo", "Su"], "Ve + Mo - Su", "Dorotheus", .same, condition: "women", source: "Report: Foundational Hellenistic", status: .complete),
        ]),
        page("Anaireta / Destroyer", aliases: ["destroyer lot", "Anairetai / destroyer"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Mo", "LA"], "Asc + Mo - LA", "Valens / later compendia", .unresolved, condition: "night reversal reported only in some sources", source: "Report: Foundational Hellenistic", status: .partial),
            formula(["Asc", "Mo", "LA", "Sect"], "Asc + Mo - LA", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Eighth house", status: .complete),
        ]),
        page("Adultery", aliases: ["opposition to Valens general marriage"], context: .natal, l1: false, l2: false, formulas: [
            formula(["Marriage"], "opposite Marriage lot", "Valens", .conditional, condition: "inherits the Valens general Marriage lot", source: "Report: Foundational Hellenistic", status: .complete),
        ]),
        page("Friendship and love", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "F", "Sp", "Sect"], "Asc + Sp - F", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes", status: .complete),
        ]),
        page("Despair, penury, fraud", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "F", "Sp", "Sect"], "Asc + F - Sp", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes", status: .complete),
        ]),
        page("Captivity, prisons, escape", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Sa", "F", "Sect"], "Asc + F - Sa", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes", status: .complete),
        ]),
        page("Victory, triumph, aid", context: .natal, l1: false, l2: false, formulas: [
            formula(["Asc", "Ju", "Sp", "Sect"], "Asc + Ju - Sp", "al-Bīrūnī / Abū Maʿshar", .reverse, source: "Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes", status: .complete),
        ]),
    ]
}
