# Connectome Restoration - Parallel Build Plan

Status: planning document for the future Connectome restoration pass.

Companion documents:

- `specs/Orbo System Map and Connectome Restoration.md`
- `specs/Bay Bridge Migration Rule.md`
- `specs/Celestial to Civil Time Conversion.md`

Purpose: preserve the current working Connectome as a live reference while rebuilding the Connectome to its intended meaning as Orbo's comprehensive neural connection map.

---

## 0. The restoration target

The word **Connectome** is used because a connectome is a comprehensive map of neural connections in a brain.

That is the intended model.

The Connectome should expose the useful expressions and relationships already implicit in an AstroDNA state without forcing every downstream engine to become its own miniature compiler.

The present `connectome.js` is not discarded as a mistake.

It is a strong implementation of one important resolution:

```text
SIGN-STAY REGULATORY EXPRESSION
```

It currently owns facts such as:

```text
planet rows
house rows
dispositor chains
bearers
keepers
cycles
receptions
house routing
agency
light
charged state
indexes
```

Those facts must survive.

The restoration broadens the nervous system around them.

---

## 1. Do not rewrite the live Connectome in place

Apply the Bay Bridge Migration Rule.

The current functional implementation remains intact while the restored architecture is built beside it.

```text
                        CANONICAL INPUT
                             |
                 +-----------+-----------+
                 |                       |
                 v                       v
           LEGACY SPAN              NEW SPAN
        current connectome       restored connectome
                 |                       |
                 +-----------+-----------+
                             |
                         COMPARATOR
```

The current output is a live oracle for everything intended to remain canonical.

The new implementation must prove compatibility before existing consumers move.

---

## 2. First act of the coding pass: make an explicit reference copy

Before changing architecture, preserve the working current Connectome implementation under a migration-only name or path.

The exact name should be chosen during implementation, but conceptually:

```text
connectomeLegacy
```

The reference copy should remain byte-for-byte or behaviorally equivalent to the production implementation at the moment restoration begins.

Do not clean it up.
Do not move ownership inside it.
Do not optimize it.

It exists to answer:

```text
What did the working bridge produce for this input?
```

The production app can continue using the current path during construction.

---

## 3. Build the restored Connectome as a new retrieval surface

The restored Connectome should not initially try to put every fact into one giant object.

Its first architectural responsibility is to become the **coherent retrieval map** for expressions that already have proper owners.

Conceptual surface:

```text
Connectome
    |
    +-- identity
    |
    +-- exact
    |
    +-- pointwise
    |
    +-- signStay
    |
    +-- governance
    |
    +-- relation
    |
    +-- temporal
    |
    +-- synchronic
```

The names are provisional. The separation of resolutions is the important part.

---

## 4. The existing sign-stay Expression becomes one branch

The current compile remains valid at its present resolution.

Conceptually:

```text
Connectome.signStay(state)
        |
        v
current Expression contract
```

The new top-level Connectome may initially delegate this branch directly to the copied working implementation.

This is desirable.

The first restored Connectome can therefore be structurally broader without rewriting a proven calculation on day one.

The Bay Bridge principle is:

```text
new bridge may reuse proven beams
```

provided ownership and contracts are explicit.

---

## 5. Multi-resolution expressions

The intended nervous system recognizes that truths expire at different rates.

### 5.1 Exact / fine expression

Examples:

```text
longitude
arcsecond identity
DMS projection
motion
speed
retrograde
stationary state
```

These are sensitive to the precise celestial sample.

### 5.2 Pointwise expression

Examples:

```text
degree
bound
face
exact dignity rungs
other sub-sign conditions
```

These should not be stuffed into the sign-stay memo.

### 5.3 Sign-stay expression

Examples:

```text
sign
whole-sign house
bearer
dispositor path
keeper
receptions
house governance
agency
light
charged
```

These remain cacheable on sign vector + sect + version inputs.

### 5.4 Relational expression

Examples:

```text
Ring relationships
aspect state
applying / separating where meaningful
cross-chart relation
qualified house relationships
```

Some relations are instantaneous; some form stable spans. Their cache policy should follow the truth they represent.

### 5.5 Temporal expression

The Connectome should expose or reference temporal structures rather than forcing consumers to rediscover them.

Examples:

```text
TimeSpine
SynchronicSpine
progression chronology
ZR chronology
event / span indexes
```

The Connectome need not physically own every byte of these artifacts. It should know how the nervous system reaches them.

---

## 6. Cache law

> **Every cached expression is keyed at the resolution where its contents change.**

Do not use one cache key for the whole restored Connectome.

Examples:

```text
AstroDNA genome
    arcsecond identity

sign-stay Expression
    sign vector + sect + doctrine/codec version

Synchronic permanent structure
    natal identity + Prism codec + place-dependent structure where required

SynchronicSpine
    natal identity + SynchronicSpine codec/doctrine + requested span
```

A coarser cache is not a degraded AstroDNA.

It is a deliberate projection of the genome for a fact that is invariant below that resolution.

---

## 7. Comparator harness

Before migrating current consumers, create a direct comparison layer.

For every fixture and selected live state:

```text
legacy = legacyConnectome(...)
next   = restoredConnectome.signStay(...)

compare(legacy, next)
```

The comparator should cover every canonical current field.

Suggested parity groups:

```text
planet table
house table
chains
cycles
receptions
agency
light
charged
indexes
metadata values that remain semantically identical
```

If the restored surface intentionally changes metadata naming or container shape, normalize only through an explicit test adapter. Do not hide semantic differences behind a loose deep-equality helper.

---

## 8. Consumer migration

Actual order must come from a fresh caller trace at implementation time.

The migration rule is consumer-by-consumer.

For each consumer:

```text
1. identify current call
2. capture fixtures / current output
3. route to restored Connectome
4. run parity
5. run living-app acceptance
6. remove that consumer's legacy dependency
```

Likely categories include:

```text
natal structural readers
ruler / ladder joins
progression structural reads
synchronic / composite structural reads
electional structural inputs
future temporal spines
```

Do not assume the UI Tabula is the architectural migration unit. Migrate by data consumer and contract.

---

## 9. New traffic should use the restored bridge

Once the new Connectome retrieval surface exists and sign-stay parity is proven, new architecture should prefer it.

The first major candidates are:

```text
SynchronicSpine
future ElectionalSpine
Transit state/relation/span contract work
future astrologer doctrine evaluators
```

This prevents new code from deepening dependencies on the narrow legacy top-level surface while old consumers are still being moved.

---

## 10. SynchronicSpine relationship

The SynchronicSpine is fundamental to Field Theory and Pisces.

It is derived from:

```text
engraved natal state
       +
TimeSpine / celestial sky through time
       |
       v
framing.refract
       |
       v
synchronic state through time
```

It is not minted at natal engraving.

It is lazy-built when a user first enables a Pisces function that requires it, analogous to Zodiacal Releasing first-use construction.

The restored Connectome should make the SynchronicSpine reachable as a first-class temporal pathway.

Conceptually:

```text
Connectome.synchronic.spine(...)
```

Exact API deferred.

---

## 11. The synchronic range is a finite connection system

For every engraved natal placement, refraction defines a fixed finite mapping from sky coordinate to synchronic coordinate.

Example:

```text
natal Ascendant = 11 Scorpio
horizon          = 11 Capricorn
synchronic ASC   = 11 Sagittarius
```

That result is always the same for those inputs.

The useful network therefore includes more than a flip event.

It includes:

```text
permitted degree range
reachable signs
reachable houses
reachable rulers
reachable Ring relations
celestial degree intervals where selected conditions are true
```

Prism already contains important permanent structure for this system.

The restored Connectome should make these fixed relations accessible beside the changing SynchronicSpine values.

---

## 12. Electional relationship

A restored Connectome makes an ElectionalSpine much simpler.

At any celestial state, the nervous system should already make questions like these cheap:

```text
Where is Venus?
What sign is Venus in?
Who rules that sign?
Where is that ruler?
Who disposes that ruler?
What is the keeper?
What dignity facts apply?
What relevant aspects exist?
When does one of those facts change?
```

An electional doctrine can then declare which of those pathways matter instead of recalculating the graph.

This supports celestial-range-first electional solving:

```text
doctrine
    -> required / forbidden paths
    -> celestial intervals
    -> interval intersection
    -> civil-time conversion
```

---

## 13. Do not prematurely centralize ownership

Restoring the Connectome does NOT mean moving all calculations into `connectome.js`.

Canonical owners should remain canonical where appropriate:

```text
Ring          geometry
Mater         inherent sign law
Tympan        whole-sign frames
Rulers        dignity facts
Dispositor    governance walking
AstroDNA      state identity / decoded expressions
Framing       refraction
Prism         permanent synchronic structure
TimeSpine     temporal celestial index
```

The Connectome is the nervous system that joins and exposes these truths.

A brain's connectome maps connections. It does not imply that every neuron becomes one neuron.

---

## 14. Retirement conditions

The legacy Connectome span may be removed only when:

```text
all canonical existing outputs have a new owner / retrieval path
all existing consumers have migrated
parity tests pass
browser and source paths agree
persisted Expression behavior is settled
new temporal consumers no longer reach around the Connectome
no fallback silently invokes the legacy path
```

Then:

```text
remove legacy copy
remove temporary comparison plumbing
rename restored implementation to canonical names
retain parity fixtures where they still protect behavior
```

Restoration ends with one Connectome.

---

## 15. Implementation rule

When the coding pass starts, do not begin by editing the current `connectome.js` until its working behavior has been copied and pinned by tests.

The first question is:

> **Can the restored nervous system reproduce the working sign-stay brain map while standing beside it?**

Only after the answer is yes does traffic begin to move.
