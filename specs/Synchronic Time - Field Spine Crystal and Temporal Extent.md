# Synchronic Time: Field, Spine, Crystal, and Temporal Extent

**Status:** foundational design and reconciliation document. This records the current Field Theory understanding of synchronic time and should be used as a comparison standard while the existing Phase 4, Phase 6, Phase 7, Prism, Loom, Embryo, and spine implementations are reconciled. It does not claim that the living app already implements every law below.

**Companion documents:**

- `specs/Ideal Data Flow - Embryo AstroDNA Connectome Loom.md`
- `specs/Shared Crystal Synchronic Synastry.md`
- `specs/Crystallized Moments - Moment Lock Favorites and Field Taxonomy.md`
- `specs/Phase 7 - Synchronic Time.md`

---

## 0. Governing statement

**The Synchronic Spine is the temporal extension of a Field.**

A chart is already a Field. In Orbo's Field Theory framing, it is a resolved configuration of light and energy in motion at a declared celestial address. A natal chart is not waiting to become a Field when it meets another chart. It is already a Field.

A Field can then be related to another Field. That relation can produce a derived Field.

A natal Field related continuously to celestial time produces its **Synchronic Spine**.

```text
NATAL FIELD A
      +
MOMENT FIELD M(t)
      |
      v
SYNCHRONIC FIELD S_A(t)
```

Formally, using the composite/refraction operation already native to Orbo:

```text
S_A(t) = Composite(A, M(t))
```

or equivalently in the existing Field Theory vocabulary:

```text
S_A(t) = Refract(A, M(t))
```

The exact implementation door remains subject to the framing/Prism reconciliation. The conceptual law is the important part: **for every supported temporal address `t`, the natal Field has a corresponding synchronic state.**

The sequence/function of those states through time is the Synchronic Spine.

> **The Synchronic Spine is the astrology of a Field as a continuous temporal object.**

---

## 1. Field and Crystal are not competing species

### Field

A **Field** is an astrological configuration of light/energy represented by a chart or chart-like state.

Fields may be:

```text
physical
  a celestial configuration that physically existed at a declared time/place

derived
  a configuration produced from one or more Fields by a declared operation

synchronic
  a derived Field produced by relating a Field to a Moment Field
```

Examples:

```text
natal chart                  -> physical Field
email moment chart           -> physical Moment Field
relationship composite       -> derived Field
native + email moment        -> derived synchronic Field
relationship + moment        -> derived synchronic relationship Field
```

### Crystal

A **Crystal** is a Field-state fixed to a particular temporal address so it can be retained, named, compared, returned to, linked, or selected.

A Crystal does not create the state. The state already exists on the relevant temporal continuum.

```text
S_A(t)
continuous synchronic Field
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>

                *
             Crystal C
              at t
```

A Crystal therefore answers:

> **Which coordinate on this Field or Spine matters enough to keep?**

Examples include:

- birth
- death
- conception hypothesis
- message sent
- reply received
- first hearing
- ritual
- historical execution
- suspected childbirth
- exact celestial perfection
- future elected moment
- horary Moment Lock

The Crystal is the retained coordinate. The Field is what exists there.

---

## 2. Birth is the identity coordinate, not the temporal boundary

Birth is mathematically and conceptually privileged because the natal Field is the physical sky at the birth address.

Let `b` be the birth moment.

```text
M(b) = A
```

Therefore:

```text
S_A(b)
= Composite(A, M(b))
= Composite(A, A)
= A
```

Birth is the **identity point** of the Synchronic Spine.

The Phase 7 Prism work already discovered this fixed point in a narrower form: the natal refracted through itself returns itself. This document generalizes that insight.

But identity does not imply boundary.

The correct law is:

> **Birth anchors the Synchronic Spine. It does not bound it.**

A natal Field may be compared with temporal Fields before birth, during life, and after death.

```text
                         BIRTH
                           *
                           |
        before             |               after
-----------|-------|-------|-------|-------|-----------
                           |
                     identity point
```

The native's biography occupies a finite interval of the chronology. The natal Field's temporal addressability is broader.

---

## 3. Biography and synchronic extent are different things

Do not confuse:

```text
BIOGRAPHICAL EXTENT
when the native physically lives

SYNCHRONIC EXTENT
all temporal addresses through which the Field can be related
```

A person does not need to have physically experienced a moment for that moment to have a meaningful synchronic relation to the person's natal Field.

This permits legitimate research questions such as:

- what did the natal Field look like when moved backward into the period of conception?
- what was happening in the mother's synchronic Field over the same prenatal interval?
- what happens to a historical subject's Field in the months after death?
- how does a later historical event relate to the natal Field of someone who died earlier?
- what future moment best satisfies an electional condition for this Field?

Physical participation, biographical experience, and synchronic relation are separate facts.

### Death

Death is therefore a major Crystal and a biographical boundary, but **not a boundary of synchronic computability**.

```text
birth ------------------- death
  |                         |
  |<----- biography ------->|

synchronic extent
<---------------------------------------------->
```

This distinction is essential for historical, ancestral, biographical, and posthumous research.

---

## 4. Finite and infinite at the same time

The Synchronic Spine has several simultaneous senses of extent.

### 4.1 A state is finite

At any exact `t`, `S_A(t)` is determinate. It has finite, addressable structure:

- positions
- signs
- houses under the declared framing doctrine
- governance
- aspects
- Lots
- exact separations
- motion
- applying/separating relation state
- boundary proximity
- other Connectome expression

### 4.2 Time is continuous

`t` varies continuously. The Field can therefore be sampled at arbitrarily fine temporal resolution within the model.

### 4.3 Biography is finite

A human life has a finite embodied interval.

### 4.4 Synchronic relation is not biography-bounded

The natal Field can be related to earlier or later temporal Fields.

### 4.5 Orbo is computationally finite

The actual instrument only supports the astronomical range provided by the Embryo and its ephemeris kernel.

Therefore:

> **The Synchronic Spine is conceptually open across temporal relation, but any shipped Orbo materialization is finite, versioned, and bounded by the Embryo's supported domain.**

The architecture must not mistake today's supported date range for a metaphysical beginning or end.

---

## 5. Time through the Field and Field through time are equivalent views

Field Theory treats these as two descriptions of the same operation:

```text
FIELD MOVING THROUGH TIME
A -> M(t1), M(t2), M(t3)...
```

and:

```text
TIME MOVING THROUGH THE FIELD
M(t1), M(t2), M(t3)... -> A
```

The computation is the same relation.

This is why the Synchronic Clock matters. It is not a decorative current-weather display. It is the transport mechanism for moving through this temporal relation.

> **The Synchronic Clock is the playhead on the Synchronic Spine.**

`NOW` is only the current playhead position.

```text
                         NOW
                          v
------------------------------------------------
                     S_A(t)
```

Move the playhead forward and Orbo reads later Field states.

Move it backward and Orbo reads earlier Field states, including before birth when the supported temporal domain allows it.

No ontological switch occurs when the playhead crosses birth or death.

---

## 6. The return grid is an index, not the ontology

The existing Phase 7 Synchronic Time plan defines a useful clock coordinate:

```text
synchronic time = frame index + sigma/180
```

where frame index identifies the return and sigma identifies position within it.

This can remain a useful coordinate system, transport index, or cache grid. It should not be mistaken for the definition of synchronic existence.

The Field exists at every supported `t`, not only at return anchors.

If the return-index coordinate survives reconciliation, the new temporal law implies:

- birth is index zero / identity;
- pre-birth chronology requires negative or otherwise signed addressing;
- posthumous chronology remains addressable;
- the return grid is one efficient sampling/indexing structure over a broader continuous function.

The distinction is:

```text
SYNCHRONIC SPINE
continuous conceptual function

RETURN GRID
canonical useful samples / coordinates

MATERIALIZED SPINE
cached anchors, crossings, intervals, and other useful structures
```

Do not materialize every instant merely because the function exists at every instant.

---

## 7. A synchronic composite is one sample of the spine

Historically, the workflow often looked like:

```text
pick moment
-> calculate synchronic composite
-> perhaps place composites into chronology
```

The deeper architecture is the reverse:

```text
NATAL FIELD
    |
    v
SYNCHRONIC SPINE
    |
    +--> sample at t1
    +--> sample at t2
    +--> sample at email Crystal
    +--> sample at conception candidate
    +--> sample at future election
```

A single synchronic composite is therefore:

> **the Field state returned when the Synchronic Spine is sampled at one temporal coordinate.**

This is why a meaningful moment does not need to manufacture a new personal timeline. It marks a coordinate on one that already exists.

---

## 8. Crystals, Threads, and Spans sit on the spine

### Crystal

A retained point:

```text
-------------------*-------------------
                   C
```

### Thread

A meaningful set of discrete Crystals:

```text
email sent       reply       call       later feeling
    *              *           *             *
----|--------------|-----------|-------------|--------
```

A Thread records what biography, research, or the user selected as meaningful samples.

### Span

A bounded interval:

```text
start *===========================* end
```

A Span lets Loom examine what happened continuously between two hinges.

Therefore:

```text
CRYSTAL = retained coordinate
THREAD  = selected set of coordinates
SPAN    = bounded interval
SPINE   = underlying temporal function/index
```

A Thread is not automatically a Field. A Span is not automatically a Field. An event Crystal is not automatically a timeline.

---

## 9. Synchronic Synastry is the crossing of two timelines

The earlier working name **Intersections** captured an important truth.

For two natal Fields `A` and `B` under the same Moment Field `M(t)`:

```text
S_A(t) = Composite(A, M(t))
S_B(t) = Composite(B, M(t))
```

Their Synchronic Synastry is:

```text
R_AB(t) = Synastry(S_A(t), S_B(t))
```

This is not a snapshot-only technique. `R_AB(t)` is itself a temporal function.

```text
A SYNCHRONIC SPINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>

B SYNCHRONIC SPINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>

            X
      INTERSECTION
```

An **Intersection** can therefore be retained as the name for an exact or meaningful relational event on the Synchronic Synastry chronology, for example:

- cross-body aspect perfection
- aspect ingress or egress
- applying/separating phase change
- mode shift
- shared governor / chain convergence
- Lot contact
- boundary crossing
- other exact relation event admitted by doctrine

Provisional vocabulary:

```text
SYNCHRONIC SYNASTRY SPINE
continuous relational chronology

INTERSECTION
meaningful exact crossing/event on that chronology
```

The old name was not wrong. It was naming the geometry of the continuous relation before the full vocabulary existed.

---

## 10. Shared moment means shared temporal coordinate

The founding Synchronic Synastry operation remains:

```text
A + M(t) -> S_A(t)
B + M(t) -> S_B(t)

S_A(t) <-> S_B(t)
```

Both sides must be evaluated against the same temporal coordinate and, under the founding shared-Crystal method, the same declared Moment Field.

This is why same-body relations contain a stable structural family while cross-body relations remain dynamically time-sensitive.

The unresolved place/horizon question documented in `Shared Crystal Synchronic Synastry.md` remains unresolved here. This document does not silently choose between the founding shared-event horizon and later two-local-horizon framing.

What is settled is the temporal law:

> **Synchronic Synastry compares two Fields at the same point in synchronic time.**

---

## 11. There are two distinct pair chronologies

Do not collapse these.

### 11.1 Synchronic Synastry Spine

```text
R_AB(t)
=
Synastry(
  Composite(A, M(t)),
  Composite(B, M(t))
)
```

Question:

> How are A's and B's personal synchronic Fields meeting one another through time?

This is the AstroGold-derived founding practice behind Synchronic Synastry.

### 11.2 Relationship-Field Synchronic Spine

First derive the relationship Field:

```text
AB = Composite(A, B)
```

Then move that relationship Field through time:

```text
S_AB(t) = Composite(AB, M(t))
```

Question:

> What is the relationship Field itself doing through time?

These are related but different objects.

A mature relational timeline may expose both.

---

## 12. Historical, prenatal, and posthumous research are native uses

Because birth does not bound synchronic extent, the same machinery can support research outside embodied biography.

### Prenatal / conception research

A natal Field can be moved backward into the months before birth.

A mother's natal Field can independently be moved through the same dates.

Researchers can then compare:

```text
S_child(t)
S_mother(t)
R_child,mother(t)
```

across a candidate conception/pregnancy Span.

A conception hypothesis is a Crystal or candidate Crystal on those timelines, not proof merely because a pattern appears.

### Historical final-year research

A historical natal Field can be moved through the months leading to a known death Crystal, execution Crystal, disappearance, trial, journey, or other documented event.

### Posthumous research

The same natal Field remains mathematically comparable with moments after death. This can be useful for aftermath, legacy, descendants, posthumous events, historical consequences, or research involving another continuing Field.

The temporal classification must record that the moment is posthumous rather than pretending the native personally experienced it.

---

## 13. Death is both boundary and Crystal

Death deserves first-class representation because it performs several roles simultaneously:

```text
DEATH CRYSTAL
  exact/approximate temporal address
  physical Moment AstroDNA
  source confidence
  subject link
  end-of-biography role
  possible Thread/Span hinge
  horary/historical/event readers where appropriate
```

Death can close a biographical Span without closing the Synchronic Spine.

This makes it useful as:

- the end hinge of a life Span;
- a comparison point for final-year chronology;
- a start hinge for posthumous aftermath research;
- a major relational Crystal for surviving Fields;
- a source-confidence-sensitive historical record.

No interpretation is implied merely by classifying a Crystal as death.

---

## 14. Applying and separating belong to synchronic relation edges

A Field state is a snapshot of motion, not a denial of motion.

At one Crystal, a relation may be:

```text
Venus <-> Saturn
trine
orb 0d30m
applying
```

At a later Crystal:

```text
Venus <-> Saturn
trine
orb 0d30m
separating
```

Those are different temporal facts.

Within the Connectome:

```text
NODE MOTION
  body velocity
  direction
  station proximity

RELATION EDGE MOTION
  applying / separating
  relative angular speed
  time to perfection
  time since perfection
  ingress / egress
  possible re-formation
```

Applying/separating belongs primarily to the edge because it describes how a relation between two moving positions is changing.

This information should be available both at retained Crystals and during Loom searches across Spans/Spines.

---

## 15. Lots and fine structure move through the spine too

Lots are not frozen decorations added only after a Crystal is chosen.

Given a state and doctrine, they are derived points whose positions can be evaluated through synchronic time:

```text
Fortune_A(t)
Spirit_A(t)
Eros_A(t)
Necessity_A(t)
Victory_A(t)
...
```

Their relations also form temporal functions:

```text
Eros_A(t) <-> Venus_B(t)
Spirit_A(t) <-> Victory_B(t)
```

They can:

- enter orb
- apply
- perfect
- separate
- leave orb
- change ruler/governor
- cross houses/bounds/other doctrinal structures

This makes Lots and other selected fine structures especially useful for **fine-tuning a candidate Crystal** after larger field conditions have narrowed the search window.

The architecture should therefore support doctrine-provenanced derived-point tables and relation edges in the Connectome without pretending that Lots are AstroDNA genes.

---

## 16. Electional is inverse search across existing synchronic time

Electional does not manufacture a future Field. The future temporal coordinates already define synchronic states.

Given a desired act `X` and a search interval `W`:

```text
find t in W
```

such that the relevant Field conditions best suit `X`.

For one native:

```text
M(t)      physical moment
S_A(t)    native synchronic Field
```

For two people:

```text
S_A(t)
S_B(t)
R_AB(t)   Synchronic Synastry Spine
```

For an existing relationship Field:

```text
S_AB(t)   relationship-field Synchronic Spine
```

Electional can search some or all of these depending on the action and doctrine.

Examples:

- best time to send an email
- worst time to initiate a difficult conversation
- best time to ask
- best time to wait
- best time to prepare
- best time to sign
- best time to arrive

The engine should not force every action into a simplistic positive/negative score. It can search for declared structural testimonies, rank candidate windows, and explain why a candidate survived.

### Coarse to fine

A natural search order is:

```text
large field structure
-> candidate windows
-> governance / major relations
-> applying/separating and lunar condition
-> Lots / fine structure / exact degree relations
-> exact candidate Crystal
```

The broad structure chooses the neighborhood. Fine structure chooses the doorstep.

When the user selects a future candidate, that temporal coordinate may then be retained as a planned/elected Crystal.

---

## 17. Horary and electional are temporal inverses

Horary:

```text
significance announces itself now
-> capture t
-> crystallize
-> read the Field at t
```

Electional:

```text
desired field condition
-> search t
-> choose candidate
-> crystallize future t
```

So:

```text
HORARY
TIME -> FIELD

ELECTIONAL
FIELD CONDITION -> TIME
```

Both belong to the same temporal organism.

The difference is direction of inquiry, not celestial authority.

---

## 18. The Synchronic Clock is the wheel in motion

The functional Synchronic Clock should expose the Synchronic Spine as something the user can physically navigate.

It should support at least the conceptual acts:

```text
NOW
move forward
move backward
jump to Crystal
jump to Intersection
scrub by body / temporal handle
return to natal identity
```

The instrument is not merely changing a date label. It is displaying the Field at a new temporal coordinate.

Because different functions move at different rates, the clock naturally contains nested rhythms. The Ascendant is fast, the Moon is fast, and slower planets create longer gears underneath.

The clock should therefore be understood as:

> **the visible transport of a Field through synchronic time.**

This is foundational to the experience, not a secondary reader.

---

## 19. Materialization is selective even though the function is continuous

The conceptual function exists across every supported `t`.

The app should still refuse the idea that every instant must be stored.

```text
CONTINUOUS FUNCTION
S_A(t)

        |
        v
SELECTIVE MATERIALIZATION
returns
boundaries
perfections
stations
Intersections
requested windows
favorite coverage
retained Crystals
```

The Embryo supplies canonical physical AstroDNA at requested temporal addresses.

Derived synchronic AstroDNA is produced from the natal/anchored Field and the Moment AstroDNA.

Connectome expresses each state.

Loom solves temporal crossings.

Spines cache/index the useful temporal structure.

This remains consistent with:

```text
Embryo -> AstroDNA -> Connectome -> Loom -> Spines
```

The Synchronic Spine is conceptually the function. A materialized spine is the instrument's practical index/cache of that function.

---

## 20. Favorite builds are Field-type dependent

Favoriting means computational commitment, but **commitment does not imply the same build for every Field type**.

A natal Field, relationship Field, company-origin Field, and one-time event Field are not temporally identical objects.

Examples:

```text
NATAL FIELD
  merits synchronic temporal coverage
  supports pre-birth / life / posthumous extension

RELATIONSHIP FIELD
  merits its own synchronic Field spine
  may also participate in a Synchronic Synastry pair spine

ORIGIN-ANCHORED PERSISTENT FIELD
  company, project, team, institution
  may merit temporal coverage around its active history and beyond on demand

FINITE EVENT CRYSTAL
  does NOT receive an independent timeline by default
  persist its AstroDNA / Connectome / provenance
  use it as a parent, hinge, Thread member, Span endpoint, Horary figure, or comparison target
```

A favorite event may deserve faster recall and richer cached relations. That is not the same thing as inventing a century spine for an event whose defining nature is one finite moment.

The detailed Favorite build policy belongs in the Crystallized Moments taxonomy companion document.

---

## 21. Provisional laws

1. **A chart is already a Field.**
2. **A Crystal is a Field-state fixed to a temporal address for retention, comparison, return, or selection.**
3. **A synchronic Field is a Field related to a Moment Field.**
4. **The Synchronic Spine is the temporal extension/function of that synchronic relation.**
5. **Birth is the natal Field's identity coordinate, not the boundary of synchronic time.**
6. **Death is a biographical boundary and major Crystal, not the end of synchronic addressability.**
7. **Physical participation and synchronic relevance are separate facts.**
8. **Time through the Field and Field through time are equivalent views of the same operation.**
9. **NOW is a playhead position, not a special species of synchronic state.**
10. **A synchronic composite is one sample of the Synchronic Spine.**
11. **A return grid may index the spine but does not define its existence.**
12. **If birth remains coordinate zero, pre-birth traversal must be addressable rather than forbidden by the index.**
13. **Crystals, Threads, and Spans organize meaningful coordinates; they are not automatically Fields with independent spines.**
14. **Synchronic Synastry is the continuous relation between two synchronic timelines evaluated at the same temporal coordinate.**
15. **Intersections are exact/meaningful relational events on that Synchronic Synastry chronology.**
16. **Synchronic Synastry Spine and relationship-field Synchronic Spine are different objects.**
17. **Applying/separating is first-class temporal information on relation edges.**
18. **Lots and other derived fine structures can trace trajectories through synchronic time and help fine-tune Crystals.**
19. **Electional searches existing synchronic time for desired structural conditions, then selects a future Crystal.**
20. **Horary captures a present Crystal because significance has already announced itself.**
21. **The Synchronic Clock is the playhead/transport of the Synchronic Spine.**
22. **The conceptual spine is continuous; materialization remains sparse, partial, and purpose-driven.**
23. **Favorite materialization depends on Field type.**
24. **An event Crystal does not receive an independent timeline merely because it was favorited.**

---

## 22. Reconciliation targets

Before implementation, compare this model against:

- `specs/Phase 7 - Synchronic Time.md`
- Phase 4 Composite Chronology and pair-film decisions
- Phase 6 Prism and Query plans
- `specs/Shared Crystal Synchronic Synastry.md`
- `prism.js`
- `framing.js`
- `loom.js`
- `fertilize.js`
- live `_makeSpine()` / cursor behavior
- current favorite persistence
- current Connectome relation and motion shapes
- current Lots/sect derivation

Specific questions:

1. Which parts of Phase 7's return-grid coordinate remain useful as indexing rather than ontology?
2. What currently prevents negative/pre-birth synchronic addressing?
3. What, if anything, currently stops computation at death or an assumed century lifespan?
4. Where should the Synchronic Clock obtain its state so that it is truly a playhead over the restored Embryo/AstroDNA architecture?
5. Which exact Synchronic Synastry events should be named `Intersections` in engine/UI vocabulary?
6. How should applying/separating, time-to-perfection, and Lot trajectories be expressed in the restored Connectome?
7. How should Favorite build policy vary by natal, relationship, persistent-origin, and finite-event Field types?
8. How should historical/pre-birth/posthumous provenance be represented without implying embodied experience?

Do not build a second temporal engine from this document. Reconcile the existing clock, Prism, Loom, Connectome, and spine pieces into the one temporal organism described here.