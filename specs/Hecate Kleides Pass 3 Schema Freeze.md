# Hecate Kleides — Pass 3 Schema Freeze

Status: design/schema only. No Swift changes.

## Corpus pressure test

The completed Lots catalogue was checked against the Pass 1 page schema after reconciling all 177 source catalogue entries into 162 Kleis pages and 182 formula rows.

The corpus exposed one missing Kleis-level field: **Context**.

The research source itself distinguishes five casting contexts:

- `natal`
- `annual/conjunction`
- `mundane/weather`
- `agricultural`
- `horary`

Every reconciled Kleis page in this corpus belongs to exactly one of those contexts, so Context belongs on the page rather than being inferred later from its name or source location.

Page counts by context:

- natal: 111
- annual/conjunction: 8
- mundane/weather: 8
- agricultural: 24
- horary: 11

## Frozen schema

### Kleis-level

- Kleis
- Aliases
- Family
- Context
- L1
- L2
- L3

### Formula-row level

- Requirements
- Formula
- Tradition
- Sect Rule
- Conditions
- Orbo Default
- Source
- Status

Full table order:

`Kleis · Aliases · Family · Context · L1 · L2 · L3 · Requirements · Formula · Tradition · Sect Rule · Conditions · Orbo Default · Source · Status`

## Invariants retained

- Legal availability states remain `T/T/T`, `F/T/T`, and `F/F/T`.
- Status remains formula-row level.
- Same formula does not imply same Kleis.
- Same English name does not imply same Kleis.
- No Formula ID or separate cross-reference registry is introduced.
- The Formula column remains directly sortable so repeated calculations can be viewed across different spell pages.
- Source remains at the precision actually supported by the research report. This pass does not invent primary-text citations that the catalogue does not supply row by row.
- The report does not supply a source-faithful basis for moving any of these 162 reconciled entries from Orbo's `Lots` family into `Parts`; all remain on the Lots shelf for this corpus.
- Fortune, Spirit, Eros, and Necessity remain `T/T/T`.
- Every other page remains `F/F/T` until Orbo deliberately curates L2.
- No Lot formula is marked Orbo Default in this pass.

## Pass 3 result

The corpus requires exactly one schema correction: add `Context` at the Kleis level. No other structural field is required before the metadata implementation pass.
