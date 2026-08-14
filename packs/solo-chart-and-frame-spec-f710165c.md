# Build prompt: solo-chart display, natal-ASC lock, plate/rete swap, elemental badges

Implement four related changes to `Orbo Astrolabe.dc.html`. Snapshot the current file to
`archive/` first per project convention before starting.

## 1. Third frame: Natal-ASC-lock

Add a third orientation frame alongside the existing `sky` (zodiac fixed) and `horizon`
(current/live ASC swept to 9 o'clock):

- **`natalAsc`**: pins the chart's own natal ascendant at 9 o'clock permanently. Unlike
  `horizon`, it does not sweep as live time advances — the rising sign never appears to drift.
- Anchor rule when two charts are in play (plate + rete both occupied): lock to whichever
  chart occupies the **plate**. If plate is empty (solo state), lock to the sole chart (which
  lives on rete per #2).
- Interaction: double-tapping the inner horizon ring cycles `sky → horizon → natalAsc → sky`.
- Update whatever currently labels the active frame (existing sky-/horizon-locked indicator)
  to show the third state with a clear short label (e.g. "asc-locked").
- Default frame when only one chart is in play should be `natalAsc`, not `horizon` — this is
  the direct fix for "can't orient to my ascendant naturally."

## 2. Plate is conditional — only exists with two charts

- **One chart in play** → it renders on the **rete only**. No plate disc, no second static
  ring, no drop-shadow/depth seam between layers.
- Header collapses from two cards ("THE PLATE" / "THE RETE") to **one card** with no
  plate/rete language — just the single occupant's identity.
- Aspect-line color in solo state uses a single hue (no red/blue set-differentiation, since
  there's nothing to differentiate against).
- **Second chart enters** (seat someone, engage live "now", mint a composite, open synastry)
  → plate reappears, the two-card header returns, and the swap control (#3) becomes
  available.
- **Chart count drops back to one** → plate un-renders again, and whichever chart survives is
  promoted to rete (never left stranded on a now-vanished plate).
- Decide and document the trigger condition for "two charts in play" — e.g. does an unseated
  but still-ticking live-now sky count, or only a deliberate seat/composite/synastry action?
  This determines how eagerly the plate reappears.
- Check that the parallax/void-background effect (currently keyed to plate+rete depth)
  doesn't assume the plate disc is always drawn.

## 3. Swap control (plate ⟷ rete)

- Visible only once the plate exists (two charts). Add a small swap affordance between/on
  the two header cards.
- Exchanges which chart is fixed (plate) vs moving (rete). This changes the reading, not just
  the picture:
  - natal-on-plate / now-on-rete = "what's transiting me right now" (standard technique).
  - now-on-plate / natal-on-rete = "where do my degrees fall against today's actual ground"
    (converse technique).
  - For two-natal pairings (synastry/composite), swap changes whose ascendant anchors
    natal-ASC-lock per #1's anchor rule.
- Default assignment each time a pairing starts fresh: personal/fixed chart → plate,
  other/live chart → rete. Treat the swap as a session-only override unless there's a reason
  to persist it.

## 4. Skittles — elemental body badges

- Each planet body's badge disc is tinted by the element of its current sign — fire / earth /
  air / water — using oklch with fixed lightness and chroma, hue varying per element, so the
  set reads as one coherent system.
- Keep the glyph itself white/legible on top of every hue; verify contrast against the
  lightest of the four.
- Apply to planet bodies only. Angle markers (ASC/MC/DESC/IC) keep their current distinct
  treatment (they're chart structure, not content).
- Make sure aspect-line color (whose chart/which set, from #2) and badge element-color don't
  visually collide where they sit adjacent (e.g. a red Mars line next to an orange fire-Mars
  badge) — should be fine but sanity-check.

## Open questions to resolve during build

- Exact trigger for "two charts in play" (see #2).
- Whether swap state (#3) should persist across sessions for a given pairing or always reset
  to the canonical default.
