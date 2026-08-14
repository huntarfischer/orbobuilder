# Orbo AstroLabe — Version Notes v0.855 (July 28, 2026)

Interpretation-corpus pass. No instrument changes; the sun is untouched. One moon-side layout fix
and a corpus re-ingest that unblocks the co-rulership work.

## Snapshot
- `archive/Orbo Astrolabe 2026-07-28b.dc.html` — the working base as shipped at v0.855.

## 1. Orbo Ask bubble — overflow verified, one latent hazard closed
Carried over from the previous session as todo 12: the byline was suspected of overlapping the
pinned Ask input row (§8 requires the credit to travel with the prose it credits).

**It was not overlapping.** Measured live at viewport 540 with a long answer: the byline is a DOM
child of the scroll region (`citeInsideScroller: true`), riding with its prose. At `scrollTop: 0`
its rect reads y 805–818 — *below* the scroller because it is scrolled out of view, not because it
escaped. Scrolled to the bottom it sits at y 315–328, inside the scroller box (222–449), with the
input row starting at 459. The earlier y 485–497 reading was a stale mid-scroll rect.

The constraint chain measures as designed: wrapper 182→516, card 334px, scroller 228px clientH
holding 718px of content, Ask row 459→503.

**Fixed while in there:** the actions block was the only scroller child without `flex-shrink:0`,
making it the sole absorber of negative free space — a tall action list could have squashed it.
Now all three scroller children (questions / answer+byline / actions) plus the pinned Ask row
carry it.

## 2. The pack's colon-header gap — closed and re-ingested (1396 → 1411 entries)
The original parser recognized title-case headers and questions. It missed **two** header shapes,
whose bodies silently merged into the preceding section:

- **`<Ordinal> House Astrology: <Name>`** — all 12 in *Intro to Astrology Houses*, merged into one
  5,549-char question entry. Now 12 `explain.house.<n>.brief` entries; the host is trimmed back to
  its 111-char lead-in. Each brief is paged directly after its house's `.overview`, not appended
  after `.strong`.
- **Sentence-case trailing-colon headers** — the 3 in *Intro to Ruling Planets in Astrology*,
  merged into a 4,003-char overview. Now `.natal-chart`, `.house-rulers`, `.transits`; overview
  trimmed to 743.

**The second split is what Phase 2 needs.** The interception / co-rulership passage — main ruler vs.
co-ruler, the Scorpio 10th with Sagittarius intercepted — is now its own addressable entry,
`explain.intro.ruling-planets-in-astrology.house-rulers`, and `explainSearch(pack, 'co-ruler')`
resolves to exactly it. That is the corpus text the ruler-row split reads.

### Defects found and fixed in the same pass
- One shipped title carried a glued page number: `1098th House in Astrology: …` → `8th House …`.
  (No text bodies carry glue — the original ingest cleaned those; only the title slipped.)
- `house-rulers` had collapsed its two lists into run-on prose (`…spirituality Depending on…`,
  `Aries Taurus Gemini…`). Lists now keep line structure; the tier renders `white-space: pre-line`.
- The new house subjects were written `"4th house"` where `explainSearch` ranks houses on the bare
  `"4"` — normalized, or ordinal queries would have silently dropped them.

### Metadata invariants (caught in review, then derived rather than hand-set)
All 15 new entries first shipped with empty `doctrine`/`lineage`, which nothing fails loudly on:
- **`doctrine`** is now computed from each entry's own text — `naturally ruled by <Pluto|Uranus|
  Neptune>` earns `{rulers:'modern'}`. Houses 8/11/12 tagged, 1–7/9/10 null; every brief agrees
  with its `.natal` sibling. `house-rulers` is tagged too — its 12-ruler list is modern and its
  co-ruler worked example turns entirely on Pluto ruling Scorpio, so the corpus's most
  rulership-dependent passage would otherwise have reached the ruler-row split doctrine-blind.
- **`lineage`** added to the two depth-3 entries (`natal-chart`, `transits`), in the sibling
  format. Pack-wide sweep: depth-3 without lineage **none**, lineage on non-depth-3 **none**,
  explain entries naming a modern ruler but untagged **none**. Doctrine count 33 → 37.

Note for future sweeps: `doctrine`/`lineage` are **explain-tier fields only**. Placement entries
are `{placement, layer, text}` — zero carry metadata, so a naive text sweep false-positives on
`composite.pluto.house.8` and `composite.neptune.house.12`.

### New: `packs/INGEST.md`
The header grammar recorded so the two missed shapes cannot be lost again: all five header shapes,
the trailing-colon trap (most such lines are list lead-ins — `They are:`, `1st house: Mars and
Aries` — that shred prose if promoted; the three real ones are enumerated, not inferred), the
list-structure rule, the field conventions incl. the bare-number house subject, the two invariants
to re-check after every ingest, how to audit coverage, and the two honest content gaps.

## 3. Generated artifacts
- `packs/dark-pixie.browser.js` regenerated from the pack (PACK literal only — the resolver half is
  a rewrite of `packs/interp.js`, which did not change). Verified deep-equal to the json, IIFE tail
  intact, no ES-module surface.
- `Orbo Astrolabe v0.855 standalone.html` — offline single file, every `script[src]` inlined.

## Known content gaps (unchanged — source has none; never placeholdered)
- `natal.sun.sign.*` — there is no *Natal Sun in the Signs* source; the Sun's sign prose lives in
  the per-sign articles. Every other natal planet has all 24.
- `composite.<planet>.sign.*` — no composite planet×sign content exists; a composite body reading
  honestly surfaces only its house layer.

## Next
1. The byline law across the eclipse tier's other pack surfaces.
2. Phase 2 app-side: the `_depth()`/`_atDepth` contract · the ruler-row split the co-rulership law
   needs (reads §2's `house-rulers`) · the dial moving ♋→♑ · doctrine presets in the Orbo menu
   with `_doctrineKey()`.
