# Astrolabe Act II gate — 2026-09-03

Status: accepted for the Lunar Port, instrument controls and first connected-reader scope. Advanced technique and entrance work below remain pending.

Branch: `feature/astrolabe-lunar-pane-swift-2026-09-03`.
Base: Act I repass `76a2dcdbdb46575f3d2c13e26587755e6280c342`.

Native XCTest additions cover Lunar whole-reading refusals, house subject qualification, nested track ranges/raw overflow, Valens span overflow, addressed prose absence, relative scrub/wrap/radius/domain, real Spine frame consistency, Chronos/Pythia doors, Tabula owner routing and velocity-carrying presentation springs.

First run 33797380511 / commit `861ce67`: 956 package tests and 957 accumulated Xcode tests (868 Core + 88 Iris + one actual-touch UI test) passed. Orbo and OrboLab built and launched. The workflow was superseded/cancelled during final cleanup; these are successful stages, not an overall successful workflow claim. Artifact 9910462423 contains the captures. Spine load/assembly: 225.854 s; first sky preparation: 0.152 s; birth/Hearth delivery: 0.826 s. The full development payload remains unchanged.

Visual inspection found a pickup defect despite that first touch test passing: the Moon overlapped a later-painted Uranus button, so a drag addressed to the Moon moved Uranus's much slower gear. The initial assertion only established that the sky changed. Correction: one wheel-level nearest-placement hit map, a single frozen pickup per drag, and the actual Horae body-focus path. The strengthened touch assertion sees the Moon as the temporal gear; a geometry regression covers overlapping Moon/Uranus and natal priority. Both passed in the final run. The inspected scrub capture now shows September 4, 2026, rather than the erroneous jump to 2028.

Run 33800640778 / commit `70490a518c65d494362db379d8d16f8437d9e32b`, first attempt: 959 package tests passed. Xcode's 870 Core and 89 Iris tests passed, but the actual-touch test failed at the Plate/Rete opening assertion before reaching the new scrub interaction. Its recording shows the button remaining pressed; XCTest's tap synthesis took almost eight seconds. The failed app job was retried on the identical code with no assertion changes, and passed. The initial tap failure remains an observed intermittency; this retry does not identify its cause.

## Final evidence

- Code commit: `70490a518c65d494362db379d8d16f8437d9e32b`; tree `a4db61a2b710ba473ccc985852c73a27af6e58b0`.
- [Run 33800640778, attempt 2](https://github.com/huntarfischer/orbobuilder/actions/runs/33800640778/attempts/2): completed, success.
- Package: 959 tests / 0 failures. Xcode: 960 tests / 0 failures (870 Core + 89 Iris + one actual-touch UI test).
- Orbo and OrboLab: builds and simulator launches passed. Aegis, Pane, placement and live-ready markers were emitted by the real app.
- Final artifact: `9912470716`, `Astrolabe-Act-II-Evidence`, created 2026-09-03 20:52:52 UTC. The same-named artifact `9911476472` belongs to the failed first attempt and is not the final evidence.
- Inspected captures: real Aegis and Big Three, natal Pane, live refresh, actual Moon scrub, Moon FACT reading, Almanac LEDGER/body rail, twelve-seat Tabula, Hestia-restored night chart, and OrboLab contract/owner readout. The touch sequence also passed crowded Mercury/Venus selection, Plate/Rete seats, ASC reading, natal preservation during live updates, playback, and paused background/foreground return.
- Existing London and Sydney real-birth regressions remain green in the accumulated suite; the simulator interaction uses Ean Weslynn's night chart.
- Debug simulator timings: Spine load/assembly 220.947 s; first sky presentation 0.145 s; birth/Hearth delivery 0.594 s. The approximately 750-year development payload is unchanged.

## Remaining boundaries

Current real readers exercise FACT, RELATION and LEDGER. SPAN, nested TRACK and addressed PROSE contracts/renderers are present and tested; advanced dishes/corpus are not connected. Pythia's first timing route is future returns to the selected degree/direction. Artemis's Moon route supplies phase, illumination, mansion, next ingress, prepared contacts and eclipse chronology; it does not claim a full Luna windowed generator or infer void-of-course from absent rows.

Hestia restores native houses through codec 4. The center hold saves that native Hearth; arbitrary marked moments need existing custody to carry displayed UT/place before exact restoration can be offered. Hecate's composite destination exposes the earned Link read and explicitly leaves two-chart casting unavailable.

Existing debug runtime warnings about duplicated `BundleFinder` / `CSVLineReader` classes remain in standalone stderr. No crash occurred in this gate; linker cleanup is not claimed. Older-runtime execution is not established by the iPhone 17 Pro / iOS 26 simulator proof.

Do not promote beyond evidence. Expanded timing techniques, full Luna windowed techniques, composite casting, mark-moment journal metadata, onboarding/3D companion, older runtime execution and Spine consolidation are not claimed by this gate.
