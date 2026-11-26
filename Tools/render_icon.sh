#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export CLANG_MODULE_CACHE_PATH="$PWD/Artifacts/ModuleCache"
swift -module-cache-path "$PWD/Artifacts/ModuleCache" -e '
import AppKit
import ImageIO
let colorSpace=CGColorSpace(name:CGColorSpace.sRGB)!
let surface=CGContext(data:nil,width:1024,height:1024,bitsPerComponent:8,bytesPerRow:0,space:colorSpace,bitmapInfo:CGImageAlphaInfo.noneSkipLast.rawValue)!
NSGraphicsContext.current=NSGraphicsContext(cgContext:surface,flipped:false)
let bg=NSBezierPath(rect:NSRect(x:0,y:0,width:1024,height:1024))
NSGradient(starting:NSColor(red:0.1,green:0.14,blue:0.16,alpha:1),ending:NSColor(red:0.035,green:0.05,blue:0.07,alpha:1))!.draw(in:bg,angle:70)
let lime=NSColor(red:205/255,green:1,blue:61/255,alpha:1)
let board=NSBezierPath(roundedRect:NSRect(x:119,y:154,width:786,height:716),xRadius:58,yRadius:58)
NSColor(red:0.08,green:0.15,blue:0.14,alpha:1).setFill();board.fill();NSColor.white.withAlphaComponent(0.28).setStroke();board.lineWidth=9;board.stroke()
let lines=NSBezierPath();lines.move(to:NSPoint(x:119,y:512));lines.line(to:NSPoint(x:905,y:512));lines.appendOval(in:NSRect(x:407,y:407,width:210,height:210));lines.appendRect(NSRect(x:385,y:154,width:254,height:100));lines.appendRect(NSRect(x:385,y:770,width:254,height:100));lines.lineWidth=8;lines.stroke()
func arrow(_ a:NSPoint,_ b:NSPoint){let p=NSBezierPath();p.move(to:a);p.line(to:b);let t=atan2(b.y-a.y,b.x-a.x);p.move(to:NSPoint(x:b.x-59*cos(t-0.55),y:b.y-59*sin(t-0.55)));p.line(to:b);p.line(to:NSPoint(x:b.x-59*cos(t+0.55),y:b.y-59*sin(t+0.55)));p.lineWidth=23;p.lineCapStyle = .round;p.lineJoinStyle = .round;lime.setStroke();p.stroke()}
arrow(NSPoint(x:318,y:325),NSPoint(x:536,y:545));arrow(NSPoint(x:580,y:589),NSPoint(x:746,y:710))
for (x,y,color) in [(275.0,290.0,lime),(571,583,lime),(754,340,NSColor.white),(312,722,NSColor.white)] {
 NSColor.black.withAlphaComponent(0.35).setFill();NSBezierPath(ovalIn:NSRect(x:x-50,y:y-60,width:112,height:112)).fill()
 color.setFill();NSBezierPath(ovalIn:NSRect(x:x-55,y:y-55,width:110,height:110)).fill()
 NSColor.black.withAlphaComponent(0.12).setStroke();let ring=NSBezierPath(ovalIn:NSRect(x:x-36,y:y-36,width:72,height:72));ring.lineWidth=6;ring.stroke()
}
NSColor.white.setFill();NSBezierPath(ovalIn:NSRect(x:681,y:580,width:36,height:36)).fill()
let dest=URL(fileURLWithPath:CommandLine.arguments[1]) as CFURL
let writer=CGImageDestinationCreateWithURL(dest,"public.png" as CFString,1,nil)!
CGImageDestinationAddImage(writer,surface.makeImage()!,nil)
precondition(CGImageDestinationFinalize(writer))
' "$PWD/CoachBoard/OrbitMarks.xcassets/OrbitIcon.appiconset/OrbitIcon.png"
