# Crystallized Moments: Moment Lock, Favorites, and Field Taxonomy

**Status:** design/recovery document. Preserve this direction while specs archaeology continues. This is not yet an executable contract and does not assert that the living app implements every object below.

**Evidence base:** the August 15, 2026 Astro-Seek databank export supplied by Ean, containing 544 saved charts, read alongside the existing Field Journal, Horary, Connectome, Ledger, Phase 7 Synchronic Time plans, the recovered Shared Crystal Synchronic Synastry operation, and `specs/Synchronic Time - Field Spine Crystal and Temporal Extent.md`.

---

## 0. The recovered idea

Orbo needs to make it easier to preserve significance **before the native understands it**.

The practical behavior already exists outside Orbo: when a strong thought, feeling, question, message, event, or coincidence happens, the native may preserve the exact time first and cast/analyze it later.

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
    +--> link to another Field later
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
- births and deaths
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

A **Field** is an astrological configuration of light/energy represented by a chart or chart-like state.

The word is intentionally broad. A natal chart is already a Field. A moment chart is already a Field. A relationship composite is a derived Field. A synchronic composite is a derived synchronic Field.

```text
PHYSICAL FIELD
  physical celestial state resolved at a declared address

DERIVED FIELD
  state produced from one or more Fields by a declared transformation

SYNCHRONIC FIELD
  derived Field produced by relating a Field to a Moment Field
```

Examples:

```text
person's natal chart           physical natal Field
email moment                   physical Moment Field
company founding chart         physical origin Field
relationship composite         derived relationship Field
person + email moment          derived synchronic Field
relationship + moment          derived synchronic relationship Field
```

A Field may be temporally persistent, origin-anchored, or finite. **Field does not automatically mean "deserves its own timeline."**

That distinction belongs to the Field's temporal character and to Favorite build policy.

---

## 4. Crystal / Crystallized Moment

A **Crystal** is a Field-state fixed to a particular temporal address so it can be retained, named, compared, returned to, linked, or selected.

`Crystallized Moment` remains the fuller user-retention phrase for a Crystal whose defining fact is one temporal coordinate.

```text
CRYSTAL
  physical AstroDNA where applicable
  time
  place / horizon where applicable
  provenance
  source confidence
  trigger metadata
  subject / Field links
  annotations
  temporal role
```

A Crystal can be:

- captured live
- entered retrospectively
- reconstructed historically
- chosen in the future
- generated from a celestial hinge
- imported from another system
- associated with a fictional / diegetic event

This separates **what the heavens were doing** from **why the time matters**.

The physical celestial state remains AstroDNA. Meaning, provenance, temporal role, and use live in metadata and downstream readers.

A Crystal does not automatically gain a personal timeline. A finite event may remain exactly what it is: one important Field-state.

---

## 5. Moment Lock

A **Moment Lock** is the live-capture route into a Crystal.

```text
Moment Lock = Crystal retained from NOW
```

The timestamp is taken immediately.

Everything after capture is optional enrichment.

The lock should survive an immediate app close.

The lock does not create the synchronic state. It identifies and retains the temporal coordinate at which the state already exists on the relevant Synchronic Spine(s).

---

## 6. Favorite

A **Favorite** is not merely a star or sorting preference.

> **Favoriting tells Orbo that this Field or Crystal matters enough to keep computationally warm.**

But the build must depend on what was favorited.

Favoriting a natal Field should not do the same work as favoriting one email Crystal.

The Favorite system therefore needs two separate questions:

```text
WHAT IS THIS OBJECT?

WHAT COMPUTATIONAL COMMITMENT DOES THAT TYPE DESERVE?
```

Some Favorites deserve synchronic temporal coverage. Some deserve only persistent state, cached relations, and fast recall.

This is developed in Part III.

---

## 7. Journal evidence

A Journal record answers a different question from a Moment Lock.

```text
LOCK
"I need this instant."

FAVORITE
"Keep this Field/Crystal computationally available."

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

The same Crystal should not be copied into separate Horary, Event, and Journal celestial objects merely because several readers use it.

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
- the start of a Span

A death Crystal can simultaneously be:

- death
- historically reconstructed
- a life-span endpoint
- a family/relationship event
- the beginning of posthumous aftermath research

A single enum would throw information away.

Each Crystal should therefore be classifiable along independent axes.

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
symbolic_or_authored
```

Do not silently claim historical certainty or physical observation when the time is approximate, fictional, reconstructed, or source-dependent.

---

## 10. Axis B: trigger / event family

What caused the native to preserve this time, or what kind of hinge is it?

Initial vocabulary suggested by the corpus and current architecture:

```text
intuition_or_feeling
question
communication_sent
communication_received
first_hearing_or_discovery
decision_or_action
encounter_or_contact
body_or_health
birth
death
ritual_or_ceremony
creative_or_professional
external_event
celestial_hinge
scheduled_or_planned
research_or_archive
unknown
```

**Death is first-class.** It should not be hidden inside `external_event` or `body_or_health` when the Crystal is specifically a death.

The taxonomy should allow more than one trigger/family when reality genuinely contains more than one.

Representative corpus-style evidence includes labels such as:

```text
feels
Thinking
help?
Investigation?
reachout?
texto?
emailreply
Missed Call
Text Reply
Ancestry Message Receive
Director Submission
First Book Reading
Ceremony
MRI Appointment
Discovery
exact celestial perfection
birth
death
```

---

## 11. Axis C: Field links / subjects

What Field or Fields does this Crystal concern?

A Crystal should link to zero, one, or many saved Fields rather than hiding subject identity inside its title.

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

The stored relationship should preferably be a Field reference plus a role, not only a string tag.

This is what lets one locked feeling later be attached to a specific Field and appear automatically on that Field's relevant timelines/readings.

---

## 12. Axis D: analysis modes

A Crystal may be read through several techniques without becoming several stored moments.

```text
open_field
horary_question
synchronic_self
synchronic_pair
synchronic_relationship_field
event_chart
journal_evidence
electional
mundane
return_or_cycle
retrospective_research
```

These are readers / lenses, not ontological species.

Horary is therefore an analysis route over a locked Crystal.

A death Crystal may be read as historical event, natal/synchronic comparison, relationship hinge, Thread member, Span endpoint, or other legitimate mode without being copied.

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

This is especially important for birth and death times, historical events, conception hypotheses, and other moments whose exact minute may be uncertain.

---

## 14. Axis F: temporal role relative to a Field

A Crystal's relationship to a Field's biography/history is separate from the Crystal's astronomical validity.

Potential roles:

```text
pre_origin
conception_candidate
prenatal
birth_or_origin
embodied_or_active_period
death_or_closure
posthumous_or_afterlife_of_field
future_relative_to_observer
external_historical_relation
unknown
```

These names remain provisional. The law is not.

> **Temporal relevance and physical participation are separate facts.**

Examples:

```text
conception candidate before a person's birth
  valid synchronic relation
  not embodied experience

death
  end of embodied biography
  major Crystal
  not end of synchronic addressability

posthumous event
  later Crystal related to natal Field
  must not be described as personally experienced
```

For companies/projects/institutions the analogous lifecycle language may be `pre_origin`, `origin`, `active`, `closure`, and `post_closure` rather than human biological terms.

---

## 15. Death as a first-class Crystal

Death deserves explicit structure because it can simultaneously be a moment, a boundary, and a hinge for later research.

```text
DEATH CRYSTAL
  eventFamily: death
  physical Moment AstroDNA
  subject Field link
  timeQuality
  source provenance
  temporalRole: death_or_closure
  optional Thread membership
  optional Span endpoint
```

A death Crystal can:

- close a biographical Span;
- anchor a final-year synchronic chronology;
- begin a posthumous aftermath Span;
- become a major Crystal on another person's or relationship's timeline;
- participate in historical, horary, mundane, or other readings where appropriate.

Classifying death does not itself interpret death or claim causation.

Most importantly:

> **Death closes the biography, not the Synchronic Spine.**

---

## 16. Point versus Span

The corpus contains explicit start/end pairs such as ritual beginnings and endings.

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

A life can be represented as a Span from birth to death while both endpoint natal/synchronic Fields remain addressable outside that Span for research.

A pregnancy hypothesis can be a Span from conception candidate to birth.

A project can have an active Span from launch/origin to closure while still being related to earlier preparation and later legacy moments.

---

## 17. Threads and event chains

The corpus also contains repeated series:

- chains of emails, calls, replies, and texts
- apology creation / sending
- recurring anniversaries
- repeated exact celestial contacts
- recurring elections
- repeated returns
- historical sequences leading to death or another major event

A set of moments can therefore belong to a **Thread** without becoming one new Field.

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

This gives Orbo a way to understand communication chains, pregnancies, trials, final-year sequences, rituals, and research series without stuffing chronology into titles.

---

# PART III. FAVORITES AND FIELD-TYPE BUILDS

## 18. Favorite is a policy decision, not one build recipe

The old formulation "Favorite -> partial spine" is too broad.

The corrected rule is:

> **Favoriting chooses a computational retention policy appropriate to the object's temporal nature.**

All Favorites may deserve:

- persistent identity/provenance
- persistent or warm Connectome state where applicable
- fast recall
- saved user annotations
- links to Crystals/Threads/Spans

Only some Favorite types deserve independent synchronic temporal coverage.

---

## 19. Favorite build matrix

### 19.1 Natal Field

Examples:

- person
- ancestor
- historical person
- fictional character with a declared natal/origin chart

Default Favorite build:

```text
persist/warm natal Connectome
establish Synchronic Spine coverage
materialize useful return/crossing indexes
allow pre-birth and posthumous extension on demand
allow pair-spine builds with other favored natal Fields
allow iCal / visual timeline windows
```

A human lifetime may be the default viewing window. It must not be an architectural hard stop.

### 19.2 Relationship Field

A saved person-person composite or other persistent relationship Field.

Default Favorite build:

```text
persist relationship Field identity / Connectome
establish relationship-field Synchronic Spine coverage
retain parent references
optionally maintain Synchronic Synastry pair coverage for the parents
support Crystals/Threads/Spans linked to the relationship
```

Do not collapse the relationship-field spine into the parents' Synchronic Synastry spine. They answer different questions.

### 19.3 Origin-anchored persistent Field

Examples:

- company
- team
- nation
- institution
- project
- production
- publication
- venue or other object with a meaningful origin chart

Default Favorite build:

```text
persist origin Field / Connectome
establish synchronic coverage around relevant active history
extend backward/forward on demand
support event Threads and Spans
support comparison with natal/relationship Fields
```

The default coverage window may differ by subtype. A project may need its development/launch/aftermath range rather than 100 years.

### 19.4 Finite event Crystal

Examples:

- email
- text
- phone call
- first hearing
- ceremony
- appointment
- accident
- execution
- death
- exact celestial perfection
- one historical event

Default Favorite build:

```text
persist Crystal AstroDNA / provenance
persist or warm its Connectome expression
cache important derived Lots / relations as appropriate
retain linked Fields
retain Thread/Span membership
make Horary/event/synchronic readers fast
```

**Do not build an independent century timeline merely because the event was favorited.**

An event is defined by its finite coordinate unless the user explicitly promotes it into a persistent Field through a legitimate origin/continuity model.

The event can still be used as:

- shared Crystal parent in Synchronic Synastry;
- Span endpoint;
- Thread member;
- comparison target;
- historical hinge;
- Journal evidence anchor.

### 19.5 Span

A Span is an interval, not automatically a Field.

Favorite build:

```text
persist start/end Crystal refs
persist metadata / notes
cache requested Loom results over the bounded interval
no independent spine by default
```

### 19.6 Thread

A Thread is an ordered set of Crystals, not automatically a Field.

Favorite build:

```text
persist membership/order/edges
warm linked Crystal/Field reads
optionally cache aggregate comparison results
no independent spine by default
```

If a Thread later becomes a recognized persistent Field, that is a separate explicit promotion rather than an automatic consequence of having many events.

---

## 20. Partial spine coverage remains the right strategy where a spine is warranted

For Field types that genuinely deserve a temporal spine, Favoriting should establish a **coverage map**, not necessarily compute an arbitrary century immediately.

```text
FAVORITE NATAL FIELD

coverage:
2025 ---------------- 2027
```

When the native asks farther into the past or future, Orbo grows that coverage by range.

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
- prenatal/posthumous work can extend only where needed
- a project/company can use an appropriate active-history range
- the Embryo already supplies the universal temporal backbone

Persistence identity still needs codec / doctrine / parent identity discipline.

---

## 21. A favorite pair can expose multiple temporal lanes

For two favored natal Fields A and B, the richest read is not one undifferentiated synastry timeline.

At minimum Orbo may eventually expose:

```text
A SYNCHRONIC SPINE

B SYNCHRONIC SPINE

A-B SYNCHRONIC SYNASTRY SPINE

A-B RELATIONSHIP-FIELD SYNCHRONIC SPINE
```

The first two are personal temporal Fields.

The third is the continuous crossing of the two personal synchronic timelines, historically called **Intersections** in early Orbo thinking.

The fourth is the relationship composite itself moved through time.

These are distinct temporal objects.

The same underlying structures can drive:

- visual timeline
- calendar view
- iCal export
- notification windows
- Almanac overlays
- electional searches

---

# PART IV. MOMENT LOCK x FAVORITE FIELD

## 22. The strongest extension is linking spontaneous locks to Fields

Example:

```text
2:17 PM
strong feeling about Field B
       |
       v
HORARY / MOMENT LOCK
       |
       v
physical AstroDNA preserved
```

Nothing more is required.

Later the native links the Crystal to Field B.

The same Crystal can then be read as:

```text
THE MOMENT
physical celestial state

ME + MOMENT
my synchronic Field state

FIELD B + MOMENT
its synchronic Field state

(ME + MOMENT) x (FIELD B + MOMENT)
Synchronic Synastry where applicable

HORARY
open-field or question judgment

JOURNAL
what actually happened
```

This is not several separately saved copies of the sky. It is one retained temporal coordinate participating in several legitimate readings.

---

## 23. Subjective moments become data on the spine

If many Moment Locks are eventually attached to the same favored natal/relationship Field, those Crystals can be placed directly on its relevant computed timelines.

That creates a new kind of question:

> What was structurally happening in this Field at the moments when I independently felt compelled to preserve it?

The user supplied the observation times first.

Orbo can compare the structures afterward.

For a finite event Favorite, the inverse is also useful: one event Crystal can be compared across several persistent Fields without pretending the event itself owns a life-long spine.

---

## 24. "Show me every time I felt this"

A locked Crystal can later receive lightweight user-authored tags such as:

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
show every Crystal tagged "sudden certainty" about this Field
```

The Connectome can compare structural commonalities across the corresponding states without requiring an interpretation engine to invent a similarity first.

This is a natural bridge between:

- Moment Lock
- Field Journal
- Favorites
- partial spines
- Connectome pattern reads

---

# PART V. EXISTING ORBO SURFACES

## 25. This does not require a new Tabula by default

Existing surface grammar already has places for these objects.

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

Death can remain an Event family/filter while also carrying its explicit `death` taxonomy role.

### Archive / Field Journal

Journal evidence, notes, outcomes, and recalled moments belong on the memory / Archive side.

### Almanac

A favorite Field's temporal coverage, a Thread of Crystals, or a bounded Span can be exposed as Almanac/timeline material when appropriate.

### Lunar Port

Horary judgment and every other interpretation remain moonlight. Moment acquisition, Crystal retention, Field identity, and Favorite build policy are structural/data acts.

---

# PART VI. ARCHITECTURAL LAWS TO CARRY FORWARD

## 26. Provisional laws

These are design conclusions to preserve through archaeology. They are not yet code contracts.

1. **Capture first. Meaning can arrive later.**
2. **A chart is already a Field.**
3. **A Crystal is a Field-state fixed to a temporal address for retention, return, comparison, or selection.**
4. **A Moment Lock is the live-capture route into a Crystal.**
5. **Horary is a reader of a locked Crystal, not a separate celestial storage species.**
6. **One moment is stored once even when many readers analyze it.**
7. **A Crystal's physical celestial state is AstroDNA; why it matters is metadata and linkage.**
8. **Crystals need multi-axis classification, not one event-type enum.**
9. **Death is a first-class Crystal/event family and lifecycle hinge.**
10. **Death closes biography, not synchronic addressability.**
11. **Temporal relevance and embodied participation are separate facts.**
12. **Favorite means computational commitment appropriate to the object's temporal character.**
13. **Favorite build policy must be Field-type dependent.**
14. **Natal and other persistent Fields may merit synchronic spine coverage.**
15. **A finite event Crystal does not receive an independent timeline by default.**
16. **A favorite event can still persist its AstroDNA, Connectome, derived points, relations, links, and readers.**
17. **Partial spine coverage is preferred over arbitrary full-century materialization where a spine is warranted.**
18. **Journal evidence describes lived experience; it does not own the celestial moment.**
19. **Subjective locks can be placed onto relevant favorite-field spines and compared structurally afterward.**
20. **Point, Span, Thread, and Spine are distinct temporal organizations.**
21. **A Thread is not automatically a Field.**
22. **A Span is not automatically a Field.**
23. **Time/source confidence is provenance and must survive.**
24. **Fictional/diegetic association is valid provenance metadata, not a reason to corrupt physical AstroDNA.**
25. **Synchronic Spine and Favorite policy are related but not synonymous: not every Favorite owns a Spine.**

---

## 27. Relationship to the ideal data flow

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

USER RETENTION / ORGANIZATION

Moment Lock ---> Crystal ---> Journal
                  |
                  +--> Horary reader
                  +--> other readers
                  +--> Field links
                  +--> Thread / Span

Field/Crystal ---> Favorite Policy
                      |
                      +--> warm/persist state
                      +--> optional partial spine coverage
                          ONLY when temporally warranted
```

The Embryo remains the celestial mint. AstroDNA remains the canonical celestial language. The Connectome remains the expression network. Loom remains temporal weaving machinery. Spines remain temporal indexes/materializations.

Moment Lock, Crystal, Favorite, Thread, Span, and Journal answer a different question:

> **Which parts of celestial time and which Fields did the native decide were worth keeping, linking, computing, and returning to?**

That user-retention layer should build on the celestial architecture rather than bypass it.

---

## 28. Next archaeology questions

While continuing the specs scrub, look specifically for prior intent around:

- event / moment capture gestures
- Horary creation and Ledger Horary records
- death/event record shapes
- favorites and favorite persistence
- whether favorites currently distinguish natal/person/event/pair kinds
- Field Journal outcome/evidence schema
- pins and moment snapshots
- event chains / related records
- photo recall / EXIF capture
- favorite pair timelines and iCal export
- historical-source confidence / uncertain birth and death times
- project/company/team charts as persistent subjects
- any existing `event`, `horary`, `favorite`, `pin`, `thread`, `span`, `death`, or `field` record shapes that can be reconciled instead of replaced

Specific Favorite question:

> **What did Orbo already decide should be persisted or materialized for each object kind, and where did later code flatten those distinctions into one favorite behavior?**

Do not code from this document until those living and historical shapes have been traced.