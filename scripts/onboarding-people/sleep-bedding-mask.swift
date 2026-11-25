import AppKit
import Foundation
let source=NSImage(contentsOfFile:CommandLine.arguments[1])!
let person=NSImage(contentsOfFile:CommandLine.arguments[2])!
let w:CGFloat=1200,h:CGFloat=800
let rep=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:1200,pixelsHigh:800,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=NSGraphicsContext(bitmapImageRep:rep)
func point(_ x:CGFloat,_ y:CGFloat)->NSPoint{NSPoint(x:x,y:h-y)}
let path=NSBezierPath();path.move(to:point(102,333));path.curve(to:point(260,333),controlPoint1:point(115,292),controlPoint2:point(210,320));path.curve(to:point(670,370),controlPoint1:point(410,350),controlPoint2:point(570,358));path.curve(to:point(722,506),controlPoint1:point(748,405),controlPoint2:point(756,465));path.curve(to:point(620,675),controlPoint1:point(695,565),controlPoint2:point(700,640));path.curve(to:point(224,583),controlPoint1:point(515,660),controlPoint2:point(310,613));path.curve(to:point(102,333),controlPoint1:point(138,530),controlPoint2:point(115,432));path.close();NSGraphicsContext.saveGraphicsState();path.addClip();source.draw(in:NSRect(x:0,y:0,width:w,height:h));NSGraphicsContext.restoreGraphicsState();person.draw(in:NSRect(x:0,y:0,width:w,height:h));NSGraphicsContext.restoreGraphicsState()
try rep.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:CommandLine.arguments[3]))
