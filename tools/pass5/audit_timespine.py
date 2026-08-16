#!/usr/bin/env python3
"""Audit a forged Mundane Timespine artifact against qualified Swiss Ephemeris reads.

The audit is intentionally independent of the Swift Forge fitting code. It decodes the
shipped binary format, reconstructs longitude and analytic velocity, compares those reads
with Swiss-file mode throughout every segment, and probes station direction changes.
"""

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

MAGIC = b"ORBTSP01"
EXPECTED_SWE_VERSION = "2.10.03"

BODY_IDS = {
    0: ("Sun", swe.SUN),
    1: ("Moon", swe.MOON),
    2: ("Mercury", swe.MERCURY),
    3: ("Venus", swe.VENUS),
    4: ("Mars", swe.MARS),
    5: ("Jupiter", swe.JUPITER),
    6: ("Saturn", swe.SATURN),
    7: ("Uranus", swe.URANUS),
    8: ("Neptune", swe.NEPTUNE),
    9: ("Pluto", swe.PLUTO),
    10: ("True North Node", swe.TRUE_NODE),
}

VARIABLE_BODIES = {
    2: 1.0,
    3: 1.0,
    4: 1.0,
    5: 1.0,
    6: 1.0,
    7: 1.0,
    8: 1.0,
    9: 1.0,
    10: 0.25,
}

AUDIT_FRACTIONS = (0.01, 0.125, 0.375, 0.625, 0.875, 0.99)
MAX_ANGULAR_ARCSEC = 0.05
MAX_P999_ANGULAR_ARCSEC = 0.01
MIN_FINE_STATE_AGREEMENT = 0.995
MIN_MOTION_AGREEMENT = 0.99999
MAX_SPEED_ERROR_DEG_PER_DAY = 0.005
STATION_PROBE_MINUTES = 5.0


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_u8(data: memoryview, offset: int) -> tuple[int, int]:
    return data[offset], offset + 1


def read_u16(data: memoryview, offset: int) -> tuple[int, int]:
    return struct.unpack_from("<H", data, offset)[0], offset + 2


def read_u32(data: memoryview, offset: int) -> tuple[int, int]:
    return struct.unpack_from("<I", data, offset)[0], offset + 4


def read_f64(data: memoryview, offset: int) -> tuple[float, int]:
    return struct.unpack_from("<d", data, offset)[0], offset + 8


def read_string(data: memoryview, offset: int) -> tuple[str, int]:
    length, offset = read_u16(data, offset)
    raw = bytes(data[offset : offset + length])
    return raw.decode("utf-8"), offset + length


def parse_artifact(raw: bytes) -> dict:
    data = memoryview(raw)
    offset = 0
    if bytes(data[:8]) != MAGIC:
        raise RuntimeError("Invalid Mundane Timespine magic")
    offset = 8
    codec, offset = read_u16(data, offset)
    version, offset = read_string(data, offset)
    astrodna_codec, offset = read_u16(data, offset)
    source, offset = read_string(data, offset)
    source_version, offset = read_string(data, offset)
    start_jd, offset = read_f64(data, offset)
    end_jd, offset = read_f64(data, offset)
    coefficient_scale, offset = read_u32(data, offset)
    body_count, offset = read_u8(data, offset)

    series = {}
    for expected_body in range(body_count):
        body, offset = read_u8(data, offset)
        if body != expected_body:
            raise RuntimeError(f"Noncanonical body order: expected {expected_body}, got {body}")
        degree, offset = read_u8(data, offset)
        segment_days, offset = read_f64(data, offset)
        segment_count, offset = read_u32(data, offset)
        coefficient_count = segment_count * (degree + 1)
        byte_count = coefficient_count * 4
        if offset + byte_count > len(data):
            raise RuntimeError(f"Truncated coefficient series for body {body}")
        series[body] = {
            "degree": degree,
            "segmentDays": segment_days,
            "segmentCount": segment_count,
            "coeffOffset": offset,
            "coefficientsPerSegment": degree + 1,
        }
        offset += byte_count

    if offset != len(data):
        raise RuntimeError(f"Trailing bytes after Timespine body series: {len(data) - offset}")

    return {
        "codec": codec,
        "version": version,
        "astroDNACodec": astrodna_codec,
        "source": source,
        "sourceVersion": source_version,
        "startJulianDay": start_jd,
        "endJulianDay": end_jd,
        "coefficientScale": coefficient_scale,
        "bodyCount": body_count,
        "series": series,
        "data": data,
    }


def normalize360(value: float) -> float:
    result = math.fmod(value, 360.0)
    if result < 0:
        result += 360.0
    return 0.0 if result == 0.0 else result


def wrap180(value: float) -> float:
    result = math.fmod(value + 180.0, 360.0)
    if result < 0:
        result += 360.0
    return result - 180.0


def state_at(artifact: dict, body: int, jd: float) -> tuple[float, float]:
    if not (artifact["startJulianDay"] <= jd < artifact["endJulianDay"]):
        raise RuntimeError(f"JD {jd} outside Timespine range")
    series = artifact["series"][body]
    start = artifact["startJulianDay"]
    duration = series["segmentDays"]
    segment_index = min(
        max(0, int(math.floor((jd - start) / duration))),
        series["segmentCount"] - 1,
    )
    segment_start = start + segment_index * duration
    u = (jd - segment_start) / duration
    x = max(-1.0, min(1.0, 2.0 * u - 1.0))
    coeff_count = series["coefficientsPerSegment"]
    coeff_offset = series["coeffOffset"] + segment_index * coeff_count * 4
    ints = struct.unpack_from(f"<{coeff_count}i", artifact["data"], coeff_offset)
    scale = float(artifact["coefficientScale"])
    coefficients = [value / scale for value in ints]

    t0 = 1.0
    t1 = x
    value = coefficients[0]
    if coeff_count > 1:
        value += coefficients[1] * x
    for k in range(2, coeff_count):
        tk = 2.0 * x * t1 - t0
        value += coefficients[k] * tk
        t0, t1 = t1, tk

    if coeff_count <= 1:
        derivative_x = 0.0
    else:
        u_previous = 1.0
        derivative_x = coefficients[1]
        if coeff_count > 2:
            u_current = 2.0 * x
            derivative_x += 2.0 * coefficients[2] * u_current
            for k in range(3, coeff_count):
                u_next = 2.0 * x * u_current - u_previous
                derivative_x += k * coefficients[k] * u_next
                u_previous, u_current = u_current, u_next

    return normalize360(value), derivative_x * 2.0 / duration


def swiss_state(jd: float, body_id: int, flags: int) -> tuple[float, float]:
    values, returned_flags = swe.calc_ut(jd, body_id, flags)
    if not (returned_flags & swe.FLG_SWIEPH) or (returned_flags & swe.FLG_MOSEPH):
        raise RuntimeError(f"Swiss-file mode lost at JD {jd}; flags={returned_flags}")
    return values[0], values[3]


def percentile(values: list[float], q: float) -> float:
    if not values:
        return 0.0
    ordered = sorted(values)
    index = min(len(ordered) - 1, max(0, int(math.ceil(q * len(ordered))) - 1))
    return ordered[index]


def fine_state(longitude: float) -> int:
    return int(math.floor(normalize360(longitude) * 3600.0)) % 1_296_000


def motion(speed: float) -> str:
    return "retrograde" if speed < 0.0 else "direct"


def audit_body(artifact: dict, body: int, body_id: int, flags: int) -> dict:
    series = artifact["series"][body]
    start = artifact["startJulianDay"]
    end = artifact["endJulianDay"]
    duration = series["segmentDays"]

    angular_errors = []
    speed_errors = []
    fine_matches = 0
    motion_matches = 0
    total = 0
    reference_direct = 0
    reference_retrograde = 0
    worst = None

    def check(jd: float) -> None:
        nonlocal fine_matches, motion_matches, total, reference_direct, reference_retrograde, worst
        reference_lon, reference_speed = swiss_state(jd, body_id, flags)
        spine_lon, spine_speed = state_at(artifact, body, jd)
        angular = abs(wrap180(spine_lon - reference_lon)) * 3600.0
        speed_error = abs(spine_speed - reference_speed)
        angular_errors.append(angular)
        speed_errors.append(speed_error)
        total += 1
        if fine_state(spine_lon) == fine_state(reference_lon):
            fine_matches += 1
        if motion(spine_speed) == motion(reference_speed):
            motion_matches += 1
        if reference_speed < 0:
            reference_retrograde += 1
        else:
            reference_direct += 1
        if worst is None or angular > worst["angularArcseconds"]:
            worst = {
                "julianDay": jd,
                "referenceLongitude": reference_lon,
                "timespineLongitude": spine_lon,
                "angularArcseconds": angular,
                "referenceSpeed": reference_speed,
                "timespineSpeed": spine_speed,
            }

    for segment_index in range(series["segmentCount"]):
        segment_start = start + segment_index * duration
        for fraction in AUDIT_FRACTIONS:
            jd = segment_start + fraction * duration
            if jd >= end:
                continue
            check(jd)

    rng = random.Random(0x4F52424F + body)
    for _ in range(5_000):
        check(start + rng.random() * (end - start))

    return {
        "segmentDays": duration,
        "segments": series["segmentCount"],
        "auditPoints": total,
        "maxAngularArcseconds": max(angular_errors, default=0.0),
        "p999AngularArcseconds": percentile(angular_errors, 0.999),
        "p99AngularArcseconds": percentile(angular_errors, 0.99),
        "maxSpeedErrorDegreesPerDay": max(speed_errors, default=0.0),
        "p999SpeedErrorDegreesPerDay": percentile(speed_errors, 0.999),
        "fineStateAgreement": fine_matches / total if total else 1.0,
        "motionAgreement": motion_matches / total if total else 1.0,
        "referenceDirectPoints": reference_direct,
        "referenceRetrogradePoints": reference_retrograde,
        "worstAngularPoint": worst,
    }


def find_station_roots(artifact: dict, body: int, body_id: int, flags: int) -> list[float]:
    step = VARIABLE_BODIES[body]
    start = artifact["startJulianDay"]
    end = artifact["endJulianDay"]
    roots = []
    left = start
    _, left_speed = swiss_state(left, body_id, flags)

    while left + step < end:
        right = left + step
        _, right_speed = swiss_state(right, body_id, flags)
        if (left_speed < 0.0) != (right_speed < 0.0):
            lo, hi = left, right
            lo_speed, hi_speed = left_speed, right_speed
            for _ in range(44):
                mid = (lo + hi) / 2.0
                _, mid_speed = swiss_state(mid, body_id, flags)
                if (lo_speed < 0.0) == (mid_speed < 0.0):
                    lo, lo_speed = mid, mid_speed
                else:
                    hi, hi_speed = mid, mid_speed
            roots.append((lo + hi) / 2.0)
        left, left_speed = right, right_speed
    return roots


def audit_stations(artifact: dict, body: int, body_id: int, flags: int) -> dict:
    roots = find_station_roots(artifact, body, body_id, flags)
    delta = STATION_PROBE_MINUTES / 1440.0
    mismatches = []

    for root in roots:
        for side, jd in (("before", root - delta), ("after", root + delta)):
            if not (artifact["startJulianDay"] <= jd < artifact["endJulianDay"]):
                continue
            _, reference_speed = swiss_state(jd, body_id, flags)
            _, spine_speed = state_at(artifact, body, jd)
            if motion(reference_speed) != motion(spine_speed):
                mismatches.append(
                    {
                        "stationJulianDay": root,
                        "probe": side,
                        "probeJulianDay": jd,
                        "referenceSpeed": reference_speed,
                        "timespineSpeed": spine_speed,
                    }
                )

    return {
        "stationCount": len(roots),
        "probeMinutes": STATION_PROBE_MINUTES,
        "motionMismatches": len(mismatches),
        "firstMismatches": mismatches[:20],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ephe-dir", required=True)
    parser.add_argument("--artifact", required=True)
    parser.add_argument("--provenance", required=True)
    parser.add_argument("--report", required=True)
    args = parser.parse_args()

    if swe.version != EXPECTED_SWE_VERSION:
        raise RuntimeError(
            f"Swiss library version drift: expected {EXPECTED_SWE_VERSION}, got {swe.version}"
        )

    swe.set_ephe_path(str(Path(args.ephe_dir).resolve()))
    flags = swe.FLG_SWIEPH | swe.FLG_SPEED
    raw = Path(args.artifact).read_bytes()
    artifact = parse_artifact(raw)
    provenance = json.loads(Path(args.provenance).read_text())

    body_reports = {}
    station_reports = {}
    failures = []

    for body in range(artifact["bodyCount"]):
        body_name, body_id = BODY_IDS[body]
        print(f"Auditing {body_name}...", flush=True)
        report = audit_body(artifact, body, body_id, flags)
        body_reports[body_name] = report

        if report["maxAngularArcseconds"] > MAX_ANGULAR_ARCSEC:
            failures.append(
                f"{body_name} max angular residual {report['maxAngularArcseconds']:.9f} arcsec"
            )
        if report["p999AngularArcseconds"] > MAX_P999_ANGULAR_ARCSEC:
            failures.append(
                f"{body_name} p99.9 angular residual {report['p999AngularArcseconds']:.9f} arcsec"
            )
        if report["fineStateAgreement"] < MIN_FINE_STATE_AGREEMENT:
            failures.append(
                f"{body_name} RingFineState agreement {report['fineStateAgreement']:.9%}"
            )
        if report["motionAgreement"] < MIN_MOTION_AGREEMENT:
            failures.append(
                f"{body_name} motion agreement {report['motionAgreement']:.9%}"
            )
        if report["maxSpeedErrorDegreesPerDay"] > MAX_SPEED_ERROR_DEG_PER_DAY:
            failures.append(
                f"{body_name} max speed residual {report['maxSpeedErrorDegreesPerDay']:.9g} deg/day"
            )

        if body in VARIABLE_BODIES:
            print(f"Auditing {body_name} stations...", flush=True)
            station_report = audit_stations(artifact, body, body_id, flags)
            station_reports[body_name] = station_report
            if station_report["motionMismatches"]:
                failures.append(
                    f"{body_name} has {station_report['motionMismatches']} station-direction mismatches at +/- {STATION_PROBE_MINUTES:g} minutes"
                )

    node_report = body_reports["True North Node"]
    if node_report["referenceDirectPoints"] == 0 or node_report["referenceRetrogradePoints"] == 0:
        failures.append("True North Node audit did not observe both direct and retrograde reference states")

    result = {
        "status": "PASS" if not failures else "FAIL",
        "artifact": {
            "bytes": len(raw),
            "sha256": sha256_bytes(raw),
            "codec": artifact["codec"],
            "version": artifact["version"],
            "astroDNACodec": artifact["astroDNACodec"],
            "astronomicalSource": artifact["source"],
            "astronomicalSourceVersion": artifact["sourceVersion"],
            "supportedStartJulianDay": artifact["startJulianDay"],
            "supportedEndJulianDay": artifact["endJulianDay"],
            "coefficientScale": artifact["coefficientScale"],
        },
        "sourceProvenance": provenance,
        "thresholds": {
            "maxAngularArcseconds": MAX_ANGULAR_ARCSEC,
            "maxP999AngularArcseconds": MAX_P999_ANGULAR_ARCSEC,
            "minimumFineStateAgreement": MIN_FINE_STATE_AGREEMENT,
            "minimumMotionAgreement": MIN_MOTION_AGREEMENT,
            "maxSpeedErrorDegreesPerDay": MAX_SPEED_ERROR_DEG_PER_DAY,
            "stationProbeMinutes": STATION_PROBE_MINUTES,
        },
        "bodies": body_reports,
        "stations": station_reports,
        "failures": failures,
    }

    report_path = Path(args.report)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps(result, indent=2, sort_keys=True))
    swe.close()

    if failures:
        print("PASS 5 QUALIFICATION FAILED", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print("PASS 5 QUALIFICATION PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
