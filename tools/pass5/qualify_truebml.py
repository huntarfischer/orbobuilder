#!/usr/bin/env python3
"""Qualify True BML against Orbo's frozen Z21-Z23 auxiliary contract.

This is forge-side diagnostic machinery only. It does not alter the finalized auxiliary pack.
It manufactures the full TrueBML substrate with the existing DE441-generation Swiss source,
records the strict legacy station residual, and emits enough neighborhood/topology evidence to
judge whether the residual floor is numerical/source-local rather than a false direction change.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import generate_auxiliary_seam_z21_z23 as aux

SECONDS_PER_DAY = 86400.0


def direction_sign(speed: float) -> int:
    return 1 if speed >= 0.0 else -1


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--library", type=Path, required=True)
    p.add_argument("--ephe-dir", type=Path, required=True)
    p.add_argument("--output-dir", type=Path, required=True)
    p.add_argument("--source-commit", required=True)
    args = p.parse_args()

    track = aux.TRACKS["TrueBML"]
    sources = aux.verify_sources(args.ephe_dir, require_eris=False)
    swiss = aux.base.SwissC(args.library, args.ephe_dir)
    try:
        args.output_dir.mkdir(parents=True, exist_ok=True)
        crossings, stations = aux.generate(swiss, track)

        cp = args.output_dir / "crossings" / "TrueBML.csv.gz"
        sp = args.output_dir / "stations" / "TrueBML.csv.gz"
        rp = args.output_dir / "retrograde-crossings" / "TrueBML.csv.gz"

        res = track.resolution
        aux.write_gzip_csv(
            cp,
            ["body", "focalCelestialTick", "focalCelestialDegrees", "celestialResolutionDegrees", "zeitgeist", "utJulianDay", "utOffsetSecondsFromZ21Start", "sequenceDirection"],
            ([track.name, c.tick, f"{c.tick * res:.1f}", f"{res:g}", aux.z_of(c.jd), f"{c.jd:.12f}", int(round((c.jd - aux.Z21_START) * SECONDS_PER_DAY)), aux.direction_name(c.direction)] for c in crossings),
        )
        aux.write_gzip_csv(
            sp,
            ["body", "zeitgeist", "utJulianDay", "utOffsetSecondsFromZ21Start", "longitudeDegrees", "beforeDirection", "afterDirection"],
            ([track.name, aux.z_of(s.jd), f"{s.jd:.12f}", int(round((s.jd - aux.Z21_START) * SECONDS_PER_DAY)), f"{s.longitude:.9f}", aux.direction_name(s.before), aux.direction_name(s.after)] for s in stations),
        )
        aux.write_gzip_csv(
            rp,
            ["body", "focalCelestialTick", "zeitgeist", "utJulianDay", "utOffsetSecondsFromZ21Start"],
            ([track.name, c.tick, aux.z_of(c.jd), f"{c.jd:.12f}", int(round((c.jd - aux.Z21_START) * SECONDS_PER_DAY))] for c in crossings if c.direction < 0),
        )

        # Legacy audit sample, preserved exactly for comparison with the failed forge.
        station_sample = stations if len(stations) <= 50 else [stations[round((len(stations) - 1) * q / 49)] for q in range(50)]
        legacy_sample_max = 0.0
        legacy_sample_worst = None
        for s in station_sample:
            _, speed = aux.state(swiss, track, s.jd)
            a = abs(speed)
            if a > legacy_sample_max:
                legacy_sample_max = a
                legacy_sample_worst = (s, speed)

        # Stronger all-station topology evidence. We do not ask a compressed-file speed
        # derivative to be exactly zero; we ask each claimed station to preserve the actual
        # direction change on both sides and to be unique/ordered.
        all_max = 0.0
        all_worst = None
        sign_failures = []
        neighborhood_seconds = (300, 60, 10, 1)
        for i, s in enumerate(stations):
            _, speed0 = aux.state(swiss, track, s.jd)
            a = abs(speed0)
            if a > all_max:
                all_max = a
                all_worst = (i, s, speed0)

            _, before60 = aux.state(swiss, track, s.jd - 60.0 / SECONDS_PER_DAY)
            _, after60 = aux.state(swiss, track, s.jd + 60.0 / SECONDS_PER_DAY)
            if direction_sign(before60) != s.before or direction_sign(after60) != s.after or s.before == s.after:
                if len(sign_failures) < 100:
                    sign_failures.append({
                        "index": i,
                        "jd": s.jd,
                        "declaredBefore": s.before,
                        "declaredAfter": s.after,
                        "before60Speed": before60,
                        "after60Speed": after60,
                    })

        worst_detail = None
        if all_worst is not None:
            i, s, speed0 = all_worst
            neighborhood = {}
            for sec in neighborhood_seconds:
                _, bm = aux.state(swiss, track, s.jd - sec / SECONDS_PER_DAY)
                _, ap = aux.state(swiss, track, s.jd + sec / SECONDS_PER_DAY)
                neighborhood[str(sec)] = {"beforeSpeed": bm, "afterSpeed": ap}
            worst_detail = {
                "index": i,
                "jd": s.jd,
                "longitude": s.longitude,
                "speedAtStoredJD": speed0,
                "declaredBefore": s.before,
                "declaredAfter": s.after,
                "neighborhoodSeconds": neighborhood,
            }

        by_z = {z: 0 for z in aux.Z_BOUNDS}
        for c in crossings:
            by_z[aux.z_of(c.jd)] += 1

        diagnostic = {
            "status": "QUALIFICATION_OUTPUT",
            "body": "TrueBML",
            "canonical": True,
            "swissIdentity": "SE_OSCU_APOG",
            "resolutionDegrees": track.resolution,
            "stepDays": track.step_days,
            "span": "Z21-Z23",
            "startJDUT": aux.Z21_START,
            "z22StartJDUT": aux.Z22_START,
            "z23StartJDUT": aux.Z23_START,
            "endJDUT": aux.Z23_END,
            "swissVersion": swiss.version,
            "swissSourceCommit": args.source_commit,
            "coordinateContract": "geocentric tropical apparent ecliptic longitude; UT",
            "flagsContract": "SWIEPH|SPEED; Moshier fallback fatal",
            "sourceFiles": sources,
            "crossingCount": len(crossings),
            "stationCount": len(stations),
            "retrogradeCrossingCount": sum(c.direction < 0 for c in crossings),
            "crossingsByZeitgeist": by_z,
            "legacyStationResidualLimitDegreesPerDay": 1e-8,
            "legacySampledMaxStationSpeedDegreesPerDay": legacy_sample_max,
            "legacySampleWouldPass": legacy_sample_max <= 1e-8,
            "allStationMaxAbsSpeedDegreesPerDay": all_max,
            "allStationOneMinuteDirectionFailures": len(sign_failures),
            "directionFailureExamples": sign_failures,
            "worstStation": worst_detail,
            "files": {
                str(path.relative_to(args.output_dir)): {"bytes": path.stat().st_size, "sha256": aux.base.sha256(path)}
                for path in (cp, sp, rp)
            },
        }
        (args.output_dir / "truebml-qualification.json").write_text(json.dumps(diagnostic, indent=2, sort_keys=True) + "\n")
        print(json.dumps(diagnostic, indent=2, sort_keys=True), flush=True)
    finally:
        swiss.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
