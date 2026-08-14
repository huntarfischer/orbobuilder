# Ledger Tabula (♎) — Spec

## Terminology (definitions — updates/extends CLAUDE.md's composite section)

- **Composite** — chart × chart (midpoints). The general operation. *(unchanged)*
- **Synchronic Composite** — natal × a moment (natal × now, or natal × any chosen moment): the live plate composite. *(clarified/formalized from existing "synchronic composite")*
- **Synchronic Synastry** — (natal A × moment) × (natal B × same moment): two Synchronic Composites sharing the same sky, read against each other. *(unchanged)*
- **Composite Framing** — the operation of taking a Synchronic Composite at the same-ascendant moment, at the natal location, recomputed once per day. Each day's result is a *frame*. *(supersedes "Composite frame" as the name of the operation, not just its basis)*
- **Composite Chronology** — Composite Framing played in succession across a date span: the scrubbable filmstrip through time. *(formalizes existing UI label — no rename needed there)*
- **Synchronic Intersections** — continual computation across two people's Synchronic Composites over a span of time, surfaced as the exact dated moments a unique transit/aspect occurs between them — timeable, addable to a calendar. *(elevates and replaces the current lowercase UI label "synchronic composite intersections")*
- **Minted Composite** — *new term.* A one-time, frozen Composite chart made from two specific charts (natal, person, event, or another Minted Composite). Distinct from Synchronic Composite, which is always live and natal-anchored — a Minted Composite is a static artifact, same standing as a saved person or event.

## Data model change

- Roster entries gain a fourth kind: **composite** — alongside person, event, horary (horary retained by default; final in/out call still open, cost of keeping it is trivial).
- A composite entry stores: name (editable, default "A × B"), references to its two source charts, mint timestamp.
- `abComposite`/`abWith` — the current single overwritable mint slot — is retired. Minting writes a new roster entry instead; the roster holds any number of Minted Composites, same as any number of people/events.
- Minted Composite entries are seatable, viewable, deletable like any other roster entry, and are valid inputs to a future mint themselves (composite × person, composite × composite).

## Ledger Tabula (♎) — scope

Ledger's sole job: **entry + roster of saved charts.** It does not mint, and does not host any composite operation. Person × Person mint is removed from Ledger entirely, relocated to ♓ Composite. Plate-card mint path — confirmed vestigial, removed.

## Ledger Tabula — layout

**1. Roster zone** (top, majority of panel height)
- Bounded, independently-scrolling list — roster growth never pushes anything below it.
- Side sort/filter buttons: Composites / People / Events / Horary (pending), default "All."
- Search field, filters visible list by name.
- Rows keep current affordances (name, kind badge, sub-label, calendar-add icon, delete ×), plus a **new secondary shortcut icon** to jump to ♓ Composite with this entry preloaded as chart B.
- Empty state copy unchanged, shown only when the filtered view is empty.

**2. Add zone** (bottom, fixed height, collapsed by default)
- Collapses to a single slim "+" affordance, not two full-width PERSON/EVENT buttons. Tapping expands the form in place; submit or dismiss collapses it back. This zone's height never grows with roster length.
- PERSON/EVENT becomes a small segmented mode switch inside the expanded form, not two CTAs. *(Open: does Horary get its own quick-add mode, or a separate minimal entry, given it's "mostly just a button and category"?)*
- Import .aaf demoted to a small icon/text link at the zone's edge — utility weight, not a primary CTA.

## Cross-tabula shortcuts (new)

- **Ledger → Composite**: row shortcut icon navigates to ♓ Composite, opening the mint picker with chart A defaulted to "you" (natal) and chart B preloaded to the tapped entry. Real navigation, not inline preview.
- **Composite → Ledger**: if the mint picker has <2 usable charts, an inline link ("→ ♎ Ledger, add someone") replaces the current vague footnote, jumping straight to Ledger's Add zone, pre-expanded.
- The existing footnote text in ♓ Composite ("person composites mint on the ♎ roster…") is removed once the picker lives there directly.

## Out of scope for this pass (flagged, not designed)

- The mint-picker UI itself inside ♓ Composite (A/B selection, defaults, placement relative to "you × this moment" and Composite Chronology).
- Whether Minted Composites can be composited further — data model says yes, UI not designed.
- Horary's final keep/cut and quick-add treatment.
