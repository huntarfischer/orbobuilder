# The Interpretation Layer — Voices, Volumes & the Slot Contract
*Working plan, 2026-07-17. Status: discussion distilled — no code yet.*

## The idea
Partner with real astrologers and slot their authored interpretations into the app —
never generate them. Each partner is a **voice**; their work ships as a purchasable
**volume** (expansion pack). The Dark Pixie Astrology is the shipped default.
Precedent: the Brennan options already on ♏ Timing (lot, peak doctrine).

## Where it lives (the law)
- **Interpretation is moonlight.** A voice's prose appears only on the pull-up sheet —
  never on the instrument. The sun (geometry) stays exact and **unsigned**; the moon
  (reading) is **signed** with a byline.
- **Choosing the voice is doctrine** — a maker's-side act. Volumes are seated on the
  back, like charts are seated and natals engraved.
- The instrument's precision is never diluted: the exact geometry line (aspect, orb,
  applying/standing) always renders in the instrument's own voice, above the partner's
  prose.

---

## Back end — how it functions

### 1. The slot-key namespace (the contract — build first, freeze, version)
A stable vocabulary naming every condition the app can compute:
`sun.house.7` · `moon.sign.aries` · `natal.sun.hard.moon` · `transit.mars.hard.sun` ·
`zr.spirit.chapter.leo.L1` · profections, lots, etc.
- **Versioned and frozen** — partners author against it; keys are never renumbered.
- **Aspect families are first-class keys.** Corpora prove authors write coarse:
  Dark Pixie merges sextile+trine ("soft") and square+opposition ("hard"), and buckets
  all transit flavor into three bands (conjunction / soft / hard).
- **Canonicalization ladder:** the app computes the *exact* condition, then degrades it
  stepwise to the coarsest bucket the active pack authored
  (`transit.mars.square.sun` → `transit.mars.hard.sun`). Each pack declares its grain.

### 2. The pack (volume)
A pack = **manifest + slot tables**.
- **Manifest:** byline, bio, method note, domains covered, authored grain, coverage map,
  price/ownership tier.
- **Slot tables:** maps of slot-key → authored prose. Spreadsheets ARE the authoring
  format (the Dark Pixie CSVs are the prototype) — partners write in tables; no
  authoring tool needed at launch.
- **Coverage is three-state:** authored / astronomically-impossible (e.g. Sun–Mercury
  can only conjoin — the author says so) / silent. Impossible ≠ silent.
- Prose is **fully authored, verbatim, one register**. The app places words; it never
  writes them. (Spectrum acknowledged — fully-authored ↔ framework-authored ↔
  doctrine-only like ZR today — but the integrity line is: the partner's words are the
  partner's.)

### 3. Resolution (per reading)
1. Instrument computes the exact condition → exact slot key.
2. Active voice for that **domain** is looked up (natal placements, natal aspects,
   transits, releasing… are separate domains; one pack may span several — Dark Pixie
   covers natal + transits, nothing Hellenistic).
3. Key canonicalizes down the ladder to the pack's grain; text found → rendered, signed.
4. Nothing found: **honest silence** — "___ is quiet here" — with optional fallback to
   the default voice, attributed to *it* (never blended, never misattributed).

### 4. Depth dial (revised)
Partners supply ONE register. Depth is what the instrument wraps around it:
- **plain** = the exact geometry line only
- **studied** = + the voice's prose (quoted, signed)
- **scholarly** = + attribution/honesty line and grain note
  ("reading by ___ · she reads squares and oppositions together · geometry by the
  instrument"), seated with the existing sources/honesty apparatus.
Never slice or tier the partner's prose — paragraphs are facets/sub-slots, not depths.

### 5. Ingestion
Forgiving import: normalize zero-width junk, mixed quoting, paragraph splits (all
present in the real CSVs). Validate against the namespace; emit the coverage map.
Ownership persists (localStorage now; account later).

---

## Front end — how it works

### The sheet (moonlight)
- Exact geometry line first, instrument's voice. Below it, the partner's prose as
  **quoted matter** — visually theirs, never restyled into the app's register. Two
  voices, honestly separated: the sun/moon law made visible.
- **One byline** under the reading — a signature, not a masthead. Everything else
  (bio, method, grain notes, store) lives one tap deeper.
- Grain/limitation notes render as **marginalia at scholarly depth**, like a scholium —
  never a disclaimer badge.
- Silence is staged in-voice: "___ is quiet here."
- A **pinned moment carries its byline** into ♒ memory — you pinned *their* reading.

### The back (maker's side)
- Volumes are **seated, not configured**: a library shelf on the back where owned
  volumes sit; seating one makes it the active voice for the domains it covers.
  Default: The Dark Pixie Astrology, shipped free, pre-seated.
- Per-domain active voice — a releasing specialist can hold ♏ while Dark Pixie holds
  the natal/transit readings.

### The store
- Reached through the byline ("other voices for this lens") — a **bookseller's shelf**,
  not an IAP modal: author, method note, and a few lines of their actual prose on *your*
  chart as the preview. The writing sells itself. Commerce never punctures the fiction;
  "expansion pack" is the business model, not the diction.

---

## Open decisions
1. Fallback-to-default on silence: on by default, or strictly opt-in? (Leaning: show
   default, attributed honestly.)
2. Storefront shape: à la carte volumes vs featured-collaborator bundles.
3. Partner spectrum: is fully-authored the hard integrity line, or is
   framework-authored (attributed rules, app-composed) admissible for some partners?
4. Namespace v1 scope: which domains get keys first (natal placements, natal aspects,
   transits-to-natal are proven by the Dark Pixie corpus; ZR keys exist implicitly).

## Next steps (when we build)
1. Draft namespace v1 from the three Dark Pixie CSVs + existing ZR/transit computations.
2. Ingest Dark Pixie as the prototype volume; wire resolution + canonicalization.
3. Sheet presentation: quoted matter + byline; depth-dial rewiring.
4. Library shelf on the back; store last.
