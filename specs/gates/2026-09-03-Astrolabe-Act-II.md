# Astrolabe Act II gate — 2026-09-03

Status: open; final implementation and verification in progress.

Branch: `feature/astrolabe-lunar-pane-swift-2026-09-03`.
Base: Act I repass `76a2dcdbdb46575f3d2c13e26587755e6280c342`.

Native XCTest additions cover Lunar whole-reading refusals, house subject qualification, nested track ranges/raw overflow, Valens span overflow, addressed prose absence, relative scrub/wrap/radius/domain, real Spine frame consistency, Chronos/Pythia doors, Tabula owner routing and velocity-carrying presentation springs.

First run 33797380511 / commit `861ce67`: 956 package tests and the accumulated Xcode/touch test stages passed. Orbo and OrboLab built and launched. Artifact 9910462423 contains the captures. Spine load/assembly: 225.854 s; first sky preparation: 0.152 s; birth/Hearth delivery: 0.826 s. The full development payload remains unchanged.

Visual inspection found a pickup defect despite that first touch test passing: the Moon overlapped a later-painted Uranus button, so a drag addressed to the Moon moved Uranus's much slower gear. The initial assertion only established that the sky changed. Correction: one wheel-level nearest-placement hit map, a single frozen pickup per drag, and the actual Horae body-focus path. The strengthened touch assertion must see the Moon as the temporal gear; a geometry regression covers overlapping Moon/Uranus and natal priority. This result is not closed until that corrected build passes.

Package count/failures: pending.
Accumulated Xcode count/failures: pending.
Orbo/OrboLab builds and live readouts: pending.
Simulator interaction captures: pending.

Do not promote beyond evidence. Expanded timing techniques, full Luna windowed techniques, composite casting, mark-moment journal metadata, onboarding/3D companion, older runtime execution and Spine consolidation are not claimed by this gate.
