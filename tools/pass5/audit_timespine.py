#!/usr/bin/env python3
"""Independently audit Orbo Mundane Timespine codec 4 against pinned official Swiss C.

Codec 4 keeps the Timespine position-first: each body owns stamped longitude knots and an
exact station chronology. The body file merely packs those same knot integers losslessly
with circular first deltas and signed second-delta varints. This auditor decodes that binary
format independently of Swift, reconstructs the stored knots, performs the same local cubic
read over cadence-aligned guard knots, and compares arbitrary-time reads back to Swiss C.
"""
from __future__ import annotations

import argparse
import ctypes
import hashlib
import json
import math
import random
import struct
from pathlib import Path
import sys

BODY_MAGIC = b"ORBTBD04"
EXPECTED_CODEC = 4
EXPECTED_SWE_VERSION = "2.10.03"
SEFLG_SWIEPH = 2
SEFLG_MOSEPH = 4
SEFLG_SPEED = 256
BODY_IDS = {
    0: ("Sun", 0),
    1: ("Moon", 1),
    2: ("Mercury", 2),
    3: ("Venus", 3),
    4: ("Mars", 4),
    5: ("Jupiter", 5),
    6: ("Saturn", 6),
    7: ("Uranus", 7),
    8: ("Neptune", 8),
    9: ("Pluto", 9),
    10: ("True North Node", 11),
}
AUDIT_FRACTIONS = (0.25, 0.5, 0.75)
MAX_EDGE_ANGULAR_ARCSEC = 0.05
MAX_CORE_ANGULAR_ARCSEC = 0.01
MAX_P999_ANGULAR_ARCSEC = 0.01
MAX_SPEED_ERROR_DEG_PER_DAY = 0.005
MIN_FINE_STATE_AGREEMENT = 0.995
MIN_MOTION_AGREEMENT = 0.99999
STATION_PROBE_MINUTES = 5.0


class SwissC:
    def __init__(self, library: Path, ephe_dir: Path):
        self.lib = ctypes.CDLL(str(library.resolve()))
        self.lib.swe_set_ephe_path.argtypes = [ctypes.c_char_p]
        self.lib.swe_set_ephe_path.restype = None
        self.lib.swe_calc_ut.argtypes = [
            ctypes.c_double,
            ctypes.c_int32,
            ctypes.c_int32,
            ctypes.POINTER(ctypes.c_double),
            ctypes.c_char_p,
        ]
        self.lib.swe_calc_ut.restype = ctypes.c_int32
        self.lib.swe_version.argtypes = [ctypes.c_char_p]
        self.lib.swe_version.restype = ctypes.c_char_p
        self.lib.swe_close.argtypes = []
        self.lib.swe_close.restype = None

        buffer = ctypes.create_string_buffer(256)
        self.lib.swe_version(buffer)
        self.version = buffer.value.decode("ascii", errors="replace")
        if self.version != EXPECTED_SWE_VERSION:
            raise RuntimeError(f"Swiss C version drift: {self.version}")
        self.lib.swe_set_ephe_path(str(ephe_dir.resolve()).encode())
        self.flags = SEFLG_SWIEPH | SEFLG_SPEED

    def state(self, jd: float, body_id: int) -> tuple[float, float]:
        values = (ctypes.c_double * 6)()
        serr = ctypes.create_string_buffer(256)
        returned = int(self.lib.swe_calc_ut(jd, body_id, self.flags, values, serr))
        if returned < 0:
            raise RuntimeError(
                f"swe_calc_ut failed at {jd}: {serr.value.decode(errors='replace')}"
            )
        if not (returned & SEFLG_SWIEPH) or (returned & SEFLG_MOSEPH):
            raise RuntimeError(f"Swiss-file mode lost at {jd}: {returned}")
        return float(values[0]), float(values[3])

    def close(self) -> None:
        self.lib.swe_close()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def normalize360(value: float) -> float:
    value = math.fmod(value, 360.0)
    if value < 0:
        value += 360.0
    return 0.0 if value == 0 else value


def wrap180(value: float) -> float:
    value = math.fmod(value + 180.0, 360.0)
    if value < 0:
        value += 360.0
    return value - 180.0


def percentile(values: list[float], q: float) -> float:
    if not values:
        return 0.0
    ordered = sorted(values)
    return ordered[min(len(ordered) - 1, max(0, math.ceil(q * len(ordered)) - 1))]


def fine_state(longitude: float) -> int:
    return int(math.floor(normalize360(longitude) * 3600.0)) % 1_296_000


def motion(speed: float) -> str:
    return "retrograde" if speed < 0 else "direct"


def motion_byte(byte: int) -> str:
    if byte == 0:
        return "direct"
    if byte == 1:
        return "retrograde"
    raise RuntimeError(f"Invalid motion byte {byte}")


def read_varuint(data: memoryview, offset: int) -> tuple[int, int]:
    value = 0
    shift = 0
    for _ in range(10):
        if offset >= len(data):
            raise RuntimeError("Truncated varint")
        byte = int(data[offset])
        offset += 1
        payload = byte & 0x7F
        if shift == 63 and payload > 1:
            raise RuntimeError("Varint overflow")
        value |= payload << shift
        if not (byte & 0x80):
            return value, offset
        shift += 7
    raise RuntimeError("Oversized varint")


def read_signed_varint(data: memoryview, offset: int) -> tuple[int, int]:
    raw, offset = read_varuint(data, offset)
    return (raw >> 1) ^ -(raw & 1), offset


def apply_circular_delta(previous: int, delta: int, circle_units: int) -> int:
    return (previous + delta) % circle_units


def decode_packed_positions(
    data: memoryview,
    offset: int,
    count: int,
    scale: int,
) -> tuple[list[int], int]:
    if count < 4 or offset + 4 > len(data):
        raise RuntimeError("Malformed packed knot sequence")
    circle_units = 360 * scale
    first = struct.unpack_from("<I", data, offset)[0]
    offset += 4
    if first >= circle_units:
        raise RuntimeError("Packed position outside circle")

    positions = [first]
    first_delta, offset = read_signed_varint(data, offset)
    second = apply_circular_delta(first, first_delta, circle_units)
    positions.append(second)
    previous = second
    previous_delta = first_delta

    for _ in range(2, count):
        second_delta, offset = read_signed_varint(data, offset)
        delta = previous_delta + second_delta
        current = apply_circular_delta(previous, delta, circle_units)
        positions.append(current)
        previous = current
        previous_delta = delta
    return positions, offset


def parse_body(path: Path, expected_body: int) -> dict:
    raw = path.read_bytes()
    data = memoryview(raw)
    offset = 0
    if bytes(data[:8]) != BODY_MAGIC:
        raise RuntimeError(f"Bad body magic: {path}")
    offset = 8
    codec = struct.unpack_from("<H", data, offset)[0]
    offset += 2
    body = int(data[offset])
    offset += 1
    region_count = int(data[offset])
    offset += 1
    scale = struct.unpack_from("<I", data, offset)[0]
    offset += 4
    initial = motion_byte(int(data[offset]))
    offset += 1
    station_count = struct.unpack_from("<I", data, offset)[0]
    offset += 4
    if codec != EXPECTED_CODEC or body != expected_body or region_count != 3:
        raise RuntimeError(f"Malformed body header: {path}")

    stations = []
    for _ in range(station_count):
        if offset + 9 > len(data):
            raise RuntimeError(f"Truncated station chronology: {path}")
        jd = struct.unpack_from("<d", data, offset)[0]
        offset += 8
        after = motion_byte(int(data[offset]))
        offset += 1
        stations.append((jd, after))

    regions = []
    total_knots = 0
    for _ in range(region_count):
        if offset + 28 > len(data):
            raise RuntimeError(f"Truncated region header: {path}")
        start, end, step = struct.unpack_from("<ddd", data, offset)
        offset += 24
        count = struct.unpack_from("<I", data, offset)[0]
        offset += 4
        if not start < end or step <= 0 or count < 4:
            raise RuntimeError(f"Malformed region: {path}")
        positions, offset = decode_packed_positions(data, offset, count, scale)
        total_knots += count
        regions.append(
            {
                "start": start,
                "end": end,
                "step": step,
                "count": count,
                "positions": positions,
            }
        )

    if offset != len(data):
        raise RuntimeError(f"Trailing body bytes: {path}")
    return {
        "raw": raw,
        "codec": codec,
        "body": body,
        "positionScale": scale,
        "initialMotion": initial,
        "stations": stations,
        "regions": regions,
        "knotCount": total_knots,
        "unpackedPositionBytes": total_knots * 4,
        "bytes": len(raw),
        "sha256": sha256_bytes(raw),
    }


def sample_position(series: dict, region: dict, index: int) -> float:
    return region["positions"][index] / series["positionScale"]


def region_for(series: dict, jd: float) -> dict:
    for region in series["regions"]:
        if region["start"] <= jd < region["end"]:
            return region
    raise RuntimeError(f"JD {jd} outside body regions")


def expected_motion(series: dict, jd: float) -> str:
    low, high = 0, len(series["stations"])
    while low < high:
        mid = (low + high) // 2
        if series["stations"][mid][0] <= jd:
            low = mid + 1
        else:
            high = mid
    return series["initialMotion"] if low == 0 else series["stations"][low - 1][1]


def interpolate(series: dict, jd: float) -> tuple[float, float]:
    region = region_for(series, jd)
    x = (jd - region["start"]) / region["step"]
    interval = math.floor(x)
    point_count = 4
    first = min(max(0, interval - 1), region["count"] - point_count)
    indices = list(range(first, first + point_count))
    coordinates = [float(index) for index in indices]

    raw_positions = [sample_position(series, region, index) for index in indices]
    positions = [raw_positions[0]]
    for value in raw_positions[1:]:
        positions.append(
            positions[-1] + wrap180(value - normalize360(positions[-1]))
        )

    value = 0.0
    derivative = 0.0
    for i, xi in enumerate(coordinates):
        basis = 1.0
        for j, xj in enumerate(coordinates):
            if j != i:
                basis *= (x - xj) / (xi - xj)

        derivative_basis = 0.0
        for m, xm in enumerate(coordinates):
            if m == i:
                continue
            term = 1.0 / (xi - xm)
            for j, xj in enumerate(coordinates):
                if j != i and j != m:
                    term *= (x - xj) / (xi - xj)
            derivative_basis += term

        value += positions[i] * basis
        derivative += positions[i] * derivative_basis

    speed = abs(derivative / region["step"])
    if expected_motion(series, jd) == "retrograde":
        speed = -speed
    return normalize360(value), speed


def audit_body(
    series: dict,
    body: int,
    body_id: int,
    swiss: SwissC,
    dense_start: float,
    dense_end: float,
) -> dict:
    angular: list[float] = []
    speeds: list[float] = []
    core: list[float] = []
    edge: list[float] = []
    fine_matches = motion_matches = total = 0
    worst = None

    def check(jd: float) -> None:
        nonlocal fine_matches, motion_matches, total, worst
        ref_lon, ref_speed = swiss.state(jd, body_id)
        spine_lon, spine_speed = interpolate(series, jd)
        error = abs(wrap180(spine_lon - ref_lon)) * 3600.0
        speed_error = abs(spine_speed - ref_speed)
        angular.append(error)
        speeds.append(speed_error)
        total += 1
        (core if dense_start <= jd < dense_end else edge).append(error)
        fine_matches += fine_state(spine_lon) == fine_state(ref_lon)
        motion_matches += motion(spine_speed) == motion(ref_speed)
        if worst is None or error > worst["angularArcseconds"]:
            worst = {
                "julianDay": jd,
                "angularArcseconds": error,
                "referenceLongitude": ref_lon,
                "timespineLongitude": spine_lon,
                "referenceSpeed": ref_speed,
                "timespineSpeed": spine_speed,
            }

    for region in series["regions"]:
        for interval in range(region["count"] - 1):
            t0 = min(region["start"] + interval * region["step"], region["end"])
            t1 = min(region["start"] + (interval + 1) * region["step"], region["end"])
            if t1 <= t0:
                continue
            for fraction in AUDIT_FRACTIONS:
                check(t0 + (t1 - t0) * fraction)

    rng = random.Random(0x4F52424F + body)
    start = series["regions"][0]["start"]
    end = series["regions"][-1]["end"]
    for _ in range(5_000):
        check(start + rng.random() * (end - start))

    unpacked = series["unpackedPositionBytes"]
    return {
        "bodyBytes": series["bytes"],
        "knotCount": series["knotCount"],
        "unpackedPositionBytes": unpacked,
        "bodyBytesPerKnot": series["bytes"] / series["knotCount"],
        "bodyToUnpackedPositionRatio": series["bytes"] / unpacked,
        "stationCount": len(series["stations"]),
        "auditPoints": total,
        "maxAngularArcseconds": max(angular, default=0),
        "maxCoreAngularArcseconds": max(core, default=0),
        "maxEdgeAngularArcseconds": max(edge, default=0),
        "p999AngularArcseconds": percentile(angular, 0.999),
        "p99AngularArcseconds": percentile(angular, 0.99),
        "maxSpeedErrorDegreesPerDay": max(speeds, default=0),
        "p999SpeedErrorDegreesPerDay": percentile(speeds, 0.999),
        "fineStateAgreement": fine_matches / total if total else 1,
        "motionAgreement": motion_matches / total if total else 1,
        "regions": [
            {"sampleDays": region["step"], "samples": region["count"]}
            for region in series["regions"]
        ],
        "worstAngularPoint": worst,
    }


def audit_stations(series: dict, body_id: int, swiss: SwissC) -> dict:
    delta = STATION_PROBE_MINUTES / 1440.0
    start = series["regions"][0]["start"]
    end = series["regions"][-1]["end"]
    mismatches = []
    for root, _ in series["stations"]:
        for side, jd in (("before", root - delta), ("after", root + delta)):
            if not (start <= jd < end):
                continue
            _, ref_speed = swiss.state(jd, body_id)
            _, spine_speed = interpolate(series, jd)
            if motion(ref_speed) != motion(spine_speed):
                mismatches.append(
                    {
                        "stationJulianDay": root,
                        "probe": side,
                        "probeJulianDay": jd,
                        "referenceSpeed": ref_speed,
                        "timespineSpeed": spine_speed,
                    }
                )
    return {
        "stationCount": len(series["stations"]),
        "probeMinutes": STATION_PROBE_MINUTES,
        "motionMismatches": len(mismatches),
        "firstMismatches": mismatches[:20],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--library", required=True)
    parser.add_argument("--ephe-dir", required=True)
    parser.add_argument("--artifact-dir", required=True)
    parser.add_argument("--provenance", required=True)
    parser.add_argument("--report", required=True)
    args = parser.parse_args()

    swiss = SwissC(Path(args.library), Path(args.ephe_dir))
    artifact_dir = Path(args.artifact_dir)
    manifest_raw = (artifact_dir / "mundane-timespine-v1.json").read_bytes()
    manifest = json.loads(manifest_raw)
    if manifest["codec"] != EXPECTED_CODEC:
        raise RuntimeError("Wrong Timespine codec")

    dense_start = float(manifest["denseStartJulianDay"])
    dense_end = float(manifest["denseEndJulianDay"])
    body_reports = {}
    station_reports = {}
    failures = []
    total_body_bytes = 0
    total_knots = 0
    total_unpacked_position_bytes = 0

    for body, (name, body_id) in BODY_IDS.items():
        record = manifest["bodies"][body]
        series = parse_body(artifact_dir / record["file"], body)
        if (
            series["sha256"] != record["sha256"]
            or series["bytes"] != record["bytes"]
            or len(series["stations"]) != record["stationCount"]
            or series["knotCount"] != record["knotCount"]
            or series["unpackedPositionBytes"] != record["unpackedPositionBytes"]
        ):
            raise RuntimeError(f"Manifest/body identity mismatch for {record['body']}")

        total_body_bytes += series["bytes"]
        total_knots += series["knotCount"]
        total_unpacked_position_bytes += series["unpackedPositionBytes"]

        print(f"Auditing {name} codec 4...", flush=True)
        report = audit_body(series, body, body_id, swiss, dense_start, dense_end)
        body_reports[name] = report
        if report["maxEdgeAngularArcseconds"] > MAX_EDGE_ANGULAR_ARCSEC:
            failures.append(
                f"{name} edge max {report['maxEdgeAngularArcseconds']:.9f} arcsec"
            )
        if report["maxCoreAngularArcseconds"] > MAX_CORE_ANGULAR_ARCSEC:
            failures.append(
                f"{name} core max {report['maxCoreAngularArcseconds']:.9f} arcsec"
            )
        if report["p999AngularArcseconds"] > MAX_P999_ANGULAR_ARCSEC:
            failures.append(
                f"{name} p99.9 {report['p999AngularArcseconds']:.9f} arcsec"
            )
        if report["maxSpeedErrorDegreesPerDay"] > MAX_SPEED_ERROR_DEG_PER_DAY:
            failures.append(
                f"{name} speed max {report['maxSpeedErrorDegreesPerDay']:.9g} deg/day"
            )
        if report["fineStateAgreement"] < MIN_FINE_STATE_AGREEMENT:
            failures.append(
                f"{name} RingFineState agreement {report['fineStateAgreement']:.9%}"
            )
        if report["motionAgreement"] < MIN_MOTION_AGREEMENT:
            failures.append(
                f"{name} motion agreement {report['motionAgreement']:.9%}"
            )

        if series["stations"]:
            station = audit_stations(series, body_id, swiss)
            station_reports[name] = station
            if station["motionMismatches"]:
                failures.append(
                    f"{name} has {station['motionMismatches']} station-direction mismatches "
                    f"at +/- {STATION_PROBE_MINUTES:g} minutes"
                )

        del series

    provenance = json.loads(Path(args.provenance).read_text())
    total_bytes = total_body_bytes + len(manifest_raw)
    result = {
        "status": "PASS" if not failures else "FAIL",
        "artifact": {
            "version": manifest["version"],
            "codec": manifest["codec"],
            "astroDNACodec": manifest["astroDNACodec"],
            "representation": manifest["representation"],
            "manifestBytes": len(manifest_raw),
            "manifestSha256": sha256_bytes(manifest_raw),
            "bodyBytes": total_body_bytes,
            "totalBytes": total_bytes,
            "totalMiB": total_bytes / (1024 * 1024),
            "knotCount": total_knots,
            "unpackedPositionBytes": total_unpacked_position_bytes,
            "unpackedPositionMiB": total_unpacked_position_bytes / (1024 * 1024),
            "bodyBytesToUnpackedPositionRatio": (
                total_body_bytes / total_unpacked_position_bytes
                if total_unpacked_position_bytes
                else 0
            ),
            "supportedStartJulianDay": manifest["supportedStartJulianDay"],
            "denseStartJulianDay": dense_start,
            "denseEndJulianDay": dense_end,
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
        "bodies": body_reports,
        "stations": station_reports,
        "sourceProvenance": provenance,
        "failures": failures,
    }
    Path(args.report).write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps(result, indent=2, sort_keys=True))
    swiss.close()

    if failures:
        print("PASS 5 QUALIFICATION FAILED", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print("PASS 5 QUALIFICATION PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
