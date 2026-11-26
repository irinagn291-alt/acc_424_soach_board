import SwiftUI
import WidgetKit

struct ZbMinute:TimelineEntry {var date:Date;var book:ZbBook?}
struct ZbClock:TimelineProvider {
 func placeholder(in context:Context)->ZbMinute{ZbMinute(date:Date(),book:nil)}
 func getSnapshot(in context:Context,completion:@escaping(ZbMinute)->Void){completion(ZbMinute(date:Date(),book:read()))}
 func getTimeline(in context:Context,completion:@escaping(Timeline<ZbMinute>)->Void){
  let b=read(), now=Date();var dates=[now]
  for i in 1...24 {dates.append(now.addingTimeInterval(Double(i)*3600))}
  if let midnight=Calendar.current.nextDate(after:now,matching:DateComponents(hour:0),matchingPolicy:.nextTime){dates.append(midnight)}
  for s in b?.sessions ?? [] where s.date>now && s.date<now.addingTimeInterval(86400){dates.append(s.date.addingTimeInterval(1))}
  completion(Timeline(entries:dates.sorted().map{ZbMinute(date:$0,book:b)},policy:.after(now.addingTimeInterval(3600))))
 }
 func read()->ZbBook? {guard let u=FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:zGroup)?.appendingPathComponent("glance.json"),let d=try? Data(contentsOf:u),let b=try? JSONDecoder().decode(ZbBook.self,from:d),!b.plays.isEmpty else{return nil};return b}
}
struct ZbGlance:View {
 let entry:ZbMinute
 @Environment(\.widgetFamily) private var systemFamily
 var previewFamily:WidgetFamily? = nil
 var family:WidgetFamily { previewFamily ?? systemFamily }
 var b:ZbBook?{entry.book}
 var next:ZbSession?{b?.next(entry.date)}
 var latest:ZbPlay?{b?.plays.max(by:{$0.revised<$1.revised})}
 var planPlay:ZbPlay?{if let id=next?.drills.first,let p=b?.plays.first(where:{$0.id==id}){return p};return latest}
 var tomorrow:ZbSession?{b?.sessions.filter{!$0.done && Calendar.current.isDateInTomorrowAt($0.date,reference:entry.date)}.sorted{$0.date<$1.date}.first}
 var week:[ZbSession]{let end=Calendar.current.date(byAdding:.day,value:7,to:entry.date) ?? entry.date;return b?.sessions.filter{!$0.done && $0.date>=entry.date && $0.date<end}.sorted{$0.date<$1.date} ?? []}
 var body:some View {
  Group{
   switch family {
   case .accessoryInline:Text(zTxt(tomorrow==nil ? "No training tomorrow" : "Training tomorrow")+(tomorrow.map{" · "+$0.date.formatted(date:.omitted,time:.shortened)} ?? ""))
   case .accessoryCircular:VStack(spacing:2){Image(systemName:"sportscourt");Text(tomorrow?.date.formatted(.dateTime.hour().minute()) ?? "—").font(.caption2)}.accessibilityLabel(zTxt(tomorrow==nil ? "No training tomorrow" : "Training tomorrow"))
   case .accessoryRectangular:VStack(alignment:.leading){Text(zTxt(tomorrow==nil ? "No training tomorrow" : "Training tomorrow")).font(.caption.bold()).lineLimit(1);if let s=tomorrow{Text(s.title).lineLimit(1);Text(s.date,style:.time)}else{Text(zTxt("Open your training plan")).font(.caption)}}
   case .systemSmall:VStack(alignment:.leading,spacing:7){brand("Latest tactic");if let p=latest{ZbPitch(sport:p.sport,step:p.steps[0]);Text(p.title).font(.caption.bold()).lineLimit(1)}else{empty}}
   case .systemMedium:HStack(spacing:14){VStack(alignment:.leading,spacing:8){brand("Next training");if let n=next{Text(n.title).font(.headline).lineLimit(2);Text(n.date,format:.dateTime.weekday(.abbreviated).hour().minute()).font(.caption).foregroundStyle(zLime);Text("\(n.minutes) "+zTxt("min")).font(.caption2).foregroundStyle(.secondary)}else{Text(zTxt("No upcoming training")).font(.headline);Text(zTxt("Open your training plan")).font(.caption).foregroundStyle(.secondary)}}.frame(maxWidth:.infinity,alignment:.leading);if let p=planPlay{ZbPitch(sport:p.sport,step:p.steps[0]).aspectRatio(1.55,contentMode:.fit).frame(maxWidth:.infinity)} }
   default:VStack(alignment:.leading,spacing:10){brand("The week ahead");if week.isEmpty{Text(zTxt("No upcoming training")).font(.headline)}else{ForEach(week.prefix(3)){s in HStack{Text(s.date,format:.dateTime.weekday(.abbreviated).day()).font(.caption.monospacedDigit()).foregroundStyle(zLime).frame(width:64,alignment:.leading);VStack(alignment:.leading){Text(s.title).font(.subheadline.bold()).lineLimit(1);Text(s.date,style:.time).font(.caption2).foregroundStyle(.secondary)};Spacer();Text("\(s.minutes) "+zTxt("min")).font(.caption2)}}};Divider();Text(zTxt("Tactic library")).font(.caption.bold());cards;if b==nil{empty};Spacer(minLength:0)}
   }
  }.containerBackground(zCoal,for:.widget).widgetURL(URL(string:family == .systemSmall ? "coachboard://board/"+(latest?.id.uuidString ?? "") : "coachboard://training"))
 }
 var cards:some View {
  let ps=Array((b?.plays ?? []).sorted{$0.revised>$1.revised}.prefix(3));let columns=week.isEmpty ? max(1,ps.count) : 3
  return HStack(alignment:.top,spacing:9){ForEach(0..<columns,id:\.self){i in
   if i<ps.count {let p=ps[i];VStack(alignment:.leading,spacing:5){ZbPitch(sport:p.sport,step:p.steps[0]).aspectRatio(1.55,contentMode:.fit);Text(p.title).font(.system(size:10,weight:.semibold)).lineLimit(1)}.frame(maxWidth:.infinity,alignment:.leading)}
   else {Color.clear.frame(height:1).frame(maxWidth:.infinity).accessibilityHidden(true)}
  }}
 }
 var empty:some View{VStack(alignment:.leading,spacing:8){Image(systemName:"sportscourt").font(.largeTitle).foregroundStyle(zLime);Text(zTxt("Open Soach Board")).font(.caption.bold());Text(zTxt("Save a tactic to see it here.")).font(.caption2).foregroundStyle(.secondary)}}
 func brand(_ text:String)->some View{HStack{Image(systemName:"sportscourt").foregroundStyle(zLime);Text(zTxt(text)).font(.system(.caption,design:.rounded,weight:.bold));Spacer(minLength:0)}}
}
extension Calendar {func isDateInTomorrowAt(_ d:Date,reference:Date)->Bool{guard let t=date(byAdding:.day,value:1,to:reference)else{return false};return isDate(d,inSameDayAs:t)}}
#if ZB_WIDGET
@main struct ZbWidgets:Widget {
 var body:some WidgetConfiguration{StaticConfiguration(kind:"ChalkOrbitGlance",provider:ZbClock()){ZbGlance(entry:$0)}.configurationDisplayName("Soach Board").description(zTxt("Your latest tactic and training plan, saved on this device.")).supportedFamilies([.systemSmall,.systemMedium,.systemLarge,.accessoryInline,.accessoryCircular,.accessoryRectangular])}
}

#endif
#if !ZB_WIDGET
struct ZbWidgetGallery:View {
 @ObservedObject var p:ZbPocket
 var body:some View{ScrollView{VStack(alignment:.leading,spacing:24){
  Text(zTxt("Widgets use your saved local data.")).font(.subheadline).foregroundStyle(.secondary)
  sample(.systemSmall,160,170,"Small")
  sample(.systemMedium,340,170,"Medium")
  sample(.systemLarge,340,360,"Large")
  sample(.accessoryRectangular,260,96,"Lock Screen")
 }.padding()}.background(zCoal).navigationTitle(zTxt("Widget previews"))}
 func sample(_ family:WidgetFamily,_ w:CGFloat,_ h:CGFloat,_ title:String)->some View{VStack(alignment:.leading,spacing:8){Text(zTxt(title)).font(.headline);ZbGlance(entry:ZbMinute(date:Date(),book:p.book),previewFamily:family).padding(14).frame(width:w,height:h).background(zPanel,in:RoundedRectangle(cornerRadius:20)).clipped().accessibilityIdentifier("widget-"+title)}}
}
#endif
