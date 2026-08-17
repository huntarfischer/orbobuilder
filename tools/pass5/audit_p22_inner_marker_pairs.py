#!/usr/bin/env python3
import argparse,csv,ctypes,gzip,json,math
from pathlib import Path
BODIES={"Sun":0,"Moon":1,"Mercury":2,"Venus":3,"Mars":4,"Jupiter":5,"Saturn":6,"Uranus":7,"Neptune":8,"Pluto":9,"NorthNode":11}
RES=[1.0,0.5,0.2,0.1,0.05,0.02,0.01]
class S:
 def __init__(self,lib,ep):
  self.l=ctypes.CDLL(lib);self.l.swe_set_ephe_path.argtypes=[ctypes.c_char_p];self.l.swe_set_ephe_path(ep.encode());self.l.swe_calc_ut.argtypes=[ctypes.c_double,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.c_char_p];self.l.swe_calc_ut.restype=ctypes.c_int32
 def lon(self,b,j):
  x=(ctypes.c_double*6)();e=ctypes.create_string_buffer(256);r=self.l.swe_calc_ut(j,b,258,x,e)
  if r<0 or not(r&2) or r&4:raise RuntimeError(e.value.decode())
  return x[0]%360
def bits(r):return math.ceil(math.log2(round(360/r)))
def cell(x,r):return int(math.floor((x+1e-12)/r))%round(360/r)
def unique(keys):
 s=set()
 for k in keys:
  if k in s:return False
  s.add(k)
 return True
def rows(path):
 with gzip.open(path,'rt',newline='') as f:return [(int(r['focalCelestialTick']),float(r['utJulianDay'])) for r in csv.DictReader(f)]
def main():
 a=argparse.ArgumentParser();a.add_argument('--library',required=True);a.add_argument('--ephe-dir',required=True);a.add_argument('--p22-dir',required=True);a.add_argument('--output',required=True);q=a.parse_args();sw=S(q.library,q.ephe_dir);root=Path(q.p22_dir);out={"question":"Can Mercury or Venus replace three whole-degree markers with Sun plus one finer companion?","bodies":[]}
 for focal in ['Mercury','Venus']:
  rr=rows(root/'body-tables'/f'{focal}.csv.gz'); sun=[sw.lon(BODIES['Sun'],j) for _,j in rr]; candidates=[b for b in BODIES if b not in {focal,'Sun'}]; item={"body":focal,"records":len(rr),"currentMarkerBits":27,"pairs":[]}; best=None
  for m in candidates:
   ml=[sw.lon(BODIES[m],j) for _,j in rr]
   for sr in RES:
    sc=[cell(x,sr) for x in sun]
    for mr in RES:
     cost=bits(sr)+bits(mr)
     if best is not None and cost>best['markerBits']:continue
     if unique((rr[i][0],sc[i],cell(ml[i],mr)) for i in range(len(rr))):
      rec={"markers":["Sun",m],"sunResolution":sr,"companionResolution":mr,"markerBits":cost}
      item['pairs'].append(rec)
      if best is None or (cost,len(rec['markers']),sr+mr)<(best['markerBits'],len(best['markers']),best['sunResolution']+best['companionResolution']):best=rec
   # next marker
  item['bestPair']=best;out['bodies'].append(item);print(focal,json.dumps(best))
 Path(q.output).write_text(json.dumps(out,indent=2)+'\n')
if __name__=='__main__':main()
