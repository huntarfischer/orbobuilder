# OrboSpine II-C app boot gate — 2026-09-04

**Status:** LOCAL GREEN / CI PERFORMANCE GATE NOT YET ADDED

**Branch:** `feature/orbospine-shippable-iib-clean-2026-09-04`

**App-mount commit:** `357b0eed0562242362bb3cd00fd756eb2714cf62`

**Sealed-artifact commit:** `02895bdf9050626b4800926726efca80679bcdc5`

## Purpose

Record the first measured application boot after Orbo stopped reconstructing the universal Spine from the bundled `orbospine-build` source directory and began mounting the finished sealed `.orbospine` artifact directly.

This is the II-C architectural proof:

```text
OLD
OrboApp
→ bundled orbospine-build directory
→ OrboSpineRuntime.load(from:)
→ validate/read source files
→ reconstruct runtime

II-C
OrboApp
→ bundled orbo-v1.orbospine
→ OrboSpineRuntime.mount(from:expectedSHA256:)
→ one finished mapped Spine
→ Locate / Library / Link
```

No artifact-format change, Library redesign, new indexing, hash optimization, or Bone reduction was part of this pass.

## Artifact identity

The app-mounted artifact is the same deterministic II-B artifact already proven across all three doors and now stored in the repository through Git LFS.

```text
file       orbo-v1.orbospine
bytes      216,569,743
SHA-256    c009ee14231747e6409fb717027a12c74d3236cdd0646f9d8db4f978b0d29191
```

`OrboApp` supplies that SHA to `OrboSpineRuntime.mount(...)` at startup.

## Benchmark method

Three ordinary Debug simulator launches were performed locally from Xcode on the development Mac after the II-C mount change.

The launches used the normal app boot path. They were not the birth-proof, instrument-proof, or UI-proof command-line routes.

The production app emitted its existing stdout timing markers:

```text
ORBO_TIMING Spine artifact mount: <seconds>
ORBO_TIMING First sky presentation: <seconds>
ORBO_READY: real Spine mounted
```

## Results

| Run | Spine artifact mount | First sky presentation |
| --- | ---: | ---: |
| 1 | 2.656 s | 0.032 s |
| 2 | 3.326 s | 0.026 s |
| 3 | 2.550 s | 0.017 s |

Summary:

```text
Spine artifact mount
mean      2.844 s
median    2.656 s
fastest   2.550 s
slowest   3.326 s

First sky presentation
mean      0.025 s
```

## Relationship to the September 3 startup records

The existing September 3 gates remain historically correct and must not be rewritten.

They measured the superseded directory-reconstruction boot architecture:

```text
2026-09-03 Astrolabe Act I repass
Sealed Spine load and assembly    194.557 s

2026-09-03 Astrolabe Act II
Spine load and assembly           220.947 s
```

Those numbers describe `OrboSpineRuntime.load(from:)` rebuilding the runtime from the bundled source directory. They do not measure the II-C `.orbospine` artifact mount path.

The September 4 measurements therefore do not contradict the older gates. They measure a different and now-current boot architecture.

## Earned conclusion

The local II-C evidence supports the following claim:

> The current Orbo application can mount the finished 216,569,743-byte sealed OrboSpine in approximately 2.5–3.3 seconds in three ordinary local Debug simulator launches, with first-sky preparation taking approximately 0.02–0.03 seconds after mount.

The earlier approximately 195–221 second startup cost was dominated by runtime reconstruction, not by the existence of the approximately 206.5 MiB finished Spine or its approximately 750-year universal Bone.

For this local II-C proof, the runtime-reconstruction startup bottleneck is resolved.

## Boundaries

This gate does **not** claim:

```text
Release-device performance
older-iOS performance
GitHub-hosted-runner performance
an enforced CI startup threshold
that no future startup optimization can be useful
```

A future CI performance gate may establish a hosted-runner baseline. It is not required to preserve the validity of this local architectural benchmark.

The existing `orbospine-shippable-iib-clean.yml` remains a regression/equivalence gate and is not represented here as a performance benchmark.
