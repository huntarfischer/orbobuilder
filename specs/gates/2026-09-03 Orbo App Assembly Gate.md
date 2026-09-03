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
- OrboLab's retired P22 diagnostics are preserved under `Obsolete/AppHarness/OrboLabApp.swift`; its active readouts use current OrboSpine contracts, the three doors, and existing foundation examples. Actual mounted runtime inspection lives in Orbo.
- Xcode now includes the complete existing Iris test folder. Its older explicit list omitted 31 Iris/Homer port tests that Swift Package Manager already ran.

## Validation status

### User-directed Sect correction

The real-source acceptance exposed a reversed semicircle in the existing `OrboFormulae.sect`. The user explicitly confirmed that Ean's chart is **night** and directed the tests to require it. The single existing Sect formula is corrected: the Sun strictly between Ascendant and Descendant in increasing zodiac longitude is below the horizon (night); the opposite semicircle is day. Existing exact-horizon day treatment is retained. Hecate and Clotho continue calling that one formula. The real-source test requires night and Fortune near 325.04°; unit-test expectations for the reversed rule are corrected, including the older synthetic Clotho slice, which is a different sky from Ean's real chart.

### Gate runs

- First native Swift compilation: passed on GitHub Actions run 33703678860.
- First real-file load: found the older CSV reader's quoted-field mismatch in the shell tables. Corrected using the existing certification parser.
- Added real-system proofs for Ean, London and Sydney inputs, canonical source identity, Chronos, Hecate Link and Fortune, independent Hearths, and failure to resolve a place.
- The original birth-to-Hearth red acceptance now continues through the production delivery function and real mounted source.
- Run 33705427645 passed 933 package tests and the previously configured 902 Xcode tests (853 Core + 49 Iris). OrboLab failed on retired P22 references. The Lab references and the 31-test Xcode membership gap are corrected for the next gate.
- Final [run 33706843653](https://github.com/huntarfischer/orbobuilder/actions/runs/33706843653), tested code `2a63e71c122eef577f08d8476ce1300f6009d015`: **passed**.

| Gate | Observed result |
| --- | --- |
| Full Swift package suite | 933 tests, zero failures |
| Complete Xcode suite | 853 Core + 80 Iris = 933 tests, zero failures |
| Orbo app | Built and launched independently after testing |
| OrboLab | Build passed with current contracts |
| Actual app birth-to-Hearth | `ORBO_HEARTH_LIT: Ean Weslynn; Scorpio / Capricorn / Aries` |
| Actual runtime mount | `ORBO_READY: real Spine mounted` |
| Screenshot inspection | Editable birth form, Hearth lit, Sect night; Ascendant 11.48° Scorpio, Moon 7.55° Capricorn, Sun 21.14° Aries |

The runner used Xcode 26.6 and an iPhone 17 Pro simulator on iOS 26.4.1. The app/package deployment minimum remains iOS 17. The local editing host is Linux and has no Swift/Xcode installation.

The [Orbo-Assembled-Evidence artifact](https://github.com/huntarfischer/orbobuilder/actions/runs/33706843653/artifacts/9875937829) contains the Xcode result bundle, app stdout/stderr, and `Orbo-Birth-Hearth.png`. The screenshot and both app logs were downloaded and inspected.

The sealed Spine files remain unchanged. Mounted candidate manifest SHA-256: `d4423805bf03c2306579d18b6ef8ec3a149ff56771be24c73e06b837239c5935`.

### Practical limits observed

- The standalone Debug app took approximately four minutes from process launch (02:29:23 UTC) to the captured Hearth completion (02:33:22 UTC). Loading is off the main actor and occurs once per app process. This is a correctness gate, not a startup-performance qualification.
- The test-built app emitted duplicate-class warnings for the SwiftPM `BundleFinder` and the reader's private `CSVLineReader`, loaded from both the package product framework and `Orbo.debug.dylib`. The app completed its journey without a crash; a warning-free Release/device build is not established by this gate.
- A pre-iOS-26 device/runtime was not exercised. The default text path and guarded 3D path compile with the iOS 17 deployment target.
- Inputs currently use known local birth times. Ambiguous places/times and nonexistent times produce explicit failures. Each submission creates an independent subject/Hearth for the current run; this pass does not add saved-profile persistence.

## Run the assembled app

Open `native/Orbo.xcodeproj` on this branch, select the **Orbo** scheme, and run. After the Spine opens, the **Birth** form starts with Ean's editable inputs; select **Begin**. **Sky** displays the real Horae frame through Iris, and **Inspect** exposes the existing Chronos, Hecate, and Homer connections. The simulator proof's `--orbo-birth-proof` argument only auto-submits those same fields through the same application function.
