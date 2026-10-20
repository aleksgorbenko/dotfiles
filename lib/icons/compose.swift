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
    var style = "flat"
    var source = "glyph"
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
        case "--style": options.style = value()
        case "--source": options.source = value()
        default: fail("unknown argument \(arguments[index])")
        }
        index += 1
    }
    guard !options.output.isEmpty, (options.input == nil) != (options.text == nil),
          ["flat", "macos"].contains(options.style), ["glyph", "logo", "whole"].contains(options.source)
    else {
        fail("usage: compose (--input FILE | --text STRING) --output FILE [--size N] [--bg COLOUR] [--radius F] [--inset F] [--glyph F] [--style flat|macos] [--source glyph|logo|whole]")
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

struct RGB {
    var red: Double
    var green: Double
    var blue: Double

    func mixed(with other: RGB, _ amount: Double) -> RGB {
        RGB(
            red: self.red + (other.red - self.red) * amount,
            green: self.green + (other.green - self.green) * amount,
            blue: self.blue + (other.blue - self.blue) * amount
        )
    }

    var cgColor: CGColor { CGColor(srgbRed: self.red, green: self.green, blue: self.blue, alpha: 1) }

    static let white = RGB(red: 1, green: 1, blue: 1)
    static let black = RGB(red: 0, green: 0, blue: 0)
}

func rgb(_ colour: CGColor) -> RGB {
    let parts = colour.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil)?.components ?? [0, 0, 0]
    return RGB(red: parts[0], green: parts[1], blue: parts[2])
}

func squircle(in rect: CGRect, exponent: Double = 5) -> CGPath {
    let path = CGMutablePath()
    let radius = rect.width / 2
    let steps = 720
    for step in 0..<steps {
        let angle = 2 * Double.pi * Double(step) / Double(steps)
        let cosine = cos(angle), sine = sin(angle)
        let x = rect.midX + radius * pow(abs(cosine), 2 / exponent) * (cosine < 0 ? -1 : 1)
        let y = rect.midY + radius * pow(abs(sine), 2 / exponent) * (sine < 0 ? -1 : 1)
        if step == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
    }
    path.closeSubpath()
    return path
}

struct Pixels {
    let width: Int
    let height: Int
    let bytesPerRow: Int
    let data: UnsafeMutablePointer<UInt8>
    let context: CGContext

    init(_ image: CGImage, size: Int) {
        self.width = size
        self.height = size
        self.context = bitmapContext(width: size, height: size)
        self.context.draw(image, in: CGRect(x: 0, y: 0, width: size, height: size))
        self.bytesPerRow = self.context.bytesPerRow
        guard let raw = self.context.data else { fail("cannot read pixels") }
        self.data = raw.bindMemory(to: UInt8.self, capacity: self.bytesPerRow * size)
    }

    func colour(atX fractionX: Double, y fractionY: Double) -> RGB {
        let x = Int(fractionX * Double(self.width - 1)), y = Int(fractionY * Double(self.height - 1))
        let offset = y * self.bytesPerRow + x * 4
        let alpha = max(Double(self.data[offset + 3]), 1)
        return RGB(
            red: Double(self.data[offset]) / alpha,
            green: Double(self.data[offset + 1]) / alpha,
            blue: Double(self.data[offset + 2]) / alpha
        )
    }
}

func extractedLogo(_ image: CGImage, size: Int, top: RGB, bottom: RGB, threshold: Double = 60) -> CGImage {
    let pixels = Pixels(image, size: size)
    let inset = Double(size) * 0.02, corner = Double(size) * 0.2
    for y in 0..<size {
        let background = top.mixed(with: bottom, Double(y) / Double(size - 1))
        for x in 0..<size {
            let offset = y * pixels.bytesPerRow + x * 4
            let alpha = Double(pixels.data[offset + 3])
            guard alpha > 0 else { continue }
            let red = Double(pixels.data[offset]) / alpha
            let green = Double(pixels.data[offset + 1]) / alpha
            let blue = Double(pixels.data[offset + 2]) / alpha
            let difference = 255 * (0.299 * abs(red - background.red) + 0.587 * abs(green - background.green)
                + 0.114 * abs(blue - background.blue))
            var keep = min(1, difference / threshold) * alpha / 255
            let dx = max(0, max(inset + corner - Double(x), Double(x) - (Double(size) - inset - corner)))
            let dy = max(0, max(inset + corner - Double(y), Double(y) - (Double(size) - inset - corner)))
            if dx * dx + dy * dy > corner * corner { keep = 0 }
            pixels.data[offset] = UInt8(red * keep * 255)
            pixels.data[offset + 1] = UInt8(green * keep * 255)
            pixels.data[offset + 2] = UInt8(blue * keep * 255)
            pixels.data[offset + 3] = UInt8(keep * 255)
        }
    }
    guard let extracted = pixels.context.makeImage() else { fail("cannot extract logo") }
    return extracted
}

func drawMacOS(options: Options, side: Double, into context: CGContext) {
    let unit = side / 1024
    let shape = CGRect(x: 100 * unit, y: 100 * unit, width: 824 * unit, height: 824 * unit)
    let source = sourceImage(options)

    if options.source == "whole" {
        context.draw(trimmed(source), in: shape)
        return
    }

    var top = RGB.white, bottom = RGB.white
    var glyph: CGImage
    var glyphRect: CGRect
    if options.source == "logo" {
        let pixels = Pixels(trimmed(source), size: 512)
        top = options.background.map(rgb) ?? pixels.colour(atX: 0.5, y: 0.06)
        bottom = options.background.map(rgb) ?? pixels.colour(atX: 0.5, y: 0.94)
        glyph = extractedLogo(trimmed(source), size: 1024, top: top, bottom: bottom)
        glyphRect = shape
    } else {
        top = options.background.map(rgb) ?? .white
        bottom = top
        glyph = trimmed(source)
        let scale = shape.width * options.glyph / Double(max(glyph.width, glyph.height))
        let width = Double(glyph.width) * scale, height = Double(glyph.height) * scale
        glyphRect = CGRect(x: shape.midX - width / 2, y: shape.midY - height / 2, width: width, height: height)
    }

    let path = squircle(in: shape)
    let space = CGColorSpace(name: CGColorSpace.sRGB)!

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -12 * unit), blur: 28 * unit,
                      color: CGColor(gray: 0, alpha: 0.3))
    context.addPath(path)
    context.setFillColor(bottom.cgColor)
    context.fillPath()
    context.restoreGState()

    context.saveGState()
    context.addPath(path)
    context.clip()
    let fill = CGGradient(colorsSpace: space, colors: [
        top.mixed(with: .white, 0.18).cgColor, bottom.mixed(with: .black, 0.12).cgColor,
    ] as CFArray, locations: [0, 1])!
    context.drawLinearGradient(fill, start: CGPoint(x: 0, y: shape.maxY), end: CGPoint(x: 0, y: shape.minY), options: [])

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -6 * unit), blur: 12 * unit,
                      color: CGColor(gray: 0, alpha: 0.28))
    context.draw(glyph, in: glyphRect)
    context.restoreGState()

    context.addPath(path)
    context.setLineWidth(5 * unit)
    context.replacePathWithStrokedPath()
    context.clip()
    let rim = CGGradient(colorsSpace: space, colors: [
        CGColor(gray: 1, alpha: 0.45), CGColor(gray: 1, alpha: 0),
    ] as CFArray, locations: [0, 1])!
    context.drawLinearGradient(rim, start: CGPoint(x: 0, y: shape.maxY), end: CGPoint(x: 0, y: shape.minY), options: [])
    context.restoreGState()
}

let options = parse(CommandLine.arguments)
let side = Double(options.size)
let context = bitmapContext(width: options.size, height: options.size)

if options.style == "macos" {
    drawMacOS(options: options, side: side, into: context)
} else {
    let glyph = trimmed(sourceImage(options))
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
}

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
