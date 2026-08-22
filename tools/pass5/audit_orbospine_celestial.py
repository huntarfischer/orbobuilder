#!/usr/bin/env python3
"""Closeout audit for Pass C4 OrboSpine celestial matter.

This auditor is independent of the Swift forge. It verifies the frozen C4 fingerprint,
manifest/checkpoint provenance, repo-local Swiss/DE441 apparatus, and CSV topology.
It does not manufacture or alter celestial matter.
"""
from __future__ import annotations

import argparse
import csv
import ctypes
import hashlib
import json
import math
import platform
import subprocess
import sys
from pathlib import Path
from typing import Any

IDENTITY = "OrboSpine"
MATTER_FORMAT = "directional-degree-csv"
MATTER_VERSION = 1
CHECKPOINT_VERSION = 1
ASTRONOMICAL_SOURCE = (
    "Swiss Ephemeris DE441; geocentric tropical apparent ecliptic longitude; UT"
)
SWISS_VERSION = "2.10.03"
SWISS_COMMIT = "3fd0f956d73898b91cc4f67cf18b21af656d1342"
SUPPORTED_START = 2_297_171.740867775
SUPPORTED_END = 2_565_295.0945935287

ZEITGEISTS = [
    (
        "Z21",
        2_297_171.740867775,
        2_386_637.0793997087,
        "1577-05-05T05:46:50.976Z",
        "1822-04-16T13:54:20.135Z",
    ),
    (
        "Z22",
        2_386_637.0793997087,
        2_475_819.1417904533,
        "1822-04-16T13:54:20.135Z",
        "2066-06-17T15:24:10.695Z",
    ),
    (
        "Z23",
        2_475_819.1417904533,
        2_565_295.0945935287,
        "2066-06-17T15:24:10.695Z",
        "2311-06-10T14:16:12.881Z",
    ),
]

# Frozen from the completed C4 manufacture on the pinned source.
BODY_FINGERPRINTS = [
    (
        "Sun", 10.0, 26_427, 0,
        "de44b6924980649587aa7c27a2b256a0c5c5319268a1450835b7cce3b21c255c",
        "38e76f4c4a6ac287ab7029400074b714b3f3784c503647a22be9e4736f971f74",
    ),
    (
        "Moon", 10.0, 353_290, 0,
        "7d62e4a2dbd983612a61fb22149858b244d0218026266c964b58fa9cd369650e",
        "38e76f4c4a6ac287ab7029400074b714b3f3784c503647a22be9e4736f971f74",
    ),
    (
        "Mercury", 1.0, 326_414, 4_627,
        "03207faa7f850cc795988c7bbb67401c3725c08ac8c49cb4266ebe58ae7e0b4e",
        "446894de88d8fdc30d8115e56fa44831c49b5225a5d1e1f5f1c2ab69e55258da",
    ),
    (
        "Venus", 1.0, 278_960, 919,
        "b287354f5f85c7833b988e1b6abc560d521595f264757ba119481f9ecf3ace59",
        "ea27188c4f50873986491a7725718ba28f33a8230c764ff98a5ea7e76e9153d8",
    ),
    (
        "Mars", 1.0, 151_788, 688,
        "fd700dfe0c12ac208e27c91cf6412022abec43856c5fb92f1ed932832780b2db",
        "81d4ed30f9cc5f043c258a423f7a2f38245ff11d25285a3de3b69f2a627a238d",
    ),
    (
        "Jupiter", 0.5, 71_330, 1_344,
        "e59315abb0312334409ac56ce2cb080108b424de848b46b3e78c634cf242710e",
        "e4eb78246f5219fb0668f80e1fe42774495999b57b4f37bb6c899350dc44a587",
    ),
    (
        "Saturn", 0.5, 37_206, 1_418,
        "2984263b380571e376844b10b3faecac88169281925f7bf077a03bb98354de5d",
        "f0bec8593750a59b349ee0b9f809e42c9526e648de05d588f8edbd9d20cb5f13",
    ),
    (
        "Uranus", 0.2, 44_969, 1_451,
        "27d8915f12c1e4d1033275119f18c8337d6568afd983fdceb69d411c88e42fec",
        "e7a5aa04d0b45aecc354e4dfbd3ee986057f6846f50abfb7c2566067679e90cf",
    ),
    (
        "Neptune", 0.1, 56_865, 1_459,
        "fa8e0b6aeb64e22ff367c0437aa46c238e617c33246fa6d8a5f37a682c263a63",
        "91d5597c5667abde9b5f176ca27feb0dfc1bd4b45551f7fc206bfc51cdfd8657",
    ),
    (
        "Pluto", 0.1, 44_244, 1_462,
        "83f32383c6b9bfdcf2b78437658146e419170a6617f23a2ed68ae9205d501d18",
        "948bdbcf66f4fafe7a07a2e969c5dab82eb23b365dcd2081bcccb7c66be3fc4f",
    ),
    (
        "True North Node", 0.1, 158_736, 39_311,
        "5d766f39cc2410b6861c692d3de8913d2c1eb986936cd88e3088bac312aa7ff7",
        "f3c8ade2d18f56566de6352b6c3f68938cd033c4a3dde32b9e5903f106610a74",
    ),
]

EXPECTED_TOTAL_SUPPORT_ROWS = 1_550_229
EXPECTED_TOTAL_STATION_ROWS = 52_679

REQUIRED_EPHEMERIS_FILES = [
    "seplm36.se1", "seplm30.se1", "seplm24.se1", "seplm18.se1", "seplm12.se1", "seplm06.se1",
    "sepl_00.se1", "sepl_06.se1", "sepl_12.se1", "sepl_18.se1", "sepl_24.se1",
    "semom36.se1", "semom30.se1", "semom24.se1", "semom18.se1", "semom12.se1", "semom06.se1",
    "semo_00.se1", "semo_06.se1", "semo_12.se1", "semo_18.se1", "semo_24.se1",
]

SUPPORT_HEADER = [
    "directional_degree", "physical_degree", "navigation_cell",
    "motion", "jd_ut", "civic_offset_seconds",
]
STATION_HEADER = [
    "physical_degree", "directional_degree_after", "navigation_cell_after",
    "lane_before", "lane_after", "jd_ut",
]
MOTIONS = {"direct", "retrograde"}
TOLERANCE = 1e-8


class AuditFailure(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AuditFailure(message)


def close(a: float, b: float, tolerance: float = TOLERANCE) -> bool:
    return abs(a - b) <= tolerance


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_json(path: Path) -> dict[str, Any]:
    require(path.is_file(), f"missing JSON: {path}")
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    require(isinstance(value, dict), f"JSON root is not an object: {path}")
    return value


def check_file(path: Path, expected_bytes: int, expected_sha: str) -> None:
    require(path.is_file(), f"missing matter file: {path.name}")
    actual_bytes = path.stat().st_size
    require(
        actual_bytes == expected_bytes,
        f"{path.name} bytes {actual_bytes} != manifest {expected_bytes}",
    )
    actual_sha = sha256(path)
    require(actual_sha == expected_sha, f"{path.name} SHA-256 {actual_sha} != {expected_sha}")


def swiss_library_path(forge_root: Path) -> Path:
    system = platform.system()
    if system == "Darwin":
        name = "libswe.dylib"
    elif system == "Linux":
        name = "libswe.so"
    else:
        raise AuditFailure(f"unsupported audit host: {system}")
    return forge_root / "swisseph" / name


def swiss_version(library: Path) -> str:
    lib = ctypes.CDLL(str(library.resolve()))
    lib.swe_version.argtypes = [ctypes.c_char_p]
    lib.swe_version.restype = ctypes.c_char_p
    buffer = ctypes.create_string_buffer(128)
    lib.swe_version(buffer)
    return buffer.value.decode("ascii", errors="replace")


def git_head(path: Path) -> str:
    result = subprocess.run(
        ["git", "-C", str(path), "rev-parse", "HEAD"],
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def validate_provenance(
    manifest: dict[str, Any],
    checkpoint: dict[str, Any],
    forge_root: Path,
) -> dict[str, Any]:
    shared = [
        "identity",
        "matterFormat",
        "matterVersion",
        "astronomicalSource",
        "astronomicalSourceVersion",
        "swissLibrarySHA256",
        "ephemerisFiles",
        "supportedStartJulianDayUT",
        "supportedEndJulianDayUT",
    ]
    for key in shared:
        require(
            manifest.get(key) == checkpoint.get(key),
            f"manifest/checkpoint provenance mismatch: {key}",
        )

    require(manifest["identity"] == IDENTITY, "identity drift")
    require(manifest["matterFormat"] == MATTER_FORMAT, "matter format drift")
    require(manifest["matterVersion"] == MATTER_VERSION, "matter version drift")
    require(checkpoint.get("checkpointVersion") == CHECKPOINT_VERSION, "checkpoint version drift")
    require(manifest["astronomicalSource"] == ASTRONOMICAL_SOURCE, "astronomical source drift")
    require(manifest["astronomicalSourceVersion"] == SWISS_VERSION, "Swiss version provenance drift")
    require(close(float(manifest["supportedStartJulianDayUT"]), SUPPORTED_START), "start JD drift")
    require(close(float(manifest["supportedEndJulianDayUT"]), SUPPORTED_END), "end JD drift")
    require(
        manifest.get("checkpointFile") == "orbospine-celestial-checkpoint.json",
        "manifest checkpoint filename drift",
    )
    require(
        manifest.get("runtimeStorage") == "none / Pass D not begun",
        "C4 manifest improperly claims runtime storage",
    )

    swiss_dir = forge_root / "swisseph"
    library = swiss_library_path(forge_root)
    require(library.is_file(), f"missing repo-local Swiss library: {library}")
    actual_commit = git_head(swiss_dir)
    require(actual_commit == SWISS_COMMIT, f"Swiss source commit {actual_commit} != {SWISS_COMMIT}")
    actual_version = swiss_version(library)
    require(actual_version == SWISS_VERSION, f"Swiss runtime version {actual_version} != {SWISS_VERSION}")
    actual_library_sha = sha256(library)
    require(
        actual_library_sha == manifest["swissLibrarySHA256"],
        "repo-local Swiss library SHA-256 != manifest/checkpoint",
    )

    reports = manifest["ephemerisFiles"]
    require(isinstance(reports, list), "ephemerisFiles is not a list")
    report_names = [item["name"] for item in reports]
    require(report_names == REQUIRED_EPHEMERIS_FILES, "DE441 file list/order drift")

    ephe_dir = forge_root / "ephe"
    for report in reports:
        path = ephe_dir / report["name"]
        require(path.is_file(), f"missing staged DE441 file: {path.name}")
        with path.open("rb") as handle:
            require(b"DE441" in handle.read(512), f"{path.name} is not DE441-generation")
        require(path.stat().st_size == int(report["bytes"]), f"{path.name} byte count != provenance")
        require(sha256(path) == report["sha256"], f"{path.name} SHA-256 != provenance")

    return {
        "swissCommit": actual_commit,
        "swissVersion": actual_version,
        "swissLibrarySHA256": actual_library_sha,
        "ephemerisFiles": len(reports),
    }


def validate_zeitgeists(manifest: dict[str, Any]) -> None:
    reports = manifest.get("zeitgeists")
    require(isinstance(reports, list) and len(reports) == 3, "manifest must contain Z21-Z23")
    for report, expected in zip(reports, ZEITGEISTS):
        shell, start, end, start_utc, end_utc = expected
        require(report.get("shell") == shell, f"{shell} identity drift")
        require(close(float(report["startJulianDayUT"]), start), f"{shell} start JD drift")
        require(close(float(report["endJulianDayUT"]), end), f"{shell} end JD drift")
        require(report.get("startUTC") == start_utc, f"{shell} start UTC drift")
        require(report.get("endUTC") == end_utc, f"{shell} end UTC drift")


def parse_supports(path: Path, expected_rows: int, support_degrees: float) -> dict[str, Any]:
    count = 0
    previous_jd: float | None = None
    motions: set[str] = set()
    first: dict[str, str] | None = None
    last: dict[str, str] | None = None

    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        require(reader.fieldnames == SUPPORT_HEADER, f"{path.name} support header drift")
        for row in reader:
            count += 1
            if count % 250_000 == 0:
                print(f"  {path.name}: {count} support rows audited", flush=True)
            if first is None:
                first = dict(row)
            last = dict(row)

            directional = float(row["directional_degree"])
            physical = float(row["physical_degree"])
            navigation = int(row["navigation_cell"])
            motion = row["motion"]
            jd = float(row["jd_ut"])
            int(row["civic_offset_seconds"])

            require(0 <= directional < 720, f"{path.name}:{count} directional degree outside [0,720)")
            require(0 <= physical < 360, f"{path.name}:{count} physical degree outside [0,360)")
            expected_physical = directional if directional < 360 else directional - 360
            require(
                close(physical, expected_physical),
                f"{path.name}:{count} physical/directional projection mismatch",
            )
            require(navigation == math.floor(directional), f"{path.name}:{count} navigation cell mismatch")
            expected_motion = "direct" if directional < 360 else "retrograde"
            require(motion == expected_motion, f"{path.name}:{count} motion/lane mismatch")
            require(
                SUPPORTED_START <= jd < SUPPORTED_END,
                f"{path.name}:{count} JD outside half-open C4 span",
            )
            if previous_jd is not None:
                require(jd > previous_jd, f"{path.name}:{count} UT is not strictly increasing")
            previous_jd = jd

            grid_units = physical / support_degrees
            require(
                close(grid_units, round(grid_units), 1e-7),
                f"{path.name}:{count} support is off the {support_degrees:g}-degree grid",
            )
            motions.add(motion)

    require(count == expected_rows, f"{path.name} rows {count} != expected {expected_rows}")
    return {"rows": count, "motions": sorted(motions), "first": first, "last": last}


def parse_stations(path: Path, expected_rows: int) -> dict[str, Any]:
    count = 0
    previous_jd: float | None = None
    transitions: set[str] = set()
    first: dict[str, str] | None = None
    last: dict[str, str] | None = None

    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        require(reader.fieldnames == STATION_HEADER, f"{path.name} station header drift")
        for row in reader:
            count += 1
            if first is None:
                first = dict(row)
            last = dict(row)

            physical = float(row["physical_degree"])
            directional = float(row["directional_degree_after"])
            navigation = int(row["navigation_cell_after"])
            before = row["lane_before"]
            after = row["lane_after"]
            jd = float(row["jd_ut"])

            require(0 <= directional < 720, f"{path.name}:{count} directional degree outside [0,720)")
            require(0 <= physical < 360, f"{path.name}:{count} physical degree outside [0,360)")
            expected_physical = directional if directional < 360 else directional - 360
            require(close(physical, expected_physical), f"{path.name}:{count} station projection mismatch")
            require(
                navigation == math.floor(directional),
                f"{path.name}:{count} station navigation cell mismatch",
            )
            require(
                before in MOTIONS and after in MOTIONS and before != after,
                f"{path.name}:{count} invalid station lane transition",
            )
            expected_after = "direct" if directional < 360 else "retrograde"
            require(
                after == expected_after,
                f"{path.name}:{count} directional lane does not belong to lane_after",
            )
            require(
                SUPPORTED_START <= jd < SUPPORTED_END,
                f"{path.name}:{count} station JD outside half-open C4 span",
            )
            if previous_jd is not None:
                require(jd > previous_jd, f"{path.name}:{count} station UT is not strictly increasing")
            previous_jd = jd
            transitions.add(f"{before}->{after}")

    require(count == expected_rows, f"{path.name} rows {count} != expected {expected_rows}")
    return {"rows": count, "transitions": sorted(transitions), "first": first, "last": last}


def validate_bodies(
    manifest: dict[str, Any],
    checkpoint: dict[str, Any],
    output_dir: Path,
) -> list[dict[str, Any]]:
    bodies = manifest.get("bodies")
    completed = checkpoint.get("completedBodies")
    require(isinstance(bodies, list), "manifest bodies is not a list")
    require(bodies == completed, "manifest bodies != checkpoint completedBodies")
    require(len(bodies) == len(BODY_FINGERPRINTS), "manifest does not contain exactly the Eleven")

    expected_names = [item[0] for item in BODY_FINGERPRINTS]
    require([item["body"] for item in bodies] == expected_names, "canonical body order drift")

    results: list[dict[str, Any]] = []
    for report, fingerprint in zip(bodies, BODY_FINGERPRINTS):
        name, support_degrees, support_rows, station_rows, support_sha, station_sha = fingerprint
        print(f"audit {name}: fingerprint + files + topology", flush=True)

        require(report["body"] == name, f"{name} report identity drift")
        require(close(float(report["supportDegrees"]), support_degrees), f"{name} support law drift")
        require(int(report["supportRows"]) == support_rows, f"{name} support row count drift")
        require(int(report["stationRows"]) == station_rows, f"{name} station row count drift")
        require(report["astronomicalSourceVersion"] == SWISS_VERSION, f"{name} source version drift")
        require(
            close(float(report["supportedStartJulianDayUT"]), SUPPORTED_START),
            f"{name} start JD drift",
        )
        require(
            close(float(report["supportedEndJulianDayUT"]), SUPPORTED_END),
            f"{name} end JD drift",
        )
        require(report["supportSHA256"] == support_sha, f"{name} support fingerprint drift")
        require(report["stationSHA256"] == station_sha, f"{name} station fingerprint drift")

        support_path = output_dir / report["supportFile"]
        station_path = output_dir / report["stationFile"]
        check_file(support_path, int(report["supportFileBytes"]), support_sha)
        check_file(station_path, int(report["stationFileBytes"]), station_sha)

        support_result = parse_supports(support_path, support_rows, support_degrees)
        station_result = parse_stations(station_path, station_rows)

        if name in {"Sun", "Moon"}:
            require(station_rows == 0, f"{name} unexpectedly has stations")
            require(support_result["motions"] == ["direct"], f"{name} is not direct-only")
        else:
            require(station_rows > 0, f"{name} unexpectedly has no stations")
            require(
                support_result["motions"] == ["direct", "retrograde"],
                f"{name} does not occupy both directional lanes",
            )

        results.append(
            {
                "body": name,
                "supportRows": support_result["rows"],
                "stationRows": station_result["rows"],
                "motions": support_result["motions"],
                "stationTransitions": station_result["transitions"],
                "firstSupport": support_result["first"],
                "lastSupport": support_result["last"],
                "firstStation": station_result["first"],
                "lastStation": station_result["last"],
                "supportSHA256": support_sha,
                "stationSHA256": station_sha,
            }
        )
        print(f"  PASS {name}: {support_rows} supports / {station_rows} stations", flush=True)

    total_supports = sum(int(item["supportRows"]) for item in bodies)
    total_stations = sum(int(item["stationRows"]) for item in bodies)
    require(total_supports == EXPECTED_TOTAL_SUPPORT_ROWS, "frozen total support row count drift")
    require(total_stations == EXPECTED_TOTAL_STATION_ROWS, "frozen total station row count drift")
    require(
        int(manifest.get("totalSupportRows", -1)) == total_supports,
        "manifest totalSupportRows mismatch",
    )
    require(
        int(manifest.get("totalStationRows", -1)) == total_stations,
        "manifest totalStationRows mismatch",
    )
    return results


def main() -> int:
    script = Path(__file__).resolve()
    repo_root = script.parents[2]

    parser = argparse.ArgumentParser(description="Audit completed Pass C4 OrboSpine celestial matter.")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=repo_root / "tools/pass5/orbospine-build/celestial",
    )
    parser.add_argument(
        "--forge-root",
        type=Path,
        default=repo_root / ".forge",
    )
    parser.add_argument(
        "--report",
        type=Path,
        default=None,
        help="successful audit report path; defaults inside the C4 output directory",
    )
    args = parser.parse_args()

    output_dir = args.output_dir.resolve()
    forge_root = args.forge_root.resolve()
    report_path = (args.report or output_dir / "orbospine-celestial-audit.json").resolve()

    try:
        print("ORBO AUDIT / C4 CELESTIAL CLOSEOUT", flush=True)
        print(f"matter: {output_dir}", flush=True)
        print(f"apparatus: {forge_root}", flush=True)

        manifest = load_json(output_dir / "orbospine-celestial-manifest.json")
        checkpoint = load_json(output_dir / "orbospine-celestial-checkpoint.json")

        provenance = validate_provenance(manifest, checkpoint, forge_root)
        print(
            "PASS provenance: pinned Swiss + 22 DE441 files + checkpoint/manifest agreement",
            flush=True,
        )

        validate_zeitgeists(manifest)
        print("PASS Bone: exact half-open Z21 -> Z22 -> Z23", flush=True)

        body_results = validate_bodies(manifest, checkpoint, output_dir)

        spot_names = {"Sun", "Mercury", "True North Node"}
        spot_checks = [item for item in body_results if item["body"] in spot_names]
        report = {
            "identity": IDENTITY,
            "pass": "C4 celestial closeout",
            "status": "PASS",
            "matterFormat": MATTER_FORMAT,
            "matterVersion": MATTER_VERSION,
            "supportedStartJulianDayUT": SUPPORTED_START,
            "supportedEndJulianDayUT": SUPPORTED_END,
            "provenance": provenance,
            "totalSupportRows": EXPECTED_TOTAL_SUPPORT_ROWS,
            "totalStationRows": EXPECTED_TOTAL_STATION_ROWS,
            "totalCelestialRecords": EXPECTED_TOTAL_SUPPORT_ROWS + EXPECTED_TOTAL_STATION_ROWS,
            "bodies": body_results,
            "topologySpotChecks": spot_checks,
            "scopeBoundary": (
                "C4 celestial matter only; no runtime image, Ring, Terra, shell linkage, "
                "eclipse annotation, Dioscuri certification, or Hephaestus seal."
            ),
        }
        report_path.parent.mkdir(parents=True, exist_ok=True)
        with report_path.open("w", encoding="utf-8") as handle:
            json.dump(report, handle, indent=2, sort_keys=True)
            handle.write("\n")

        print(
            "PASS topology: full CSV structural scan; Sun / Mercury / True North Node spot evidence retained"
        )
        print(
            f"PASS totals: {EXPECTED_TOTAL_SUPPORT_ROWS} supports / {EXPECTED_TOTAL_STATION_ROWS} stations"
        )
        print(f"audit report: {report_path}")
        print("C4 CLOSEOUT AUDIT: PASS")
        return 0
    except (AuditFailure, KeyError, ValueError, OSError, subprocess.CalledProcessError) as exc:
        print(f"C4 CLOSEOUT AUDIT: FAIL / {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
