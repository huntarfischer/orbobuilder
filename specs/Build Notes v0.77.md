# v0.77 build notes — synchronic composite intersections fix

## What shipped
- **Fixed synchronic composite intersections** (`_sheetDataCross`, `_crossExact`, cross-sheet
  window filter in `renderVals`): the feature was computing composites and scanning the ±window
  against `this.jd` — the *parked* instrument date. Because seating a person freezes the clock at
  that person's birth (`_reteFrozen()` forces `live=false` and parks `this.jd` at `rete.jd`), the
  intersections were being built as you×**birthyear** × them×**birthyear** and scanned around the
  birthyear — i.e. a *natal* composite reading, not the intended *synchronic* one.
  - Fix: the cross sheet now captures a single present-instant "now"
    (`Date.now()/86400000 + 2440587.5`) when it opens, carries it as `sd.now`, and threads that one
    value through all three coupled sites (window filter, `crossAspects` call + scan horizon, and
    the exact-time scan in `_crossExact`). They must share one value or the filter drops rows the
    scan produces.
  - Result: composites build as you×now × them×now, rows land in the present (2026), window math
    (45 back / 180 fwd) centers correctly. Seated person still only supplies natal positions; row
    taps still travel the instrument via `_homeJd`, unchanged.
  - Chosen over forcing the instrument "live" on open, which the seat-freeze law
    (`_reteFrozen` → `live=false`) would immediately undo. Scoping a private "now" to the sheet
    respects the sun/moon law: the instrument (sun) stays parked; the panel (moon) reads against
    present time.

## Copy
- **Removed "frozen" from all user-facing strings** (rete seat subtitle, roster entry subs,
  person×person mint note, gear readout). The internal `_reteFrozen()` identifier is unchanged —
  it names a clock-state ("the seat holds a fixed chart, so time is parked"), which is a different
  axis from the subject vocabulary (synchronic / natal composite) and shouldn't surface to users.
- Version bumped to **V0.77** (header + feature comment).

## Not done this pass
- The entry path into intersections is still clunky (into the ♎ people panel, tap through). A more
  direct "open intersections" affordance was flagged but left out — it's a UX change, not part of
  this bug. Awaiting confirmation.
- Internal key rename + migration shim for `abComposite`/`abWith`/`compAB` (carried over from v0.74).
