import SwiftUI
import UniformTypeIdentifiers

@main struct ZbOrbit: App {
 @StateObject private var p=ZbPocket()
 @Environment(\.scenePhase) private var phase
 var body: some Scene {
  WindowGroup {
   Group {
#if targetEnvironment(simulator)
    if let index = StoreCaptureRoute.index { StoreCaptureScene(index: index) }
    else { ZbHome(p:p) }
#else
    ZbHome(p:p)
#endif
}.preferredColorScheme(.dark).tint(zLime)
    .onChange(of:phase){_,v in if v == .active{Task{await p.schedule()}}}
    .onOpenURL { url in
     if url.scheme == "coachboard" {if url.host=="board",let id=UUID(uuidString:url.lastPathComponent),p.book.plays.contains(where:{$0.id==id}){p.choose(id)};NotificationCenter.default.post(name:Notification.Name("ZbRoute"),object:url.host)}
     else if url.pathExtension == "json" {p.importFile(url)}
    }
  }
 }
}
struct ZbHome: View {
 @ObservedObject var p:ZbPocket;@State private var tab=0
 var body: some View {
  TabView(selection:$tab) {
   NavigationStack{ZbDesk(p:p)}.tabItem{Label(zTxt("Board"),systemImage:"sportscourt")}.tag(0)
   NavigationStack{ZbShelf(p:p,onOpen:{tab=0})}.tabItem{Label(zTxt("Library"),systemImage:"square.stack.3d.up")}.tag(1)
   NavigationStack{ZbCalendar(p:p,onOpen:{tab=0})}.tabItem{Label(zTxt("Training"),systemImage:"calendar")}.tag(2)
   NavigationStack{ZbPrefs(p:p)}.tabItem{Label(zTxt("Team & settings"),systemImage:"person.2")}.tag(3)
  }
  .onReceive(NotificationCenter.default.publisher(for:Notification.Name("ZbRoute"))){n in tab = (n.object as? String) == "training" ? 2 : 0}
  .alert(zTxt("Soach Board"),isPresented:Binding(get:{p.issue != nil},set:{if !$0{Task{@MainActor in p.issue=nil}}})){Button(zTxt("OK"),role:.cancel){}}message:{Text(p.issue ?? "")}
 }
}
struct ZbDesk: View {
 @ObservedObject var p:ZbPocket;var expanded=false
 @Environment(\.dismiss) private var dismiss
 @State private var tool="move"
 @State private var chosen:UUID?
 @State private var draft:ZbStep?
 @State private var base:ZbStep?
 @State private var started:Date?
 @State private var fullscreen=false
 @State private var details=false
 @State private var importing=false
 @State private var deleteAll=false
 @State private var pdf:URL?
 @State private var file:URL?
 @Environment(\.accessibilityReduceMotion) private var reduced
 let tools=[("move","hand.draw","Move"),("home","person.fill","Player"),("away","person.fill","Opponent"),("ball","soccerball","Ball"),("cone","triangle.fill","Cone"),("arrow","arrow.up.right","Pass"),("run","figure.run","Run"),("zone","rectangle.dashed","Zone"),("erase","eraser","Erase")]
 var body:some View {
  GeometryReader { g in
   ScrollView {
    VStack(alignment:.leading,spacing:18) {
     heading
     if p.current.imported {Label(zTxt("Team copy · duplicate to edit"),systemImage:"person.2.fill").font(.caption).foregroundStyle(zLime)}
     if g.size.width > 900 && g.size.width > g.size.height * 1.2 {
      HStack(alignment:.top,spacing:22) {
       board(width:g.size.width*0.66).frame(width:g.size.width*0.66)
       VStack(spacing:20){palette;frames;inspector}.frame(maxWidth:.infinity)
      }
     } else {
      board(width:g.size.width-32)
      palette
      frames
      inspector
     }
    }.padding(16).padding(.bottom,20)
   }.background(zCoal)
  }
  .navigationTitle(expanded ? zTxt("Tactical board") : "Soach Board").navigationBarTitleDisplayMode(.inline)
  .toolbar {
   if expanded{ToolbarItem(placement:.topBarLeading){Button(zTxt("Done")){dismiss()}}}
   ToolbarItem(placement:.topBarTrailing){Menu {
    Button(zTxt("New tactic"),systemImage:"plus"){p.add(ZbPlay(sport:p.current.sport))}
    Button(zTxt("Tactic details"),systemImage:"pencil"){details=true}
    Button(zTxt("Duplicate"),systemImage:"doc.on.doc"){p.duplicate(p.current)}
    Button(zTxt("Export PDF"),systemImage:"doc.richtext"){exportPDF()}
    Button(zTxt("Export tactic file"),systemImage:"square.and.arrow.up"){exportFile()}
    Button(zTxt("Import tactic file"),systemImage:"square.and.arrow.down"){importing=true}
    if !expanded{Button(zTxt("Full screen"),systemImage:"arrow.up.left.and.arrow.down.right"){fullscreen=true}}
   }label:{Image(systemName:"ellipsis.circle").font(.title3)}.accessibilityIdentifier("boardMenu")}
  }
  .sheet(isPresented:$details){ZbDetails(p:p)}
  .popover(item:$pdf,attachmentAnchor:.rect(.bounds),arrowEdge:.top){u in ZbShare(items:[u]).presentationCompactAdaptation(.sheet)}
  .popover(item:$file,attachmentAnchor:.rect(.bounds),arrowEdge:.top){u in ZbShare(items:[u]).presentationCompactAdaptation(.sheet)}
  .fullScreenCover(isPresented:$fullscreen){NavigationStack{ZbDesk(p:p,expanded:true)}.tint(zLime).preferredColorScheme(.dark)}
  .fileImporter(isPresented:$importing,allowedContentTypes:[.json]){r in if case .success(let u)=r {p.importFile(u)}}
  .task(id:started){
   guard started != nil else{return};let total=p.current.steps.count
   for i in 0..<total {guard !Task.isCancelled,started != nil else{return};p.frame=min(i,p.current.steps.count-1);do{try await Task.sleep(for:.seconds(i==total-1 ? 1.4 : 2))}catch{return}}
   started=nil
  }
  .onDisappear{started=nil;draft=nil;base=nil}
  .onChange(of:p.book.chosen){_,_ in chosen=nil;draft=nil;base=nil;started=nil}
  .confirmationDialog(zTxt("Clear this frame?"),isPresented:$deleteAll,titleVisibility:.visible){Button(zTxt("Clear frame"),role:.destructive){p.replace(ZbStep());chosen=nil}}
 }
 var heading:some View {
  VStack(alignment:.leading,spacing:10) {
   HStack(spacing:8) {
    Capsule().fill(zLime).frame(width:23,height:5)
    Text(zTxt("Tactical board")).font(.system(.caption,design:.monospaced,weight:.bold))
     .tracking(1.4).textCase(.uppercase).foregroundStyle(zLime)
    Spacer()
    Menu {
     ForEach(ZbSport.allCases){sport in Button(sport.name){p.change{$0.sport=sport}}}
    } label: {
     HStack {Image(systemName:p.current.sport.symbol);Text(p.current.sport.name);Image(systemName:"chevron.down")}
      .font(.caption.bold()).padding(.horizontal,12).frame(minHeight:40)
      .overlay(Capsule().strokeBorder(zLime.opacity(0.48)))
    }.disabled(p.current.imported).accessibilityIdentifier("sportMenu")
   }
   Text(p.current.title).font(.custom("AvenirNextCondensed-HeavyItalic",size:42,relativeTo:.largeTitle))
    .fixedSize(horizontal:false,vertical:true).accessibilityIdentifier("tacticTitle")
  }
 }
 func board(width:CGFloat)->some View {
  VStack(spacing:10) {
   HStack{Label(zTxt("FRAME")+" \(p.frame+1)/\(p.current.steps.count)",systemImage:"square.stack").font(.system(.caption,design:.monospaced,weight:.semibold)).accessibilityIdentifier("frameSummary");Spacer();Label(zTxt("Saved on device"),systemImage:"checkmark.circle.fill").font(.caption2).foregroundStyle(.secondary)}
   GeometryReader{geo in
    TimelineView(.animation(minimumInterval:1/30,paused:started == nil)){tick in ZbPitch(sport:p.current.sport,step:visual(tick.date),selected:chosen)}
     .contentShape(Rectangle())
     .gesture(DragGesture(minimumDistance:0).onChanged {v in drag(v,geo.size,false)}.onEnded{v in drag(v,geo.size,true)})
     .accessibilityElement(children:.ignore).accessibilityLabel(zTxt("Tactical board")+", "+p.current.sport.name).accessibilityValue(zCounts(p.step)).accessibilityIdentifier("pitch")
   }.frame(height:max(220,min(expanded ? 740 : 675,width*0.69)))
   HStack{Text(zTxt(tool == "move" ? "Drag a marker to move it." : ["arrow","run","zone"].contains(tool) ? "Drag on the field to draw." : "Tap the field to place or erase.")).font(.caption).foregroundStyle(.secondary);Spacer();Button{deleteAll=true}label:{Image(systemName:"trash")}.accessibilityLabel(zTxt("Clear frame")).disabled(p.current.imported)}
  }
 }
 var palette:some View {
  ScrollView(.horizontal,showsIndicators:false){HStack(spacing:8){ForEach(tools,id:\.0){t in Button{tool=t.0;started=nil}label:{VStack(spacing:6){Image(systemName:t.1).font(.title3).frame(height:22);Text(zTxt(t.2)).font(.caption2.bold())}.frame(minWidth:49,minHeight:52).padding(.horizontal,5).foregroundStyle(tool==t.0 ? zCoal : t.0 == "away" ? zAway : .white).background(tool==t.0 ? zLime : zPanel,in:RoundedRectangle(cornerRadius:6)).contentShape(Rectangle())}.buttonStyle(.plain).accessibilityLabel(zTxt(t.2)).accessibilityAddTraits(tool==t.0 ? .isSelected : []).accessibilityIdentifier("tool-"+t.0)}}}.disabled(p.current.imported)
 }
 var frames:some View {
  VStack(alignment:.leading,spacing:12){
   HStack{Text(zTxt("PLAY SEQUENCE")).font(.system(.caption,design:.monospaced,weight:.bold)).foregroundStyle(.secondary);Spacer();Button{p.undo()}label:{Image(systemName:"arrow.uturn.backward")}.disabled(p.back.isEmpty).accessibilityLabel(zTxt("Undo"));Button{p.redo()}label:{Image(systemName:"arrow.uturn.forward")}.disabled(p.forward.isEmpty).accessibilityLabel(zTxt("Redo"))}
   ScrollView(.horizontal,showsIndicators:false){HStack(spacing:10){ForEach(Array(p.current.steps.enumerated()),id:\.element.id){i,s in Button{p.frame=i;started=nil;chosen=nil}label:{VStack(spacing:5){ZbPitch(sport:p.current.sport,step:s).frame(width:92,height:58);Text("\(i+1)").font(.caption.monospacedDigit())}.padding(5).background(p.frame==i ? zLime.opacity(0.15) : zPanel,in:RoundedRectangle(cornerRadius:10)).overlay{RoundedRectangle(cornerRadius:10).stroke(p.frame==i ? zLime : .clear,lineWidth:1)}}.buttonStyle(.plain).accessibilityLabel(zTxt("Frame")+" \(i+1)").accessibilityIdentifier("frame-\(i)")}
    Button{p.addStep();started=nil}label:{Image(systemName:"plus").font(.title2).frame(width:48,height:75).background(zPanel,in:RoundedRectangle(cornerRadius:12))}.accessibilityLabel(zTxt("Add frame")).accessibilityIdentifier("addFrame").disabled(p.current.imported || p.current.steps.count>=24)
   }}
   HStack{Button{if started != nil {started=nil}else{p.frame=0;started=Date()}}label:{Label(zTxt(started==nil ? "Play sequence" : "Pause"),systemImage:started==nil ? "play.fill" : "pause.fill").font(.subheadline.bold())}.disabled(p.current.steps.count<2).accessibilityIdentifier("playSequence");Spacer();Text(reduced ? zTxt("Step preview") : zTxt("2 sec / frame")).font(.caption).foregroundStyle(.secondary);Button{p.deleteStep();started=nil}label:{Image(systemName:"minus.square")}.accessibilityLabel(zTxt("Delete frame")).disabled(p.current.steps.count<2 || p.current.imported)}
  }.padding(14).background(zPanel,in:RoundedRectangle(cornerRadius:6)).overlay(alignment:.leading){Rectangle().fill(zLime).frame(width:3)}
 }
 var inspector:some View {
  VStack(alignment:.leading,spacing:12){
   if let id=chosen,let m=p.step.marks.first(where:{$0.id==id}) {
    HStack{Text(zTxt("Selected marker")).font(.subheadline.bold());Spacer();Button(zTxt("Delete"),role:.destructive){var s=p.step;s.marks.removeAll{$0.id==id};p.replace(s);chosen=nil}}
    if ["home","away"].contains(m.kind){Stepper(zTxt("Number")+" \(m.number)",value:Binding(get:{m.number},set:{v in editMark(id){$0.number=v}}),in:1...99)}
    HStack{nudge("arrow.left",-0.02,0,id);nudge("arrow.right",0.02,0,id);nudge("arrow.up",0,-0.02,id);nudge("arrow.down",0,0.02,id)}
   }
   DisclosureGroup(zTxt("Markers")){LazyVGrid(columns:[GridItem(.adaptive(minimum:95))]){ForEach(p.step.marks){m in Button{chosen=m.id;tool="move"}label:{Text(zTxt(m.kind=="home" ? "Player" : m.kind=="away" ? "Opponent" : m.kind=="cone" ? "Cone" : "Ball")+" \(m.number)").font(.caption).padding(8)}.accessibilityAddTraits(chosen==m.id ? .isSelected : [])}}}
   if !p.current.memo.isEmpty{Text(p.current.memo).font(.subheadline).foregroundStyle(.secondary)}
   if p.current.imported{Button(zTxt("Duplicate to edit")){p.duplicate(p.current)}}
  }.disabled(p.current.imported && chosen != nil)
 }
 func nudge(_ icon:String,_ dx:Double,_ dy:Double,_ id:UUID)->some View{Button{editMark(id){$0.x=min(0.98,max(0.02,$0.x+dx));$0.y=min(0.98,max(0.02,$0.y+dy))}}label:{Image(systemName:icon).frame(maxWidth:.infinity,minHeight:34).background(zPanel,in:RoundedRectangle(cornerRadius:8))}.accessibilityLabel(zTxt(icon=="arrow.left" ? "Move left" : icon=="arrow.right" ? "Move right" : icon=="arrow.up" ? "Move up" : "Move down"))}
 func editMark(_ id:UUID,_ f:(inout ZbMark)->Void){var s=p.step;if let i=s.marks.firstIndex(where:{$0.id==id}){f(&s.marks[i]);p.replace(s)}}
 func visual(_ d:Date)->ZbStep {
  if let started {let seconds=d.timeIntervalSince(started);let steps=p.current.steps;let n=min(steps.count-1,Int(seconds/2));let next=min(steps.count-1,n+1);return reduced ? steps[n] : ZbStep.mix(steps[n],steps[next],min(1,(seconds.truncatingRemainder(dividingBy:2))/1.3))}
  return draft ?? p.step
 }
 func point(_ p:CGPoint,_ s:CGSize)->(Double,Double){let m=zInset(s.width);return (min(0.98,max(0.02,(p.x-m)/max(1,s.width-2*m))),min(0.98,max(0.02,(p.y-m)/max(1,s.height-2*m))))}
 func drag(_ v:DragGesture.Value,_ size:CGSize,_ end:Bool) {
  guard !p.current.imported, started==nil else{return}
  let a=point(v.startLocation,size), b=point(v.location,size)
  if base == nil {base=p.step;if tool=="move"{chosen=p.step.marks.min(by:{hypot($0.x-a.0,$0.y-a.1)<hypot($1.x-a.0,$1.y-a.1)}).flatMap{hypot($0.x-a.0,$0.y-a.1)<0.1 ? $0.id : nil}}}
  guard var s=base else{return}
  switch tool {
  case "move":if let chosen,let i=s.marks.firstIndex(where:{$0.id==chosen}){s.marks[i].x=b.0;s.marks[i].y=b.1}
  case "arrow","run","zone":if s.lines.count<80{s.lines.append(ZbLine(x:a.0,y:a.1,u:b.0,v:b.1,kind:tool))}
  case "erase":
   if let m=s.marks.min(by:{hypot($0.x-b.0,$0.y-b.1)<hypot($1.x-b.0,$1.y-b.1)}),hypot(m.x-b.0,m.y-b.1)<0.1{s.marks.removeAll{$0.id==m.id}}
   else if let i=s.lines.indices.min(by:{distance(s.lines[$0],b)<distance(s.lines[$1],b)}),distance(s.lines[i],b)<0.08{s.lines.remove(at:i)}
  default:if s.marks.count<80{let n=(s.marks.filter{$0.kind==tool}.map(\.number).max() ?? 0)+1;s.marks.append(ZbMark(x:b.0,y:b.1,kind:tool,number:min(99,n)))}
  }
  draft=s
  if end {if s != p.step{p.replace(s)};base=nil;draft=nil}
 }
 func distance(_ l:ZbLine,_ p:(Double,Double))->Double{let dx=l.u-l.x,dy=l.v-l.y;let t=min(1,max(0,((p.0-l.x)*dx+(p.1-l.y)*dy)/max(0.00001,dx*dx+dy*dy)));return hypot(p.0-l.x-t*dx,p.1-l.y-t*dy)}
 func exportPDF(){do{pdf=try ZbPrint.pdf(p.current)}catch{p.issue=zTxt("Could not export this tactic.")}}
 func exportFile(){do{file=try p.portableTactic()}catch{p.issue=error.localizedDescription}}
}
extension URL: @retroactive Identifiable {public var id:String{absoluteString}}

#if targetEnvironment(simulator)
private enum StoreCaptureRoute {
    static var index: Int? {
        let process = ProcessInfo.processInfo
        let args = process.arguments
        if let at = args.firstIndex(of:"-ReviewScreen"), args.indices.contains(at+1) {
            return ["football-board", "tactic-library", "basketball-play", "training-calendar", "session-drills", "widget-gallery"].firstIndex(of:args[at+1])
        }
        guard args.contains("-AppStoreScreenshots") || process.environment["APPSTORE_SCREENSHOTS"] == "1" else { return nil }
        if let at = args.firstIndex(of: "-AppStoreScreenshotScreen"), args.indices.contains(at+1) { return Int(args[at+1]) }
        return Int(process.environment["APPSTORE_SCREENSHOT_SCREEN"] ?? "0")
    }
}

@MainActor private struct StoreCaptureScene: View {
    let index: Int
    @StateObject private var model: ZbPocket
    init(index: Int) {
        self.index = index
        let p = ZbPocket(FileManager.default.temporaryDirectory.appendingPathComponent("capture-playbook"),false)
        let plays = (0..<6).map { i in ZbSeeds.make(i < 3 ? .football : i == 3 ? .futsal : .basketball, i) }
        let english = ["Passing under pressure", "Attacking the space", "Final-third combinations"]
        let portuguese = ["Passe sob pressão", "Ataque ao espaço", "Combinações no ataque"]
        let pt = Locale.preferredLanguages.first?.hasPrefix("pt") == true
        let sessions = (0..<3).map { i in
            ZbSession(title:(pt ? portuguese : english)[i],date:Calendar.current.date(byAdding:.day,value:i+1,to:Date())!,minutes:[70,50,90][i],drills:[plays[i].id,plays[i+1].id],notes:pt ? "Trabalhe em grupos de três e alterne os lados." : "Work in groups of three and alternate sides.",season:pt ? "Outono" : "Autumn")
        }
        p.book = ZbBook(plays:plays,sessions:sessions,chosen:plays[index == 2 ? 5 : 0].id)
        if index == 2 { p.frame=1 }
        _model = StateObject(wrappedValue:p)
    }
    var body: some View {
        switch index {
        case 1: ZbHome(p:model, storeTab:1)
        case 3: ZbHome(p:model, storeTab:2)
        case 4: ZbSessionEdit(p:model,value:model.book.sessions[0])
        case 5: NavigationStack { ZbWidgetGallery(p:model).navigationBarTitleDisplayMode(.inline) }
        default: ZbHome(p:model)
        }
    }
}
private extension ZbHome {
    init(p: ZbPocket, storeTab:Int) { self.p=p; _tab=State(initialValue:storeTab) }
}

#endif
