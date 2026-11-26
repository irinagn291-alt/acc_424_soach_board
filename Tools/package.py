from pathlib import Path
import zipfile,hashlib,json
r=Path(__file__).resolve().parents[1]
files=[r/'README.md',r/'REPORT.md',r/'StoreMetadata.json',r/'.gitignore',r/'QA/run_device.sh',r/'QA/collect.py']
files.extend(p for name in ['input-manifest.json','source-audit.json','model-results.json','storage-results.json','symbol-check.json','widget-visual-review.json','visual-review.json','final-results.json'] if (p:=r/'QA'/name).is_file())
for root in ['CoachBoard','ChalkOrbit.xcodeproj','Tools']:
 files.extend(p for p in (r/root).rglob('*')if p.is_file() and 'xcuserdata'not in p.parts and '__pycache__'not in p.parts and p.name!='.DS_Store')
with zipfile.ZipFile(r/'Artifacts/CoachBoard-Source.zip','w',zipfile.ZIP_DEFLATED)as z:
 for p in files:z.write(p,p.relative_to(r).as_posix())
with zipfile.ZipFile(r/'Artifacts/CoachBoard-Device.zip','w',zipfile.ZIP_DEFLATED)as z:
 for p in (r/'Artifacts/CoachBoard-Final.xcarchive').rglob('*'):
  if p.is_file():z.write(p,p.relative_to(r/'Artifacts').as_posix())
checks={name:hashlib.sha256((r/'Artifacts'/name).read_bytes()).hexdigest()for name in ['CoachBoard-Source.zip','CoachBoard-Device.zip']}
(r/'Artifacts/SHA256.json').write_text(json.dumps(checks,indent=2));print(json.dumps(checks,indent=2))
