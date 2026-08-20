# Zeitgeist Eclipse Manufacture Law

This directory is the canonical Pass 5 family for eclipse tables manufactured by Zeitgeist owner span.

## Celestial-first law

Eclipse identity is celestial first.

- solar eclipse phase = exact Sun-Moon conjunction
- lunar eclipse phase = exact Sun-Moon opposition
- eclipse degree is the exact phase degree
- solar eclipse degree is the Sun longitude at exact conjunction
- lunar eclipse degree is the Moon longitude at exact opposition
- civic UT identifies the occurrence after the celestial phase geometry has been established
- greatest-eclipse UT is a physical-event attribute supplied by Swiss Ephemeris, not the primary celestial coordinate

Tables are sorted by `eclipse_degree`, not civic date.

## Actual eclipse occurrence law

Do not treat every conjunction or opposition as an eclipse.

Actual solar and lunar eclipse occurrences are discovered with the pinned Swiss Ephemeris global eclipse-search functions. For each discovered eclipse, the exact Sun-Moon phase is then refined independently against geocentric tropical apparent ecliptic longitude.

Swiss source:

- repository: `huntarfischer/swisseph`
- commit: `3fd0f956d73898b91cc4f67cf18b21af656d1342`
- Swiss Ephemeris: 2.10.03
- ephemeris: DE441
- coordinates: geocentric tropical apparent ecliptic longitude
- time argument: UT

Zeitgeist ownership is the half-open interval from the current Zeitgeist's first Pluto ingress into Aries to the next Zeitgeist's first Pluto ingress into Aries, using `tools/pass5/zeitgeist-data/zeitgeist-z0-z30.csv`.

## Canonical schema

The Z22 artifact contract is:

`eclipse_degree,degree_label,sign,degree_in_sign,eclipse_kind,eclipse_type,centrality,phase_jd_ut,phase_utc,greatest_eclipse_jd_ut,greatest_eclipse_utc,magnitude,secondary_magnitude`

Persisted eclipse kinds:

- `solar`
- `lunar`

Persisted eclipse types:

- `annular`
- `penumbral`
- `partial`
- `total`
- `hybrid`

Solar centrality is `central` or `noncentral`. Lunar centrality is blank.

Solar `magnitude` is the Swiss solar eclipse magnitude and `secondary_magnitude` is blank. Lunar `magnitude` is the umbral magnitude and `secondary_magnitude` is the penumbral magnitude.

## Z22 reference contract

The frozen Z22 table is `tools/pass5/p22-data/eclipse-table.csv.gz`.

It contains 1,133 eclipses:

- solar: 561
- lunar: 572

Z22 type distribution:

- annular: 175
- penumbral: 205
- partial: 373
- total: 352
- hybrid: 28

The frozen Z22 table is the schema, vocabulary, ordering, and topology calibration reference for neighboring Zeitgeist manufacture.

## Z22 calibration finding

The focused eclipse Forge was run across the full Z22 owner span before neighboring manufacture. It reproduced all 1,133 eclipse occurrences with exact agreement in eclipse kind, eclipse type, and solar centrality.

The regenerated pinned-Swiss numerical values were not bit-identical to the historical Z22 artifact. Maximum observed differences were:

- solar phase time: 4.788548 seconds
- solar greatest-eclipse time: 4.986374 seconds
- solar eclipse degree: 0.208681 arcseconds
- solar magnitude: 0.000970
- lunar phase time: 3.784852 seconds
- lunar greatest-eclipse time: 4.044034 seconds
- lunar eclipse degree: 0.192937 arcseconds
- lunar magnitude: 0.001251

Therefore the historical Z22 table remains the topology/schema reference, while newly manufactured neighboring Zeitgeists use the pinned direct Swiss search values and independently refined exact phase roots. Historical numerical drift is not deliberately copied into new data.

## Precision and acceptance

The eclipse phase root must be residual-driven. The manufacturer must refine the exact conjunction/opposition geometry to less than 0.001 arcseconds before emitting an event.

Before a neighboring Zeitgeist can be frozen:

1. the focused manufacturer must reproduce Z22 eclipse topology and type/centrality vocabulary on the frozen Z22 span;
2. every emitted eclipse phase must satisfy the exact conjunction/opposition residual gate;
3. all phase JDs must lie inside the Zeitgeist half-open owner interval;
4. duplicate source occurrences must be absent;
5. the artifact must preserve the canonical Z22 schema and eclipse-degree ordering;
6. deterministic gzip and SHA-256 provenance must be recorded in the Zeitgeist manifest.

## Z21 frozen reference

Canonical Z21 eclipse data lives at:

`tools/pass5/zeitgeist-eclipse-data/z21/`

Owner span:

`1577-05-05T05:46:50.976Z` to `1822-04-16T13:54:20.135Z`, half-open.

Frozen count: 1,221 eclipses.

Kinds:

- solar: 606
- lunar: 615

Types:

- annular: 184
- penumbral: 230
- partial: 453
- total: 304
- hybrid: 50

Solar centrality:

- central: 385
- noncentral: 221

No duplicate source rows were emitted.

Frozen gzip:

- bytes: 66,677
- SHA-256: `ca192388a7897eb4f5e7a58117098ef36d7879c6879ad451d6ab6f07d6e7236f`

The Z21 freeze commit is `0f6c257` on `agent/p22-duplicate-cleanup-staging`.

## Z23 frozen reference

Canonical Z23 eclipse data lives at:

`tools/pass5/zeitgeist-eclipse-data/z23/`

Owner span:

`2066-06-17T15:24:10.695Z` to `2311-06-10T14:16:12.881Z`, half-open.

Frozen count: 1,185 eclipses.

Kinds:

- solar: 588
- lunar: 597

Types:

- annular: 206
- penumbral: 219
- partial: 422
- total: 329
- hybrid: 9

Solar centrality:

- central: 376
- noncentral: 212

No duplicate source rows were emitted.

Frozen gzip:

- bytes: 64,965
- SHA-256: `d5b486cd9aa1860bcac5d9bf48269384396e36f35afa8d9d49666782a6b7438f`

The Z23 freeze commit is `e013408` on `agent/p22-duplicate-cleanup-staging`.

## Manufacture workflow rule

Temporary manufacture code and CI workflows belong on temporary manufacture branches. Verified data and its manifest are frozen directly onto `agent/p22-duplicate-cleanup-staging`; the temporary PR is then closed without merge and its branch is preserved for archaeology.
