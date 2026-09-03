# Orbo app assembly — September 3, 2026

Branch: `feature/orbo-assembled-2026-09-02`; inspected base: `9be3d84`.

## Approved scope

1. Mount the existing sealed Z21–Z23 OrboSpine once and connect Iris through its existing port.
2. Connect Chronos, Hecate Link, and Homer before the full Engraving journey.
3. Complete the real birth-to-Hearth path with editable inputs, starting with Ean.

## Implementation

- `OrboSpineRuntime.load(from:)` transplants the D5 readers, the later boundary-anchor reader, and quoted-field CSV parsing from the certification tool. System zlib reads the existing CSV/gzip files on iOS; no new archive format, astronomy, or manufacture is introduced.
- Existing seal/testimony/manifest bindings and file hashes are checked before mounting. The sealed manifest includes Reign; the current runtime Library still exposes its existing F/R/W/Z interfaces. No new shell interface is claimed.
- The app bundles the existing `tools/pass5/orbospine-build` directory by reference. Loading occurs off the main actor. Failure is explicit; there is no synthetic fallback.
- Iris's port, frame, control session, and text view are reused. Only the 3D renderer requires iOS 26.
- `SpineLink` binds existing celestial member addresses to the mounted candidate hash and existing Locate authority. Hecate preserves N-way order and can supply the received values to its existing casting functions. This pass does not define other Spines' member syntax or new relation engines.
- Application delivery functions in `Onboarding/EngravingDelivery.swift` call the fixed existing itinerary and retain no state or domain authority. Orbo, Hermes, Atlas, Moirai, and Hestia keep their established jobs.
- The app exposes editable known-time birth input, actual kept AstroDNA, existing Big Three beats, Chronos queries, Hecate member reads, and Homer snapshots. Unknown birth times and ambiguous local times are not silently resolved.
- The original app harness and D5 executable are preserved under `native/OrboCore/Obsolete`.

## Validation status

- First native Swift compilation: passed on GitHub Actions run 33703678860.
- First real-file load: found the older CSV reader's quoted-field mismatch in the shell tables. Corrected using the existing certification parser.
- Added real-system proofs for Ean, London and Sydney inputs, canonical source identity, Chronos, Hecate Link and Fortune, independent Hearths, and failure to resolve a place.
- The original birth-to-Hearth red acceptance now continues through the production delivery function and real mounted source.
- Full package, accumulated Xcode tests, app/OrboLab builds, and live simulator proof: pending subsequent CI.

No green completion claim until those gates have run. The local editing host is Linux and has no Swift/Xcode installation.
