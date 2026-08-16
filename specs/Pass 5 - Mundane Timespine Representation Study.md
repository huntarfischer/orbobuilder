# Pass 5: Mundane Timespine Representation Study

**Status:** Position-first codec 3 candidate under qualified official Swiss C audit. Mundane Timespine v1 is not sealed until astronomical qualification, shipped-artifact installation, accumulated native proof, and OrboLab proof are green.

**Date:** 2026-08-16

---

# 1. Object

The Mundane Timespine is the universal celestial chronology carried by Orbo.

```text
same Mundane Timespine version
=
same universal sky
```

It sits between the Ephemeris and the rest of Orbo. Normal celestial traffic reads the Timespine rather than reopening the Ephemeris.

It must answer arbitrary supported-time reads for:

```text
Sun
Moon
Mercury
Venus
Mars
Jupiter
Saturn
Uranus
Neptune
Pluto
True / osculating North Node
```

The Ascendant is not part of the Mundane Timespine. Horizon owns local geometry.

---

# 2. 4R

```text
Component: Mundane Timespine
4R: REPRODUCE
Parity: STRUCTURAL
Native owner: OrboCore / MundaneTimespine
```

The prototype contributes the universal-artifact, deterministic-manufacture, resumability, seam-safety, version-identity, and packed-read laws. Its JavaScript event tables do not survive as the native representation.

---

# 3. Data law

The Timespine is a data organ, not a disguised runtime ephemeris.

> The Timespine may interpolate its memory. It may not reinvent the heavens.

When explicit stamped celestial data costs only a modest number of megabytes more than a more abstract approximation, Orbo prefers the explicit data.

Package size matters, but it is not a reason to discard celestial resolution that a personal device can afford. The 1950...2050 center may therefore be denser than the historical and future edges while the whole supported range remains above the fidelity floor.

Each body is stored separately so its density can follow its own apparent motion and measured reconstruction error.

---

# 4. Candidate history

## Candidate A: uniform dense knots

A six-hour position + speed knot for every body across 1700...2149 was estimated around 55 MiB before packing. It proved the data-first idea but wasted bytes by sampling Pluto as often as the Moon.

## Candidate B: fixed-point Chebyshev segments

The first native candidate used degree-7 body-specific Chebyshev segments. With Mercury tightened to one-day segments it measured 15,778,794 bytes.

The qualified Swiss audit rejected it. Several bodies missed the position gate by multiple arcseconds and station-direction checks found hundreds of mismatches for Pluto and the true Node.

Chebyshev remains benchmark evidence, not the v1 representation.

## Candidate C: stamped position + speed knots, codec 2

The next candidate stored actual Swiss-derived longitude and signed speed together in eleven separate body files.

It proved the separate-body artifact architecture but exposed a more important problem: isolated Swiss `SEFLG_SPEED` discontinuities can be harmless to the longitude trajectory yet become destructive Hermite tangents. Making the body data denser did not solve that ownership problem.

The same speed behavior was reproduced against the pinned official Swiss C library directly, so it was not treated as a Python-wrapper artifact.

Codec 2 is therefore superseded.

---

# 5. Active representation: codec 3

Mundane Timespine codec 3 is **position-first**.

```text
Mundane Timespine v1
|
|-- mundane-timespine-v1.json
|-- sun.orbbody
|-- moon.orbbody
|-- mercury.orbbody
|-- venus.orbbody
|-- mars.orbbody
|-- jupiter.orbbody
|-- saturn.orbbody
|-- uranus.orbbody
|-- neptune.orbbody
|-- pluto.orbbody
`-- true-north-node.orbbody
```

Each ordinary celestial knot stores only:

```text
UInt32 longitude
```

at:

```text
0.001 arcsecond positional quantum
4 bytes / knot
```

Each body also carries a small explicit motion chronology:

```text
initial motion
station Julian Day
motion after station
station Julian Day
motion after station
...
```

Runtime state is then produced from two kinds of stored temporal fact:

```text
position knots
    -> local polynomial read
    -> longitude
    -> local derivative magnitude

station chronology
    -> direct / retrograde sign
```

The Timespine does not evaluate an orbital model and does not reopen the Ephemeris.

Velocity remains a pointwise node fact, but its local magnitude is reconstructed from the stamped positional trajectory while its direction is anchored to explicitly stamped station chronology.

---

# 6. Body and era density

Supported interval:

```text
1700-01-01 00:00
through
2150-01-01 00:00 exclusive
```

Dense personal-era interval:

```text
1950-01-01 00:00
through
2050-01-01 00:00 exclusive
```

Current qualification profile:

| Body | Edge cadence | 1950-2050 cadence |
|---|---:|---:|
| Sun | 2 days | 1 day |
| Moon | 6 hours | 3 hours |
| Mercury | 2 hours | 30 minutes |
| Venus | 6 hours | 1.5 hours |
| Mars | 12 hours | 3 hours |
| Jupiter | 12 hours | 3 hours |
| Saturn | 1 day | 3 hours |
| Uranus | 6 hours | 1.5 hours |
| Neptune | 12 hours | 3 hours |
| Pluto | 12 hours | 3 hours |
| True North Node | 3 hours | 30 minutes |

The pinned candidate fixture estimates:

```text
47,080,276 raw positional bytes
```

before the small body headers, station tables, and binding manifest.

This is not a file-size target that may override fidelity. It is the cost of the current measured candidate. If the audit says one body needs more data, that body changes independently.

---

# 7. Local read law

A production v1 region normally has many knots. Runtime reads the nearest four stamped positions and performs local cubic interpolation. The derivative of that local polynomial supplies speed magnitude.

Tiny construction fixtures are also legal artifacts. When a region has only three knots, the same local interpolation machinery becomes quadratic; with two knots it becomes linear. This keeps the codec valid for microscopes and tests without weakening the production v1 representation.

No interpolation may cross from unsupported time into a user-visible answer.

---

# 8. Guard-knot seam law

Every stored knot must remain on the cadence declared by its region.

If a region boundary is not an exact multiple of that cadence, Forge must **not** move the final knot onto the boundary. Doing so would create one irregular interval while the reader continued to interpret the series as uniformly sampled.

Instead:

```text
region start
  + n * cadence
  + n * cadence
  + n * cadence
  + guard knot just beyond region end when necessary
```

The final cadence-aligned position may lie just beyond the region boundary solely as a read-only interpolation guard.

The supported Timespine interval remains half-open. The guard interval itself is never exposed as supported runtime time.

This law is generic codec seam safety, not a special case for the 1700/1950/2050/2150 v1 boundaries.

---

# 9. Artifact identity

Each `.orbbody` contains:

```text
body magic
Timespine codec
body identity
position scale
initial motion
station chronology
three temporal regions
region start / end
region cadence
position count
UInt32 position knots
```

The JSON manifest binds:

```text
Timespine version
codec
AstroDNA codec compatibility
representation identity
astronomical source + version
supported range
dense range
per-body cadence
per-body filename
per-body byte count
per-body station count
per-body SHA-256
```

Thus:

```text
one version + one manifest + eleven bound body hashes
=
one universal shipped sky
```

Separate body files are storage and maintenance boundaries, not eleven independent authorities.

---

# 10. Forge law

For Mundane Timespine v1 the Forge:

```text
asks the qualified Ephemeris for declared position-knot times
keeps every knot cadence-aligned
quantizes and stores the positions
solves station transitions at construction time
stores the station chronology
writes eleven independent body artifacts
writes the binding manifest
checksums every body
versions the resulting set
```

Construction remains deterministic and resumable.

Later child spines are also Forge products, but they are forged from the Mundane Timespine plus other canonical Orbo state and Loom results. Child spines do not reopen the Ephemeris.

---

# 11. Qualified astronomical source

Pass 4 remains authoritative:

```text
Swiss Ephemeris 2.10.03
Swiss-file mode
2026 DE441-derived .se1 data
no silent Moshier fallback
```

The qualification bench pins the official Swiss repository at:

```text
3fd0f956d73898b91cc4f67cf18b21af656d1342
```

It builds `libswe.so` from the official C source and calls that library directly through `ctypes`. Python is construction orchestration, not the astronomical engine.

The audit downloads the `.se1` files from the same pinned official commit and verifies they identify as the DE441 generation.

Four similarly named `.se1` files are currently committed under `tools/pass5/`. They identify as older DE431 files and are therefore not accepted as the Mundane Timespine v1 authority. They remain untouched pending later distribution/licensing cleanup.

---

# 12. Coordinate contract

Forge reference reads are:

```text
geocentric
tropical
ecliptic of date
standard apparent Swiss Ephemeris position
true / osculating North Node
```

`SEFLG_SPEED` remains construction-time evidence used to solve motion transitions and audit local velocity behavior. Its sampled values are not stored as runtime interpolation tangents in codec 3.

No topocentric, sidereal, J2000, heliocentric, or geometric-true-position override belongs to Mundane Timespine v1.

---

# 13. Astronomical audit

The artifact is independently decoded outside Swift Forge and compared to the same pinned official Swiss C engine.

For every body the audit measures:

```text
maximum angular residual
maximum core angular residual
maximum edge angular residual
99.9-percentile angular residual
99-percentile angular residual
maximum speed residual
99.9-percentile speed residual
RingFineState agreement
motion agreement
worst measured point
```

The audit probes quarter, midpoint, and three-quarter positions inside every stored interval plus deterministic random points.

Every stored station receives before/after motion probes.

Current construction gates remain:

```text
edge maximum angular residual     <= 0.05 arcsecond
1950-2050 maximum residual        <= 0.01 arcsecond
p99.9 angular residual            <= 0.01 arcsecond
RingFineState agreement           >= 99.5%
motion agreement                  >= 99.999%
maximum speed residual            <= 0.005 degree/day
station mismatch at +/-5 minutes  0
```

These are construction fidelity gates, not astrological orb tolerances.

If one body fails because its position memory is too sparse, change that body's density rather than weakening the gate.

---

# 14. Native proof

The native Forge, codec, per-body checksum behavior, deterministic resumability, position interpolation, station chronology, 0/360 handling, half-open range law, and artifact round-trip all have dedicated XCTest coverage.

The accumulated suite target remains 98 tests.

Final v1 still requires a fresh Apple Swift proof after the candidate passes astronomical audit and the shipped v1 body files are installed as resources.

---

# 15. Completion gate

Pass 5 is complete only when:

```text
qualified official Swiss C source verified     PASS
position profile astronomical audit             PASS
station chronology audit                        PASS
final body-specific density frozen              PASS
11 immutable body artifacts created             PASS
binding v1 manifest created                     PASS
all SHA-256 identities recorded                 PASS
artifact set bundled with OrboCore               PASS
runtime loader reads shipped v1                  PASS
accumulated native tests                         PASS
OrboLab reads shipped v1                         PASS
Native Port Manifest updated                     PASS
```

Only then may Mundane Timespine v1 become **NATIVE CANONICAL** and Pass 6 become ready.
