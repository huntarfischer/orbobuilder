# Chronos — Temporal Query MVP

**Status:** FROZEN / PROVEN  
**Target:** Orbo 1.0 native  
**Branch:** `feature/chronos-mvp`  
**Base:** `feature/engraving-orbospine-graft`  
**Certified implementation head:** `91f86b68649a9c165f48505540bb5e387b64d1df`  
**Certification date:** 2026-08-27

## 1. Purpose

Chronos is Orbo's temporal query authority.

> **Chronos receives a factual temporal predicate and returns the ordered temporal addresses at which that predicate is true.**

Chronos does not interpret those facts, rank their importance, explain their meaning, or create relationship truth.

The first implementation must establish the correct permanent shape with the smallest useful surface.

---

## 2. Three-door separation

```text
ORBOSPINE
      |
      +-- DOOR I: LOCATE
      |       |
      |     HORAE
      |       |
      |   one temporal state
      |
      +-- DOOR II: LIBRARY
      |       |
      |    CHRONOS
      |       |
      |   temporal address set
      |
      +-- DOOR III: LINK
              |
            HECATE
              |
         relational truth
```

### Horae

Horae resolve and expose one temporal position.

Their fundamental shape is a movable plane across the Spine:

```text
one UT
  -> complete celestial + Terra cross-section
```

Horae may use body, directional state, and UT as grips to resolve one lawful Spine address. Their occurrence machinery exists to move truthfully to one selected position.

### Chronos

Chronos is set-oriented.

```text
one factual predicate
        |
        v
zero / one / many temporal addresses
```

Chronos preserves multiplicity because multiplicity is part of the answer.

### Hecate

Hecate owns comparison and convergence between two or more lawful addressed states, moments, charts, or Spines.

Chronos may enumerate relational facts already made true and stored by another authority, but Chronos may not create relational truth.

Permanent firewall:

```text
Chronos may return:
[t1, t2, t3]

Chronos may not determine:
t1 <-> t2
chart A <-> chart B
composite A + B
synastry A + B
```

---

## 3. Separation from meaning

Horae, Chronos, and Hecate expose fact. They do not interpret fact.

Chronos may answer:

```text
When does Mercury station?
When is Mars at this exact directional state?
What interval is Wave W12?
What absolute instant corresponds to this civil birth time?
```

Chronos may not answer:

```text
Is this important?
Is this favorable?
What does this mean?
Is this good for romance?
When will I have a breakthrough?
```

No Chronos query or answer type should contain interpretive variables such as:

```text
importance
strength
benefic / malefic
romance
career
good / bad
meaning
prediction
recommendation
```

---

## 4. Query law

Chronos answers:

> **WHERE ON TIME IS THIS FACT TRUE?**

Chronos does not own the truth being queried. He asks the authority that already owns it.

Initial sources:

```text
CIVIL TIME
human civic time -> absolute temporal address candidates

HORAE AVAILABILITY
exact body/state -> occurrence UTs

ORBOSPINE LIBRARY
prepared chronology -> stored moments / intervals
```

Chronos must never receive `OrboSpineLocate` directly.

For continuous tract occurrence truth, Chronos asks Horae's public availability surface.

For prepared chronology, Chronos reads through a Door II Library-facing read surface rather than receiving the whole `OrboSpineRuntime`.

---

## 5. Query and expression are separate

```text
ChronosQuery
WHAT temporal truth is requested?
        |
        v
Chronos
        |
        v
ChronosAnswer
WHERE in time is it true?
        |
        v
ChronosExpression
HOW should those facts be returned?
```

Export and presentation must never affect truth selection.

---

## 6. MVP query families

The MVP supports only four factual predicates.

### 6.1 Civil moment

```text
civilMoment(
    date,
    time,
    timezone
)
```

Purpose:

```text
human civic time
        |
        v
Chronos
        |
     CivilTime
        |
        v
canonical temporal address candidate(s)
```

This immediately serves Clotho.

Civil-time ambiguity is preserved.

A repeated wall-clock time may yield two lawful moments. Chronos returns both in temporal order.

A nonexistent civil time remains unresolved. Chronos does not guess.

Unknown timezone, unsupported year, and unsupported calendar remain explicit unresolved outcomes.

### 6.2 Body state

```text
bodyState(
    body,
    directionalDegree
)
```

Purpose:

```text
exact canonical body/state
        |
        v
Chronos
        |
        v
Horae occurrence availability
        |
        v
ordered occurrence moments
```

Chronos does not move Horae's plane and does not request a `HoraeOutput`.

### 6.3 Station

```text
station(
    body
)
```

Purpose: prove one prepared Library chronology returning moments.

### 6.4 Shell

```text
shell(
    shellID
)
```

Purpose: prove one prepared Library chronology returning an interval.

These four predicates establish the architecture. Retrograde passages, Ring chronology, eclipses, and other shelves are later breadth, not MVP architecture.

---

## 7. Temporal answer law

Chronos has only two address shapes:

```text
MOMENT
JulianDay

INTERVAL
[start, endExclusive)
```

Conceptually:

```swift
enum ChronosAddress {
    case moment(JulianDay)
    case interval(start: JulianDay, endExclusive: JulianDay)
}
```

A Chronos answer is an ordered collection of factual hits:

```text
ChronosAnswer
└── hits: [ChronosHit]
```

Each hit contains only:

```text
temporal address
+
minimal factual identity / source reference
```

Example:

```text
moment: JD x
fact: Mercury station
```

or:

```text
interval: [JD x, JD y)
fact: Wave W12
```

A valid query with no matches returns an empty hit set. It is not an error.

Machine provenance may identify the canonical source row or authority, but must not introduce semantic description.

---

## 8. Temporal operators

Chronos may bound and order temporal fact without interpreting it.

MVP variables:

| Variable | Purpose |
| --- | --- |
| `predicate` | factual condition being queried |
| `scope` | whole available domain or `[start,end)` |
| `relation` | `all`, `before`, `after`, `previous`, `next`, `nearest`, `containing` |
| `anchor` | explicit UT for relational queries |
| `order` | `ascending`, `descending` |
| `limit` | optional positive result cap |
| `projection` | factual columns to expose |
| `timezone` | optional civic rendering timezone |
| `format` | `native`, `txt`, `csv`, `pdf`, `iCalendar` |

`previous`, `next`, `nearest`, `before`, `after`, and `containing` require an explicit anchor.

Chronos must not secretly substitute the current time.

Temporal relation means only relation in time.

It never means:

```text
stronger
better
important
favorable
compatible
similar
```

If two answers are equally nearest, both may be returned. Chronos has no need to collapse multiplicity merely to choose one plane.

---

## 9. Expression and export

The same identified answer may be expressed many ways without rerunning or changing the query:

```text
ChronosAnswer
      |
      +-- native
      +-- .txt
      +-- .csv
      +-- .pdf
      +-- iCalendar (.ics)
```

### Native

Structured Orbo result for downstream consumers.

### TXT

Plain factual ordered enumeration.

### CSV

Stable one-hit-per-row data export.

Possible factual columns include:

```text
start_ut
end_ut
fact
body
directional_state
source
```

Only columns relevant to the query are emitted.

### PDF

Neutral printable chronology / almanac.

Allowed:

```text
headings
dates
tables
pagination
machine provenance
```

Forbidden:

```text
interpretation
importance
ratings
advice
semantic commentary
```

### iCalendar

Standard `.ics` expression.

Moments become dated calendar entries. Intervals receive start/end bounds.

Summary labels remain literal factual identities:

```text
Mercury station
Solar eclipse
Saturn retrograde passage
Wave W12 begins
```

Never semantic labels such as:

```text
Important Mercury turning point
Powerful eclipse energy
```

---

## 10. Chronos / Horae implementation boundary

Horae consume multiplicity to resolve one state.

```text
HORAE
"Where may this control go?"
        |
occurrence set
        |
select one
        |
MOVE PLANE
```

Chronos preserves multiplicity as the answer.

```text
CHRONOS
"When is this fact true?"
        |
occurrence set
        |
RETURN THE SET
```

This is the permanent distinction even where both consult the same canonical occurrence truth.

Chronos may use Horae's read-only availability capability but may not:

```text
move Horae
retain a currentUT
request a HoraeOutput as query result
receive Locate
reimplement occurrence topology
```

---

## 11. Chronos / Hecate implementation boundary

Chronos owns temporal enumeration.

Hecate owns relation and convergence.

Chronos may later query a relation already established and stored by another authority, such as a canonical Ring chronology occurrence.

Chronos may not itself compare:

```text
moment A with moment B
chart A with chart B
Spine A with Spine B
subject A with subject B
```

Chronos may enumerate Hecate-established truths later, but may not manufacture Hecate's truth.

---

## 12. Clotho as first customer

Chronos is not designed around Clotho, but Clotho supplies the first required use.

```text
ENGRAVING
birth date + birth time
        |
ATLAS TOPOS
timezone
        |
        v
CLOTHO
  "when is this?"
        |
        v
CHRONOS
        |
     CivilTime
        |
        v
ordered temporal address candidate(s)
```

When exactly one lawful birth moment exists:

```text
Clotho
  |
  | "show me there"
  v
Horae
  |
  v
HoraeOutput
  |
  v
Clotho spins AstroDNA
```

If Chronos returns two lawful birth moments, Clotho does not choose.

If Chronos cannot resolve the civic time, Clotho does not guess.

No natal pin is placed in the Mundane OrboSpine.

No Natal Spine exists at this stage.

Personal Spine manufacture remains locked until Hestia accepts the Tapestry and authorizes Hephaestus.

---

## 13. Negative architecture

Chronos MVP contains no:

```text
astronomical calculation
ephemeris
second Timespine
persistent currentUT
playback
interpretation
semantic ranking
recommendation
prediction
relationship engine
synastry
composite math
Hecate logic
HoraeOutput ownership
Locate ownership
personal-Spine manufacture
Hestia persistence
user favorites / bookmarks
```

Chronos does not become an events database. He queries canonical temporal matter and returns addresses.

---

## 14. Build plan

### Stage 0 — Chronos contract

Add only the foundational vocabulary and tests:

```text
ChronosAddress
ChronosHit
ChronosAnswer
ChronosQuery
scope
relation
order
unresolved outcomes
```

Prove:

```text
zero / one / many
moment / interval
stable ordering
no interpretation fields
```

No CivilTime, Horae, Library, exports, or Clotho.

### Stage 1 — Civic time

Add `civilMoment` through existing `CivilTime`.

Prove:

```text
ordinary civil time -> one moment
repeated DST time -> two ordered moments
nonexistent time -> explicit unresolved result
unknown timezone -> explicit unresolved result
unsupported year/calendar -> explicit unresolved result
```

This is enough to satisfy Clotho's immediate temporal-address need, but Clotho is not modified yet.

### Stage 2 — Horae occurrence source

Give Chronos access to Horae, not Locate.

Add `bodyState` through Horae occurrence availability.

Prove:

```text
zero / many results
Bone scoping
ascending order
Chronos does not move Horae
Chronos produces no HoraeOutput
Chronos owns no occurrence topology
```

### Stage 3 — Door II graft

Create the smallest read-only Library surface required to expose existing canonical prepared chronology without giving Chronos the full `OrboSpineRuntime`.

Support only:

```text
station(body)
shell(shellID)
```

Prove:

```text
Library moment query
Library interval query
no copied chronology ownership
no full runtime ownership
```

### Stage 4 — Temporal operators

Add:

```text
scope
explicit anchor
all
before
after
previous
next
nearest
containing
ascending / descending
limit
```

Prove all operations remain purely temporal.

### Stage 5 — Expression / export

Add projection and expression of an already-resolved `ChronosAnswer` as:

```text
native
TXT
CSV
PDF
iCalendar (.ics)
```

Prove export:

```text
does not rerun the query
does not alter result identity
does not introduce semantic meaning
```

Then run the full accumulated package suite and freeze Chronos MVP.

---

## 15. After MVP freeze

Only after Chronos itself is proven should the Clotho seam be modernized.

That later graft should:

```text
remove stale Clotho "Door One / Port I" vocabulary
ask Chronos for the birth temporal address
ask Horae to seek that address
use the resulting mundane cross-section to continue AstroDNA formation
```

The later graft must not change Horae's Door I ownership, create a Clotho door, or create a Natal Spine before Hearth authorization.

---

## 16. Freeze target

The MVP succeeds if this statement is true:

> **Chronos queries time, preserves every lawful answer, orders temporal fact without interpreting it, and expresses the same chronology without changing its truth.**

---

## 17. Certification record

### 17.1 Proven build

The implementation certified for this MVP ends at:

```text
91f86b68649a9c165f48505540bb5e387b64d1df
Prove Chronos Stage 5 expression and export
```

The accumulated native package proof on that implementation head is:

```text
TympanTests
19 tests
0 failures

OrboCorePackageTests.xctest
531 tests
0 failures

All tests
531 tests
0 failures
0 unexpected
```

This is the authoritative freeze proof for the implementation bytes. The freeze commit changes this specification only.

### 17.2 Branch-delta audit

Compared with the isolated build base `ccedfcce7c93497582fe45ca61d698eca6b8b612`, the certified implementation is 17 commits ahead and 0 behind.

The production delta is intentionally narrow:

```text
Chronos/
  Chronos.swift
  ChronosTypes.swift
  ChronosHorae.swift
  ChronosLibrary.swift
  ChronosOperators.swift
  ChronosExpression.swift

OrboSpine/
  OrboSpineLibrary.swift
  OrboSpineRuntime.swift
```

The OrboSpine change is limited to the Stage 3 Door II ownership/read seam. No Locate or Link production file changed.

### 17.3 Ownership audit

The frozen source satisfies these boundaries:

```text
CIVIL TIME
Chronos delegates civic resolution to CivilTime.
Chronos owns no timezone-history or Julian-day conversion law.

DOOR I / HORAE
Chronos receives Horae for occurrence availability only.
Chronos does not receive OrboSpineLocate.
Chronos does not request or return HoraeOutput.
Chronos does not move the Horae plane.

DOOR II / LIBRARY
OrboSpineLibraryCatalog owns the prepared station and shell rows exposed to Chronos.
Chronos receives the Library catalog, not OrboSpineRuntime.
Runtime compatibility views reference Library-owned matter rather than retaining a second station/shell chronology.

DOOR III / HECATE
Chronos contains no Link or Hecate relation engine.
No synastry, composite, comparison, or convergence truth is manufactured here.
```

### 17.4 State and multiplicity audit

Chronos is an enum of static query/expression behavior and retains no persistent temporal cursor.

```text
no currentUT
no playback state
no hidden now
```

Multiplicity remains lawful answer data:

```text
civil repeated hour -> two moments
body/state occurrence -> zero / one / many moments
equal nearest -> every equally-nearest hit
```

No operator is permitted to collapse a plural answer merely to choose one temporal plane.

### 17.5 Operator audit

Stage 4 operators act only on already-resolved `ChronosAnswer` truth.

```text
predicate identity
scope
before / after
previous / next
nearest
containing
order
limit
```

Scope selects canonical addresses but does not clip or rewrite them. Relational operators require an explicit anchor and never substitute the current time.

### 17.6 Expression audit

Stage 5 expression receives only:

```text
ChronosAnswer
+
ChronosExpressionRequest
```

An expression request contains format, projection, and optional civic rendering timezone. It has no predicate or source-query authority.

Frozen formats:

```text
native
TXT
CSV
PDF
iCalendar (.ics)
```

Native returns the exact answer. Other formats project the same ordered hits. Optional civic rendering supplements, but does not replace, canonical Julian Day identity. iCalendar uses deterministic UTC event bounds and carries exact Orbo Julian-day fields.

Expression does not rerun Chronos, CivilTime, Horae, Library, Locate, or any astronomical authority.

### 17.7 Negative audit

No Chronos production source owns or implements:

```text
ephemeris / astronomy
second Timespine
persistent currentUT
playback
interpretation or semantic ranking
prediction or recommendation
relationship / synastry / composite logic
Hecate logic
Locate ownership
HoraeOutput ownership
Clotho behavior
Hestia persistence
personal-Spine manufacture
```

Clotho remains outside this MVP and must be modernized only after the frozen Chronos work is reintegrated onto the current integration line.

### 17.8 Freeze declaration

**Chronos Temporal Query MVP is frozen and proven.**

The freeze target is satisfied:

> **Chronos queries time, preserves every lawful answer, orders temporal fact without interpreting it, and expresses the same chronology without changing its truth.**

Any later addition of predicates, Library shelves, export richness, or consumers is post-MVP breadth and must preserve this ownership law rather than reopening it implicitly.
