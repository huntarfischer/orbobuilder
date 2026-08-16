# Pass 5: Mundane Timespine Representation Study

**Status:** Data-forward separate-body codec 4 under qualified Swiss C audit. Mundane Timespine v1 is not sealed until the astronomical audit, shipped-artifact installation, accumulated native proof, and OrboLab readout are green.

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

with celestial longitude and motion. Its local position trajectory also supports a longitudinal-speed read without evaluating an orbital model. Horizon owns the Ascendant and other local geometry.

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

Package size remains a first-class construction measurement, but it is not by itself a reason to discard celestial resolution a personal device can afford. The 1950...2050 center may therefore be denser than the historical and future edges while the whole supported range remains above the fidelity floor.

Each body is stored separately so its density and storage cost can follow its own measured temporal behavior.

---

# 4. Candidate history

## Candidate A: uniform dense knots

A uniform dense chronology established the data-first idea but wastes bytes by sampling every body at the same rate regardless of actual motion.

## Candidate B: fixed-point Chebyshev segments

The first compact native candidate used degree-7 body-specific Chebyshev segments. With Mercury tightened to one-day segments it measured 15,778,794 bytes.

The qualified Swiss audit rejected it. Several bodies produced rare multi-arcsecond residuals and the station audit found direction mismatches for Pluto and the true Node.

Chebyshev remains benchmark evidence, not the v1 representation.

## Candidate C: stamped position + speed knots, codec 2

A later candidate stored actual Swiss-derived longitude and signed speed together in eleven separate body files.

It proved the separate-body artifact architecture, but it also showed that sampled velocity should not become a second runtime positional trajectory. Position identity and station chronology are cleaner authorities.

Codec 2 is superseded.

## Candidate D: position-first separate bodies, codec 3

Codec 3 moved to stamped longitude knots plus an explicit station chronology. It proved the ownership split and the independent-body artifact set.

Its first Apple-Swift run exposed an implementation seam defect: Forge can place the last knot exactly on a region boundary even when that last interval is shorter than the region's nominal cadence, while the local reader treated every knot as if it were uniformly spaced.

That defect was caught before canonicalization. Codec 3 is superseded rather than silently changing its binary meaning.

---

# 5. Active representation: codec 4

Mundane Timespine codec 4 is **position-first, separate-body, and losslessly packed**.

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

This is not eleven celestial authorities. The manifest binds all eleven body identities, checksums, profiles, source provenance, supported interval, dense interval, AstroDNA codec, and Timespine codec into one Mundane Timespine version.

Separate body files are storage and maintenance boundaries that let Forge spend bytes where the sky actually requires them.

---

# 6. Stored temporal facts

Each body file owns two kinds of canonical temporal fact.

## Position chronology

At each declared knot time Forge asks the qualified Ephemeris for apparent geocentric tropical longitude and stamps it at:

```text
0.001 arcsecond units
3,600,000 integer units per degree
1,296,000,000 integer units per circle
```

The longitude knots are the stored celestial memory.

## Motion chronology

Direct/retrograde transitions are stored as an explicit station chronology:

```text
initial motion
+
ordered station instant -> motion after station
```

Motion identity therefore does not depend on whether a local numerical derivative crosses zero a few minutes early or late.

A local derivative of the stamped position trajectory may supply longitudinal-speed magnitude. The station chronology supplies the canonical motion sign.

---

# 7. Local read law

An arbitrary-time read uses a small neighborhood of stored positions and local cubic interpolation.

```text
query instant
    |
    v
nearby stamped knots
    |
    v
local cubic interpolation
    |
    +-- longitude
    +-- local derivative magnitude

exact station chronology
    |
    +-- direct / retrograde sign
```

The interpolation only operates on Timespine memory. It never evaluates planetary elements, lunar theory, Swiss Ephemeris, JPL, or any other orbital model.

A temporal region's final knot may occur sooner than one nominal cadence after the preceding knot when Forge clamps that knot to the exact region boundary. Codec 4 therefore evaluates each selected knot at its **actual temporal coordinate** rather than assuming all selected knots are equally spaced.

The supported Timespine interval remains half-open. No interpolation result outside that interval is exposed as a supported read.

---

# 8. Lossless body packing

Explicit celestial data does not require every longitude knot to occupy four bytes on disk.

Codec 4 packs each region as:

```text
first position       absolute UInt32
first circular delta signed ZigZag varint
remaining positions  signed second-delta ZigZag varints
```

The circular first delta follows the shortest signed path across 0/360. Later values store changes in that delta.

Decoding reconstructs the exact original UInt32 position sequence. Packing therefore introduces **zero additional astronomical approximation**.

```text
compression of stored integers
!=
calculation of missing astronomy
```

The manifest records both encoded bytes and the equivalent unpacked UInt32 position bytes for each body so package-size decisions remain measurable rather than rhetorical.

---

# 9. Body and era density

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

The current fixture estimates about **47.1 MB** of position integers if every knot is stored naïvely as a raw UInt32. That is not the final package-size result. The codec-4 qualification run must report the actual packed body bytes, per-body bytes per knot, and complete Timespine size.

The storage allocation is intentionally uneven. Moon, Mercury, and the true Node can receive far more temporal detail than slow bodies without forcing every body to pay the same cost.

---

# 10. Artifact identity

Each `.orbbody` carries:

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
knot count
losslessly packed position knots
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
per-body encoded byte count
per-body knot count
per-body unpacked position bytes
per-body station count
per-body SHA-256
```

Thus:

```text
one version + one manifest + eleven bound body hashes
=
one universal shipped sky
```

---

# 11. Forge law

For Mundane Timespine v1 the Forge:

```text
asks the qualified Ephemeris for declared position-knot times
quantizes and stamps the longitudes
solves station transitions at construction time
stores the station chronology
losslessly packs each body's position integers
writes eleven independent body artifacts
writes the binding manifest
checksums every body
versions the resulting set
```

Construction remains deterministic and resumable.

Later child spines are also Forge products, but they are forged from the Mundane Timespine plus other canonical Orbo state and Loom results. Child spines do not reopen the Ephemeris.

---

# 12. Qualified astronomical source

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

It builds the official Swiss C library from that source and calls it directly. Python is construction orchestration, not the astronomical engine.

The accepted qualification `.se1` files are fetched from that same pinned source and must identify themselves as DE441. Returned calculation flags must remain Swiss-file mode.

Four similarly named `.se1` files are currently committed under `tools/pass5/`. Their filename alone does not make them authority. The qualification bench identifies them as older DE431 material, so they are not used to manufacture canonical Mundane Timespine v1. Their repository/distribution cleanup is a separate licensing task.

---

# 13. Coordinate contract

Forge reference reads are:

```text
geocentric
tropical
ecliptic of date
standard apparent Swiss Ephemeris position
true / osculating North Node
```

`SEFLG_SPEED` remains construction-time evidence for station solving and fidelity audit. Its sampled values are not stored as a parallel runtime position authority.

No topocentric, sidereal, J2000, heliocentric, or geometric-true-position override belongs to Mundane Timespine v1.

---

# 14. Astronomical and storage audit

The artifact is independently decoded outside Swift Forge and compared to the same pinned official Swiss C engine.

For codec 4 the auditor independently reconstructs:

```text
absolute first knot
circular first delta
signed second-delta varints
exact stamped integer sequence
actual temporal coordinate of a shortened final interval
```

For every body it records:

```text
maximum angular residual
maximum core angular residual
maximum edge angular residual
p99.9 and p99 angular residual
maximum speed residual
p99.9 speed residual
RingFineState agreement
motion agreement
worst measured point
encoded body bytes
knot count
unpacked position bytes
bytes per knot
encoded/unpacked ratio
```

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

If one body fails because its memory is too sparse, alter that body's density rather than weakening the gate.

---

# 15. Package-size decision rule

Pass 5 does not optimize for the smallest mathematical artifact at any cost.

> If a more explicit celestial dataset costs only a modest number of additional megabytes, prefer the explicit data.

The final profile is judged body by body on both:

```text
astronomical fidelity
actual encoded bytes
```

The dense 1950...2050 center is allowed to spend more bytes because it serves the overwhelming majority of personal-era natal and derived Orbo work. The edges remain complete and must still satisfy the declared fidelity floor.

---

# 16. Native proof state

The earlier Chebyshev construction candidate completed a 98/98 Xcode proof and OrboLab runtime readout before astronomical qualification rejected that representation.

The separate-body path has already proven independent body checksums, deterministic resumable manufacture, manifest binding, station chronology, and codec round-trip.

The first Apple-Swift position-first run then exposed the irregular-final-knot interpolation defect described above. Codec 4 corrects that reader law and changes the body binary format for lossless second-delta packing.

A fresh accumulated Apple-Swift run is required. No prior green count is reused as proof of codec 4.

---

# 17. Completion gate

Pass 5 is complete only when:

```text
qualified official Swiss C source verified     PASS
codec-4 independent decode audit                PASS
stamped body astronomical audit                 PASS
station chronology audit                        PASS
actual encoded bytes measured per body          PASS
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
