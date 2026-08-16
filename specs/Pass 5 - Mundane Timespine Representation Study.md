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

with celestial longitude and signed longitudinal speed. Horizon owns the Ascendant and other local geometry.

---

# 2. 4R

```text
Component: Mundane Timespine
4R: REPRODUCE
Parity: STRUCTURAL
Native owner: OrboCore / MundaneTimespine
```

The prototype laws that survive are the universal artifact, deterministic manufacture, resumability, version identity, seam safety, and packed runtime reads. The old JavaScript event tables do not survive as the native representation.

---

# 3. Representation principle

The Timespine is a data organ, not a disguised runtime ephemeris.

> The Timespine may interpolate its memory. It may not reinvent the heavens.

When explicit stamped celestial data costs only a modest number of megabytes more than a more abstract approximation, Orbo prefers the explicit data.

Package size matters, but it is not a reason to discard celestial resolution that the personal device can afford. The 1950...2050 personal-era center may therefore be denser than the historical and future edges while all supported years still satisfy the fidelity floor.

---

# 4. Candidate history

## A. Uniform dense knots

A six-hour position + speed knot for every body across 1700...2149 was estimated around 55 MiB before packing. It established the data-first reference idea, but wastes bytes by sampling every body at the same rate.

## B. Fixed-point Chebyshev segments

The first implemented candidate used degree-7 body-specific Chebyshev segments. With Mercury tightened to one-day segments it measured 15,778,794 total bytes.

The qualified Swiss audit rejected it. Maximum errors included several arcseconds for Venus through Neptune and the station audit found 348 Pluto and 236 true-Node direction mismatches at +/-5 minutes.

The polynomial implementation remains useful benchmark evidence. It is not the v1 representation.

## C. Separate stamped body chronologies

The active representation stores each body's actual Swiss-derived knots separately:

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
8 bytes total
```

Both quantities are quantized at 0.001 arcsecond units. Runtime uses local cubic Hermite interpolation between adjacent stored knots. The interpolation sees only stamped celestial data. It does not evaluate an orbital model or call the Ephemeris.

---

# 5. Codec 2

The stamped representation is **Mundane Timespine codec 2**.

Each body artifact carries its own identity, scales, temporal regions, cadences, knots, and SHA-256. A small JSON manifest binds all eleven body checksums into one versioned Timespine.

This gives Orbo both laws at once:

```text
one Timespine version = one universal sky
```

and:

```text
each body may carry the density its actual motion requires
```

A corrupted or later changed body can therefore be identified independently without turning the Timespine into eleven unrelated authorities.

---

# 6. First stamped qualification

The first stamped profile used a 1950...2050 dense center but remained deliberately modest, totaling 15,692,301 bytes including headers and manifest.

That run proved the codec and the body-separated architecture, but the astronomical audit showed that the cadences were too sparse. Sun and Moon were already close to the construction gate. Mercury, apparent geocentric outer planets, and especially the true Node needed more stored temporal detail.

The failure was treated as a density measurement, not as permission to weaken the fidelity gate.

---

# 7. Second stamped qualification profile

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

Current profile:

| Body | Edge cadence | 1950-2050 cadence |
|---|---:|---:|
| Sun | 2 days | 1 day |
| Moon | 6 hours | 3 hours |
| Mercury | 6 hours | 1.5 hours |
| Venus | 1 day | 6 hours |
| Mars | 2 days | 12 hours |
| Jupiter | 2 days | 12 hours |
| Saturn | 2 days | 12 hours |
| Uranus | 1 day | 6 hours |
| Neptune | 1 day | 6 hours |
| Pluto | 2 days | 12 hours |
| True North Node | 3 hours | 30 minutes |

The profile contains 6,145,289 stamped knots and 49,162,312 raw knot bytes, approximately **46.9 MiB** before the small headers and manifest.

The storage increase is intentionally uneven. The true Node and Mercury receive far more data than slow outer bodies because measured curvature and station behavior require it. This is the reason the body files are separate.

This profile is a measured candidate, not a final frozen allocation. The qualified Swiss audit decides whether any one body can be relaxed or must become denser.

---

# 8. Forge law

For Mundane Timespine v1 the Forge:

```text
asks the qualified Ephemeris for declared knot times
quantizes those actual celestial states
writes one body artifact per celestial occupant
writes the binding manifest
checksums every body
versions the resulting set
```

Construction is deterministic and resumable. The same source and plan must produce byte-identical output whether manufactured in one run or resumed in bounded chunks.

Later child spines remain Forge products, but are forged from the Mundane Timespine plus other canonical Orbo state and Loom results. Child spines do not reopen the Ephemeris.

---

# 9. Qualified source

Pass 4 remains authoritative:

```text
Swiss Ephemeris 2.10.03
Swiss-file mode
2026 DE441-derived .se1 data
no silent Moshier fallback
```

The qualification workflow fetches the official current files into a temporary construction workspace and verifies DE441 provenance at historical and modern probes.

Four similarly named `.se1` files are currently committed under `tools/pass5/`. They identify as older DE431 files and are therefore **not** accepted as the Mundane Timespine v1 source. They remain untouched pending the separate distribution/licensing cleanup. Filename similarity is not authority.

---

# 10. Coordinate contract

Forge reference reads are:

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

# 11. Astronomical audit

The artifact is independently decoded outside the Swift Forge and compared back to Swiss.

For every body the audit checks quarter, midpoint, and three-quarter positions inside every stored interval plus deterministic random points. It records maximum and percentile angular residual, core versus edge residual, speed residual, RingFineState agreement, motion agreement, and the worst measured point.

Variable-motion bodies receive a separate station scan with probes on both sides of every discovered station.

Construction thresholds remain:

```text
edge maximum angular residual     <= 0.05 arcsecond
1950-2050 maximum residual        <= 0.01 arcsecond
p99.9 angular residual            <= 0.01 arcsecond
RingFineState agreement           >= 99.5%
motion agreement                  >= 99.999%
maximum speed residual            <= 0.005 degree/day
station mismatch at +/-5 minutes  0
```

These are construction gates, not astrological orb tolerances.

If a body fails, alter that body's stored density or representation and forge again. Do not weaken the gate merely to preserve a file-size target.

---

# 12. Native proof

The Apple Swift accumulated suite has proven both the earlier construction candidate and the codec-2 body-separated implementation path.

The latest macOS qualification runner reports the accumulated OrboCore suite green after the codec-2 transition.

The final v1 artifact still requires a fresh native bundled-resource proof after its body profile is frozen and installed.

---

# 13. Completion gate

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
