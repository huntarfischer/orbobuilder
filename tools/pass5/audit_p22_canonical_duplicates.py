#!/usr/bin/env python3
"""Audit every canonical P22 construction input for duplicate emissions.

This is a repository-data gate, not an astronomical recomputation. It walks the exact
17 gzip CSV inputs admitted by the body/motion and universal-event manifests and proves:

1. no input contains an identical CSV row twice;
2. no relationship source rows collapse to the same native stored relationship at the
   same civic second; and
3. the four known storage-level celestial recurrences remain present at distinct civic
   occurrences, so recurrence is preserved rather than deleted.

Relationship storage identity follows MundaneTimespineStorageEncoder: body pair, Ring mark,
orientation, body A rounded to one microdegree, and the rounded civic second. Body B is not
encoded independently; it is reconstructed from the exact relationship geometry.
"""

from __future__ import annotations

import csv
import gzip
import json
import math
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DATA = ROOT / "p22-data"

EXPECTED_CANONICAL_INPUTS = 17
EXPECTED_RELATIONSHIP_ROWS = 770_293
EXPECTED_NATIVE_RECURRENCE_GROUPS = 4
EXPECTED_NATIVE_RECURRENCE_EXTRA_OCCURRENCES = 4


def fail(message: str) -> None:
    raise AssertionError(message)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def load_json(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def microdegrees(text: str) -> int:
    degrees = float(text) % 360.0
    # Swift's positive Double.rounded() is nearest with .5 away from zero.
    return int(math.floor(degrees * 1_000_000.0 + 0.5)) % 360_000_000


def canonical_paths() -> list[Path]:
    body_manifest = load_json(DATA / "manifest.json")
    universal_manifest = load_json(DATA / "universal-events-manifest.json")

    body_paths = [DATA / record["path"] for record in body_manifest["files"]]
    universal_paths = [DATA / record["path"] for record in universal_manifest["files"]]
    paths = body_paths + universal_paths

    require(len(body_paths) == 14, f"expected 14 body/motion inputs, found {len(body_paths)}")
    require(len(universal_paths) == 3, f"expected 3 universal-event inputs, found {len(universal_paths)}")
    require(len(paths) == EXPECTED_CANONICAL_INPUTS, f"expected 17 canonical inputs, found {len(paths)}")
    require(len(set(paths)) == len(paths), "canonical input manifests repeat a path")
    require(all(path.is_file() for path in paths), "one or more canonical inputs are missing")
    return paths


def audit_literal_rows(path: Path) -> int:
    seen: set[tuple[str, ...]] = set()
    rows = 0
    with gzip.open(path, "rt", encoding="utf-8", newline="") as handle:
        reader = csv.reader(handle)
        try:
            header = next(reader)
        except StopIteration:
            fail(f"empty canonical input: {path.relative_to(DATA)}")
        require(bool(header), f"missing CSV header: {path.relative_to(DATA)}")

        for line_number, row in enumerate(reader, start=2):
            rows += 1
            key = tuple(row)
            require(
                key not in seen,
                f"literal duplicate row in {path.relative_to(DATA)} at CSV line {line_number}",
            )
            seen.add(key)

    print(f"PASS literal {str(path.relative_to(DATA)):48s} rows={rows}")
    return rows


def relationship_paths() -> list[Path]:
    manifest = load_json(DATA / "universal-events-manifest.json")
    paths: list[Path] = []
    for record in manifest["files"]:
        if record["family"] in {"exact-major-relationships", "exact-minor-relationships"}:
            paths.append(DATA / record["path"])
    require(len(paths) == 2, "relationship canonical input set changed")
    return paths


def audit_relationship_storage_identity() -> None:
    celestial_counts: Counter[tuple[str, str, int, str, int]] = Counter()
    seen_occurrences: set[tuple[tuple[str, str, int, str, int], int]] = set()
    rows = 0

    for path in relationship_paths():
        with gzip.open(path, "rt", encoding="utf-8", newline="") as handle:
            reader = csv.DictReader(handle)
            required = {
                "bodyA",
                "bodyB",
                "ringDegrees",
                "orientation",
                "bodyACelestialTimeDegrees",
                "civicTimeOffsetSeconds",
            }
            require(reader.fieldnames is not None and required.issubset(reader.fieldnames), f"relationship schema changed: {path.name}")

            for line_number, row in enumerate(reader, start=2):
                rows += 1
                celestial_key = (
                    row["bodyA"],
                    row["bodyB"],
                    int(row["ringDegrees"]),
                    row["orientation"],
                    microdegrees(row["bodyACelestialTimeDegrees"]),
                )
                civic_offset = int(row["civicTimeOffsetSeconds"])
                occurrence_key = (celestial_key, civic_offset)
                require(
                    occurrence_key not in seen_occurrences,
                    f"duplicate native relationship occurrence in {path.name} at CSV line {line_number}: {occurrence_key}",
                )
                seen_occurrences.add(occurrence_key)
                celestial_counts[celestial_key] += 1

    require(rows == EXPECTED_RELATIONSHIP_ROWS, f"relationship row total changed: {rows}")

    repeated = {key: count for key, count in celestial_counts.items() if count > 1}
    extra_occurrences = sum(count - 1 for count in repeated.values())
    require(
        len(repeated) == EXPECTED_NATIVE_RECURRENCE_GROUPS,
        f"native relationship recurrence group count changed: {len(repeated)}",
    )
    require(
        extra_occurrences == EXPECTED_NATIVE_RECURRENCE_EXTRA_OCCURRENCES,
        f"native relationship recurrence occurrence count changed: {extra_occurrences}",
    )
    require(all(count == 2 for count in repeated.values()), "unexpected higher-order relationship recurrence in P22")

    print(
        "PASS relationship native identity "
        f"rows={rows} duplicateOccurrences=0 recurrenceGroups={len(repeated)} extraOccurrences={extra_occurrences}"
    )


def main() -> None:
    paths = canonical_paths()
    total_rows = 0
    for path in paths:
        total_rows += audit_literal_rows(path)
    audit_relationship_storage_identity()
    print(
        "PASS P22 canonical duplicate gate "
        f"inputs={len(paths)} literalDuplicates=0 totalRowsScanned={total_rows}"
    )


if __name__ == "__main__":
    main()
