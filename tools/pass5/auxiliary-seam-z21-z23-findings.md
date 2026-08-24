# Z21–Z23 Auxiliary Seam findings

Status: non-Eris forge complete; Eris deferred.

## Source-qualified tracks

- Mean BML: DE441-qualified companion track.
- Chiron: DE441-qualified.
- Ceres: DE441-qualified.
- Pallas: DE441-qualified.
- Juno: DE441-qualified.
- Vesta: DE441-qualified.

## True BML

True BML remains the canonical BML representation, with Mean BML as its companion.

The 1-degree True BML crossing skeleton converges across 0.25-day, 0.125-day, and 0.0625-day scans:

- Z21: 188,316 crossings
- Z22: 187,730 crossings
- Z23: 188,256 crossings
- total: 564,302 crossings
- decreasing-direction crossings: 267,229
- adjacent tick errors: 0

Eight integer-degree boundaries coincide with documented compressed-lunar `semo*.se1` discontinuities. These are source discontinuities, not failed numerical roots. All smooth crossings satisfy the `1e-7°` residual gate; the largest documented discontinuity jump in this pass is `8.976227687185201e-05°`.

Raw True BML station chronology is therefore **quarantined** when forged from compressed `semo*.se1` files. Swiss Ephemeris documents small discontinuities for the true node and osculating apogee at compressed lunar segment boundaries, so speed-zero station counts do not converge monotonically as scan cadence tightens.

Decision:

- retain the converged 1-degree crossing table;
- retain crossing direction material;
- explicitly enumerate discontinuity-bound crossings;
- do not canonize a raw True BML station table from compressed `semo*.se1` files;
- if exact True BML speed-zero chronology is required, requalify that layer from a smooth JPL source.

The current True BML crossing table was forged from user-supplied DE431 `sepl`/`semo` files and is therefore **provisional** until refreshed from the current DE441 source generation.

## Eris

Deferred intentionally to a later pass.
