# Moirai - Connectome Field MVP

**Status:** Stage 0-3 implementation plan  
**Target:** Orbo 1.0 native  
**Primary language:** Swift  
**Implementation root:** `native/OrboCore/Sources/OrboCore/Connectome/`

## Governing objective

Build the smallest complete version of the Moirai that proves the native-specific Connectome structure can be constructed, checked, and sealed without defining the final Loom.

```text
HERMES
Ticket: natal AstroDNA + expected outcome
    ↓
CLOTHO
creates natal threads and registers a MoiraiRecipe
    ↓                    ↓
LACHESIS             ATROPOS
allots threads        holds recipe
    ↓                    ↑
DegreeGrid ──────────────┘
                         ↓
                    inspect
                         ↓
                  PASS / REJECT
                         ↓
                  AtroposPackage
                  ready for Hermes
```

Stages 0-3 prove the Sisters. Hermes is not implemented in this pass.

## MVP boundary

This pass does not add:

- Hermes implementation or callback/rendezvous mechanics
- final Loom architecture
- persistence or codec work
- Ring aspects or aspect reachability
- dispositor chains
- full Synchronic Governance
- field overlap or density
- special nodal handling
- Timespine joins
- Composite Framing
- Synchronic Clock integration
- electional
- synastry
- final packing or performance optimization

---

# Stage 0 - The Degree Grid

## Goal

Define only the 360 zodiacal degree addresses.

```text
DegreeAddress
0 ... 359

DegreeCell
address only at Stage 0 construction

DegreeGrid
exactly 360 cells
```

Stage 0 does not define the Loom, construction state, persistence, natal threads, allotments, governance, Arc data, or birth-chart meaning.

The degree grid is an index only. It does not replace exact positional precision.

## Stage 0 gate

Prove:

```text
addresses accept only 0...359
exactly 360 canonical addresses
exactly 360 cells
no duplicates
no missing addresses
canonical order is 0...359
each fresh cell has its degree address and no allotted threads
```

---

# Stage 1 - Clotho

## Goal

Create the natal threads Lachesis will allot and, in the same gathering operation, register the recipe Atropos will later use to check the work.

For the MVP, Clotho receives canonical natal AstroDNA. For each canonical gene she creates one thread containing gene identity, exact `RingFineState`, and the matching whole-degree `DegreeAddress` supplied by Ring's existing exact-to-coarse projection.

At that same moment she records the same production facts in a `MoiraiRecipeEntry`.

```text
INPUT
natal AstroDNA

CLOTHO
for each canonical gene:
    creates one ClothoThread
    records one MoiraiRecipeEntry

OUTPUT
ClothoOutput
    packet  -> Lachesis
    recipe  -> Atropos
```

The packet and recipe come from the same gathering operation. Clotho does not make a second pass later to reconstruct the recipe.

`ClothoThread` and `MoiraiRecipeEntry` intentionally carry the same three facts for different purposes:

```text
gene
exact RingFineState
degreeAddress
```

The thread is the material Lachesis allots. The recipe is the production specification Atropos checks against. The recipe is not another astrological authority.

Clotho is the sole construction authority for Clotho threads, source packets, and Moirai recipes.

Clotho does not name signs, assign houses, consult Tympan or Mater, interpret positions, allot threads into the degree grid, answer degree queries, or write the Loom.

The whole degree is only the Stage 0 grid address. Exact `RingFineState` remains attached at arcsecond precision.

## Stage 1 gate

Prove:

```text
natal AstroDNA is the input
exactly 12 Clotho threads are created
threads remain in canonical AstroDNA gene order
each exact RingFineState is preserved unchanged to the arcsecond
each DegreeAddress matches RingFineState.coarseState.degree
sub-degree precision does not alter the containing DegreeAddress
retrograde motion does not change the 0...359 DegreeAddress
multiple genes may share one DegreeAddress while retaining distinct exact states
Clotho does not alter the Stage 0 DegreeGrid
exactly one recipe entry is recorded for each thread
recipe entry facts match the thread facts from the same gathering operation
same natal AstroDNA produces the same ClothoOutput
no sign, house, ruler, or other astrological meaning is added
```

---

# Stage 2 - Lachesis

## Goal

Fill the existing Stage 0 `DegreeGrid` with the Clotho threads already addressed to it.

Lachesis receives only the existing degree grid and Clotho's source packet. She does not receive the Moirai recipe, recalculate thread positions, or derive additional astrological meaning.

```text
INPUT
DegreeGrid
ClothoSourcePacket

LACHESIS
for each existing DegreeCell:
    preserves valid existing allotments
    allots every new Clotho thread whose supplied DegreeAddress matches that cell

OUTPUT
the same DegreeGrid type
with Clotho threads allotted into its existing cells
```

A `DegreeCell` carries:

```text
address
threads[]
```

The cell remains whole-degree. Each allotted thread still carries its exact `RingFineState`, so arcsecond precision survives inside the degree-addressed structure.

Lachesis is the sole allotment authority for Clotho threads. She trusts the `DegreeAddress` Clotho supplied. She does not call Ring to recalculate the address and does not consult Tympan, Mater, Arc, or other authorities in this stage.

Lachesis may receive a grid that already contains valid allotments. Re-allotting the same authoritative thread is idempotent. A conflicting thread for a gene already allotted is invalid rather than silently replacing existing truth.

This stage does not define or persist the final Loom.

## Stage 2 gate

Prove:

```text
the grid remains exactly 360 cells in canonical 0...359 order
all 12 Clotho threads are allotted
each thread appears exactly once
each thread appears only in its supplied DegreeAddress
multiple threads may share one existing cell
empty cells remain valid
exact RingFineState survives unchanged to the arcsecond
Lachesis does not change thread identity or address
same empty grid + same Clotho packet produces the same allotted grid
an already allotted grid may be given back to Lachesis
re-allotting the same threads does not duplicate them
valid existing allotments are preserved
no sign, house, ruler, aspect, or other astrological meaning is added
```

---

# Stage 3 - Atropos

## Goal

Perform the Moirai's internal quality check by comparing the finished allotment from Lachesis against the `MoiraiRecipe` Clotho registered, and seal only a faithful result.

Atropos answers one question:

> Does what Lachesis handed me match what Clotho said she handed to Lachesis?

She does not decide whether Clotho correctly represented Hermes's original ticket. That later ticket-to-package check belongs to Hermes.

```text
INPUT A
MoiraiRecipe from Clotho

INPUT B
DegreeGrid from Lachesis

ATROPOS
validate structure
compare recipe to allotted threads

FAIL
AtroposFailure

PASS
AtroposPackage containing the exact supplied DegreeGrid
```

### Atropos checks

```text
GRID
exactly 360 canonical cells

RECIPE
exactly 12 canonical genes
one entry per gene

ALLOTMENT
exactly 12 canonical genes
one thread per gene

FIDELITY
for every gene:
    recipe exactState == allotted thread exactState
    recipe degreeAddress == allotted thread degreeAddress
    allotted thread is in the matching DegreeCell
```

Atropos compares by gene identity, not by array position.

Atropos does not derive a new degree from `RingFineState`, consult AstroDNA, call Ring, consult Tympan, Mater, or Arc, repair a thread, replace a thread, or re-allot anything. A mismatch is reported as deterministic failure data rather than repaired.

Only Atropos creates `AtroposPackage`. The package contains the same `DegreeGrid` Lachesis supplied. The seal means only that the grid faithfully matches Clotho's registered Moirai recipe.

Stage 3 stops at a package ready for Hermes. It does not invent Hermes's callback or final ticket-matching mechanics.

## Stage 3 gate

Prove:

```text
valid Clotho recipe + faithful Lachesis grid passes
successful package contains the exact supplied grid
all 12 threads remain unchanged
shared-degree occupancy remains valid
unrelated empty cells remain valid
exact-state disagreement is rejected
different production output is rejected deterministically
same recipe + same grid produces the same inspection result
Atropos never recalculates or repairs the work
```

---

# Native Swift repository layout

```text
native/OrboCore/Sources/OrboCore/Connectome/
native/OrboCore/Tests/OrboCoreTests/Connectome/
```

Reuse existing native OrboCore vocabulary wherever possible.

---

# MVP acceptance

```text
STAGE 0
360 degree places exist.

CLOTHO
creates exact natal threads and simultaneously registers their Moirai recipe.

LACHESIS
allots the threads into the existing degree cells without changing them.

ATROPOS
checks the completed allotment against the recipe and seals only a faithful grid.

HERMES
later receives the sealed package and compares it against the original ticket.
```

> **Build the places. Spin the threads and record the recipe. Allot the threads. Check the allotment. Seal only what matches.**
