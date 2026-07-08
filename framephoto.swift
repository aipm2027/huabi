import Foundation
import Vision
import CoreImage
import ImageIO
import UniformTypeIdentifiers

func die(_ m: String) -> Never {
    FileHandle.standardError.write((m + "\n").data(using: .utf8)!); exit(1)
}
let args = CommandLine.arguments
guard args.count >= 3 else { die("usage: frame <in> <out.jpg>") }
let inURL = URL(fileURLWithPath: args[1])
let outURL = URL(fileURLWithPath: args[2])

guard let src = CGImageSourceCreateWithURL(inURL as CFURL, nil),
      let cg0 = CGImageSourceCreateImageAtIndex(src, 0, nil) else { die("load") }
let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
let orient = (props?[kCGImagePropertyOrientation] as? UInt32) ?? 1

let ctx = CIContext(options: [.useSoftwareRenderer: false])
let ciOriented = CIImage(cgImage: cg0).oriented(forExifOrientation: Int32(orient))
guard let cg = ctx.createCGImage(ciOriented, from: ciOriented.extent) else { die("orient") }
let W = cg.width, H = cg.height

// --- 用 Vision 找人物包围盒 (只为定位裁剪中心, 背景保留) ---
let handler = VNImageRequestHandler(cgImage: cg, options: [:])
let req = VNGenerateForegroundInstanceMaskRequest()
try? handler.perform([req])

var minx = 0, miny = 0, maxx = W, maxy = H
if let obs = req.results?.first {
    func area(_ s: IndexSet) -> Double {
        guard let b = try? obs.generateScaledMaskForImage(forInstances: s, from: handler) else { return -1 }
        let m = CIImage(cvPixelBuffer: b)
        guard let a = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: m, kCIInputExtentKey: CIVector(cgRect: m.extent)])?.outputImage else { return -1 }
        var px = [Float](repeating: 0, count: 4)
        ctx.render(a, toBitmap: &px, rowBytes: 16, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBAf, colorSpace: nil)
        return Double(px[0]) * Double(m.extent.width * m.extent.height)
    }
    var bi = -1, ba = -1.0
    for i in obs.allInstances { let a = area(IndexSet(integer: i)); if a > ba { ba = a; bi = i } }
    let chosen = bi >= 0 ? IndexSet(integer: bi) : obs.allInstances
    if let mb = try? obs.generateScaledMaskForImage(forInstances: chosen, from: handler) {
        let mCI = CIImage(cvPixelBuffer: mb)
        let bw = 400
        let sc = CGFloat(bw) / mCI.extent.width
        let bh = Int(mCI.extent.height * sc)
        if let mCG = ctx.createCGImage(mCI.transformed(by: .init(scaleX: sc, y: sc)), from: CGRect(x: 0, y: 0, width: bw, height: bh)) {
            let cs = CGColorSpaceCreateDeviceRGB()
            var buf = [UInt8](repeating: 0, count: bw * bh * 4)
            if let bc = CGContext(data: &buf, width: bw, height: bh, bitsPerComponent: 8, bytesPerRow: bw * 4, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                bc.draw(mCG, in: CGRect(x: 0, y: 0, width: bw, height: bh))
                var a1 = bw, b1 = bh, a2 = 0, b2 = 0
                for y in 0..<bh { for x in 0..<bw {
                    if buf[(y * bw + x) * 4] > 128 { if x < a1 { a1 = x }; if x > a2 { a2 = x }; if y < b1 { b1 = y }; if y > b2 { b2 = y } }
                }}
                if a2 > a1 && b2 > b1 {
                    let fx = Double(W) / Double(bw), fy = Double(H) / Double(bh)
                    minx = Int(Double(a1) * fx); maxx = Int(Double(a2) * fx)
                    miny = Int(Double(b1) * fy); maxy = Int(Double(b2) * fy)
                }
            }
        }
    }
}

// --- 计算竖幅 4:5 裁剪框, 以人物为中心, 保留左右背景 ---
let A = 0.8 // w/h
let ph = Double(maxy - miny), pw = Double(maxx - minx)
let cx = Double(minx + maxx) / 2
var ch = ph * 1.32
var cw = ch * A
if cw < pw * 1.14 { cw = pw * 1.14; ch = cw / A }
if ch > Double(H) { ch = Double(H); cw = ch * A }
if cw > Double(W) { cw = Double(W); ch = cw / A }
var tx = cx - cw / 2
var ty = Double(miny) - ph * 0.16
tx = max(0, min(Double(W) - cw, tx))
ty = max(0, min(Double(H) - ch, ty))
let crop = CGRect(x: tx.rounded(), y: ty.rounded(), width: cw.rounded(), height: ch.rounded())
guard let cropCG = cg.cropping(to: crop) else { die("crop") }

// --- 轻度美颜: 提亮 + 抬暗部 + 通透 + 柔肤 + 一点柔光 ---
var img = CIImage(cgImage: cropCG)
img = img.applyingFilter("CIExposureAdjust", parameters: ["inputEV": 0.18])
img = img.applyingFilter("CIHighlightShadowAdjust", parameters: ["inputShadowAmount": 0.35, "inputHighlightAmount": 1.0, "inputRadius": 8])
img = img.applyingFilter("CIColorControls", parameters: ["inputSaturation": 1.05, "inputContrast": 1.03, "inputBrightness": 0.015])
img = img.applyingFilter("CIVibrance", parameters: ["inputAmount": 0.12])
img = img.applyingFilter("CINoiseReduction", parameters: ["inputNoiseLevel": 0.02, "inputSharpness": 0.35])
let blur = img.applyingFilter("CIGaussianBlur", parameters: ["inputRadius": 7]).cropped(to: img.extent)
let soft = blur.applyingFilter("CIColorMatrix", parameters: ["inputAVector": CIVector(x: 0, y: 0, z: 0, w: 0.15)])
img = soft.composited(over: img)

guard let outCG = ctx.createCGImage(img, from: img.extent, format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB()) else { die("render") }
guard let dest = CGImageDestinationCreateWithURL(outURL as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else { die("dest") }
CGImageDestinationAddImage(dest, outCG, [kCGImageDestinationLossyCompressionQuality: 0.92] as CFDictionary)
if !CGImageDestinationFinalize(dest) { die("write") }
print("OK \(outCG.width)x\(outCG.height)")
