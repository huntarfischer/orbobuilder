# ORBO LAWBOOK

**Established:** 2026-08-30  
**Authority:** Governing architectural doctrine for Orbo  
**Status vocabulary:** `FROZEN`, `ACTIVE`, `EXPERIMENTAL`

This file records approved Orbo architectural laws.

Implementation documents explain **how** Orbo is built. This Lawbook governs **what Orbo is**.

Before architectural work begins, read this file first. If living code, tests, specifications, handoffs, frozen branches, or construction notes conflict with a law here, surface the conflict. Do not silently reinterpret the law to preserve convenient code, and do not silently rewrite the implementation to conceal the disagreement.

## Change protocol

A law changes only when the architecture itself is explicitly changed.

```text
architecture changes
        ↓
Lawbook changes
        ↓
implementation changes
```

Never:

```text
implementation was convenient
        ↓
quietly reinterpret the law
```

Frozen implementation is evidence and construction memory. It is not a substitute for the Lawbook.

---

# I. TIMESPINE

## Law 1. Celestial time first
**Status:** FROZEN

The Timespine is celestial time expressed through continuous chronological time.

UT is an occurrence/Bone coordinate. It is not the sole conceptual language of the Timespine.

## Law 2. Multiple traversals
**Status:** FROZEN

The same Timespine may be traversed through different temporal and celestial rungs.

Earth time may locate celestial state. Celestial state may locate occurrence in Earth time.

Neither direction replaces the other.

## Law 3. The matrix
**Status:** FROZEN

The Timespine is the temporal matrix itself.

Celestial degrees and states are embedded locations and events within that matrix.

## Law 4. Direction matters
**Status:** FROZEN

Direct and retrograde celestial passage are not collapsed merely because they occupy the same zodiacal degree.

---

# II. THE THREE DOORS

## Law 5. Door I: Traverse
**Status:** FROZEN

Door I provides a scrollable and traversable view of the Spine.

## Law 6. Door II: Query
**Status:** FROZEN

Door II answers questions across the Spine.

Examples:

```text
When is X?
When are X and Y?
```

## Law 7. Door III: Relation / Link
**Status:** FROZEN

Door III is the **RELATION** door.

Its Timespine verb is **LINK**: to link is to bring two or more explicitly identified points of the Spine into relation by presenting them together.

`RELATION` names what Door III is for. `LINK` is the Spine's vocabulary for performing that basic 2+ point operation.

Door III does not decide what the relationship means or what ritual should be performed with the linked points.

## Law 8. Doors expose the Spine
**Status:** FROZEN

Domain intelligence does not belong in the doors.

The doors expose Timespine capability without becoming owners of the astrology performed with what they expose.

---

# III. HECATE

## Law 9. Hecate stands at Door III
**Status:** FROZEN

Hecate is placed at Door III because her domain is **RELATION**.

Door III establishes the linked set of points. Hecate is the intelligence at the front of the door who decides what relational ritual to perform with those points.

## Law 10. Hecate, not Link, chooses the ritual
**Status:** FROZEN

Link retrieves or presents the requested Timespine points together.

Hecate determines what operation is performed with them.

## Law 11. Relate
**Status:** FROZEN

If existing things remain themselves and the result describes what exists between them:

```text
RELATE → TABLE
```

Examples include relational operations such as synastry, where the participants remain themselves and the result describes the relationship among them.

## Law 12. Cast
**Status:** FROZEN

If the operation produces a new astrological value or astrological object:

```text
CAST → NEW VALUE / OBJECT
```

Examples include a composite field, midpoint, Lot, or Part when the ritual produces new astrological matter from the supplied relation.

## Law 13. The spellbook is a tool
**Status:** FROZEN

Kleides is one collection of relational casts available to Hecate.

Kleides does not define the whole of Hecate.

The spellbook contains preserved ways of relating supplied bodies, placements, coordinates, or other admitted astrological matter that resolve into a new value or object.

Lots and Parts are organized shelves within Kleides. AstroDNA is a Kleis in Kleides but is neither a Lot nor a Part.

## Law 14. Exact retrieval, not hunting
**Status:** FROZEN

Hecate may use Door III to obtain explicitly named Timespine points required by a ritual.

She does not choose alternative moments, search for unspecified matter, or hunt for substitute ingredients.

## Law 15. Summon
**Status:** FROZEN

Titans may be summoned by Hecate as helpers required for a ritual.

`SUMMON` is Hecate's internal action, not the caller's primary Door III command.

The Titans provide their own frozen laws when Hecate needs them; they do not define Hecate or Door III.

## Law 16. No interpretation
**Status:** FROZEN

Hecate establishes or casts astrological relation.

She does not interpret its meaning.

## Law 17. No holding
**Status:** FROZEN

Hecate does not become the persistent owner of the things brought to her or the results she returns.

---

# IV. BOUNDARIES

## Law 18. AstroDNA is downstream matter
**Status:** FROZEN

AstroDNA is not the fundamental address language of the Timespine.

## Law 19. Implementation may not redefine doctrine
**Status:** FROZEN

Convenience in Swift does not promote an implementation detail into an Orbo architectural law.

Implementation must serve the architecture, not quietly replace it.

## Law 20. Conflicts must surface
**Status:** FROZEN

If living code contradicts this Lawbook, stop and expose the conflict.

Do not silently change the Lawbook to match the code.

Do not silently change the architecture to preserve convenient code.

---

# V. HECATE RELATIONAL PRIMITIVES

## Law 21. Point and field grammar
**Status:** FROZEN

Hecate's core relational grammar is determined by action and scale.

At point scale:

```text
RELATE + two celestial points → ASPECT
CAST   + two celestial points → MIDPOINT
```

At field scale:

```text
RELATE + two celestial fields → SYNASTRY TABLE
CAST   + two celestial fields → COMPOSITE FIELD
```

Synastry is composed from point-to-point Aspects across the two supplied fields.

Composite is composed from Midpoints between corresponding points of the two supplied fields.

Aspect and Synastry preserve the supplied matter. Midpoint and Composite create derived astrological matter.

## Law 22. Exact aspect default
**Status:** FROZEN

Aspect matching defaults to **0 arcminutes of orb** unless a caller or downstream system explicitly widens the tolerance.

The exact angular separation is factual matter and does not change when an orb is widened.

A widened orb is a lens over the exact relation. It never rewrites the underlying celestial geometry.

---

# Working rule

Before any new Orbo architectural pass:

```text
READ ORBO_LAWBOOK.md
        ↓
inspect the living repository
        ↓
compare law to implementation
        ↓
propose the smallest faithful change
```

The purpose of this file is to keep approved architecture alive at the point of construction, rather than requiring future work to rediscover frozen decisions from branch history or conversational memory.
