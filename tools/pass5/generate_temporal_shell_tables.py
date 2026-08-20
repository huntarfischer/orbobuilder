#!/usr/bin/env python3
"""Manufacture Orbo's numbered Neptune/Uranus/Saturn temporal-shell tables.

Numbering law:
  Z0 = canonical Pluto first direct Aries ingress (3532 BCE)
  W0 = first qualifying Neptune Aries ingress strictly after Z0
  R0 = first qualifying Uranus Aries ingress strictly after Z0
  F0 = first qualifying Saturn Aries ingress strictly after Z0

Each family is a global independent counter. A qualifying boundary is the first direct
Pisces->Aries crossing in that body's Aries-transition cluster; later retrograde
recrossings belong to the same numbered shell.

Canonical manufacture requires official Swiss-file mode and aborts on Moshier fallback.
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

Z0_JD = 431167.610188324
Z0_UTC = "-3532-05-24T02:38:40.271Z"
Z_BOUNDS = {
    "Z21": (2297171.740867775, 2386637.0793997087),
    "Z22": (2386637.0793997087, 2475819.1417904533),
    "Z23": (2475819.1417904533, 2565295.0945935287),
}
Z_UTC = {
    "Z21": ("1577-05-05T05:46:50.976Z", "1822-04-16T13:54:20.135Z"),
    "Z22": ("1822-04-16T13:54:20.135Z", "2066-06-17T15:24:10.695Z"),
    "Z23": ("2066-06-17T15:24:10.695Z", "2311-06-10T14:16:12.881Z"),
}

FAMILIES = {
    "W": {"body": 8, "planet": "Neptune", "family": "Neptunian Wave", "step": 30.0, "cluster_gap": 40 * 365.25},
    "R": {"body": 7, "planet": "Uranus", "family": "Uranian Revolt", "step": 20.0, "cluster_gap": 20 * 365.25},
    "F": {"body": 6, "planet": "Saturn", "family": "Saturnian Frame", "step": 10.0, "cluster_gap": 10 * 365.25},
}

REQUIRED_EPHE_FILES = (
    "seplm36.se1", "seplm30.se1", "seplm24.se1", "seplm18.se1", "seplm12.se1", "seplm06.se1",
    "sepl_00.se1", "sepl_06.se1", "sepl_12.se1", "sepl_18.se1", "sepl_24.se1",
)


class SwissC:
    def __init__(self, library: Path, ephe_dir: Path):
        self.lib = ctypes.CDLL(str(library.resolve()))
        self.lib.swe_set_ephe_path.argtypes = [ctypes.c_char_p]
        self.lib.swe_set_ephe_path.restype = None
        self.lib.swe_calc_ut.argtypes = [ctypes.c_double, ctypes.c_int32, ctypes.c_int32, ctypes.POINTER(ctypes.c_double), ctypes.c_char_p]
        self.lib.swe_calc_ut.restype = ctypes.c_int32
        self.lib.swe_version.argtypes = [ctypes.c_char_p]
        self.lib.swe_version.restype = ctypes.c_char_p
        self.lib.swe_revjul.argtypes = [ctypes.c_double, ctypes.c_int32, ctypes.POINTER(ctypes.c_int32), ctypes.POINTER(ctypes.c_int32), ctypes.POINTER(ctypes.c_int32), ctypes.POINTER(ctypes.c_double)]
        self.lib.swe_revjul.restype = None
        self.lib.swe_close.argtypes = []
        self.lib.swe_close.restype = None
        buf = ctypes.create_string_buffer(256)
        self.lib.swe_version(buf)
        self.version = buf.value.decode("ascii", errors="replace")
        if self.version != EXPECTED_SWE_VERSION:
            raise RuntimeError(f"Swiss C version drift: {self.version} != {EXPECTED_SWE_VERSION}")
        self.lib.swe_set_ephe_path(str(ephe_dir.resolve()).encode())

    def state(self, jd: float, body: int) -> tuple[float, float]:
        xx = (ctypes.c_double * 6)()
        serr = ctypes.create_string_buffer(256)
        returned = int(self.lib.swe_calc_ut(jd, body, FLAGS, xx, serr))
        if returned < 0:
            raise RuntimeError(f"swe_calc_ut failed at JD {jd}: {serr.value.decode(errors='replace')}")
        if not (returned & SEFLG_SWIEPH) or (returned & SEFLG_MOSEPH):
            raise RuntimeError(f"Swiss-file mode required at JD {jd}, body {body}: flags={returned}")
        return float(xx[0]), float(xx[3])

    def utc(self, jd: float) -> str:
        y = ctypes.c_int32(); m = ctypes.c_int32(); d = ctypes.c_int32(); hour = ctypes.c_double()
        self.lib.swe_revjul(jd, 1, ctypes.byref(y), ctypes.byref(m), ctypes.byref(d), ctypes.byref(hour))
        total_ms = int(round(hour.value * 3600000.0))
        if total_ms >= 86400000:
            return self.utc(jd + 0.5 / 86400000.0)
        hh, rem = divmod(total_ms, 3600000)
        mm, rem = divmod(rem, 60000)
        ss, ms = divmod(rem, 1000)
        ys = f"-{abs(y.value):04d}" if y.value <= 0 else f"{y.value:04d}"
        return f"{ys}-{m.value:02d}-{d.value:02d}T{hh:02d}:{mm:02d}:{ss:02d}.{ms:03d}Z"

    def close(self):
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
            raise RuntimeError(f"Missing required fork ephemeris file: {name}")
        head = p.read_bytes()[:512]
        if b"DE441" not in head:
            raise RuntimeError(f"{name} is not a DE441-generation Swiss file")
        records.append({"name": name, "bytes": p.stat().st_size, "sha256": sha256(p)})
    return records


def signed_zero(lon: float) -> float:
    return ((lon + 180.0) % 360.0) - 180.0


def refine_crossing(swiss: SwissC, body: int, lo: float, hi: float, direct: bool) -> dict:
    for _ in range(64):
        mid = (lo + hi) / 2.0
        fm = signed_zero(swiss.state(mid, body)[0])
        if direct:
            if fm >= 0.0: hi = mid
            else: lo = mid
        else:
            if fm <= 0.0: hi = mid
            else: lo = mid
    jd = (lo + hi) / 2.0
    lon, speed = swiss.state(jd, body)
    return {"jd_ut": jd, "motion": "direct" if speed > 0 else "retrograde", "utc": swiss.utc(jd)}


def all_zero_crossings(swiss: SwissC, body: int, start: float, end: float, step: float) -> list[dict]:
    out = []
    t0 = start
    lon0, _ = swiss.state(t0, body)
    while t0 < end:
        t1 = min(end, t0 + step)
        lon1, _ = swiss.state(t1, body)
        if lon0 > 300.0 and lon1 < 60.0:
            c = refine_crossing(swiss, body, t0, t1, True)
            if c["motion"] == "direct": out.append(c)
        elif lon0 < 60.0 and lon1 > 300.0:
            c = refine_crossing(swiss, body, t0, t1, False)
            if c["motion"] == "retrograde": out.append(c)
        t0, lon0 = t1, lon1
    return out


def cluster_crossings(crossings: list[dict], gap: float) -> list[list[dict]]:
    clusters = []
    for c in crossings:
        if not clusters or c["jd_ut"] - clusters[-1][-1]["jd_ut"] > gap:
            clusters.append([c])
        else:
            clusters[-1].append(c)
    return clusters


def refine_station(swiss: SwissC, body: int, lo: float, hi: float) -> float:
    _, slo = swiss.state(lo, body)
    for _ in range(64):
        mid = (lo + hi) / 2.0
        _, smid = swiss.state(mid, body)
        if (slo < 0) == (smid < 0):
            lo, slo = mid, smid
        else:
            hi = mid
    return (lo + hi) / 2.0


def transition_shadow(swiss: SwissC, body: int, first: float, final: float) -> tuple[float | None, str | None, float | None]:
    """Replicate the Pluto-table transition shadow where a return to Pisces occurs.

    The floor is the deepest Pisces longitude reached at the direct station after a
    retrograde 0-Aries recrossing. Pre-shadow start is the earlier direct passage over
    that same longitude before first ingress. Returns nulls when the transition never
    returns to Pisces.
    """
    if final <= first + 1e-7:
        return None, None, None

    # Find retrograde->direct stations between first and final and choose deepest Pisces floor.
    candidates = []
    step = 2.0
    t0 = first
    _, s0 = swiss.state(t0 + 1e-5, body)
    while t0 < final:
        t1 = min(final, t0 + step)
        _, s1 = swiss.state(t1, body)
        if s0 < 0 <= s1:
            st = refine_station(swiss, body, t0, t1)
            lon, _ = swiss.state(st, body)
            if lon > 180.0:
                candidates.append((signed_zero(lon), lon, st))
        t0, s0 = t1, s1
    if not candidates:
        return None, None, None
    _, floor_lon, _ = min(candidates, key=lambda x: x[0])
    target = signed_zero(floor_lon)

    # Find the earlier direct passage over the floor before first Aries ingress.
    hi = first
    fhi = signed_zero(swiss.state(hi - 1e-6, body)[0]) - target
    lo = hi - 2.0
    max_back = 8 * 365.25
    travelled = 2.0
    while travelled <= max_back:
        flo = signed_zero(swiss.state(lo, body)[0]) - target
        if flo <= 0.0 <= fhi:
            a, b = lo, hi
            for _ in range(64):
                mid = (a + b) / 2.0
                fm = signed_zero(swiss.state(mid, body)[0]) - target
                if fm >= 0.0: b = mid
                else: a = mid
            jd = (a + b) / 2.0
            _, speed = swiss.state(jd, body)
            if speed > 0:
                return jd, swiss.utc(jd), floor_lon
        hi, fhi = lo, flo
        lo -= 2.0
        travelled += 2.0
    raise RuntimeError("Could not solve pre-shadow start for transition floor")


def z_intersections(start: float, end: float) -> list[str]:
    return [z for z, (a, b) in Z_BOUNDS.items() if start < b and end > a]


def manufacture_family(swiss: SwissC, prefix: str, cfg: dict, scan_end: float) -> list[dict]:
    crossings = all_zero_crossings(swiss, cfg["body"], Z0_JD, scan_end, cfg["step"])
    clusters = cluster_crossings(crossings, cfg["cluster_gap"])
    qualifying = []
    for cluster in clusters:
        directs = [c for c in cluster if c["motion"] == "direct"]
        if not directs:
            continue
        first = directs[0]
        if first["jd_ut"] <= Z0_JD:
            continue
        final = directs[-1]
        transition = [c for c in cluster if first["jd_ut"] - 1e-7 <= c["jd_ut"] <= final["jd_ut"] + 1e-7]
        qualifying.append((first, final, transition))

    rows = []
    for ordinal in range(len(qualifying) - 1):
        first, final, transition = qualifying[ordinal]
        next_first = qualifying[ordinal + 1][0]
        # Keep every numbered shell through the one intersecting Z23; once start is beyond Z24, stop.
        if first["jd_ut"] >= Z_BOUNDS["Z23"][1]:
            break
        pre_jd, pre_utc, floor = transition_shadow(swiss, cfg["body"], first["jd_ut"], final["jd_ut"])
        rows.append({
            "shell_id": f"{prefix}{ordinal}",
            "ordinal": ordinal,
            "planet": cfg["planet"],
            "family": cfg["family"],
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
    if not rows or rows[0]["ordinal"] != 0:
        raise RuntimeError(f"{prefix}0 was not manufactured")
    return rows


def write_family(out_dir: Path, prefix: str, rows: list[dict], provenance: dict):
    stem = {"W":"neptunian-wave-table", "R":"uranian-revolt-table", "F":"saturnian-frame-table"}[prefix]
    doc = {
        "schema_version": "1.0.0",
        "numbering_epoch": {"zeitgeist_id": "Z0", "jd_ut": Z0_JD, "utc": Z0_UTC},
        "numbering_law": f"{prefix}0 is the first qualifying {rows[0]['planet']} direct Pisces-to-Aries ingress strictly after Z0; later 0-Aries recrossings remain in the same shell.",
        "ownership": "[first_aries_ingress, next_shell_first_aries_ingress)",
        "provenance": provenance,
        "rows": rows,
    }
    jp = out_dir / f"{stem}.json"
    jp.write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n")
    flat = []
    for r in rows:
        q = dict(r)
        q["transition_crossings"] = json.dumps(q["transition_crossings"], separators=(",", ":"))
        q["z21_z23_intersections"] = ";".join(q["z21_z23_intersections"])
        flat.append(q)
    with (out_dir / f"{stem}.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(flat[0].keys()))
        w.writeheader(); w.writerows(flat)


def audit(rows_by_prefix: dict[str, list[dict]]) -> dict:
    checks = {}
    for p, rows in rows_by_prefix.items():
        checks[p] = {
            "row_count": len(rows),
            "ordinals_contiguous": all(r["ordinal"] == i for i, r in enumerate(rows)),
            "starts_strictly_increasing": all(rows[i]["first_aries_ingress_jd_ut"] < rows[i+1]["first_aries_ingress_jd_ut"] for i in range(len(rows)-1)),
            "next_boundary_exact": all(abs(rows[i]["next_shell_first_aries_ingress_jd_ut"] - rows[i+1]["first_aries_ingress_jd_ut"]) < 1e-9 for i in range(len(rows)-1)),
            "transition_starts_direct": all(r["transition_crossings"][0]["motion"] == "direct" for r in rows),
            "transition_ends_direct": all(r["transition_crossings"][-1]["motion"] == "direct" for r in rows),
            "z21_rows": [r["shell_id"] for r in rows if "Z21" in r["z21_z23_intersections"]],
            "z22_rows": [r["shell_id"] for r in rows if "Z22" in r["z21_z23_intersections"]],
            "z23_rows": [r["shell_id"] for r in rows if "Z23" in r["z21_z23_intersections"]],
        }
    bools = [v for fam in checks.values() for k, v in fam.items() if isinstance(v, bool)]
    return {"status": "PASS" if all(bools) else "FAIL", "checks": checks}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--library", required=True, type=Path)
    ap.add_argument("--ephe-dir", required=True, type=Path)
    ap.add_argument("--out-dir", required=True, type=Path)
    ap.add_argument("--source-commit", required=True)
    args = ap.parse_args()

    files = verify_ephe(args.ephe_dir)
    swiss = SwissC(args.library, args.ephe_dir)
    # Need a full Neptune boundary after Z24 to close the last shell intersecting Z23.
    scan_end = Z_BOUNDS["Z23"][1] + 190 * 365.25
    rows_by_prefix = {}
    provenance = {
        "astronomical_engine": "official Swiss Ephemeris C",
        "swiss_version": swiss.version,
        "source_repository": "huntarfischer/swisseph",
        "source_commit": args.source_commit,
        "ephemeris_generation": "DE441",
        "flags": FLAGS,
        "coordinate_contract": {"center":"geocentric", "zodiac":"tropical", "frame":"ecliptic of date"},
        "ephemeris_files": files,
    }
    args.out_dir.mkdir(parents=True, exist_ok=True)
    for prefix, cfg in FAMILIES.items():
        print(f"Manufacturing {cfg['family']}...", flush=True)
        rows = manufacture_family(swiss, prefix, cfg, scan_end)
        rows_by_prefix[prefix] = rows
        write_family(args.out_dir, prefix, rows, provenance)
        print(f"  {len(rows)} numbered rows", flush=True)

    report = audit(rows_by_prefix)
    report["zeitgeist_boundaries"] = {z: {"start_jd_ut": Z_BOUNDS[z][0], "end_jd_ut": Z_BOUNDS[z][1], "start_utc": Z_UTC[z][0], "end_utc": Z_UTC[z][1]} for z in Z_BOUNDS}
    report["numbering_epoch"] = {"zeitgeist_id":"Z0", "jd_ut":Z0_JD, "utc":Z0_UTC}
    (args.out_dir / "temporal-shell-z21-z23-summary.json").write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    if report["status"] != "PASS":
        raise RuntimeError("Temporal shell audit failed")
    swiss.close()
    print(json.dumps(report, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
