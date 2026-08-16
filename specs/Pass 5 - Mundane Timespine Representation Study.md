# Pass 5: Mundane Timespine Representation Study

**Status:** Data-forward stamped-body candidate under qualified Swiss audit. Mundane Timespine v1 is not sealed until the astronomical audit, shipped artifact installation, and accumulated native proof are green.

**Date:** 2026-08-16

---

# 1. Object

The Mundane Timespine is the universal celestial chronology carried by Orbo.

```text
same Mundane Timespine version
=
same universal sky
```

It exists between the Ephemeris and the rest of Orbo. Normal celestial traffic reads the Timespine rather than reopening the Ephemeris.

It must answer arbitrary supported time reads for:

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

with:

```text
celestial longitude
signed longitudinal speed
```

The Ascendant is not part of the Mundane Timespine. Horizon owns local geometry.

---

# 2. Prototype laws preserved

`mundane.js` contributes:

```text
universal native-independent artifact
same artifact for every reader
verified before shipping
compact runtime data
```

`timespine.js` contributes:

```text
chunkable construction
seam-safe manufacture
deterministic materialization
version identity
```

`fertilize.js` contributes:

```text
resumability
packing discipline
artifact ancestry
```

None of those prototype event tables is the native Mundane Timespine representation.

---

# 3. 4R

```text
Component: Mundane Timespine
4R: REPRODUCE
Parity: STRUCTURAL
Native owner: OrboCore / MundaneTimespine
```

The solved artifact laws survive. The JavaScript event-table representation does not.

---

# 4. Representation principle

Pass 5 initially optimized too aggressively for mathematical compactness.

The corrected Orbo rule is:

> The Timespine may interpolate its memory. It may not reinvent the heavens.

And the storage preference is:

> If explicit stamped celestial data costs only a modest number of megabytes more than a more abstract approximation, prefer the explicit data.

Orbo is a personal device. Package size is a constraint, not a command to discard useful celestial state.

The personal-era center of the chronology may also be denser than the historical/future edges while all supported years remain above the required fidelity floor.

---

# 5. Candidate A: uniform dense state knots

A simple six-hour position + speed knot for every body across 1700...2149 was estimated at roughly 55 MiB before packing.

It proved the data-first approach but wastes bytes by sampling Pluto as often as the Moon.

---

# 6. Candidate B: fixed-point Chebyshev segments

The first implemented native candidate used degree-7 body-specific Chebyshev segments and analytic differentiation.

After tightening Mercury to a one-day segment, its qualified full-range artifact measured:

```text
15,778,794 total bytes
3,944,640 Swiss sample nodes used to manufacture it
```

The qualified Swiss audit rejected it.

Representative failures included:

```text
Mercury   max angular residual   0.777965 arcsec
Venus     max angular residual   2.708060 arcsec
Mars      max angular residual   3.487476 arcsec
Jupiter   max angular residual   3.206779 arcsec
Saturn    max angular residual   5.832903 arcsec
Uranus    max angular residual   3.228505 arcsec
Neptune   max angular residual   5.015463 arcsec
Pluto     max angular residual   0.903975 arcsec
Node      max angular residual   0.299493 arcsec
```

Station-direction stress was particularly revealing:

```text
Pluto             348 mismatches at +/- 5 minutes
True North Node   236 mismatches at +/- 5 minutes
```

The failure is useful evidence. The polynomial candidate is retained as a benchmark, not protected as an architecture choice.

---

# 7. Candidate C: separate stamped body chronologies

The active candidate stores each body's actual Swiss-derived knots separately.

```text
Mundane Timespine v1
|
|-- manifest
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

Each knot stores:

```text
UInt32 longitude
Int32  signed longitudinal speed
```

Quantization:

```text
longitude       0.001 arcsecond
speed           0.001 arcsecond / day
bytes / knot    8
```

Runtime uses local cubic Hermite interpolation between the two adjacent stamped knots.

That interpolation uses actual stored longitude and speed at the bracketing times. It does not evaluate an orbital model or open the Ephemeris.

---

# 8. Body-specific and era-specific density

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
| Sun | 4 days | 1 day |
| Moon | 12 hours | 3 hours |
| Mercury | 1 day | 3 hours |
| Venus | 2 days | 12 hours |
| Mars | 4 days | 1 day |
| Jupiter | 8 days | 2 days |
| Saturn | 8 days | 2 days |
| Uranus | 8 days | 2 days |
| Neptune | 8 days | 2 days |
| Pluto | 8 days | 2 days |
| True North Node | 12 hours | 3 hours |

Mercury is intentionally dense. Its rapid apparent motion and station behavior justify spending bytes on temporal detail rather than asking a wider mathematical segment to recover it later.

The current profile contains:

```text
1,960,953 stamped knots
15,687,624 raw knot bytes
14.96 MiB raw knot payload
```

before the small per-body headers and manifest.

That is already approximately the same size as, and slightly below, the failed Chebyshev candidate.

Approximate raw knot payload by body:

```text
Sun               547,896 bytes
Moon            4,382,968 bytes
Mercury         3,360,296 bytes
Venus           1,095,760 bytes
Mars              547,896 bytes
Jupiter            273,968 bytes
Saturn             273,968 bytes
Uranus             273,968 bytes
Neptune            273,968 bytes
Pluto              273,968 bytes
True North Node  4,382,968 bytes
```

The body split means one body's density can be increased without inflating every other body.

---

# 9. Codec 2

The stamped-data representation is **Mundane Timespine codec 2**.

Each body file carries:

```text
body magic
Timespine codec
body identity
three temporal regions
position scale
speed scale
for each region:
    start JD
    end JD
    sample cadence
    sample count
    stamped position + speed knots
```

The JSON manifest carries:

```text
Timespine version
codec
AstroDNA codec compatibility
representation identity
astronomical source + version
supported range
dense range
scales
per-body cadence
per-body filename
per-body byte count
per-body SHA-256
```

Each body artifact has its own checksum. The manifest binds all eleven checksums into one Timespine version identity.

This allows corruption or later replacement to be located by body without weakening the one-version-one-sky law.

---

# 10. Forge law

The Forge is still the maker.

For Mundane Timespine v1 it:

```text
asks the qualified Ephemeris for the declared knot times
quantizes those actual celestial states
writes one body artifact per celestial occupant
writes the binding manifest
checksums every body
versions the resulting set
```

Construction remains resumable and deterministic.

The same source + plan must produce byte-identical artifacts whether manufactured in one run or resumed in bounded work chunks.

Later child spines remain Forge products, but they are forged from the Mundane Timespine and other canonical Orbo state. They do not reopen the Ephemeris.

---

# 11. Qualified source

Pass 4 remains authoritative:

```text
Swiss Ephemeris 2.10.03
qualified Swiss-file mode
DE441-derived .se1 data
no silent Moshier fallback
```

Pass 5 currently uses these four files for the 1700...2149 interval:

```text
sepl_12.se1
semo_12.se1
sepl_18.se1
semo_18.se1
```

They are presently committed under `tools/pass5/` as construction inputs. Their eventual distribution/licensing treatment remains a separate release gate and is not silently resolved by Pass 5.

The qualification adapter explicitly verifies Swiss-file mode and DE441 provenance at historical and modern probes.

---

# 12. Coordinate contract

The Forge source reads are:

```text
geocentric
tropical
ecliptic of date
standard apparent Swiss Ephemeris position
signed longitudinal speed
true / osculating North Node
```

No topocentric, sidereal, J2000, heliocentric, or geometric-true-position override belongs to Mundane Timespine v1.

---

# 13. Astronomical audit

The stamped artifact is independently decoded outside the Swift Forge and compared back to Swiss.

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

It tests quarter, midpoint, and three-quarter positions inside every stored interval plus deterministic random points.

Variable-motion bodies receive a separate station scan with probes on both sides of every discovered station.

Qualification thresholds currently are:

```text
edge maximum angular residual     <= 0.05 arcsecond
1950-2050 maximum residual        <= 0.01 arcsecond
p99.9 angular residual            <= 0.01 arcsecond
RingFineState agreement           >= 99.5%
motion agreement                  >= 99.999%
maximum speed residual            <= 0.005 degree/day
station mismatch at +/-5 minutes  0
```

If a body fails, increase that body's stamped density and forge again.

Do not weaken the fidelity requirement to save a small amount of package space.

---

# 14. Native proof

The earlier native candidate established the Forge -> artifact -> decode -> state-read pathway in Xcode and OrboLab:

```text
98 tests
98 passed
0 failures
```

Because codec 2 changes the representation, the accumulated native suite must run again before v1 is sealed.

The Pass 5 qualification workflow therefore separates:

```text
Ubuntu
    qualified Swiss manufacture + independent astronomical audit

macOS
    accumulated Apple Swift / OrboCore tests
```

Linux compiler behavior is not allowed to force unrelated edits to already-canonical Ring tests.

---

# 15. Completion gate

Pass 5 is complete only when:

```text
qualified Swiss-file source verified           PASS
stamped body profile audit                      PASS
station-direction audit                         PASS
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
