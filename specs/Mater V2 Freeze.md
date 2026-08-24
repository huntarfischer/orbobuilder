# Mater V2 Freeze

Status: FROZEN
Branch: `feature/mater-v2`
Date: 2026-08-24

Mater V2 is the canonical native zodiacal-condition authority for OrboCore.

Frozen contract:

- **Mater Temper** is the reusable planet × sign condition form
- ten canonical planetary headers: Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto
- each planet carries exactly 12 reusable sign Tempers in canonical zodiac order
- sign, element, and modality are fixed-shape one-hot state
- traditional and modern rulership channels are stored separately and can be selected without recomputation
- modern baseline currently admitted:
  - Pluto domicile Scorpio / detriment Taurus
  - Uranus domicile Aquarius / detriment Leo
  - Neptune domicile Pisces / detriment Virgo
- no modern exaltation, fall, triplicity, bound, face, reception, or dispositor doctrine is invented
- the traditional classical seven remain the dispositor backbone
- degree-sensitive facts are qualifiers over the reusable Temper rather than separate full-degree Tempers
- admitted degree-sensitive qualifiers are exact exaltation degree, Egyptian bound, and Chaldean face
- sect is fixed-shape state (`sectDay`, `sectNight`) selecting already-known triplicity outcomes
- peregrine is resolved from the complete classical five-rung dignity law; `peregrineApplies` prevents modern planets from being mislabeled by a law that does not apply to them
- `mutualReception` is an immediate boolean fact; partner and kind are stored separately as detail

Field layer:

- `Mater.resolveField` resolves one complete ten-planet sign field
- each `FieldTemper` references the reusable sign Temper and adds field-dependent circuitry only
- recorded field facts include bearer, dispositor path, keeper, terminal kind, cycle membership, mutual reception, immediate dependents, and transitive descendants
- dispositor terminal vocabulary:
  - 1-cycle = domicile
  - 2-cycle = mutual reception
  - 3+ cycle = dispositor loop
- modern planets may occupy the field but remain leaves on the traditional dispositor backbone

Placement layer:

- `Mater.resolvePlacement` joins a resolved Mater Field to an existing frozen Tympan Imprint
- Tympan remains the authority for house governorship
- Mater records where the already-known governor is actually placed
- traditional house-routing vocabulary:
  - own-house
  - house-exchange
  - routing-loop
- modern governor placement is preserved as a separate Tympan-derived augmentation and does not enter the traditional house-routing graph
- Mater does not rebuild Tympan Imprints or Governance Lattices

Cross-field layer:

- `Mater.resolveCrossField` compares two already-resolved fields
- cross handoffs are exactly one step into the other field and never become alternating walks
- cross receptions preserve direction and domicile/exaltation/mixed kind
- the recovered at-home rule remains: a planet at home is host, not guest, for reception
- no Ring, Arc, aspect, orb, or interpretation logic enters cross-field Mater

Qualification layer:

- `Mater.qualifyField` accepts exact longitudes for the ten canonical planets plus optional sect
- there is no natal, mundane, electional, or synchronic mode in Mater qualification
- identical coordinates and sect produce identical Mater truth regardless of caller/source
- `QualifiedTemper` retains the reusable `Temper` and `FieldTemper` beneath exact-coordinate qualifiers
- consumer-facing condition includes fixed booleans for traditional/modern domicile and detriment, exaltation, exact exaltation degree, triplicity, bound, face, fall, peregrine applicability/status, and mutual reception
- bound/face/triplicity identities remain available as provenance/detail without forcing downstream recomputation
- crossing a sign boundary swaps the reusable Temper; movement within a sign keeps the same Temper while only genuine degree-sensitive qualifiers may change

System boundaries:

```text
Ring   → angular relationship law
Mater  → zodiacal condition / field circuitry law
Tympan → whole-sign form / house governance law
Arc    → synchronic union geometry
```

Mater V2 does not own:

- AstroDNA construction
- Timespine construction
- Ring aspects or orbs
- Tympan Imprints or Governance Lattices
- Arc geometry
- Horizon / geoplacement
- Iris visualization
- interpretation or signification text

Build passes:

```text
0  TEMPER CONTRACT
1  REUSABLE TEMPERS
2  FIELD TEMPER
3  PLACEMENT + CROSS-FIELD
4  QUALIFICATION
```

Implementation commits:

```text
c8618b7c  Freeze Mater V2 Pass 0 Temper contract
a395a6b8  Build Mater V2 reusable sign Tempers
556ada2f  Test Mater V2 reusable sign Tempers
e27a4732  Build Mater V2 field Tempers
6cfe038f  Test Mater V2 field Tempers
ae01f64d  Fix Mater V2 field reception projections
7b98ab6f  Build Mater V2 placement and cross-field reads
51c59f8c  Test Mater V2 placement and cross-field reads
e6c77b56  Build Mater V2 qualification reads
3c6fdbe0  Test Mater V2 qualification portability
7d925d9d  Tighten Mater V2 qualification test sect fixture
```

Final green gate:

- `swift test --filter MaterQualificationTests`: passed
- `swift test`: **355 tests, 0 failures**
- `TympanTests`: **19 tests, 0 failures** inside the same full gate

The freeze is documentation-only and does not alter runtime behavior after this green gate.

Any change to this contract reopens Mater V2 and requires focused Mater tests plus the full OrboCore suite before refreezing.
