repo: huntarfischer/orborectifier
branch: main
path: (whole repo — content bank only, no code copied)

## Last sync
date: 2026-08-12T05:58:05Z

### Updated in this project
- Ingested the rectification content bank (Lunar Lock v2, Decan Lock v2, Ascendant-Ruler
  House bank, Sabian degree bank) into `rect-data.js` (Lunar Houses + Decans only — Ruler/House
  and Sabian degree banks read but not wired in, see Screen map).
- Built Part Three (Rectification) of onboarding: Time Prior → Lunar Lock → Decan Lock →
  Confirm, reached from "I don't know" on birth time. Real astronomy throughout — candidate
  ascendant signs come from a live horizon scan (spine.ascProbe), not scripted content.
- Onboarding script wording follows the project's existing voice (lowercase, typewriter),
  not the repo's verbatim script — confirmed with user as an intentional divergence.

## Screen map
| Screen | Repo source |
|---|---|
| Onboarding — Part Three rectification wizard | `Orbo Onboarding Script.txt` (flow/structure), `orbo-lunar-lock-v2-48-question-bank.md` (Lunar Lock content, in `rect-data.js`), `orbo-decan-lock-v2-48-question-bank.md` (Decan Lock content, in `rect-data.js`) |
| Not yet wired | `orbo_rectifier_ascendant_ruler_house_questions_v1.2_timeless.md` (144-Q Ruler/House Lock — Lunar Lock alone is sufficient to lock the 30° window per the bank's own spec, so this was skipped for scope), `orbo-degree-lock-v3-dual-layer*.md/json` (Sabian 1° lock — replaced with a lighter geometric decan-midpoint + confirm step) |
