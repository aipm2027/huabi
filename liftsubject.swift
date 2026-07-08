import Foundation
import Vision
import CoreImage
import ImageIO
import UniformTypeIdentifiers

func die(_ m: String) -> Never {
    FileHandle.standardError.write((m + "\n").data(using: .utf8)!)
    exit(1)
}

let args = CommandLine.arguments
guard args.count >= 3 else { die("usage: lift <in> <out>") }
let inURL = URL(fileURLWithPath: args[1])
let outURL = URL(fileURLWithPath: args[2])

guard let src = CGImageSourceCreateWithURL(inURL as CFURL, nil),
      let cg0 = CGImageSourceCreateImageAtIndex(src, 0, nil) else { die("cannot load image") }
let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
let orientation = (props?[kCGImagePropertyOrientation] as? UInt32) ?? 1

let ctx = CIContext(options: [.useSoftwareRenderer: false])
// 先把 EXIF 方向烘焙成正立像素
let ciOriented = CIImage(cgImage: cg0).oriented(forExifOrientation: Int32(orientation))
guard let cg = ctx.createCGImage(ciOriented, from: ciOriented.extent) else { die("orient fail") }

let handler = VNImageRequestHandler(cgImage: cg, options: [:])
let req = VNGenerateForegroundInstanceMaskRequest()
do { try handler.perform([req]) } catch { die("vision perform: \(error)") }
guard let obs = req.results?.first else { die("no foreground subject found") }

let ciFull = CIImage(cgImage: cg)

// 逐个实例算面积, 取最大的那个 (= 人物, 排除墙上画作等)
func areaOf(_ set: IndexSet) -> Double {
    guard let buf = try? obs.generateScaledMaskForImage(forInstances: set, from: handler) else { return -1 }
    let m = CIImage(cvPixelBuffer: buf)
    guard let avg = CIFilter(name: "CIAreaAverage", parameters: [
        kCIInputImageKey: m, kCIInputExtentKey: CIVector(cgRect: m.extent)
    ])?.outputImage else { return -1 }
    var px = [Float](repeating: 0, count: 4)
    ctx.render(avg, toBitmap: &px, rowBytes: 16,
               bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
               format: .RGBAf, colorSpace: nil)
    return Double(px[0]) * Double(m.extent.width * m.extent.height)
}

var bestIdx = -1, bestArea = -1.0
for idx in obs.allInstances {
    let a = areaOf(IndexSet(integer: idx))
    if a > bestArea { bestArea = a; bestIdx = idx }
}
let chosen = bestIdx >= 0 ? IndexSet(integer: bestIdx) : obs.allInstances
guard let maskBuf = try? obs.generateScaledMaskForImage(forInstances: chosen, from: handler) else { die("mask gen") }

let ciMask = CIImage(cvPixelBuffer: maskBuf)
let sx = ciFull.extent.width / ciMask.extent.width
let sy = ciFull.extent.height / ciMask.extent.height
let ciMaskScaled = ciMask.transformed(by: CGAffineTransform(scaleX: sx, y: sy))
// 轻度收边: gamma 收紧软边 + 1.5px 腐蚀, 去掉 JPEG/抠图的彩色毛边 (量小, 不吃手指)
let ciMaskClean = ciMaskScaled
    .applyingFilter("CIGammaAdjust", parameters: ["inputPower": 1.6])
    .applyingFilter("CIMorphologyMinimum", parameters: [kCIInputRadiusKey: 1.5])
    .cropped(to: ciFull.extent)

guard let out = CIFilter(name: "CIBlendWithMask", parameters: [
    kCIInputImageKey: ciFull,
    kCIInputBackgroundImageKey: CIImage.empty(),
    kCIInputMaskImageKey: ciMaskClean
])?.outputImage else { die("blend") }

guard let outCG = ctx.createCGImage(out, from: ciFull.extent) else { die("render out") }

// 扫描 alpha 找主体包围盒, 裁掉多余透明区
let bw = 500
let bh = max(1, Int(Double(bw) * Double(outCG.height) / Double(outCG.width)))
let cs = CGColorSpaceCreateDeviceRGB()
var buf = [UInt8](repeating: 0, count: bw * bh * 4)
guard let bctx = CGContext(data: &buf, width: bw, height: bh, bitsPerComponent: 8,
                           bytesPerRow: bw * 4, space: cs,
                           bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { die("bctx") }
bctx.draw(outCG, in: CGRect(x: 0, y: 0, width: bw, height: bh))
var minx = bw, miny = bh, maxx = 0, maxy = 0
for y in 0..<bh { for x in 0..<bw {
    if buf[(y * bw + x) * 4 + 3] > 20 {
        if x < minx { minx = x }; if x > maxx { maxx = x }
        if y < miny { miny = y }; if y > maxy { maxy = y }
    }
}}
if maxx < minx || maxy < miny { die("empty mask") }

let sxf = Double(outCG.width) / Double(bw)
let syf = Double(outCG.height) / Double(bh)
var rx = Double(minx) * sxf, ry = Double(miny) * syf
var rw = Double(maxx - minx + 1) * sxf, rh = Double(maxy - miny + 1) * syf
let pad = 0.04
let px2 = rw * pad, py2 = rh * pad
rx = max(0, rx - px2); ry = max(0, ry - py2)
rw = min(Double(outCG.width) - rx, rw + 2 * px2)
rh = min(Double(outCG.height) - ry, rh + 2 * py2)

guard let cropped = outCG.cropping(to: CGRect(x: rx, y: ry, width: rw, height: rh)) else { die("crop") }
guard let dest = CGImageDestinationCreateWithURL(outURL as CFURL, UTType.png.identifier as CFString, 1, nil) else { die("dest") }
CGImageDestinationAddImage(dest, cropped, nil)
if !CGImageDestinationFinalize(dest) { die("write fail") }
print("OK \(cropped.width)x\(cropped.height) instances=\(obs.allInstances.count)")
