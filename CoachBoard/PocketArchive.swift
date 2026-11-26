import Foundation
import SwiftUI
import Combine
import UserNotifications
import WidgetKit

@MainActor final class ZbPocket: ObservableObject {
 @Published var book: ZbBook
 @Published var issue:String?
 @Published var frame = 0
 var back: [ZbPlay] = []; var forward: [ZbPlay] = []
 private var place: URL
 private let q8:Bool
 var current: ZbPlay { book.plays.first(where:{$0.id == book.chosen}) ?? book.plays[0] }
 var step: ZbStep { current.steps[min(frame,current.steps.count-1)] }
 init(_ h:URL?=nil,_ t:Bool=true) {
  let d=h ?? FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("ChalkOrbit",isDirectory:true)
  place=d.appendingPathComponent("playbook.json");q8=t
  var recovered=false
  if let data=try? Data(contentsOf:place), let b=try? JSONDecoder().decode(ZbBook.self,from:data), !b.plays.isEmpty, b.plays.allSatisfy({ !$0.steps.isEmpty }) { book=b }
  else if let data=try? Data(contentsOf:place.appendingPathExtension("backup")), let b=try? JSONDecoder().decode(ZbBook.self,from:data), !b.plays.isEmpty { book=b; recovered=true }
  else { book = .fresh; recovered=FileManager.default.fileExists(atPath:place.path) }
  if !book.plays.contains(where:{$0.id==book.chosen}){book.chosen=book.plays[0].id}
  if recovered { issue=zTxt("The saved file could not be read. A recovery copy was used when available.") }
  save()
 }
 func save() {
  do {
   try FileManager.default.createDirectory(at:place.deletingLastPathComponent(),withIntermediateDirectories:true)
   let data=try JSONEncoder().encode(book)
   if let old=try? Data(contentsOf:place), (try? JSONDecoder().decode(ZbBook.self,from:old)) != nil { try old.write(to:place.appendingPathExtension("backup"),options:.atomic) }
   try data.write(to:place,options:[.atomic,.completeFileProtectionUntilFirstUserAuthentication])
   if q8 {
    if let g=FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:zGroup) {try data.write(to:g.appendingPathComponent("glance.json"),options:.atomic)}
    WidgetCenter.shared.reloadAllTimelines()
   }
  } catch { issue=zTxt("Could not save. Keep the app open and free some device storage.") }
 }
 func change(_ f: (inout ZbPlay)->Void) {
  guard let i=book.plays.firstIndex(where:{$0.id == book.chosen}), !current.imported else { return }
  back.append(book.plays[i]); if back.count > 40 { back.removeFirst() }; forward=[]
  f(&book.plays[i]); book.plays[i].revised=Date(); save()
 }
 func replace(_ s: ZbStep) { change { $0.steps[min(frame,$0.steps.count-1)]=s } }
 func undo() { guard let p=back.popLast(), let i=book.plays.firstIndex(where:{$0.id==p.id}) else {return}; forward.append(book.plays[i]); book.plays[i]=p; frame=min(frame,p.steps.count-1);save();objectWillChange.send() }
 func redo() { guard let p=forward.popLast(), let i=book.plays.firstIndex(where:{$0.id==p.id}) else{return}; back.append(book.plays[i]); book.plays[i]=p; frame=min(frame,p.steps.count-1);save();objectWillChange.send() }
 func choose(_ id:UUID) { book.chosen=id;frame=0;back=[];forward=[];save() }
 func add(_ p:ZbPlay) { book.plays.insert(p,at:0);choose(p.id) }
 func duplicate(_ p:ZbPlay) { var c=p;c.id=UUID();c.name=p.title+" · "+zTxt("Copy");c.titleKey=nil;c.teamRecord=nil;c.teamZone=nil;c.teamOwner=nil;c.revised=Date();add(c) }
 func remove(_ id:UUID) {
  book.plays.removeAll{$0.id==id};for i in book.sessions.indices { book.sessions[i].drills.removeAll{$0==id} }
  if book.plays.isEmpty { let p=ZbPlay();book.plays=[p] }
  if book.chosen==id { choose(book.plays[0].id) }; save()
 }
 func addStep() { guard current.steps.count < 24 else {issue=zTxt("A tactic can contain up to 24 frames.");return};change { var s=$0.steps[min(frame,$0.steps.count-1)];s.id=UUID();$0.steps.insert(s,at:frame+1) };frame+=1 }
 func deleteStep() { guard current.steps.count>1 else{return};change{$0.steps.remove(at:frame)};frame=max(0,frame-1) }
 func training(_ s:ZbSession, count:Int=1) {
  if let i=book.sessions.firstIndex(where:{$0.id==s.id}) {book.sessions[i]=s}
  else { for w in 0..<count {var q=s;q.id = w==0 ? s.id : UUID();q.date=Calendar.current.date(byAdding:.weekOfYear,value:w,to:s.date) ?? s.date;book.sessions.append(q)} }
  save();Task{await schedule()}
 }
 func dropSession(_ id:UUID) {book.sessions.removeAll{$0.id==id};save();Task{await schedule()}}
 func enableReminders() async {
  do { book.reminders=try await UNUserNotificationCenter.current().requestAuthorization(options:[.alert,.sound,.badge]);save();await schedule(); if !book.reminders { issue=zTxt("Notifications are off. You can still use your training plan. Enable alerts in Settings.") } }
  catch {issue=zTxt("Notifications are unavailable. Your training plan is saved.")}
 }
 func schedule() async {
  let n=UNUserNotificationCenter.current();n.removeAllPendingNotificationRequests()
  guard book.reminders else{return}
  let settings=await n.notificationSettings();guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else{return}
  for s in book.sessions.filter({!$0.done && $0.date>Date()}).sorted(by:{$0.date<$1.date}).prefix(50) {
   let tomorrow=Calendar.current.date(byAdding:.day,value:-1,to:s.date) ?? s.date
   let due=tomorrow>Date() ? tomorrow : s.date.addingTimeInterval(-3600)
   guard due>Date() else{continue}
   let c=UNMutableNotificationContent();c.title=zTxt(tomorrow>Date() ? "Training tomorrow" : "Training soon");c.body=s.title;c.sound = .default
   let parts=Calendar.current.dateComponents([.year,.month,.day,.hour,.minute],from:due)
   try? await n.add(UNNotificationRequest(identifier:"practice-"+s.id.uuidString,content:c,trigger:UNCalendarNotificationTrigger(dateMatching:parts,repeats:false)))
  }
 }
 func importFile(_ url:URL) {
  let access=url.startAccessingSecurityScopedResource();defer{if access{url.stopAccessingSecurityScopedResource()}}
  do {guard let n=try url.resourceValues(forKeys:[.fileSizeKey]).fileSize,n<2_000_000 else{throw CocoaError(.fileReadTooLarge)};let d=try Data(contentsOf:url);guard d.count<2_000_000 else{throw CocoaError(.fileReadTooLarge)};var p=try JSONDecoder().decode(ZbPlay.self,from:d);guard valid(p) else{throw CocoaError(.coderReadCorrupt)};p.id=UUID();p.teamRecord=nil;p.teamOwner=nil;p.teamZone=nil;add(p)}
  catch {issue=zTxt("This file is not a valid Soach Board tactic.")}
 }
 func valid(_ p:ZbPlay)->Bool {
  !p.steps.isEmpty && p.steps.count<=24 && Set(p.steps.map(\.id)).count==p.steps.count && p.steps.allSatisfy { f in f.marks.count<=80 && f.lines.count<=80 && Set(f.marks.map(\.id)).count==f.marks.count && Set(f.lines.map(\.id)).count==f.lines.count && f.marks.allSatisfy{ ["home","away","ball","cone"].contains($0.kind) && $0.x.isFinite && $0.y.isFinite && (0...1).contains($0.x) && (0...1).contains($0.y) } && f.lines.allSatisfy{["arrow","run","zone"].contains($0.kind) && [$0.x,$0.y,$0.u,$0.v].allSatisfy{$0.isFinite && (0...1).contains($0)}} }
 }
 func portableTactic() throws -> URL {
  let url=FileManager.default.temporaryDirectory.appendingPathComponent("Soach-Board-"+current.id.uuidString+".json")
  var play=current;play.teamOwner=nil;play.teamRecord=nil;play.teamZone=nil
  try JSONEncoder().encode(play).write(to:url,options:[.atomic,.completeFileProtection]);return url
 }
}
