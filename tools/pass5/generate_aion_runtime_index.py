#!/usr/bin/env python3
"""Generate Aion's compact runtime Shell.sign index from canonical Pass 5 tables.

The canonical CSVs remain construction authority. This artifact is a stripped,
versioned runtime projection for the Ovum. It contains only the interval identity
and boundary-crossing facts Aion needs to resolve and verify temporal addresses.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
from pathlib import Path

SUPPORTED_START_JD = 2297171.740867775  # Z21.01
SUPPORTED_END_JD = 2565295.0945935287   # start Z24.01

FAMILIES = {
    "F": "saturnian-frame-sign-table.csv",
    "R": "uranian-revolt-sign-table.csv",
    "W": "neptunian-wave-sign-table.csv",
    "Z": "plutonian-zeitgeist-sign-table-z21-z23.csv",
}

SHELL_RE = re.compile(r"^([FRWZ])(\d+)$")


def shell_ordinal(shell_id: str, expected_prefix: str) -> int:
    match = SHELL_RE.match(shell_id)
    if not match or match.group(1) != expected_prefix:
        raise RuntimeError(f"Malformed shell id {shell_id!r} for family {expected_prefix}")
    return int(match.group(2))


def load_family(source_dir: Path, prefix: str, filename: str) -> list[dict]:
    path = source_dir / filename
    if not path.is_file():
        raise RuntimeError(f"Missing canonical Shell.sign table: {path}")

    rows: list[dict] = []
    with path.open(newline="", encoding="utf-8") as handle:
        for raw in csv.DictReader(handle):
            start = float(raw["first_direct_ingress_jd_ut"])
            end = float(raw["next_sign_first_direct_ingress_jd_ut"])
            if start >= SUPPORTED_END_JD or end <= SUPPORTED_START_JD:
                continue

            shell_id = raw["shell_id"]
            ordinal = shell_ordinal(shell_id, prefix)
            sign_ordinal = int(raw["sign_ordinal"])
            expected_id = f"{shell_id}.{sign_ordinal:02d}"
            if raw["shell_sign_id"] != expected_id:
                raise RuntimeError(
                    f"Shell.sign id drift: {raw['shell_sign_id']} != {expected_id}"
                )

            crossings_raw = json.loads(raw["transition_crossings"])
            crossings = [
                {
                    "jd_ut": float(c["jd_ut"]),
                    "motion": c["motion"],
                }
                for c in crossings_raw
            ]

            rows.append({
                "shell_sign_id": expected_id,
                "shell_id": shell_id,
                "shell_ordinal": ordinal,
                "sign_ordinal": sign_ordinal,
                "start_jd_ut": start,
                "end_jd_ut": end,
                "crossings": crossings,
            })

    rows.sort(key=lambda row: row["start_jd_ut"])
    audit_family(prefix, rows)
    return rows


def audit_family(prefix: str, rows: list[dict]) -> None:
    if not rows:
        raise RuntimeError(f"Aion {prefix} index is empty")
    if rows[0]["start_jd_ut"] > SUPPORTED_START_JD + 1e-9:
        raise RuntimeError(f"Aion {prefix} index does not cover Z21 start")
    if rows[-1]["end_jd_ut"] < SUPPORTED_END_JD - 1e-9:
        raise RuntimeError(f"Aion {prefix} index does not cover Z23 end")

    for row in rows:
        if row["start_jd_ut"] >= row["end_jd_ut"]:
            raise RuntimeError(f"Non-positive Aion interval: {row['shell_sign_id']}")
        if not 1 <= row["sign_ordinal"] <= 12:
            raise RuntimeError(f"Invalid sign ordinal: {row['shell_sign_id']}")
        crossings = row["crossings"]
        if not crossings:
            raise RuntimeError(f"Missing crossings: {row['shell_sign_id']}")
        if crossings[0]["motion"] != "direct":
            raise RuntimeError(f"First crossing not direct: {row['shell_sign_id']}")
        if abs(crossings[0]["jd_ut"] - row["start_jd_ut"]) > 1e-7:
            raise RuntimeError(f"First crossing/start drift: {row['shell_sign_id']}")
        if any(c["motion"] not in ("direct", "retrograde") for c in crossings):
            raise RuntimeError(f"Unknown crossing motion: {row['shell_sign_id']}")
        if any(a["jd_ut"] >= b["jd_ut"] for a, b in zip(crossings, crossings[1:])):
            raise RuntimeError(f"Crossings not strictly increasing: {row['shell_sign_id']}")

    for left, right in zip(rows, rows[1:]):
        if abs(left["end_jd_ut"] - right["start_jd_ut"]) > 1e-7:
            raise RuntimeError(
                f"Aion {prefix} gap/overlap: {left['shell_sign_id']} -> {right['shell_sign_id']}"
            )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-dir", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    families = {
        prefix: load_family(args.source_dir, prefix, filename)
        for prefix, filename in FAMILIES.items()
    }

    document = {
        "schema_version": 1,
        "notation": "Shell.sign",
        "ownership": "[first_direct_ingress, next_sign_first_direct_ingress)",
        "supported_start_jd_ut": SUPPORTED_START_JD,
        "supported_end_jd_ut": SUPPORTED_END_JD,
        "families": families,
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(document, separators=(",", ":"), sort_keys=True) + "\n",
        encoding="utf-8",
    )

    print(json.dumps({
        "status": "PASS",
        "output": str(args.output),
        "row_counts": {prefix: len(rows) for prefix, rows in families.items()},
        "supported_start_jd_ut": SUPPORTED_START_JD,
        "supported_end_jd_ut": SUPPORTED_END_JD,
    }, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
