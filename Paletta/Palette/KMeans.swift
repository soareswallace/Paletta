// Pure Swift — no framework dependencies, testable on Linux via SPM

struct KMeansColor {
    var r, g, b: Float
}

func kMeans(pixels: [KMeansColor], k: Int, iterations: Int) -> [KMeansColor] {
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
            centroids[i] = KMeansColor(r: sums[i].r / n, g: sums[i].g / n, b: sums[i].b / n)
        }
    }

    return centroids
}

func sortedByHue(_ colors: [KMeansColor]) -> [KMeansColor] {
    colors.sorted { hueOf($0) < hueOf($1) }
}

private func nearestCentroid(to pixel: KMeansColor, in centroids: [KMeansColor]) -> Int {
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

private func hueOf(_ c: KMeansColor) -> Float {
    let maxC = max(c.r, c.g, c.b)
    let minC = min(c.r, c.g, c.b)
    let delta = maxC - minC
    guard delta > 0.001 else { return 0 }
    var h: Float
    if maxC == c.r      { h = (c.g - c.b) / delta }
    else if maxC == c.g { h = 2 + (c.b - c.r) / delta }
    else                { h = 4 + (c.r - c.g) / delta }
    h /= 6
    if h < 0 { h += 1 }
    return h
}
