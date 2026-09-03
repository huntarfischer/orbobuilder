# Astrolabe Act I gate — September 3, 2026

Status: initial native gate passed; visual corrections under validation.

Plan: `specs/Astrolabe-Act-I.md`.

Required closure: accumulated Swift package tests; accumulated Orbo.xcodeproj tests; Orbo and OrboLab builds; visible Aegis, natal FACT Pane and selected placement; real-chart source correspondence; branch publication.

No gate is promoted before results are recorded here.

## Initial native and visual proof

[Run 33728669362](https://github.com/huntarfischer/orbobuilder/actions/runs/33728669362), code `2c0b493a92078635929d8ddb6ae6d5fd73f961f5`, passed 940 Swift package tests and 940 Xcode tests (858 Core + 82 Iris), all with zero failures. Orbo and OrboLab built and launched. The real app emitted Hearth, Aegis, Pane, and selected-placement readiness markers.

All four screenshots in artifact `9883705029` were inspected. The natal Pane shows Ean's night chart, Sun in house 6 with Mars in Taurus as dispositor, and the kept condition path Sun → Mars → Venus. The header shows the separate displayed sky's ASC Cancer, Moon Taurus, and Sun Virgo.

The review exposed missing rendered bitmap artwork, excess Pane transparency, an overly low wheel, the wheel using natal house labels, and a misplaced live ASC. The next revision addresses those and captures returning to live sky. It adds a native bitmap decoding test. No final visual closure is claimed yet.

The first standalone Debug launch reached the Aegis screenshot about six minutes after launch. Duplicate-class linker warnings from the assembly pass remain present. This run does not qualify startup performance, a Release/device build, or execution before iOS 26.
