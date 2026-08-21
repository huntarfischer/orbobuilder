# Moirai - Connectome Field MVP

**Status:** Stage 0-3 implementation plan  
**Target:** Orbo 1.0 native  
**Primary language:** Swift  
**Implementation root:** `native/OrboCore/Sources/OrboCore/Connectome/`

## Governing objective

Build the smallest complete version of the Moirai that proves the permanent Connectome Field can be constructed once and then read without reconstructing its sources.

```text
CLOTHO
gathers once
    ↓
LACHESIS
allots once
    ↓
LOOM
persists the Field
    ↓
ATROPOS
seals and serves
    ↓
REST OF ORBO
reads
```

Stages 0-3 prove the Sisters. They do not attempt to finish the Connectome.

## Field and Loom

The terms are related but not interchangeable.

```text
FIELD
The native-specific relational space: what is allotted where.

LOOM
The persistent interconnected table structure that stores the Field.
```

Use **Field** when referring to the native topology itself.

Use **Loom** when referring to the stored artifact, tables, indexes, persistence, or query structure that materializes that Field.

Therefore:

> **Clotho gathers authoritative facts. Lachesis allots those facts across the Field by writing them into the Loom. Atropos seals and serves the finished Loom as the authoritative Field.**

## MVP boundary

This pass does not add:

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

Those are later stages built on the same Moirai contract.

---

# Stage 0 - Loom Skeleton

## Goal

Create the durable vessel before adding astrological complexity.

The MVP defines four persistent structural families:

```text
manifest
threads
degrees
allotments
```

Stage 0 defines their contracts and stable identifiers. It does **not** require `12 × 360 = 4,320` allotments to be stored as literal rows. It defines the complete address space and leaves the most efficient Swift representation to Stage 2.

## Manifest

Minimum identity and provenance:

```text
native fingerprint
Loom schema version
AstroDNA version
Mater version
Tympan version
Arc version
construction state
checksum
```

## Threads

Reserve twelve stable thread identities:

```text
Ascendant
Moon
Sun
Mercury
Venus
Mars
Jupiter
Saturn
Uranus
Neptune
Pluto
North Node
```

## Degrees

Define exactly 360 stable Field addresses:

```text
0 ... 359
```

These are indexing cells. They do not reduce Orbo's exact positional precision.

## Allotment address contract

Every thread must be addressable against every degree:

```text
thread_id × degree_id
```

The contract must support the complete 12 × 360 address space regardless of the eventual physical representation.

## Stage 0 gate

Prove:

```text
12 stable thread IDs
360 stable degree IDs
complete thread × degree address contract
valid manifest
exact serialization round-trip
no floating-point positional authority
```

An empty Loom can be created, persisted, destroyed from memory, and reloaded exactly.

---

# Stage 1 - Clotho

## Goal

Create one complete canonical source packet containing everything MVP Lachesis needs.

Clotho gathers. She does not allot.

For the MVP she reads only:

```text
Natal AstroDNA
Mater
Tympan
Arc
```

No Ring.  
No Timespines.

## Clotho source packet

For every thread, gather the minimum authoritative facts required by Lachesis:

```text
thread ID
exact natal coordinate
natal sign
natal Ascendant/frame reference
houses governed source facts
Arc center
Arc poles
Arc exact bounds
source/version provenance
```

Clotho also gathers the authoritative Mater and Tympan facts needed for the MVP Field.

Clotho does **not** place those facts into the Field.

For example, Clotho may hand Lachesis facts such as:

```text
natal Ascendant sign = Scorpio
Aries ruler = Mars
Moon Arc bounds = [exact coordinates]
```

Clotho does not write Field facts such as:

```text
7 Aries = natal 6H
7 Aries = Mars governed
7 Aries = Moon Arc boundary
```

The boundary is:

```text
CLOTHO
gathers authoritative facts

LACHESIS
allots those facts across the Field
```

## Persistence

Clotho's source packet persists independently and records sufficient provenance to reproduce exactly what Lachesis received.

## Stage 1 gate

After Clotho finishes, remove Lachesis's access to:

```text
AstroDNA
Mater
Tympan
Arc
```

Using only the persisted Clotho packet, Lachesis must still have everything necessary to complete Stage 2.

That proves Clotho gathered the source material rather than leaving deferred work behind.

---

# Stage 2 - Lachesis

## Goal

Construct the first real native Field by allotting Clotho's authoritative facts into the Loom.

This is the MVP's principal construction stage. Lachesis receives Clotho's completed source packet and performs the allotment work once.

## 2A. Populate the 360 Field

For every degree address, allot and persist the applicable facts:

```text
degree ID
sign
natal house
sign ruler
house ruler
```

Example for a Scorpio-rising native:

```text
7 Aries
→ Aries
→ natal 6H
→ Mars
```

These are Field facts stored in the Loom.

After construction, no runtime Mater or Tympan read is required to answer those Field questions.

## 2B. Allot every thread

For every thread × degree address, persist its permanent allotment state.

Use the minimum explicit state vocabulary:

```text
outside
inside
boundary
center
pole
```

Exact sub-degree coordinates remain attached where needed. A whole-degree cell is only an index and must never replace the exact Arc coordinate.

Example:

```text
Moon × 7 Aries
status: boundary / pole
exact coordinate: [canonical exact value]
```

## 2C. Persist both query directions

The Loom must support direct persisted lookup for:

```text
thread → allotted degrees
degree → allotted threads
```

The implementation may use rows, packed arrays, masks, indexes, or another native representation. The requirement is that both query directions are directly available without rebuilding the inverse at runtime.

## 2D. Minimal governance

Persist only the governance needed for the MVP:

```text
degree → natal house
degree → ruler
thread → natal houses governed
```

Do not build dispositor chains or moving governance state in this pass.

## Stage 2 proof queries

Using the persisted Loom alone, answer:

```text
What is this degree?
What natal house is this degree?
Who governs this degree?
Where is sJupiter allotted?
Can sJupiter occupy this degree?
Which threads can occupy this degree?
What houses does Jupiter govern?
Where are the Moon's center and poles?
```

None of those answers may invoke:

```text
Clotho
Mater
Tympan
Arc
```

## Stage 2 gate

The persisted Loom itself contains the required Field facts.

At that point Lachesis has finished the MVP Field.

---

# Stage 3 - Atropos

## Goal

Turn Lachesis's completed Loom into the immutable public representation of the Connectome Field.

Atropos does not enrich, allot, or recalculate the Field.

## 3A. Validate

Atropos checks construction integrity:

```text
manifest valid
12 threads complete
360 degree addresses complete
complete thread × degree address contract
all IDs resolve
all exact coordinates valid
forward and reverse query structures agree
versions compatible
checksum valid
```

A failed Loom is rejected.

## 3B. Seal

A valid artifact moves from:

```text
construction
```

to:

```text
sealed
```

The final version and checksum are recorded. The sealed Loom is immutable.

## 3C. Public query door

MVP Atropos exposes only the minimum query families:

```text
degree(...)
thread(...)
allotment(thread, degree)
threadsAt(degree)
governanceAt(degree)
```

Exact Swift method names are implementation details. These query responsibilities are the contract.

Normal Orbo code does not query Clotho or Lachesis.

```text
ORBO
  ↓
ATROPOS
  ↓
SEALED LOOM
  ↓
FIELD FACTS
```

## Stage 3 decisive test

Terminate the construction environment completely.

Restart with only:

```text
Atropos
+
sealed Loom artifact
```

Successfully answer all Stage 2 proof queries without loading:

```text
Clotho
Lachesis
Mater
Tympan
Arc
```

No recalculation is permitted.

## Stage 3 gate

If that test passes, the Moirai MVP exists.

---

# Native Swift repository layout

```text
native/OrboCore/Sources/OrboCore/Connectome/
    ConnectomeTypes.swift
    Loom.swift
    Clotho.swift
    Lachesis.swift
    Atropos.swift

native/OrboCore/Tests/OrboCoreTests/Connectome/
```

Stage 0 may begin with fewer physical files if that proves cleaner. The ownership boundaries above matter more than prematurely forcing file count or storage representation.

---

# MVP acceptance

The pass is complete when all four statements are true:

```text
CLOTHO
Orbo's required authorities can be gathered once into a complete native construction packet.

LACHESIS
Those authoritative facts can be allotted once across a persistent native-specific 360-degree Field.

LOOM
The Field survives independently of the machinery that created it because its allotted facts persist in the Loom.

ATROPOS
The rest of Orbo can retrieve finished Field facts from the sealed Loom without rediscovering how they were made.
```

The governing implementation rule is:

> **Build the vessel first. Gather only what the MVP requires. Allot it once across the Field. Persist it in the Loom. Seal it. Prove that Orbo can read it after every construction authority has gone away.**
