import SwiftUI
import Foundation

let zLime = Color(red: 205/255, green: 1, blue: 61/255)
let zAway = Color(red:1.0, green:0.61, blue:0.47)
let zCoal = Color(red: 14/255, green: 17/255, blue: 22/255)
let zPanel = Color(red: 25/255, green: 30/255, blue: 37/255)
func zTxt(_ s: String) -> String { NSLocalizedString(s, comment: "") }
let zGroup = "group.com.coachboard.app-c977830d8707"
func zInset(_ w:CGFloat)->CGFloat {max(3,min(12,w*0.0324))}
let zCloud = "iCloud.com.coachboard.app-c977830d8707"

enum ZbSport: String, Codable, CaseIterable, Identifiable {
 case football, futsal, basketball
 var id: String { rawValue }
 var name: String { zTxt(rawValue.capitalized) }
 var symbol: String { self == .basketball ? "basketball" : "soccerball" }
}
struct ZbMark: Codable, Identifiable, Equatable {
 var id = UUID(); var x: Double; var y: Double; var kind: String
 var number: Int = 1
}
struct ZbLine: Codable, Identifiable, Equatable {
 var id = UUID(); var x: Double; var y: Double; var u: Double; var v: Double; var kind: String = "arrow"
}
struct ZbStep: Codable, Equatable, Identifiable {
 var id = UUID(); var marks: [ZbMark] = []; var lines: [ZbLine] = []
 static func mix(_ a: Self, _ b: Self, _ t: Double) -> Self {
  var c = a
  c.marks = a.marks.map { m in
   guard let n = b.marks.first(where: { $0.id == m.id }) else { return m }
   var q=m; q.x += (n.x-m.x)*t; q.y += (n.y-m.y)*t; return q
  }
  if t >= 0.99 { c = b }; return c
 }
}
func zCounts(_ f:ZbStep)->String {"\(f.marks.count) "+zTxt(f.marks.count==1 ? "marker" : "markers")+", \(f.lines.count) "+zTxt(f.lines.count==1 ? "drawing" : "drawings")}
struct ZbPlay: Codable, Identifiable, Equatable {
 var id = UUID(); var name: String = ""; var titleKey: String? = "Untitled tactic"
 var sport: ZbSport = .football; var notes: String = ""; var noteKey: String?; var steps: [ZbStep] = [ZbStep()]
 var revised = Date(); var teamRecord: String?; var teamZone: String?; var teamOwner: String?
 var title: String { titleKey.map(zTxt) ?? name }
 var memo: String { noteKey.map(zTxt) ?? notes }
 var imported: Bool { teamOwner != nil }
}
struct ZbSession: Codable, Identifiable, Equatable {
 var id = UUID(); var title = ""; var date = Date().addingTimeInterval(86400)
 var minutes = 60; var drills: [UUID] = []; var notes = ""; var season = ""; var done = false
}
struct ZbBook: Codable {
 var format = 1; var plays: [ZbPlay]; var sessions: [ZbSession] = []
 var chosen: UUID; var reminders = false; var syncOnLaunch = false
 static var fresh: Self { let p=ZbSeeds.make(.football, 0); return Self(plays: [p], chosen:p.id) }
 func next(_ d: Date = Date()) -> ZbSession? { sessions.filter { !$0.done && $0.date >= d }.sorted { $0.date < $1.date }.first }
}
enum ZbSeeds {
 static let titles = ["Build from the back", "Wide overload", "Press and recover", "Rotation triangle", "Give and go", "Screen and cut"]
 static let descriptions = ["Draw the press, then find the free player. Keep the supporting angles open.", "Move the ball wide. Create a spare player near the touchline.", "Close the passing lane together. Recover into shape when the ball moves.", "Pass, follow and rotate. Keep one passing option on each side.", "Pass to a teammate, cut into space, then receive the return pass.", "Set a screen, change direction and cut toward the basket."]
 static func make(_ s: ZbSport, _ n: Int) -> ZbPlay {
  var points: [(Double,Double)] = s == .basketball ? [(0.22,0.5),(0.42,0.2),(0.5,0.75),(0.68,0.35),(0.74,0.68)] : [(0.13,0.5),(0.3,0.24),(0.3,0.74),(0.5,0.38),(0.5,0.64),(0.7,0.2),(0.72,0.77)]
  switch n {
  case 1: points=[(0.14,0.5),(0.32,0.18),(0.47,0.14),(0.63,0.12),(0.73,0.29),(0.48,0.53),(0.7,0.78)]
  case 2: points=[(0.25,0.5),(0.44,0.28),(0.44,0.73),(0.61,0.31),(0.61,0.68),(0.74,0.48)]
  case 3: points=[(0.13,0.5),(0.3,0.23),(0.3,0.77),(0.64,0.5),(0.8,0.26)]
  case 5: points=[(0.22,0.5),(0.46,0.26),(0.57,0.46),(0.74,0.72),(0.75,0.2)]
  default: break
  }
  var first=ZbStep()
  first.marks = points.enumerated().map { ZbMark(x:$0.element.0,y:$0.element.1,kind:"home",number:$0.offset+1) }
  first.marks += [ZbMark(x:0.62,y:0.5,kind:"away",number:1),ZbMark(x:0.8,y:0.4,kind:"away",number:2),ZbMark(x:0.38,y:0.53,kind:"ball")]
  first.lines = [ZbLine(x:0.31,y:0.25,u:0.59,v:0.23), ZbLine(x:0.52,y:0.62,u:0.75,v:0.54,kind:"run")]
  if n == 1 {first.lines=[ZbLine(x:0.34,y:0.19,u:0.6,v:0.13),ZbLine(x:0.65,y:0.15,u:0.78,v:0.2,kind:"run")]}
  if n == 2 {first.lines=[ZbLine(x:0.45,y:0.29,u:0.59,v:0.43,kind:"run"),ZbLine(x:0.45,y:0.72,u:0.58,v:0.56,kind:"run"),ZbLine(x:0.55,y:0.3,u:0.73,v:0.7,kind:"zone")]}
  if n == 3 {first.lines=[ZbLine(x:0.3,y:0.24,u:0.63,v:0.5),ZbLine(x:0.3,y:0.76,u:0.46,v:0.36,kind:"run")]}
  if n == 4 {first.lines=[ZbLine(x:0.24,y:0.5,u:0.46,v:0.24),ZbLine(x:0.25,y:0.51,u:0.68,v:0.49,kind:"run")]}
  if n == 5 {first.lines=[ZbLine(x:0.48,y:0.28,u:0.72,v:0.5,kind:"run"),ZbLine(x:0.52,y:0.4,u:0.62,v:0.54,kind:"zone")]}
  var second=first; second.id=UUID()
  for i in second.marks.indices where second.marks[i].kind == "home" { second.marks[i].x = min(0.9,second.marks[i].x+0.08); second.marks[i].y = min(0.9,max(0.1,second.marks[i].y+(i%2 == 0 ? -0.1 : 0.08))) }
  if let i=second.marks.firstIndex(where:{$0.kind == "ball"}) { second.marks[i].x=0.62; second.marks[i].y=0.24 }
  var third=second; third.id=UUID(); for i in third.marks.indices where third.marks[i].kind == "home" { third.marks[i].x=min(0.92,third.marks[i].x+0.06) }
  let k=min(5,max(0,n)); return ZbPlay(titleKey:titles[k],sport:s,noteKey:descriptions[k],steps:[first,second,third])
 }
}

struct ZbPitch: View {
 var sport: ZbSport; var step: ZbStep; var selected: UUID? = nil
 var body: some View {
  Canvas { c, s in
   let m=zInset(s.width), unit=max(0.35,min(1.5,s.width/370))
   let r=CGRect(x:m,y:m,width:max(1,s.width-2*m),height:max(1,s.height-2*m))
   func p(_ x:Double,_ y:Double)->CGPoint { CGPoint(x:r.minX+r.width*x,y:r.minY+r.height*y) }
   let surface: Color
   switch sport {
   case .football: surface = Color(red:0.075, green:0.36, blue:0.245)
   case .futsal: surface = Color(red:0.08, green:0.34, blue:0.43)
   case .basketball: surface = Color(red:0.55, green:0.29, blue:0.14)
   }
   c.fill(Path(roundedRect:CGRect(origin:.zero,size:s),cornerRadius:9*unit),with:.color(surface))
   for i in 0..<10 where i.isMultiple(of:2) {
    c.fill(Path(CGRect(x:r.minX+r.width*Double(i)/10,y:r.minY,width:r.width/10,height:r.height)),with:.color(.white.opacity(0.064)))
   }
   if s.width > 200 {
    var ticks=Path()
    for i in 0...50 {
     let x = r.minX + r.width * CGFloat(i) / 50
     let length: CGFloat = i.isMultiple(of:5) ? 4 * unit : 2 * unit
     ticks.move(to: CGPoint(x:x,y:r.minY-2*unit)); ticks.addLine(to:CGPoint(x:x,y:r.minY-2*unit-length))
     ticks.move(to: CGPoint(x:x,y:r.maxY+2*unit)); ticks.addLine(to:CGPoint(x:x,y:r.maxY+2*unit+length))
    }
    c.stroke(ticks,with:.color(.white.opacity(0.38)),lineWidth:unit)
   }
   var f=Path(); f.addRect(r); f.move(to:p(0.5,0)); f.addLine(to:p(0.5,1))
   f.addEllipse(in:CGRect(x:r.midX-r.height*0.16,y:r.midY-r.height*0.16,width:r.height*0.32,height:r.height*0.32))
   if sport == .basketball {
    for left in [true,false] {
     let x=left ? 0.0 : 0.76; f.addRect(CGRect(x:p(x,0.28).x,y:p(x,0.28).y,width:r.width*0.24,height:r.height*0.44))
     let a=p(left ? 0.11 : 0.89,0.5); f.addEllipse(in:CGRect(x:a.x-5*unit,y:a.y-5*unit,width:10*unit,height:10*unit))
     let start=p(left ? 0.06 : 0.94,0.13), end=p(left ? 0.06 : 0.94,0.87)
     f.move(to:start); f.addQuadCurve(to:end,control:p(left ? 0.64 : 0.36,0.5))
    }
   } else {
    for left in [true,false] {
     let x=left ? 0.0 : 0.84
     if sport == .football { f.addRect(CGRect(x:p(x,0.22).x,y:p(x,0.22).y,width:r.width*0.16,height:r.height*0.56)); f.addRect(CGRect(x:p(left ? 0 : 0.94,0.36).x,y:p(x,0.36).y,width:r.width*0.06,height:r.height*0.28)) }
     else { f.move(to:p(left ? 0 : 1,0.22)); f.addQuadCurve(to:p(left ? 0 : 1,0.78),control:p(left ? 0.29 : 0.71,0.5)) }
     let xx=left ? r.minX-6*unit : r.maxX
     f.addRect(CGRect(x:xx,y:r.midY-r.height*0.09,width:6*unit,height:r.height*0.18))
    }
   }
   c.stroke(f,with:.color(.white.opacity(0.70)),lineWidth:1.35*unit)
   c.fill(Path(ellipseIn:CGRect(x:r.midX-2*unit,y:r.midY-2*unit,width:4*unit,height:4*unit)),with:.color(.white.opacity(0.6)))
   for l in step.lines {
    let a=p(l.x,l.y), b=p(l.u,l.v)
    if l.kind == "zone" { let rr=CGRect(x:min(a.x,b.x),y:min(a.y,b.y),width:abs(b.x-a.x),height:abs(b.y-a.y)); c.fill(Path(roundedRect:rr,cornerRadius:6*unit),with:.color(zLime.opacity(0.14))); c.stroke(Path(roundedRect:rr,cornerRadius:6*unit),with:.color(zLime.opacity(0.7)),style:StrokeStyle(lineWidth:1.5*unit,dash:[5*unit,4*unit])) }
    else {
     var path=Path(); path.move(to:a); path.addLine(to:b)
     c.stroke(path,with:.color(zLime),style:StrokeStyle(lineWidth:2.4*unit,lineCap:.round,dash:l.kind == "run" ? [6*unit,5*unit] : []))
     let ang=atan2(b.y-a.y,b.x-a.x); var head=Path(); head.move(to:CGPoint(x:b.x-10*unit*cos(ang-0.48),y:b.y-10*unit*sin(ang-0.48))); head.addLine(to:b); head.addLine(to:CGPoint(x:b.x-10*unit*cos(ang+0.48),y:b.y-10*unit*sin(ang+0.48)))
     c.stroke(head,with:.color(zLime),style:StrokeStyle(lineWidth:2.4*unit,lineCap:.round,lineJoin:.round))
    }
   }
   let radius=max(3.5,min(25,s.width*0.031))
   for m in step.marks {
    let a=p(m.x,m.y); let rr=CGRect(x:a.x-radius,y:a.y-radius,width:radius*2,height:radius*2)
    if selected == m.id { c.stroke(Path(ellipseIn:rr.insetBy(dx:-5*unit,dy:-5*unit)),with:.color(.white),style:StrokeStyle(lineWidth:2*unit,dash:[3*unit,3*unit])) }
    if m.kind == "cone" {
     var tr=Path(); tr.move(to:CGPoint(x:a.x,y:a.y-radius)); tr.addLine(to:CGPoint(x:a.x-radius,y:a.y+radius)); tr.addLine(to:CGPoint(x:a.x+radius,y:a.y+radius)); tr.closeSubpath(); c.fill(tr,with:.color(.orange))
    } else {
     c.fill(Path(ellipseIn:rr.offsetBy(dx:0,dy:2*unit)),with:.color(.black.opacity(0.46)))
     c.fill(Path(ellipseIn:rr),with:.color(m.kind == "home" ? zLime : m.kind == "away" ? zAway : .white))
     c.stroke(Path(ellipseIn:rr),with:.color(.black.opacity(0.74)),lineWidth:1.4*unit)
     if radius>=6 {let label=m.kind == "ball" ? "•" : "\(m.number)";c.draw(Text(label).font(.system(size:radius*1.12,weight:.black,design:.rounded)).foregroundColor(zCoal),at:a)}
    }
   }
  }.accessibilityLabel(zTxt("Tactical board") + ", " + sport.name).accessibilityValue(zCounts(step))
 }
}
