#!/usr/bin/env python3
"""Merge P22 duplicate-cleanup proof results into the existing verification status."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
STATUS_PATH = ROOT / "tools/pass5/p22-verification-status.json"
RECURRENCE_LAW = "exact celestial geometry + recurrence ordinal / civic UT excluded"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--substrate-result", required=True)
    parser.add_argument("--native-result", required=True)
    parser.add_argument("--source-commit", required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    status = json.loads(STATUS_PATH.read_text(encoding="utf-8"))
    success = args.substrate_result == "success" and args.native_result == "success"

    status.update(
        {
            "sourceCommit": args.source_commit,
            "repositorySubstrate": args.substrate_result,
            "nativeProof": args.native_result,
            "status": "success" if success else "failure",
            "canonicalDuplicateAudit": (
                "17 canonical inputs / literal duplicates 0 / relationship native duplicate occurrences 0 / success"
                if args.substrate_result == "success"
                else "failed"
            ),
            "relationshipRecurrenceIdentity": (
                f"{RECURRENCE_LAW} / native proof success"
                if args.native_result == "success"
                else f"{RECURRENCE_LAW} / native proof {args.native_result}"
            ),
        }
    )

    if args.native_result == "success":
        status["certificationCheckpointing"] = "built / native proof success"
        status["checkpointValidation"] = "exact scope-count shape + divergence parity / native proof success"
        status["preservedCandidateRestart"] = "built / native proof success"
        status["smallEventSecondStrikeLookup"] = "station + eclipse direct celestial identity / native proof success"
        status["lastNativeRun"] = (
            "accumulated OrboCore tests + OrboCore build + OrboLab build successful; "
            "corrected P22 candidate manufacture and exhaustive Dioscuri certification still pending"
        )
    else:
        status["lastNativeRun"] = f"cleanup native proof {args.native_result}; inspect workflow job before candidate manufacture"

    STATUS_PATH.write_text(json.dumps(status, indent=2, sort_keys=True) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
