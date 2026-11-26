import SwiftUI
import UIKit
import CoreText
import UniformTypeIdentifiers

struct ZbShelf:View {
 @ObservedObject var p:ZbPocket;var onOpen:()->Void
 @State private var query=""
 @State private var sport:ZbSport?
 @State private var importing=false
 @State private var pending:UUID?
 private static let starters = (0..<6).map { index in
  ZbSeeds.make(index < 3 ? .football : index == 3 ? .futsal : .basketball, index)
 }
 var items:[ZbPlay]{p.book.plays.filter{(sport==nil || $0.sport==sport) && (query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) || $0.memo.localizedCaseInsensitiveContains(query))}.sorted{$0.revised>$1.revised}}
 var body:some View {
  List{
   Section{Picker(zTxt("Sport"),selection:$sport){Text(zTxt("All sports")).tag(Optional<ZbSport>.none);ForEach(ZbSport.allCases){Text($0.name).tag(Optional($0))}}}
   Section(zTxt("Saved tactics")){
    ForEach(items){play in
     Button{p.choose(play.id);onOpen()}label:{HStack(spacing:14){ZbPitch(sport:play.sport,step:play.steps[0]).frame(width:104,height:72);VStack(alignment:.leading,spacing:5){Text(play.title).font(.custom("AvenirNextCondensed-DemiBold",size:22,relativeTo:.headline)).foregroundStyle(.white);Text(play.sport.name+" · \(play.steps.count) "+zTxt(play.steps.count==1 ? "Frame" : "frames")).font(.caption).foregroundStyle(.secondary);if play.imported{Label(zTxt("Team copy"),systemImage:"person.2").font(.caption2).foregroundStyle(zLime)}};Spacer();Image(systemName:"chevron.right").foregroundStyle(.secondary)}.contentShape(Rectangle())}.buttonStyle(.plain)
     .contextMenu{Button(zTxt("Duplicate"),systemImage:"doc.on.doc"){p.duplicate(play)};Button(zTxt("Delete"),systemImage:"trash",role:.destructive){pending=play.id}}
     .swipeActions{Button(zTxt("Delete"),role:.destructive){pending=play.id}}
    }
    if items.isEmpty{ContentUnavailableView(zTxt("No matching tactics"),systemImage:"sportscourt",description:Text(zTxt("Create a tactic or choose a built-in exercise below.")))}
   }
   Section{ForEach(0..<6,id:\.self){n in let s:ZbSport = n<3 ? .football : n==3 ? .futsal : .basketball
    if sport==nil || sport==s{Button{p.add(ZbSeeds.make(s,n));onOpen()}label:{HStack{ZbPitch(sport:s,step:Self.starters[n].steps[0]).frame(width:86,height:56).accessibilityHidden(true);VStack(alignment:.leading,spacing:5){Text(zTxt(ZbSeeds.titles[n])).font(.headline).foregroundStyle(.white);Text(s.name+" · "+zTxt("Built-in exercise")).font(.caption).foregroundStyle(.secondary)};Spacer();Image(systemName:"plus.circle").foregroundStyle(zLime)}}}
   }}header:{Text(zTxt("Exercise starters"))}footer:{Text(zTxt("Built-in exercises are starting points. Adapt the movements and intensity to your players."))}
  }.scrollContentBackground(.hidden).background(zCoal).searchable(text:$query,prompt:zTxt("Find a tactic"))
   .navigationTitle(zTxt("Library"))
   .toolbar{ToolbarItem(placement:.topBarTrailing){Menu{Button(zTxt("New tactic"),systemImage:"plus"){p.add(ZbPlay());onOpen()};Button(zTxt("Import tactic file"),systemImage:"square.and.arrow.down"){importing=true}}label:{Image(systemName:"plus.circle")}}}
   .fileImporter(isPresented:$importing,allowedContentTypes:[.json]){r in if case .success(let u)=r {p.importFile(u);onOpen()}}
   .confirmationDialog(zTxt("Delete this tactic?"),isPresented:Binding(get:{pending != nil},set:{if !$0{pending=nil}}),titleVisibility:.visible){Button(zTxt("Delete tactic"),role:.destructive){if let id=pending{p.remove(id)};pending=nil}}message:{Text(zTxt("It will also be removed from local training plans. iCloud invitations are managed in Team & settings."))}
 }
}
struct ZbDetails:View {
 @ObservedObject var p:ZbPocket;@Environment(\.dismiss) private var dismiss
 @State private var title=""
 @State private var note=""
 var body:some View{NavigationStack{Form{Section(zTxt("Tactic details")){TextField(zTxt("Tactic name"),text:$title).accessibilityIdentifier("tacticName");TextField(zTxt("Coaching notes"),text:$note,axis:.vertical).lineLimit(4...10)};Section{Text(zTxt("Every change on the board is saved automatically on this device.")).font(.footnote)}}.navigationTitle(zTxt("Tactic details")).toolbar{ToolbarItem(placement:.cancellationAction){Button(zTxt("Cancel")){dismiss()}};ToolbarItem(placement:.confirmationAction){Button(zTxt("Save")){let prior=p.current.memo;p.change{$0.name=title.trimmingCharacters(in:.whitespacesAndNewlines);$0.titleKey=nil;if note != prior{$0.notes=note;$0.noteKey=nil}};dismiss()}.disabled(title.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty || p.current.imported).accessibilityIdentifier("saveDetails")}}.onAppear{title=p.current.title;note=p.current.memo}}}
}
struct ZbCalendar:View {
 @ObservedObject var p:ZbPocket;var onOpen:()->Void
 @State private var edit:ZbSession?
 @State private var new=false
 @State private var season=""
 @State private var showCompleted=false
 var sessions:[ZbSession]{p.book.sessions.filter{(showCompleted || !$0.done) && (season.isEmpty || $0.season==season)}.sorted{$0.date<$1.date}}
 var body:some View {
  List{
   Section{VStack(alignment:.leading,spacing:8){Text(zTxt("Make every session count.")).font(.title2.bold());Text(zTxt("Plan a week. Build a season.")).foregroundStyle(.secondary)}.padding(.vertical,8).listRowBackground(Color.clear)}
   Section{Picker(zTxt("Season"),selection:$season){Text(zTxt("All seasons")).tag("");ForEach(Array(Set(p.book.sessions.map(\.season).filter{!$0.isEmpty})).sorted(),id:\.self){Text($0).tag($0)}};Toggle(zTxt("Show completed"),isOn:$showCompleted)}
   if sessions.isEmpty{Section{ContentUnavailableView(zTxt("Your next training starts here"),systemImage:"calendar.badge.plus",description:Text(zTxt("Add a session, attach tactics and repeat it across your season.")));Button(zTxt("Plan training")){new=true}.accessibilityIdentifier("planTraining")}}
   ForEach(sessions){s in Section{
    HStack(alignment:.top){Button{var q=s;q.done.toggle();p.training(q)}label:{Image(systemName:s.done ? "checkmark.circle.fill" : "circle").font(.title2).foregroundStyle(s.done ? zLime : .secondary)}.buttonStyle(.plain).accessibilityLabel(zTxt(s.done ? "Mark incomplete" : "Complete training"));VStack(alignment:.leading,spacing:6){Text(s.title).font(.headline);Text(s.date,format:.dateTime.weekday(.abbreviated).day().month().hour().minute()).font(.subheadline).foregroundStyle(zLime);Text("\(s.minutes) "+zTxt("min")+(s.season.isEmpty ? "" : " · "+s.season)).font(.caption).foregroundStyle(.secondary);if !s.notes.isEmpty{Text(s.notes).font(.caption).foregroundStyle(.secondary)}};Spacer();Button{edit=s}label:{Image(systemName:"pencil")}.accessibilityLabel(zTxt("Edit training"))}
    ForEach(Array(s.drills.enumerated()),id:\.element){n,id in if let d=p.book.plays.first(where:{$0.id==id}){Button{p.choose(id);onOpen()}label:{HStack{Text(String(format:"%02d",n+1)).font(.caption.monospacedDigit()).foregroundStyle(.secondary);Text(d.title);Spacer();Image(systemName:"arrow.up.right")}.font(.subheadline)}}}
   }.swipeActions{Button(zTxt("Delete"),role:.destructive){p.dropSession(s.id)}}}
  }.scrollContentBackground(.hidden).background(zCoal).navigationTitle(zTxt("Training"))
  .toolbar{ToolbarItem(placement:.topBarTrailing){Button{new=true}label:{Image(systemName:"plus.circle")}.accessibilityLabel(zTxt("Plan training")).accessibilityIdentifier("newTraining")}}
  .sheet(isPresented:$new){ZbSessionEdit(p:p,value:ZbSession())}.sheet(item:$edit){s in ZbSessionEdit(p:p,value:s)}
 }
}
struct ZbSessionEdit:View {
 @ObservedObject var p:ZbPocket;@State var value:ZbSession
 @State private var repeatCount=1;@Environment(\.dismiss) private var dismiss
 var existing:Bool{p.book.sessions.contains{$0.id==value.id}}
 var body:some View{NavigationStack{Form{
  Section(zTxt("Session")){TextField(zTxt("Training title"),text:$value.title).accessibilityIdentifier("trainingTitle");DatePicker(zTxt("Date & time"),selection:$value.date);Stepper(zTxt("Duration")+": \(value.minutes) "+zTxt("min"),value:$value.minutes,in:15...240,step:5);TextField(zTxt("Season name"),text:$value.season);TextField(zTxt("Session notes"),text:$value.notes,axis:.vertical).lineLimit(3...8)}
  if !existing{Section{Stepper(zTxt("Weekly sessions")+": \(repeatCount)",value:$repeatCount,in:1...12)}footer:{Text(zTxt("Create a weekly plan with the same tactics. Each session can be edited separately."))}}
  Section{ForEach(p.book.plays){d in Button{if value.drills.contains(d.id){value.drills.removeAll{$0==d.id}}else{value.drills.append(d.id)}}label:{HStack{Text(d.title).foregroundStyle(.primary);Spacer();if let i=value.drills.firstIndex(of:d.id){Text("\(i+1)").font(.caption.bold()).padding(7).background(zLime,in:Circle()).foregroundStyle(zCoal)}else{Image(systemName:"circle").foregroundStyle(.secondary)}}}}}header:{Text(zTxt("Tactics · tap in session order"))}
  if !value.drills.isEmpty{Section(zTxt("Session order")){ForEach(Array(value.drills.enumerated()),id:\.element){i,id in HStack{Text("\(i+1). "+(p.book.plays.first{$0.id==id}?.title ?? ""));Spacer();if i>0{Button{value.drills.swapAt(i,i-1)}label:{Image(systemName:"arrow.up")}.buttonStyle(.borderless).accessibilityLabel(zTxt("Move up"))}}}}}
 }.navigationTitle(zTxt(existing ? "Edit training" : "Plan training")).toolbar{ToolbarItem(placement:.cancellationAction){Button(zTxt("Cancel")){dismiss()}};ToolbarItem(placement:.confirmationAction){Button(zTxt("Save")){value.title=value.title.trimmingCharacters(in:.whitespacesAndNewlines);p.training(value,count:repeatCount);dismiss()}.disabled(value.title.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty).accessibilityIdentifier("saveTraining")}}}}
}
struct ZbPrefs:View {
 @ObservedObject var p:ZbPocket;@State private var file:URL?;@State private var pick=false
 var body:some View {
  Form{
   Section(zTxt("Team library")){
    Text(zTxt("Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again."))
    Button(zTxt("Share a copy")){do{file=try p.portableTactic()}catch{p.issue=error.localizedDescription}}
    Button(zTxt("Open a shared file")){pick=true}
   }
   Section {
    if p.book.reminders{Toggle(zTxt("Training reminders"),isOn:Binding(get:{p.book.reminders},set:{p.book.reminders=$0;p.save();Task{await p.schedule()}}))}
    else{Button(zTxt("Enable training reminders")){Task{await p.enableReminders()}}.accessibilityIdentifier("enableReminders")}
    Button(zTxt("Open system settings")){if let u=URL(string:UIApplication.openSettingsURLString){UIApplication.shared.open(u)}}
   }header:{Text(zTxt("Notifications"))}
   Section(zTxt("Privacy")){Text(zTxt("Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again."));Text(zTxt("No camera, microphone, location, health or calendar access is needed."))}
   Section(zTxt("Widgets")){NavigationLink(zTxt("Widget previews")){ZbWidgetGallery(p:p)};Text(zTxt("Add Soach Board widgets to your Home Screen or Lock Screen. They use the last saved local board and training plan, with no network requests."))}
   Section{LabeledContent(zTxt("Version"),value:"1.2.6 (162)");Text(zTxt("Free. Offline. Built for the touchline.")).font(.caption).foregroundStyle(.secondary)}
  }.scrollContentBackground(.hidden).background(zCoal).navigationTitle(zTxt("Team & settings"))
   .sheet(item:$file){ZbShare(items:[$0])}.fileImporter(isPresented:$pick,allowedContentTypes:[.json]){if case let .success(u)=$0{p.importFile(u)}}
 }
}
struct ZbShare:UIViewControllerRepresentable {
 var items:[Any]
 func makeUIViewController(context:Context)->UIActivityViewController{UIActivityViewController(activityItems:items,applicationActivities:nil)}
 func updateUIViewController(_ uiViewController:UIActivityViewController,context:Context){}
}
enum ZbPrint {
 @MainActor static func pdf(_ p:ZbPlay)throws->URL {
  let target=FileManager.default.temporaryDirectory.appendingPathComponent("Soach-Board-\(p.id.uuidString.prefix(8)).pdf")
  let renderer=UIGraphicsPDFRenderer(bounds:CGRect(x:0,y:0,width:842,height:595))
  try renderer.writePDF(to:target){ctx in
   for (i,step) in p.steps.enumerated(){
    ctx.beginPage();let c=ctx.cgContext;c.setFillColor(UIColor(red:14/255,green:17/255,blue:22/255,alpha:1).cgColor);c.fill(CGRect(x:0,y:0,width:842,height:595))
    let head:[NSAttributedString.Key:Any]=[.font:UIFont.boldSystemFont(ofSize:24),.foregroundColor:UIColor.white]
    (p.title as NSString).draw(in:CGRect(x:32,y:25,width:675,height:60),withAttributes:head)
    let caption=p.sport.name+" · "+zTxt("Frame")+" \(i+1)/\(p.steps.count)"
    (caption as NSString).draw(at:CGPoint(x:32,y:83),withAttributes:[.font:UIFont.systemFont(ofSize:12),.foregroundColor:UIColor.lightGray])
    let pitch=ImageRenderer(content:ZbPitch(sport:p.sport,step:step).frame(width:620,height:400))
    pitch.render{_,draw in c.saveGState();c.translateBy(x:111,y:512);c.scaleBy(x:1,y:-1);c.textMatrix = .identity;draw(c);c.restoreGState();c.textMatrix = .identity}
    ("Soach Board · "+zTxt("Coaching sequence") as NSString).draw(at:CGPoint(x:32,y:557),withAttributes:[.font:UIFont.systemFont(ofSize:11),.foregroundColor:UIColor.lightGray])
   }
   if !p.memo.isEmpty {
    let font=UIFont.systemFont(ofSize:15);let attrs:[NSAttributedString.Key:Any]=[.font:font,.foregroundColor:UIColor.black]
    let text=NSAttributedString(string:p.memo,attributes:attrs);let fs=CTFramesetterCreateWithAttributedString(text)
    var start=0
    while start<text.length {
     ctx.beginPage();(p.title+" · "+zTxt("Coaching notes") as NSString).draw(in:CGRect(x:32,y:25,width:778,height:45),withAttributes:[.font:UIFont.boldSystemFont(ofSize:22)])
     let c=ctx.cgContext;c.saveGState();c.translateBy(x:32,y:535);c.scaleBy(x:1,y:-1);c.textMatrix = .identity
     let path=CGPath(rect:CGRect(x:0,y:0,width:778,height:450),transform:nil);let frame=CTFramesetterCreateFrame(fs,CFRange(location:start,length:0),path,nil);CTFrameDraw(frame,c);let range=CTFrameGetVisibleStringRange(frame);c.restoreGState();c.textMatrix = .identity;guard range.length>0 else{break};start+=range.length
    }
   }
  };return target
 }
}
