#!/usr/bin/env python3
import argparse,csv,ctypes,gzip,json,math
from pathlib import Path
BODIES={"Sun":0,"Moon":1,"Mercury":2,"Venus":3,"Mars":4,"Jupiter":5,"Saturn":6,"Uranus":7,"Neptune":8,"Pluto":9,"NorthNode":11}
RES=[1.0,0.5,0.2,0.1,0.05,0.02,0.01]
CANDIDATES={"Mercury":["Pluto","Moon"],"Venus":["Pluto","Mercury"]}
class S:
 def __init__(self,lib,ep):
  self.l=ctypes.CDLL(lib);self.l.swe_set_ephe_path.argtypes=[ctypes.c_char_p];self.l.swe_set_ephe_path(ep.encode());self.l.swe_calc_ut.argtypes=[ctypes.c_double,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.c_char_p];self.l.swe_calc_ut.restype=ctypes.c_int32
 def lon(self,b,j):
  x=(ctypes.c_double*6)();e=ctypes.create_string_buffer(256);r=self.l.swe_calc_ut(j,b,258,x,e)
  if r<0 or not(r&2) or r&4:raise RuntimeError(e.value.decode())
  return x[0]%360
def bits(r):return math.ceil(math.log2(round(360/r)))
def cells(xs,r):
 n=round(360/r);return [int(math.floor((x+1e-12)/r))%n for x in xs]
def is_unique(focal,a,b):
 s=set()
 for x,y,z in zip(focal,a,b):
  k=(x,y,z)
  if k in s:return False
  s.add(k)
 return True
def rows(path):
 with gzip.open(path,'rt',newline='') as f:return [(int(r['focalCelestialTick']),float(r['utJulianDay'])) for r in csv.DictReader(f)]
def main():
 a=argparse.ArgumentParser();a.add_argument('--library',required=True);a.add_argument('--ephe-dir',required=True);a.add_argument('--p22-dir',required=True);a.add_argument('--output',required=True);q=a.parse_args();sw=S(q.library,q.ephe_dir);root=Path(q.p22_dir);out={"question":"Can Mercury or Venus replace three whole-degree markers with Sun plus one finer companion from their already-selected structure?","bodies":[]}
 combos=sorted([(bits(sr)+bits(mr),sr,mr) for sr in RES for mr in RES],key=lambda x:(x[0],x[1]+x[2]))
 for focal in ['Mercury','Venus']:
  rr=rows(root/'body-tables'/f'{focal}.csv.gz');ft=[x for x,_ in rr];jds=[j for _,j in rr];sunlon=[sw.lon(BODIES['Sun'],j) for j in jds];sun_cells={r:cells(sunlon,r) for r in RES};item={"body":focal,"records":len(rr),"currentMarkerBits":27,"candidateCompanions":CANDIDATES[focal],"bestPair":None,"tested":[]}
  for m in CANDIDATES[focal]:
   mlon=[sw.lon(BODIES[m],j) for j in jds];mcells={r:cells(mlon,r) for r in RES};winner=None
   for cost,sr,mr in combos:
    if cost>=27:continue
    if is_unique(ft,sun_cells[sr],mcells[mr]):
     winner={"markers":["Sun",m],"sunResolution":sr,"companionResolution":mr,"markerBits":cost};break
   item['tested'].append({"companion":m,"best":winner})
   if winner and (item['bestPair'] is None or winner['markerBits']<item['bestPair']['markerBits']):item['bestPair']=winner
  out['bodies'].append(item);print(focal,json.dumps(item['bestPair']))
 Path(q.output).write_text(json.dumps(out,indent=2)+'\n')
if __name__=='__main__':main()
