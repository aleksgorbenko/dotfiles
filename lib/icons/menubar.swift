// Turn a flat, single-colour glyph (typically black-on-white) into a macOS menu-bar
// TEMPLATE image set: a black silhouette + alpha channel that the system re-tints for
// light/dark/active. Only the alpha matters - the RGB is forced to black.
//
// Technique: luminance -> alpha (white background & interior gaps become transparent,
// anti-aliased edges become partial alpha), then trim to the glyph, pad, and downscale
// to 1x/2x/3x. Not for multi-colour art or photos - those aren't template material.
//
// Usage:
//   icon-menubar.sh <input.png> <output.imageset> [height=18]
//
// Writes icon.png / icon@2x.png / icon@3x.png + a template-rendering Contents.json into
// the output image set directory (created if needed). Point NSImage(named:) at the set
// name and set isTemplate = true.

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("\(message)\n".utf8))
    exit(1)
}

guard CommandLine.arguments.count >= 3 else {
    FileHandle.standardError.write(
        Data("usage: icon-menubar.sh <input.png> <output.imageset> [height=18]\n".utf8))
    exit(2)
}
let srcPath = CommandLine.arguments[1]
let outDir = CommandLine.arguments[2]
let baseHeight = CommandLine.arguments.count >= 4 ? (Int(CommandLine.arguments[3]) ?? 18) : 18

guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: srcPath) as CFURL, nil),
    let img = CGImageSourceCreateImageAtIndex(src, 0, nil)
else {
    FileHandle.standardError.write(Data("cannot read source image: \(srcPath)\n".utf8))
    exit(1)
}

let width = img.width, height = img.height
let cs = CGColorSpaceCreateDeviceRGB()
let info = CGImageAlphaInfo.premultipliedLast.rawValue
var px = [UInt8](repeating: 0, count: width * height * 4)
guard
    let ctx = CGContext(
        data: &px, width: width, height: height, bitsPerComponent: 8,
        bytesPerRow: width * 4, space: cs, bitmapInfo: info)
else { fail("cannot create a bitmap context for the source image") }
ctx.draw(img, in: CGRect(x: 0, y: 0, width: width, height: height))

// Luminance -> alpha; force colour black. Track the glyph's bounding box.
var minX = width, minY = height, maxX = -1, maxY = -1
for y in 0..<height {
    for x in 0..<width {
        let pixelIndex = (y * width + x) * 4
        let gray = (Int(px[pixelIndex]) + Int(px[pixelIndex + 1]) + Int(px[pixelIndex + 2])) / 3
        let a = UInt8(255 - gray)
        px[pixelIndex] = 0; px[pixelIndex + 1] = 0; px[pixelIndex + 2] = 0; px[pixelIndex + 3] = a
        if a > 12 {
            if x < minX { minX = x }; if x > maxX { maxX = x }
            if y < minY { minY = y }; if y > maxY { maxY = y }
        }
    }
}
guard maxX >= minX else {
    FileHandle.standardError.write(Data("image has no dark pixels to silhouette\n".utf8))
    exit(1)
}

guard
    let full = CGContext(
        data: &px, width: width, height: height, bitsPerComponent: 8,
        bytesPerRow: width * 4, space: cs, bitmapInfo: info)?.makeImage()
else { fail("cannot render the silhouette") }

// Trim to the glyph, pad ~9% of the larger side so it doesn't kiss the menu-bar edges.
let gw = maxX - minX + 1, gh = maxY - minY + 1
let pad = Int(Double(max(gw, gh)) * 0.09)
let cx = max(0, minX - pad), cy = max(0, minY - pad)
let cw = min(width - cx, gw + pad * 2), ch = min(height - cy, gh + pad * 2)
guard let cropped = full.cropping(to: CGRect(x: cx, y: cy, width: cw, height: ch)) else {
    fail("cannot crop to the glyph")
}

try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

func write(scale: Int, name: String) {
    let th = baseHeight * scale
    let tw = Int((Double(cropped.width) * Double(th) / Double(cropped.height)).rounded())
    var buf = [UInt8](repeating: 0, count: tw * th * 4)
    guard
        let context = CGContext(
            data: &buf, width: tw, height: th, bitsPerComponent: 8,
            bytesPerRow: tw * 4, space: cs, bitmapInfo: info)
    else { fail("cannot create a \(tw)x\(th) bitmap context") }
    context.interpolationQuality = .high
    context.draw(cropped, in: CGRect(x: 0, y: 0, width: tw, height: th))
    guard let out = context.makeImage() else { fail("cannot render \(name)") }
    let url = URL(fileURLWithPath: outDir).appendingPathComponent(name)
    guard let dst = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        fail("cannot write \(url.path)")
    }
    CGImageDestinationAddImage(dst, out, nil)
    CGImageDestinationFinalize(dst)
    print("wrote \(name) \(tw)x\(th)")
}

write(scale: 1, name: "icon.png")
write(scale: 2, name: "icon@2x.png")
write(scale: 3, name: "icon@3x.png")

let contents = """
    {
      "images" : [
        { "filename" : "icon.png", "idiom" : "universal", "scale" : "1x" },
        { "filename" : "icon@2x.png", "idiom" : "universal", "scale" : "2x" },
        { "filename" : "icon@3x.png", "idiom" : "universal", "scale" : "3x" }
      ],
      "info" : { "author" : "xcode", "version" : 1 },
      "properties" : { "template-rendering-intent" : "template" }
    }
    """
try? contents.write(
    toFile: URL(fileURLWithPath: outDir).appendingPathComponent("Contents.json").path,
    atomically: true, encoding: .utf8)
print("wrote Contents.json (template-rendering)")
