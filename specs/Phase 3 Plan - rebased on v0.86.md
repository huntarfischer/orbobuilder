# Phase 3 — The Lunar Surface · implementation plan, rebased on v0.86

Written 2026-07-28 after reading the 7/26 build plan, the 7/28 Phase 3 build plan (written against
v0.855), the v0.86 version notes, and the current `Orbo Astrolabe.dc.html`. Supersedes
`specs/Phase 3 - Lunar Surface Build Plan.md` for ordering and open questions; that file stays as
the reasoning of record for the rune and the ladder shape.

## What changed since that plan was written

**Phase 2 shipped (v0.86).** The depth contract now exists — `_depthRank()` / `_atLeast(d)` /
`_atDepth(rows)`, cumulative and additive-only, absent `d` means L1, plus `state.doctrine` behind
`_doc` / `_setDoctrine` / `_doctrineKey`. Consequences for Phase 3:

- **C2's open question is answered by fact, not by preference.** The depth slot no longer needs to be
  an empty prop hole — the spread's headers and subheaders can carry the real contract on day one.
  `_atDepth` is a row *filter*, so the spread's description field takes a filtered row list, and its
  header takes a rank + lineage pair. No second depth contract, no rebuild later.
- **The depth dial is in Orbo's panel, not ♑.** The 7/26 plan put it in ♑ (gears = behaviour); v0.86
  moved it to the foot of Orbo's panel ("how far I go"), on the argument that depth is a property of
  moonlight. That is now the shipped law and the tabula spread must not re-litigate it: **♑ gets no
  depth control.** Note the residual asymmetry — the *doctrine* presets are still specced for the back
  and still have no UI, so ♑/back and Orbo now split settings on a line that is worth restating in
  CLAUDE.md before C2 lands.
- **`_atDepth` filters rather than annotates**, which is a hard constraint on the spread: the
  description field must render an empty list gracefully at L1, because rows genuinely disappear. A
  layout that assumed "always three rows, some dimmed" will collapse.

**Nothing else in Phase 3 moved.** Confirmed against the file: A (moonglass) is in; B, C, D, E and the
rune are not started — the five `+ Pin to Moon pane` text chips are still there (renderVals ~3381,
3391, 3521, 3743, plus the ♒ `ptPin` glyph), and there is no `_makePane`. The seven owners of the pane
rise are unchanged.

**Also inherited from v0.86, and relevant:** a pre-existing unclosed `sc-if` (`orboOn`, template ~177)
and an unresponsive preview harness for that whole session, so the instrument was last visually
confirmed at v0.86-standalone (this session's export renders correctly, which retires that worry).

---

## The order I'd build in

Unchanged in shape from the 7/28 plan — B before C before D before E, because C needs a known rise and
D needs a content rectangle to put in a non-moon surface. Two edits: the rune moves ahead of everything
(it is independent, it is approved-in-principle, and it retires five inconsistent chips), and C2 now
builds with the real depth contract instead of a hole.

| # | Item | Who | Gate |
|---|---|---|---|
| 1 | Rune button — one component, mounted at ZR only | `[O]` | approve the glyph in place |
| 2 | Rune applied to the other four pin sites; text chips retired | `[S]` | after 1 is judged |
| 3 | `this.pane` stop ladder, behaviour-identical | `[O]` design · `[S]` sweep | snapshot first |
| 4 | C1 rimmed content box; ledger `BODY / HSE / DISPOSITOR` headers restored | `[O]` | needs 3 |
| 5 | C2 tabula spread — first customer ♑ doctrine, real depth slot | `[O]` then `[S]` × rest | needs 4 |
| 6 | Occulter API; cold open proves it | `[O]` | needs 4 |
| 7 | Cohesion sweep | `[S→O]` | last by definition |
| 8 | Arc slider | `[O]` | any time after 3; ♑ is first customer |

**Snapshot to `archive/Orbo Astrolabe 2026-07-28e.dc.html` before step 3.** The ladder is the one
risky move in the phase; steps 1–2 are additive and don't need their own snapshot.

---

## Step-by-step

### 1–2 · The rune

Build exactly as specced: two `<circle>` strokes with a clip, tinted by `stroke`, the far disc's `cy`
animated on the presentation clock (`_spr`, never a CSS transition — the gesture-motion ban applies to
a 200ms button too). 44px round hit target, 22px glyph. Three states by finish, not value: silver /
risen-with-gold-hem / 0.35-no-tap.

Two things to get right that the earlier plan left implicit:

- **Availability comes from the same source the ladder will use.** Don't wire the disabled state to a
  per-site boolean now and rewire it in step 3 — write it against a single `_paneLensAvailable(id)`
  helper that step 3 can move into `pane.available()` without touching five mounts.
- **The five sites are not identical.** ZU/election/almanac carry a border colour (`*PaneBd`) that the
  rising site doesn't; the ♒ pin is a glyph, not a chip, and **keeps the ♒ glyph** — memory is a
  different destination. So it is four mounts plus one deliberate non-change.

On the open question, **build one rune and hold.** A rune family per moon view needs the spread's
headers to exist (step 5) before there is anywhere for them to live.

### 3 · The ladder

The 7/28 spec's five rules stand as written and I would not restate them. What I'd add now:

- **Capture the five rise states as screenshots before touching anything** — peek, facts, eclipse,
  almanac (0.30 veil), flipped — and diff after each of the three sub-moves. This is a refactor whose
  only acceptance criterion is *indistinguishable*, and the last session's harness trouble is a reason
  to bank the reference images while the preview is known-good.
- **Three sub-moves, in this order, each independently shippable:** (a) stops + `_box()`-derived
  geometry, `_eclipseTranslate` and `_eYCache` collapsed in, everything else still reading through
  shim accessors; (b) the resolver — `flipped` and "no sheet" become *reasons*, availability becomes
  content-declared (`needs`), `_eReadLen > 0 || _raisedLens` retires; (c) the drag's rubber band, alone,
  last, with the release-velocity hand-off (`spr.v = spr.vHint`) preserved verbatim.
- **The spine is not involved.** `this.pane` is a sibling of `this.spine` and never a field on it, and
  it advances on the one `dt` from the one RAF via `_sprStep`. If any part of the ladder wants to know
  *when*, it asks the spine and does not cache.

### 4 · C1, the content rectangle

A geometry fix, not doctrine, and the one visible defect the phase exists to clear: at v0.85 the bead
ring was sliced at both edges and `NATAL` / `THE SKY` were half-clipped. Seat a straight-sided panel
inside the dome, inset far enough that the ring is whole **at every stop** — which is only checkable
once step 3 owns the stops. The panel *is* A's scrim: one glass recipe, not a sixth gradient. Restore
the ledger column headers v0.82 had; note that v0.86 made the ledger's **column count follow the depth
dial** (hse L2, dispositor L3), so the header row must be generated from the same filtered column set,
not hardcoded — otherwise L1 shows a DISPOSITOR header over nothing.

No `backdrop-filter` unless a measured contrast floor forces it, and then on the ledger column only.

Arc-riding labels: labels on the dome's limb keep their curve, anything inside the rectangle is set
straight. Mixed is honest — the arc is the moon's limb, the rectangle is the page laid on it.

### 5 · C2, the tabula spread

*Items along one edge · description field beside them · pin at the bottom* (the pin is the rune). Built
once, then `[S]` applies it to the rest of ♍ ♎ ♏ ♋ ♑ ♒.

**The first customer is ♏ Timing, not ♐** *(decided 2026-07-28; see the doctrine reversal below —
there is no ♑ doctrine section to be the first customer)*. ♏ is the measured worst offender: the
2026-07-28 screenshot shows the ZR block, the new rune, two peak pills and a bare column all fighting
in one 180px stack, and peak definition is itself a doctrine component, so ♏ exercises the in-context
lineage door on its home turf.

#### The settings-homes decision — FIRST PASS, SUPERSEDED

> **Superseded within the same day** by *§ The depth ladder owns doctrine* below. Kept deliberately:
> the argument here is sound **for doctrine-as-school-choice**, which is not what doctrine turned out
> to be. Read it, then read the reversal — the reversal is only legible against it.

**The 7/26 "two-panel split" law is void.** It read *depth dial in ♑ · doctrine presets on the back*,
which presumed a maker's-side surface separate from the tabulae. **There is no such surface.** The back
is the engraving plus the twelve tabulae — nothing else. Strike the law; do not re-argue it.

What replaces it: **they are all gears.** Motion gears change how the instrument moves; doctrine gears
change what it is geared *to*. Same tabula (♑), two sections, not interleaved.

| Door | Subject | Question |
|---|---|---|
| Orbo's panel | **Orbo** | how much he tells me — shipped v0.86, stays |
| ♑ Gears · motion | **the mechanism** | how it moves under my hand |
| ♑ Gears · doctrine | **the instrument** | which school it is geared to |

Depth stays with Orbo because the dial is in his voice and about his own behaviour; nothing about the
sky changes when it moves. Doctrine cannot live there — **Orbo is the herald, not the authority.** His
L3 voice rule (*"this is Valens's Eros, not Paulus's Venus-lot"*) only works if someone else made the
choice. **The tabula sets doctrine; Orbo reports it.** Same fact, two faces, neither doing the other's
job.

#### What a doctrine preset is, and what the control looks like

Six places where the math cannot proceed until a school is picked — all six already in `state.doctrine`
as of v0.86, four of them with no UI: **sect rule** (Ptolemaic vs. mainstream Hellenistic Fortune) ·
**lot source** (Ptolemy / Valens / Dorotheus / Paulus / al-Bīrūnī) · **ZR starting lot** (Spirit or
Fortune) · **peak definition** (classical vs. Brennan) · **profection year-start** (birthday / solar
return / discrete-12) · **progressed-angle method** (Naibod / quotidian / solar arc).

These are a category, not just more settings: **they change what the instrument says is true.** Same
chart, same depth, different answer — Naibod and quotidian differ by ~178° on one progressed MC.

**"Preset" must become literal.** Today it is six independent fields. The control is a list of named
schools; picking one resolves all six at once:

```
PTOLEMY                 sect: Ptolemaic · lots: Ptolemy · ZR from: Spirit
VALENS                  peak: classical · year: birthday · angles: Naibod
PAULUS
TRADITIONAL + MODERN    ← engraved (default)
CUSTOM                  (appears only once you deviate)
```

School on the item edge, the six resolved fields in the description field, any single field openable to
override — which flips the selection to **CUSTOM** rather than leaving you inside a name it no longer
matches. Six dropdowns is a settings screen; a plate you choose is an instrument.

**Which is why ♑ doctrine is the spread's best first customer** — better than ♐. Its description field
genuinely wants to be a resolved-values readout rather than prose, so it exercises the layout's harder
half immediately, and it is the one section whose content is fully specified before the layout exists.

**Sequencing consequence:** do NOT build a doctrine UI ahead of the spread. It would be a rectangular
settings panel the tabula overhaul immediately rebuilds. The tabula overhaul is not a separate later
phase — it *is* C2, and should absorb the rest of the twelve rather than duplicate the work.

**Open for `[O]`:** whether **rulership mode** (`traditional+modern | traditional | modern`) is a
seventh doctrine field or something more fundamental than a swappable school — it was decided from the
native's own chart and reads as a property of the instrument, not a preset.

#### SETTLED 2026-07-28: doctrine is an Orbo menu **profile switch**

The native's ruling, closing the whole ♑-vs-Orbo question: **doctrine lives in the Orbo menu as a
profile switch.** Not a ♑ section, not a tabula spread instance, not the engraving. ♑ Gears keeps
motion and mechanism only (play speed, rim gearing, snap magnetism, the arc slider's home).

Which means the L2 credits line and the L3 clockwork both sit in Orbo's panel, alongside the depth
dial they are gated by — one place, one gate, no surface configured from elsewhere. Everything in
the reversal below still holds; this is where it lands.

Consequence for C2: **the tabula spread's first customer is ♏ Timing**, not a doctrine section that
no longer exists. The 2026-07-28 pane screenshots make ♏ the measured worst offender anyway.

#### The depth ladder owns doctrine *(the reversal — 2026-07-28, late)*

Two new facts arrived and both cut the same way.

**Fact 1 — `uploads/Orbo Traditions.md`: there are no six schools.** They are six authors preserving
different slices of one machine, and selecting one as a global default would silently move bounds,
triplicity rulers, lots, Fortune direction, house treatment and timing *at once*. The radio-of-authors
design is dead. What replaces it is **one default profile assembled from several traditions, each
component carrying its own provenance** — *Ptolemaic in physics, Valensian in time, Dorothean in
judgment, Paulus in grammar, al-Bīrūnī in scholarship, Firmicus in the archives.* Named:
**Orbo Classical Field**. And note what this does to "CUSTOM": my preset design treated deviation as a
fallen state, but the default *is* an assembly — there is no pure profile to fall from, so CUSTOM is
meaningless.

**Fact 2 — the native's rule: the options must not exist at L1.** Which makes ♑ untenable on its own
terms. A ♑ section whose contents appear and vanish according to a dial in *Orbo's* panel is a surface
configured from elsewhere. In Orbo's panel the dial and what it opens sit together, and "turn it down
and the clockwork isn't there" is exactly how `_atDepth` already behaves (rows **removed**, never
annotated-and-hidden).

**And the herald objection dissolves.** *"Orbo is the herald, not the authority"* was aimed at choosing
a school — that is authority. Disclosing provenance is his L3 voice register verbatim (*names the
framework at L2, names the source at L3*). Citation was always his job.

**So: doctrine is the tail of the depth ladder, not a settings screen.** One continuous descent — depth
answers *how far down*, doctrine answers *along which road*:

| rung | doctrine surface |
|---|---|
| **L1** | nothing. No profile, no provenance, no doors. |
| **L2** | the profile **named and stated, read-only** — *Orbo Classical Field · Ptolemaic in physics, Valensian in time, Dorothean in judgment, Paulus in grammar.* You learn the instrument has a lineage; nothing to change. |
| **L3** | the clockwork opens — each component, its current source, its alternates. |

This is the same three-kinds split as the first pass, now with a *reason* for the split rather than my
hand-wave: the credits **are** L2, the settable components **are** L3.

#### There is probably no doctrine section at all — the lineage label IS the door

If components exist only at L3, and at L3 every derived row already carries its lineage label, then
**make the label the door.** Tap *“Egyptian bounds”* where it appears under a bound-ruler reading and
get that one component and its alternate. Doctrine becomes reachable from where it was *used*, never a
list you visit and configure blind.

Three things this buys: Orbo's panel stays small (the dial and the profile name, nothing more — no
eight-row settings list bolted to his voice) · the L1 rule is satisfied **structurally**, since no
lineage labels at L1 means no doors at L1, nothing to gate · and it is literally him pointing at the
instrument instead of holding a control panel.

#### The three kinds, restated against the traditions doc

**Settable (changes the numbers, L3):** bounds — Egyptian *(default)* / Ptolemaic · triplicity scheme —
Dorothean three-ruler *(default)* / Ptolemaic · Fortune–Spirit direction — sect-reversed *(default)* /
Ptolemaic unreversed · lot framework extent — Hermetic seven + historically important Valens lots
*(default)*, al-Bīrūnī's catalog behind the library · ZR starting lot · peak definition · profection
year-start · progressed-angle method.

**Stated, not settable (the credits, L2):** Ptolemy in physics · Dorotheus in judgment · Paulus in
grammar · al-Bīrūnī in scholarship. Nothing computes differently if you "change" these. **A row that
does nothing when tapped is the worst affordance in the app** — do not build them as rows.

**A source you invoke, not a setting (L3):** Firmicus's delineation archive. Mechanically it is the same
shape as the existing DPA corpus — `packs/`, ingested, bylined — so reusing the pack machinery costs
nothing. What to drop is the *commerce* framing: user-facing it is not something you install, it is **a
voice you can ask Orbo to read in**, which makes it L3 by the same rule as everything else, and it is
the byline law's real customer.

**al-Bīrūnī is neither a pack nor a component.** He is the citation layer itself — provenance, variant
formulas, *traditions disagree here* — and that layer **already shipped in v0.86 as the L3 lineage
labels.** Naming him is a naming, not a build.

#### Pulled out of doctrine before it hides in a row

- **The angular-strength overlay** — whole-sign for topics, ASC/DSC and MC/IC degrees as horizon and
  meridian vectors, angular proximity as an *independent intensity* measurement. This is new math and
  belongs to **Phase 8**, not a doctrine toggle. It is also unusually aligned with the native's premise:
  *the house tells us where the energy expresses; the angle tells us how forcefully it enters observable
  life.*
- **"Warnings when traditions disagree"** — a real feature (when an alternate would change a value you
  are currently looking at, say so), but downstream of all of the above existing. Backlog.

#### Schema caution

`state.doctrine`'s six fields were chosen against the dead preset model; the component list above is
different and larger. `_doctrineKey()` feeds memo keys **and** lineage fingerprints, so the schema change
needs the same additive migration discipline v0.86 used for the legacy `zrLot` / `zrPeak` mirrors — new
fields read through a fallback and get a *correct* key on their first render, not the default one after
the next write.

#### Consequences accepted

- **♑ is motion and gearing only** — play speed, rim gearing, snap magnetism, the arc slider's home.
  Cleaner than either earlier version.
- **"Valens is the engraved default" is superseded.** The default is the assembled profile; Valens is
  only its time-lord component. (The 7/28 lot roster still tells us the native's *taste*, which is why
  Valens holds the timing seat.)
- **Rulership mode sits outside the assembly.** The traditions doc is entirely traditional; modern
  rulership is not in the corpus. `traditional+modern` is a post-1930 overlay **on** the profile, not a
  row inside it — which is what the native already said from his own chart. **Answers open question 5.**
- **Nothing doctrinal is engraved.** See the difficulty-level note below.

---

## Depth is a difficulty level — the orientation question *(native, 2026-07-28)*

The native's frame: **these are a video game's difficulty levels.** Not something to remind the player
of, so **no profile statement on the engraving** — the L2 credits line lives in Orbo's panel, in his
voice, or nowhere. The engraving stays the chart.

And the seed is a real question in orientation, which had been cut. Reinstate it. The native's draft:

> **How interested are you in astrology?**
> · **Very interested** — *Mercury conjunct your natal Saturn: communications*
> · **Interested** — *Mercury is affecting your house of self*
> · **Not very** — *it's gonna be a rough week*
>
> One phrase, three ways. The advice underneath all three: **don't buy tech for the next week.**
> No wrong choice. No need to hurry.

**Why this is the right question and not the tour/explore proxy v0.86 seeds from:** the three options
*are* the three registers. It demonstrates rather than describes, so the player picks by recognizing
which sentence they'd rather be told — which is the only reliable signal, and it retires the
"familiarity question" the v0.86 notes deliberately left uninvented. `depthSeeded` still retires on any
manual pick.

**⚠ One law clarification this forces — depth has TWO mechanisms and they must not be conflated.**

| | mechanism | v0.86 door |
|---|---|---|
| **the instrument's rows** | rows are **filtered** by inference distance | `_atDepth(rows)` |
| **Orbo's voice** | same conclusion, different amount of named machinery | his per-level voice rule |

*"It's gonna be a rough week"* is **not** an L1 row — by inference distance it is *further* from the sky
than "Mercury conjunct Saturn," it merely hides the work. It is L1 **voice**. So: at L1 Orbo may state a
conclusion plainly, and the guardrail is that v0.86 made the honesty line **unconditional** — *computed
symbolism, faithfully traditional; not validated prediction* — precisely so hiding the derivation never
becomes overclaiming it. A row filter and a register are one dial with two mechanisms; a producer that
confuses them will leak an interpretation into the ledger.

The script itself needs a rewrite pass (`[O]`, native's note) — the draft above is the shape, not the
copy.

#### The depth slot

With Phase 2 in, the depth slot is real: header/subheader take `{rank, lineage}`, the description field
takes an `_atDepth`-filtered row list, and **L3 rows render their lineage on their own row** (v0.86's
step 3 law — `lin` renders whenever its row renders, never behind a separate depth flag). The honesty
line is unconditional now, so the spread's footer carries it always.

Three quick strikes from the 7/26 list are the same edit as this spread and should ride along rather
than be scheduled separately: ♍'s five-aspect buttons overlapping the orb slider, ♎'s overlapping chart
+ lower panel, ♐'s "show on timeline" overlapping the transits.

### 6 · The occulter

`pane.occulter = { id, needs, surface, render }`, one at a time, default the lunar pane. Proven by
moving the **cold open** onto it — a non-moon surface, already staged by Phase 0b's `--instr-op`
handoff, where "the instrument's light arrives as the occulter withdraws" is the real choreography.

The brass-stays-brass constraint is enforced by the registration shape: silver palette and the
moonlight depth ladder key off `surface === 'moon'`, never off "is rising". Fused layer —
`_fuse('occulter', …)`; it fails, `_eclipse` sits at 0, the plate keeps drawing.

I'd keep the maker's side *out* of this step even though it is the harder test of the constraint: it is
the one surface where a mistake dissolves the sun/moon law visibly. Move it after E, deliberately.

### 7 · E, cohesion

Inventory first (six inventions of one material: pane body, sub-arc pills, "how to play" tab ~1102,
mark/calendar sheets ~964/978, ♒ pin strip ~897, `sheetTab` ~1016). One glass recipe derived from A's
ramp — a function returning the same literal, per inline-styles-only — and one limb-light direction
constant consumed by pane edge, chip borders and rim.

---

## Cross-phase notes from the 2026-07-28 review

### The pill buttons are out (system-wide, `[O]`)

Native's note: *"I hate the pill buttons."* This upgrades the 7/26 file's soft general note (*more
circles, more glyphs, fewer rectangular buttons*) into a rule with a replacement grammar, so the sweep
has something to sweep *toward*:

| Kind of thing | Was | Becomes |
|---|---|---|
| a **verb** (pin, swap, flip, play, mark) | pill chip with text | a glyph in the round \u2014 rune, no label |
| **navigation** (open a lens, a tabula row) | pill | text with a hairline rule, the row *is* the target |
| a **choice among few** (2\u20133 options) | pill group | segmented ring / arc slider (step 8), or glyph row |
| a **container** | rounded rect | the rimmed box (C1) or the dome |

The five `+ Pin to Moon pane` chips are the first five casualties and they go in step 2 regardless.
Beyond them the pill inventory to sweep in E: the seat cards' rounded rects, the \u2650 "show on timeline"
chip, \u264d's five aspect buttons, the ZR level chips, and the onboarding's two "Show me around / Let me
explore" buttons \u2014 the last of which I'd leave alone, since a first-run either/or is the one place a
labelled button is honest.

### Teaching the rune \u2014 four teachers, no tutorial copy

The rune means **something has come up in front of the sky.** My recommendation is to teach it with the
instrument rather than with words, in this order of load-bearing-ness:

1. **The button performs the pane's rise.** Tap it and the far disc rises in the glyph *on the same
   spring, in the same moment* as the pane rises behind it. Cause and effect in one gesture \u2014 this is
   the actual teacher and it is already in the component spec. Everything else is backup.
2. **The destination wears the same rune.** The pane's header carries the glyph you just tapped. You
   learn where it went by seeing it there. Zero copy, and it is the one argument for a rune *family*
   later (each moon view wearing its own), which stays deferred.
3. **A label that retires.** On first encounter the rune sits beside its word; after the first
   successful pin the word never returns. Training wheels, not chrome. Persist the flag with the
   session, so a returning native isn't re-taught.
4. **Hold any glyph and Orbo names it** \u2014 as a *system-wide* rule, not a rune special case. This is the
   same door as Phase 4's "tap Orbo = contextual help anywhere," and it means no glyph in the app is
   ever a dead end. Cheapest possible glossary.

What I would **not** do: have Orbo interrupt to explain it. He is the herald; a herald who narrates
every button becomes a tooltip.

**Size \u2014 the rune gets smaller.** Per the native. Split the two numbers that the 7/28 spec conflated:
the **drawn glyph goes to ~15px**, the **touch target stays 44px** and invisible. That also answers the
open row-rhythm question by itself \u2014 a 15px glyph sits inside a line of text without breaking the row,
so the rune goes *in* the row and the row does not grow.

### The native is a Valens guy \u2014 consequences

From the AstroGold extra-points roster supplied 2026-07-28
(`uploads/Screenshot 2026-07-28 at 5.15.58 PM.png`, `\u2026 5.16.19 PM.png`): Spirit \u00b7 Victory \u00b7 Eros \u00b7
Courage \u00b7 Nemesis \u00b7 Foundation (Valens) \u00b7 Cupid/Eros (Firmicus) \u00b7 Accusation (Valens) \u00b7 Exaltation
(Valens) [N] and [D] \u00b7 Necessity (Valens) \u00b7 Marriage of Men / of Women / of Men & \u2026 (Hermes) \u00b7
Intercourse (Men) / (Women) \u00b7 Fame (Positive) \u00b7 Ancestors \u00b7 Eros (Valens) \u00b7 Daimon \u00b7 Cupid/Eros
(Paulus) \u00b7 **Sappho \u00b7 Nemesis \u00b7 Hera**.

Three things fall out:

1. **The engraved default preset is Valens**, not `traditional+modern` (which is the *rulership* default
   and a separate axis). Lot source: Valens \u00b7 ZR from Spirit. Revises \u00a7 5's proposal.
2. **The list is the argument for the preset.** *Eros* appears three times \u2014 Valens, Firmicus, Paulus \u2014
   and *Cupid/Eros* twice. A checkbox library has to show all three and make you adjudicate; with Valens
   engraved, **"Eros" means Valens's Eros** and the other two only surface if you go looking. That is
   what collapses the 97-lot census from a list into a library, exactly as the 7/26 plan requires
   (*"a library, not a feature \u2014 it never goes on screen as a list"*). The AstroGold screenshots are the
   anti-pattern to design against, not the target.
3. **The last three are not lots.** Sappho, Nemesis-the-asteroid and Hera are bodies. Which is why \u264a
   Gemini's center should read **"planets, objects and points"** \u2014 native's note, and it is the correct
   generalization: *lots* is a subset of *points*, and asteroids are objects. Retitle it and drop "lots"
   as the section name. Belongs with the existing \u264a quick strike (stack the three groups in the center,
   drop the domicile note, bigger object icons).

## Questions I still need answered

1. ~~Rune scope~~ — **answered 2026-07-28: one lunar rune only**; more get designed if needed.
2. ~~Contrast floor~~ — **answered: judge on device.** I build C1's panel, export a standalone, you judge.
3. ~~Settings homes~~ — **settled 2026-07-28**, see § 5. All gears live in ♑; depth stays with Orbo; the
   "back" as a separate maker's surface does not exist.
4. ~~Unclosed `sc-if`~~ — **fixed 2026-07-28** ahead of step 3. `orboOn` now closes after Orbo's canvas
   wrapper; it had been swallowing the entire instrument column. Snapshot:
   `archive/Orbo Astrolabe 2026-07-28e.dc.html`.

### Still open before I start

5. ~~Rulership mode's status~~ — **answered by the traditions doc**: a post-1930 overlay on the profile,
   not a component inside it.
6. ~~Which named schools ship~~ — **void.** No schools ship; see the doctrine reversal in § 5. The
   default is the assembled **Orbo Classical Field** profile.
7. ~~The rune's tap target on the ZR sheet~~ — **answered by the size decision**: 15px glyph inside an
   invisible 44px target, sits in the row, row does not grow.
8. **Whether ♑ motion settings get the spread too, or stay as-is** — the arc slider (step 8) is their
   real fix, and it may not want the item-edge layout at all.
9. **Does the rune's label-that-retires need a reset?** If a native wants the words back (or you want to
   demo it), the flag needs a door — I'd hang it off Orbo's panel rather than invent a "reset tips"
   setting.

---

## Step 1 shipped, and its two follow-ups *(2026-07-28)*

The rune is mounted at the ZR site (♏ Timing), replacing the pill. Springs on the one `dt` via
`_paneTick` → `_runeSprings()` / `_runeWrite()`; the RAF is the sole writer of the far disc's `cy` and
there is no style hole for it. `_paneLensAvailable(id)` added as the single availability door so step 3
can move its body into `pane.available()` without touching a mount. `runeTaught` persisted; the word
*"etch to the pane"* retires on the first successful etch.

**Verb confirmed: etch.** Engrave = the back · pin = memory (♒) · **etch = the lunar pane.** Three
destinations, three verbs, no collision. Step 2 spreads *etch* to the other four sites.

Two defects the native caught on sight, both for C1 rather than a patch now:

1. **It reads as a padlock**, and that is geometry, not taste: a padlock is a *narrow* shackle over a
   *wide* body — which is exactly far-disc r5 rising over near-disc r6.7. Fix: far disc **equal or
   slightly larger** than the near one, and **shorten the rise**, so it reads as one body passing behind
   another. Occultation, not hardware.
2. **It takes a whole line.** The 44px `min-height` reserves layout. The touch target must **overflow**
   its neighbours instead of pushing them apart — ~15px glyph box in flow, hit area expanding past it.
   Belongs with C1's formatting pass, alongside the two peak **pills** sitting directly beneath it.


## Step 3 shipped — the ladder, all three sub-moves *(2026-07-28, v0.866)*

Snapshot before the resolver: `archive/Orbo Astrolabe 2026-07-28g.dc.html`.

**(a) stops** — `_paneStops()` is the one geometry door (gone · peek · facts · eclipse), memoized and
invalidated in `_size()`; `_eclipseTranslate`/`_eYCache` collapsed in behind it. Still deliberately
offsetParent-derived rather than `_box()`-derived — see the note in the source; that re-derivation
MOVES the eclipse rest on a notched device and wants device eyes, not a refactor.

**(b) resolver** — `_paneNeeds()` + `_paneLadder()`. The sheet declares `'raised' | 'pager' | 'facts'`;
the ladder resolves `{ stops, needs, eclipseAvail, stop, reason, y, top, base }`. `flipped` and
"no sheet" are *reasons*; `_eReadLen > 0 || _raisedLens` is retired as a predicate re-spelled at three
handlers; the dead `this._eGeo` mirror is gone. `_paneTick`, the three drag handlers and `_shadeTick`
all read the resolution. Behaviour-identical by construction.

**(c) rubber band** — `_paneRubber(v, lo, hi)` with `_paneBand(x) = B·(1 − e^(−x/B))`, B = 46px. 1:1 at
contact (no kink), asymptotic give past either limit, replacing the hard clamp (`min(peek+30, max(top, …))`).
The point is legibility: a dead stop can't be told apart from a broken gesture, and an *unavailable*
eclipse rest now feels like a taut band. Release path untouched — `spr.v = spr.vHint`, then the
resolved rest reels it back in.

### What's left in Phase 3
4 · C1 rimmed content box — the plate is seated (v0.865) and C1b collapsed the three ledger blocks
into one; the contrast floor is still an **on-device judgement** (v0.866 standalone is the artifact).
Then 5 · C2 tabula spread (first customer ♏ Timing) · 6 · occulter · 7 · cohesion sweep · 8 · arc slider.
Open question 8 (does ♑ motion want the spread at all) is still the gate on C2's scope.


## C2 · the tabula spread, as built *(2026-07-28, v0.869 — ♏ Timing first)*

The first attempt kept the items *inside* the 175px well as a list of rows and squeezed the
description under them. Wrong: a reframe that inherits the porthole isn't a reframe. **The items
belong to the plate; the well is the field.**

### The template (apply verbatim to the other eleven)

1. **The item band** — one FIXED arc for every tabula: the top of the inner disc, `mid = 90°`
   (the frame's top; angle grows counter-clockwise, so the fan is *subtracted* to read left→right),
   `span = 27°`, `r = 28` via `_ringLT` — the same chip band ♊ and ♍ already use. The discs land
   just OUTSIDE the well; only their labels reach into its top margin (hence the field's 20px
   top pad). ≤6 items. Fanning about each tabula's *own* angle was tried and rejected: the field
   then dodges a different side per tabula, which is the opposite of a template.
2. **The field** — the whole well, `height:100%`, column, `justify-content:center`. No header row
   and no ×: the tabula's name is lit on the rim and re-tapping it closes, and the selected chip's
   label is the title (printing it again 40px lower was the tell that it was chrome). 11px prose,
   1.6, `text-wrap:pretty`.
3. **The verbs, in the round, at the foot** — the item's own glyph in a 32px disc (open the reading
   on the pane) and ONE rune bound to the selected item (etch). Not one rune per lens.
4. **Doctrine via the lineage label** — L3 only, under a hairline: *"Peaks read against the natal
   angles — tap for the Lot's own angles (Brennan)."* Tapping flips the component where it was
   used. At L1/L2 no label renders, so there is nothing to gate.
5. **Chip states** — selected: gold rim + gold glyph + 12px gold glow · pinned to the pane: half-gold
   rim · plain: silver hairline · unavailable: opacity 0.35.

Registry: `tabSpreadOn: ['releasing'].includes(s.panel)` — each tabula joins by id as it is reframed.
Contract keys: `tabChips · tabDesc · tabReady/tabBlocked/tabBlockedNote · tabOpen/tabOpenGlyph ·
tabRune* · tabLineage*`. One door for opening a lens: `_openTabLens(id)`.

Retired by this: ♏'s five rectangular buttons, its three separate pin chips, its two peak pills,
and its panel header row.

**Also added:** `window.__orbo` in `componentDidMount` (try/caught). The back face is only reachable
by a rim double-tap, which synthetic pointer events don't reproduce, so every visual check of a
tabula was blind. `__orbo.setState({flipped:true, panel:'releasing', tabSel:'zr', depth:'scholarly'})`
is now the review path.

### Open question 8, restated by this build
♑ motion's controls are sliders and toggles, not items with descriptions — the spread's item band
fits a tabula whose contents are *nameable things*. ♐ Almanac (streams) and ♎ Ledger (people) fit;
♑ probably wants the arc slider instead. Decide after ♐ is reframed.


## C2 v2 — the socket ring *(2026-07-29, v0.870)*
The chip-band version (v0.869) is superseded. The back now reads as concentric label rings: the
twelve tabulae outside, the open tabula's items on a **socket ring** just inside them, in the same
arced Georgia. Twelve sockets, filled ones centred on the top, the rest empty with a centre dot —
the native's read: *a skill tree; it makes me wonder what appears in those spaces next.*

Field: icon (open) fixed on top, rune (etch) fixed below, only the reading scrolling between them.
Georgia throughout — the back is engraved, the pull-up is moonlight. Engraving: fractal-noise grain,
paired hairlines (shadow + lit stroke), incised type shadows, sockets as recesses with the selected
one gold-filled.

Registered: ♏ Timing (Releasing · Windows · Rising) and ♓ Composite (Moment · Chronicle · Synastry,
the last two carrying their own controls in the field). Everything else keeps its body — see the
CLAUDE.md entry for which and why. Ring labels are capped at ~11 characters, which is what rules the
rosters (♎ ♒ ♐) out of the ring rather than out of the spread.


## Phase 3 closed — the spread complete + the dock law *(2026-07-29, v0.875)*
Snapshot of the v0.870 state: `archive/Orbo Astrolabe 2026-07-29.dc.html`.

**All eight registrable tabulae are on the spread**, in the three kinds the socket ring turned out to
need (the answer to open question 8, which the C2 v2 note left for "after ♐ is reframed"):
- `item` — the socket picks WHAT YOU READ, field is a glossary entry with two verbs: ♏ Timing,
  ♓ Composite, ♐ Almanac.
- `mode` — the socket picks WHAT THE FIELD CONFIGURES, no verbs, one control at a time: ♊ Bodies,
  ♍ Aspects, ♑ Gears. ♑ did NOT want the arc slider; it wanted four sockets and one control each,
  which is the same answer with less invention.
- `sort` — the socket picks HOW A ROSTER IS CUT, the tabula keeps its own body because a socket label
  holds about eight characters and cannot hold a person's name: ♎ Ledger, ♒ Archive.

Unregistered deliberately: the forms (♈ ♉), ♌ Appearance, ♋ Moon.

**Two corrections to the C2 v2 note above.** Ring labels cap at ~8 characters, not 11 (past that a
curved label overruns its 30° socket). Empty sockets carry no centre dot: the recess alone says a seat
is open, and they are inert and unmarked.

**The bottom socket is always AEGIS**, the way back to the face, which retired the floating ⟲ front
button that the ♊ and ♍ chip rings used to displace entirely.

**The dock law** (see CLAUDE.md) is the doctrine this build produced: *open* is not *etch*. ♐ used to
force-etch on the way in, which made it the one lens you could not look at without keeping it.
Un-etching happens at the dock, a 520ms hold on an etched chip at the pane's crown.

### Carried forward out of Phase 3
- **Step 6 · the occulter** — `pane.occulter = { id, needs, surface, render }`. Not built. The plan
  already argued for moving it late; it now moves out of the phase.
- **Step 7 · E, cohesion** — the pill-button sweep `[O]` is not done system-wide.
