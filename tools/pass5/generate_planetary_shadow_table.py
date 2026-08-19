#!/usr/bin/env python3
import argparse, csv, ctypes, json, math
from pathlib import Path

SECONDS_PER_DAY = 86400.0
GREG_CAL = 1
SEFLG_SWIEPH = 2
SEFLG_MOSEPH = 4
SEFLG_SPEED = 256
BODIES = [("Mercury",2),("Venus",3),("Mars",4),("Jupiter",5),("Saturn",6),("Uranus",7),("Neptune",8),("Pluto",9)]
TARGET_START_JD = 2297171.740867775   # Z21 first Pluto Aries ingress
TARGET_END_JD = 2565295.0945935287   # Z24 first Pluto Aries ingress; half-open
BUFFER_DAYS = 2200.0


def norm(x):
    x %= 360.0
    return x + 360.0 if x < 0 else x


def delta(a, b):
    d = norm(b) - norm(a)
    if d > 180: d -= 360
    if d < -180: d += 360
    return d

class Swiss:
    def __init__(self, library, ephe_dir):
        self.lib = ctypes.CDLL(library)
        self.lib.swe_set_ephe_path.argtypes = [ctypes.c_char_p]
        self.lib.swe_calc_ut.argtypes = [ctypes.c_double, ctypes.c_int, ctypes.c_int, ctypes.POINTER(ctypes.c_double), ctypes.c_char_p]
        self.lib.swe_calc_ut.restype = ctypes.c_int
        self.lib.swe_revjul.argtypes = [ctypes.c_double, ctypes.c_int, ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_double)]
        self.lib.swe_version.argtypes = [ctypes.c_char_p]
        self.lib.swe_version.restype = ctypes.c_char_p
        self.lib.swe_set_ephe_path(str(ephe_dir).encode())
        buf = ctypes.create_string_buffer(128)
        self.lib.swe_version(buf)
        self.version = buf.value.decode()

    def state(self, jd, body):
        xx = (ctypes.c_double * 6)()
        serr = ctypes.create_string_buffer(256)
        flags = self.lib.swe_calc_ut(jd, body, SEFLG_SWIEPH | SEFLG_SPEED, xx, serr)
        if flags < 0 or not (flags & SEFLG_SWIEPH) or (flags & SEFLG_MOSEPH):
            raise RuntimeError(f"Swiss failure body={body} jd={jd}: {serr.value.decode(errors='replace')}")
        return norm(xx[0]), xx[3]

    def utc(self, jd):
        y=ctypes.c_int(); m=ctypes.c_int(); d=ctypes.c_int(); h=ctypes.c_double()
        self.lib.swe_revjul(jd, GREG_CAL, ctypes.byref(y), ctypes.byref(m), ctypes.byref(d), ctypes.byref(h))
        ms = int(round(h.value * 3600000))
        hh, ms = divmod(ms, 3600000); mm, ms = divmod(ms, 60000); ss, ms = divmod(ms, 1000)
        year = f"{y.value:04d}" if y.value >= 0 else f"-{abs(y.value):04d}"
        return f"{year}-{m.value:02d}-{d.value:02d}T{hh:02d}:{mm:02d}:{ss:02d}.{ms:03d}Z"


def refine_station(sw, body, lo, hi):
    flo = sw.state(lo, body)[1]
    for _ in range(60):
        mid = (lo + hi) / 2
        fm = sw.state(mid, body)[1]
        if abs(fm) < 1e-13: return mid
        if flo * fm <= 0:
            hi = mid
        else:
            lo = mid; flo = fm
        if (hi-lo)*SECONDS_PER_DAY < 0.001: break
    return (lo+hi)/2


def refine_degree_crossing(sw, body, target, lo, hi):
    flo = delta(target, sw.state(lo, body)[0])
    for _ in range(60):
        mid=(lo+hi)/2
        fm=delta(target, sw.state(mid, body)[0])
        if abs(fm) < 1e-12: return mid
        if flo * fm <= 0:
            hi=mid
        else:
            lo=mid; flo=fm
        if (hi-lo)*SECONDS_PER_DAY < 0.001: break
    return (lo+hi)/2


def stations(sw, body, start, end):
    out=[]
    step=1.0
    lo=start; _, slo=sw.state(lo, body)
    while lo < end:
        hi=min(end, lo+step); _, shi=sw.state(hi, body)
        if slo == 0 or shi == 0 or slo*shi < 0:
            jd=refine_station(sw, body, lo, hi)
            lon, _=sw.state(jd, body)
            before = 1 if slo >= 0 else -1
            after = 1 if shi >= 0 else -1
            if not out or abs(out[-1][0]-jd)*SECONDS_PER_DAY > 1:
                out.append((jd, lon, before, after))
        lo=hi; slo=shi
    return out


def prior_direct_crossing(sw, body, target, before_jd):
    start=before_jd-BUFFER_DAYS; step=1.0
    lo=start; lon,speed=sw.state(lo, body); f=delta(target,lon)
    found=None
    while lo < before_jd:
        hi=min(before_jd,lo+step); lon2,speed2=sw.state(hi,body); f2=delta(target,lon2)
        if speed>0 and speed2>0 and f <= 0 <= f2 and abs(f-f2) < 30:
            found=refine_degree_crossing(sw,body,target,lo,hi)
        lo=hi; lon,speed,f=lon2,speed2,f2
    return found


def next_direct_crossing(sw, body, target, after_jd):
    end=after_jd+BUFFER_DAYS; step=1.0
    lo=after_jd; lon,speed=sw.state(lo,body); f=delta(target,lon)
    while lo < end:
        hi=min(end,lo+step); lon2,speed2=sw.state(hi,body); f2=delta(target,lon2)
        if speed>0 and speed2>0 and f <= 0 <= f2 and abs(f-f2) < 30:
            return refine_degree_crossing(sw,body,target,lo,hi)
        lo=hi; lon,speed,f=lon2,speed2,f2
    return None


def make_rows(sw):
    rows=[]
    scan_start=TARGET_START_JD-BUFFER_DAYS
    scan_end=TARGET_END_JD+BUFFER_DAYS
    for name,body in BODIES:
        sts=stations(sw,body,scan_start,scan_end)
        ordinal=0
        i=0
        while i < len(sts)-1:
            r=sts[i]
            if r[2] == 1 and r[3] == -1:
                j=i+1
                while j < len(sts) and not (sts[j][2] == -1 and sts[j][3] == 1): j+=1
                if j>=len(sts): break
                d=sts[j]
                pre=prior_direct_crossing(sw,body,d[1],r[0])
                post=next_direct_crossing(sw,body,r[1],d[0])
                if pre is None or post is None:
                    raise RuntimeError(f"Could not close shadow topology for {name} retrograde station {sw.utc(r[0])}")
                if pre < TARGET_END_JD and post >= TARGET_START_JD:
                    rows.append({
                        "body":name,"bodyId":body,"ordinal":ordinal,
                        "preShadowStartDegree":d[1],"preShadowStartJulianDayUT":pre,"preShadowStartUTC":sw.utc(pre),
                        "retrogradeStationDegree":r[1],"retrogradeStationJulianDayUT":r[0],"retrogradeStationUTC":sw.utc(r[0]),
                        "directStationDegree":d[1],"directStationJulianDayUT":d[0],"directStationUTC":sw.utc(d[0]),
                        "postShadowEndDegree":r[1],"postShadowEndJulianDayUT":post,"postShadowEndUTC":sw.utc(post),
                    })
                    ordinal+=1
                i=j
            i+=1
    rows.sort(key=lambda x:(x["preShadowStartJulianDayUT"],x["bodyId"]))
    return rows


def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--library',required=True); ap.add_argument('--ephe-dir',required=True); ap.add_argument('--json',required=True); ap.add_argument('--csv',required=True)
    a=ap.parse_args(); sw=Swiss(a.library,a.ephe_dir)
    if sw.version != "2.10.03": raise SystemExit(f"Unexpected Swiss version {sw.version}")
    rows=make_rows(sw)
    counts={name:sum(1 for r in rows if r['body']==name) for name,_ in BODIES}
    artifact={
      "artifactFamily":"Orbo planetary retrograde shadow table Z21-Z23",
      "astronomicalSource":"Swiss Ephemeris DE441","astronomicalSourceVersion":sw.version,
      "span":{"startJulianDayUT":TARGET_START_JD,"startUTC":"1577-05-05T05:46:50.976Z","endJulianDayUT":TARGET_END_JD,"endUTC":"2311-06-10T14:16:12.881Z","law":"include every complete retrograde-shadow episode whose [pre-shadow start, post-shadow end] intersects the half-open Z21-Z24 ownership span"},
      "shadowLaw":"pre-shadow begins at the first direct crossing of the later direct-station degree; retrograde begins at the retrograde station; direct motion resumes at the direct station; post-shadow ends at the next direct crossing of the earlier retrograde-station degree",
      "bodies":[x[0] for x in BODIES],"trueNodePolicy":"excluded pending separate motion-topology decision","rows":rows}
    Path(a.json).parent.mkdir(parents=True,exist_ok=True)
    Path(a.json).write_text(json.dumps(artifact,indent=2,sort_keys=True)+"\n")
    fields=["body","bodyId","ordinal","preShadowStartDegree","preShadowStartJulianDayUT","preShadowStartUTC","retrogradeStationDegree","retrogradeStationJulianDayUT","retrogradeStationUTC","directStationDegree","directStationJulianDayUT","directStationUTC","postShadowEndDegree","postShadowEndJulianDayUT","postShadowEndUTC"]
    with open(a.csv,'w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=fields); w.writeheader(); w.writerows(rows)
    print(f"rows={len(rows)}")
    for name,_ in BODIES: print(f"{name}={counts[name]}")
    print(f"first={rows[0]['preShadowStartUTC']} {rows[0]['body']}")
    print(f"last={rows[-1]['postShadowEndUTC']} {rows[-1]['body']}")

if __name__=='__main__': main()
