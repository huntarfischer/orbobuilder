#!/usr/bin/env python3
"""Manufacture Orbo's numbered Mars Campaign table.

Numbering law:
  Z0 = canonical Pluto first direct Aries ingress (3532 BCE)
  C0 = first qualifying Mars direct Pisces->Aries ingress strictly after Z0

Each Campaign owns [first_aries_ingress, next_campaign_first_aries_ingress).
Later retrograde recrossings of 0 Aries belong to the same Campaign.

Deliverable: one CSV, shaped exactly like the existing temporal-shell tables.
Canonical manufacture requires Swiss Ephemeris 2.10.03 in DE441 Swiss-file mode
and aborts on Moshier fallback.
"""
from __future__ import annotations

import argparse
import csv
import ctypes
import hashlib
import json
from pathlib import Path

EXPECTED_SWE_VERSION = "2.10.03"
SEFLG_SWIEPH = 2
SEFLG_MOSEPH = 4
SEFLG_SPEED = 256
FLAGS = SEFLG_SWIEPH | SEFLG_SPEED
MARS = 4

Z0_JD = 431167.610188324
Z0_UTC = "-3532-05-24T02:38:40.271Z"
Z_BOUNDS = {
    "Z21": (2297171.740867775, 2386637.0793997087),
    "Z22": (2386637.0793997087, 2475819.1417904533),
    "Z23": (2475819.1417904533, 2565295.0945935287),
}

# Wide enough to bind the final Campaign that begins before the end of Z23.
SCAN_END = Z_BOUNDS["Z23"][1] + 4 * 365.25
SCAN_STEP_DAYS = 2.0
CLUSTER_GAP_DAYS = 365.25

REQUIRED_EPHE_FILES = (
    "seplm36.se1", "seplm30.se1", "seplm24.se1", "seplm18.se1", "seplm12.se1", "seplm06.se1",
    "sepl_00.se1", "sepl_06.se1", "sepl_12.se1", "sepl_18.se1", "sepl_24.se1",
)

FIELDNAMES = [
    "shell_id",
    "ordinal",
    "planet",
    "family",
    "pre_shadow_start_jd_ut",
    "pre_shadow_start_utc",
    "pre_shadow_floor_degree",
    "first_aries_ingress_jd_ut",
    "first_aries_ingress_utc",
    "final_pisces_egress_jd_ut",
    "final_pisces_egress_utc",
    "next_shell_first_aries_ingress_jd_ut",
    "next_shell_first_aries_ingress_utc",
    "transition_crossings",
    "transition_crossing_count",
    "z21_z23_intersections",
]


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
        self.lib.swe_revjul.argtypes = [
            ctypes.c_double,
            ctypes.c_int32,
            ctypes.POINTER(ctypes.c_int32),
            ctypes.POINTER(ctypes.c_int32),
            ctypes.POINTER(ctypes.c_int32),
            ctypes.POINTER(ctypes.c_double),
        ]
        self.lib.swe_revjul.restype = None
        self.lib.swe_close.argtypes = []
        self.lib.swe_close.restype = None

        buf = ctypes.create_string_buffer(256)
        self.lib.swe_version(buf)
        self.version = buf.value.decode("ascii", errors="replace")
        if self.version != EXPECTED_SWE_VERSION:
            raise RuntimeError(f"Swiss C version drift: {self.version} != {EXPECTED_SWE_VERSION}")
        self.lib.swe_set_ephe_path(str(ephe_dir.resolve()).encode())

    def state(self, jd: float) -> tuple[float, float]:
        xx = (ctypes.c_double * 6)()
        serr = ctypes.create_string_buffer(256)
        returned = int(self.lib.swe_calc_ut(jd, MARS, FLAGS, xx, serr))
        if returned < 0:
            raise RuntimeError(f"swe_calc_ut failed at JD {jd}: {serr.value.decode(errors='replace')}")
        if not (returned & SEFLG_SWIEPH) or (returned & SEFLG_MOSEPH):
            raise RuntimeError(f"Swiss-file mode required at JD {jd}: flags={returned}")
        return float(xx[0]), float(xx[3])

    def utc(self, jd: float) -> str:
        y = ctypes.c_int32()
        m = ctypes.c_int32()
        d = ctypes.c_int32()
        hour = ctypes.c_double()
        self.lib.swe_revjul(jd, 1, ctypes.byref(y), ctypes.byref(m), ctypes.byref(d), ctypes.byref(hour))
        total_ms = int(round(hour.value * 3600000.0))
        if total_ms >= 86400000:
            return self.utc(jd + 0.5 / 86400000.0)
        hh, rem = divmod(total_ms, 3600000)
        mm, rem = divmod(rem, 60000)
        ss, ms = divmod(rem, 1000)
        ys = f"-{abs(y.value):04d}" if y.value <= 0 else f"{y.value:04d}"
        return f"{ys}-{m.value:02d}-{d.value:02d}T{hh:02d}:{mm:02d}:{ss:02d}.{ms:03d}Z"

    def close(self) -> None:
        self.lib.swe_close()


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def verify_ephe(ephe_dir: Path) -> list[dict]:
    records = []
    for name in REQUIRED_EPHE_FILES:
        p = ephe_dir / name
        if not p.is_file():
            raise RuntimeError(f"Missing required ephemeris file: {name}")
        head = p.read_bytes()[:512]
        if b"DE441" not in head:
            raise RuntimeError(f"{name} is not a DE441-generation Swiss file")
        records.append({"name": name, "bytes": p.stat().st_size, "sha256": sha256(p)})
    return records


def signed_zero(lon: float) -> float:
    return ((lon + 180.0) % 360.0) - 180.0


def refine_crossing(swiss: SwissC, lo: float, hi: float, direct: bool) -> dict:
    for _ in range(64):
        mid = (lo + hi) / 2.0
        fm = signed_zero(swiss.state(mid)[0])
        if direct:
            if fm >= 0.0:
                hi = mid
            else:
                lo = mid
        else:
            if fm <= 0.0:
                hi = mid
            else:
                lo = mid
    jd = (lo + hi) / 2.0
    lon, speed = swiss.state(jd)
    residual = abs(signed_zero(lon))
    if residual > 1e-7:
        raise RuntimeError(f"0-Aries crossing residual too large at JD {jd}: {residual} deg")
    return {"jd_ut": jd, "motion": "direct" if speed > 0 else "retrograde", "utc": swiss.utc(jd)}


def all_zero_crossings(swiss: SwissC) -> list[dict]:
    out = []
    t0 = Z0_JD
    lon0, _ = swiss.state(t0)
    while t0 < SCAN_END:
        t1 = min(SCAN_END, t0 + SCAN_STEP_DAYS)
        lon1, _ = swiss.state(t1)
        if lon0 > 300.0 and lon1 < 60.0:
            c = refine_crossing(swiss, t0, t1, True)
            if c["motion"] == "direct":
                out.append(c)
        elif lon0 < 60.0 and lon1 > 300.0:
            c = refine_crossing(swiss, t0, t1, False)
            if c["motion"] == "retrograde":
                out.append(c)
        t0, lon0 = t1, lon1
    return out


def cluster_crossings(crossings: list[dict]) -> list[list[dict]]:
    clusters: list[list[dict]] = []
    for crossing in crossings:
        if not clusters or crossing["jd_ut"] - clusters[-1][-1]["jd_ut"] > CLUSTER_GAP_DAYS:
            clusters.append([crossing])
        else:
            clusters[-1].append(crossing)
    return clusters


def refine_station(swiss: SwissC, lo: float, hi: float) -> float:
    _, slo = swiss.state(lo)
    for _ in range(64):
        mid = (lo + hi) / 2.0
        _, smid = swiss.state(mid)
        if (slo < 0) == (smid < 0):
            lo, slo = mid, smid
        else:
            hi = mid
    return (lo + hi) / 2.0


def transition_shadow(swiss: SwissC, first: float, final: float) -> tuple[float | None, str | None, float | None]:
    """Mirror the existing shell-table transition-shadow treatment."""
    if final <= first + 1e-7:
        return None, None, None

    candidates = []
    step = 1.0
    t0 = first
    _, s0 = swiss.state(t0 + 1e-5)
    while t0 < final:
        t1 = min(final, t0 + step)
        _, s1 = swiss.state(t1)
        if s0 < 0 <= s1:
            st = refine_station(swiss, t0, t1)
            lon, _ = swiss.state(st)
            if lon > 180.0:
                candidates.append((signed_zero(lon), lon, st))
        t0, s0 = t1, s1

    if not candidates:
        return None, None, None

    _, floor_lon, _ = min(candidates, key=lambda x: x[0])
    target = signed_zero(floor_lon)
    hi = first
    fhi = signed_zero(swiss.state(hi - 1e-6)[0]) - target
    lo = hi - 1.0
    travelled = 1.0
    max_back = 2 * 365.25
    while travelled <= max_back:
        flo = signed_zero(swiss.state(lo)[0]) - target
        if flo <= 0.0 <= fhi:
            a, b = lo, hi
            for _ in range(64):
                mid = (a + b) / 2.0
                fm = signed_zero(swiss.state(mid)[0]) - target
                if fm >= 0.0:
                    b = mid
                else:
                    a = mid
            jd = (a + b) / 2.0
            _, speed = swiss.state(jd)
            if speed > 0:
                return jd, swiss.utc(jd), floor_lon
        hi, fhi = lo, flo
        lo -= 1.0
        travelled += 1.0
    raise RuntimeError("Could not solve Martian Campaign pre-shadow start")


def z_intersections(start: float, end: float) -> list[str]:
    return [z for z, (a, b) in Z_BOUNDS.items() if start < b and end > a]


def manufacture(swiss: SwissC) -> list[dict]:
    clusters = cluster_crossings(all_zero_crossings(swiss))
    qualifying = []
    for cluster in clusters:
        directs = [c for c in cluster if c["motion"] == "direct"]
        if not directs:
            continue
        first = directs[0]
        if first["jd_ut"] <= Z0_JD:
            continue
        final = directs[-1]
        transition = [
            c for c in cluster
            if first["jd_ut"] - 1e-7 <= c["jd_ut"] <= final["jd_ut"] + 1e-7
        ]
        qualifying.append((first, final, transition))

    rows = []
    for ordinal in range(len(qualifying) - 1):
        first, final, transition = qualifying[ordinal]
        next_first = qualifying[ordinal + 1][0]
        if first["jd_ut"] >= Z_BOUNDS["Z23"][1]:
            break
        pre_jd, pre_utc, floor = transition_shadow(swiss, first["jd_ut"], final["jd_ut"])
        rows.append({
            "shell_id": f"C{ordinal}",
            "ordinal": ordinal,
            "planet": "Mars",
            "family": "Martian Campaign",
            "pre_shadow_start_jd_ut": pre_jd,
            "pre_shadow_start_utc": pre_utc,
            "pre_shadow_floor_degree": floor,
            "first_aries_ingress_jd_ut": first["jd_ut"],
            "first_aries_ingress_utc": first["utc"],
            "final_pisces_egress_jd_ut": final["jd_ut"],
            "final_pisces_egress_utc": final["utc"],
            "next_shell_first_aries_ingress_jd_ut": next_first["jd_ut"],
            "next_shell_first_aries_ingress_utc": next_first["utc"],
            "transition_crossings": transition,
            "transition_crossing_count": len(transition),
            "z21_z23_intersections": z_intersections(first["jd_ut"], next_first["jd_ut"]),
        })

    if not rows or rows[0]["shell_id"] != "C0":
        raise RuntimeError("C0 was not manufactured")
    return rows


def audit(rows: list[dict]) -> dict:
    checks = {
        "row_count": len(rows),
        "c0_after_z0": rows[0]["first_aries_ingress_jd_ut"] > Z0_JD,
        "ordinals_contiguous": all(r["ordinal"] == i for i, r in enumerate(rows)),
        "starts_strictly_increasing": all(
            rows[i]["first_aries_ingress_jd_ut"] < rows[i + 1]["first_aries_ingress_jd_ut"]
            for i in range(len(rows) - 1)
        ),
        "next_boundary_exact": all(
            abs(rows[i]["next_shell_first_aries_ingress_jd_ut"] - rows[i + 1]["first_aries_ingress_jd_ut"]) < 1e-9
            for i in range(len(rows) - 1)
        ),
        "transition_starts_direct": all(r["transition_crossings"][0]["motion"] == "direct" for r in rows),
        "transition_ends_direct": all(r["transition_crossings"][-1]["motion"] == "direct" for r in rows),
        "z21_rows": [r["shell_id"] for r in rows if "Z21" in r["z21_z23_intersections"]],
        "z22_rows": [r["shell_id"] for r in rows if "Z22" in r["z21_z23_intersections"]],
        "z23_rows": [r["shell_id"] for r in rows if "Z23" in r["z21_z23_intersections"]],
    }
    bools = [value for value in checks.values() if isinstance(value, bool)]
    checks["status"] = "PASS" if all(bools) else "FAIL"
    return checks


def write_csv(path: Path, rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
        writer.writeheader()
        for row in rows:
            flat = dict(row)
            flat["transition_crossings"] = json.dumps(flat["transition_crossings"], separators=(",", ":"))
            flat["z21_z23_intersections"] = ";".join(flat["z21_z23_intersections"])
            writer.writerow(flat)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--library", required=True, type=Path)
    ap.add_argument("--ephe-dir", required=True, type=Path)
    ap.add_argument("--output", required=True, type=Path)
    ap.add_argument("--source-commit", required=True)
    args = ap.parse_args()

    ephe_files = verify_ephe(args.ephe_dir)
    swiss = SwissC(args.library, args.ephe_dir)
    try:
        rows = manufacture(swiss)
        report = audit(rows)
        if report["status"] != "PASS":
            raise RuntimeError(f"Martian Campaign audit failed: {report}")
        write_csv(args.output, rows)
        print(json.dumps({
            "status": "PASS",
            "artifact": str(args.output),
            "family": "Martian Campaign",
            "numbering_epoch": {"zeitgeist_id": "Z0", "jd_ut": Z0_JD, "utc": Z0_UTC},
            "ownership": "[first_aries_ingress, next_shell_first_aries_ingress)",
            "swiss_version": swiss.version,
            "source_commit": args.source_commit,
            "ephemeris_generation": "DE441",
            "ephemeris_files": ephe_files,
            "audit": report,
            "csv_bytes": args.output.stat().st_size,
            "csv_sha256": sha256(args.output),
        }, indent=2, sort_keys=True))
    finally:
        swiss.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
