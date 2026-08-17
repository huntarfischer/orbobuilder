#!/usr/bin/env python3
import json
from pathlib import Path
p=Path(__file__).resolve().parent/"p22-results"
a=json.loads((p/"marker-resolution-audit.json").read_text())
out={"span":a["span"],"bodies":[]}
for b in a["bodies"]:
    item={"body":b["body"],"focalResolution":b["focalResolutionDegrees"],"records":b["records"],"currentMarkers":b["currentMarkers"],"currentMarkerBits":b["currentMarkerBitsAssumingWholeDegree"]}
    if b["body"]!="Sun":
        item["minimumUniqueSunMarker"]=b["minimumUniqueSunMarker"]
        item["sunAt001RepeatedKeys"]=b["singleSunMarkerTests"][-1]["repeatedKeys"]
    else:
        item["bestSingleMarker"]=b["bestSingleMarker"]
        item["candidateMinimums"]={x["marker"]:x["minimumUnique"] for x in b["singleMarkerCandidates"]}
    out["bodies"].append(item)
(p/"marker-resolution-audit-compact.json").write_text(json.dumps(out,indent=2)+"\n")
print(json.dumps(out,indent=2))
