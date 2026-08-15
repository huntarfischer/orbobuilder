# Orbo System Map and Connectome Restoration

Status: working architecture map and restoration note.

Purpose: record the current living Orbo system as understood from the v0.9 codebase, separate what already exists from architectural ideas that have been identified but are not yet fully implemented, and preserve the intended meaning of the Connectome before another implementation pass narrows it by accident.

This document does not supersede `CLAUDE.md`, the Phase specifications, or the engine source. It is a cross-system map of how the current organism fits together.

---

## 0. The shortest description of Orbo

Orbo is a celestial-time instrument.

The sky is the source of truth. AstroDNA gives a celestial state a stable identity. The instrument lets the user manipulate celestial time directly. Structural engines derive relationships from that state without interpreting them. Technique engines ask specific astrological questions. The Lunar Port controls how those answers become reflection. Interpretation packs supply authored meaning without becoming a second source of astronomy.

The system is organized around the direction of light:

```text
SKY
  |
  v
CELESTIAL STATE
  |
  v
STRUCTURE / RELATION / TIME
  |
  v
READING
  |
  v
LUNAR PORT
  |
  v
REFLECTION
  |
  v
USER
```

The return path from the user is equally constrained:

```text
read / pin         -> memory
log experience     -> archive / journal
seat / mint        -> maker side
scrub a body       -> celestial time
choose a socket    -> request a reading
choose a voice     -> change interpretation, not celestial truth
```

---

## 1. Foundational laws already visible in the living system

### 1.1 The astrolabe is the Sun

The front is the light itself: geometry, celestial positions, motion, houses, relationships, and the physical truth of the selected moment.

New interpretive features do not belong on the face merely because they are useful.

The user may play with the light. The user may not make the Sun explain itself.

### 1.2 The lunar pane is the Moon

The Moon reflects the light.

A transit ledger, natal interpretation, synchronic reading, election window, Zodiacal Releasing period, or explanatory article is a way of looking at celestial truth. It therefore belongs to the reflective side.

Plain, Studied, and Scholarly are properties of the reflection, not alternate versions of astronomy.

### 1.3 The back is the maker's side

The back configures the instrument.

Its governing verbs are the maker's verbs:

```text
engrave
seat
mint
configure
```

A generative act belongs here because it changes what the instrument is holding, not what the Moon says about it.

### 1.4 Natural law is a design specification

Orbo should prefer the behavior of the physical system over conventional application controls.

Examples already present:

- the planets are the hands of the clock
- each body scrubs time at a rate derived from its actual celestial period
- the astrolabe flips to expose its maker side
- the Moon rises and can eclipse the instrument
- the synchronic field is produced by refraction through a fixed natal field
- celestial ranges should be solved before converting them to civil clock time

### 1.5 One source, one door

Several mature parts of Orbo have become explicit single-door systems.

```text
raw sky -> live TimeSpine door
refraction -> framing.refract
lunar presentation -> Lunar Port
```

A second path that produces the same answer is considered a defect because the two paths can eventually disagree.

---

## 2. Celestial time and the Big Three

Orbo is oriented around celestial time rather than civil time.

The Big Three are Ascendant, Moon, Sun. They sit above the ordinary date and clock because they are a human-readable celestial timestamp at three natural rates:

```text
Ascendant  local rotational time
Moon       fast celestial time
Sun        annual solar time
```

AstroDNA is the deeper computational address of the same idea.

The ordinary timestamp answers:

```text
When did humans label this moment?
```

The celestial state answers:

```text
Where was the sky?
```

The user can move through that time by grabbing the bodies themselves. Mercury, Venus, Mars, Jupiter, Saturn, and the other movable hands therefore function as natural gear ratios rather than decorative alternatives to a scrub bar.

---

## 3. The major data families

One important result of tracing the current engines is that Orbo should not force all astrological data into one universal record.

Different phenomena are genuinely different kinds of information.

### 3.1 State

A crystallized celestial configuration at an instant.

Examples:

```text
natal state
current sky state
event state
election state
mundane state
```

A state answers:

```text
What is true at this instant?
```

### 3.2 Derived State

A complete field derived from one or more states rather than literally occupying the sky in that arrangement.

Examples:

```text
synchronic state
composite state
progressed state
```

A derived state can itself be structurally expressed and read.

### 3.3 Relation

A relationship inside or between states.

Examples:

```text
aspect
reception
dispositor path
synchronic pair relation
house governance
```

### 3.4 Event

A change, crossing, perfection, or exact relationship associated with a time.

Examples:

```text
ingress
station
exact transit hit
synchronic boundary crossing
return
```

An event is not the whole celestial state at its timestamp. The state can be reconstructed at the event's hinge.

### 3.5 Span

An interval during which a selected condition remains true.

Examples:

```text
planet in sign
rising lord unchanged
ZR period
synchronic placement in one permitted stretch
planet within an aspect orb
```

Spans are especially important to electional work.

### 3.6 Assessment

A judgment made from structural facts under a doctrine.

The current electional result is the clearest example.

```text
facts
  +
doctrine / priorities
  ->
assessment
```

### 3.7 Ticket

The reader's contract with the Lunar Port.

The current ticket contains:

```text
template
subject
rows
doctrine
chips
empty
```

The ticket declares what kind of thing has been found. It does not control markup, height, caption, or rails.

### 3.8 Interpretation

Authored meaning supplied after structural truth exists.

A change of interpretive voice must not silently change the celestial address being interpreted.

---

## 4. The current circulation

The living system can be understood as this circulation:

```text
                           SKY
                            |
                            v
                    live TimeSpine
                   one cursor / sky door
                            |
                            v
                         AstroDNA
                            |
             +--------------+--------------+
             |              |              |
             v              v              v
            Ring        Mater/Tympan      Rulers
          geometry      signs/houses      degree law
             |              |              |
             +--------------+--------------+
                            |
                            v
                 Dispositor / Connectome
                     structural expression
                            |
             +--------------+--------------+
             |              |              |
             v              v              v
          temporal       technique        field
           engines        engines        engines
             |              |              |
             +--------------+--------------+
                            |
                            v
                          reader
                            |
                            v
                          ticket
                            |
                            v
                       Lunar Port
                            |
                            v
                  plate / arrangement / bands
                            |
                            v
                    interpretation voice
                            |
                            v
                           Moon
                            |
                            v
                           USER
```

The reverse path does not run backward through the same pipe. The user's act determines the legitimate return route.

---

## 5. Engine strata in the current code

### 5.1 Inherent / stamped law

These are true before a native exists.

```text
ring.js       degree geometry and marks
mater.js      signs, elements, modalities, rulership, exaltation
Tympan        twelve whole-sign frames and house governance
rulers.js     degree-level dignity facts
```

These are closer to engraved parts of an instrument than ordinary runtime calculations.

### 5.2 Celestial identity and astronomy

```text
ephem.js      generates the numerical sky
astrodna.js   gives a chart or moment canonical celestial identity
```

AstroDNA currently carries a fine arcsecond genome plus richer decoded expression such as sign, house, speed, motion, aspects, extras, and Lots.

The genome is identity. Coarser projections are allowed for artifacts whose truth does not change at finer resolution.

### 5.3 Regulatory structure

```text
dispositor.js
connectome.js
```

The present `connectome.js` compiles a sign-resolution `Expression` from an occupant-to-sign map, a whole-sign frame, and sect.

It currently provides structures such as:

```text
planet table
house table
dispositor chains
keepers
cycles
receptions
house routing
agency
light
charged state
lookup indexes
```

This implementation is valuable and should survive.

It is not, however, the full intended meaning of the Connectome. See Section 7.

### 5.4 Root and event machinery

```text
loom.js
transits.js
luna.js
mundane.js
fertilize.js
timespine.js
```

These engines discover or materialize temporal phenomena at different scales.

The current code already follows a useful law:

```text
expensive + stable over a long horizon -> materialize
cheap or extremely dense               -> derive locally
```

This is why the century TimeSpine stores sparse events but refuses Moon floods and frequent cASC handoffs.

### 5.5 Technique engines

```text
zr.js
progressions.js
progressed-aspects.js
electional.js
framing.js
prism.js
```

These engines apply particular astrological procedures to structural or temporal truth.

`progressed-aspects.js` is already an important precedent: Alan Leo affects what computational events are admitted, while interpretive prose remains a separate concern.

### 5.6 Support / import / location

```text
aaf.js
cities.js
rect-data.js
```

These support chart entry, import, location, or human evidence rather than forming a separate astrology doctrine.

---

## 6. Two different TimeSpines currently exist

The name currently refers to two distinct things.

### 6.1 The live spine inside the instrument

The live spine owns the celestial cursor.

It is the one door to the sky and supplies calls such as:

```text
at
posAt
probe
bodyProbe
ascProbe
progressedAt
armcAt
axialAt
connAt
```

Planet scrubbing changes this cursor. The drawing then reads the new sky.

The user therefore manipulates time rather than dragging graphics.

### 6.2 `timespine.js`

The module `timespine.js` is a materialized century-scale event index.

It currently stores expensive sparse phenomena such as:

```text
transit hits
synchronic-composite hits
ingresses
stations
```

and derives cheap views such as returns and flips from those stored rows.

It deliberately refuses dense Moon events and frequent cASC handoffs.

These two objects should not be conceptually conflated even though the current vocabulary uses the same word.

---

# 7. CONNECTOME RESTORATION

## 7.1 The intended meaning

The Connectome is named after a comprehensive map of neural connections in a brain.

It should function accordingly.

The Connectome should not be understood merely as:

```text
the dispositorship engine
```

or:

```text
the current sign-stay Expression object
```

Those are important parts of it.

The intended Connectome is the comprehensive retrievable map of how an AstroDNA state expresses and connects across every useful resolution required by Orbo.

Its job is to make the relationships already implicit in celestial state available without every downstream engine independently re-deriving them.

## 7.2 Preserve the current Expression

The existing sign-stay `Expression` is a good cache because its truth changes only when the sign vector or sect changes.

It should remain keyed at the resolution to which its contents are sensitive.

Do not solve restoration by putting exact longitudes into the sign-stay object and invalidating it every sample.

The restoration is not a monolith.

It is a network of expression layers.

## 7.3 Multi-resolution expression map

Conceptually:

```text
                          ASTRODNA
                     immutable identity
                            |
                            v
                       CONNECTOME
                            |
       +--------------------+--------------------+
       |                    |                    |
       v                    v                    v
 exact expression      pointwise expression   sign-stay expression
 longitude             degree                 sign
 DMS                   bound                  house
 motion                face                   bearer
 speed                  exact dignity         path
 retrograde             exact Ring reads      keeper
 station                                       receptions
                                               house routing
       |                    |                    |
       +--------------------+--------------------+
                            |
                            v
                  relational expression
                 aspects / applying state
                 lots / qualified houses
                 cross-chart relationships
                            |
                            v
                    temporal indexes
```

The exact membership of each layer is a later design task. The important rule is that every expression is cached or derived at the resolution where its truth changes.

## 7.4 Cache keys are deliberate cuts of the genome

AstroDNA identity stays fine.

Caches are allowed to be coarser when the cached truth is coarser.

Examples:

```text
arcsecond genome
    identity of the celestial state

whole-degree projection
    useful for artifacts whose result does not change within the degree

sign vector + sect
    valid for regulatory wiring that does not change inside a sign-stay

relation-specific key
    valid for a stable cross-chart or field relationship
```

A cache key is not an alternate truth. It is a named cut of the truth at the resolution required by that artifact.

## 7.5 The Connectome as retrieval, not duplication

The Connectome does not need to physically copy every value into one object.

It can function as the nervous system that knows where a relationship lives and can expose it through one coherent interface.

A downstream engine should be able to ask questions conceptually like:

```text
Where is Venus?
What sign is Venus in?
Who disposes Venus?
Where is that disposer?
What is the keeper?
What houses does Venus govern?
What exact dignity applies here?
What aspects are active?
Is the aspect applying?
What changes next?
```

without each consumer becoming a miniature chart compiler.

## 7.6 The Connectome is beneath both faces

The Connectome is not Sun-side or Moon-side.

It is beneath the instrument in the same sense as the Ring.

The Sun can display facts read from it. The Moon can reflect readings built from it. Neither owns it.

---

## 8. SynchronicSpine

The SynchronicSpine is a fundamental Field Theory object.

It is derived from:

```text
engraved natal state
        +
celestial time
        |
        v
framing.refract
        |
        v
synchronic state through time
```

### 8.1 What already exists

`framing.js` owns the one refraction door.

`prism.js` already records permanent synchronic structure such as:

```text
permitted 180-degree arcs
reachable signs
reachable houses
reachable lords
segment boundaries
sASC itinerary
ascension durations
same-body pair families
```

`Phase 7 - Synchronic Time.md` already recognizes that Clock, Chronicle, and synchronic synastry were built as separate features even though they are different readings of one temporal object.

### 8.2 What is missing

The actual cached refracted chronology is not yet fully built into v0.9.

The intended solo SynchronicSpine should preserve refracted states rather than repeatedly computing them and discarding them.

### 8.3 Trigger law

The SynchronicSpine must NOT be minted merely because a natal chart is engraved.

It is lazy.

The first Pisces function that requires it should trigger or resume construction, analogous to Zodiacal Releasing's first-use behavior.

```text
natal chart engraved
        |
        X  no SynchronicSpine yet

user first enables Pisces chronology / clock / field function
        |
        v
SynchronicSpine begins lazy incremental build
        |
        v
cached for future Pisces readers
```

### 8.4 The range is primary

AI implementations have repeatedly over-focused on the synchronic flip.

The more fundamental object is the finite permitted range.

For a fixed natal longitude, the synchronic placement is a deterministic function of the matching sky longitude and is confined to a 180-degree range.

Example:

```text
natal Ascendant = 11 Scorpio
horizon          = 11 Capricorn
synchronic ASC   = 11 Sagittarius
```

Every time those two inputs recur, the result is the same.

The important stored / queryable truths are therefore:

```text
what degrees can it occupy?
what signs can it occupy?
what houses can it occupy?
what lords can govern it?
what relations can it form?
```

The flip is one seam in that finite system.

### 8.5 Pisces Tabula

The Pisces Tabula should be understood as a family of readers over the synchronic field rather than a collection of unrelated calculations.

Conceptually:

```text
SynchronicSpine
      |
      +-> Moment
      +-> Chronicle
      +-> Clock
      +-> Crossing
      +-> Synastry
      +-> Query / Arrival
```

The same refracted temporal backbone can support different scales and arrangements without recomputing the field from scratch.

---

## 9. Spines as a general Orbo pattern

A spine is best understood as a temporal index of truths available through the Connectome for a particular kind of question.

Not every Tabula necessarily needs its own spine.

But several existing systems already behave like spines:

```text
TimeSpine             sparse celestial changes through life
SynchronicSpine       refracted celestial chronology
ZR table              zodiacal period chronology
Progression table     progressed chronology
Progressed hits       progressed aspect chronology
```

Future spines should be justified by a distinct temporal resolution or doctrine, not by UI ownership.

A Tabula requests a pathway through the nervous system. It does not necessarily own the pathway.

---

## 10. ElectionalSpine

The current `electional.js` combines several kinds of work:

```text
celestial facts
astrological definitions
condition scoring
priority weights
vetoes
activity-specific judgment
```

This is a census fact, not an instruction to rewrite the engine immediately.

### 10.1 The new direction

An ElectionalSpine should not primarily be a grid of sampled clock times.

It should be a doctrine-sensitive segmentation of celestial time.

The question becomes:

```text
When do the facts relevant to this doctrine change?
```

Possible boundaries include:

```text
rising-sign handoff
rising-lord handoff
planet sign ingress
dispositor change
keeper change
house change
bound change
face change
station
combustion threshold
aspect-orb entry / exit
exact perfection
Moon condition change
void-of-course boundary
next application change
```

### 10.2 Why the Connectome matters

If Venus is in Aries, the sign range itself tells Orbo that its traditional bearer is Mars.

If Venus enters Taurus, its bearer becomes Venus.

The Connectome should already expose the chain:

```text
Venus
  -> sign
  -> bearer
  -> bearer's sign
  -> next bearer
  -> keeper
```

An electional doctrine should not have to rebuild that network.

It should declare which pathways matter.

### 10.3 Celestial-time first

The preferred electional direction is:

```text
doctrine
   |
   v
required / forbidden celestial conditions
   |
   v
solve their celestial ranges
   |
   v
intersect ranges
   |
   v
convert surviving ranges to civil time
```

See `specs/Celestial to Civil Time Conversion.md`.

This allows questions such as:

```text
What is the better time to send correspondence each working day for the next year?
```

without repeatedly scoring every five minutes of the year.

---

## 11. Transits need a contract pass

The current word `transit` covers several different things.

These should be kept conceptually distinct before a future rewrite:

```text
Transit State
    where the moving sky is

Transit Relation
    how that sky relates to a seated state

Transit Event
    when a relation perfects or changes

Transit Span
    the interval during which a transit condition remains true
```

The current `transits.js` primarily scans exact hits. `timespine.js` materializes selected sparse transit events. The live sky itself is supplied through the live spine.

A `TransitHit` should not be mistaken for a complete AstroState merely because both are currently discussed under the word transit.

---

## 12. The Lunar Port and the kitchen

The Lunar Port is the egress boundary between computation and reflection.

The French-kitchen model is currently:

```text
walk-in
    celestial state / TimeSpine

measuring + prep
    Ring / framing / rulers / Connectome

line
    readers / techniques

pass
    Lunar Port

server
    rail / dock / arc

table
    lunar pane
```

The reader should not hand the pane finished markup.

It hands a ticket.

The Port:

```text
validates
names the dish from subject
sets rest / plate behavior
renders provenance
applies interpretation voice
lays shared bands
refuses malformed tickets
```

This is why a growing number of engines can share one Moon without each technique becoming its own miniature application.

---

## 13. Plates, arrangements, and bands

The current presentation grammar separates three axes.

### Plate

What kind of information is this?

Current vocabulary includes:

```text
FACT
RELATION
LEDGER
SPAN
PROSE
```

`TRACK` appears in Phase 9 planning and should be reconciled against the current implementation during the later specs pass.

### Arrangement

How is the plate laid out?

Current families include:

```text
flat
railed
stepped
```

### Bands

Shared supporting presentation such as:

```text
caption
chips
stepper
rail
provenance
```

The rule remains:

```text
A band with nothing to show emits nothing.
```

This separation is one of the strongest current examples of Orbo finding independent axes instead of mixing categories.

---

## 14. Tabulas, sockets, and maker-side command grammar

The back is not simply a menu.

The interaction grammar is:

```text
TABULA
    domain
      |
      v
SOCKET
    operation / lens / course
      |
      v
FIELD
    arguments / targets / options
      |
      v
VERB
    open / etch / fuse / seat / mint / log
```

The user is not configuring the Lunar Pane directly.

The user is configuring the question or the instrument.

The Moon remains responsible for how a valid reading is reflected.

Sockets can therefore route to different kinds of acts:

```text
show this     -> Moon
remember this -> Archive
seat this     -> instrument
mint this     -> new relationship / field
```

The socket system is the maker-side command grammar of Orbo.

---

## 15. Almanac

The Almanac is a calendar aggregator, not a technique engine.

It can receive timing streams from multiple sources:

```text
mundane sky
transits
Zodiacal Releasing
progressions
progressed aspects
crossings
rising lord
synchronic field
eclipses
saved events / beads
```

A timing may be read by itself on the Moon or fused into the Almanac.

The underlying timing should exist once.

The user chooses where to look at it.

This is another Sun/Moon-consistent distinction:

```text
same temporal truth
    -> standalone reflection
    -> calendar-context reflection
```

---

## 16. Interpretation packs and astrologer doctrine

The existing generic interpretation resolver is already multi-pack shaped.

Dark Pixie currently demonstrates a key-addressed placement and explanation corpus with pack-owned attribution.

Alan Leo currently demonstrates something additional: an astrologer's work can affect engine behavior as well as prose.

`progressed-aspects.js` is already a precedent for this distinction.

Future astrologer support therefore likely has at least two contracts:

```text
OPERATIONAL DOCTRINE
what to admit / inspect / prioritize / veto / derive

INTERPRETIVE VOICE
what the astrologer says about a valid address or result
```

These must not be collapsed.

For electional work this is especially important because astrologers may agree on celestial facts while disagreeing on which facts deserve priority.

The long-term goal should allow a third-party astrologer to publish work against a stable Orbo contract so that their doctrine and/or interpretation can populate the appropriate parts of the system without bespoke UI or bespoke astronomy.

---

## 17. The word `doctrine` currently spans several contracts

The living code uses `doctrine` to mean more than one thing.

Examples include:

```text
calculation policy
    progressed-angle method

cache identity
    doctrine version affecting an Expression

reading provenance
    recipe keys carried by a ticket

source metadata
    an author's rulership assumptions

judgment policy
    electional priorities / definitions
```

These are related but not interchangeable.

A future contract pass should distinguish them without erasing the useful common idea that Orbo must know which rules produced a result.

---

## 18. Current architecture versus restoration

The following distinction should remain visible in future planning.

### Already substantially built

```text
fine AstroDNA identity
Ring / Mater / Tympan
rulers facts
Dispositor
sign-stay Connectome Expression
live TimeSpine sky door
materialized century TimeSpine
Loom
Mundane
Luna
Fertilization
Transits exact-hit scanner
Zodiacal Releasing
Progressions
Alan-Leo-derived progressed aspects
Electional scoring
Framing / refraction
Prism permanent synchronic structure
Lunar Port
plate / arrangement / band grammar
Tabula / socket interface
Almanac aggregation
Dark Pixie interpretation resolver
```

### Identified restoration / completion work

```text
Connectome restored to comprehensive multi-resolution nervous-system meaning

SynchronicSpine completed as a lazy-built cached refracted chronology

State / Derived State / Relation / Event / Span taxonomy formalized

Transit contracts separated into state / relation / event / span

ElectionalSpine designed as celestial-range segmentation rather than arbitrary time sampling

astrologer doctrine contract separated from interpretive voice contract

current `doctrine` meanings reconciled

current reader subjects / addresses traced against future pack contracts
```

These are not equivalent in status. The second group must not be described as already implemented simply because pieces of it appear in planning documents.

---

## 19. The central system map

The whole organism can now be summarized as:

```text
                              SKY
                               |
                               v
                         LIVE TIMESPINE
                    celestial cursor / sky door
                               |
                               v
                            ASTRODNA
                   immutable celestial identity
                               |
                               v
                           CONNECTOME
                comprehensive connection / expression map
                               |
          +--------------------+--------------------+
          |                    |                    |
          v                    v                    v
      structural           temporal             relational
      expression           indexes              expression
          |                    |                    |
          |          +---------+---------+          |
          |          |                   |          |
          |          v                   v          |
          |      TimeSpine         SynchronicSpine  |
          |                              |          |
          +---------------+--------------+----------+
                          |
                          v
                    TECHNIQUE / READER
                          |
                          v
                        TICKET
                          |
                          v
                     LUNAR PORT
                          |
                    interpretation
                          |
                          v
                         MOON
                          |
                          v
                         USER
                          |
            +-------------+--------------+
            |             |              |
            v             v              v
          memory       maker side    celestial scrub
          Archive      Tabula/socket   body as hand
```

---

## 20. Planning priorities when the specs pass begins

The first major planning task should be **Connectome Restoration**, because the answer determines how every later engine is allowed to obtain derived state.

The next foundational task should be **SynchronicSpine completion**, because Field Theory currently has permanent Prism structure and live refraction but lacks the completed cached temporal backbone Phase 7 already identified.

Only after those two should the architecture decide how broadly to generalize the spine pattern, including the ElectionalSpine.

Then the system can revisit Transits, State/Event/Span taxonomy, astrologer doctrine contracts, and pack standardization against a stable nervous system rather than designing each of them around today's local implementation seams.

---

## 21. Working principle

The most useful question for future Orbo work is not:

```text
How do we add this feature?
```

It is:

```text
What kind of truth is this?
Who owns it?
At what resolution does it change?
Where is it cached or derived?
Which existing pathway should carry it?
How may the user request it?
How is it allowed to become reflection?
```

If those questions have clean answers, the implementation should become smaller rather than larger.

That is the architecture Orbo is already growing toward.
