# Zeitgeist Relationship Manufacture Law

This directory is the canonical Pass 5 family for exact mundane relationship tables manufactured by Zeitgeist owner span.

## Scope

Each Zeitgeist relationship family contains two separate compressed CSV tables:

- `exact-major-mundane-transits.csv.gz`
- `exact-minor-mundane-transits.csv.gz`

The relationship universe is the eleven-body mundane body set used by the Mundane Timespine:

- Sun
- Moon
- Mercury
- Venus
- Mars
- Jupiter
- Saturn
- Uranus
- Neptune
- Pluto
- NorthNode (True North Node)

All unordered body pairs are eligible. A body pair may legitimately have no event for a particular aspect family inside a given Zeitgeist span.

## Celestial-first identity law

Relationship identity is celestial first.

Canonical identity:

`exact celestial geometry + recurrence ordinal / civic UT excluded`

The celestial relationship address consists of the two bodies, exact Ring mark, orientation, exact body-A celestial longitude, exact body-B celestial longitude, and recurrence ordinal when the same stored celestial geometry recurs. Civic UT identifies the occurrence after the celestial relationship has been established; it is not part of celestial identity.

A repeated qualified celestial geometry at the same stored civic second is a duplicate source emission and must be emitted only once.

## Ring families and artifact vocabulary

Major marks:

- 0 conjunction
- 60 sextile
- 90 square
- 120 trine
- 180 opposition

Minor marks:

- 30 semisextile
- 45 octile
- 72 quintile
- 135 trioctile
- 144 biquintile
- 150 quincunx

The CSV artifact vocabulary deliberately preserves the historical Z22 names `octile` and `trioctile` for 45 and 135 degrees, even where native Ring code may use the synonyms `semisquare` and `sesquiquadrate`.

## Astronomical source

Manufacture uses the pinned Orbo Swiss Ephemeris source:

- repository: `huntarfischer/swisseph`
- commit: `3fd0f956d73898b91cc4f67cf18b21af656d1342`
- Swiss Ephemeris: 2.10.03
- ephemeris: DE441
- coordinates: geocentric tropical apparent ecliptic longitude
- time argument: UT

Zeitgeist bounds are half-open owner intervals from the frozen `tools/pass5/zeitgeist-data/zeitgeist-z0-z30.csv` table:

`[current Zeitgeist first Pluto Aries ingress, next Zeitgeist first Pluto Aries ingress)`

## Z22 calibration finding

The frozen Z22 relationship tables remain the topology and artifact-contract reference, but diagnostic calibration during Z23 manufacture established that their stored civic timestamps are not uniformly the exact Swiss roots of their relationship geometry. The same relationship topology was reproduced while individual Z22 civic placements differed from direct Swiss roots by amounts ranging from fractions of a second to minutes. The old rows can therefore carry small nonzero aspect residuals.

This historical interpolation/grid behavior is not propagated into newly manufactured neighboring Zeitgeists.

For Z23 and later neighboring manufacture, the governing law is:

1. detect the same oriented Ring crossing topology used by Z22;
2. refine the crossing against pinned Swiss/DE441 until the celestial aspect residual converges;
3. persist the exact body longitudes as the primary relationship geometry;
4. derive civic UT from that exact celestial occurrence;
5. preserve Z22 CSV schema and aspect vocabulary;
6. preserve recurrence and duplicate-source laws used by Pollux/Dioscuri.

The focused relationship Forge must calibrate its event topology against a known slice of the frozen Z22 tables before a full neighboring Zeitgeist manufacture is eligible to proceed.

## Precision gate

The relationship manufacturer is residual-driven. It must not accept a root merely because its time bracket is small.

Every frozen neighboring-Z relationship row must satisfy:

`exactAspectResidualArcSeconds < 0.001`

The Z23 production repair tightened root refinement rather than weakening this gate. The accepted Z23 manufacture reached maximum residuals of:

- major: 0.000108 arcseconds
- minor: 0.000014 arcseconds

## Z23 frozen reference

Canonical Z23 relationship data lives at:

`tools/pass5/zeitgeist-relationship-data/z23/`

Frozen row counts:

- major: 309,501
- minor: 463,309
- total: 772,810

No duplicate-source rows were removed and no repeated stored celestial keys required a recurrence ordinal greater than zero in that Z23 manufacture.

The Z23 freeze commit is `cdb26d0` on `agent/p22-duplicate-cleanup-staging`.

## Manufacture workflow rule

Temporary manufacture code and CI workflows belong on temporary manufacture branches and are not canonical runtime architecture. Verified data and its manifest are frozen directly onto `agent/p22-duplicate-cleanup-staging`; the temporary manufacture PR is then closed without merge and its branch is preserved for archaeology.

Do not loosen the astronomical acceptance gate to force a manufacture through. If a neighboring Zeitgeist fails calibration or residual audit, repair the manufacturer or explain the divergence before freezing data.
