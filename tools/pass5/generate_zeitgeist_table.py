#!/usr/bin/env python3
import argparse
import csv
import ctypes
import json
import math
from pathlib import Path

SECONDS_PER_DAY = 86400.0
GREG_CAL = 1
PLUTO = 9
SEFLG_SWIEPH = 2
SEFLG_SPEED = 256
STEP_DAYS = 2.0
CLUSTER_GAP_DAYS = 20 * 365.25

P22_START_JD = 2386637.079399706
P22_END_JD = 2475819.1417904524


def norm(x):
    x %= 360.0
    return x + 360.0 if x < 0 else x


def shortest(a, b):
    d = norm(b) - norm(a)
    if d > 180:
        d -= 360
    elif d < -180:
        d += 360
    return d


class Swiss:
    def __init__(self, library, ephe_dir):
        self.lib = ctypes.CDLL(library)
        self.lib.swe_set_ephe_path.argtypes = [ctypes.c_char_p]
        self.lib.swe_set_ephe_path(ephe_dir.encode())
        self.lib.swe_calc_ut.argtypes = [ctypes.c_double, ctypes.c_int, ctypes.c_int,
                                         ctypes.POINTER(ctypes.c_double), ctypes.c_char_p]
        self.lib.swe_calc_ut.restype = ctypes.c_int
        self.lib.swe_julday.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_int,
                                        ctypes.c_double, ctypes.c_int]
        self.lib.swe_julday.restype = ctypes.c_double
        self.lib.swe_revjul.argtypes = [ctypes.c_double, ctypes.c_int,
                                        ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int),
                                        ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_double)]
        self.lib.swe_version.argtypes = [ctypes.c_char_p]
        self.lib.swe_version.restype = ctypes.c_char_p
        buf = ctypes.create_string_buffer(128)
        self.lib.swe_version(buf)
        self.version = buf.value.decode()

    def jd(self, year, month=1, day=1, hour=0.0):
        return self.lib.swe_julday(year, month, day, hour, GREG_CAL)

    def state(self, jd):
        xx = (ctypes.c_double * 6)()
        serr = ctypes.create_string_buffer(256)
        flags = self.lib.swe_calc_ut(jd, PLUTO, SEFLG_SWIEPH | SEFLG_SPEED, xx, serr)
        if flags < 0 or not (flags & SEFLG_SWIEPH):
            raise RuntimeError(f"Swiss failure at JD {jd}: {serr.value.decode(errors='replace')}")
        return norm(xx[0]), xx[3]

    def utc(self, jd):
        y = ctypes.c_int(); m = ctypes.c_int(); d = ctypes.c_int(); h = ctypes.c_double()
        self.lib.swe_revjul(jd, GREG_CAL, ctypes.byref(y), ctypes.byref(m), ctypes.byref(d), ctypes.byref(h))
        total_ms = int(round(h.value * 3600000.0))
        if total_ms >= 86400000:
            return self.utc(jd + 0.5 / SECONDS_PER_DAY)
        hh, total_ms = divmod(total_ms, 3600000)
        mm, total_ms = divmod(total_ms, 60000)
        ss, ms = divmod(total_ms, 1000)
        year = f"{y.value:04d}" if y.value >= 0 else f"-{abs(y.value):04d}"
        return f"{year}-{m.value:02d}-{d.value:02d}T{hh:02d}:{mm:02d}:{ss:02d}.{ms:03d}Z"


def bisect_root(fn, lo, hi, tol_seconds=0.001):
    flo = fn(lo)
    fhi = fn(hi)
    if flo == 0:
        return lo
    if fhi == 0:
        return hi
    if flo * fhi > 0:
        raise RuntimeError(f"Root not bracketed: {flo}, {fhi}")
    for _ in range(80):
        mid = (lo + hi) / 2.0
        fm = fn(mid)
        if fm == 0 or (hi - lo) * SECONDS_PER_DAY <= tol_seconds:
            return mid
        if flo * fm <= 0:
            hi = mid
            fhi = fm
        else:
            lo = mid
            flo = fm
    return (lo + hi) / 2.0


def refine_zero(swiss, lo_jd, hi_jd, lo_lon, target_unwrapped):
    def f(jd):
        lon, _ = swiss.state(jd)
        return lo_lon + shortest(lo_lon, lon) - target_unwrapped
    return bisect_root(f, lo_jd, hi_jd)


def refine_station(swiss, lo_jd, hi_jd):
    return bisect_root(lambda jd: swiss.state(jd)[1], lo_jd, hi_jd)


def scan(swiss, start_jd, end_jd):
    crossings = []
    stations = []
    lo_jd = start_jd
    lo_lon, lo_speed = swiss.state(lo_jd)

    while lo_jd < end_jd:
        hi_jd = min(lo_jd + STEP_DAYS, end_jd)
        hi_lon, hi_speed = swiss.state(hi_jd)

        # Split at a station so a local reversal cannot hide a 0-Aries crossing.
        segments = []
        if lo_speed * hi_speed < 0:
            st_jd = refine_station(swiss, lo_jd, hi_jd)
            st_lon, st_speed = swiss.state(st_jd)
            stations.append({
                "jd": st_jd,
                "longitude": st_lon,
                "before": "direct" if lo_speed > 0 else "retrograde",
                "after": "direct" if hi_speed > 0 else "retrograde",
            })
            segments.append((lo_jd, st_jd, lo_lon, st_lon, lo_speed))
            segments.append((st_jd, hi_jd, st_lon, hi_lon, hi_speed))
        else:
            segments.append((lo_jd, hi_jd, lo_lon, hi_lon, lo_speed))

        for a_jd, b_jd, a_lon, b_lon, motion_speed in segments:
            delta = shortest(a_lon, b_lon)
            b_unwrapped = a_lon + delta
            if delta > 0:
                first = math.floor(a_lon / 360.0) + 1
                last = math.floor(b_unwrapped / 360.0)
                multiples = range(first, last + 1)
            elif delta < 0:
                first = math.ceil(a_lon / 360.0) - 1
                last = math.ceil(b_unwrapped / 360.0)
                multiples = range(first, last - 1, -1)
            else:
                multiples = []

            for k in multiples:
                target = k * 360.0
                jd = refine_zero(swiss, a_jd, b_jd, a_lon, target)
                motion = "direct" if motion_speed >= 0 else "retrograde"
                if not crossings or abs(crossings[-1]["jd"] - jd) * SECONDS_PER_DAY > 0.1:
                    crossings.append({"jd": jd, "motion": motion})

        lo_jd, lo_lon, lo_speed = hi_jd, hi_lon, hi_speed

    return crossings, stations


def clusters(crossings):
    out = []
    for c in crossings:
        if out and c["jd"] - out[-1][-1]["jd"] <= CLUSTER_GAP_DAYS:
            out[-1].append(c)
        else:
            out.append([c])
    return [x for x in out if x[0]["motion"] == "direct" and x[-1]["motion"] == "direct"]


def prior_direct_crossing(swiss, target_degree, before_jd):
    lo_jd = before_jd - 10 * 365.25
    lo_lon, lo_speed = swiss.state(lo_jd)
    lo_delta = shortest(target_degree, lo_lon)
    while lo_jd < before_jd:
        hi_jd = min(lo_jd + 1.0, before_jd)
        hi_lon, hi_speed = swiss.state(hi_jd)
        hi_delta = shortest(target_degree, hi_lon)
        if lo_speed > 0 and hi_speed > 0 and lo_delta <= 0 <= hi_delta:
            return bisect_root(lambda jd: shortest(target_degree, swiss.state(jd)[0]), lo_jd, hi_jd)
        lo_jd, lo_lon, lo_speed, lo_delta = hi_jd, hi_lon, hi_speed, hi_delta
    return None


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--library", required=True)
    p.add_argument("--ephe-dir", required=True)
    p.add_argument("--json", required=True)
    p.add_argument("--csv", required=True)
    args = p.parse_args()

    swiss = Swiss(args.library, args.ephe_dir)
    if swiss.version != "2.10.03":
        raise RuntimeError(f"Expected Swiss 2.10.03, got {swiss.version}")

    crossings, stations = scan(swiss, swiss.jd(-3600), swiss.jd(4300))
    transition_clusters = clusters(crossings)

    # Z0 is the established Pluto generation whose first Aries ingress is near 3532 BCE.
    z0_index = None
    for i, cl in enumerate(transition_clusters):
        year = int(swiss.utc(cl[0]["jd"]).split("-")[1]) * -1 if swiss.utc(cl[0]["jd"]).startswith("-") else int(swiss.utc(cl[0]["jd"])[:4])
        utc = swiss.utc(cl[0]["jd"])
        if utc.startswith("-3531-") or utc.startswith("-3532-") or utc.startswith("-3530-"):
            z0_index = i
            break
    if z0_index is None:
        raise RuntimeError("Could not locate Z0 near 3532 BCE")
    if len(transition_clusters) < z0_index + 32:
        raise RuntimeError("Not enough transitions for Z0-Z30 plus Z31 boundary")

    rows = []
    for ordinal in range(31):
        cl = transition_clusters[z0_index + ordinal]
        next_cl = transition_clusters[z0_index + ordinal + 1]
        first = next(c for c in cl if c["motion"] == "direct")
        final = next(c for c in reversed(cl) if c["motion"] == "direct")
        next_first = next(c for c in next_cl if c["motion"] == "direct")

        retro_returns = [c for c in cl if c["jd"] > first["jd"] and c["motion"] == "retrograde"]
        pre_jd = None
        floor_degree = None
        if retro_returns:
            return_cross = retro_returns[0]
            direct_station = next((s for s in stations
                                   if return_cross["jd"] < s["jd"] < final["jd"]
                                   and s["before"] == "retrograde" and s["after"] == "direct"), None)
            if direct_station is None:
                raise RuntimeError(f"Missing direct station inside Z{ordinal} transition")
            floor_degree = direct_station["longitude"]
            pre_jd = prior_direct_crossing(swiss, floor_degree, first["jd"])
            if pre_jd is None:
                raise RuntimeError(f"Missing pre-shadow start for Z{ordinal}")

        rows.append({
            "zeitgeist_id": f"Z{ordinal}",
            "ordinal": ordinal,
            "pre_shadow_start_jd_ut": pre_jd,
            "pre_shadow_start_utc": swiss.utc(pre_jd) if pre_jd is not None else None,
            "pre_shadow_floor_degree": floor_degree,
            "first_aries_ingress_jd_ut": first["jd"],
            "first_aries_ingress_utc": swiss.utc(first["jd"]),
            "final_pisces_egress_jd_ut": final["jd"],
            "final_pisces_egress_utc": swiss.utc(final["jd"]),
            "next_zeitgeist_first_aries_ingress_jd_ut": next_first["jd"],
            "next_zeitgeist_first_aries_ingress_utc": swiss.utc(next_first["jd"]),
            "transition_crossings": [
                {"jd_ut": c["jd"], "utc": swiss.utc(c["jd"]), "motion": c["motion"]}
                for c in cl
            ],
        })

    if len(rows) != 31:
        raise RuntimeError("Expected 31 rows")

    # Existing P22 boundaries are our modern audit anchors.
    z22 = rows[22]
    z23 = rows[23]
    if abs(z22["first_aries_ingress_jd_ut"] - P22_START_JD) * SECONDS_PER_DAY > 2.0:
        raise RuntimeError(f"Z22 does not match canonical 1822 P22 start: {z22['first_aries_ingress_utc']}")
    if abs(z23["first_aries_ingress_jd_ut"] - P22_END_JD) * SECONDS_PER_DAY > 2.0:
        raise RuntimeError(f"Z23 does not match canonical 2066 P22 end: {z23['first_aries_ingress_utc']}")

    for r in rows:
        if r["pre_shadow_start_jd_ut"] is not None and not (r["pre_shadow_start_jd_ut"] < r["first_aries_ingress_jd_ut"]):
            raise RuntimeError(f"Invalid pre-shadow ordering in {r['zeitgeist_id']}")
        if r["final_pisces_egress_jd_ut"] < r["first_aries_ingress_jd_ut"]:
            raise RuntimeError(f"Invalid shadow ordering in {r['zeitgeist_id']}")
        if r["next_zeitgeist_first_aries_ingress_jd_ut"] <= r["first_aries_ingress_jd_ut"]:
            raise RuntimeError(f"Invalid owner ordering in {r['zeitgeist_id']}")

    artifact = {
        "artifact_family": "Orbo Pluto Zeitgeist Z0-Z30 canonical boundary table",
        "astronomical_source": "Swiss Ephemeris DE441",
        "astronomical_source_version": swiss.version,
        "swiss_fork": "huntarfischer/swisseph",
        "swiss_commit": "3fd0f956d73898b91cc4f67cf18b21af656d1342",
        "calendar": "proleptic Gregorian UTC",
        "year_numbering": "astronomical year numbering; year 0 = 1 BCE",
        "ownership_law": "A Zeitgeist begins and takes ownership at Pluto's first direct ingress into Aries. Ownership transfers at the next Zeitgeist's first direct Aries ingress.",
        "shadow_law": "If Pluto returns to Pisces after a new Zeitgeist begins, the previous Zeitgeist remains as Shadow until Pluto's final direct egress from Pisces into Aries.",
        "pre_shadow_law": "Pre-shadow begins at Pluto's earlier direct crossing of the degree of the later direct station in Pisces to which Pluto falls back after the first Aries ingress.",
        "numbering_anchor": "Z0 = Pluto first-Aries-ingress generation near 3532 BCE; sequence audited forward against canonical Z22 1822 and Z23 2066 anchors.",
        "rows": rows,
    }

    json_path = Path(args.json)
    csv_path = Path(args.csv)
    json_path.parent.mkdir(parents=True, exist_ok=True)
    json_path.write_text(json.dumps(artifact, indent=2, sort_keys=True) + "\n")

    fieldnames = [
        "zeitgeist_id", "ordinal", "pre_shadow_start_jd_ut", "pre_shadow_start_utc",
        "pre_shadow_floor_degree", "first_aries_ingress_jd_ut", "first_aries_ingress_utc",
        "final_pisces_egress_jd_ut", "final_pisces_egress_utc",
        "next_zeitgeist_first_aries_ingress_jd_ut", "next_zeitgeist_first_aries_ingress_utc",
        "transition_crossing_count",
    ]
    with csv_path.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        for r in rows:
            flat = {k: r.get(k) for k in fieldnames if k != "transition_crossing_count"}
            flat["transition_crossing_count"] = len(r["transition_crossings"])
            w.writerow(flat)

    print("ZEITGEIST TABLE Z0-Z30")
    print(f"source=huntarfischer/swisseph@3fd0f956d73898b91cc4f67cf18b21af656d1342 / Swiss {swiss.version} / DE441")
    print(f"rows={len(rows)}")
    print(f"Z0 firstAriesIngress={rows[0]['first_aries_ingress_utc']}")
    print(f"Z22 firstAriesIngress={z22['first_aries_ingress_utc']} deltaFromOldP22StartSeconds={(z22['first_aries_ingress_jd_ut']-P22_START_JD)*SECONDS_PER_DAY:.3f}")
    print(f"Z23 firstAriesIngress={z23['first_aries_ingress_utc']} deltaFromOldP22EndSeconds={(z23['first_aries_ingress_jd_ut']-P22_END_JD)*SECONDS_PER_DAY:.3f}")
    print(f"Z23 finalPiscesEgress={z23['final_pisces_egress_utc']}")
    print(f"json={json_path}")
    print(f"csv={csv_path}")


if __name__ == "__main__":
    main()
