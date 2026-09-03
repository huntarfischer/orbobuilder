# Astrolabe Act I gate — September 3, 2026

Status: **closed for Act I's Aegis, Big Three, and Lunar Pane FACT scope**. Acts II and III remain pending.

Plan: `specs/Astrolabe-Act-I.md`.

Required closure: accumulated Swift package tests; accumulated Orbo.xcodeproj tests; Orbo and OrboLab builds; visible Aegis, natal FACT Pane and selected placement; real-chart source correspondence; branch publication.

The final accepted implementation and its evidence are recorded below; earlier runs retain the construction trail.

## Initial native and visual proof

[Run 33728669362](https://github.com/huntarfischer/orbobuilder/actions/runs/33728669362), code `2c0b493a92078635929d8ddb6ae6d5fd73f961f5`, passed 940 Swift package tests and 940 Xcode tests (858 Core + 82 Iris), all with zero failures. Orbo and OrboLab built and launched. The real app emitted Hearth, Aegis, Pane, and selected-placement readiness markers.

All four screenshots in artifact `9883705029` were inspected. The natal Pane shows Ean's night chart, Sun in house 6 with Mars in Taurus as dispositor, and the kept condition path Sun → Mars → Venus. The header shows the separate displayed sky's ASC Cancer, Moon Taurus, and Sun Virgo.

The review exposed missing rendered bitmap artwork, excess Pane transparency, an overly low wheel, the wheel using natal house labels, and a misplaced live ASC. The next revision addresses those and captures returning to live sky. It adds a native bitmap decoding test. No final visual closure is claimed yet.

The first standalone Debug launch reached the Aegis screenshot about six minutes after launch. Duplicate-class linker warnings from the assembly pass remain present. This run does not qualify startup performance, a Release/device build, or execution before iOS 26.

## Revised visual proof and timer check

[Run 33731191472](https://github.com/huntarfischer/orbobuilder/actions/runs/33731191472), code `bc996f802dec97c53cc8e400d22024d4f42c1996`, passed 941 package tests and 941 Xcode tests (858 Core + 83 Iris), zero failures. All five screenshots in artifact `9884484327` were inspected. The artwork, rim ASC, sky house band, darker Pane, and current-time handoff render correctly. OrboLab's live-runtime directions now name the Astrolabe tab.

The live screenshot's clock appeared unchanged shortly after the return-to-live action. The view's long-lived task could capture the initial inactive scene state. The timer is now keyed to scene/tab activation, and the simulator proof requires a later real Horae frame after four seconds while the natal chart stays unchanged. The final run passed that explicit continuous-clock check.

## Final accepted gate

[Run 33733075809](https://github.com/huntarfischer/orbobuilder/actions/runs/33733075809), tested code `74a3476fe6c89cb4cf52585cbb77a8ec325f704b`: **passed**.

| Gate | Observed result |
| --- | --- |
| Full Swift package suite | 941 tests, zero failures |
| Complete Xcode suite | 858 Core + 83 Iris = 941 tests, zero failures |
| Orbo | Built, launched independently, and mounted the real sealed Spine |
| OrboLab | Built, launched, and its current foundation readout inspected |
| Real natal source | Ean's night chart; Scorpio ASC, Capricorn Moon, Aries Sun; kept positions, motion, houses and conditions agree |
| Other native subjects | London and Sydney birth paths passed; subjects, houses and dispositors remain independent |
| Live frame continuity | Horae JD advanced from `2461286.8600399564` to `2461286.860079701` after returning live; the entire natal chart remained equal |
| Visual review | Aegis, natal Pane, selected Sun, live sky and Lab screenshots all downloaded and inspected |

[Artifact 9885162555](https://github.com/huntarfischer/orbobuilder/actions/runs/33733075809/artifacts/9885162555) contains `OrboTests.xcresult`, the five screenshots, and application stdout/stderr. `ORBO_LIVE_READY` is emitted only after the Swift continuity assertion passes; the proof does not manually advance the clock during its waiting interval. Selection captures use the production application callbacks, rather than claiming automated fingertip interaction.

The accepted screens show both existing bitmap assets, the legible Big Three, a sky-oriented house band and rim ASC, the Sun-facing lunar disc, and the darker circular Pane. The selected natal Sun shows house 6, Mars in Taurus as dispositor, the Sun → Mars → Venus condition path, Mars bound and Venus face. The live screen shows a later sky with Leo rising while the same natal engraving remains present.

## Boundaries and remaining work

- This closes the first native instrument/FACT slice, not the whole Phase 11 prototype transcription. Finger-decoupled scrubbing, playback, aspect web/magnetism, Tabula behavior and Pane springs/lenses remain Act II. Further reading templates and technique/corpus connections remain Act III.
- The final run used an iPhone 17 Pro simulator on iOS 26.4.1. The deployment minimum remains iOS 17; execution on an older runtime or physical device was not tested.
- The final Debug launch took roughly five minutes to reach the first Aegis capture; the preceding run took roughly six. Startup performance is not qualified by this pass.
- The existing duplicate `BundleFinder` and `CSVLineReader` class warnings remain in the test-built app. A warning-free Release build is not claimed.
- The first local horizon uses the named birthplace. Saved profiles, arbitrary current-location selection, full Tapestry browsing and Natal Spine commissioning are outside this slice.

Celestial coordinates remain primary; civic time identifies the occurrence being displayed. The repository's existing Swift owners and one mounted Spine supply all celestial/astrological facts. No ephemeris runtime, synthetic sky, new non-Swift native dependency, or alternate authority was introduced. The prototype and sealed Spine files are unchanged, the previous assembled app is preserved under `Obsolete`, and no files were deleted. The active specification and Native Port Manifest are updated with this closure.
