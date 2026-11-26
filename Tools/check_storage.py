from pathlib import Path
import subprocess,os
R=Path(__file__).resolve().parents[1]
test=r'''
@MainActor func z9()throws {
 func check(_ b:Bool,_ s:String){if !b{fatalError(s)}}
 let root=URL(fileURLWithPath:CommandLine.arguments[1]);let fm=FileManager.default
 if fm.fileExists(atPath:root.path){try fm.removeItem(at:root)}
 let p=ZbPocket(root,false)
 check(p.issue==nil,"Initial atomic save")
 p.change{$0.name="Archive A";$0.titleKey=nil}
 p.change{$0.name="Archive B"}
 let r=ZbPocket(root,false);check(r.current.title=="Archive B","Cold reload preserves tactic")
 p.change{$0.name="Archive C"}
 p.undo();check(p.current.title=="Archive B","Undo restores full tactic")
 p.redo();check(p.current.title=="Archive C","Redo restores full tactic")
 let before=try Data(contentsOf:root.appendingPathComponent("playbook.json.backup"));let expected=try JSONDecoder().decode(ZbBook.self,from:before)
 check(expected.plays.first{$0.id==expected.chosen}?.title=="Archive B","Backup is the previous distinct version")
 try Data("broken-json".utf8).write(to:root.appendingPathComponent("playbook.json"))
 let recovered=ZbPocket(root,false)
 check(recovered.book.plays==expected.plays,"Recovery loads previous valid archive")
 check(recovered.issue != nil,"Recovery is disclosed")
 var bad=recovered.current;bad.steps.append(bad.steps[0]);check(!recovered.valid(bad),"Duplicate frame identities rejected")
 bad=recovered.current;bad.steps[0].marks[0].x=10;check(!recovered.valid(bad),"Off-pitch coordinates rejected")
 bad=recovered.current;bad.steps[0].marks[0].kind="unknown";check(!recovered.valid(bad),"Unknown shapes rejected")
 bad=recovered.current;bad.steps[0].marks.append(bad.steps[0].marks[0]);check(!recovered.valid(bad),"Duplicate marker identities rejected")
 let invalid=root.appendingPathComponent("invalid.json");try Data("not-json".utf8).write(to:invalid)
 let unchanged=recovered.book.plays.count;recovered.importFile(invalid);check(recovered.book.plays.count==unchanged,"Malformed import preserves library")
 let oversized=root.appendingPathComponent("oversized.json");try Data(repeating:32,count:2_000_001).write(to:oversized);recovered.importFile(oversized);check(recovered.book.plays.count==unchanged,"Oversized import preserves library")
 let exported=root.appendingPathComponent("portable.json");var portable=recovered.current;portable.teamOwner="fixture-owner";portable.teamRecord="fixture-record";portable.teamZone="fixture-zone";try JSONEncoder().encode(portable).write(to:exported)
 let count=recovered.book.plays.count;let previousID=recovered.current.id;recovered.importFile(exported)
 check(recovered.book.plays.count==count+1 && recovered.current.id != previousID,"Import creates independent tactic")
 check(recovered.current.teamOwner==nil && recovered.current.teamRecord==nil && recovered.current.teamZone==nil,"Portable import carries no cloud ownership")
 recovered.book.sessions=[ZbSession(title:"Local plan",drills:[UUID()])]
 recovered.book.plays=[];recovered.frame=99;recovered.f9()
 check(recovered.book.plays.count==1 && recovered.book.chosen==recovered.current.id,"Revoked final tactic leaves a valid editable board")
 check(recovered.frame==0 && recovered.book.sessions[0].drills.isEmpty,"Cursor and stale training references are repaired")
 recovered.save();check(recovered.issue != zTxt("Could not save. Keep the app open and free some device storage."),"Final save succeeds")
 let result:[String:Any]=["passed":true,"checks":["Atomic save and cold reload","Full tactic undo and redo","Corruption recovery from actual backup file","Invalid geometry, shape kinds and duplicate identities rejected","Malformed and oversized imports preserve the library", "Portable JSON import creates an independent local tactic and clears foreign ownership","Revoked tactics repair the selection, frame and training references"],"scope":"Actual shared archive code on host, isolated QA storage, widget services disabled; iOS file protection and device UI are outside this host check"]
 FileHandle.standardOutput.write(try JSONSerialization.data(withJSONObject:result,options:[.prettyPrinted,.sortedKeys]))
}
try await z9()
'''
env=dict(os.environ,DEVELOPER_DIR='/Applications/Xcode.app/Contents/Developer',CLANG_MODULE_CACHE_PATH=str(R/'Artifacts/ModuleCache'))
source=(R/'CoachBoard/ChalkKernel.swift').read_text()+'\n'+(R/'CoachBoard/PocketArchive.swift').read_text()+'\n'+test
r=subprocess.run(['swift','-module-cache-path',str(R/'Artifacts/ModuleCache'),'-',str(R/'QA/HostStorage')],input=source,text=True,capture_output=True,cwd=R,env=env)
(R/'QA/storage-results.json').write_text(r.stdout);(R/'QA/storage-check.log').write_text(r.stderr)
print(r.stdout or r.stderr[-6000:]);raise SystemExit(r.returncode)
