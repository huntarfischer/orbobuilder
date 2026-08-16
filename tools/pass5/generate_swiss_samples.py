#!/usr/bin/env python3
"""Generate deterministic Swiss longitude/speed knot data for Orbo's native Forge.

This harness calls the official Swiss Ephemeris C library directly through ctypes.
Python supplies orchestration only. The astronomical calculation is performed by the
qualified C engine that Pass 4 selected.
"""

from __future__ import annotations

import argparse
import ctypes
import hashlib
import json
import math
from pathlib import Path
import struct
import sys

EXPECTED_SWE_VERSION = "2.10.03"
BODY_IDS = {
    "Sun": 0,
    "Moon": 1,
    "Mercury": 2,
    "Venus": 3,
    "Mars": 4,
    "Jupiter": 5,
    "Saturn": 6,
    "Uranus": 7,
    "Neptune": 8,
    "Pluto": 9,
    "True North Node": 11,
}
REQUIRED_FILES = ("sepl_12.se1", "semo_12.se1", "sepl_18.se1", "semo_18.se1")
SEFLG_SWIEPH = 2
SEFLG_MOSEPH = 4
SEFLG_SPEED = 256


class SwissC:
    def __init__(self, library: Path, ephe_dir: Path) -> None:
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

        version_buffer = ctypes.create_string_buffer(256)
        self.lib.swe_version(version_buffer)
        self.version = version_buffer.value.decode("ascii", errors="replace")
        if self.version != EXPECTED_SWE_VERSION:
            raise RuntimeError(f"Swiss C version drift: expected {EXPECTED_SWE_VERSION}, got {self.version}")
        self.lib.swe_set_ephe_path(str(ephe_dir.resolve()).encode())
        self.flags = SEFLG_SWIEPH | SEFLG_SPEED

    def state(self, jd: float, body_id: int) -> tuple[float, float]:
        xx = (ctypes.c_double * 6)()
        serr = ctypes.create_string_buffer(256)
        returned = int(self.lib.swe_calc_ut(jd, body_id, self.flags, xx, serr))
        if returned < 0:
            raise RuntimeError(f"swe_calc_ut failed at JD {jd}: {serr.value.decode(errors='replace')}")
        if not (returned & SEFLG_SWIEPH) or (returned & SEFLG_MOSEPH):
            raise RuntimeError(f"Swiss-file mode required at JD {jd}: flags={returned}")
        return float(xx[0]), float(xx[3])

    def close(self) -> None:
        self.lib.swe_close()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def verify_files(ephe_dir: Path) -> list[dict]:
    records = []
    for name in REQUIRED_FILES:
        path = ephe_dir / name
        if not path.is_file():
            raise RuntimeError(f"Missing qualified Swiss file: {name}")
        header = path.read_bytes()[:512]
        if b"DE441" not in header:
            raise RuntimeError(f"{name} is not the qualified DE441 generation")
        records.append({"name": name, "sha256": sha256(path), "bytes": path.stat().st_size})
    return records


def sample_count(start: float, end: float, step: float) -> int:
    return math.ceil((end - start) / step) + 1


def regions(fixture: dict, profile: dict) -> list[tuple[float, float, float]]:
    start = float(fixture["supportedStartJulianDay"])
    dense_start = float(fixture["denseStartJulianDay"])
    dense_end = float(fixture["denseEndJulianDay"])
    end = float(fixture["supportedEndJulianDay"])
    edge = float(profile["edgeSampleDays"])
    core = float(profile["coreSampleDays"])
    return [(start, dense_start, edge), (dense_start, dense_end, core), (dense_end, end, edge)]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--library", required=True)
    parser.add_argument("--ephe-dir", required=True)
    parser.add_argument("--fixture", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--provenance-output", required=True)
    args = parser.parse_args()

    library = Path(args.library)
    ephe_dir = Path(args.ephe_dir)
    fixture = json.loads(Path(args.fixture).read_text())
    output_path = Path(args.output)
    provenance_path = Path(args.provenance_output)
    start_jd = float(fixture["supportedStartJulianDay"])
    end_jd = float(fixture["supportedEndJulianDay"])

    file_records = verify_files(ephe_dir)
    swiss = SwissC(library, ephe_dir)

    # Force historical and modern reads before manufacture. Any missing-file fallback
    # is rejected by SwissC.state() through the returned ephemeris flags.
    for jd in (start_jd + 10, 2_451_545.0, end_jd - 10):
        swiss.state(jd, BODY_IDS["Sun"])
        swiss.state(jd, BODY_IDS["Moon"])

    expected = sum(
        sum(sample_count(a, b, step) for a, b, step in regions(fixture, profile))
        for profile in fixture["profiles"]
    )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    written = 0
    with output_path.open("wb") as output:
        for profile in fixture["profiles"]:
            body_name = profile["body"]
            body_id = BODY_IDS[body_name]
            body_written = 0
            for region_start, region_end, step in regions(fixture, profile):
                count = sample_count(region_start, region_end, step)
                for index in range(count):
                    jd = min(region_start + index * step, region_end)
                    longitude, speed = swiss.state(jd, body_id)
                    output.write(struct.pack("<dd", longitude, speed))
                    written += 1
                    body_written += 1
            print(f"{body_name}: {body_written:,} stamped knots", flush=True)

    if written != expected:
        raise RuntimeError(f"Sample cardinality mismatch: expected {expected}, wrote {written}")

    provenance = {
        "astronomicalEngine": "official Swiss Ephemeris C library",
        "swissLibraryVersion": swiss.version,
        "files": file_records,
        "flags": swiss.flags,
        "coordinateContract": {
            "center": "geocentric",
            "zodiac": "tropical",
            "frame": "ecliptic of date",
            "position": "standard apparent Swiss Ephemeris position",
            "speed": "SEFLG_SPEED analytic signed longitudinal speed",
            "northNode": "true / osculating",
        },
        "representationCandidate": fixture["representation"],
        "supportedStartJulianDay": start_jd,
        "denseStartJulianDay": fixture["denseStartJulianDay"],
        "denseEndJulianDay": fixture["denseEndJulianDay"],
        "supportedEndJulianDay": end_jd,
        "sampleCount": written,
        "sampleStreamBytes": output_path.stat().st_size,
        "sampleStreamSha256": sha256(output_path),
    }
    provenance_path.write_text(json.dumps(provenance, indent=2, sort_keys=True) + "\n")
    print(json.dumps(provenance, indent=2, sort_keys=True))
    swiss.close()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"PASS 5 SWISS C SAMPLE FAILURE: {exc}", file=sys.stderr)
        raise
