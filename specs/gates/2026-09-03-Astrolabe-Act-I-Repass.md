# Astrolabe Act I correction gate

Status: passed for the Act I correction scope on iPhone 17 Pro / iOS 26.4.1. Startup performance and older-runtime execution remain open.

Branch: `feature/astrolabe-lunar-pane-swift-2026-09-03`, starting from `7050b48`.

The pass follows the user's five prototype screenshots and the matching source in `Orbo Astrolabe.dc.html`. Scope and pending Acts II/III are recorded in `specs/Astrolabe-Act-I.md`.

Required evidence: full package and Xcode suites; actual taps selecting both Mercury and Venus from their crowded natal location; raised/lowered Pane, chart seats, live clock continuity and retained natal reading; Orbo/OrboLab builds and captures; measured Spine load, first presentation and Hearth delivery. Preserve original implementations, sealed Spine and prototype.

Native bottom navigation is removed. Temporary Orbo-menu routes retain the existing Hearth, Text and Inspect screens until the Tabula is transcribed. The menu is not the final Tabula design.

## First native run

Code `6b0cb0b2ece881ac1c479f74efdec91ed79b22d5`, [run 33779289503](https://github.com/huntarfischer/orbobuilder/actions/runs/33779289503): the full package suite passed 943 tests with zero failures. The first sealed-runtime integration test took 228.681 seconds; the complete test suite took 253.765 seconds. This identifies mounting as the dominant package-test cost, but does not yet measure the separate app startup phases.

The first Xcode run passed 858 Core and 85 Iris tests (943 total, zero failures), and built OrboLab. The new UI test failed before its first interaction: the root `accessibilityIdentifier` propagated to every child control. The failure's accessibility hierarchy and recorded screen prove that the real natal instrument loaded, but each button was exposed as `orbo.astrolabe`. The correction uses accessibility containment and identifiers on the individual controls. It does not bypass the touch test or change its natal source.

The same captured screen showed excess vertical spacing and the lowered Pane ending above the bottom safe area. The correction tightens the header/wheel spacing and extends the Pane to the bottom edge. First-run artifact: 9903672315. Final closure awaits the rerun.

## Corrected native run

[Run 33782473759](https://github.com/huntarfischer/orbobuilder/actions/runs/33782473759), code `53e7d40bdd0d163ca8463b616d8e39047fe14dd7`: package regression passed 943 tests with zero failures. Xcode passed 944 tests: 858 Core, 85 Iris and one actual-touch UI test. Orbo and OrboLab built and launched. The standalone real-Spine proof completed all stages.

The touch test selected both Mercury and Venus from the same crowded natal location, opened and closed the Pane, exposed both chart seats, verified selected ASC feedback, visited the Hearth and returned to its natal reading, and observed the live clock advance without changing the natal Sun row. There is no native bottom bar. The clock’s accessible text now includes the same seconds and timezone as its visible text. The Moon’s lighting uses the actual staggered Sun and Moon screen positions.

Artifact `9904940378` contains the XCResult, six actual-touch screenshots, standalone Aegis/Pane/selected-placement/live captures, OrboLab capture, and app logs. Visual inspection of the instrument, Pane, seats, crowded choice, Mercury, Venus, live sky and Lab confirmed the intended hierarchy and reading results. The preserved Lab readout still uses the older wording “Astrolabe and Inspect tabs”; application navigation now uses the Orbo menu.

## Measured startup and limits

Standalone Debug simulator measurements from `Orbo-stdout.log`:

| Stage | Seconds |
| --- | ---: |
| Sealed Spine load and assembly | 194.557 |
| First sky data/presentation preparation | 0.043 |
| Birth engraving and Hearth delivery | 0.802 |

The first-sky timer measures preparation, not the display compositor's first visible frame. These are one runner's Debug measurements, not a device or Release benchmark. Mounting dominates this run. The sealed loader is unchanged; optimizing it remains a separate measured follow-up. Natal delivery is the real Ean night-chart route through Hermes, Moirai and Hestia. Existing regression also covers the London and Sydney births.

The standalone live proof advanced JD `2461287.227299907` to `2461287.2273373907` while asserting retained natal equality. The UI proof uses a fixed real Spine moment only to make crowded selection reproducible, then returns to live time through an actual tap.

Xcode 26.6 ran on iOS 26.4.1. Installed iOS runtimes were 26.2, 26.4.1 and 26.5; no pre-26 runtime was available, so older-iOS execution is not qualified by this gate. XCResult also records a non-fatal SwiftUI `_UIReparentingView` diagnostic during the successful UI run; no interaction failure or broken layout was observed in its captures.

Act II scrubbing, playback, aspect web/magnetism, full Tabula and Pane dynamics remain unimplemented by this correction pass. Onboarding, composite chart swapping, persistence and a full Tapestry browser are likewise outside this gate.
