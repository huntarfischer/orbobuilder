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

## Precision and acceptance

The eclipse phase root must be residual-driven. The manufacturer must refine the exact conjunction/opposition geometry to less than 0.001 arcseconds before emitting an event.

Before a neighboring Zeitgeist can be frozen:

1. the focused manufacturer must reproduce Z22 eclipse topology and type/centrality vocabulary on the frozen Z22 span;
2. every emitted eclipse phase must satisfy the exact conjunction/opposition residual gate;
3. all phase JDs must lie inside the Zeitgeist half-open owner interval;
4. duplicate source occurrences must be absent;
5. the artifact must preserve the canonical Z22 schema and eclipse-degree ordering;
6. deterministic gzip and SHA-256 provenance must be recorded in the Zeitgeist manifest.

Temporary manufacture code and CI workflows belong on temporary manufacture branches. Verified data and its manifest are frozen directly onto `agent/p22-duplicate-cleanup-staging`; the temporary PR is then closed without merge and its branch is preserved for archaeology.
