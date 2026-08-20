# Mundane Timespine Z21-Z23 sizing bench

Sizing/fidelity benchmark only. This is not a canonical manufacture or final qualification.

Full range: `1577-05-05T05:46:50.976Z` through `2311-06-10T14:16:12.881Z` (734.082 Julian years).

## Full-range projection

| Tier | Raw positions | Projected body artifacts | Bench-era range | Reference gates |
| --- | ---: | ---: | ---: | --- |
| lower | 42.45 MiB | 21.94 MiB | 21.90-22.00 MiB | FAIL |
| higher | 181.04 MiB | 60.81 MiB | 60.62-60.96 MiB | FAIL |

## lower per body

| Body | Cadence | Raw MiB | Projected MiB | Packing | Max arcsec | P99.9 arcsec | Fine state | Gate |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Sun | 2 d | 0.51 | 0.27 | 0.532 | 0.014485 | 0.013371 | 0.996000 | FAIL |
| Moon | 0.25 d | 4.09 | 2.99 | 0.731 | 0.020613 | 0.019867 | 0.996500 | FAIL |
| Mercury | 0.083333333 d | 12.27 | 6.05 | 0.490 | 0.001032 | 0.000551 | 0.999132 | FAIL |
| Venus | 0.25 d | 4.09 | 1.84 | 0.448 | 0.009284 | 0.000604 | 1.000000 | FAIL |
| Mars | 0.5 d | 2.05 | 1.07 | 0.522 | 0.836788 | 0.066943 | 0.999022 | FAIL |
| Jupiter | 0.5 d | 2.05 | 1.03 | 0.496 | 0.787967 | 0.027102 | 0.998563 | FAIL |
| Saturn | 1 d | 1.02 | 0.52 | 0.498 | 0.553889 | 0.159195 | 0.999522 | FAIL |
| Uranus | 0.25 d | 4.09 | 1.84 | 0.447 | 0.915587 | 0.078417 | 0.998569 | FAIL |
| Neptune | 0.5 d | 2.05 | 1.00 | 0.481 | 0.038164 | 0.017660 | 0.999523 | FAIL |
| Pluto | 0.5 d | 2.05 | 1.00 | 0.481 | 0.000605 | 0.000562 | 0.999523 | FAIL |
| True North Node | 0.125 d | 8.18 | 4.33 | 0.489 | 0.159464 | 0.053695 | 0.999340 | FAIL |

## higher per body

| Body | Cadence | Raw MiB | Projected MiB | Packing | Max arcsec | P99.9 arcsec | Fine state | Gate |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Sun | 1 d | 1.02 | 0.51 | 0.496 | 0.001288 | 0.001221 | 0.999000 | PASS |
| Moon | 0.125 d | 8.18 | 5.48 | 0.669 | 0.001843 | 0.001675 | 0.999000 | PASS |
| Mercury | 0.020833333 d | 49.09 | 18.01 | 0.366 | 0.000570 | 0.000548 | 0.999130 | FAIL |
| Venus | 0.0625 d | 16.36 | 5.28 | 0.322 | 0.000572 | 0.000550 | 0.999514 | FAIL |
| Mars | 0.125 d | 8.18 | 2.96 | 0.361 | 0.004320 | 0.000566 | 0.999510 | FAIL |
| Jupiter | 0.125 d | 8.18 | 3.44 | 0.419 | 0.004154 | 0.001267 | 0.999519 | FAIL |
| Saturn | 0.125 d | 8.18 | 3.10 | 0.378 | 0.005109 | 0.000708 | 0.999042 | FAIL |
| Uranus | 0.0625 d | 16.36 | 4.11 | 0.250 | 0.064640 | 0.001101 | 0.999523 | FAIL |
| Neptune | 0.125 d | 8.18 | 2.06 | 0.250 | 0.000593 | 0.000577 | 0.999046 | FAIL |
| Pluto | 0.125 d | 8.18 | 2.06 | 0.250 | 0.000579 | 0.000566 | 0.999523 | FAIL |
| True North Node | 0.020833333 d | 49.09 | 13.81 | 0.274 | 0.159761 | 0.008107 | 1.000000 | FAIL |

## Bench slices

- `Z21.08`: 1736-12-06T11:56:13.210Z through 1748-12-10T17:11:44.971Z (4387.219 days)
- `Z22.08`: 1983-11-05T21:08:39.137Z through 1995-01-17T09:15:54.002Z (4090.505 days)
- `Z23.08`: 2229-12-23T18:45:52.297Z through 2241-12-18T05:06:18.031Z (4377.431 days)
