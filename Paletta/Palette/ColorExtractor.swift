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
        var pixels: [Pixel] = []
        pixels.reserveCapacity(2000)

        for y in Swift.stride(from: 0, to: height, by: sampleStep) {
            for x in Swift.stride(from: 0, to: width, by: sampleStep) {
                let offset = y * bytesPerRow + x * 4
                // AVFoundation BGRA format
                let b = Float(buffer[offset])     / 255.0
                let g = Float(buffer[offset + 1]) / 255.0
                let r = Float(buffer[offset + 2]) / 255.0
                pixels.append(Pixel(r: r, g: g, b: b))
            }
        }

        guard pixels.count >= count else { return [] }

        let centroids = kMeans(pixels: pixels, k: count, iterations: 12)
        return centroids.map { UIColor(red: CGFloat($0.r), green: CGFloat($0.g), blue: CGFloat($0.b), alpha: 1) }
    }

    // MARK: - K-Means

    private struct Pixel {
        var r, g, b: Float
    }

    private static func kMeans(pixels: [Pixel], k: Int, iterations: Int) -> [Pixel] {
        // Seed centroids by spreading initial picks across the array
        let step = pixels.count / k
        var centroids = (0..<k).map { pixels[$0 * step] }

        for _ in 0..<iterations {
            var sums = Array(repeating: (r: Float(0), g: Float(0), b: Float(0), count: 0), count: k)

            for pixel in pixels {
                let idx = nearestCentroid(to: pixel, in: centroids)
                sums[idx].r     += pixel.r
                sums[idx].g     += pixel.g
                sums[idx].b     += pixel.b
                sums[idx].count += 1
            }

            for i in 0..<k {
                let n = Float(max(1, sums[i].count))
                centroids[i] = Pixel(r: sums[i].r / n, g: sums[i].g / n, b: sums[i].b / n)
            }
        }

        return centroids
    }

    private static func nearestCentroid(to pixel: Pixel, in centroids: [Pixel]) -> Int {
        var minDist = Float.infinity
        var minIdx  = 0
        for (i, c) in centroids.enumerated() {
            let d = (pixel.r - c.r) * (pixel.r - c.r)
                  + (pixel.g - c.g) * (pixel.g - c.g)
                  + (pixel.b - c.b) * (pixel.b - c.b)
            if d < minDist { minDist = d; minIdx = i }
        }
        return minIdx
    }
}

// MARK: - Hex helper

extension UIColor {
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
