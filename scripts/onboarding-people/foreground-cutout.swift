import AppKit
import Vision
import CoreImage
import Foundation

let args = CommandLine.arguments
guard args.count == 3 else { fatalError("input output") }
let input = URL(fileURLWithPath: args[1])
let output = URL(fileURLWithPath: args[2])
let source = CGImageSourceCreateWithURL(input as CFURL, nil)!
let image = CGImageSourceCreateImageAtIndex(source, 0, nil)!
let handler = VNImageRequestHandler(cgImage: image, options: [:])
let request = VNGenerateForegroundInstanceMaskRequest()
try handler.perform([request])
guard let observation = request.results?.first, !observation.allInstances.isEmpty else { fatalError("No foreground mask") }
let buffer = try observation.generateScaledMaskForImage(forInstances: observation.allInstances, from: handler)
let mask = CIImage(cvPixelBuffer: buffer)
let original = CIImage(cgImage: image)
let clear = CIImage(color: .clear).cropped(to: original.extent)
let result = original.applyingFilter("CIBlendWithMask", parameters: [kCIInputBackgroundImageKey: clear, kCIInputMaskImageKey: mask])
let context = CIContext(options: [.useSoftwareRenderer: false])
let rendered = context.createCGImage(result, from: original.extent)!
let png = NSBitmapImageRep(cgImage: rendered).representation(using: .png, properties: [:])!
try png.write(to: output)
print("Saved \(image.width)x\(image.height), foreground instances \(observation.allInstances.count)")
