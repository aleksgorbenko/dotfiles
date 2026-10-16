import AppKit

struct Options {
    var input: String?
    var text: String?
    var output = ""
    var size = 1024
    var background: CGColor?
    var radius = 0.2237
    var inset = 0.0
    var glyph = 0.56
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("icon-compose: \(message)\n".utf8))
    exit(1)
}

func colour(_ hex: String) -> CGColor? {
    guard hex != "none" else { return nil }
    guard hex.hasPrefix("#"), hex.count == 7, let value = Int(hex.dropFirst(), radix: 16) else {
        fail("colour must be #RRGGBB or none, got \(hex)")
    }
    return CGColor(
        srgbRed: CGFloat((value >> 16) & 0xFF) / 255,
        green: CGFloat((value >> 8) & 0xFF) / 255,
        blue: CGFloat(value & 0xFF) / 255,
        alpha: 1
    )
}

func parse(_ arguments: [String]) -> Options {
    var options = Options()
    var index = 1
    func value() -> String {
        index += 1
        guard index < arguments.count else { fail("missing value for \(arguments[index - 1])") }
        return arguments[index]
    }
    func number(_ text: String) -> Double {
        guard let parsed = Double(text) else { fail("not a number: \(text)") }
        return parsed
    }
    while index < arguments.count {
        switch arguments[index] {
        case "--input": options.input = value()
        case "--text": options.text = value()
        case "--output": options.output = value()
        case "--size": options.size = Int(number(value()))
        case "--bg": options.background = colour(value())
        case "--radius": options.radius = number(value())
        case "--inset": options.inset = number(value())
        case "--glyph": options.glyph = number(value())
        default: fail("unknown argument \(arguments[index])")
        }
        index += 1
    }
    guard !options.output.isEmpty, (options.input == nil) != (options.text == nil) else {
        fail("usage: compose (--input FILE | --text STRING) --output FILE [--size N] [--bg COLOUR] [--radius F] [--inset F] [--glyph F]")
    }
    return options
}

func bitmapContext(width: Int, height: Int) -> CGContext {
    guard let space = CGColorSpace(name: CGColorSpace.sRGB),
          let context = CGContext(
              data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
              space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
          )
    else { fail("cannot create bitmap context") }
    context.interpolationQuality = .high
    return context
}

func rasterise(draw: (NSRect) -> Void) -> CGImage {
    let canvas = 2048
    let context = bitmapContext(width: canvas, height: canvas)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    draw(NSRect(x: 0, y: 0, width: canvas, height: canvas))
    NSGraphicsContext.restoreGraphicsState()
    guard let image = context.makeImage() else { fail("cannot rasterise source") }
    return image
}

func sourceImage(_ options: Options) -> CGImage {
    if let text = options.text {
        return rasterise { rect in
            let font = NSFont(name: "Apple Color Emoji", size: rect.height * 0.7) ?? .systemFont(ofSize: rect.height * 0.7)
            let string = NSAttributedString(string: text, attributes: [.font: font])
            let bounds = string.size()
            string.draw(at: NSPoint(x: (rect.width - bounds.width) / 2, y: (rect.height - bounds.height) / 2))
        }
    }
    guard let path = options.input, let image = NSImage(contentsOfFile: path) else {
        fail("cannot read \(options.input ?? "")")
    }
    let isVector = image.representations.contains { !($0 is NSBitmapImageRep) }
    if !isVector, let bitmap = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
        return bitmap
    }
    return rasterise { rect in image.draw(in: rect) }
}

func trimmed(_ image: CGImage) -> CGImage {
    let width = image.width, height = image.height
    let context = bitmapContext(width: width, height: height)
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let data = context.data else { fail("cannot read pixels") }
    let pixels = data.bindMemory(to: UInt8.self, capacity: context.bytesPerRow * height)
    var minX = width, minY = height, maxX = -1, maxY = -1
    for y in 0..<height {
        for x in 0..<width where pixels[y * context.bytesPerRow + x * 4 + 3] > 0 {
            minX = min(minX, x); maxX = max(maxX, x)
            minY = min(minY, y); maxY = max(maxY, y)
        }
    }
    guard maxX >= minX else { fail("source has no visible pixels") }
    guard let cropped = context.makeImage()?.cropping(
        to: CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    ) else { fail("cannot crop source") }
    return cropped
}

let options = parse(CommandLine.arguments)
let glyph = trimmed(sourceImage(options))
let side = Double(options.size)
let context = bitmapContext(width: options.size, height: options.size)

if let background = options.background {
    let rect = CGRect(x: 0, y: 0, width: side, height: side).insetBy(dx: side * options.inset, dy: side * options.inset)
    let corner = min(side * options.radius, rect.width / 2)
    context.addPath(CGPath(roundedRect: rect, cornerWidth: corner, cornerHeight: corner, transform: nil))
    context.setFillColor(background)
    context.fillPath()
}

let scale = side * options.glyph / Double(max(glyph.width, glyph.height))
let width = Double(glyph.width) * scale
let height = Double(glyph.height) * scale
context.draw(glyph, in: CGRect(x: (side - width) / 2, y: (side - height) / 2, width: width, height: height))

guard let rendered = context.makeImage(),
      let png = NSBitmapImageRep(cgImage: rendered).representation(using: .png, properties: [:])
else { fail("cannot encode PNG") }
do {
    try FileManager.default.createDirectory(
        at: URL(fileURLWithPath: options.output).deletingLastPathComponent(), withIntermediateDirectories: true
    )
    try png.write(to: URL(fileURLWithPath: options.output))
} catch {
    fail("cannot write \(options.output)")
}
