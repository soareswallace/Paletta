import XCTest
@testable import PalettaCore

final class KMeansTests: XCTestCase {

    func testSingleColorConvergesToItself() {
        let pixels = Array(repeating: KMeansColor(r: 1, g: 0, b: 0), count: 100)
        let result = kMeans(pixels: pixels, k: 1, iterations: 5)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].r, 1.0, accuracy: 0.01)
        XCTAssertEqual(result[0].g, 0.0, accuracy: 0.01)
        XCTAssertEqual(result[0].b, 0.0, accuracy: 0.01)
    }

    func testTwoDistinctColorsAreSeparated() {
        let red  = Array(repeating: KMeansColor(r: 1, g: 0, b: 0), count: 50)
        let blue = Array(repeating: KMeansColor(r: 0, g: 0, b: 1), count: 50)
        let result = kMeans(pixels: red + blue, k: 2, iterations: 10)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.r > 0.9 && $0.b < 0.1 }, "Expected red centroid")
        XCTAssertTrue(result.contains { $0.b > 0.9 && $0.r < 0.1 }, "Expected blue centroid")
    }

    func testReturnsExactlyKCentroids() {
        let pixels = (0..<100).map { i in KMeansColor(r: Float(i) / 100, g: 0, b: 0) }
        for k in 1...5 {
            let result = kMeans(pixels: pixels, k: k, iterations: 5)
            XCTAssertEqual(result.count, k, "Expected \(k) centroids")
        }
    }

    func testSortedByHuePutsRedBeforeBlue() {
        let red  = KMeansColor(r: 1, g: 0, b: 0)
        let green = KMeansColor(r: 0, g: 1, b: 0)
        let blue = KMeansColor(r: 0, g: 0, b: 1)
        let sorted = sortedByHue([blue, red, green])
        XCTAssertEqual(sorted[0].r, red.r, accuracy: 0.01)
        XCTAssertEqual(sorted[1].g, green.g, accuracy: 0.01)
        XCTAssertEqual(sorted[2].b, blue.b, accuracy: 0.01)
    }

    func testSortedByHueIsStable() {
        let colors = [
            KMeansColor(r: 0, g: 0, b: 1),
            KMeansColor(r: 1, g: 0, b: 0),
            KMeansColor(r: 0, g: 1, b: 0),
        ]
        let a = sortedByHue(colors)
        let b = sortedByHue(colors.reversed())
        XCTAssertEqual(a.map(\.r), b.map(\.r))
        XCTAssertEqual(a.map(\.g), b.map(\.g))
        XCTAssertEqual(a.map(\.b), b.map(\.b))
    }

    func testCentroidIsAverageOfCluster() {
        // All pixels are the same — centroid should equal that color
        let color = KMeansColor(r: 0.4, g: 0.6, b: 0.2)
        let pixels = Array(repeating: color, count: 60)
        let result = kMeans(pixels: pixels, k: 1, iterations: 10)
        XCTAssertEqual(result[0].r, color.r, accuracy: 0.01)
        XCTAssertEqual(result[0].g, color.g, accuracy: 0.01)
        XCTAssertEqual(result[0].b, color.b, accuracy: 0.01)
    }
}
