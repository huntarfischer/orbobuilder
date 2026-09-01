#!/usr/bin/env python3
"""Diagnose an already manufactured True BML station table against its canonical Swiss source.

No astronomy is manufactured here. This only asks whether each stored station is a persistent
longitude extremum and records the numerical speed residual at the stored UT.
"""
from __future__ import annotations

import argparse
import csv
import gzip
import json
from pathlib import Path

import generate_auxiliary_seam_z21_z23 as aux

SECONDS_PER_DAY = 86400.0


def dsign(v: float) -> int:
    return 1 if v >= 0.0 else -1


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--library", type=Path, required=True)
    p.add_argument("--ephe-dir", type=Path, required=True)
    p.add_argument("--stations", type=Path, required=True)
    p.add_argument("--output-dir", type=Path, required=True)
    args = p.parse_args()

    track = aux.TRACKS["TrueBML"]
    aux.verify_sources(args.ephe_dir, require_eris=False)
    swiss = aux.base.SwissC(args.library, args.ephe_dir)
    try:
        with gzip.open(args.stations, "rt", newline="") as f:
            rows = list(csv.DictReader(f))

        out = []
        thresholds = [1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3]
        counts = {str(x): 0 for x in thresholds}
        persistent_counts = {"60": 0, "300": 0, "3600": 0, "21600": 0}
        extremum_counts = {"60": 0, "300": 0, "3600": 0, "21600": 0}

        for i, row in enumerate(rows):
            jd = float(row["utJulianDay"])
            lon0, speed0 = aux.state(swiss, track, jd)
            before = 1 if row["beforeDirection"] == "increasing" else -1
            after = 1 if row["afterDirection"] == "increasing" else -1
            residual = abs(speed0)
            for t in thresholds:
                if residual > t:
                    counts[str(t)] += 1

            rec = {
                "index": i,
                "jd": jd,
                "longitude": lon0,
                "speedAtStoredJD": speed0,
                "absSpeedAtStoredJD": residual,
                "declaredBefore": before,
                "declaredAfter": after,
            }
            for sec in (60, 300, 3600, 21600):
                blon, bspeed = aux.state(swiss, track, jd - sec / SECONDS_PER_DAY)
                alon, aspeed = aux.state(swiss, track, jd + sec / SECONDS_PER_DAY)
                persistent = dsign(bspeed) == before and dsign(aspeed) == after and before != after
                # Relative to center, both sides are lower for a max and higher for a min.
                bdelta = aux.sdelta(lon0, blon)
                adelta = aux.sdelta(lon0, alon)
                extremum = (before > 0 and after < 0 and bdelta <= 0 and adelta <= 0) or (before < 0 and after > 0 and bdelta >= 0 and adelta >= 0)
                if persistent:
                    persistent_counts[str(sec)] += 1
                if extremum:
                    extremum_counts[str(sec)] += 1
                rec[f"persistent{sec}s"] = persistent
                rec[f"extremum{sec}s"] = extremum
                rec[f"beforeSpeed{sec}s"] = bspeed
                rec[f"afterSpeed{sec}s"] = aspeed
                rec[f"beforeDelta{sec}s"] = bdelta
                rec[f"afterDelta{sec}s"] = adelta
            out.append(rec)

        args.output_dir.mkdir(parents=True, exist_ok=True)
        fields = list(out[0].keys()) if out else []
        with (args.output_dir / "TrueBML-station-diagnostics.csv").open("w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=fields)
            w.writeheader(); w.writerows(out)

        worst = sorted(out, key=lambda r: r["absSpeedAtStoredJD"], reverse=True)[:200]
        summary = {
            "status": "DIAGNOSTIC_ONLY",
            "body": "TrueBML",
            "stationCount": len(out),
            "residualCountAbove": counts,
            "persistentDirectionCount": persistent_counts,
            "localExtremumCount": extremum_counts,
            "worst200": worst,
        }
        (args.output_dir / "TrueBML-station-diagnostics.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
        print(json.dumps({k:v for k,v in summary.items() if k != "worst200"}, indent=2, sort_keys=True))
    finally:
        swiss.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
