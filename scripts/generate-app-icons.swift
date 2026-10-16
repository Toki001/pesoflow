// Run from the repository root: swift scripts/generate-app-icons.swift
// Uses macOS Quick Look to render the supplied vector; no package dependencies.
import AppKit
import ImageIO
import UniformTypeIdentifiers
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: true)
defer { try? FileManager.default.removeItem(at: temporary) }
let render = Process()
render.executableURL = URL(fileURLWithPath: "/usr/bin/qlmanage")
render.arguments = ["-t", "-s", "1024", "-o", temporary.path, root.appendingPathComponent("logo.svg").path]
try render.run()
render.waitUntilExit()
precondition(render.terminationStatus == 0, "SVG rendering failed")
let source = NSImage(contentsOf: temporary.appendingPathComponent("logo.svg.png"))!
func writeIcon(_ path: String, size: Int) throws {
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
        bytesPerRow: size * 4, space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    let bounds = CGRect(x: 0, y: 0, width: size, height: size)
    context.fill(bounds)
    context.interpolationQuality = .high
    context.draw(source.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: bounds)
    let target = CGImageDestinationCreateWithURL(root.appendingPathComponent(path) as CFURL,
        UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(target, context.makeImage()!, nil)
    precondition(CGImageDestinationFinalize(target), "Could not write icon")
}
for (density, size) in [("mdpi",48),("hdpi",72),("xhdpi",96),("xxhdpi",144),("xxxhdpi",192)] {
    try writeIcon("mobile/android/app/src/main/res/mipmap-\(density)/ic_launcher.png", size: size)
}
let ios = "mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/"
let manifest = try JSONSerialization.jsonObject(with: Data(contentsOf: root.appendingPathComponent(ios + "Contents.json"))) as! [String: Any]
for entry in manifest["images"] as! [[String: String]] {
    let size = Double(entry["size"]!.components(separatedBy: "x")[0])!
    let scale = Double(entry["scale"]!.replacingOccurrences(of: "x", with: ""))!
    try writeIcon(ios + entry["filename"]!, size: Int(size * scale))
}
print("Generated Android and iOS launcher icons from logo.svg")
