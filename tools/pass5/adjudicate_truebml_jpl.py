#!/usr/bin/env python3
"""Adjudicate manufactured True BML stations against original JPL DE441.

The compressed Swiss table remains the candidate source. This witness uses the original
uncompressed JPL DE441 lunar/planetary ephemeris through the same Swiss Ephemeris code and
asks only whether each candidate station is a persistent local extremum with the same
before/after direction. It does not manufacture replacement coordinates.
"""
from __future__ import annotations

import argparse
import csv
import ctypes
import gzip
import json
from pathlib import Path

SECONDS_PER_DAY = 86400.0
SE_OSCU_APOG = 13
SEFLG_JPLEPH = 1
SEFLG_SWIEPH = 2
SEFLG_MOSEPH = 4
SEFLG_SPEED = 256
FLAGS = SEFLG_JPLEPH | SEFLG_SPEED


def norm(x: float) -> float:
    return x % 360.0


def sdelta(a: float, b: float) -> float:
    d = norm(b) - norm(a)
    if d > 180.0:
        d -= 360.0
    if d < -180.0:
        d += 360.0
    return d


def dsign(v: float) -> int:
    return 1 if v >= 0.0 else -1


class JPLSwiss:
    def __init__(self, library: Path, ephe_dir: Path, jpl_file: str):
        self.lib = ctypes.CDLL(str(library.resolve()))
        self.lib.swe_set_ephe_path.argtypes = [ctypes.c_char_p]
        self.lib.swe_set_ephe_path.restype = None
        self.lib.swe_set_jpl_file.argtypes = [ctypes.c_char_p]
        self.lib.swe_set_jpl_file.restype = None
        self.lib.swe_calc_ut.argtypes = [ctypes.c_double, ctypes.c_int32, ctypes.c_int32, ctypes.POINTER(ctypes.c_double), ctypes.c_char_p]
        self.lib.swe_calc_ut.restype = ctypes.c_int32
        self.lib.swe_version.argtypes = [ctypes.c_char_p]
        self.lib.swe_version.restype = ctypes.c_char_p
        self.lib.swe_close.argtypes = []
        self.lib.swe_close.restype = None
        buf = ctypes.create_string_buffer(256)
        self.lib.swe_version(buf)
        self.version = buf.value.decode("ascii", errors="replace")
        self.lib.swe_set_ephe_path(str(ephe_dir.resolve()).encode())
        self.lib.swe_set_jpl_file(jpl_file.encode())

    def state(self, jd: float) -> tuple[float, float, int]:
        xx = (ctypes.c_double * 6)()
        serr = ctypes.create_string_buffer(256)
        returned = int(self.lib.swe_calc_ut(jd, SE_OSCU_APOG, FLAGS, xx, serr))
        if returned < 0:
            raise RuntimeError(f"swe_calc_ut failed at JD {jd}: {serr.value.decode(errors='replace')}")
        if not (returned & SEFLG_JPLEPH) or (returned & (SEFLG_SWIEPH | SEFLG_MOSEPH)):
            raise RuntimeError(f"Original JPL mode required at JD {jd}: flags={returned}; {serr.value.decode(errors='replace')}")
        return norm(float(xx[0])), float(xx[3]), returned

    def close(self) -> None:
        self.lib.swe_close()


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--library", type=Path, required=True)
    p.add_argument("--ephe-dir", type=Path, required=True)
    p.add_argument("--jpl-file", default="de441.eph")
    p.add_argument("--stations", type=Path, required=True)
    p.add_argument("--output-dir", type=Path, required=True)
    args = p.parse_args()

    with gzip.open(args.stations, "rt", newline="") as f:
        rows = list(csv.DictReader(f))

    swiss = JPLSwiss(args.library, args.ephe_dir, args.jpl_file)
    try:
        out = []
        persistent_counts = {str(s): 0 for s in (60, 300, 3600, 21600)}
        extremum_counts = {str(s): 0 for s in (60, 300, 3600, 21600)}
        both_counts = {str(s): 0 for s in (60, 300, 3600, 21600)}
        max_position_delta = 0.0
        first_flags = None

        for i, row in enumerate(rows):
            jd = float(row["utJulianDay"])
            candidate_lon = float(row["longitudeDegrees"])
            before = 1 if row["beforeDirection"] == "increasing" else -1
            after = 1 if row["afterDirection"] == "increasing" else -1
            lon0, speed0, flags = swiss.state(jd)
            if first_flags is None:
                first_flags = flags
            position_delta = abs(sdelta(candidate_lon, lon0))
            max_position_delta = max(max_position_delta, position_delta)
            rec = {
                "index": i,
                "jd": jd,
                "candidateLongitude": candidate_lon,
                "jplLongitude": lon0,
                "candidateToJPLDeltaDegrees": position_delta,
                "jplSpeedAtCandidateJD": speed0,
                "declaredBefore": before,
                "declaredAfter": after,
            }
            for sec in (60, 300, 3600, 21600):
                blon, bspeed, _ = swiss.state(jd - sec / SECONDS_PER_DAY)
                alon, aspeed, _ = swiss.state(jd + sec / SECONDS_PER_DAY)
                persistent = dsign(bspeed) == before and dsign(aspeed) == after and before != after
                bdelta = sdelta(lon0, blon)
                adelta = sdelta(lon0, alon)
                extremum = (before > 0 and after < 0 and bdelta <= 0 and adelta <= 0) or (before < 0 and after > 0 and bdelta >= 0 and adelta >= 0)
                both = persistent and extremum
                if persistent: persistent_counts[str(sec)] += 1
                if extremum: extremum_counts[str(sec)] += 1
                if both: both_counts[str(sec)] += 1
                rec[f"persistent{sec}s"] = persistent
                rec[f"extremum{sec}s"] = extremum
                rec[f"both{sec}s"] = both
                rec[f"beforeSpeed{sec}s"] = bspeed
                rec[f"afterSpeed{sec}s"] = aspeed
                rec[f"beforeDelta{sec}s"] = bdelta
                rec[f"afterDelta{sec}s"] = adelta
            out.append(rec)

        args.output_dir.mkdir(parents=True, exist_ok=True)
        with (args.output_dir / "TrueBML-JPL-DE441-adjudication.csv").open("w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(out[0].keys()))
            w.writeheader(); w.writerows(out)

        failed6h = [r for r in out if not r["both21600s"]]
        summary = {
            "status": "JPL_DE441_ADJUDICATION",
            "body": "TrueBML",
            "candidateStationCount": len(out),
            "swissVersion": swiss.version,
            "requestedFlags": FLAGS,
            "returnedFlagsFirstState": first_flags,
            "persistentDirectionCount": persistent_counts,
            "localExtremumCount": extremum_counts,
            "bothCount": both_counts,
            "failedSixHourCount": len(failed6h),
            "maxCandidateToJPLLongitudeDeltaDegrees": max_position_delta,
            "failedSixHour": failed6h,
        }
        (args.output_dir / "TrueBML-JPL-DE441-adjudication.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
        print(json.dumps({k:v for k,v in summary.items() if k != "failedSixHour"}, indent=2, sort_keys=True))
    finally:
        swiss.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
