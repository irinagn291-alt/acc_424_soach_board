from pathlib import Path
import json,re,plistlib,subprocess
R=Path(__file__).resolve().parents[1];checks={}
sources=list((R/'CoachBoard').glob('*.swift'));checks['swift_files_including_ui_tests']=len(sources);assert len(sources)==6
pbx=(R/'ChalkOrbit.xcodeproj/project.pbxproj').read_text();ids=set(re.findall(r'^([A-F0-9]{24}) = \{',pbx,re.M));assert len(ids)==66
checks['fresh_project_object_ids']=len(ids)
root=R.parents[3]
r=subprocess.run(['rg','--files','--no-ignore','output/concepts15nov','-g','project.pbxproj','-g','!**/Artifacts/**'],cwd=root,text=True,capture_output=True)
collisions=[]
for f in r.stdout.splitlines():
 p=root/f
 if p==R/'ChalkOrbit.xcodeproj/project.pbxproj':continue
 text=p.read_text(errors='replace');other=set(re.findall(r'\b[A-F0-9]{24}\b',text))
 if ids&other:collisions.append(f)
 assert 'com.coachboard.app-c977830d8707'not in text,f
assert not collisions;checks['other_project_uuid_collisions']=collisions;checks['project_files_inspected']=len(r.stdout.splitlines())
for p in sources+[R/'ChalkOrbit.xcodeproj/project.pbxproj']+list((R/'CoachBoard').glob('*.plist'))+list((R/'CoachBoard').glob('*.entitlements')):
 t=p.read_text();assert str(Path.home())not in t and Path.home().name not in t,p
 assert not re.search(r'\b(ContentView|MyApp|ViewModel|Manager)\b',t),p
checks['source_machine_paths']=False
local=json.loads((R/'CoachBoard/Localizable.xcstrings').read_text());langs={'en','de','es','it','pt-BR','el'}
for k,v in local['strings'].items():assert set(v['localizations'])==langs,k
checks['fully_localized_keys']=len(local['strings']);checks['languages']=sorted(langs)
text='\n'.join(p.read_text()for p in sources if p.name!='BoardJourney.swift')
keys=set()
for match in re.finditer(r'zTxt\(',text):
 i=match.end();depth=1;quoted=False;escaped=False;start=i
 while i<len(text) and depth:
  c=text[i]
  if quoted:
   if escaped:escaped=False
   elif c=='\\':escaped=True
   elif c=='"':quoted=False
  elif c=='"':quoted=True
  elif c=='(':depth+=1
  elif c==')':depth-=1
  i+=1
 keys.update(re.findall(r'"([^"\\]*(?:\\.[^"\\]*)*)"',text[start:i-1]))
keys.update(re.findall(r'brand\("([^"]+)"\)',text))
keys.update(re.findall(r'\("[a-z]+","[^"]+","([^"]+)"\)',text))
for name in ['titles','descriptions']:
 m=re.search(r'static let '+name+r' = \[([^\]]+)\]',text)
 if m:keys.update(re.findall(r'"([^"]+)"',m[1]))
keys.update(['Football','Futsal','Basketball','Untitled tactic'])
internal={'home','away','ball','cone','move','arrow','run','zone','arrow.left','arrow.right','arrow.up','arrow.down'}
missing=keys-set(local['strings'])-internal
assert not missing,sorted(missing)
checks['literal_and_conditional_localization_keys_verified']=len(keys-internal)

app=plistlib.loads((R/'CoachBoard/BoardInfo.plist').read_bytes());ext=plistlib.loads((R/'CoachBoard/GlanceInfo.plist').read_bytes());a=plistlib.loads((R/'CoachBoard/BoardRights.entitlements').read_bytes());w=plistlib.loads((R/'CoachBoard/GlanceRights.entitlements').read_bytes())
assert a['com.apple.security.application-groups']==w['com.apple.security.application-groups']==['group.com.coachboard.app-c977830d8707']
assert a['com.apple.developer.icloud-container-identifiers']==['iCloud.com.coachboard.app-c977830d8707']
assert app['UIBackgroundModes']==['remote-notification'];assert app['NSSupportsLiveActivities']==False
assert ext['NSExtension']['NSExtensionPointIdentifier']=='com.apple.widgetkit-extension'
assert not any('UsageDescription'in k for k in app)
checks['capabilities_and_extension']=True
for family in ['systemSmall','systemMedium','systemLarge','accessoryInline','accessoryCircular','accessoryRectangular']:assert '.'+family in (R/'CoachBoard/BoardGlance.swift').read_text()
checks['widget_families']=6
arc=R/'Artifacts/CoachBoard-Final.xcarchive';assert arc.exists();bad=[]
for p in arc.rglob('*'):
 if p.is_file() and (str(Path.home()).encode()in (d:=p.read_bytes()) or Path.home().name.encode()in d):bad.append(str(p.relative_to(R)))
assert not bad,bad;checks['release_archive_machine_paths']=False
for p in (arc/'Products/Applications/ChalkOrbit.app').glob('*.lproj'):assert p.name.removesuffix('.lproj')in langs
checks['passed']=True
(R/'QA/source-audit.json').write_text(json.dumps(checks,ensure_ascii=False,indent=2));print(json.dumps(checks,ensure_ascii=False,indent=2))
