# Horary: Moment Lock, Testimony, Judgment, and Crystal Integration

**Status:** compiled design/specification document, 2026-08-15. This brings the reviewed Horary architecture already developed in the project Library into the Git repository and reconciles it with the current Field/Crystal/Embryo/Connectome architecture. It is not a claim that the full engine is currently wired into the living app.

**Primary source basis:** Alan Leo's *Dictionary of Astrology* (1929), edited by Vivian E. Robson, Horary Astrology entry, as preserved in the Orbo canonical transcription.

**Reviewed implementation basis:** `orbo-horary-layered-system-stable-reviewed.md` in the project Library.

**Companions:**

- `specs/Crystallized Moments - Moment Lock Favorites and Field Taxonomy.md`
- `specs/Synchronic Time - Field Spine Crystal and Temporal Extent.md`
- `specs/Ideal Data Flow - Embryo AstroDNA Connectome Loom.md`
- `specs/Specs Archaeology - Field Crystal Lock Favorite and Memory Lineage.md`

---

## 0. Governing idea

Horary begins with a **moment that matters before the user necessarily knows how to phrase it**.

Alan Leo's source allows a figure to be erected for:

- a moment when the mind is deeply anxious;
- an important question being asked;
- reading a letter;
- first hearing of an event.

The source also requires seriousness/clarity for sound judgment and warns against frivolous use.

Orbo's reviewed Horary work made one deliberate extension:

```text
intuition_signal
```

and paired that extension with an immutable pre-verbal **Moment Lock**. That extension must remain labeled as Orbo's own compatible development rather than attributed to Leo.

The central law is:

> **Capture the moment first. Resolve the question second.**

---

## 1. The five-layer Horary architecture

The reviewed system already settled the architecture:

```text
HORARY MOMENT LOCK
      |
      v
QUESTION / CONCERN RESOLVER
      |
      v
HORARY TESTIMONY ENGINE
      |
      v
HORARY JUDGMENT LAYER
      |
      v
HORARY INTERPRETATION LAYER
```

These layers must remain distinct.

### Moment Lock

Owns the immutable captured temporal address and the user's immediate trigger/mind-state metadata.

### Question / Concern Resolver

Determines whether the concern is mature enough to route to a quested house/topic, including turned-house logic where needed.

### Testimony Engine

Collects source-defined structural testimonies without collapsing them prematurely into prose or one numerical score.

### Judgment Layer

Composes the testimonies into the source-bounded answer shape: perfection, difficulty, interruption, mediation, passing-off, timing, unresolved status, etc.

### Interpretation Layer

Translates the judgment into user-facing language through the Lunar Port / interpretation-pack system.

The interpretation layer never owns the Horary chart or the source calculations.

---

## 2. Horary is a reader of a Crystal

The August 15 Field/Crystal reconciliation makes the storage contract cleaner than the older Ledger model.

```text
NOW + PLACE
    |
    v
MOMENT LOCK
    |
    v
EMBRYO.fertilize(address)
    |
    v
PHYSICAL ASTRODNA
    |
    v
CRYSTAL C
```

Horary then reads `C`.

```text
Crystal C
   |
   +--> open Field snapshot
   +--> Horary inquiry
   +--> Journal evidence
   +--> synchronic reads
   +--> other legitimate readers
```

The Horary record must therefore **reference the Crystal rather than duplicate the astronomical state**.

A Ledger `Horary` category can survive as an index/filter/intent category. It should not imply a second celestial species beside Event.

---

## 3. Capture must be instantaneous

The intended user gesture is almost frictionless:

```text
HORARY
  |
  v
LOCK NOW
```

The timestamp/address is authoritative at the capture gesture.

Do not wait for:

- a question form;
- topic selection;
- animation;
- interpretation-pack load;
- note entry;
- naming;
- relationship/Field linking.

After the lock, Orbo can ask what brought the user there or allow the user to dismiss the sheet entirely.

The Crystal must survive an immediate app close.

---

## 4. Trigger vocabulary

The reviewed Horary layer uses source-grounded triggers plus the explicit Orbo extension:

```text
deep_anxiety
question_asked
first_hearing
reading_letter
intuition_signal
```

The first four have direct source precedent in Leo's Horary entry.

`intuition_signal` is the Orbo extension.

A user-facing quick vocabulary can be more natural while retaining structured metadata underneath:

```text
I FELT SOMETHING
I ASKED SOMETHING
I HEARD / SAW SOMETHING
SOMETHING HAPPENED
LATER
```

The UI wording is not the doctrine enum.

---

## 5. Inquiry maturity

The reviewed architecture distinguishes three maturities:

```text
preverbal
emerging
explicit
```

This is load-bearing.

A user can know that a moment is significant before knowing the final question.

Therefore:

> **Question maturation must never rewrite the original captured time.**

The question is metadata/judgment context attached later to the same Crystal.

---

## 6. Two Horary modes over one Crystal

### 6.1 `field_snapshot`

The moment is preserved before a quested house is forced.

Orbo may examine structural facts such as:

- Ascendant / horizon;
- First House and its co-significators;
- general planetary condition;
- Moon/lunar storyline;
- radicality cautions that are meaningful without inventing a question;
- broad open-field description.

It must not manufacture a yes/no answer merely because a chart exists.

### 6.2 `question_judgment`

Once the concern is clear enough to resolve the relevant matter/house, the same Crystal can be routed through:

- querent and quested significators;
- turned-house logic;
- capacity/condition;
- application/separation;
- perfection;
- intervention;
- mediation;
- reception;
- lunar testimony;
- timing;
- house testimony;
- final judgment shape.

These are modes/read depths of one captured Field, not separate charts.

---

## 7. Mind-state and fitness metadata

The reviewed system preserves source-relevant question-state facts:

```text
clear?
definite?
anxious?
earnest?
unbiased?
frivolous?
```

These should not become a moralizing questionnaire.

Their architectural purpose is to record whether the source's own conditions for sound Horary judgment are available.

Unknown is a valid state.

Do not turn unavailable mind-state data into a fabricated pass/fail.

---

## 8. Radicality / judgment readiness

The source discusses caution when the Ascendant is very early or very late and when the querent's mind is not settled.

The reviewed engine preserves statuses such as:

```text
radical
early_ascendant
late_ascendant
question_state_unresolved
question_not_fit
mixed
```

The important architectural law is:

> **A caution can refuse or qualify final judgment without invalidating the captured Crystal.**

The moment remains useful as a Field snapshot even when final Horary judgment is withheld.

---

## 9. Question / concern resolver

The resolver translates the concern into the appropriate matter-house and significator structure.

It must support:

- direct topic -> house routing;
- explicit house override where the user/researcher already knows the house;
- turned-house questions;
- distinction between source-primary mappings and worked-example-only extensions;
- open-field state when no matter-house is yet resolved.

Example shape:

```text
HoraryInquiry
  text?
  topic?
  houseOverride?
  derivedFromHouse?
  derivedHouseNumber?
  allowExampleDerivedTopics?
```

The resolver does not change celestial state.

---

## 10. Structural testimony categories

The reviewed system recognizes testimony families including:

```text
moment
radicality
signification
horizon
capacity
application
separation
perfection
intervention
mediation
reception
lunar_storyline
timing
house_testimony
description
location
```

This is valuable because it prevents one giant `scoreHorary()` function.

Each testimony should preserve:

- category;
- source/provenance;
- role;
- effect or descriptive function;
- supporting structural facts;
- unresolved data where needed.

---

## 11. No numerical Horary score

The reviewed architecture explicitly rejects a single numerical Horary score.

Keep that ruling.

A Horary judgment is a structured composition of testimonies, not an averaging exercise in which several weak positives can mathematically erase a source-level prohibition or unresolved condition.

The engine may classify outcomes/judgment shapes, but it should expose the reasons.

---

## 12. Significators

At minimum, preserve the source structure:

```text
querent
  Ascendant ruler
  Moon as co-significator
  First-House occupants as descriptive/co-signifying testimony

quested matter
  ruler of resolved quested house
  relevant house occupants/testimony
```

The reviewed engine models:

```text
SignificatorSet
  querent
  moon
  questedHouse
  quested
  firstHouseCoSignificators[]
```

This is a reader over the Crystal/Connectome, not a new chart calculation.

---

## 13. Applying and separating are first-class

The reviewed Horary interfaces explicitly model:

```text
phase:
  applying
  exact
  separating

orb
degreesToExact
```

and separate queries for applying and separating aspects.

This aligns directly with the August 15 Connectome ruling:

```text
NODE MOTION
  speed / direction / station proximity

RELATION EDGE MOTION
  applying / exact / separating
  relative angular speed
  perfection / ingress / egress
```

Horary should consume this structural edge state rather than maintain a second application/separation calculator if the restored Connectome can supply the canonical relation.

---

## 14. Perfection, intervention, and mediation

The reviewed source boundaries matter.

### Perfection

A conjunction can perfect the matter without being assigned an automatically fortunate nature.

Trine/sextile receives the source's unqualified favorable treatment only under the reviewed first-aspect condition.

Square/opposition may still perfect while describing difficulty or an unsatisfactory result.

### Intervention

A prior contact encountered before the significators reach their intended perfection is recorded as intervention rather than erased from the story.

### Mediation

A more ponderous planet that joins the parties is preserved as mediation. It is not automatically labeled favorable/adverse merely because mediation occurred.

These distinctions belong in testimony/judgment, not geometry.

---

## 15. Reception

Mutual reception is a modifying testimony.

The reviewed Horary work intentionally refuses to invent richer reception details unless Orbo's reception subsystem supplies them.

That is now a natural Connectome seam:

```text
Crystal AstroDNA
   -> Connectome
      -> receptions
      -> dispositors / governors
```

Horary consumes the reception facts and applies Horary doctrine to them.

It should not reconstruct a private reception system beside the Connectome.

---

## 16. Lunar storyline

The Moon has a special Horary role beyond generic aspect counting.

The reviewed system preserves:

- current lunar condition;
- applying contacts;
- separating contacts where source-relevant;
- lunar perfection/timing testimony;
- intervention/story sequencing.

This should be read as an ordered temporal story rather than an unordered bag of Moon aspects.

Where Loom/Connectome can supply exact crossing order, Horary should consume that common machinery.

---

## 17. Timing

The reviewed architecture preserves both:

- significator-derived timing;
- Moon-derived timing;

when each is available.

Do not discard one simply because the other resolves.

Timing units and modality/house-condition rules belong to the Horary doctrine layer. Exact astronomical perfection addresses belong to Loom/Embryo-mediated temporal machinery.

---

## 18. Source boundaries that must survive

The reviewed Horary system already made several important provenance decisions:

1. No numerical Horary score.
2. Perfection and significator capacity are separate.
3. Conjunction is not automatically labeled fortunate.
4. Trine/sextile favorable treatment is source-conditioned.
5. Prior contact is recorded as intervention.
6. Square/opposition can perfect with difficulty.
7. Separating significators can describe a matter passing off or completed.
8. Mediation remains its own testimony.
9. Mutual reception modifies rather than automatically decides.
10. Significator timing and lunar timing are both preserved.
11. Source orb limits remain doctrine, not generic Ring geometry.
12. Worked-example-only topic mappings stay opt-in/source-labeled.
13. `intuition_signal` and pre-verbal Moment Lock are explicit Orbo extensions.

Do not flatten source-derived doctrine and Orbo extensions into one unattributed ruleset.

---

## 19. Relationship to Ring / Connectome / Loom

The restored architecture gives Horary a clean dependency line.

```text
EMBRYO
  physical moment
      |
      v
ASTRODNA
      |
      v
CONNECTOME
  houses / rulers / condition / receptions / relation edges / motion
      |
      +--------------------+
      |                    |
      v                    v
HORARY TESTIMONY          LOOM
source doctrine         exact crossing/timing where needed
      |                    |
      +---------+----------+
                v
          HORARY JUDGMENT
                |
                v
            LUNAR PORT
                |
                v
          INTERPRETATION
```

The Ring owns geometry.

The Connectome expresses the Crystal.

The Loom finds temporal crossings.

Horary owns Horary doctrine and judgment.

The Lunar Port owns presentation/interpretation delivery.

---

## 20. Relationship to Moment Lock / Pin / Journal

These gestures are related but not identical.

```text
MOMENT LOCK
capture NOW immediately

PIN
keep the already-addressed moment under the cursor

LOG
keep a reading and open reflection/evidence entry
```

A Horary button invokes Moment Lock because timing is the point.

Afterward the same Crystal may:

- remain a Horary Field snapshot;
- mature into a question judgment;
- receive a Journal note/rating;
- link to another Field/person/project;
- be added to a Thread;
- serve as a Span hinge;
- be compared on a Synchronic Spine.

No duplicate astronomical state is required.

---

## 21. Relationship to Synchronic Time

For the native `A` and Horary Crystal at `t`:

```text
M(t)
  physical Horary Moment Field

S_A(t)
  native's synchronic Field state at the same coordinate
```

Those are different legitimate reads of one temporal coordinate.

Horary asks what the physical moment says about the question/concern.

Synchronic Time asks where the native's Field is on its own temporal extension at that coordinate.

Orbo should make both available without implying they are interchangeable.

---

## 22. Ledger / roster integration

The older Ledger spec treats `horary` as a roster kind beside `person`, `event`, and `composite`.

The unified plan should separate:

```text
CELESTIAL / STATE ONTOLOGY
Crystal

INDEX / USER INTENT
Horary category
Event category
Journal linkage
etc.
```

A Horary row can still look and behave like a Horary row in Ledger while its underlying state reference points to the same Crystal model used elsewhere.

This avoids breaking useful UI taxonomy while preventing duplicate celestial records.

---

## 23. Persistence

The Moment Lock must persist immediately enough to survive abandonment of the interaction.

Minimum persistent Horary capture should include:

```text
crystalId
capturedAt / canonical temporal address
place / horizon provenance
physical AstroDNA reference or durable encoded state
trigger
trigger authority
inquiry maturity
rawSignal? / note?
```

Question text/topic/house routing can arrive later.

Testimony/judgment results should be versioned/provenanced enough to distinguish:

- the immutable captured state;
- doctrine used to judge it;
- interpretation pack/voice used to explain it.

A doctrine update may require re-judgment without changing the Crystal.

---

## 24. Horary Crystal versus finite-event timeline

A Horary Crystal is usually a finite moment.

Favoriting it does not automatically create a century-long Horary spine.

A favorite Horary Crystal may deserve:

- durable state/provenance;
- warm Connectome expression;
- cached testimony/judgment;
- Journal links;
- Thread/Span membership;
- easy comparison with natal/synchronic Fields.

This follows the Field-type-specific Favorite law.

---

## 25. User-facing process

A likely process, subject to design review:

```text
1. user feels/asks/hears something

2. tap HORARY
   timestamp/address locks immediately

3. confirmation can disappear immediately
   Crystal is safe

4. optional post-lock prompt
   I FELT SOMETHING
   I ASKED SOMETHING
   I HEARD / SAW SOMETHING
   SOMETHING HAPPENED
   LATER

5. optional raw note / question

6. if concern is not mature
   show/open FIELD SNAPSHOT

7. when concern becomes explicit
   resolve matter house
   build TESTIMONY
   produce JUDGMENT

8. interpretation arrives through Lunar Port

9. later
   Journal outcome / rating / Thread links can attach to same Crystal
```

The exact surface location of the Horary button remains a design question. The capture law does not.

---

## 26. Provisional data relationship

Do not freeze property names before the unified plan, but preserve this separation:

```text
Crystal
  id
  stateRef
  address
  provenance

HoraryRecord
  crystalId
  trigger
  triggerAuthority
  mindState
  maturity
  rawSignal?
  inquiry?
  doctrineVersion?
  testimonyRef?
  judgmentRef?

JournalEvidence
  crystalId
  note
  rating?
  outcomeObserved?
```

One Crystal can have zero or one/more Horary records depending on final inquiry versioning policy. It should never require cloning the sky.

---

## 27. Verification obligations for eventual integration

When this moves from plan to code, prove at least:

1. The timestamp is fixed before any Horary form interaction.
2. Closing the app immediately after Lock does not lose the Crystal.
3. Adding/editing the question later never changes the captured state.
4. `field_snapshot` can render without forcing a quested house.
5. Final judgment can refuse/qualify itself while the Crystal remains valid.
6. Applying/separating agrees with the canonical relation-edge calculation.
7. Reception agrees with the Connectome, not a hidden Horary duplicate.
8. Exact temporal perfections use the common temporal machinery rather than another root finder where the Loom contract applies.
9. Changing interpretation voice changes words, not judgment addresses.
10. Changing doctrine invalidates/recomputes judgment as appropriate without mutating the Crystal.
11. A Horary Crystal and an Event/Journal view of the same moment reference one state rather than duplicate AstroDNA.
12. Old Ledger Horary records can migrate/add references without data loss.

---

## 28. What remains open for the unified plan

The source doctrine and layered architecture are mature enough to preserve. The following implementation choices remain deliberately open:

- exact Crystal schema and IDs;
- whether one Crystal can carry multiple evolving Horary inquiries or one canonical inquiry with revisions;
- where the Horary quick-capture button lives;
- which post-lock trigger choices are shown by default;
- how Ledger migrates `kind:'horary'` records;
- which Horary structural facts are read directly from the restored Connectome versus computed in a Horary adapter;
- how source orb policy composes with universal Ring geometry;
- how Horary timing requests route through Loom without making Loom own Horary doctrine;
- how Journal evidence links back to eventual outcomes.

Those are unified-plan questions. The fundamental law is already settled:

> **Horary captures one meaningful Crystal, then progressively resolves what that moment is being asked to say.**
