from pathlib import Path
import json
R=Path(__file__).resolve().parents[1];langs=['en','de','es','it','pt-BR','el'];strings={}
for row in (R/'Tools/translations.txt').read_text().splitlines():
 a=row.split('|');assert len(a)==6,(len(a),a[0]);strings[a[0]]={'localizations':{l:{'stringUnit':{'state':'translated','value':v}}for l,v in zip(langs,a)},'extractionState':'manual'}
keys=set(json.loads((R/'Tools/keys.json').read_text()));assert not keys-strings.keys(),keys-strings.keys()
(R/'CoachBoard/Localizable.xcstrings').write_text(json.dumps({'sourceLanguage':'en','strings':strings,'version':'1.0'},ensure_ascii=False,indent=2))
(R/'CoachBoard/InfoPlist.xcstrings').write_text(json.dumps({'sourceLanguage':'en','strings':{'CFBundleDisplayName':strings['Soach Board']},'version':'1.0'},ensure_ascii=False,indent=2))
print(len(strings),'strings,',len(langs),'languages; all keys covered')
