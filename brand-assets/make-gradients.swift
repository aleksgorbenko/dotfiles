import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        self.state &+= 0x9E37_79B9_7F4A_7C15
        var value = self.state
        value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
        value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB
        return value ^ (value >> 31)
    }
}

struct Palette {
    let name: String
    let hexColours: [UInt32]
}

struct ImageSize {
    let width: Int
    let height: Int

    var extent: CGRect { CGRect(x: 0, y: 0, width: self.width, height: self.height) }
    var label: String { "\(self.width)x\(self.height)" }

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    init?(_ text: some StringProtocol) {
        let parts = text.split(separator: "x").compactMap { Int($0) }
        guard parts.count == 2, parts[0] > 0, parts[1] > 0 else { return nil }
        self.init(width: parts[0], height: parts[1])
    }
}

struct Options {
    var count = 3
    var seed = UInt64.random(in: 0...UInt64.max)
    var sizes = [ImageSize(width: 3840, height: 2160)]
    var outputDirectory = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Documents/reference/wallpaper")
    var paletteName: String?
    var colours: [UInt32]?
    var format = "png"
    var optimise = true
    var grain: Double = 0.015
    var dpi: Int?
}

let palettes: [Palette] = [
    Palette(name: "sunset", hexColours: [0xFF6B6B, 0xFFB86B, 0xC850C0, 0x4158D0, 0xFFD3A5]),
    Palette(name: "ocean", hexColours: [0x0B1D3A, 0x1E4E79, 0x4FACFE, 0x00C6FB, 0x9CECFB]),
    Palette(name: "aurora", hexColours: [0x1B1464, 0x6A11CB, 0x2575FC, 0x43E97B, 0x38F9D7]),
    Palette(name: "dusk", hexColours: [0x0F0C29, 0x302B63, 0x24243E, 0x8E54E9, 0x4776E6]),
    Palette(name: "pastel", hexColours: [0xE0C3FC, 0x8EC5FC, 0xF5F7FA, 0xFBC2EB, 0xD9E4F5]),
    Palette(name: "peach", hexColours: [0xFFECD2, 0xFCB69F, 0xFF9A9E, 0xFAD0C4, 0xF6D365]),
    Palette(name: "mint", hexColours: [0x84FAB0, 0x8FD3F4, 0xA1C4FD, 0xC2E9FB, 0x5EE7DF]),
    Palette(name: "ember", hexColours: [0x2B1055, 0x7597DE, 0xD53369, 0xDAAE51, 0x3A1C71]),
    Palette(name: "slate", hexColours: [0x232526, 0x414345, 0x6B7A8F, 0x9AA5B1, 0x1C2833]),
    Palette(name: "candy", hexColours: [0xFF5F6D, 0xFFC371, 0xA770EF, 0xFDB99B, 0xCF8BF3]),
    Palette(name: "midnight", hexColours: [0x020024, 0x090979, 0x1A2980, 0x26D0CE, 0x0F2027]),
    Palette(name: "haze", hexColours: [0xD7D2CC, 0xE6DADA, 0xB8C6DB, 0xF5F7FA, 0xC9D6FF]),
]

let usage = """
    usage: swift make-gradients.swift [options]
      --count N              images to generate (default 3)
      --seed N               seed for repeatable output
      --sizes WxH[,WxH…]     render each image at every size (default 3840x2160)
      --palette NAME         one of: \(palettes.map(\.name).joined(separator: ", "))
      --colours HEX[,HEX…]   custom colours; repeat a colour to weight it
      --grain AMOUNT         grain opacity 0…1 (default 0.015)
      --dpi N                write DPI metadata (e.g. 300 for print)
      --format png|jpeg|heic (default png)
      --optimise true|false  pngquant + oxipng for png (default true)
      --out DIR              output folder (default ~/Documents/reference/wallpaper)
    """

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("\(message)\n\(usage)\n".utf8))
    exit(2)
}

func parseOptions() -> Options {
    var options = Options()
    var arguments = CommandLine.arguments.dropFirst().makeIterator()
    while let argument = arguments.next() {
        guard let value = arguments.next() else { fail("missing value for \(argument)") }
        switch argument {
        case "--count": options.count = Int(value) ?? options.count
        case "--seed": options.seed = UInt64(value) ?? options.seed
        case "--sizes":
            let sizes = value.split(separator: ",").compactMap(ImageSize.init)
            guard !sizes.isEmpty else { fail("bad --sizes \(value)") }
            options.sizes = sizes
        case "--palette": options.paletteName = value
        case "--colours":
            let colours = value.split(separator: ",").compactMap {
                UInt32($0.trimmingCharacters(in: CharacterSet(charactersIn: "# ")), radix: 16)
            }
            guard colours.count >= 2 else { fail("--colours needs at least two hex colours") }
            options.colours = colours
        case "--grain": options.grain = Double(value) ?? options.grain
        case "--dpi": options.dpi = Int(value)
        case "--format": options.format = value
        case "--optimise": options.optimise = value != "false"
        case "--out": options.outputDirectory = URL(fileURLWithPath: value)
        default: fail("unknown option \(argument)")
        }
    }
    return options
}

func colour(hex: UInt32, generator: inout SeededGenerator) -> Color {
    let base = NSColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: 1
    )
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    base.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
    let shiftedHue = (hue + CGFloat.random(in: -0.025...0.025, using: &generator) + 1)
        .truncatingRemainder(dividingBy: 1)
    let shiftedSaturation = min(1, max(0, saturation + CGFloat.random(in: -0.08...0.08, using: &generator)))
    let shiftedBrightness = min(1, max(0, brightness + CGFloat.random(in: -0.05...0.05, using: &generator)))
    return Color(hue: shiftedHue, saturation: shiftedSaturation, brightness: shiftedBrightness)
}

func meshPoints(generator: inout SeededGenerator) -> [SIMD2<Float>] {
    let steps: [Float] = [0, 1.0 / 3, 2.0 / 3, 1]
    var points: [SIMD2<Float>] = []
    for (row, y) in steps.enumerated() {
        for (column, x) in steps.enumerated() {
            let isEdgeColumn = column == 0 || column == 3
            let isEdgeRow = row == 0 || row == 3
            let jitterX = isEdgeColumn ? 0 : Float.random(in: -0.2...0.2, using: &generator)
            let jitterY = isEdgeRow ? 0 : Float.random(in: -0.2...0.2, using: &generator)
            points.append(SIMD2(x + jitterX, y + jitterY))
        }
    }
    return points
}

@MainActor
func renderMesh(palette: Palette, size: ImageSize, generator: inout SeededGenerator) -> CGImage? {
    let source = palette.hexColours.shuffled(using: &generator)
    let colours = (0..<16).map { _ in
        colour(hex: source.randomElement(using: &generator) ?? 0, generator: &generator)
    }
    let mesh = MeshGradient(
        width: 4,
        height: 4,
        points: meshPoints(generator: &generator),
        colors: colours,
        smoothsColors: true
    )
    .frame(width: CGFloat(size.width), height: CGFloat(size.height))
    let renderer = ImageRenderer(content: mesh)
    renderer.scale = 1
    return renderer.cgImage
}

func finish(_ image: CGImage, size: ImageSize, grain: Double, generator: inout SeededGenerator) -> CIImage {
    let extent = size.extent
    let reference = Float(max(extent.width, extent.height))
    var output = CIImage(cgImage: image)

    if Double.random(in: 0...1, using: &generator) < 0.6 {
        let twirl = CIFilter.twirlDistortion()
        twirl.inputImage = output.clampedToExtent()
        twirl.center = CGPoint(
            x: CGFloat.random(in: 0.25...0.75, using: &generator) * extent.width,
            y: CGFloat.random(in: 0.25...0.75, using: &generator) * extent.height
        )
        twirl.radius = reference * Float.random(in: 0.3...0.6, using: &generator)
        twirl.angle = Float.random(in: -2.5...2.5, using: &generator)
        output = twirl.outputImage ?? output
    }

    let blur = CIFilter.gaussianBlur()
    blur.inputImage = output.clampedToExtent()
    blur.radius = reference * 0.012
    output = (blur.outputImage ?? output).cropped(to: extent)

    guard grain > 0 else { return output }
    let noise = CIFilter.randomGenerator().outputImage?
        .cropped(to: extent)
        .applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0])
        .applyingFilter("CIColorMatrix", parameters: [
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: grain),
        ])
    if let noise {
        output = noise.composited(over: output).cropped(to: extent)
    }
    return output
}

func write(_ image: CIImage, to url: URL, format: String, context: CIContext, colourSpace: CGColorSpace) throws {
    let quality = [CIImageRepresentationOption(rawValue: kCGImageDestinationLossyCompressionQuality as String): 0.92]
    switch format {
    case "png":
        try context.writePNGRepresentation(of: image, to: url, format: .RGBA8, colorSpace: colourSpace)
    case "heic":
        try context.writeHEIFRepresentation(of: image, to: url, format: .RGBA8, colorSpace: colourSpace, options: quality)
    case "jpeg":
        try context.writeJPEGRepresentation(of: image, to: url, colorSpace: colourSpace, options: quality)
    default:
        fail("unknown format \(format)")
    }
}

func run(_ tool: String, _ arguments: [String]) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = [tool] + arguments
    process.standardOutput = FileHandle.nullDevice
    do {
        try process.run()
        process.waitUntilExit()
        return process.terminationStatus == 0
    } catch {
        return false
    }
}

func optimisePNG(at url: URL) {
    guard run("pngquant", ["--force", "--quality", "70-95", "--speed", "1", "--ext", ".png", url.path]) else {
        FileHandle.standardError.write(Data("pngquant failed or missing (brew install pngquant); kept lossless\n".utf8))
        return
    }
    if !run("oxipng", ["-o", "4", "--strip", "safe", "-q", url.path]) {
        FileHandle.standardError.write(Data("oxipng failed or missing (brew install oxipng)\n".utf8))
    }
}

@MainActor
func main() throws {
    let options = parseOptions()
    let candidates: [Palette]
    if let colours = options.colours {
        candidates = [Palette(name: "custom", hexColours: colours)]
    } else if let name = options.paletteName {
        candidates = palettes.filter { $0.name == name }
        guard !candidates.isEmpty else { fail("unknown palette \(name)") }
    } else {
        candidates = palettes
    }
    try FileManager.default.createDirectory(at: options.outputDirectory, withIntermediateDirectories: true)
    let context = CIContext()
    let colourSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
    var generator = SeededGenerator(seed: options.seed)

    for index in 0..<options.count {
        let imageSeed = generator.next()
        for size in options.sizes {
            var imageGenerator = SeededGenerator(seed: imageSeed)
            let palette = candidates.randomElement(using: &imageGenerator) ?? candidates[0]
            guard let mesh = renderMesh(palette: palette, size: size, generator: &imageGenerator) else { continue }
            let finished = finish(mesh, size: size, grain: options.grain, generator: &imageGenerator)
            let name = String(format: "%@-%016llx_%@.%@", palette.name, imageSeed, size.label, options.format)
            let url = options.outputDirectory.appendingPathComponent(name)
            try write(finished, to: url, format: options.format, context: context, colourSpace: colourSpace)
            if options.format == "png" && options.optimise {
                optimisePNG(at: url)
            }
            if let dpi = options.dpi {
                _ = run("sips", ["-s", "dpiWidth", "\(dpi)", "-s", "dpiHeight", "\(dpi)", url.path])
            }
            print("\(index + 1)/\(options.count) \(url.path)")
        }
    }
}

try await main()
