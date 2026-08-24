# Tympan V2 Freeze

Status: FROZEN
Branch: `feature/tympan-v2`
Date: 2026-08-23

Tympan V2 is the canonical native house-governance authority for OrboCore.

Frozen contract:

- 12 canonical `Tympan.Imprint`s, one for each rising sign
- whole-sign house/sign mapping across all 144 house cells
- Mater remains the owner of universal sign rulership
- Tympan projects sign rulership into chart-specific house governance
- 7-group `traditionalGovernanceLattice` per Imprint
- traditional lattice shape: five two-house governor groups plus singleton Sun and Moon groups
- modern governance augmentation is explicit and separate:
  - Pluto governs the house occupied by Scorpio
  - Uranus governs the house occupied by Aquarius
  - Neptune governs the house occupied by Pisces
- modern governance does not replace traditional governance
- modern governors cannot become `TraditionalGovernor`s and do not enter the classical dispositor backbone
- 12 precalculated `HouseGovernance` records per Imprint
- each `HouseGovernance` carries house, sign, traditional governor, traditional governed houses, and optional modern governor
- canonical house-facing reads use governance vocabulary
- canonical sign-facing reads use ruler vocabulary
- legacy V1 `ruler` / `housesRuled` / `coRuler` surfaces remain compatibility shims only
- parity fixture proves all 12 Imprints, all 84 traditional governance groups, all 36 modern governance placements, and all 144 complete house-governance reads
- shared vocabulary is defined in `specs/Rulership and Governance.md`

Out of scope for this freeze:

- natal occupants
- co-presence
- dispositor walking or house routing
- Mater redesign
- Lachesis implementation
- Tapestry construction
- degree-grid expansion
- interpretation
- weighting traditional versus modern governance
- Ring or Arc changes

Final green gate:

- `swift test --filter TympanTests`: 19 tests, 0 failures
- `swift test`: 326 tests, 0 failures

Stage 5 was documentation-only and did not alter code after this green gate.

Any change to this contract reopens Tympan V2 and requires focused Tympan tests plus the full OrboCore suite before refreezing.
