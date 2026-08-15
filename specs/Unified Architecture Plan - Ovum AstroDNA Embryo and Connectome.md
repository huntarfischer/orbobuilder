# Unified Architecture Plan - Ovum, AstroDNA, Embryo, and Connectome

**Status:** high-level reconciled architecture and migration order.

**Date:** 2026-08-15.

**Purpose:** establish the shared conceptual architecture for Orbo before the detailed phase plans are written. This document answers three questions:

1. Where are we?
2. Where are we going?
3. How do we get there?

This is not yet the detailed implementation plan for each phase. It is the reference architecture those plans must obey.

---

# 0. Governing idea

Orbo is a celestial-time instrument that ships already knowing the astrosphere.

Before Orbo knows a native, it can move through celestial time using its universal machinery and the Orbo Spine.

During onboarding, Orbo determines the user's exact natal coordinate. If that coordinate is uncertain, rectification exists to determine it.

That natal configuration is encoded in exactly the same AstroDNA language Orbo always uses, but it is then **engraved as my AstroDNA**.

That act fertilizes the Ovum.

The result is a personalized Orbo whose entire computational nervous system can now be organized around that one immutable celestial address.

The product story and the architecture are the same story:

```text
Orbo knows the astrosphere.

Onboarding determines where I am in it.

Engraving makes that position the root of my Orbo.
```

The shortest computational form is:

```text
ASTROSPHERE
    ↓
EPHEMERIS
    ↓
ORBO OVUM
    ↓
ASTRODNA
```

Then:

```text
AstroDNA of my birth
        ↓
      ENGRAVE
        ↓
   MY ASTRODNA
        ↓
   FERTILIZATION
        ↓
      EMBRYO
        ↓
 personalized Orbo
```

---

# I. WHERE WE ARE

Orbo already contains much of the machinery required for this architecture.

The problem is not that the system lacks engines. The problem is that engines were built at different stages of Orbo's conceptual development, so ownership and circulation do not yet consistently obey the architecture we now understand.

Today Orbo already substantially possesses:

```text
Universal geometry and law
  Ring
  Mater
  Tympan
  Rulers

Astronomical machinery
  ephemeris
  live celestial cursor

Celestial encoding
  AstroDNA
  arcsecond-resolution genome
  coarser projections where appropriate

Structural expression
  Dispositor
  current sign-resolution Connectome Expression

Temporal machinery
  Loom
  mundane chronology
  timespine.js
  transits
  Luna
  progressions
  progressed aspects
  Zodiacal Releasing

Derived-field machinery
  framing / refraction
  Prism
  composites
  synchronic calculations

Technique machinery
  electional
  Horary architecture
  interpretation readers

Presentation
  Lunar Port
  plates
  sockets
  Tabulas
  Almanac

Memory ancestors
  Pins
  Ledger
  Favorites
  Field Journal work
```

There is also an important living ancestor in `fertilize.js`: Orbo ships a native-independent temporal structure, native data fertilizes it, and Loom produces personal CONTACT and SYNCHRONIC structures. The ontology around that code has changed, but the underlying insight remains valuable.

The current architectural problems are therefore primarily:

```text
duplicate authority
incomplete expression
mixed ownership
historical naming
parallel temporal pathways
partial user-memory ontology
```

The goal is reconciliation, not a greenfield rewrite.

---

# II. WHERE WE ARE GOING

# 1. The Ovum is the walled garden

Every copy of Orbo ships with an **Ovum**.

The Ovum is complete enough to operate as a celestial-time instrument without a native, but it has not yet been personalized.

Conceptually:

```text
┌────────────────────── ORBO OVUM ──────────────────────┐
│                                                       │
│  EPHEMERIS ACCESS                                     │
│  private astronomical mechanics                       │
│                                                       │
│  ORBO SPINE                                           │
│  universal native-independent celestial chronology    │
│                                                       │
│  INHERENT CONNECTOME LAW                              │
│  Ring                                                 │
│  Mater                                                │
│  Tympan                                               │
│  Rulers                                               │
│                                                       │
│  ASTRODNA ENCODING                                    │
│  maximal-fidelity celestial encoding                  │
│                                                       │
│  LOOM / temporal solving machinery                    │
│                                                       │
│  RESONATOR / invariant checking                       │
│                                                       │
└───────────────────────────────────────────────────────┘
```

The Ovum is a real architectural membrane.

The rest of Orbo should not independently ask the ephemeris, the Orbo Spine, or other raw astronomical machinery for competing versions of celestial state.

The Ovum encapsulates the machinery required to resolve a valid celestial configuration.

What comes out is **AstroDNA**.

---

# 2. The ephemeris remains separate

The ephemeris is not the Ovum itself.

It is astronomical mechanics encapsulated by the Ovum.

```text
EPHEMERIS
mechanics

    ↓ private access

OVUM
celestial-state authority

    ↓

ASTRODNA
```

The ephemeris may know how to calculate positions, angles, and motion.

It does not decide what constitutes an Orbo state.

The architectural law is:

> **The Ovum encapsulates access to the ephemeris.**

---

# 3. The Orbo Spine ships with every Orbo

The Orbo Spine is the universal celestial chronology.

It exists before a user and before fertilization.

```text
ORBO SPINE

past ============================================ future
              │        │     │
           ingress  station eclipse ...
```

It can carry or index native-independent temporal truths such as:

```text
planetary ingresses
stations
retrograde periods
lunations
eclipses
universal celestial contacts
other admitted celestial hinges
```

The Orbo Spine is **not a second application-facing state authority**.

It is internal temporal substrate inside the Ovum.

If the application asks what the heavens are doing at a particular address, the answer still crosses the Ovum boundary as AstroDNA.

```text
Orbo Spine
    │
    │ internal assistance
    ▼
Ovum
    ▼
AstroDNA
```

This prevents a split architecture such as:

```text
reader A → AstroDNA
reader B → Orbo Spine row
reader C → ephemeris
```

Downstream Orbo speaks one celestial language.

The Orbo Spine should be canonical in meaning across installations while remaining versioned as a shipped artifact so its range, precision, indexed families, and corrected astronomical material can evolve safely.

---

# 4. AstroDNA is the universal celestial encoding

AstroDNA is the encoding system Orbo uses for complete celestial configurations.

Its canonical twelve nodes are:

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

The guiding law is:

> **Preserve maximum useful fidelity upstream. Reduce resolution downstream only where the truth being stored cannot change at the finer resolution.**

Therefore:

```text
arcsecond AstroDNA
      ↓
whole-degree projection
      ↓
sign projection
      ↓
sign-stay cache
```

is legitimate.

Trying to recover lost precision from a coarse encoding is not.

This is the architectural reason for moving beyond the old coarse `0-719` whole-degree representation toward the most specific reliable ephemeris-derived encoding.

The full AstroDNA is authoritative. Coarser cuts are named computational conveniences.

---

# 5. "My AstroDNA" is a privileged AstroDNA, not another format

The Ovum can resolve AstroDNA for any supported celestial address, including:

```text
now
an eclipse
a death
an email
a Horary question
a historical event
a future election
another meaningful moment
```

But onboarding identifies one AstroDNA as uniquely important:

```text
birth address
    ↓
Ovum
    ↓
AstroDNA
    ↓
ENGRAVE
    ↓
MY ASTRODNA
```

"My AstroDNA" has the same encoding structure as any other AstroDNA.

Its specialness comes from its role inside Orbo, not from additional metadata glued onto the genome.

This AstroDNA becomes the immutable root around which the personalized Orbo is organized.

The genome itself does not need to carry a flag saying that it is home. Orbo knows which AstroDNA has been engraved as the native root.

---

# 6. Rectification is part of fertilization

Orbo is designed around having a natal coordinate.

If the user knows their birth time, fertilization is straightforward.

If the user does not, Orbo helps determine the missing coordinate.

```text
Do you know your birth time?
          │
     ┌────┴────┐
     │         │
    yes        no
     │         │
     │     rectification
     │         │
     └────┬────┘
          ▼
 precise natal address
          ▼
       AstroDNA
          ▼
        ENGRAVE
```

The rectification system is therefore not merely an optional astrology feature.

It is part of Orbo's onboarding and fertilization apparatus.

The instrument exists before the native. Rectification helps determine the exact coordinate needed to make the instrument theirs.

---

# 7. Fertilization turns the Ovum into the Embryo

This is the decisive transition.

```text
ORBO OVUM
unpersonalized Orbo

     +

MY ASTRODNA
native genome

     ↓

FERTILIZATION

     ↓

ORBO EMBRYO
personalized Orbo
```

The Embryo is not a temporary build step.

It is the personalized organism that persists.

After fertilization, Orbo can continually relate new AstroDNA to **my AstroDNA**.

```text
MY ASTRODNA
     │
     ├──── moment AstroDNA
     ├──── progressed calculation
     ├──── another person's AstroDNA
     ├──── composite AstroDNA
     └──── event AstroDNA
```

Before fertilization Orbo knows the heavens.

After fertilization Orbo knows the heavens relative to the native.

The current `fertilize.js` should therefore be treated as an architectural ancestor to reconcile, not as the final definition of fertilization.

---

# 8. The Connectome is AstroDNA unfolded

AstroDNA says, in compressed form:

```text
these are the exact celestial coordinates
```

The Connectome expresses what those coordinates structurally imply.

```text
ASTRODNA
    ↓
CONNECTOME
    ↓
structure
```

The Connectome is where structural expression belongs, including families such as:

```text
sign
degree
house
motion
dignity
rulership
dispositorship
keeper
reception
relations
applying / separating
Lots
Forged Ring
temporal handles
```

These should not be bloated into the AstroDNA genome itself.

The governing sentence remains:

> **The Connectome is AstroDNA unfolded.**

---

# 9. Ring, Mater, Tympan, and Rulers are inherent Connectome law

Their conceptual membership in the Connectome is compatible with their physical presence in the shipped Ovum.

The distinction is:

```text
INHERENT CONNECTOME LAW
ships inside the Ovum

Ring
Mater
Tympan
Rulers
```

versus:

```text
EXPRESSED CONNECTOME
created against a particular AstroDNA

gene tables
house network
governance
relations
conditions
Lots
Forged Ring
temporal references
```

Therefore:

```text
Ring / Mater / Tympan / Rulers
             +
          AstroDNA
             ↓
         Connectome
```

The law ships universally.

The expression becomes specific.

---

# 10. Every AstroDNA gene becomes a first-class Connectome node

The restored Connectome should express the primary AstroDNA as a graph of first-class nodes and canonical edges.

```text
CONNECTOME

Ascendant node
Moon node
Sun node
Mercury node
Venus node
Mars node
Jupiter node
Saturn node
Uranus node
Neptune node
Pluto node
North Node node

RELATION EDGES

HOUSE / GOVERNANCE NETWORK

DERIVED POINTS

FORGED RING

TEMPORAL REFERENCES
```

Each node contains what is true of that gene.

Facts that exist between genes belong to canonical relation edges.

The important ownership law remains:

> **Velocity belongs to the node. Applying and separating belong to the edge.**

---

# 11. The Forged Ring belongs to the expressed Connectome

The universal Ring knows angular geometry.

An AstroDNA-specific Forged Ring knows where those geometries strike this particular configuration.

```text
UNIVERSAL RING
      +
   ASTRODNA
      ↓
FORGED RING
```

This belongs to the Connectome because it cannot exist before a specific AstroDNA exists.

The Ring owns exact geometry.

Doctrine determines what surrounding orb or testimony matters.

The Forged Ring should support both gene-facing and circle-facing traversal over one exact lattice.

---

# 12. Loom remains a solver

The Loom does not own the sky.

It does not own a chart.

It does not interpret.

Its job remains:

> **The Connectome knows the target. The Loom finds the crossing.**

```text
Connectome target
      ↓
Loom
      ↓
candidate time
      ↓
Ovum / Embryo celestial authority
      ↓
AstroDNA at candidate
```

A downstream system never treats Loom's intermediate calculation as a celestial authority.

A candidate becomes a complete Orbo celestial state by being resolved as AstroDNA.

The same law applies to optimized single-gene reads: they may exist for performance, but they must be definitionally identical to the corresponding gene in the complete AstroDNA that the canonical encoder would produce.

---

# 13. Personalized temporal structures grow downstream

Once fertilized, personal temporal systems can grow around my AstroDNA.

```text
MY ASTRODNA
      │
      ├── Contact structures
      ├── Synchronic Spine
      ├── Progressions
      ├── Zodiacal Releasing
      ├── Synchronic Synastry
      ├── Electional relationships
      └── other personal chronologies
```

These are not additional celestial authorities.

They are temporal organizations, derivations, and indexes of AstroDNA-based truth.

A materialized spine is rebuildable. It is never more authoritative than the AstroDNA and structural laws from which it was derived.

---

# 14. The Synchronic Spine

The Synchronic Spine is the temporal extension of the native Field.

At any time `t`:

```text
MY ASTRODNA
      +
moment AstroDNA(t)
      ↓
synchronic operation
      ↓
synchronic AstroDNA(t)
```

Then:

```text
synchronic AstroDNA(t)
      ↓
Connectome
```

The conceptual Synchronic Spine is continuous.

The materialized Spine is sparse, indexed, or cached as useful.

The canonical spatial frame remains the natal location.

Relocation or travel may later apply horizon-sensitive addenda without replacing the canonical Spine.

Birth anchors this chronology but does not bound it.

Death bounds biography, not synchronic addressability.

---

# 15. The Synchronic Clock

The Synchronic Clock is the continuous playhead through the personalized chronology.

It is not Composite Frames.

It is not merely the return grid.

It is the live personalized counterpart to Orbo's ordinary celestial clock.

```text
Orbo Clock
current celestial time

Synchronic Clock
current celestial time refracted through me
```

Composite Frames are selected analytical samples from that continuum.

The Clock is navigation.

Frames are analysis.

---

# 16. Profiles, Fields, Crystals, and Threads live above the celestial substrate

These user-knowledge objects should not contaminate celestial authority.

```text
PROFILE
identity / organization

FIELD
astrological structure

CRYSTAL
retained meaningful temporal instance

THREAD
relationship among Crystals
```

They reference AstroDNA and AstroDNA-derived structures.

They do not manufacture celestial truth.

A Crystal is a meaningful crystallization retained by the native.

Two Crystals can legitimately point to the same underlying celestial timestamp while representing different experiences.

An email and a Horary question at the same instant remain different Crystals because they mean different things to the native, even if the underlying celestial AstroDNA is identical.

A Profile may exist with incomplete astrological information and may accumulate Fields and Crystals over time.

---

# 17. Lock becomes the capture gesture

The existing Pin concept should eventually be migrated rather than preserved as a parallel ontology.

The full conceptual verb is:

```text
crystallize
```

The short UI action can be:

```text
LOCK
```

The result is:

```text
CRYSTAL
```

A Lock may capture:

```text
now
a selected historical moment
a Synchronic Clock coordinate
an election
a meaningful Intersection
another currently addressed moment
```

There is no separate ontology for mundane "now" and synchronic "now". They are different expressions of one temporal coordinate through different astrological relationships.

---

# 18. Favorites extend the native nervous system

Anything may be favorited.

Favorite does not create a new astrological species.

It tells Orbo:

> **This matters enough to keep computationally warm.**

Possible consequences depend on what was favorited.

```text
favorite natal Field
→ persist Connectome
→ cache useful temporal coverage

favorite Crystal
→ persist its relevant structural expression

favorite relationship
→ preserve parent Fields and useful pair structures

favorite Thread
→ retain linked Crystal organization
```

The exact name of the Connectome region that houses this extended network remains deliberately open.

The architectural distinction is settled:

```text
CONNECTOME

CORE NATIVE EXPRESSION

[NAME TBD]
favored / extended Field network
```

It must be separate enough not to contaminate the immutable native core and connected enough to genuinely function as part of the native's wider nervous system.

Favoriting a subject also establishes durable Profile-level organization for that subject.

---

# 19. Journal becomes lived evidence

The Journal should be built around experience and salience rather than a "for me / against me" verdict.

A Journal observation should support:

```text
intensity

narrative

evidence
  photos
  documents
  messages
  other attachments

links
  Profiles
  Fields
  Crystals
  Threads

experiencedAt

occurredAt

learnedAt
```

This allows realities such as:

```text
Monday
promotion decision happened

Friday
user learned about promotion
```

without falsely forcing the entire event into one timestamp.

Photo recall belongs to the same evidence model.

A photo keeps its exact EXIF moment. Other astrological relationships are links to that moment, not replacements for its identity.

---

# 20. Horary becomes a reader over a locked moment

Horary does not need a separate celestial storage species.

```text
LOCK
  ↓
Crystal
  ↓
AstroDNA
  ↓
Connectome
  ↓
Horary testimony
  ↓
judgment
```

The Horary question is asked once according to the technique's rules.

Other meaningful moments, such as suddenly thinking of someone, can still receive appropriate interpretation suggestions without being falsely declared Horary questions.

A moment's tags and linked Fields may guide what Orbo examines, including ordinary astrological structures such as the first house, seventh house, third house, angles, and exact contacts to linked persons' significant degrees.

---

# 21. Composites and progressions remain distinct operations

A natal composite:

```text
Composite(
  natal AstroDNA A,
  natal AstroDNA B
)
```

produces a fixed derived AstroDNA.

It can receive mundane transits.

It does not inherently possess its own progression clock.

A progressed composite is different:

```text
Composite(
  Progressed(A,t),
  Progressed(B,t)
)
```

It changes because its parents advance.

It too can receive mundane transits.

The architecture should support these operations in one AstroDNA language without pretending every derived Field has identical temporal capabilities.

---

# 22. Synchronic Synastry is a distinct relation

For A and B:

```text
synchronic AstroDNA A(t)
          ↕
synchronic AstroDNA B(t)
```

This is Synchronic Synastry.

It is not the same thing as:

```text
Composite(A,B)
```

or:

```text
transits to Composite(A,B)
```

or:

```text
Progressed Composite(A,B,t)
```

These are different valid astrological operations and may coexist.

**Intersections** remains the larger concept of two synchronic timelines meeting.

The underlying astrological relationships keep their ordinary names such as conjunction, square, trine, applying, exact, and separating.

---

# 23. Electional becomes inverse navigation

Electional should eventually become:

```text
desired action
      ↓
required / forbidden conditions
      ↓
Connectome targets
      ↓
Loom searches time
      ↓
candidate times
      ↓
AstroDNA
      ↓
fine structural judgment
      ↓
candidate Crystal
```

Electional does not manufacture favorable time.

It searches the already-existing astrosphere for coordinates suited to an intended act.

Doctrine determines which structural facts matter and how they are judged. It does not manufacture a separate sky.

---

# III. HOW WE GET THERE

The migration should be dependency-ordered rather than feature-ordered.

The high-level sequence is:

```text
0. MAP THE LIVING TRAFFIC

1. FORMALIZE THE OVUM BOUNDARY

2. FINISH THE ASTRODNA FIDELITY CONTRACT

3. FORMALIZE THE ORBO SPINE

4. MAKE FERTILIZATION REAL

5. RESTORE THE CONNECTOME

6. ESTABLISH THE PERSONALIZED EXTENDED NETWORK

7. MIGRATE RETENTION

8A. JOURNAL AND HORARY
8B. TEMPORAL-CORE RECONCILIATION

9. BUILD THE FULL SYNCHRONIC SPINE AND CLOCK

10. RECONCILE PROGRESSIONS AND COMPOSITES

11. REBUILD ELECTIONAL ON THE ORGANISM

12. RECONCILE THE SURFACES

13. RETIRE THE BRIDGES AND ACTIVATE THE RESONATOR
```

The detailed plan for each phase is intentionally left for the next planning pass.

Every implementation phase should obey the Bay Bridge migration rule: build the replacement beside the living path, prove parity where parity is expected, move consumers one by one, observe, then retire the old path.

---

# Phase 0 - Map the living traffic

Before changing ownership, inventory every relevant seam:

```text
ephemeris callers
AstroDNA producers
live cursor
Orbo Spine / timespine consumers
Ring / Mater / Tympan / Rulers callers
Connectome callers
Loom callers
Pin / Ledger / Favorite storage
progression / composite paths
Horary
electional
browser mirrors
standalone consumers
tests
```

For each target record:

```text
owner
callers
data shape
cache
persistence
browser mirror
tests
standalone usage
```

No rewrite begins from conceptual architecture alone.

---

# Phase 1 - Formalize the Ovum boundary

Establish the one public celestial-state path:

```text
EPHEMERIS
      ↓
OVUM
      ↓
ASTRODNA
```

The Ovum encapsulates ephemeris access.

The Orbo Spine remains behind the same wall.

The rest of Orbo gradually stops consuming naked ephemeris or Orbo Spine state.

**Exit condition:** every complete physical celestial configuration crosses the Ovum boundary as AstroDNA.

---

# Phase 2 - Finish the AstroDNA fidelity contract

Pin down the canonical maximum-fidelity genome and its permitted reductions:

```text
canonical twelve-node order
arcsecond precision
direction encoding
normalization
projection rules
identity rules
cache cuts
browser parity
serialization
```

Preserve the law:

```text
full AstroDNA
→ coarse projection allowed

coarse projection
→ never authoritative over full AstroDNA
```

**Exit condition:** every engine agrees what AstroDNA is and what constitutes identical celestial identity.

---

# Phase 3 - Formalize the Orbo Spine

Separate the universal Orbo Spine from:

```text
live celestial cursor
personal materialized spines
technique-specific indexes
```

Determine exactly which native-independent facts ship and version the artifact explicitly.

Keep it internal to the Ovum boundary.

**Exit condition:** an unengraved Orbo can navigate universal celestial time consistently without creating personal structures or exposing the Orbo Spine as a competing celestial-state API.

---

# Phase 4 - Make fertilization real

Reconcile the existing `fertilize.js` with the new ontology rather than merely renaming it.

Onboarding becomes structurally:

```text
natal input
    ↓
rectification if needed
    ↓
birth AstroDNA
    ↓
engrave as MY ASTRODNA
    ↓
fertilize Ovum
    ↓
Embryo
```

The existing CONTACT and SYNCHRONIC weave machinery should be evaluated as living descendants of this act, not assumed to define fertilization forever.

**Exit condition:** Orbo has an explicit transition from universal celestial instrument to native-specific instrument.

---

# Phase 5 - Restore the Connectome

Preserve the current sign-stay Expression.

Build outward from it.

Establish the relationship between inherent Connectome law and AstroDNA-specific expression, then restore:

```text
one node table per AstroDNA gene
canonical relation edges
motion
condition
governance
Lots
Forged Ring
temporal references
```

**Exit condition:** the Connectome can answer structural questions from AstroDNA without downstream engines independently rebuilding chart logic.

---

# Phase 6 - Establish the personalized extended network

Add the still-to-be-named Connectome region that houses durable relationships to:

```text
Favorite Profiles
Favorite Fields
Favorite Crystals
Favorite Threads
cached Expressions
personal temporal coverage
pair structures
```

Keep native core and extended network structurally distinct.

**Exit condition:** favorite objects become computational extensions of the native without contaminating my AstroDNA or its core Connectome expression.

---

# Phase 7 - Migrate retention

Build the reconciled user-knowledge grammar:

```text
Profile
Field
Crystal
Thread
Lock
Favorite policy
```

Migrate existing:

```text
Pin
Ledger people
Ledger events
Horary records
composites
Favorites
```

without data loss.

A Crystal references celestial truth through AstroDNA while remaining a significance-bearing user object.

**Exit condition:** Orbo has one coherent system for retaining meaningful moments and subjects.

---

# Phase 8A - Journal and Horary

These can proceed once Crystals and Connectome exist.

Journal becomes:

```text
intensity
narrative
evidence
links
experiencedAt
occurredAt
learnedAt
```

Horary becomes:

```text
Crystal
→ question resolver
→ testimony
→ judgment
→ interpretation
```

No duplicate sky.

---

# Phase 8B - Temporal-core reconciliation

In parallel, reconcile:

```text
live cursor
timespine.js
Loom
contact chronology
progression chronology
ZR indexing
mundane chronology
```

Clarify the distinct jobs:

```text
CURSOR
where we are

LOOM
find when something happens

SPINE / INDEX
retain useful temporal structure
```

**Exit condition:** temporal engines no longer overlap merely because they were built in different historical phases.

---

# Phase 9 - Build the full Synchronic Spine and Clock

Once the temporal substrate and Connectome are stable:

```text
MY ASTRODNA
+
moment AstroDNA(t)
↓
synchronic AstroDNA(t)
↓
Connectome
↓
Synchronic Spine
```

Then establish:

```text
Synchronic Clock
Composite Frames
pair synchronic timelines
Synchronic Synastry
Intersections
```

Use natal location as the canonical horizon.

Relocation and travel become horizon-sensitive addenda rather than replacement chronologies.

---

# Phase 10 - Reconcile progressions and composites

Formalize the operation family:

```text
natal composite
progressed state
progressed composite
transits to natal composite
transits to progressed composite
synchronic state
```

Ensure they all use AstroDNA as the common encoding without collapsing their different temporal behaviors.

---

# Phase 11 - Rebuild Electional on the organism

Only after its dependencies are stable should Electional be substantially reworked.

It should become a consumer of:

```text
Ovum / Embryo AstroDNA
Connectome
Lots
Loom
personal spines
relationship structures
applying / separating
doctrine
```

rather than maintaining parallel celestial or structural calculations.

---

# Phase 12 - Reconcile the surfaces

Once the contracts are stable, reconcile the user-facing surfaces around the final organism:

```text
Astrolabe
Ledger
Almanac
Journal
Profiles
Lock rune
Favorites
Pisces Tabula
Horary
Electional
Lunar Port
```

Major interaction and presentation work should land against stable object contracts rather than fossilizing temporary data structures.

---

# Phase 13 - Retire the bridges and activate the Resonator

After consumers have crossed the Bay Bridge, remove obsolete pathways such as:

```text
direct ephemeris consumers
direct Orbo Spine state consumers
duplicate chart compilers
obsolete Pin storage
old temporal ownership
dead caches
parallel derived-state paths
```

Then permanently regulate critical seams, including:

```text
Ephemeris ↔ Ovum
Ovum ↔ AstroDNA
AstroDNA ↔ Connectome
Ring ↔ Forged Ring
live derivation ↔ cached spine
source ↔ browser mirror ↔ standalone
```

The Resonator verifies fidelity. It never becomes a second source of truth.

---

# IV. MASTER PICTURE

```text
                           ASTROSPHERE
                                │
                                ▼
                            EPHEMERIS
                      astronomical mechanics
                                │
                                ▼
┌────────────────────────── ORBO OVUM ──────────────────────────┐
│                                                              │
│  ORBO SPINE                                                  │
│  universal celestial chronology                              │
│                                                              │
│  INHERENT CONNECTOME LAW                                     │
│  Ring · Mater · Tympan · Rulers                              │
│                                                              │
│  AstroDNA encoder                                            │
│  Loom                                                        │
│  Resonator                                                   │
│                                                              │
└──────────────────────────────┬───────────────────────────────┘
                               │
                            AstroDNA
                               │
                     natal AstroDNA selected
                               │
                            ENGRAVING
                               │
                          FERTILIZATION
                               │
                               ▼
┌────────────────────────── EMBRYO ─────────────────────────────┐
│                                                              │
│  MY ASTRODNA                                                 │
│  immutable native root                                       │
│                                                              │
│  EXPRESSED CONNECTOME                                        │
│  native nervous system                                       │
│                                                              │
│  FORGED RING                                                 │
│                                                              │
│  [EXTENDED NETWORK NAME TBD]                                 │
│  Favorites · Profiles · linked Fields · caches               │
│                                                              │
└──────────────────────────────┬───────────────────────────────┘
                               │
                     AstroDNA relationships
                               │
             ┌─────────────────┼──────────────────┐
             ▼                 ▼                  ▼
         Contact          Synchronic         Progression
          Spine             Spine             structures
                               │
                               ▼
                         Synchronic Clock
                               │
                     ┌─────────┼──────────┐
                     ▼         ▼          ▼
                  Journal    Horary    Electional
                     │         │          │
                     └─────────┼──────────┘
                               ▼
                           Lunar Port
                               │
                               ▼
                              USER
```

The diagram is conceptual, not a promise that every box is a single module or that every reader has only one dependency. Its purpose is to preserve authority and direction of circulation.

---

# V. GOVERNING SENTENCES

The following sentences should be used as reconciliation tests throughout the detailed phase planning:

> **Orbo ships knowing the astrosphere.**

> **Everything Orbo understands as a complete celestial configuration is encoded as AstroDNA.**

> **The Ovum encapsulates the machinery that turns the astrosphere into AstroDNA.**

> **The ephemeris supplies mechanics; it does not become a parallel application-facing celestial authority.**

> **The Orbo Spine is the universal temporal substrate inside the Ovum, not a competing state authority.**

> **Onboarding determines my exact coordinate in the astrosphere.**

> **Engraving makes that exact AstroDNA "my AstroDNA."**

> **My AstroDNA fertilizes the Ovum, producing the personalized Embryo.**

> **Rectification is part of the fertilization apparatus when the natal coordinate is uncertain.**

> **The Connectome is AstroDNA unfolded.**

> **Ring, Mater, Tympan, and Rulers are inherent Connectome law shipped inside the Ovum; the expressed Connectome is specific to an AstroDNA.**

> **The Connectome knows the target. The Loom finds the crossing.**

> **Maximum fidelity enters the system once; downstream systems are free to use coarser cuts when their truth permits it.**

> **A materialized spine is an index or cache of authoritative celestial relationships, not a new celestial authority.**

> **Profiles, Fields, Crystals, Threads, Favorites, and Journal evidence organize what matters to the native without becoming parallel astronomical engines.**

> **The instrument exists before the native. Fertilization makes it mine.**

---

# VI. NEXT STEP

The next planning pass should expand each numbered phase into an implementation plan containing, at minimum:

```text
purpose
architectural law being established
living code affected
new contracts required
old contracts retained during migration
Bay Bridge sequence
Resonator / parity tests
persistence and cache implications
browser mirror implications
standalone implications
explicit non-goals
exit criteria
```

The detailed phases must be derived from this architecture and the living engine inventory rather than from feature priority alone.
