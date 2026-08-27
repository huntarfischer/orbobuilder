# Hecate Kleides — Lots Catalogue

Status: Pass 2 source reconciliation. Design/data only. No casting code.

## Pass 1 schema

Each row is one formula attestation/variant for one Kleis page.

- **Kleis-level:** Kleis, Aliases, Family, L1, L2, L3
- **Formula-level:** Requirements, Formula, Tradition, Sect Rule, Conditions, Orbo Default, Source, Status
- Legal availability states are `T/T/T`, `F/T/T`, and `F/F/T`.
- `Status` is formula-row level.
- `Orbo Default` remains `F` throughout this pass. Lot defaults are deliberately reserved for the later Orbo-default design pass.
- `L2` is deliberately not curated in this source-ingestion pass. The agreed first four are `T/T/T`; every other admitted spell is `F/F/T`.

## Audit

- Source catalogue entries accounted for: **177 / 177**
- Reconciled Kleis pages: **162**
- Formula rows after splitting source entries that contain explicit variants: **182**
- Distinct formula cells: **86**
- Distinct formula cells shared by more than one Kleis page: **35**

The difference between 177 source entries and 182 formula rows comes from source entries that contain more than one explicit formula tradition or conditional formula. No source entry is discarded.

## Abbreviation key

`Asc` Ascendant · `Su` Sun · `Mo` Moon · `Me` Mercury · `Ve` Venus · `Ma` Mars · `Ju` Jupiter · `Sa` Saturn · `F` Fortune · `Sp` Spirit · `cN` house cusp N · `LN` lord of house N · `LA` lord of Ascendant · `LSy` lord of preceding syzygy · `LT` lord of time · `LH` lord of hour.

`II` is preserved exactly as it appears in the source report and is marked partial because the report does not define that symbol.

## Catalogue

| Kleis | Aliases | Family | L1 | L2 | L3 | Requirements | Formula | Tradition | Sect Rule | Conditions | Orbo Default | Source | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Fortune | Lot of Fortune; Lot of the Moon; Pars Fortunae; Tychē; Part of Fortune; Lunar horoscope | Lots | T | T | T | Asc, Mo, Su, Sect | Asc + Mo - Su | Mainstream Hellenistic / Valens | reverse | — | F | Report: Foundational Hellenistic | complete |
| Fortune | Lot of Fortune; Lot of the Moon; Pars Fortunae; Tychē; Part of Fortune; Lunar horoscope | Lots | T | T | T | Asc, Mo, Su | Asc + Mo - Su | Ptolemy | same | — | F | Report: Foundational Hellenistic | complete |
| Spirit | Lot of Spirit; Daimon; Lot of the Sun; Pars Daemonis; Daemon and religion | Lots | T | T | T | Asc, Su, Mo, Sect | Asc + Su - Mo | Hellenistic mainstream | reverse | — | F | Report: Foundational Hellenistic | complete |
| Eros | Love; Valens Love | Lots | T | T | T | Asc, Sp, F, Sect | Asc + Sp - F | Valens | reverse | — | F | Report: Foundational Hellenistic | complete |
| Necessity | Valens Necessity; Anankē | Lots | T | T | T | Asc, F, Sp, Sect | Asc + F - Sp | Valens | reverse | — | F | Report: Foundational Hellenistic | complete |
| Planetary Love (Venus) | Planetary Love; Lot of Venus | Lots | F | F | T | unresolved | various later planetary forms | Paulus line | unresolved | Report gives no exact planetary formula | F | Report: Foundational Hellenistic | unresolved |
| Planetary Necessity (Mercury) | Planetary Necessity; Lot of Mercury | Lots | F | F | T | unresolved | various later planetary forms | Paulus line | unresolved | Report gives no exact planetary formula | F | Report: Foundational Hellenistic | unresolved |
| Basis | Foundation | Lots | F | F | T | Love, Necessity, Horizon | choose whichever of Love or Necessity is below horizon | Valens | none | same principle by day/night | F | Report: Foundational Hellenistic | complete |
| Exaltation | Hypsoma / Exaltation lot | Lots | F | F | T | unresolved | source-dependent | Valens / related | unresolved | Report does not give a stable formula | F | Report: Foundational Hellenistic | unresolved |
| Affliction | Chronic Illness; Injury; Crisis-Producing Place; Accusation | Lots | F | F | T | Asc, Ma, Sa, Sect | Asc + Ma - Sa | Dorotheus / Valens | reverse | — | F | Report: Foundational Hellenistic | complete |
| Father | Pars Patris | Lots | F | F | T | Asc, Sa, Su, Sect | Asc + Sa - Su | Dorotheus / Valens / Paulus | reverse | ordinary formula | F | Report: Foundational Hellenistic | complete |
| Father | Pars Patris | Lots | F | F | T | Asc, Ju, Ma, Sa solar condition | Asc + Ju - Ma | Dorotheus / Paulus | same | combust-Saturn / Saturn-under-beams override | F | Report: Foundational Hellenistic | complete |
| Mother | Pars Matris; Mothers | Lots | F | F | T | Asc, Mo, Ve, Sect | Asc + Mo - Ve | Dorotheus / Paulus | reverse | — | F | Report: Foundational Hellenistic | complete |
| Siblings | Brothers; Pars Fratrum | Lots | F | F | T | Asc, Ju, Sa | Asc + Ju - Sa | Paulus / Dorothean line | same | primary sibling lot | F | Report: Foundational Hellenistic | complete |
| Siblings | Brothers; Pars Fratrum | Lots | F | F | T | Asc, Ju, Sa, Sect | Asc + Ju - Sa | Valens / Maternus tradition | reverse | primary sibling lot | F | Report: Foundational Hellenistic | complete |
| Siblings | Brothers; Pars Fratrum | Lots | F | F | T | Asc, Ju, Me, Sect | Asc + Ju - Me | Dorotheus | reverse | secondary sibling lot | F | Report: Foundational Hellenistic | complete |
| Children | Pars Filiorum | Lots | F | F | T | Asc, Sa, Ju | Asc + Sa - Ju | Dorotheus / Paulus | same | Paulus/non-reversing line | F | Report: Foundational Hellenistic | complete |
| Children | Pars Filiorum | Lots | F | F | T | Asc, Sa, Ju, Sect | Asc + Sa - Ju | Medieval / Arabic practice | reverse | reversing line | F | Report: Foundational Hellenistic | complete |
| Sons | male children | Lots | F | F | T | Asc, Me, Ju | Asc + Me - Ju | Valens | same | — | F | Report: Foundational Hellenistic | complete |
| Daughters | female children | Lots | F | F | T | Asc, Ve, Ju | Asc + Ve - Ju | Valens | same | — | F | Report: Foundational Hellenistic | complete |
| Marriage | general marriage | Lots | F | F | T | Asc, Ve, Ju, Sect | Asc + Ve - Ju | Valens | reverse | general marriage lot | F | Report: Foundational Hellenistic | complete |
| Marriage-Bringer (male, Valens) | wife lot in Valens; Marriage of men according to Valens | Lots | F | F | T | Asc, Ve, Su | Asc + Ve - Su | Valens | unresolved | night formula described as probably same | F | Report: Foundational Hellenistic | partial |
| Marriage-Bringer (female, Valens) | husband lot in Valens; Marriage of women according to Valens | Lots | F | F | T | Asc, Ma, Mo | Asc + Ma - Mo | Valens | unresolved | night formula described as probably same | F | Report: Foundational Hellenistic | partial |
| Marriage (male, Hermes/Dorotheus-Paulus) | wife lot; Marriage of men according to Hermes | Lots | F | F | T | Asc, Ve, Sa | Asc + Ve - Sa | Dorotheus / Paulus | same | wife lot / male nativity | F | Report: Foundational Hellenistic | complete |
| Marriage (female, Hermes/Dorotheus-Paulus) | husband lot; Marriage of women according to Hermes | Lots | F | F | T | Asc, Sa, Ve | Asc + Sa - Ve | Dorotheus / Paulus | same | husband lot / female nativity | F | Report: Foundational Hellenistic | complete |
| Pleasure and Wedding | Dorothean marriage lot | Lots | F | F | T | Asc, c7, Ve | Asc + c7 - Ve | Dorotheus | same | — | F | Report: Foundational Hellenistic | complete |
| Wedding by luminaries | projected from Venus or Mars | Lots | F | F | T | Ma, Mo, Su | Ma + Mo - Su | Dorotheus | same | men | F | Report: Foundational Hellenistic | complete |
| Wedding by luminaries | projected from Venus or Mars | Lots | F | F | T | Ve, Mo, Su | Ve + Mo - Su | Dorotheus | same | women | F | Report: Foundational Hellenistic | complete |
| Anaireta / Destroyer | destroyer lot; Anairetai / destroyer | Lots | F | F | T | Asc, Mo, LA | Asc + Mo - LA | Valens / later compendia | unresolved | night reversal reported only in some sources | F | Report: Foundational Hellenistic | partial |
| Adultery | opposition to Valens general marriage | Lots | F | F | T | Marriage | opposite Marriage lot | Valens | conditional | inherits the Valens general Marriage lot | F | Report: Foundational Hellenistic | complete |
| Fortune | Lot of Fortune; Lot of the Moon; Pars Fortunae; Tychē; Part of Fortune; Lunar horoscope | Lots | T | T | T | Asc, Mo, Su, Sect | Asc + Mo - Su | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes | complete |
| Spirit | Lot of Spirit; Daimon; Lot of the Sun; Pars Daemonis; Daemon and religion | Lots | T | T | T | Asc, Su, Mo, Sect | Asc + Su - Mo | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes | complete |
| Friendship and love | — | Lots | F | F | T | Asc, Sp, F, Sect | Asc + Sp - F | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes | complete |
| Despair, penury, fraud | — | Lots | F | F | T | Asc, F, Sp, Sect | Asc + F - Sp | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes | complete |
| Captivity, prisons, escape | — | Lots | F | F | T | Asc, F, Sa, Sect | Asc + F - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes | complete |
| Victory, triumph, aid | — | Lots | F | F | T | Asc, Ju, Sp, Sect | Asc + Ju - Sp | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes | complete |
| Valour and bravery | — | Lots | F | F | T | Asc, F, Ma, Sect | Asc + F - Ma | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seven planetary fortunes | complete |
| Life | — | Lots | F | F | T | Asc, Sa, Ju, Sect | Asc + Sa - Ju | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — First house | complete |
| Pillar of horoscope; permanence; constancy | — | Lots | F | F | T | Asc, Sp, F, Sect | Asc + Sp - F | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — First house | complete |
| Reasoning and eloquence | — | Lots | F | F | T | Asc, Ma, Me, Sect | Asc + Ma - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — First house | complete |
| Property | — | Lots | F | F | T | Asc, c2, L2, Sect | Asc + c2 - L2 | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Second house | complete |
| Debt | — | Lots | F | F | T | Asc, Me, Sa, Sect | Asc + Me - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Second house | complete |
| Treasure trove | — | Lots | F | F | T | Asc, Ve, Me | Asc + Ve - Me | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Second house | complete |
| Siblings | Brothers; Pars Fratrum | Lots | F | F | T | Asc, Ju, Sa | Asc + Ju - Sa | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Third house | complete |
| Number of brothers | — | Lots | F | F | T | Asc, Sa, Me | Asc + Sa - Me | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Third house | complete |
| Death of brothers and sisters | — | Lots | F | F | T | Asc, Su, Sect | Asc + 10° Gemini - Su | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Third house | complete |
| Parents | — | Lots | F | F | T | Asc, Sa, Su, Sect | Asc + Sa - Su | al-Bīrūnī / Abū Maʿshar | reverse | source table gives two alternatives | F | Report: al-Bīrūnī/Abū Maʿshar — Fourth house | complete |
| Parents | — | Lots | F | F | T | Asc, Sa, Ju, Sect | Asc + Sa - Ju | al-Bīrūnī / Abū Maʿshar | reverse | source table gives two alternatives | F | Report: al-Bīrūnī/Abū Maʿshar — Fourth house | complete |
| Death of parents | — | Lots | F | F | T | Asc, Ju, Sa, Sect | Asc + Ju - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Fourth house | complete |
| Grandparents | — | Lots | F | F | T | Asc, Sa, II, Sect | Asc + Sa - II | al-Bīrūnī / Abū Maʿshar | reverse | symbol II is not defined in the report | F | Report: al-Bīrūnī/Abū Maʿshar — Fourth house | partial |
| Ancestors and relations | — | Lots | F | F | T | Asc, Ma, Sa, Sect | Asc + Ma - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Fourth house | complete |
| Real estate according to Hermes | — | Lots | F | F | T | Asc, Mo, Sa, Sect | Asc + Mo - Sa | al-Bīrūnī / Abū Maʿshar; Hermes attribution | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Fourth house | complete |
| Real estate according to some Persians | — | Lots | F | F | T | Asc, Ju, Me, Sect | Asc + Ju - Me | al-Bīrūnī / Abū Maʿshar; Persian attribution | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Fourth house | complete |
| Agriculture, tillage | — | Lots | F | F | T | Asc, Sa, Ve | Asc + Sa - Ve | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Fourth house | complete |
| Issue of affairs; end of matter | — | Lots | F | F | T | Asc, LSy, Sa | Asc + LSy - Sa | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Fourth house | complete |
| Children | Pars Filiorum | Lots | F | F | T | Asc, Sa, Ju, Ve, Sect | Asc + Sa - Ju or (Ve) | al-Bīrūnī / Abū Maʿshar | reverse | source gives 'Asc + Sa - Ju or (Ve)'; alternate is not fully specified | F | Report: al-Bīrūnī/Abū Maʿshar — Fifth house | partial |
| Time and number of sexes | — | Lots | F | F | T | Asc, Ju, Ma | Asc + Ju - Ma | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Fifth house | complete |
| Condition of males | — | Lots | F | F | T | Asc, Ju, Ma | Asc + Ju - Ma | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Fifth house | complete |
| Condition of females | — | Lots | F | F | T | Asc, Ve, Mo | Asc + Ve - Mo | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Fifth house | complete |
| Whether expected birth is male or female | — | Lots | F | F | T | Asc, Mo, lord(Mo), Sect | Asc + Mo - lord(Mo) | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Fifth house | complete |
| Disease, defects, onset according to Hermes | — | Lots | F | F | T | Asc, Ma, Sa, Sect | Asc + Ma - Sa | al-Bīrūnī / Abū Maʿshar; Hermes attribution | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Sixth house | complete |
| Disease according to some ancients | — | Lots | F | F | T | Asc, Ma, Me | Asc + Ma - Me | al-Bīrūnī / Abū Maʿshar; ancient attribution | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Sixth house | complete |
| Captivity (sixth-house) | Captivity | Lots | F | F | T | Asc, LT, dispositor(LT) | Asc + dispositor(LT) - LT | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Sixth house | complete |
| Slaves | — | Lots | F | F | T | Asc, Mo, Me | Asc + Mo - Me | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Sixth house | complete |
| Marriage (male, Hermes/Dorotheus-Paulus) | wife lot; Marriage of men according to Hermes | Lots | F | F | T | Asc, Ve, Sa | Asc + Ve - Sa | al-Bīrūnī / Abū Maʿshar; Hermes attribution | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Marriage-Bringer (male, Valens) | wife lot in Valens; Marriage of men according to Valens | Lots | F | F | T | Asc, Ve, Su | Asc + Ve - Su | al-Bīrūnī / Abū Maʿshar; Valens attribution | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Trickery and deception of men and women | — | Lots | F | F | T | Asc, Ve, Su | Asc + Ve - Su | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Intercourse (men) | Intercourse | Lots | F | F | T | Asc, Ve, Su | Asc + Ve - Su | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Marriage (female, Hermes/Dorotheus-Paulus) | husband lot; Marriage of women according to Hermes | Lots | F | F | T | Asc, Sa, Ve | Asc + Sa - Ve | al-Bīrūnī / Abū Maʿshar; Hermes attribution | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Marriage-Bringer (female, Valens) | husband lot in Valens; Marriage of women according to Valens | Lots | F | F | T | Asc, Ma, Mo | Asc + Ma - Mo | al-Bīrūnī / Abū Maʿshar; Valens attribution | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Misconduct by women | — | Lots | F | F | T | Asc, Ma, Mo | Asc + Ma - Mo | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Trickery and deceit of men by women | — | Lots | F | F | T | Asc, Ma, Mo | Asc + Ma - Mo | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Intercourse (women) | Intercourse | Lots | F | F | T | Asc, Ma, Mo | Asc + Ma - Mo | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Unchastity of women | — | Lots | F | F | T | Asc, Ma, Mo | Asc + Ma - Mo | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Chastity of women | — | Lots | F | F | T | Asc, Ve, Mo | Asc + Ve - Mo | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Marriage of men and women according to Hermes | — | Lots | F | F | T | Asc, c7, Ve | Asc + c7 - Ve | al-Bīrūnī / Abū Maʿshar; Hermes attribution | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Time of marriage according to Hermes | — | Lots | F | F | T | Asc, Mo, Su | Asc + Mo - Su | al-Bīrūnī / Abū Maʿshar; Hermes attribution | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Fraudulent marriage and facilitating it | — | Lots | F | F | T | Asc, Ve, Sa | Asc + Ve - Sa | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Sons-in-law | — | Lots | F | F | T | Asc, Ve, Sa, Sect | Asc + Ve - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Lawsuits | — | Lots | F | F | T | Asc, Ju, Ma, Sect | Asc + Ju - Ma | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Seventh house | complete |
| Death | — | Lots | F | F | T | Sa, c8, Mo | Sa + c8 - Mo | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eighth house | complete |
| Anaireta / Destroyer | destroyer lot; Anairetai / destroyer | Lots | F | F | T | Asc, Mo, LA, Sect | Asc + Mo - LA | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eighth house | complete |
| Feared year at birth for death/famine | — | Lots | F | F | T | Asc, Sa, dispositor(last syzygy) | Asc + dispositor(last syzygy) - Sa | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eighth house | complete |
| Place of murder and sickness | — | Lots | F | F | T | Me, Ma, Sa, Sect | Me + Ma - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eighth house | complete |
| Danger of violence | — | Lots | F | F | T | Asc, Me, Sa, Sect | Asc + Me - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eighth house | complete |
| Journeys | — | Lots | F | F | T | Asc, c9, L9 | Asc + c9 - L9 | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Ninth house | complete |
| Journeys by water | — | Lots | F | F | T | Asc, Sa, Sect | Asc + 15° Cancer - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Ninth house | complete |
| Timidity and hiding | — | Lots | F | F | T | Asc, Me, Mo, Sect | Asc + Me - Mo | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Ninth house | complete |
| Deep reflection | — | Lots | F | F | T | Asc, Mo, Sa, Sect | Asc + Mo - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Ninth house | complete |
| Understanding and wisdom | — | Lots | F | F | T | Asc, Su, Sa, Sect | Asc + Su - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Ninth house | complete |
| Traditions, knowledge of affairs | — | Lots | F | F | T | Asc, Ju, Su, Sect | Asc + Ju - Su | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Ninth house | complete |
| Knowledge whether true or false | — | Lots | F | F | T | Asc, Mo, Me | Asc + Mo - Me | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Ninth house | complete |
| Noble births | — | Lots | F | F | T | Asc, LT, degree(exaltation of LT), Sect | Asc + degree(exaltation of LT) - LT | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | complete |
| Kings and sultans | — | Lots | F | F | T | — | same family, implied | al-Bīrūnī / Abū Maʿshar | reverse | formula only described as 'same family, implied' | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | unresolved |
| Administrators, viziers | — | Lots | F | F | T | Asc, Ma, Me, Sect | Asc + Ma - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | complete |
| Sultan’s victory, conquest | — | Lots | F | F | T | Asc, Sa, Su, Sect | Asc + Sa - Su | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | complete |
| Those who rise in station | — | Lots | F | F | T | Asc, F, Sa, Sect | Asc + F - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | complete |
| Celebrated persons of rank | — | Lots | F | F | T | Asc, Su, Sa | Asc + Su - Sa | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | complete |
| Armies and police | — | Lots | F | F | T | Asc, Sa, Ma, Sect | Asc + Sa - Ma | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | complete |
| Sultan; those concerned in nativities | — | Lots | F | F | T | Asc, Mo, Sa | Asc + Mo - Sa | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | complete |
| Merchants and their work | — | Lots | F | F | T | Asc, Ve, Me, Sect | Asc + Ve - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | complete |
| Buying and selling | — | Lots | F | F | T | Asc, F, Sp, Sect | Asc + F - Sp | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | complete |
| Operations and orders in medical treatment | — | Lots | F | F | T | Asc, Ju, Su, Sect | Asc + Ju - Su | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | complete |
| Mother | Pars Matris; Mothers | Lots | F | F | T | Asc, Mo, Ve, Sect | Asc + Mo - Ve | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Tenth house | complete |
| Glory | — | Lots | F | F | T | Asc, Sp, F, Sect | Asc + Sp - F | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eleventh house | complete |
| Friendship and enmity | — | Lots | F | F | T | Asc, Sp, F, Sect | Asc + Sp - F | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eleventh house | complete |
| Known by men and revered; constancy in affairs | — | Lots | F | F | T | Asc, Su, F, Sect | Asc + Su - F | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eleventh house | complete |
| Success | — | Lots | F | F | T | Asc, Ju, F, Sect | Asc + Ju - F | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eleventh house | complete |
| Worldliness | — | Lots | F | F | T | Asc, Ve, F, Sect | Asc + Ve - F | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eleventh house | complete |
| Hope | — | Lots | F | F | T | Asc, Me, Ju, Sect | Asc + Me - Ju | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eleventh house | complete |
| Friends | — | Lots | F | F | T | Asc, Me, Mo | Asc + Me - Mo | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eleventh house | complete |
| Violence | — | Lots | F | F | T | Asc, Me, Sp | Asc + Me - Sp | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eleventh house | complete |
| Abundance in house | — | Lots | F | F | T | Asc, Su, Mo | Asc + Su - Mo | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eleventh house | complete |
| Liberty of person | — | Lots | F | F | T | Asc, Su, Me, Sect | Asc + Su - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eleventh house | complete |
| Praise and acceptation | — | Lots | F | F | T | Asc, Ve, Ju, Sect | Asc + Ve - Ju | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Eleventh house | complete |
| Enmity according to some ancients | — | Lots | F | F | T | Asc, Ma, Sa | Asc + Ma - Sa | al-Bīrūnī / Abū Maʿshar; ancient attribution | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Twelfth house | complete |
| Enmity according to Hermes | — | Lots | F | F | T | Asc, c12, L12 | Asc + c12 - L12 | al-Bīrūnī / Abū Maʿshar; Hermes attribution | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Twelfth house | complete |
| Bad luck | — | Lots | F | F | T | Asc, F, Sp | Asc + F - Sp | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Twelfth house | complete |
| Hailaj / Hyleg / life-giver | — | Lots | F | F | T | Asc, Mo, previous syzygy | Asc + Mo - previous syzygy | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Al‑Bīrūnī’s ten miscellaneous natal lots | complete |
| Debilitated bodies | — | Lots | F | F | T | Asc, Ma, F, Sect | Asc + Ma - F | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Al‑Bīrūnī’s ten miscellaneous natal lots | complete |
| Horsemanship, bravery | — | Lots | F | F | T | Asc, Mo, Sa, Sect | Asc + Mo - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Al‑Bīrūnī’s ten miscellaneous natal lots | complete |
| Boldness, violence, murder | — | Lots | F | F | T | Asc, Mo, LA, Sect | Asc + Mo - LA | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Al‑Bīrūnī’s ten miscellaneous natal lots | complete |
| Trickery and deceit | — | Lots | F | F | T | Asc, Sp, Me, Sect | Asc + Sp - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Al‑Bīrūnī’s ten miscellaneous natal lots | complete |
| Necessity and wish | — | Lots | F | F | T | Asc, Ma, Sa | Asc + Ma - Sa | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Al‑Bīrūnī’s ten miscellaneous natal lots | complete |
| Requirements and necessities according to Egyptians | — | Lots | F | F | T | Asc, c3, Ma | Asc + c3 - Ma | al-Bīrūnī / Abū Maʿshar; Egyptian attribution | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Al‑Bīrūnī’s ten miscellaneous natal lots | complete |
| Realisation of needs and desires | — | Lots | F | F | T | Asc, Me, F | Asc + Me - F | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Al‑Bīrūnī’s ten miscellaneous natal lots | complete |
| Retribution | — | Lots | F | F | T | Asc, Su, Ma, Sect | Asc + Su - Ma | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Al‑Bīrūnī’s ten miscellaneous natal lots | complete |
| Rectitude | — | Lots | F | F | T | Asc, Ma, Me, Sect | Asc + Ma - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Al‑Bīrūnī’s ten miscellaneous natal lots | complete |
| Sultan's Lot | — | Lots | F | F | T | Ju, MC, Su, MC(return) | Ju + MC(return) - MC or (Sun) | al-Bīrūnī / Abū Maʿshar | same | source gives 'Ju + MC(return) - MC or (Sun)' | F | Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions | partial |
| Sultan's Lot | — | Lots | F | F | T | Asc, degree(conjunction), Asc(conjunction) | Asc + degree(conjunction) - degree(Asc of conjunction) | al-Bīrūnī / Abū Maʿshar | same | alternative Sultan's Lot formula | F | Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions | complete |
| Victory (annual/conjunction) | Victory | Lots | F | F | T | Asc, Su, Desc, L7 | Asc + L7 or Desc-degree - Su | al-Bīrūnī / Abū Maʿshar | same | source gives 'L7 or Desc-degree' as alternative operand | F | Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions | partial |
| Battle | — | Lots | F | F | T | Mo, Ma, Lot of Victory | degree(Lot of Victory) + Mo - Ma | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions | complete |
| Battle | — | Lots | F | F | T | Asc, Mo, Ma | Asc + Mo - Ma | al-Bīrūnī / Abū Maʿshar; Umar attribution | same | alternate Battle formula | F | Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions | complete |
| Battle | — | Lots | F | F | T | Asc, Mo, Sa | Asc + Mo - Sa | al-Bīrūnī / Abū Maʿshar; al-Furkhan attribution | same | alternate Battle formula | F | Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions | complete |
| Truce between armies | — | Lots | F | F | T | Asc, Me, Mo | Asc + Me - Mo | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions | complete |
| Conquest | — | Lots | F | F | T | Asc, Ma, Su | Asc + Ma - Su | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions | complete |
| Triumph | — | Lots | F | F | T | Asc, Ju, F, Sect | Asc + Ju - F | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions | complete |
| First conjunction | — | Lots | F | F | T | Asc, degree(conjunction), Asc(year conjunction) | Asc + degree(conjunction) - Asc(year conjunction) | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions | complete |
| Second conjunction | — | Lots | F | F | T | Asc, degree(conjunction), Asc(conjunction) | Asc + degree(conjunction) - Asc(conjunction) | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Anniversaries, returns, and conjunctions | complete |
| Earth | — | Lots | F | F | T | Asc, Ju, Sa | Asc + Ju - Sa | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions | complete |
| Water | — | Lots | F | F | T | Asc, Ve, Mo | Asc + Ve - Mo | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions | complete |
| Air and wind | — | Lots | F | F | T | Asc, Me, dispositor(Me) | Asc + dispositor(Me) - Me | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions | complete |
| Fire | — | Lots | F | F | T | Asc, Ma, Su | Asc + Ma - Su | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions | complete |
| Clouds | — | Lots | F | F | T | Asc, Sa, Ma, Sect | Asc + Sa - Ma | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions | complete |
| Rains | — | Lots | F | F | T | Asc, Ve, Mo, Sect | Asc + Ve - Mo | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions | complete |
| Cold | — | Lots | F | F | T | Asc, Sa, Me, Sect | Asc + Sa - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions | complete |
| Floods | — | Lots | F | F | T | Mo, Su, Sa, Moon-rise | Mo + Su - Sa cast at Moon-rise | al-Bīrūnī / Abū Maʿshar | none | cast at Moon-rise | F | Report: al-Bīrūnī/Abū Maʿshar — Quarters, weather, and mundane conditions | complete |
| Wheat | — | Lots | F | F | T | Asc, Ju, Su, Sect | Asc + Ju - Su | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Barley meal | — | Lots | F | F | T | Asc, Ju, Mo, Sect | Asc + Ju - Mo | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Rice, millet | — | Lots | F | F | T | Asc, Ve, Ju, Sect | Asc + Ve - Ju | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Maize | — | Lots | F | F | T | Asc, Sa, Ju, Sect | Asc + Sa - Ju | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Pulse | — | Lots | F | F | T | Asc, Me, Ve, Sect | Asc + Me - Ve | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Lentils and iron | — | Lots | F | F | T | Asc, Sa, Ma, Sect | Asc + Sa - Ma | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Beans, onions | — | Lots | F | F | T | Asc, Ma, Sa, Sect | Asc + Ma - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Chick peas | — | Lots | F | F | T | Asc, Su, Ve, Sect | Asc + Su - Ve | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Sesame, grapes | — | Lots | F | F | T | Asc, Ve, Sa, Sect | Asc + Ve - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Sugar | — | Lots | F | F | T | Asc, Me, Ve, Sect | Asc + Me - Ve | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Honey | — | Lots | F | F | T | Asc, Su, Mo, Sect | Asc + Su - Mo | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Oil | — | Lots | F | F | T | Asc, Mo, Ma, Sect | Asc + Mo - Ma | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Nuts, flax | — | Lots | F | F | T | Asc, Ve, Ma, Sect | Asc + Ve - Ma | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Olives | — | Lots | F | F | T | Asc, Mo, Me, Sect | Asc + Mo - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Apricots | — | Lots | F | F | T | Asc, Ma, Sa, Sect | Asc + Ma - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Water melons | — | Lots | F | F | T | Asc, Me, Ju, Sect | Asc + Me - Ju | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Salt | — | Lots | F | F | T | Asc, Ma, Mo, Sect | Asc + Ma - Mo | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Sweets | — | Lots | F | F | T | Asc, Ve, Su, Sect | Asc + Ve - Su | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Astringents | — | Lots | F | F | T | Asc, Sa, Me, Sect | Asc + Sa - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Pungent things | — | Lots | F | F | T | Asc, Sa, Ma, Sect | Asc + Sa - Ma | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Raw silk, cotton | — | Lots | F | F | T | Asc, Ve, Me, Sect | Asc + Ve - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Purgatives | — | Lots | F | F | T | Asc, Sa, Me, Sect | Asc + Sa - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Bitter purgatives | — | Lots | F | F | T | Asc, Ma, Sa, Sect | Asc + Ma - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Acid purgatives | — | Lots | F | F | T | Asc, Ju, Sa, Sect | Asc + Ju - Sa | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Agricultural and crop lots | complete |
| Secrets | — | Lots | F | F | T | Asc, c10, LA | Asc + c10 - LA | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Horary lots | complete |
| Urgent wish | — | Lots | F | F | T | Asc, LA, LH, Sect | Asc + LA - LH | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Horary lots | complete |
| Time of attainment | — | Lots | F | F | T | Asc, L10, LH, Sect | Asc + L10 - LH | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Horary lots | complete |
| Information true or not | — | Lots | F | F | T | Asc, Mo, Me, Sect | Asc + Mo - Me | al-Bīrūnī / Abū Maʿshar | reverse | — | F | Report: al-Bīrūnī/Abū Maʿshar — Horary lots | complete |
| Injury to business | — | Lots | F | F | T | Asc, F, LA | Asc + F - LA | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Horary lots | complete |
| Freedmen and servants | — | Lots | F | F | T | Me, Sa, Ju | Me + Sa - Ju | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Horary lots | complete |
| Lords and masters | — | Lots | F | F | T | Mo, Sa, Ju | Mo + Sa - Ju | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Horary lots | complete |
| Marriage (horary) | Marriage | Lots | F | F | T | Asc, c7, Ve | Asc + c7 - Ve | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Horary lots | complete |
| Time for action | — | Lots | F | F | T | Asc, Ju, Su | Asc + Ju - Su | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Horary lots | complete |
| Time occupied therein | — | Lots | F | F | T | Asc, Sa, Su | Asc + Sa - Su | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Horary lots | complete |
| Dismissal or resignation | — | Lots | F | F | T | Su, Ju | Ju + Ju - Su | al-Bīrūnī / Abū Maʿshar | same | — | F | Report: al-Bīrūnī/Abū Maʿshar — Horary lots | complete |

## Reconciliation notes

These are the identity merges made in this pass because the report itself supports them as the same spell/page rather than merely the same equation:

- Fortune + al-Bīrūnī's Fortune/Lunar horoscope
- Spirit + al-Bīrūnī's Daemon/Religion
- Father + the combust-Saturn special-case formula
- Mother + al-Bīrūnī's Mothers
- Siblings + Dorotheus's secondary sibling lot + al-Bīrūnī's Brothers
- Children + al-Bīrūnī's Children
- Valens male/female Marriage-Bringer + the corresponding al-Bīrūnī Valens-attributed rows
- Hermes/Dorotheus-Paulus male/female Marriage + the corresponding al-Bīrūnī Hermes-attributed rows
- Anaireta/Destroyer + al-Bīrūnī's Anairetai/Destroyer
- Sultan's Lot + its explicitly labeled alternative
- Battle + Umar and al-Furkhan alternatives

Same formula alone was **not** treated as proof of same Kleis. This preserves cases where distinct astrological objects share an equation.

Likewise, same English label alone was **not** treated as proof of identity. Valens Eros/Necessity remain separate from the planetary Love/Venus and Necessity/Mercury lots.

## L1 set at the end of Pass 2

- Fortune — `T/T/T`
- Spirit — `T/T/T`
- Eros — `T/T/T`
- Necessity — `T/T/T`

All other pages are presently `F/F/T`.
