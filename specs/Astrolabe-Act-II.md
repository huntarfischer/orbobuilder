# Astrolabe Act II — Lunar Port and instrument control

Status: implementation in progress on `feature/astrolabe-lunar-pane-swift-2026-09-03`. No acceptance claim until the accumulated Xcode and simulator gates pass.

## Source transcription

Read-only prototype sources: `Orbo Astrolabe.dc.html` (`ROW_CONTRACTS`, `_pass`, `_captionOf`, `ARRANGEMENT`, `PLATE_REST`, `_fingerLon`, `_down/_move/_up`, `_applyMagnet`, `_sprStep`, `_paneGrab*`, `SECTIONS`, `_tabItems`), `luna.js`, and `specs/Lunar Pane Templates - Build Guide.md`.

Avoid: prototype ephemeris/cursor `_makeSpine`, DOM measurement constants, legacy ROSTER as a seventh Pane plate, second render path bypassing accepted rows, and an independent lunar scanner. Native source is the single mounted OrboSpine through the earned doors. Broader Luna work remains Artemis's jurisdiction; no empty event set is presented as proof of void-of-course.

## Native owners

- Apollo: source Aegis, relative body/ASC gears, bounded requests, nearest enabled Ring contact and sample-based magnetic time correction.
- Artemis: typed Lunar tickets and accepted readings; FACT, RELATION, LEDGER, SPAN, nested TRACK, addressed PROSE; lunar phase/mansion and prepared events.
- Chronos: Almanac's prepared station, Ring-contact and eclipse chronology, with independently selected streams and an ALL/body rail. Existing Ring/eclipse arrays now live on their already-declared Library shelves; runtime compatibility views read those same arrays.
- Pythia: timing landing begins with actual future returns to the selected body's current degree/direction, resolved by Chronos through Horae. This does not claim zodiacal releasing or election techniques have been ported.
- Hermes: twelve zodiacal Tabula destinations; request navigation remains separate from the Messenger's process contracts.
- Hestia: existing codec-4 snapshots, saved as individual houses, with an app preference selecting the active house. No alternate archive format; failed birth input preserves the previous Hearth.
- Hecate: existing Door III coordinate read exposed at the composite destination. Composite casting remains a separate unearned operation.
- Iris: presentation, gesture geometry, native velocity-carrying Pane/arc springs and controls. The Pane's allowed detents follow Artemis's rest contract. No astronomical calculator or synthetic source. Optional kept lenses are independent of opening a reading or choosing Almanac streams.

## Acceptance scope

Keep Big Three, clock, wheel and Pane on one accepted answer. Preserve natal chart during live/play/scrub. Relative finger travel and pickup radius choose a temporal gear; actual longitudes come from Horae. Zero aspect residual is valid, disallowed marks do not attract, zero speed does not create a fabricated correction, and requests respect the exclusive Spine boundary. Presentation springs never change celestial time.

No bottom tab bar. Tabula is the reverse instrument with AEGIS return. Onboarding and the 3D Orbo companion remain the next entrance pass. Consolidating the approximately 750-year development Spine is a separate performance task.

## Preservation

Act I app, Iris views and Artemis port are preserved in `native/OrboCore/Obsolete/AstrolabeActII/`. No prototype files or live/base branch are changed.

## Gates

Pending: full Swift package suite, accumulated Xcode suite, actual simulator gesture/Tabula proof, Orbo/OrboLab build and captures. See the dated Act II gate for measured results and remaining scope.

First implementation commit `861ce67`: 956 package tests passed with zero failures in run 33797380511. Subsequent refinements require their own final gate; the first result is not a claim about untested edits.

The center hold currently saves the native Hearth using its existing codec. Marking an arbitrary displayed moment needs a kept-moment representation: Holdings currently keeps AstroDNA without the displayed UT/place, so pretending those records can restore an exact moment would lose information. No such alternate record or codec is invented in this pass. The composite seat reaches Hecate's existing linked sky read, with two-chart casting explicitly unavailable. The six typed axes/renderers are prepared; current real readers exercise FACT, RELATION and LEDGER. Advanced SPAN/PROSE dishes and the full Luna windowed reader are not claimed as connected.
