from pathlib import Path
import json,shutil,sys
folder=Path(sys.argv[1]);manifest=folder/'manifest.json';out=folder.parent
if manifest.exists():
 for case in json.loads(manifest.read_text()):
  for a in case.get('attachments',[]):
   name=a.get('suggestedHumanReadableName','');src=folder/a.get('exportedFileName','')
   if not src.is_file():continue
   for language in ['en','de','es','it','pt-BR','el']:
    for kind in ['Board','Training']:
     if name.startswith(kind+'-'+language+'_'):
      target=kind.lower()+(''if language=='en'else'-'+language)+'.png';shutil.copy2(src,out/target)
