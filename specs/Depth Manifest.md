# The Depth Manifest — Phase 2

*Every readout row in Orbo, ranked L1 / L2 / L3, with the lineage label each L3 row must carry.
Companion to `specs/Orbo Plan 2026-07-26.md` (the depth law) and the co-rulership law.
Written 2026-07-28, before ingest, so the DPA generator can emit depth + lineage in one pass.*

---

## 1 · The law, restated

Depth is **inference distance from the sky**, not three levels of jargon.

- **L1 — what is.** Positional. Confirmable by looking up. No doctrine.
- **L2 — what it belongs to.** One step of classical framework, resting only on commitments already
  made instrument-wide: tropical zodiac, whole-sign houses, traditional rulers (+ named co-ruler).
- **L3 — what it derives.** Constructed points and chains. **May never render without its lineage label.**

**The test:** if a readout requires you to pick a school, it is L3.

### The ladder is cumulative, and additive-only

**Each level is a superset of the one below.** L3 shows L1 + L2 + L3; L2 shows L1 + L2. A row's rank is
the **threshold at which it first appears**, not a bucket it belongs to — the filter is `depth <=
maxDepth`, never `===`. The acceptance test says it plainly: *L1 = Sun, sign, degree · L2 = **+** house
· L3 = **+** dispositor.*

**No row may supersede another.** Turning the dial up only ever *adds* rows; it never rewrites or
replaces one already on screen. If a simpler phrasing of the same fact is ever wanted at L1, it must be
its own row that stays visible at L3 too — never the same fact stated twice, differently, at different
levels. Two versions of one truth is how a reading starts contradicting itself, and it would make the
dial feel like a mode switch instead of a depth of field.

*(Field naming: `depth` is kept for continuity with the persisted `state.depth`, but read it as
“floor” — the level from which this row is visible.)*

### Two contradictions in the source plan, resolved here

The plan's law-paragraph and its acceptance test disagree twice. Both resolve the same way — by the
plan's own test.

**a · Void-of-course.** Listed L2 in the law paragraph, stated L3 in the acceptance test. VoC requires
choosing a definition (Lilly vs. modern), and `depthSrc` already cites "Lilly VoC" — by the school test
it is **L3**. The L2 listing is the error.

**b · Dispositor.** "Domicile ruler" is L2 in the law; "L3 = + dispositor" in the acceptance test.
These are two different readouts and the manifest separates them:

| Readout | Rank | Why |
|---|---|---|
| *Scorpio's lord is Mars (with Pluto)* | **L2** | one step, no chain, no school beyond the standing commitment |
| *dispositor: ♂ Mars in Capricorn* | **L3** | the first link of a chain — it points off the body at another placement |
| *final dispositor / chain / mutual reception* | **L3** | the chain itself |

This is also what makes the acceptance test come out right: **L1 = Sun, sign, degree · L2 = + house
· L3 = + dispositor.**

### The inheritance rule (new — derived while reading the DPA corpus)

**An explanation inherits the depth of the thing it explains.** "What is a natal chart?" is L1 because
a natal chart is L1. "What is a progressed chart?" is L3 because progressions are L3. This makes the
term ladder in §4 derivable from the row manifest in §3 rather than a second act of judgement, and it
keeps Orbo's voice automatically in sync with the dial.

---

## 2 · The contract

Rows grow two optional fields: `{ k, v, d, lin }` — `d` = 1|2|3, `lin` = lineage string.

- **Absent `d` means L1.** Nothing disappears mid-build; the manifest can land producer by producer.
- One accessor `_depthRank()` → `1|2|3` (maps the persisted `plain|studied|scholarly`, no migration).
  It already exists at 5415, scoped to Orbo's Ask — **promote it, do not add a second `_depth()`.**
  Two accessors for one dial is how the six scattered checks happened in the first place.
- One filter door `_atDepth(rows)`. **It filters** *(decided 2026-07-28)* — rows above the current rank
  are removed, not annotated-and-hidden. Simpler, and it means no producer can leak an L3 value into
  the DOM where a screenshot or an export would pick it up.
- The six existing ad-hoc `!== 'plain'` checks collapse into it (2929, 3166, 3168, 3427, 3828/3854).
- **`lin` renders whenever its row renders** — not only at scholarly, which is what `depthScholarly`
  does today (1270, 1324, 1473). `depthSrc` survives, demoted to the sheet-level honesty line.

### Where the dial lives — with Orbo

*(decided 2026-07-28, superseding the ♑ placement in `Orbo Plan 2026-07-26`.)*

Depth is **how Orbo speaks**, so the control belongs to him, next to the doctrine presets. Two paths,
one value:

1. **Orientation seeds it.** Orbo asks the native how familiar they are with astrology and sets the
   level from their answer. The native never meets the words *plain / studied / scholarly* first — they
   answer a human question about themselves. (The ♒ glossary already promises exactly this: *"onboarding
   just seeds the default."*)
2. **Orbo changes it.** Thereafter it lives in his menu — ask him to speak more plainly, or deeper.

So the chips leave ♋ (template 447–451, inside `pMoon`) and land with Orbo — **not** ♑, which was the
earlier plan. ♑ is behaviour; this is voice. Consequence for the flow: the answer copy must read as
self-description ("I'm just starting out" / "I know my chart" / "I read traditionally"), never as a
technical tier, and Orbo should be able to say which level he's speaking at when asked.

---

## 3 · The row manifest

Ranks are per row. Line numbers are `Orbo Astrolabe.dc.html` at time of writing.

### `_signifRows` (6644) — the live body reading

| Row | Rank | Lineage |
|---|---|---|
| `sign` (name · element) | **L1** | — |
| `house` (n · whole sign) | **L2** | — |
| `dignity` (domicile/exalt/detriment/fall/peregrine) | **L2** | — |
| `ruler` *(new — the sign's lord, both when co-ruled)* | **L2** | — |
| `dispositor` (lord's own placement) | **L3** | traditional domicile rulers · classical disposition |
| `rules houses` | **L3** | whole-sign houses · traditional rulers (+ modern co-ruler where named) |
| *co-ruler rationale* | **L3** | modern rulership · post-1930 attribution |

The `ruler` row is a **split-out of what `dispositor` currently conflates**, and it is what the
co-rulership law needs: at L2 a Scorpio rising reads *Mars · with Pluto* without yet being sent off to
Capricorn. Same split applies to `_sheetDataNatal` (5817) and `_sheetDataCompositeBody` (5704).

### `_motionRows` (6671) · `_natalMotionRows` (5844)

| Row | Rank | Lineage |
|---|---|---|
| `motion` (°/day · direct/℞ · fast/slow) | **L1** | — |
| `entered {sign}` / `enters {sign}` | **L1** | — |
| `turned ℞` / `next station` | **L1** | — |
| `note` (derived point — moves with the Ascendant) | **L2** | — |

All L1: these are ephemeris facts. Speed class (fast/average/slow) is a comparison against the body's
own mean, not a doctrine.

### `_specRows` (4482) — the pane ledger columns

| Column | Rank | Lineage |
|---|---|---|
| BODY · glyph · sign · degree | **L1** | — |
| HSE (whole sign) | **L2** | — |
| DISPOSITOR | **L3** | traditional domicile rulers · classical disposition |

At L1 the ledger is two columns. This is the single most visible depth effect in the app and the best
early proof — Phase 3C's rimmed content box has to accommodate a column count that changes with depth.

### Aspects — `_aspectListFor` (6617) · `_toYouList` · `_transitsToNatal` · `_natalAspectList`

| Row / field | Rank | Lineage |
|---|---|---|
| the pair, the aspect, the orb | **L1** | — |
| exact hit date (transit rows) | **L1** | — |
| applying / separating / standing | **L2** | — |
| harmony (soft/hard colouring) | **L2** | — |
| gloss (the interpretive sentence) | **L2** | — |
| same-body doubled-orb note (synchronic synastry) | **L3** | synchronic synastry · same-body separations are time-invariant |

**Aspects themselves are not depth-dependent** *(decided 2026-07-28: "depth is about complexity of
concepts")*. Which aspects are drawn and listed — majors, minors, the seven harmonics — is a **display
choice**, owned by the ♍ toggles alone. A septile is not a harder *idea* than a trine; it is a
narrower one. So no aspect row is gated by rank: if the toggle is on, the row renders at every depth.

What remains ranked here is the *conceptual overlay* on a row — applying/separating, harmony, the
gloss, the time-invariance note. Those are ways of thinking about a contact, and they ladder.

*(Superseded: an earlier draft ranked the seven harmonic minors L3 and leaned on their coinciding
exactly with the seven DPA does not cover. Tidy, but it made depth do a toggle's job — and it would
have hidden a row the native had explicitly switched on, which no depth rule may ever do.)*

### ♋ Moon — `_moonReadout` (6811) · `_vocData` · `_mansionOf` (6757)

| Row | Rank | Lineage |
|---|---|---|
| phase · illumination % | **L1** | — |
| sign · degree | **L1** | — |
| next ingress | **L1** | — |
| sect (day/night Moon) | **L2** | — |
| void-of-course | **L3** | void-of-course per Lilly, *Christian Astrology* |
| lunar mansion | **L3** | 28 mansions · fixed 12°51′26″ from 0° Aries |

This is the ♋ complaint from the 7/25 notes answered directly: at L1 the Moon panel is phase, sign,
next ingress. Nothing else.

### ♏ Timing — ZR (`_zrData`, `_sheetDataZr`) · Rising Lord (`_sheetDataRising`) · Election (`_sheetDataElection`)

| Row | Rank | Lineage |
|---|---|---|
| ZR L1 period (sign · dates) | **L3** | zodiacal releasing · Valens, *Anthology* IV · from {lot} |
| ZR L2–L4 sub-periods | **L3** | *as above* · sub-periods |
| peak / `LB` loosing of the bond | **L3** | *as above* · peak definition: {peak \| Brennan peak} |
| rising-lord window (time · lord · sign) | **L2** | — |
| rising-lord rotating whole-sign house | **L2** | — |
| condition badge (dignity state) | **L3** | essential dignity · Lilly points |
| election score | **L3** | Lilly dignity points · Egyptian bounds · Chaldean faces · Dorotheus Book V |
| election `top` factors | **L3** | *as above* |
| election `drv` derivation trace | **L3** | *as above* |

**ZR is L3 in its entirety** — it cannot be pointwise-evaluated, it is unspooled from a lot, and its
period lengths change with the peak-definition preset. The whole releasing lens simply does not exist
at L1/L2; it is a pinned lens already, so this costs nothing at the default depth.

**The rising lord is the exception worth noting:** *which sign is rising now and who rules it* is one
step from the sky (L2). Only its **condition** is scored, and only that is L3.

### Lots · profections · progressions (Phase 8, ranked now so the engines ship tagged)

| Row | Rank | Lineage |
|---|---|---|
| Fortune, Spirit | **L2** | sect-reversed per {sect rule} |
| every other lot | **L3** | Lot of {name} · {Ptolemy \| Valens \| Dorotheus \| Paulus \| al-Bīrūnī} |
| annual profection + lord of the year | **L2** | — |
| monthly / daily profections | **L3** | {discrete-12 \| solar-ingress \| Ptolemy 28d} · {Ptolemy 2⅓ \| Paulus 1} |
| progressed Sun / Moon | **L3** | secondary progressions · day-for-a-year |
| progressed angles | **L3** | **{Naibod \| quotidian \| solar arc}** — mandatory, 178° divergence |

### Composites — `_sheetDataCompositeBody` (5704) · synastry · cross

| Row | Rank | Lineage |
|---|---|---|
| composite sign · degree | **L1** | — |
| composite house (from cASC) | **L2** | — |
| grammar label ⟨left⟩ × ⟨right⟩ · ⟨how⟩ | **L1** | — |
| composite sect | **L3** | sect from the cASC horizon axis · flips ~2×/day when synchronic |
| composite chronology frame | **L3** | same-ascendant scan · not progression |
| progressed composite | **L3** | prog(A) ⊕ prog(B) · never Davison |

### Ticker & instrument (`_readouts`) — L1 throughout

Big Three signs, date, time, location, the ASC degree. The instrument states where things are; that is
its whole job. **Depth never touches the plate** — sun/moon law: depth is a property of moonlight only.

### The journal — `_snapshotLines` (2361)

Currently reads depth as a *quantity* (1 / 3 / 8 contacts). Under the new law that is a category error:
volume and inference distance are different questions.

**Resolution:** the snapshot keeps all contacts it froze — a pinned record must not lose data to a dial
— but ranks them, and `_atDepth` filters. A pin taken at scholarly and read at plain shows its headline
contact, and shows all eight again when the dial moves back. Nothing is destroyed; the count follows
from the rank rather than being the rank.

---

## 4 · The term ladder (what the DPA entries inherit)

By §1's inheritance rule, each explain entry takes the depth of the thing it explains.

**L1** — the zodiac signs · elements · qualities/modalities · the 12 houses (in themselves) · the
planets and luminaries · what a natal chart is · the five major aspects · the six house axes.

**L2** — house types (angular / succedent / cadent) · rulership basics ("every sign has a lord") ·
sect · applying and separating · the semisextile and quincunx · what a composite chart is · what a
return chart is.

**L3** — house *systems* as a choice (Placidus / Koch / Equal / Whole Sign) · traditional vs. modern
rulership and why Scorpio has two lords · the contested Ceres–Taurus claim · progressed charts ·
horary · relocation · the harmonic minors.

Every entry additionally carries `doctrine: { rulers: 'modern' }` where DPA's text assumes modern
rulership, per the co-rulership law. Where the corpus and the plate disagree — Scorpio's article names
only Pluto — Orbo names the source rather than siding with either.

---

## 5 · Coverage, honestly

Gaps stay absent. No placeholders — the discipline v0.83 set for composite planet×sign.

| Layer | Covered | Absent |
|---|---|---|
| Signs | 12 / 12 + keywords omnibus | — |
| Bodies | 11 of 14 `BODY_ORDER`, + Ceres | Node · SNode · Lilith |
| Houses | 12 / 12 + 6 axes | — |
| Aspects | 7 of 14 (0 30 60 90 120 150 180) | 45° 51.43° 72° 102.86° 135° 144° 154.29° |
| Charts / FAQ | 17 sections | — |

The seven uncovered aspects have no prose in the corpus — an honest gap, and unrelated to depth now
that aspect selection belongs to the ♍ toggles. If the native switches on septiles, the rows render;
Orbo simply has nothing written to say about them yet.

### As built (2026-07-28)

47 source files → **520 explain entries**, merged into `packs/dark-pixie.pack.json`
(876 → **1,396** entries; the original placement readings are untouched).

| | |
|---|---|
| by depth | L1 **417** · L2 **93** · L3 **10** |
| by topic | sign 180 · body 146 · house 142 · intro 24 · aspect 20 · axis 8 |
| doctrine-tagged `rulers:'modern'` | 33 |
| every L3 entry carries a lineage label | ✅ asserted in test |

**Key shape:** `explain.{topic}.{subject}.{kind}` — kinds are `overview · natal · keywords ·
k.{keyword} · where · transit · strong · q.{question}`, plus `explain.axis.{n}-{m}` for the six
axes and `explain.sign.{sign}.summary` for the Keywords omnibus. Aspect docs carry an `angles`
array (60 and 120 share one article) resolved by `explainByAngle`.

**Resolver** (`packs/interp.js`, regenerated into `dark-pixie.browser.js`): `explainFor` ·
`explainAll` · `explainByAngle` · `explainSearch` (ranked, for Orbo's free text) · `hasExplain` ·
`attributionOf`. Every door takes `maxDepth`, so the dial filters the corpus at the resolver rather
than at each call site.

**Tests:** `tests/explain-corpus.test.html` — 26 assertions, including the manifest's own acceptance
test 3 (no L3 entry without lineage), the 876-reading regression, PDF-artifact cleanliness, and the
honest 72° gap.

**Depth is assigned from the section TITLE, not the body.** A body scan buried entries — "What is a
natal chart?" tagged L3 because one sentence mentions house systems. Two narrow body triggers remain,
for passages that *are* the doctrine question (the traditional-vs-modern paragraph, the Ceres claim).
**Doctrine tagging is not a depth bump:** Scorpio's article says "ruled by intense Pluto" — it carries
`rulers:'modern'` so Orbo names the source, but stays L1. Hiding Scorpio's basic description behind
scholarly depth would misread the co-rulership law.

⚠ **The lineage law passes vacuously when a technique is mis-ranked out of L3.** The first title-driven
pass used `/progressed/i`, which does not match "Progressions" — four aspect sections explaining
day-for-a-year silently fell to L1/L2, and the "every L3 has lineage" assertion still passed *because
they were no longer L3*. Caught in review, corrected to `/progress(ed|ion)/i`. The suite now carries a
second guard asserting that nothing whose title names a technique sits below L3 — an absence test, not
a presence test. **Any future depth rule needs both halves.**

⚠ **A wrong lineage is worse than a missing one.** The modern-rulership table shipped labelled
*"Ceres rulership · contested modern claim"* — asserting to the native that the modern scheme is a
contested Ceres attribution, on the single most doctrine-sensitive entry in the corpus. Two causes,
both worth remembering: the body matcher looked for "these are called the traditional rulers" while
the text says "these are the modern rulerships", so the Ceres rule won by **fallthrough** — an ordered
rule list fails silently when no rule matches and a later, looser one catches; and a hand-patch
applied to the pack but *not* to `scraps/explain-entries.json` was then reverted when the next
correction pass re-merged from the stale staging file. **Rule: staging and pack are always written
from the same pass** — never patch one and not the other. Guarded now by two assertions (modern text
never carries the Ceres label; the Ceres label appears only on the Ceres claim).

**Wired into Orbo (2026-07-28).** `_orboAnswer` now consults two corpora in a deliberate order:
a subject/title-grade **corpus** hit → the **instrument glossary** (`_orboGloss`, Orbo's own words for
Aegis / Rete / Plate / Tabula — never attributed) → a body-text-grade corpus hit → the live reading.
A passing mention can therefore never outrank an instrument term, while "moon" still answers with the
body rather than the ♋ menu. `_depthRank()` maps `plain|studied|scholarly` → 1|2|3 and gates every
lookup; `_packCite()` is the single source for the byline. The bubble renders, under the answer: the
doctrine note (when the source assumes modern rulers), the lineage label (L3), and the hyperlinked
byline.

**Gated hits are named, not swallowed.** When a strong hit sits above the native's depth, Orbo says so
and names the school it rests on — he never serves L3 prose at L2, but he never pretends the material
isn't there either. Found because "ruling planets" at *studied* silently fell through to the ♊ menu:
a worse answer delivered confidently is the failure mode a depth gate invites.

**Known parser gap (next pass):** colon-terminated headers ("Ruling planets and the natal chart:",
"A natal chart requires 3 pieces of data:") are not detected as headers, so a handful of intro
sections are merged into their neighbours. The text is present and searchable; only the sectioning is
coarse. Fix is one pattern in the generator plus a re-ingest.

**Not yet wired:** `_orboGloss()` retains its ~25 instrument definitions — correctly, they are not DPA
content. The byline law still needs applying to the eclipse tier's other pack surfaces.

---

## 6 · Acceptance tests

1. **The worked example.** A body reading at L1 = Sun · Leo · 14°22′. At L2 = + 5th house, + dignity,
   + its lord. At L3 = + dispositor placement, + rules-houses, each with lineage.
2. **Scorpio rising at the default depth (studied/L2)** reads *Mars · with Pluto* — the native's own
   chart is correct without touching the dial.
3. **No L3 row renders without `lin`.** Assertable in a test: walk every producer at depth 3 and fail
   on any `d === 3 && !lin`.
4. **♋ at L1** shows phase, sign, next ingress — no VoC, no mansion.
5. **The ledger at L1** is two columns; at L2, three.
6. **A pin frozen at scholarly, read at plain, then back** returns all eight contacts. No data loss.
7. **Nothing regresses at `studied`** — the shipped default must look approximately as it does today,
   or the manifest has mis-ranked something.
8. **No pack prose renders without its byline** — walk every surface that draws from `pack.entries`
   and fail on a missing attribution (§8).
9. **A row the native switched on is never hidden by depth.** Enable septiles at *plain*: the rows
   render. Depth gates concepts, never content the native asked for.
10. **Orientation seeds the level without naming it.** Answering Orbo's familiarity question sets
    `state.depth`; the words plain/studied/scholarly appear nowhere in that flow.

---

## 7 · Open for `[O]`

1. **`rules houses` at L3** — arguably L2 (it is one step). Ranked L3 because it is where traditional
   and modern visibly diverge, so it needs a lineage label. Reconsider if L2 feels bare.
2. **Element colour** is L1 everywhere (it drives the instrument's colour language and cannot be
   depth-gated without the wheel changing colour with the dial). Confirm that's intended.
3. **Minor aspects on the wheel** — *resolved 2026-07-28: aspect selection is not a depth matter at
   all. The ♍ toggles own it; no aspect row is rank-gated. See §3 Aspects.*

---

## 8 · Attribution — the byline law

*Decided 2026-07-28. Applies to everything the user can read that we did not write.*

**Every surface that renders prose from the interpretation pack carries a byline to The Dark Pixie
Astrology, hyperlinked to <https://www.thedarkpixieastrology.com/> wherever the surface supports a
link.**

**Single source, as now.** `pack.attribution` is already the sole owner of the name; it gains
`pack.attributionUrl`. Neither string is ever a literal in the DC — the same discipline that kept
`eclipseAttribution` honest through 876 entries.

**Scope — attribute text, never numbers.**

| Carries the byline | Does not |
|---|---|
| eclipse readings · Orbo's answers and glossary replies · the explain corpus · keyword chips drawn from DPA · any pack paragraph | computed readouts (sign, degree, house, dignity, motion, aspect, orb) · engine-derived rows (ZR periods, election scores, rising windows) · the instrument itself |

Attributing computed output to DPA would credit them with the ephemeris; leaving prose unattributed
takes credit for their writing. Both are wrong in the same way.

**Attribution is not lineage — they are different fields and must never be merged.** Lineage names the
*doctrine* a readout derives from ("Valens, *Anthology* IV"); attribution names *who wrote the words*
("The Dark Pixie Astrology"). A single row can honestly carry both — a ZR period explained in DPA prose
is Valens's technique in their sentences. One string conflating them would be a false citation.

**Placement.** One byline per surface, not per paragraph: a three-paragraph reading gets a single line
at its foot. Set in the same quiet register as `depthSrc` (8.5px, `#8478b8`), below the honesty line —
it is a credit, not a disclaimer, and it should read as a colophon rather than a legal notice.

**Where a link can't live** — canvas text, a chip, the ticker — the byline renders as plain text and the
link appears on the nearest surface that can hold one. Links open in a new tab (`rel="noopener"`); an
external URL is not an asset, so it is invisible to the bundler and survives standalone export intact.

**Orbo speaks the credit too.** When he answers from the corpus he names his source in his own voice —
the herald law already has him naming sources at L3; here he does it at every depth, because the
obligation is to the author, not to the reader's depth setting.
