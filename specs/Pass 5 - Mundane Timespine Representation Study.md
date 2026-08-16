# Pass 5: Mundane Timespine Representation Study

**Status:** Native representation and Forge path proven locally. Qualified Swiss astronomical audit in progress. Mundane Timespine v1 is not sealed until that audit passes.

**Date:** 2026-08-16

**Purpose:** Record the representation measurement that chooses the first native Mundane Timespine format, distinguish native implementation proof from astronomical-source proof, and define the exact Swiss qualification gate before one universal v1 sky may ship.

---

# 1. The Object Being Manufactured

The Mundane Timespine is the universal celestial chronology that every Orbo of the same Timespine version reads.

It is not the old prototype mundane event floor and it is not the old natal TimeSpine.

It must answer:

```text
body + supported absolute time
        ↓
Mundane Timespine
        ↓
celestial longitude
signed longitudinal motion
```

for the eleven universal celestial occupants required downstream:

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
true / osculating North Node
```

The Ascendant is not here. Horizon owns it.

The Mundane Timespine must be:

```text
universal
native-independent
versioned
immutable once released
identical for every Orbo carrying that version
offline-readable
random-access
compact enough to ship
precise enough to support AstroDNA codec 4
capable of yielding signed longitudinal motion
```

Normal Orbo celestial traffic reads the Mundane Timespine. It does not reopen the Ephemeris.

---

# 2. Prototype Lessons Preserved

`mundane.js` contributes the universal-artifact law:

```text
native-independent floor
same artifact for every reader
verified once before shipping
compact packed runtime data
universal temporal indexes may ride beside chronology
runtime reads decode rather than rescan
```

`timespine.js` contributes temporal-manufacturing lessons:

```text
chunkable construction
seam-safe manufacture
deterministic materialization
version identity
sorted temporal behavior
conformance between expensive source reads and materialized reads
```

`fertilize.js` contributes:

```text
resumable construction
caller-owned yield points
explicit artifact ancestry
packing and codec discipline
```

None of the three prototype objects is the native Mundane Timespine representation.

---

# 3. 4R

```text
Component: Mundane Timespine
4R: REPRODUCE
Parity: STRUCTURAL
Native owner: OrboCore / MundaneTimespine
```

The useful laws survive. The JavaScript event-table forms do not.

---

# 4. Representation Candidates Measured

## Candidate A: dense state knots with cubic Hermite reads

A straightforward representation stores longitude and signed speed at a fixed cadence and reconstructs between knots with cubic Hermite interpolation.

A conservative six-hour cadence across all eleven bodies requires roughly 55 MiB before secondary compression and metadata across the v1 range.

Advantages:

```text
simple
fast
velocity explicit
excellent local interpolation
```

Disadvantages:

```text
large
stores position and velocity as parallel sampled facts
more bytes than the same smooth chronology appears to require
```

It remains a useful reference design, but it is not the selected candidate.

## Candidate B: fixed-point Chebyshev segments

The selected candidate stores one polynomial trajectory for each segment.

```text
Chebyshev degree        7
coefficients/segment    8
coefficient storage     signed Int32
coefficient scale       5,000,000 units / degree
coefficient quantum     0.0000002 degree = 0.00072 arcsecond
```

Longitude is evaluated from the polynomial.

Signed longitudinal speed is the analytic derivative of that same polynomial:

```text
one chronology
    ↓
position
+
velocity
```

There is no separately sampled velocity truth inside the artifact.

The coefficient scale was tightened from the first construction candidate before v1 became canonical. The storage cost is unchanged because coefficients remain Int32, while fixed-point quantization headroom improves fivefold.

---

# 5. Candidate Body Profile

The current qualification profile is:

| Body | Degree | Segment days |
|---|---:|---:|
| Sun | 7 | 16 |
| Moon | 7 | 4 |
| Mercury | 7 | 1 |
| Venus | 7 | 16 |
| Mars | 7 | 8 |
| Jupiter | 7 | 2 |
| Saturn | 7 | 8 |
| Uranus | 7 | 4 |
| Neptune | 7 | 4 |
| Pluto | 7 | 8 |
| True North Node | 7 | 4 |

Mercury is deliberately fixed at a one-day segment before the Swiss qualification run. Its fast apparent geocentric motion and station behavior justify more temporal headroom than the original two-day candidate.

Across the Gregorian interval:

```text
1700-01-01 00:00
through
2150-01-01 00:00 exclusive
```

this profile requires:

```text
493,080 polynomial segments
3,944,640 Int32 coefficients
15,778,560 coefficient bytes
15.05 MiB coefficient payload
```

before the small artifact header and before any optional future secondary compression.

---

# 6. Why Fixed Body Cadences First

The v1 candidate deliberately avoids adaptive segment boundaries.

Fixed body-specific cadence gives:

```text
O(1) segment address from Julian Day
no per-segment timestamp table
simple deterministic codec
simple corruption checks
simple random access
simple version comparison
small runtime surface
```

A more elaborate adaptive representation is justified only if qualified Swiss measurement proves that a fixed profile cannot satisfy fidelity at acceptable size.

The representation becomes smarter only when measurement pays for the machinery.

---

# 7. Native Forge Law

The native Forge is the maker.

For every body and segment it:

```text
selects deterministic Chebyshev-Gauss sample nodes
asks the injected Forge Ephemeris reference for longitude
unwraps circular longitude locally
fits degree-7 Chebyshev coefficients
quantizes the coefficients
appends the body series
```

Construction is resumable in bounded segment budgets.

The same plan and same reference must produce byte-identical output whether forged:

```text
one shot
or
many resumed chunks
```

That law is already covered by native tests.

---

# 8. Swiss Qualification Bench

The qualified astronomical source from Pass 4 remains:

```text
official Swiss Ephemeris
Swiss-file mode
DE441-derived .se1 data
no silent Moshier fallback
```

The Pass 5 construction bench is now explicit:

```text
official Swiss .se1 files
        ↓
Python Swiss adapter
        ↓
deterministic longitude sample stream
        ↓
OrboCore MundaneTimespineForge
        ↓
binary Mundane Timespine candidate
        ↓
independent Python decoder
        ↓
Swiss comparison audit
```

The Python sample generator is not a second Forge. It supplies astronomical samples at the exact nodes requested by the native Forge profile.

The Python audit is deliberately independent of the Swift polynomial evaluator so a shared implementation mistake is less likely to certify itself.

The construction workflow downloads exactly the planet and lunar files needed for the v1 interval:

```text
sepl_12.se1    1200-1799
semo_12.se1    1200-1799
sepl_18.se1    1800-2399
semo_18.se1    1800-2399
```

The workflow requires Swiss-file mode and DE441 provenance at probes in both file blocks. A fallback calculation is a hard failure.

---

# 9. Coordinate Contract Under Audit

The reference reads are:

```text
geocentric
tropical
ecliptic of date
standard apparent Swiss Ephemeris position
signed longitudinal speed
true / osculating North Node
```

The sample adapter requests `SWIEPH + SPEED` and explicitly rejects a returned Moshier flag.

No topocentric, sidereal, J2000, heliocentric, or true-position override belongs to Mundane Timespine v1.

---

# 10. Astronomical Audit

The audit does not protect the representation from the sky. It protects the sky from the representation.

For each body it measures throughout every polynomial segment:

```text
maximum angular residual
99.9-percentile angular residual
99-percentile angular residual
maximum signed-speed residual
99.9-percentile signed-speed residual
RingFineState agreement rate
motion agreement rate
worst measured angular point
```

It also includes deterministic random reads across the full interval.

For variable-motion bodies it separately scans Swiss longitudinal speed for station sign changes and tests the Timespine on both sides of every discovered station.

The true North Node audit must observe both direct and retrograde reference states.

The initial qualification gate is intentionally stricter than AstroDNA's whole-arcsecond quantum:

```text
maximum angular residual        <= 0.05 arcsecond
p99.9 angular residual          <= 0.01 arcsecond
RingFineState agreement         >= 99.5%
motion agreement                >= 99.999%
maximum speed residual          <= 0.005 degree/day
station direction mismatch      0 at +/- 5 minutes
```

These are construction gates, not astrological or interpretive tolerances.

If a body fails, shorten that body's segment duration or otherwise improve the representation and forge again.

Do not weaken the gate to protect a chosen cadence.

The final qualification report is preserved with the artifact and becomes evidence for the v1 seal.

---

# 11. Candidate Codec

The native binary codec carries:

```text
magic
codec
Timespine version identity
AstroDNA codec compatibility
astronomical source identity
astronomical source version
supported start / end Julian Day
coefficient scale
canonical body count
per-body polynomial degree
per-body segment duration
per-body segment count
fixed-point coefficients
```

Bodies are encoded in one explicit canonical order.

The artifact checksum is SHA-256 over the encoded bytes.

The checksum is not celestial truth. It proves byte identity.

Thus:

```text
same declared Timespine version
+
same checksum
=
same shipped chronology bytes
```

---

# 12. Runtime Law

Runtime never asks how the polynomial was forged.

It performs:

```text
Julian Day
    ↓
body series
    ↓
segment index
    ↓
Chebyshev evaluation
    ├── longitude
    └── analytic derivative -> signed longitudinal speed
```

The supported interval is half-open.

A read outside the artifact range fails explicitly rather than extrapolating or opening the Ephemeris.

---

# 13. Native Proof Already Earned

The native construction candidate has passed the accumulated standalone Xcode suite:

```text
98 tests
98 passed
0 failures
```

OrboLab has also proven the live Forge -> artifact -> decode -> state-read path using an analytic construction fixture.

That proof establishes the native machinery. It does not substitute for the Swiss astronomical audit.

---

# 14. What Is Not Yet Claimed

Until the Swiss workflow is green and the resulting artifact is installed as a package resource, this pass does not claim:

```text
the canonical full-range v1 sky is sealed
the current body profile survived the qualified source unchanged
the final v1 checksum exists in the manifest
the final artifact ships with Orbo
Pass 5 is complete
```

Those claims require the qualified Swiss-mode forge and residual audit.

---

# 15. Pass 5 Completion Gate

Pass 5 becomes complete only when all of the following are true:

```text
qualified Swiss-file sample source           PASS
native Forge full-range manufacture           PASS
independent residual audit                    PASS
station-direction audit                       PASS
final body profile                            FROZEN
Mundane Timespine v1 binary                   CREATED
v1 SHA-256                                    RECORDED
v1 binary bundled as OrboCore resource        PASS
native bundled-artifact tests                 PASS
OrboLab reads the shipped v1 artifact         PASS
Manifest                                      UPDATED
```

Only then may Mundane Timespine v1 become **NATIVE CANONICAL** and Pass 6 begin.
