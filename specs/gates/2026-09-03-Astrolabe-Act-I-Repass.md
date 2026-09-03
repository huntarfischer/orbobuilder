# Astrolabe Act I correction gate

Status: implemented; native validation pending.

Branch: `feature/astrolabe-lunar-pane-swift-2026-09-03`, starting from `7050b48`.

The pass follows the user's five prototype screenshots and the matching source in `Orbo Astrolabe.dc.html`. Scope and pending Acts II/III are recorded in `specs/Astrolabe-Act-I.md`.

Required evidence: full package and Xcode suites; actual taps selecting both Mercury and Venus from their crowded natal location; raised/lowered Pane, chart seats, live clock continuity and retained natal reading; Orbo/OrboLab builds and captures; measured Spine load, first presentation and Hearth delivery. Preserve original implementations, sealed Spine and prototype.

Native bottom navigation is removed. Temporary Orbo-menu routes retain the existing Hearth, Text and Inspect screens until the Tabula is transcribed. The menu is not the final Tabula design.

## First native run

Code `6b0cb0b2ece881ac1c479f74efdec91ed79b22d5`, [run 33779289503](https://github.com/huntarfischer/orbobuilder/actions/runs/33779289503): the full package suite passed 943 tests with zero failures. The first sealed-runtime integration test took 228.681 seconds; the complete test suite took 253.765 seconds. This identifies mounting as the dominant package-test cost, but does not yet measure the separate app startup phases.

Xcode, touch and screenshot results pending.

The first Xcode run passed 858 Core and 85 Iris tests (943 total, zero failures), and built OrboLab. The new UI test failed before its first interaction: the root `accessibilityIdentifier` propagated to every child control. The failure's accessibility hierarchy and recorded screen prove that the real natal instrument loaded, but each button was exposed as `orbo.astrolabe`. The correction uses accessibility containment and identifiers on the individual controls. It does not bypass the touch test or change its natal source.

The same captured screen showed excess vertical spacing and the lowered Pane ending above the bottom safe area. The correction tightens the header/wheel spacing and extends the Pane to the bottom edge. First-run artifact: 9903672315. Final closure awaits the rerun.
