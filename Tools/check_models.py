from pathlib import Path
import subprocess, os
R=Path(__file__).resolve().parents[1]
checks=r'''
func check(_ b:Bool,_ s:String){if !b{fatalError(s)}}
var passes:[String]=[]
for n in 0..<6 {
 let sport:ZbSport = n<3 ? .football : n==3 ? .futsal : .basketball
 let p=ZbSeeds.make(sport,n)
 check(p.steps.count==3,"Exercise has three frames")
 check(Set(p.steps.map(\.id)).count==3,"Frame identities are unique")
 check(p.steps[0].marks.map(\.id)==p.steps[1].marks.map(\.id),"Player identities survive animation")
 check(p.steps[0].marks != p.steps[1].marks,"Exercise has actual movement")
 for s in p.steps {check(s.marks.allSatisfy{(0...1).contains($0.x) && (0...1).contains($0.y)},"Markers stay on pitch")}
 let data=try JSONEncoder().encode(p);let restored=try JSONDecoder().decode(ZbPlay.self,from:data)
 check(p==restored,"Tactic file roundtrip is lossless")
}
passes.append("Six bundled exercises: unique frames, stable players, real movement, valid coordinates, lossless JSON")
let p=ZbSeeds.make(.football,0), a=p.steps[0], b=p.steps[1]
let mid=ZbStep.mix(a,b,0.5)
let ball=mid.marks.first{$0.kind=="ball"}!
check(abs(ball.x-0.5)<0.000001,"Ball passes through expected midpoint")
check(ZbStep.mix(a,b,0).marks==a.marks,"Animation starts exactly at source")
check(ZbStep.mix(a,b,1)==b,"Animation ends exactly at next frame")
passes.append("Animation: exact start, known midpoint and exact finish")
let now=Date(timeIntervalSince1970:1_800_000_000)
var book=ZbBook.fresh
book.sessions=[ZbSession(title:"Finished",date:now.addingTimeInterval(50),done:true),ZbSession(title:"Past",date:now.addingTimeInterval(-50)),ZbSession(title:"Later",date:now.addingTimeInterval(200)),ZbSession(title:"Next",date:now.addingTimeInterval(100))]
check(book.next(now)?.title=="Next","Next training excludes completed/past sessions and sorts by date")
book.sessions=[];check(book.next(now)==nil,"No fictional session in empty plan")
passes.append("Training: past/completed excluded; earliest future selected; empty plan stays empty")
let encoded=try JSONEncoder().encode(book);let decoded=try JSONDecoder().decode(ZbBook.self,from:encoded)
check(decoded.chosen==book.chosen && decoded.plays==book.plays,"Whole archive roundtrip")
passes.append("Local archive roundtrip preserves selection and every tactic")
let result:[String:Any]=["passed":true,"checks":passes,"scope":"Host-side shared Swift model; device UI tests run separately through simulator_pool"]
let data=try JSONSerialization.data(withJSONObject:result,options:[.prettyPrinted,.sortedKeys]);FileHandle.standardOutput.write(data)
'''
env=dict(os.environ,DEVELOPER_DIR='/Applications/Xcode.app/Contents/Developer',CLANG_MODULE_CACHE_PATH=str(R/'Artifacts/ModuleCache'))
r=subprocess.run(['swift','-module-cache-path',str(R/'Artifacts/ModuleCache'),'-'],input=(R/'CoachBoard/ChalkKernel.swift').read_text()+checks,text=True,capture_output=True,cwd=R,env=env)
(R/'QA/model-results.json').write_text(r.stdout);(R/'QA/model-check.log').write_text(r.stderr)
print(r.stdout or r.stderr[-5000:]);raise SystemExit(r.returncode)
