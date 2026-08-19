#!/usr/bin/env python3
import argparse, csv, ctypes, hashlib, json
from pathlib import Path

SECONDS_PER_DAY=86400.0
SEFLG_SWIEPH=2
SEFLG_MOSEPH=4
SEFLG_SPEED=256
START=2297171.740867775
END=2386637.0793997087
SHADOW_TABLE_START=2297171.740867775
SHADOW_BUFFER_DAYS=2200.0
SHADOW_SCAN_START=SHADOW_TABLE_START-SHADOW_BUFFER_DAYS
SHADOW_SCAN_END=END+SHADOW_BUFFER_DAYS
BODIES=[
    ("Mercury",2,2.0),("Venus",3,3.0),("Mars",4,5.0),("Jupiter",5,8.0),
    ("Saturn",6,8.0),("Uranus",7,10.0),("Neptune",8,10.0),("Pluto",9,10.0),
    ("NorthNode",11,0.1),
]


def norm(x):
    x%=360.0
    return x+360.0 if x<0 else x

class Swiss:
    def __init__(self,library,ephe_dir):
        self.lib=ctypes.CDLL(library)
        self.lib.swe_set_ephe_path.argtypes=[ctypes.c_char_p]
        self.lib.swe_calc_ut.argtypes=[ctypes.c_double,ctypes.c_int,ctypes.c_int,ctypes.POINTER(ctypes.c_double),ctypes.c_char_p]
        self.lib.swe_calc_ut.restype=ctypes.c_int
        self.lib.swe_version.argtypes=[ctypes.c_char_p]
        self.lib.swe_version.restype=ctypes.c_char_p
        self.lib.swe_set_ephe_path(str(ephe_dir).encode())
        buf=ctypes.create_string_buffer(128); self.lib.swe_version(buf); self.version=buf.value.decode()
    def state(self,jd,body):
        xx=(ctypes.c_double*6)(); serr=ctypes.create_string_buffer(256)
        flags=self.lib.swe_calc_ut(jd,body,SEFLG_SWIEPH|SEFLG_SPEED,xx,serr)
        if flags<0 or not(flags&SEFLG_SWIEPH) or (flags&SEFLG_MOSEPH):
            raise RuntimeError(f"Swiss failure body={body} jd={jd}: {serr.value.decode(errors='replace')}")
        return norm(xx[0]),xx[3]

def refine_station(sw,body,lo,hi):
    flo=sw.state(lo,body)[1]
    for _ in range(60):
        mid=(lo+hi)/2; fm=sw.state(mid,body)[1]
        if abs(fm)<1e-13: return mid
        if flo*fm<=0: hi=mid
        else: lo=mid; flo=fm
        if (hi-lo)*SECONDS_PER_DAY<0.001: break
    return (lo+hi)/2

def find_stations(sw,name,body,step,scan_start,scan_end):
    out=[]; lo=scan_start; _,slo=sw.state(lo,body)
    while lo<scan_end:
        hi=min(scan_end,lo+step); _,shi=sw.state(hi,body)
        if slo==0 or shi==0 or slo*shi<0:
            jd=refine_station(sw,body,lo,hi); slon,_=sw.state(jd,body)
            before=1 if slo>=0 else -1; after=1 if shi>=0 else -1
            if not out or abs(out[-1]['jd']-jd)*SECONDS_PER_DAY>1:
                out.append({'body':name,'jd':jd,'lon':slon,'before':before,'after':after})
        lo=hi; slo=shi
    return out

def seq(d): return 'increasing' if d>=0 else 'decreasing'

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--library',required=True); ap.add_argument('--ephe-dir',required=True); ap.add_argument('--output-dir',required=True); ap.add_argument('--shadow-csv',required=True)
    a=ap.parse_args(); sw=Swiss(a.library,a.ephe_dir)
    if sw.version!='2.10.03': raise SystemExit(f'Unexpected Swiss version {sw.version}')
    out=Path(a.output_dir); out.mkdir(parents=True,exist_ok=True)
    stations=[]; passages=[]; per_body={}
    for name,body,step in BODIES:
        if name=='NorthNode':
            raw=find_stations(sw,name,body,step,START,END)
        else:
            raw=find_stations(sw,name,body,step,SHADOW_SCAN_START,SHADOW_SCAN_END)
        sts=[x for x in raw if START <= x['jd'] < END]
        per_body[name]={'stations':len(sts)}; stations.extend(sts)
        bounds=[START]+[x['jd'] for x in sts]+[END]
        retro=0
        for i in range(len(bounds)-1):
            s,e=bounds[i],bounds[i+1]
            if e-s<=1e-12: continue
            _,speed=sw.state((s+e)/2,body)
            if speed<0:
                slon,_=sw.state(s,body); elon,_=sw.state(e,body)
                passages.append({'body':name,'start':s,'end':e,'startLon':slon,'endLon':elon})
                retro+=1
        per_body[name]['retrogradePassages']=retro
        print(f'{name}: stations={len(sts)} retrogradePassages={retro}',flush=True)
    stations.sort(key=lambda x:(x['jd'],x['body']))
    passages.sort(key=lambda x:(x['start'],x['body']))

    sp=out/'station-table.csv'
    with sp.open('w',newline='') as f:
        w=csv.writer(f); w.writerow(['body','celestialTimeDegrees','utOffsetSeconds','utJulianDay','sequenceBefore','sequenceAfter','userFacingStation'])
        for r in stations:
            w.writerow([r['body'],f"{r['lon']:.9f}",int(round((r['jd']-START)*SECONDS_PER_DAY)),f"{r['jd']:.12f}",seq(r['before']),seq(r['after']),'station_retrograde' if r['after']<0 else 'station_direct'])
    rp=out/'retrograde-passages.csv'
    with rp.open('w',newline='') as f:
        w=csv.writer(f); w.writerow(['body','startCelestialTimeDegrees','endCelestialTimeDegrees','startOffsetSeconds','endOffsetSeconds','startJulianDay','endJulianDay','userFacingMotion'])
        for r in passages:
            w.writerow([r['body'],f"{r['startLon']:.9f}",f"{r['endLon']:.9f}",int(round((r['start']-START)*SECONDS_PER_DAY)),int(round((r['end']-START)*SECONDS_PER_DAY)),f"{r['start']:.12f}",f"{r['end']:.12f}",'retrograde'])

    with open(a.shadow_csv,newline='') as f:
        shadows=list(csv.DictReader(f))
    idx={n:[] for n,_,_ in BODIES if n!='NorthNode'}
    for s in shadows:
        b=s['body']
        if b in idx: idx[b].append((float(s['retrogradeStationJulianDayUT']),float(s['directStationJulianDayUT'])))
    compared=0; maxerr=0.0
    for r in passages:
        b=r['body']
        if b not in idx: continue
        if abs(r['start']-START)<1e-8 or abs(r['end']-END)<1e-8: continue
        best=min(idx[b],key=lambda x:abs(x[0]-r['start'])+abs(x[1]-r['end']))
        err=max(abs(best[0]-r['start']),abs(best[1]-r['end']))*SECONDS_PER_DAY
        maxerr=max(maxerr,err)
        if err>0.001: raise AssertionError((b,r['start'],r['end'],best,err))
        compared+=1
    if compared==0: raise AssertionError('No shadow comparisons made')

    manifest={
      'zeitgeist':'Z21','artifactFamily':'Orbo motion tables',
      'ownershipLaw':'Z21 first Pluto Aries ingress inclusive to Z22 first Pluto Aries ingress exclusive',
      'startJulianDayUT':START,'startUTC':'1577-05-05T05:46:50.976Z','endJulianDayUT':END,'endUTC':'1822-04-16T13:54:20.135Z',
      'astronomicalSource':'Swiss Ephemeris DE441; geocentric tropical apparent ecliptic longitude and signed speed; UT',
      'swissVersion':sw.version,'swissRepository':'huntarfischer/swisseph','swissCommit':'3fd0f956d73898b91cc4f67cf18b21af656d1342',
      'stationRows':len(stations),'retrogradePassageRows':len(passages),'perBody':per_body,
      'shadowCrossCheckBodies':[x for x in idx],'shadowCrossCheckCompletePassages':compared,'shadowCrossCheckMaxErrorSeconds':maxerr,
      'shadowCrossCheckLaw':'Mercury through Pluto complete retrograde passages reproduce the frozen planetary-shadow retrograde-station to direct-station intervals by using the same buffered Z21-Z24 station scan grid; boundary-clipped passages excluded; 0.001 second maximum accepted difference',
      'trueNodePolicy':'True Node motion is manufactured independently from signed Swiss longitudinal speed using 0.1-day bracketing; it is not cross-checked against planetary-shadow data because True Node was intentionally excluded from that table.',
      'files':[]
    }
    for p in (sp,rp):
        data=p.read_bytes(); manifest['files'].append({'path':p.name,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()})
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')
    print('PASS Z21 focused motion manufacture')
    print(json.dumps({'stations':len(stations),'retrogradePassages':len(passages),'shadowCompared':compared,'maxErrorSeconds':maxerr},sort_keys=True))

if __name__=='__main__': main()
