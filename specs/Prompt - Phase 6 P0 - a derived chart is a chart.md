# Prompt · Phase 6 · P0 — a derived chart is a chart

Plan of record: `specs/Phase 6 - The Synchronic Prism.md`, §2.1. This is the first pass of Phase 6 and
it is deliberately the smallest one: **one function, no new files, no doctrine call, no engine.**

**The one sentence:** a composite holding the plate with nothing seated on the rete draws no aspect web
at all, and it must draw its own.

Do NOT build the prism, the clock, the tables, the ♓ socket or the seating layout in this pass. P0b
(seating, §12) and P1 (the seam) are separate prompts.

---

## 0 · Before anything

- **Snapshot first**, per the versioning convention: copy the working file to
  `archive/Orbo Astrolabe 2026-08-06b.dc.html` (the unsuffixed 2026-08-06 snapshot already exists).
- Version goes **v0.888 → v0.889**.
- Orbo never uses the em-dash. Not in the UI, not in a comment, not in the write-up.

---

## 1 · THE DEFECT, exactly located

In the wheel draw, the block commented *"the plate's OWN aspects"* (around line 9701) is gated:

```
if (natT.length && this.state.show.natal !== false
    && !((this.state.composite && this.comp) || (this.state.abComposite && this.compAB))
    && showWeb) {
```

Its own comment explains the gate: *"Off while composite holds the seat (the gilt bead threads take
over that job then)."* But the block that takes over, the ambient threads a few lines below, is gated on
`skyOn`. And `_toggleComposite` opens composite mode **solo** (`rete: 'off'`), which is composite mode's
DEFAULT state.

So in the default state of composite mode: the plate's own web is suppressed because a composite is
seated, and the threads that were supposed to replace it never draw because there is no sky to thread
from. **Nothing draws.** That is the second screenshot of 2026-08-06.

**The gate is wrong, not the code.** The condition it wants is "a partner is supplying threads", and it
was written as "a composite exists". Those coincided for as long as a composite was only ever read
against something.

One more thing the gate hides: when a composite holds the plate, the web's target set must be the
**composite's own marks** (`this.comp`), not `natT`. Removing the gate alone would draw the natal chart's
web under composite beads, which is worse than drawing nothing.

---

## 2 · What to build

### 2.1 A seated derived chart draws its own web over its own marks

Give the plate's own web a target set chosen by **what is seated on the plate**, not by whether a
composite exists:

- composite on → the composite's marks (`this.comp`), at `rN`, the radius the composite beads already use
- `abComposite` on → `this.compAB`, the same way
- otherwise → `natT`, exactly as today

Reuse `_aspHit(this._arc(a, b))`, `_webColor`, the `tt` tightness ramp, the `_twA` tween fields and the
`AXIS_TWIN` degenerate-axis skip verbatim. **No new aspect arithmetic anywhere in this pass.**

### 2.2 Suppress only when a partner is threading, never merely because a composite is seated

Replace the composite test in the gate with the real condition: the plate's own web stands down when the
ambient threads are actually drawing (a partner is seated or the sky is on and `show.skyThreads` is
live), and draws otherwise. A solo plate always draws its own web, whatever kind of chart it is.

### 2.3 Ordinary orbs, and no doctrine call (this is a finding, not a licence)

**A composite chart has one Mars**, so its internal web is entirely CROSS-BODY, where nothing halves and
ordinary orbs apply. A body meets itself only when a composite is read against its own natal, which is
the paired reading that already exists and already carries the twice-deferred hardcoded 3°.

So: use the reader's own ♍ orb, unchanged, and **do not touch `_compPairs` or its 3°.** The deferred
two-orb question stays exactly where it is.

### 2.4 cASC joins the web

This is the clock's whole premise arriving one pass early for the price of one entry in a target list:
**the composite Ascendant is an occupant that forms real aspects.**

`cASC` is drawn on the rim (`R + 1`) where the bodies sit at `rN`, so its lines run from the rim inward.
That is honest rather than a defect: the frame's own point rides the limb. Keep the `AXIS_TWIN` skip so
a cASC/cDSC pair is not reported as an opposition.

Gate it on the same ♊ Bodies / ♍ Aspects reads every other occupant obeys. If it reads badly at speed,
say so in the write-up rather than tuning it here.

---

## 3 · What must NOT move

- The instrument's own wiring. Canvas sizing, pointer listeners and the RAF loop come first and
  unconditionally in `componentDidMount`; nothing in this pass goes near them.
- `natT` for the non-composite case. A natal solo plate must draw byte-identically to today.
- The sky web, the ambient threads, the held-hand block, `rAsp`, `rN`, `rBody`, the #2b solo spread.
- `_compPairs`, `synOrb`, `framing.js`, `loom.js`, `ring.js`, any `.browser.js`, any codec, any key.
  **Nothing in this pass may move `fertKey`, `connectome.CODEC` or the spine seed.**
- The two-chart layout. That is P0b.

---

## 4 · Acceptance, measured

1. **The screenshots' own case.** Reach it by the review path, since the state is gesture-only:
   `__orbo.setState({ composite: true, rete: 'off' })`. The wheel draws a web among the gold composite
   beads. Before this pass it draws none.
2. **The paired case is unchanged.** With the sky on, and with a person seated, the wheel reads as it
   does today: the ambient threads own the reading and the plate's own web stands down.
3. **The natal solo case is unchanged.** Composite off, rete off: the same natal web as today.
4. **cASC is in the web** and its lines run from the limb to the beads.
5. **STEP 0 of `tests/rewire-parity.test.html` passes**, which is the extract-and-`new Function`
   compile of the logic class plus the template's control-flow tag balance. A SyntaxError passes straight
   through a grep, and the whole suite once said ALL GREEN while the app did not boot.
6. **The full suite is green**, no suite reporting zero rows. An unfinished suite is not a passing suite.

---

## 5 · Traps

- **Never build an `old_string` out of grep output.** Grep truncates its lines, and a truncated match
  welds the original's tail onto the replacement.
- **A bulk edit is verified by PARSING, never by reading the diff.** Every changed line can read
  correctly in isolation while the file cannot run.
- The gate is one long boolean. Restructure it into a named local (`platePartnered`, or similar) rather
  than adding a fourth clause to a line nobody can read.
- `this.comp` is keyed by body name and includes `cASC`, so a naive `for (const k in this.comp)` will put
  cASC in the body list at the wrong radius. Build the target list explicitly.
- Do not "help" the web by adding a second line style to distinguish composite from natal. Line style is
  P0b's subject and §12.5 retires a style rather than adding one.

---

## 6 · Owed on completion

- `CLAUDE.md` gains a short section: **the solo-web law.** A seated chart draws its own web whatever kind
  of chart it is, and the suppression condition is "a partner is threading", never "a derived chart
  exists". Same defect class as an invariant living only in a comment: the gate encoded an intention that
  stopped being true the moment a derived chart could be read alone.
- `specs/Phase 6 - The Synchronic Prism.md` §10: mark P0 done, with the measured before and after.
- The write-up states whether cASC in the web reads well at Ascendant speed, since that is the first
  direct evidence about the clock's central premise and it arrives here rather than in P1.
