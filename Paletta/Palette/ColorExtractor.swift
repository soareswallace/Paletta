import UIKit

struct ColorExtractor {

    // Entry point: takes a pixel buffer, returns 5 dominant UIColors
    static func dominantColors(from pixelBuffer: CVPixelBuffer, count: Int = 5) -> [UIColor] {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return [] }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)

        // Sample ~2000 pixels evenly across the frame for performance
        let sampleStep = max(1, Int(sqrt(Double(width * height) / 2000.0)))
        var pixels: [KMeansColor] = []
        pixels.reserveCapacity(2000)

        for y in Swift.stride(from: 0, to: height, by: sampleStep) {
            for x in Swift.stride(from: 0, to: width, by: sampleStep) {
                let offset = y * bytesPerRow + x * 4
                // AVFoundation BGRA format
                let b = Float(buffer[offset])     / 255.0
                let g = Float(buffer[offset + 1]) / 255.0
                let r = Float(buffer[offset + 2]) / 255.0
                pixels.append(KMeansColor(r: r, g: g, b: b))
            }
        }

        guard pixels.count >= count else { return [] }

        let centroids = sortedByHue(kMeans(pixels: pixels, k: count, iterations: 12))
        return centroids.map { UIColor(red: CGFloat($0.r), green: CGFloat($0.g), blue: CGFloat($0.b), alpha: 1) }
    }
}

// MARK: - Hex helpers

extension UIColor {
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }

    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard hex.count == 6, let value = UInt64(hex, radix: 16) else { return nil }
        self.init(
            red:   CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >>  8) & 0xFF) / 255,
            blue:  CGFloat( value        & 0xFF) / 255,
            alpha: 1
        )
    }
}
