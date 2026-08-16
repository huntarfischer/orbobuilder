#!/usr/bin/env python3
"""Independently audit Orbo's stamped body Timespine against Swiss Ephemeris."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
import random
import struct
import sys

import swisseph as swe

BODY_MAGIC = b"ORBTBD02"
EXPECTED_CODEC = 2
EXPECTED_SWE_VERSION = "2.10.03"
BODY_IDS = {
    0: ("Sun", swe.SUN), 1: ("Moon", swe.MOON), 2: ("Mercury", swe.MERCURY),
    3: ("Venus", swe.VENUS), 4: ("Mars", swe.MARS), 5: ("Jupiter", swe.JUPITER),
    6: ("Saturn", swe.SATURN), 7: ("Uranus", swe.URANUS), 8: ("Neptune", swe.NEPTUNE),
    9: ("Pluto", swe.PLUTO), 10: ("True North Node", swe.TRUE_NODE),
}
VARIABLE_BODIES = {2: 0.5, 3: 1.0, 4: 1.0, 5: 1.0, 6: 1.0, 7: 1.0, 8: 1.0, 9: 1.0, 10: 0.25}
AUDIT_FRACTIONS = (0.25, 0.5, 0.75)
MAX_EDGE_ANGULAR_ARCSEC = 0.05
MAX_CORE_ANGULAR_ARCSEC = 0.01
MAX_P999_ANGULAR_ARCSEC = 0.01
MAX_SPEED_ERROR_DEG_PER_DAY = 0.005
MIN_FINE_STATE_AGREEMENT = 0.995
MIN_MOTION_AGREEMENT = 0.99999
STATION_PROBE_MINUTES = 5.0


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def normalize360(value: float) -> float:
    value = math.fmod(value, 360.0)
    if value < 0: value += 360.0
    return 0.0 if value == 0.0 else value


def wrap180(value: float) -> float:
    value = math.fmod(value + 180.0, 360.0)
    if value < 0: value += 360.0
    return value - 180.0


def percentile(values: list[float], q: float) -> float:
    if not values: return 0.0
    ordered = sorted(values)
    return ordered[min(len(ordered) - 1, max(0, math.ceil(q * len(ordered)) - 1))]


def fine_state(longitude: float) -> int:
    return int(math.floor(normalize360(longitude) * 3600.0)) % 1_296_000


def motion(speed: float) -> str:
    return "retrograde" if speed < 0 else "direct"


def swiss_state(jd: float, body_id: int, flags: int) -> tuple[float, float]:
    values, returned = swe.calc_ut(jd, body_id, flags)
    if not (returned & swe.FLG_SWIEPH) or (returned & swe.FLG_MOSEPH):
        raise RuntimeError(f"Swiss-file mode lost at JD {jd}; flags={returned}")
    return values[0], values[3]


def parse_body(path: Path, expected_body: int) -> dict:
    raw = path.read_bytes()
    if sha256_bytes(raw) == "": raise AssertionError
    data = memoryview(raw)
    offset = 0
    if bytes(data[:8]) != BODY_MAGIC: raise RuntimeError(f"Bad body magic: {path}")
    offset = 8
    codec = struct.unpack_from("<H", data, offset)[0]; offset += 2
    body = data[offset]; offset += 1
    region_count = data[offset]; offset += 1
    pos_scale = struct.unpack_from("<I", data, offset)[0]; offset += 4
    speed_scale = struct.unpack_from("<I", data, offset)[0]; offset += 4
    if codec != EXPECTED_CODEC or body != expected_body or region_count != 3:
        raise RuntimeError(f"Malformed body header: {path}")

    regions = []
    for _ in range(region_count):
        start, end, step = struct.unpack_from("<ddd", data, offset); offset += 24
        count = struct.unpack_from("<I", data, offset)[0]; offset += 4
        sample_offset = offset
        byte_count = count * 8
        if count < 2 or offset + byte_count > len(data): raise RuntimeError(f"Truncated body: {path}")
        regions.append({"start": start, "end": end, "step": step, "count": count, "offset": sample_offset})
        offset += byte_count
    if offset != len(data): raise RuntimeError(f"Trailing body bytes: {path}")
    return {
        "raw": raw, "data": data, "codec": codec, "body": body,
        "positionScale": pos_scale, "speedScale": speed_scale,
        "regions": regions, "bytes": len(raw), "sha256": sha256_bytes(raw),
    }


def sample(series: dict, region: dict, index: int) -> tuple[float, float]:
    pos, speed = struct.unpack_from("<Ii", series["data"], region["offset"] + index * 8)
    return pos / series["positionScale"], speed / series["speedScale"]


def region_for(series: dict, jd: float) -> dict:
    for region in series["regions"]:
        if region["start"] <= jd < region["end"]:
            return region
    raise RuntimeError(f"JD {jd} outside body regions")


def state_at(series: dict, jd: float) -> tuple[float, float]:
    region = region_for(series, jd)
    raw_index = math.floor((jd - region["start"]) / region["step"])
    index = min(max(0, raw_index), region["count"] - 2)
    t0 = region["start"] + index * region["step"]
    t1 = min(t0 + region["step"], region["end"])
    h = t1 - t0
    u = max(0.0, min(1.0, (jd - t0) / h))
    p0, v0 = sample(series, region, index)
    p1_raw, v1 = sample(series, region, index + 1)
    p1 = p0 + wrap180(p1_raw - p0)
    u2, u3 = u * u, u * u * u
    h00, h10 = 2*u3 - 3*u2 + 1, u3 - 2*u2 + u
    h01, h11 = -2*u3 + 3*u2, u3 - u2
    longitude = h00*p0 + h10*h*v0 + h01*p1 + h11*h*v1
    dh00, dh10 = 6*u2 - 6*u, 3*u2 - 4*u + 1
    dh01, dh11 = -6*u2 + 6*u, 3*u2 - 2*u
    speed = (dh00*p0 + dh10*h*v0 + dh01*p1 + dh11*h*v1) / h
    return normalize360(longitude), speed


def audit_body(series: dict, body: int, body_id: int, flags: int, dense_start: float, dense_end: float) -> dict:
    angular, speed_errors, core_angular, edge_angular = [], [], [], []
    fine_matches = motion_matches = total = 0
    worst = None

    def check(jd: float) -> None:
        nonlocal fine_matches, motion_matches, total, worst
        ref_lon, ref_speed = swiss_state(jd, body_id, flags)
        spine_lon, spine_speed = state_at(series, jd)
        error = abs(wrap180(spine_lon - ref_lon)) * 3600.0
        speed_error = abs(spine_speed - ref_speed)
        angular.append(error); speed_errors.append(speed_error); total += 1
        (core_angular if dense_start <= jd < dense_end else edge_angular).append(error)
        fine_matches += fine_state(spine_lon) == fine_state(ref_lon)
        motion_matches += motion(spine_speed) == motion(ref_speed)
        if worst is None or error > worst["angularArcseconds"]:
            worst = {
                "julianDay": jd, "angularArcseconds": error,
                "referenceLongitude": ref_lon, "timespineLongitude": spine_lon,
                "referenceSpeed": ref_speed, "timespineSpeed": spine_speed,
            }

    for region in series["regions"]:
        for interval in range(region["count"] - 1):
            t0 = region["start"] + interval * region["step"]
            t1 = min(t0 + region["step"], region["end"])
            for fraction in AUDIT_FRACTIONS:
                check(t0 + (t1 - t0) * fraction)

    rng = random.Random(0x4F52424F + body)
    start = series["regions"][0]["start"]
    end = series["regions"][-1]["end"]
    for _ in range(5_000): check(start + rng.random() * (end - start))

    return {
        "bodyBytes": series["bytes"],
        "auditPoints": total,
        "maxAngularArcseconds": max(angular, default=0.0),
        "maxCoreAngularArcseconds": max(core_angular, default=0.0),
        "maxEdgeAngularArcseconds": max(edge_angular, default=0.0),
        "p999AngularArcseconds": percentile(angular, 0.999),
        "p99AngularArcseconds": percentile(angular, 0.99),
        "maxSpeedErrorDegreesPerDay": max(speed_errors, default=0.0),
        "p999SpeedErrorDegreesPerDay": percentile(speed_errors, 0.999),
        "fineStateAgreement": fine_matches / total if total else 1.0,
        "motionAgreement": motion_matches / total if total else 1.0,
        "regions": [{"sampleDays": r["step"], "samples": r["count"]} for r in series["regions"]],
        "worstAngularPoint": worst,
    }


def find_station_roots(start: float, end: float, body_id: int, flags: int, step: float) -> list[float]:
    roots = []
    left = start
    _, left_speed = swiss_state(left, body_id, flags)
    while left + step < end:
        right = left + step
        _, right_speed = swiss_state(right, body_id, flags)
        if (left_speed < 0) != (right_speed < 0):
            lo, hi, lo_speed = left, right, left_speed
            for _ in range(44):
                mid = (lo + hi) / 2
                _, mid_speed = swiss_state(mid, body_id, flags)
                if (lo_speed < 0) == (mid_speed < 0): lo, lo_speed = mid, mid_speed
                else: hi = mid
            roots.append((lo + hi) / 2)
        left, left_speed = right, right_speed
    return roots


def audit_stations(series: dict, body: int, body_id: int, flags: int) -> dict:
    start, end = series["regions"][0]["start"], series["regions"][-1]["end"]
    roots = find_station_roots(start, end, body_id, flags, VARIABLE_BODIES[body])
    delta = STATION_PROBE_MINUTES / 1440.0
    mismatches = []
    for root in roots:
        for side, jd in (("before", root-delta), ("after", root+delta)):
            if not (start <= jd < end): continue
            _, ref_speed = swiss_state(jd, body_id, flags)
            _, spine_speed = state_at(series, jd)
            if motion(ref_speed) != motion(spine_speed):
                mismatches.append({
                    "stationJulianDay": root, "probe": side, "probeJulianDay": jd,
                    "referenceSpeed": ref_speed, "timespineSpeed": spine_speed,
                })
    return {
        "stationCount": len(roots), "probeMinutes": STATION_PROBE_MINUTES,
        "motionMismatches": len(mismatches), "firstMismatches": mismatches[:20],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ephe-dir", required=True)
    parser.add_argument("--artifact-dir", required=True)
    parser.add_argument("--provenance", required=True)
    parser.add_argument("--report", required=True)
    args = parser.parse_args()

    if swe.version != EXPECTED_SWE_VERSION:
        raise RuntimeError(f"Swiss version drift: {swe.version}")
    swe.set_ephe_path(str(Path(args.ephe_dir).resolve()))
    flags = swe.FLG_SWIEPH | swe.FLG_SPEED
    artifact_dir = Path(args.artifact_dir)
    manifest_path = artifact_dir / "mundane-timespine-v1.json"
    manifest_raw = manifest_path.read_bytes()
    manifest = json.loads(manifest_raw)
    if manifest["codec"] != EXPECTED_CODEC: raise RuntimeError("Wrong Timespine codec")

    dense_start = float(manifest["denseStartJulianDay"])
    dense_end = float(manifest["denseEndJulianDay"])
    series_by_body = {}
    for body, body_record in enumerate(manifest["bodies"]):
        path = artifact_dir / body_record["file"]
        series = parse_body(path, body)
        if series["sha256"] != body_record["sha256"] or series["bytes"] != body_record["bytes"]:
            raise RuntimeError(f"Manifest/body identity mismatch for {body_record['body']}")
        series_by_body[body] = series

    body_reports, station_reports, failures = {}, {}, []
    for body, (name, body_id) in BODY_IDS.items():
        print(f"Auditing {name}...", flush=True)
        report = audit_body(series_by_body[body], body, body_id, flags, dense_start, dense_end)
        body_reports[name] = report
        if report["maxEdgeAngularArcseconds"] > MAX_EDGE_ANGULAR_ARCSEC:
            failures.append(f"{name} edge max {report['maxEdgeAngularArcseconds']:.9f} arcsec")
        if report["maxCoreAngularArcseconds"] > MAX_CORE_ANGULAR_ARCSEC:
            failures.append(f"{name} core max {report['maxCoreAngularArcseconds']:.9f} arcsec")
        if report["p999AngularArcseconds"] > MAX_P999_ANGULAR_ARCSEC:
            failures.append(f"{name} p99.9 {report['p999AngularArcseconds']:.9f} arcsec")
        if report["maxSpeedErrorDegreesPerDay"] > MAX_SPEED_ERROR_DEG_PER_DAY:
            failures.append(f"{name} speed max {report['maxSpeedErrorDegreesPerDay']:.9g} deg/day")
        if report["fineStateAgreement"] < MIN_FINE_STATE_AGREEMENT:
            failures.append(f"{name} RingFineState agreement {report['fineStateAgreement']:.9%}")
        if report["motionAgreement"] < MIN_MOTION_AGREEMENT:
            failures.append(f"{name} motion agreement {report['motionAgreement']:.9%}")

        if body in VARIABLE_BODIES:
            print(f"Auditing {name} stations...", flush=True)
            station = audit_stations(series_by_body[body], body, body_id, flags)
            station_reports[name] = station
            if station["motionMismatches"]:
                failures.append(f"{name} has {station['motionMismatches']} station-direction mismatches at +/- {STATION_PROBE_MINUTES:g} minutes")

    provenance = json.loads(Path(args.provenance).read_text())
    total_body_bytes = sum(s["bytes"] for s in series_by_body.values())
    result = {
        "status": "PASS" if not failures else "FAIL",
        "artifact": {
            "version": manifest["version"], "codec": manifest["codec"],
            "astroDNACodec": manifest["astroDNACodec"],
            "representation": manifest["representation"],
            "manifestBytes": len(manifest_raw), "manifestSha256": sha256_bytes(manifest_raw),
            "bodyBytes": total_body_bytes, "totalBytes": total_body_bytes + len(manifest_raw),
            "supportedStartJulianDay": manifest["supportedStartJulianDay"],
            "denseStartJulianDay": dense_start, "denseEndJulianDay": dense_end,
            "supportedEndJulianDay": manifest["supportedEndJulianDay"],
        },
        "thresholds": {
            "maxEdgeAngularArcseconds": MAX_EDGE_ANGULAR_ARCSEC,
            "maxCoreAngularArcseconds": MAX_CORE_ANGULAR_ARCSEC,
            "maxP999AngularArcseconds": MAX_P999_ANGULAR_ARCSEC,
            "maxSpeedErrorDegreesPerDay": MAX_SPEED_ERROR_DEG_PER_DAY,
            "minimumFineStateAgreement": MIN_FINE_STATE_AGREEMENT,
            "minimumMotionAgreement": MIN_MOTION_AGREEMENT,
            "stationProbeMinutes": STATION_PROBE_MINUTES,
        },
        "bodies": body_reports, "stations": station_reports,
        "sourceProvenance": provenance, "failures": failures,
    }
    Path(args.report).write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps(result, indent=2, sort_keys=True))
    if failures:
        print("PASS 5 QUALIFICATION FAILED", file=sys.stderr)
        for failure in failures: print(f"  - {failure}", file=sys.stderr)
        return 1
    print("PASS 5 QUALIFICATION PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
