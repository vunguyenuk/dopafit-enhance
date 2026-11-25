import AppKit
import CoreImage
import Foundation
let a=CommandLine.arguments
let im=NSImage(contentsOfFile:a[1])!;let raw=NSBitmapImageRep(data:im.tiffRepresentation!)!
let w=raw.pixelsWide,h=raw.pixelsHigh
var minX=w,minY=h,maxX=0,maxY=0
let limit=a.count>3 ? Int(Double(h)*Double(a[3])!) : h
for y in 0..<min(h,limit){for x in 0..<w{if raw.colorAt(x:x,y:y)!.alphaComponent > 0.04{minX=min(minX,x);maxX=max(maxX,x);minY=min(minY,y);maxY=max(maxY,y)}}}
let cg=raw.cgImage!.cropping(to:CGRect(x:max(0,minX-5),y:max(0,minY-5),width:min(w-minX,maxX-minX+11),height:min(limit-minY,maxY-minY+6)))!
try NSBitmapImageRep(cgImage:cg).representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:a[2]))
print("Trimmed \(cg.width)x\(cg.height)")
