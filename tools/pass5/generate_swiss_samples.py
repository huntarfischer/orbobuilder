#!/usr/bin/env python3
"""Generate the deterministic Swiss Ephemeris longitude stream consumed by Orbo's native Forge.

This tool is an astronomical adapter, not a second Timespine implementation. It reads the
Pass 5 profile, asks the qualified Swiss Ephemeris for the exact Chebyshev sample nodes used
by MundaneTimespineForge, and writes only those longitudes as little-endian Float64 values.
The Swift Forge remains responsible for fitting, quantization, codec construction, and the
finished artifact.
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

REQUIRED_FILES = (
    "sepl_12.se1",
    "semo_12.se1",
    "sepl_18.se1",
    "semo_18.se1",
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def require_swiss_mode(jd: float, body_id: int, flags: int) -> tuple[float, float]:
    values, returned_flags = swe.calc_ut(jd, body_id, flags)
    if not (returned_flags & swe.FLG_SWIEPH) or (returned_flags & swe.FLG_MOSEPH):
        raise RuntimeError(
            f"Swiss-file mode required at JD {jd}: returned flags {returned_flags}"
        )
    return values[0], values[3]


def verify_ephemeris_files(ephe_dir: Path, start_jd: float, end_jd: float, flags: int) -> dict:
    missing = [name for name in REQUIRED_FILES if not (ephe_dir / name).is_file()]
    if missing:
        raise RuntimeError(f"Missing qualified Swiss files: {', '.join(missing)}")

    # Exercise both 600-year file blocks and both planet/lunar file families.
    probes = [
        (start_jd + 10.0, swe.SUN, 0, "sepl_12.se1"),
        (start_jd + 10.0, swe.MOON, 1, "semo_12.se1"),
        (2_451_545.0, swe.SUN, 0, "sepl_18.se1"),
        (2_451_545.0, swe.MOON, 1, "semo_18.se1"),
        (end_jd - 10.0, swe.SUN, 0, "sepl_18.se1"),
        (end_jd - 10.0, swe.MOON, 1, "semo_18.se1"),
    ]

    observed = []
    for jd, body_id, file_index, expected_name in probes:
        require_swiss_mode(jd, body_id, flags)
        path, file_start, file_end, denum = swe.get_current_file_data(file_index)
        if not path or Path(path).name != expected_name:
            raise RuntimeError(
                f"Expected {expected_name} at JD {jd}, Swiss reports {path!r}"
            )
        if denum != EXPECTED_DENUM:
            raise RuntimeError(
                f"Expected DE{EXPECTED_DENUM} provenance for {expected_name}, got DE{denum}"
            )
        if not (file_start <= jd <= file_end):
            raise RuntimeError(
                f"Swiss file range {file_start}..{file_end} does not contain probe JD {jd}"
            )
        observed.append(
            {
                "probeJulianDay": jd,
                "file": expected_name,
                "fileStartJulianDay": file_start,
                "fileEndJulianDay": file_end,
                "denum": denum,
            }
        )

    return {
        "swissLibraryVersion": swe.version,
        "files": [
            {
                "name": name,
                "sha256": sha256(ephe_dir / name),
                "bytes": (ephe_dir / name).stat().st_size,
            }
            for name in REQUIRED_FILES
        ],
        "probes": observed,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ephe-dir", required=True)
    parser.add_argument("--fixture", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--provenance-output", required=True)
    args = parser.parse_args()

    ephe_dir = Path(args.ephe_dir).resolve()
    fixture_path = Path(args.fixture)
    output_path = Path(args.output)
    provenance_path = Path(args.provenance_output)

    fixture = json.loads(fixture_path.read_text())
    start_jd = float(fixture["supportedStartJulianDay"])
    end_jd = float(fixture["supportedEndJulianDay"])
    degree = int(fixture["polynomialDegree"])
    profiles = fixture["profiles"]

    if swe.version != EXPECTED_SWE_VERSION:
        raise RuntimeError(
            f"Swiss library version drift: expected {EXPECTED_SWE_VERSION}, got {swe.version}"
        )

    swe.set_ephe_path(str(ephe_dir))
    flags = swe.FLG_SWIEPH | swe.FLG_SPEED
    provenance = verify_ephemeris_files(ephe_dir, start_jd, end_jd, flags)

    sample_count = 0
    for profile in profiles:
        segment_days = float(profile["segmentDays"])
        sample_count += math.ceil((end_jd - start_jd) / segment_days) * (degree + 1)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("wb") as output:
        written = 0
        for profile in profiles:
            body_name = profile["body"]
            body_id = BODY_IDS[body_name]
            segment_days = float(profile["segmentDays"])
            segment_count = math.ceil((end_jd - start_jd) / segment_days)
            node_count = degree + 1

            for segment_index in range(segment_count):
                segment_start = start_jd + segment_index * segment_days
                for j in range(node_count):
                    theta = math.pi * (j + 0.5) / node_count
                    x = math.cos(theta)
                    jd = segment_start + (x + 1.0) * segment_days / 2.0
                    longitude, _ = require_swiss_mode(jd, body_id, flags)
                    output.write(struct.pack("<d", longitude))
                    written += 1

                if segment_index and segment_index % 25_000 == 0:
                    print(
                        f"{body_name}: {segment_index:,}/{segment_count:,} segments",
                        flush=True,
                    )

    if written != sample_count:
        raise RuntimeError(f"Sample cardinality mismatch: expected {sample_count}, wrote {written}")

    provenance.update(
        {
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
            "supportedStartJulianDay": start_jd,
            "supportedEndJulianDay": end_jd,
            "polynomialDegree": degree,
            "sampleCount": sample_count,
            "sampleStreamBytes": output_path.stat().st_size,
            "sampleStreamSha256": sha256(output_path),
        }
    )
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
