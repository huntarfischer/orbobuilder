# Phase 5 handoff · paste this to open the new chat

We are building **Phase 5 · The Loom** in the Orbo AstroLabe project. Everything you need is in the
project. Read these first, in this order, before writing anything:

1. `CLAUDE.md` · the project's laws. All of them bind. Especially: the TimeSpine law (the spine is the
   sole owner of time and the only door to the sky), the sun/moon law (nothing new lands on the
   instrument; every way of looking is a moon view), the presentation-clock law (one dt, one RAF), the
   dock law (open is not etch), the standalone-export law (no fetch, no module imports, plain
   `<script src>` only), the instrument-survives-everything law, the generated-files law
   (`*.browser.js` are builds, never hand-edited), the versioning system, and **Orbo never uses the
   em-dash, in the UI, in a write-up, or in chat**.
2. `specs/Phase 5 - The Loom.md` · the plan of record for this phase. Follow its order of work.
3. `specs/Phase 4 - The Synchronic Engine.md` · what the synchronic engine already IS. Not superseded;
   its unfinished items are absorbed into Phase 5.
4. `Version Notes v0.878.md` · what shipped last and the bugs that shaped the engine.
5. `docs/Synchronic Conversation -source for the white paper-.md` is the authority on doctrine wherever
   it and the white paper (`docs/Field Theory Astrology for Orbo Timespine.md`) differ.

## The working file

**`Orbo Astrolabe.dc.html` is THE base.** One Design Component, ~9,200 lines: template 1 to 1669,
logic class 1669 to end, 274 methods, inline styles only. Snapshot to
`archive/Orbo Astrolabe YYYY-MM-DD[a,b,c].dc.html` before any significant revision. Never create
parallel `v9` root files.

Engines are plain scripts, each self-registering a `window.__ORBO_*` global: `ephem` · `framing` ·
`astrodna` · `rulers` · `transits` · `timespine` (the materialized event-table unspooler, a different
thing from the DC's cursor spine) · `electional` · `aaf` · `cities` · `packs/interp` · `orbo-sphere`.
Edit the `.js` source of truth, then regenerate the `.browser.js`.

Reaching the back for review: `window.__orbo.setState({flipped:true, panel:'releasing', ...})`.

## What Phase 5 is, in one paragraph

Two threads and two weaves. The **sky** thread is the mundane floor: native-independent, place-free,
byte-identical for every user, shipped as an embryo covering 1700 to 2100. The **native** thread is
the engraved natal chart. The two weave together twice: by **contact**, which is the natal spine and
means a transiting body touching a natal degree, the sky meeting you; and by **union**, which is the
synchronic spine and means the two becoming one placement at the midpoint, the sky merged with you.
Both weaves materialize a century at engrave time, in the background, while Orbo gives the onboarding.
The almanac reads the floor by default and the two weaves on top of it.

## Three things that will save you a wrong turn

- **The midpoint is primary.** Do not describe the synchronic layer as the transiting layer "halved."
  That factor is bookkeeping inside a root-finder that asks the inverted question, and it belongs
  nowhere else: not in doctrine, not in a UI string, not in a comment outside `loom.js`.
- **Do not write a synchronic spine. Write the third target set.** All three layers are the same
  builders over the same sampling; they differ only in what counts as a target. One scanner,
  parameterized.
- **A union target defined mod 180 resolves to TWO sky targets, 180° apart, and both must be
  scanned.** That is the algebraic shadow of the two poles. Getting it wrong does not throw; it
  returns a plausible half of the events.

## Start here

**S0 from the plan: the target algebra in `framing.js`.** Pure functions, no scanning, verified against
a real natal before anything else moves. Then S1 (`loom.js`, one scanner, three target sets, floor for
a decade only), then S5 thin (ingresses and flips on the pane so the thing is readable early), then the
rest in the plan's order.

## The fixture

`uploads/Screenshot 2026-07-29 at 8.5*.png` are fourteen consecutive daily synchronic composites for
one natal (10 Apr 1985 20:16, 43°4'N 89°24'W), same-ascendant anchored, whole sign, from Astro-Seek.
Sixteen rows each, 224 values. Use them as a numeric fixture, not as a screenshot. Three findings
already extracted from them, all recorded in the plan:

- Their ASC wanders 11°08' to 11°53' because they anchor on a five-minute grid. `findAscAnchor`
  bisects, so ours should be an order tighter, and that is a number to assert.
- Union Saturn crosses 29°56' Capricorn into 0°00' Aquarius on 9 Mar 2026: a change of sign and house
  with **no change of dispositor**, Saturn to Saturn. The ingress row must not assume the three
  readings always change together.
- The Moon is not the moving light in a still set, she is the **switch**. The 6th-house group is parked
  within a few degrees of itself, so the instant she reaches one member she reaches all of them and the
  whole configuration lights and goes dark at once. A row that says "Moon trine Mercury" is
  under-reporting the event. This is why the synchronic chart reads as a **mundane** chart: standing
  structure, its government, and the fast bodies that switch it on.

## Open decisions already made, so do not reopen them

- The floor is the almanac's **base layer**, not a fusible stream. ♐ gets density chips per mundane
  kind.
- Materialize generously (every body, every aspect, widest orb, with enter/exit) and **filter at read**,
  so ♊ Bodies and ♍ Aspects never invalidate the build.
- The Moon gets `luna.js`, a windowed generator, never materialized, because she is ~270k rows per
  century against ~50k for everything else. Two exceptions materialize: lunations and eclipses on the
  floor, and her flips and union ingresses, which are chapters of the film.
- The embryo ships for **trust, not size**. Positions are already free from `ephem.js`; what needs
  shipping is what can be verified once and be right forever, above all eclipses.
- The same-ascendant anchor is the **camera** on the union weave, not its foundation. Houses are natal
  whole-sign by law, so a union ingress is a function of time alone.
- "Fuse" keeps its dock-law meaning only. The floor is not fused; the weaves are woven.
