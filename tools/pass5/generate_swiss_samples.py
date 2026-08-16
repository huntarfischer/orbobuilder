#!/usr/bin/env python3
"""Generate deterministic Swiss longitude/speed knot data for Orbo's native Forge.

Python is only the qualified Swiss adapter. It emits Float64 longitude/speed pairs at the
exact knot times declared by the Pass 5 fixture. Swift Forge quantizes, packs, versions,
checksums, and manufactures the eleven independent Mundane Timespine body artifacts.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
import struct
import sys

import swisseph as swe

EXPECTED_SWE_VERSION = "2.10.03"
EXPECTED_DENUM = 441
BODY_IDS = {
    "Sun": swe.SUN,
    "Moon": swe.MOON,
    "Mercury": swe.MERCURY,
    "Venus": swe.VENUS,
    "Mars": swe.MARS,
    "Jupiter": swe.JUPITER,
    "Saturn": swe.SATURN,
    "Uranus": swe.URANUS,
    "Neptune": swe.NEPTUNE,
    "Pluto": swe.PLUTO,
    "True North Node": swe.TRUE_NODE,
}
REQUIRED_FILES = ("sepl_12.se1", "semo_12.se1", "sepl_18.se1", "semo_18.se1")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def swiss_state(jd: float, body_id: int, flags: int) -> tuple[float, float]:
    values, returned_flags = swe.calc_ut(jd, body_id, flags)
    if not (returned_flags & swe.FLG_SWIEPH) or (returned_flags & swe.FLG_MOSEPH):
        raise RuntimeError(f"Swiss-file mode required at JD {jd}: flags={returned_flags}")
    return values[0], values[3]


def verify_files(ephe_dir: Path, start_jd: float, end_jd: float, flags: int) -> dict:
    missing = [name for name in REQUIRED_FILES if not (ephe_dir / name).is_file()]
    if missing:
        raise RuntimeError(f"Missing qualified Swiss files: {', '.join(missing)}")

    probes = [
        (start_jd + 10, swe.SUN, 0, "sepl_12.se1"),
        (start_jd + 10, swe.MOON, 1, "semo_12.se1"),
        (2_451_545.0, swe.SUN, 0, "sepl_18.se1"),
        (2_451_545.0, swe.MOON, 1, "semo_18.se1"),
        (end_jd - 10, swe.SUN, 0, "sepl_18.se1"),
        (end_jd - 10, swe.MOON, 1, "semo_18.se1"),
    ]
    observed = []
    for jd, body_id, file_index, expected_name in probes:
        swiss_state(jd, body_id, flags)
        path, file_start, file_end, denum = swe.get_current_file_data(file_index)
        if Path(path).name != expected_name or denum != EXPECTED_DENUM:
            raise RuntimeError(
                f"Expected {expected_name} / DE{EXPECTED_DENUM} at JD {jd}; got {path!r} / DE{denum}"
            )
        observed.append({
            "probeJulianDay": jd,
            "file": expected_name,
            "fileStartJulianDay": file_start,
            "fileEndJulianDay": file_end,
            "denum": denum,
        })
    return {
        "swissLibraryVersion": swe.version,
        "files": [
            {"name": name, "sha256": sha256(ephe_dir / name), "bytes": (ephe_dir / name).stat().st_size}
            for name in REQUIRED_FILES
        ],
        "probes": observed,
    }


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
    parser.add_argument("--ephe-dir", required=True)
    parser.add_argument("--fixture", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--provenance-output", required=True)
    args = parser.parse_args()

    ephe_dir = Path(args.ephe_dir).resolve()
    fixture = json.loads(Path(args.fixture).read_text())
    output_path = Path(args.output)
    provenance_path = Path(args.provenance_output)
    start_jd = float(fixture["supportedStartJulianDay"])
    end_jd = float(fixture["supportedEndJulianDay"])

    if swe.version != EXPECTED_SWE_VERSION:
        raise RuntimeError(f"Swiss version drift: expected {EXPECTED_SWE_VERSION}, got {swe.version}")

    swe.set_ephe_path(str(ephe_dir))
    flags = swe.FLG_SWIEPH | swe.FLG_SPEED
    provenance = verify_files(ephe_dir, start_jd, end_jd, flags)

    expected = 0
    for profile in fixture["profiles"]:
        expected += sum(sample_count(a, b, step) for a, b, step in regions(fixture, profile))

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
                    longitude, speed = swiss_state(jd, body_id, flags)
                    output.write(struct.pack("<dd", longitude, speed))
                    written += 1
                    body_written += 1
            print(f"{body_name}: {body_written:,} stamped knots", flush=True)

    if written != expected:
        raise RuntimeError(f"Sample cardinality mismatch: expected {expected}, wrote {written}")

    provenance.update({
        "adapter": "pyswisseph",
        "adapterPackageVersion": "2.10.3.2",
        "flags": int(flags),
        "coordinateContract": {
            "center": "geocentric",
            "zodiac": "tropical",
            "frame": "ecliptic of date",
            "position": "standard apparent Swiss Ephemeris position",
            "speed": "signed longitudinal speed",
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
    })
    provenance_path.write_text(json.dumps(provenance, indent=2, sort_keys=True) + "\n")
    print(json.dumps(provenance, indent=2, sort_keys=True))
    swe.close()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"PASS 5 SWISS SAMPLE FAILURE: {exc}", file=sys.stderr)
        raise
