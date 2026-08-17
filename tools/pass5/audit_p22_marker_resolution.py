#!/usr/bin/env python3
import argparse, csv, ctypes, gzip, json, math
from pathlib import Path

BODIES = {"Sun":0,"Moon":1,"Mercury":2,"Venus":3,"Mars":4,"Jupiter":5,"Saturn":6,"Uranus":7,"Neptune":8,"Pluto":9,"NorthNode":11}
MARKER_RESOLUTIONS = [1.0,0.5,0.2,0.1,0.05,0.02,0.01]

class Swiss:
    def __init__(self, lib, ephe):
        self.l = ctypes.CDLL(lib)
        self.l.swe_set_ephe_path.argtypes=[ctypes.c_char_p]
        self.l.swe_set_ephe_path(ephe.encode())
        self.l.swe_calc_ut.argtypes=[ctypes.c_double,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.c_char_p]
        self.l.swe_calc_ut.restype=ctypes.c_int32
    def lon(self, body, jd):
        x=(ctypes.c_double*6)(); err=ctypes.create_string_buffer(256)
        r=self.l.swe_calc_ut(jd, body, 258, x, err)
        if r < 0 or not (r & 2) or (r & 4):
            raise RuntimeError(err.value.decode())
        return x[0] % 360.0

def bits_for_resolution(res):
    return math.ceil(math.log2(round(360.0/res)))

def cell(lon,res):
    return int(math.floor((lon+1e-12)/res)) % round(360.0/res)

def collisions(keys):
    d={}
    for k in keys:d[k]=d.get(k,0)+1
    reps=[n for n in d.values() if n>1]
    return len(reps),sum(reps)

def load_rows(path):
    rows=[]
    with gzip.open(path,"rt",newline="") as f:
        for r in csv.DictReader(f):
            rows.append((int(r["focalCelestialTick"]),float(r["utJulianDay"])))
    return rows

def audit_marker(sw, rows, marker_body):
    lons=[sw.lon(marker_body,jd) for _,jd in rows]
    out=[]
    for res in MARKER_RESOLUTIONS:
        keys=[(rows[i][0],cell(lons[i],res)) for i in range(len(rows))]
        rk,rr=collisions(keys)
        out.append({"resolutionDegrees":res,"markerBits":bits_for_resolution(res),"repeatedKeys":rk,"repeatedRows":rr,"unique":rk==0})
    return out

def main():
    ap=argparse.ArgumentParser();ap.add_argument("--library",required=True);ap.add_argument("--ephe-dir",required=True);ap.add_argument("--p22-dir",required=True);ap.add_argument("--output",required=True);a=ap.parse_args()
    sw=Swiss(a.library,a.ephe_dir); root=Path(a.p22_dir); summary=json.loads((root/"summary.json").read_text()); current={x["body"]:x for x in summary["bodyTables"]}
    result={"span":summary["spanName"],"question":"Can higher-resolution Sun celestial time replace extra whole-degree companion bodies?","bodies":[]}
    for path in sorted((root/"body-tables").glob("*.csv.gz")):
        body=path.name.removesuffix(".csv.gz"); rows=load_rows(path); cur=current[body]; current_marker_count=cur["selectedResolutionMarkerAudit"]["markerCount"]
        item={"body":body,"focalResolutionDegrees":cur["selectedResolutionDegrees"],"records":len(rows),"currentMarkers":cur["selectedResolutionMarkerAudit"]["selectedMarkers"],"currentMarkerBitsAssumingWholeDegree":9*current_marker_count}
        if body != "Sun":
            tests=audit_marker(sw,rows,BODIES["Sun"])
            item["singleSunMarkerTests"]=tests
            winners=[x for x in tests if x["unique"]]
            item["minimumUniqueSunMarker"]=winners[0] if winners else None
        else:
            candidates=[]
            for name in ["Pluto","Neptune","Uranus","Saturn","Jupiter"]:
                tests=audit_marker(sw,rows,BODIES[name]); wins=[x for x in tests if x["unique"]]
                candidates.append({"marker":name,"tests":tests,"minimumUnique":wins[0] if wins else None})
            item["singleMarkerCandidates"]=candidates
            winners=[(c["minimumUnique"]["markerBits"],MARKER_RESOLUTIONS.index(c["minimumUnique"]["resolutionDegrees"]),c["marker"],c["minimumUnique"]) for c in candidates if c["minimumUnique"]]
            winners.sort()
            item["bestSingleMarker"]={"marker":winners[0][2],**winners[0][3]} if winners else None
        result["bodies"].append(item)
        print(body, json.dumps(item))
    Path(a.output).write_text(json.dumps(result,indent=2)+"\n")

if __name__=="__main__":main()
