# Pack ingest — the header grammar

`packs/dark-pixie.pack.json` is **generated** from the Dark Pixie source CSVs in `uploads/`
(`The Dark Pixie Astrology - <hub> - <article>.csv`). Never hand-author entries; fix the parser
rule here and re-ingest, so the pack stays reproducible from source.
After any pack change, regenerate `packs/dark-pixie.browser.js` (the PACK literal only — the
resolver half is a rewrite of `packs/interp.js` and changes only when that file does).

## The source shape

These CSVs are PDF-derived text, one physical line per column of the original page:

- **Prose that wrapped** is `"quoted"` when it contains a comma, bare otherwise. Either way it is
  a *fragment* — rejoin consecutive prose lines with a single space.
- **Section headers** are bare (never quoted), short, and carry no sentence-terminal punctuation.
- **Page numbers leak** as a digit run glued to the first word of the line that followed the page
  break: `7positives`, `78fear`, `123We`, and — the one that reached a shipped title —
  `1098th House in Astrology: …`. Strip a leading `\d{1,3}` when it is glued to a word and is not
  itself an ordinal (`21st` must survive).

## Header shapes — all five

A bare line is a header if it matches one of these. **Shapes 4 and 5 were missed by the original
parser** (the "colon-header gap"); their bodies silently merged into the preceding section, which
is why `Intro to Astrology Houses` shipped 3 sections instead of 15 and
`Intro to Ruling Planets in Astrology` shipped 1 instead of 4.

| # | Shape | Example | Keyed as |
|---|---|---|---|
| 1 | Article title (first line of file) | `All About Aries in Astrology` | `.overview` |
| 2 | `<Subject> in Astrology: <Keyword>` | `Aries in Astrology: Leader` | `.k.<slug>` |
| 3 | A question | `What is a composite chart?` | `.q.<slug>` |
| 4 | `<Ordinal> House Astrology: <Name>` | `1st House Astrology: House of the Self` | `explain.house.<n>.brief` |
| 5 | Sentence-case, **trailing colon** | `Ruling planets and transits:` | `.<slug>` |

### The trap in shape 5

Most trailing-colon lines are **list lead-ins, not headers** — promoting them shreds prose:

    They are:                                   ← lead-in
    The signs go in order:                      ← lead-in
    A natal chart requires 3 pieces of data:    ← lead-in
    other people. Like:                         ← lead-in (also: continues a sentence)
    1st house: Mars and Aries                   ← list ITEM
    97At-a-glance Fourth House Keywords:        ← header, but page-number glued

A trailing-colon line is a header only when it names a *section of the article* — in practice:
it is a complete noun phrase, it does not continue the previous sentence, and the block it opens
runs to another header rather than a handful of list items. There are exactly **three** in the
corpus, all in `Intro to Ruling Planets in Astrology`; they are enumerated explicitly in the
ingest rather than inferred, because no cheap heuristic separates them from the lead-ins above.

## Lists must keep their line structure

`house-rulers` first shipped as run-on prose (`… spirituality Depending on which house system …`,
`Aries Taurus Gemini …`) because every line was joined with a space. Within a section, a line that
is a **list item** (`^\d+(st|nd|rd|th) house ruler =`, or a bare zodiac-sign name) stays on its own
line; runs of items are separated from surrounding prose by a blank line. The pack's text
convention is `\n\n` between blocks, `\n` between items; the eclipse tier renders it
`white-space: pre-line`.

## Entry field conventions

    { title, text, topic, subject, depth, lineage, doctrine, source }

- `topic` — `sign | house | body | axis | aspect | intro`.
- `subject` — **the bare house number** for `topic:'house'` (`"4"`, not `"4th house"`);
  `explainSearch` ranks an ordinal query by `String(e.subject) === houseN`, so a prettier
  subject silently drops the entry out of house lookups. Sign/body: the proper name.
  Intro: the article title.
- `depth` — 1 plain / 2 studied / 3 scholarly; an explanation inherits the depth of the thing it
  explains. `where`/`strong` sections are 2. `lineage` is required on every depth-3 entry.
- `doctrine` — `{ rulers: 'modern' }` where the source assumes modern rulership. **Derive it, don't
  eyeball it:** an entry whose text assigns Pluto, Uranus or Neptune as a natural ruler carries the
  tag; traditional-compatible rulers carry `null`. A new entry must agree with its siblings for the
  same subject — `explain.house.8.brief` and `explain.house.8.natal` both say Pluto rules Scorpio,
  so both are tagged. The plate is cut
  traditional **and** modern (the co-rulership law), so Orbo names the source instead of silently
  siding with either. `Intro to Ruling Planets in Astrology` is the corpus's explicit statement of
  both schemes and of interception/co-rulership — it is the text the ruler-row split reads.
- `source` — the CSV basename minus the `The Dark Pixie Astrology - ` prefix and `.csv`. Every
  ingested entry carries it; it is how coverage is audited against the source files.

## Two invariants to re-check after every ingest

Both were violated by the first pass of the shape-4/5 re-ingest — new entries default to empty
metadata, and nothing fails loudly when they ship that way:

1. **Every depth-3 entry has a `lineage`; nothing else does.** `interp.js` states it; assert it.
2. **`doctrine` agrees with the text.** Sweep for entries naming a modern-only ruler with
   `doctrine: null` — and for the tag on text that names none.

## Auditing coverage

Group entries by `source`, and for each CSV list the bare lines that pass the header test and have
no entry whose `title` matches. Everything remaining should be prose or a list item — if a real
section name appears, a header shape is missing from the grammar above. Note that the
`Natal Houses - *`, `Composite - *`, `Composite Houses - *` and `The Natal Planets - *` files feed
the **placement** tier (`natal.*` / `composite.*` / `transit.*`), not `explain.*`, and are audited
by key count instead: 12 signs × 12 houses per planet, 144 per house×sign family.

## Known content gaps (source has none — never fill with a placeholder)

- `natal.sun.sign.*` — there is no `Natal Sun in the Signs.csv`; the Sun's sign prose lives inside
  the per-sign articles. Every other natal planet has all 24.
- `composite.<planet>.sign.*` — no composite planet×sign content exists. A composite body reading
  honestly surfaces only its house layer.
