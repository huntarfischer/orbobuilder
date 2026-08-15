# Crystallized Moments: Moment Lock, Favorites, and Field Taxonomy

**Status:** design/recovery document. Preserve this direction while specs archaeology continues. This is not yet an executable contract and does not assert that the living app implements every object below.

**Evidence base:** the August 15, 2026 Astro-Seek databank export supplied by Ean, containing 544 saved charts, read alongside the existing Field Journal, Horary, Connectome, Ledger, and Phase 7 Synchronic Time plans.

---

## 0. The recovered idea

Orbo needs to make it easier to preserve significance **before the native understands it**.

The practical behavior already exists outside Orbo: when a strong thought, feeling, question, message, event, or coincidence happens, Ean screenshots the lock screen so the exact time survives and can be cast later.

Orbo should absorb that gesture.

> **Capture first. Meaning can arrive later.**

The basic live-capture act is the **Moment Lock**.

A Moment Lock preserves the present celestial address immediately. It must not wait for a question form, interpretation, animation, or classification step before fixing the timestamp.

```text
NOW
 |
 v
MOMENT LOCK
 |
 v
Embryo.fertilize(time, place)
 |
 v
physical AstroDNA
```

The capture may be enriched afterward or left unexplained indefinitely.

---

## 1. Horary is a reader of the locked moment, not the storage species

Alan Leo's 1929 Horary doctrine permits a figure for a moment when the mind is deeply anxious, when a question is asked, when a letter is read, or when an event is first heard of. The reviewed Orbo Horary work already generalized this into a Moment Lock with an explicitly Orbo-authored `intuition_signal` extension.

The user-facing instrument should therefore have a fast **HORARY** act, but the storage beneath it should remain more general:

```text
HORARY button
    |
    v
Moment Lock
    |
    +--> open-field horary reading now
    |
    +--> question judgment later
    |
    +--> journal annotation later
    |
    +--> link to a person / field later
```

A question is not required at capture.

The same immutable moment can mature from an inarticulate signal into a clear question without changing the original time or AstroDNA.

Potential post-capture triggers, deliberately after the lock:

```text
I FELT SOMETHING
I ASKED SOMETHING
I HEARD / SAW SOMETHING
SOMETHING HAPPENED
LATER
```

These should map to structured trigger metadata without requiring the user to speak in horary terminology.

---

## 2. The Astro-Seek corpus shows that `person | event` is too crude

The supplied databank contains **544 saved charts**:

- 267 marked `m`
- 97 marked `f`
- 180 marked `e`

The flags appear to be Astro-Seek's male / female / event distinction. But the actual use defeats that taxonomy. Several plainly moment-like records are stored under `m`, including names such as:

- `bad day`
- `howlong`
- `mygoal`
- `missed`
- exact-aspect moments
- solar returns

This is not a data-cleanliness problem. It is evidence that the container did not match the behavior.

The chart names reveal a much richer practice. Saved objects include:

- people, family, ancestors, historical people, celebrities
- organizations, companies, teams, nations, venues
- personal communications and replies
- strong feelings and uncertain questions
- appointments and bodily events
- creative work, launches, recordings, readings, shows, submissions
- rituals and ceremonies
- archive and research discoveries
- historical events and reconstructed moments
- fictional and diegetic events
- lunations, eclipses, exact aspects, returns, nodal events
- future elections and deliberately chosen future dates
- repeated relationship contacts

Orbo should model this richness directly rather than reproducing Astro-Seek's coarse flag.

---

# PART I. THE CORE OBJECTS

## 3. Field

A **Field** is a persistent subject whose celestial identity is worth returning to.

A field may begin from a crystallized origin moment, but it persists beyond that moment.

Examples supported by the corpus:

```text
PERSON
family member
ancestor
historical person
public figure

RELATIONSHIP
person x person
other derived pair field

COLLECTIVE
nation
company
sports team
institution

PROJECT / WORK
book
film
show
recording
creative project

PLACE / VENUE
property
building
venue

FICTIONAL / DIEGETIC SUBJECT
character
story-world entity
```

A natal person is therefore one kind of Field, not the definition of Field.

A company founding, team debut, project launch, or other origin event can likewise anchor a Field.

---

## 4. Crystallized Moment

A **Crystallized Moment** is any deliberately retained temporal address.

It is broader than a live Moment Lock.

```text
CRYSTALLIZED MOMENT
  physical AstroDNA where applicable
  time
  place / horizon where applicable
  provenance
  source confidence
  trigger metadata
  subject links
  annotations
```

A Crystallized Moment can be:

- captured live
- entered retrospectively
- reconstructed historically
- chosen in the future
- generated from a celestial hinge
- imported from another system
- associated with a fictional / diegetic event

This separates **what the heavens were doing** from **why the time matters**.

The physical celestial state remains AstroDNA. Meaning, provenance, and use live in metadata and downstream readers.

---

## 5. Moment Lock

A **Moment Lock** is the live-capture route into a Crystallized Moment.

```text
Moment Lock = Crystallized Moment minted from NOW
```

The timestamp is taken immediately.

Everything after capture is optional enrichment.

The lock should survive an immediate app close.

---

## 6. Favorite

A **Favorite** is not merely a star or sorting preference.

> **Favoriting tells Orbo that this Field matters enough to remember computationally through time.**

This is already partly anticipated in living architecture:

- favorited charts' Connectome Expressions are persisted
- the Phase 7 Synchronic Time plan specifies a pair spine minted on favorite

The restored meaning should be stronger:

```text
favorite(field)
    |
    +--> persist / warm Connectome expression
    |
    +--> establish temporal coverage
    |
    +--> lazily grow relevant partial spine(s)
    |
    +--> make relational timeline queries cheap
```

Favorites should apply to Fields generally, not only people.

A favorite may therefore be a person, relationship, project, company, team, place, or other persistent Field that Orbo can legitimately compare through time.

---

## 7. Journal evidence

A Journal record answers a different question from a Moment Lock.

```text
LOCK
"I need this instant."

FAVORITE
"I care about this field through time."

JOURNAL
"This is what happened."
```

The abandoned Field Journal plan was right to treat lived outcomes as calibration data rather than mere diary prose.

A locked moment may acquire journal evidence later:

- what happened
- how it felt
- outcome
- tags
- notes
- attachments
- predicted vs. experienced comparison where appropriate

The same Crystallized Moment should not be copied into separate Horary, Event, and Journal objects merely because three readers use it.

---

# PART II. TAXONOMY OF CRYSTALLIZED MOMENTS

## 8. Do not force one flat `eventType`

The corpus argues for a **multi-axis taxonomy**.

`CB Support Reply` is simultaneously:

- a received communication
- a relationship-linked moment
- a live personal event
- potentially a first-hearing Horary moment
- potentially journal evidence

`Grand Trine Bath (begin)` is simultaneously:

- ritual
- personally lived
- intentionally aligned with a celestial field
- the start of a span

A single enum would throw information away.

Each Crystallized Moment should therefore be classifiable along independent axes.

---

## 9. Axis A: temporal provenance

How did this time enter Orbo?

```text
live_capture
retrospective_entry
historical_reconstruction
future_planned
computed_celestial
imported
```

A second provenance qualifier can describe narrative status when needed:

```text
observed
reported
research_reconstructed
diegetic
symbolic / authored
```

Do not silently claim historical certainty or physical observation when the time is approximate, fictional, reconstructed, or source-dependent.

---

## 10. Axis B: trigger

What caused the native to preserve this time?

Initial trigger vocabulary suggested by the corpus:

```text
intuition_or_feeling
question
communication_sent
communication_received
first_hearing_or_discovery
decision_or_action
encounter_or_contact
body_or_health
ritual_or_ceremony
creative_or_professional
external_event
celestial_hinge
scheduled_or_planned
research_or_archive
unknown
```

This is deliberately closer to lived behavior than to astrological technique names.

Representative corpus evidence includes labels such as:

```text
feels
Thinking
help?
Investigation?
reachout?
texto?
emailreply
CB Missed Call
CB Text Reply
Ancestry Message Receive
FILM OFFICE DIRECTOR SUBMISSION
FIRST BOOK READING
Franks Hill Ceremony
MRI Appointment
Predictive mythology Discovery
Water trine commence
```

The taxonomy should allow more than one trigger when reality genuinely contains more than one.

---

## 11. Axis C: subject links

What Field or Fields does this moment concern?

A moment should link to zero, one, or many saved Fields rather than hiding subject identity inside its title.

Potential subject roles:

```text
self
person
relationship
family_or_ancestor
project_or_work
organization_company_team_nation
place_or_property
object_document_media
fictional_or_diegetic
celestial_phenomenon
```

The actual stored relationship should preferably be a Field reference plus a role, not only a string tag.

This is what lets one locked feeling later be attached to a specific person and appear automatically on that person's relational timeline.

---

## 12. Axis D: analysis modes

A Crystallized Moment may be read through several techniques without becoming several stored moments.

```text
open_field
horary_question
synchronic_self
synchronic_pair
event_chart
journal_evidence
electional
mundane
return_or_cycle
retrospective_research
```

These are readers / lenses, not ontological species.

Horary is therefore an analysis route over a locked moment.

---

## 13. Axis E: source confidence and time quality

The saved corpus includes exact-looking times, obvious default/noon-style times, historical reconstructions, future plans, and fictional events.

Orbo therefore needs explicit time provenance rather than pretending every timestamp has equal authority.

Potential shape:

```text
timeQuality:
  exact
  recorded
  approximate
  rounded
  rectified
  unknown
  authored_diegetic

source:
  user_observed
  document
  database
  published_source
  inferred
  imported
```

This belongs to provenance, not interpretation.

---

## 14. Point versus span

The corpus contains explicit start / end pairs such as `Grand Trine Bath (begin)` and `Grand Trine Bath (end)`.

Not every meaningful temporal object is a point.

Orbo should therefore permit:

```text
CRYSTAL
one temporal hinge

CRYSTALLIZED SPAN
start Crystal
end Crystal
optional internal milestones
```

This aligns naturally with the existing SPAN plate vocabulary and prevents a ritual, trip, performance, meeting, or episode from being flattened into one arbitrary timestamp.

---

## 15. Threads and event chains

The corpus also contains repeated series:

- chains of CB emails, calls, replies, and texts
- apology creation / sending
- repeated Gold Plates anniversaries
- repeated exact Mercury-Venus conjunction records
- recurring elections
- repeated returns

A set of moments can therefore belong to a **Thread** without becoming one Field.

```text
THREAD
  contains Crystal refs
  may link to one or more Fields
  ordered in time
  optional relation edges:
      response_to
      caused_by
      continuation_of
      same_series
```

This gives Orbo a way to understand communication chains and research series without stuffing chronology into titles.

---

# PART III. FAVORITES AND PARTIAL SPINES

## 16. Favorites mint partial spines, not necessarily centuries at once

Phase 7 proposed century pair spines minted when a chart is favorited. The recovered direction keeps the important law and loosens the materialization strategy.

A favorite should establish a **coverage map**.

```text
FAVORITE FIELD
Ean x Field B

coverage:
2025 ---------------- 2027
```

When the native asks farther into the past or future, Orbo grows that spine by range.

```text
favorite created
    |
    v
small useful temporal coverage
    |
user asks farther
    v
Loom extends requested range
```

Reasons:

- first use stays cheap
- iCal export needs only the requested window
- historical research can request a past range without paying for irrelevant future years
- a favorite can grow naturally with use
- the Embryo already supplies the universal temporal backbone

Persistence identity still needs codec / doctrine / parent identity discipline.

---

## 17. A favorite relationship wants three temporal lanes

For a favorite person or relationship, the richest read is not one undifferentiated "synastry timeline."

```text
ME
----------------o------------o----------

THEM
---------o----------------o-------------

BETWEEN US
-----o--------o-------------------o------
```

These represent distinct temporal facts:

1. my relevant spine
2. their relevant spine
3. the pair / relational spine

The interesting moments are often clusters across lanes. Orbo does not need to invent a relationship score to show that several independent systems are changing together.

The same underlying structure can drive:

- visual timeline
- calendar view
- iCal export
- notification windows
- Almanac overlays

---

## 18. Favorites should not be person-only

The Astro-Seek corpus contains repeated astrology around:

- companies
- teams
- nations
- venues
- creative projects
- historical figures
- fictional characters and story events

This suggests a broader rule:

> **Any persistent Field with a legitimate anchored state can be favorited and followed through time.**

A person's natal is one instance.

A team's founding chart, a company's origin chart, a project launch field, or a saved relationship field may also become a persistent subject if the user actually works astrologically with it.

The architecture should not hard-code `favoritePerson` where `favoriteField` is the real concept.

---

# PART IV. MOMENT LOCK x FAVORITE FIELD

## 19. The strongest extension is linking spontaneous locks to Fields

Example:

```text
2:17 PM
strong feeling about Person B
       |
       v
HORARY / MOMENT LOCK
       |
       v
physical AstroDNA preserved
```

Nothing more is required.

Later the native links the moment to Person B.

The same Crystal can then be read as:

```text
THE MOMENT
physical celestial state

ME x MOMENT
my synchronic field

PERSON B x MOMENT
their synchronic field

ME x PERSON B x MOMENT
pair field at that time

HORARY
open-field or question judgment

JOURNAL
what actually happened
```

This is not six saved charts. It is one preserved moment participating in six legitimate readings.

---

## 20. Subjective moments become data on the spine

If fifteen Moment Locks are eventually attached to the same favorite person, those fifteen moments can be placed directly on the pair timeline.

That creates a new kind of question:

> What was structurally happening in this field at the moments when I independently felt compelled to preserve it?

This is closer to Orbo's Field Theory purpose than a generic diary feature.

The user did not begin by selecting an astrological condition. They supplied the observation times first.

Orbo can then compare the structures afterward.

---

## 21. "Show me every time I felt this"

A locked moment can later receive lightweight user-authored tags such as:

```text
uneasy
sudden certainty
thought of them
wanted to call
dream
conflict
good feeling
```

Then a favorite timeline can answer:

```text
show every moment tagged "sudden certainty" about this Field
```

The Connectome can compare structural commonalities across the corresponding AstroDNAs without requiring an interpretation engine to invent a similarity first.

This is a natural bridge between:

- Moment Lock
- Field Journal
- Favorites
- partial spines
- Connectome pattern reads

---

# PART V. EXISTING ORBO SURFACES

## 22. This does not require a new Tabula by default

Existing surface grammar already has places for these objects:

### Ledger

The Ledger registry already includes:

```text
Add
Search
All
Pairs
People
Events
Horary
```

A locked Horary moment can therefore become a Ledger record and appear under Horary without inventing a Horary Tabula.

### Archive / Field Journal

Journal evidence, notes, outcomes, and recalled moments belong on the memory / Archive side.

### Almanac

A favorite field's temporal spine or a thread of crystals can be exposed as an Almanac stream / timeline when appropriate.

### Lunar Port

Horary judgment and every other interpretation remain moonlight. The Moment Lock itself is acquisition, not interpretation.

---

# PART VI. ARCHITECTURAL LAWS TO CARRY FORWARD

## 23. Provisional laws

These are design conclusions to preserve through archaeology. They are not yet code contracts.

1. **Capture first. Meaning can arrive later.**
2. **A Moment Lock is a live-minted Crystallized Moment.**
3. **Horary is a reader of a locked moment, not a separate celestial storage species.**
4. **One moment is stored once even when many readers analyze it.**
5. **A Crystallized Moment's physical celestial state is AstroDNA; why it matters is metadata and linkage.**
6. **Crystallized Moments need multi-axis classification, not one event-type enum.**
7. **Favorite means computational commitment to a Field through time.**
8. **Favorites should apply to Fields, not only people.**
9. **Favoriting may lazily mint / extend partial spines by requested temporal range.**
10. **Journal evidence describes lived experience; it does not own the celestial moment.**
11. **Subjective locks can be placed onto favorite-field spines and compared structurally afterward.**
12. **Point, span, and thread are distinct temporal organizations.**
13. **Time/source confidence is provenance and must survive.**
14. **Fictional / diegetic association is valid provenance metadata, not a reason to corrupt physical AstroDNA.**

---

## 24. Relationship to the ideal data flow

This document adds user-retained temporal objects around the settled celestial organism without changing its astronomical authority:

```text
                         EMBRYO
                            |
                    fertilize(address)
                            |
                            v
                         ASTRODNA
                            |
                            v
                       CONNECTOME
                            |
                            v
                          LOOM
                            |
                            v
                         SPINES

USER RETENTION LAYER

Moment Lock  ---> Crystallized Moment ---> Journal
                         |
                         +--> Horary reader
                         +--> other readers
                         +--> Field links

Field ------> Favorite ------> partial spine coverage
```

The Embryo remains the celestial mint. AstroDNA remains the canonical celestial language. The Connectome remains the expression network. The Loom remains temporal weaving machinery. Spines remain temporal indexes.

Moment Lock, Crystallized Moment, Favorite, Thread, and Journal answer a different question:

> **Which parts of celestial time did the native decide were worth keeping, linking, and returning to?**

That user-retention layer should build on the celestial architecture rather than bypass it.

---

## 25. Next archaeology questions

While continuing the specs scrub, look specifically for prior intent around:

- event / moment capture gestures
- Horary creation and Ledger Horary records
- favorites and favorite persistence
- Field Journal outcome / evidence schema
- pins and moment snapshots
- event chains / related records
- photo recall / EXIF capture
- favorite pair timelines and iCal export
- historical-source confidence / uncertain birth times
- project / company / team charts as persistent subjects
- any existing `event`, `horary`, `favorite`, `pin`, `thread`, or `field` record shapes that can be reconciled instead of replaced

Do not code from this document until those living and historical shapes have been traced.
