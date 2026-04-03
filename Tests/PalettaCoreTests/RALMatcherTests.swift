import XCTest
@testable import PalettaCore

final class RALMatcherTests: XCTestCase {

    func testPureBlackMatchesJetBlack() {
        let result = nearestRALColor(r: 0, g: 0, b: 0)
        XCTAssertEqual(result.code, "RAL 9005")
    }

    func testPureWhiteMatchesAWhiteRAL() {
        let result = nearestRALColor(r: 255, g: 255, b: 255)
        XCTAssertTrue(result.code.hasPrefix("RAL 9"),
                      "Expected a 9xxx white/neutral, got \(result.code)")
    }

    func testExactDatabaseEntryReturnsItself() {
        // RAL 3020 Traffic red: 187, 30, 16
        let result = nearestRALColor(r: 187, g: 30, b: 16)
        XCTAssertEqual(result.code, "RAL 3020")
    }

    func testResultIsClosestEntryInDatabase() {
        let r: Float = 200, g: Float = 40, b: Float = 28
        let result = nearestRALColor(r: r, g: g, b: b)

        func dist(_ c: RALColor) -> Float {
            let dr = Float(c.r) - r
            let dg = Float(c.g) - g
            let db = Float(c.b) - b
            return dr*dr + dg*dg + db*db
        }

        let resultDist = dist(result)
        for color in ralDatabase {
            XCTAssertLessThanOrEqual(
                resultDist, dist(color),
                "\(result.code) is not closest — \(color.code) is nearer to (\(r),\(g),\(b))"
            )
        }
    }

    func testRALColorHasCodeNameAndRGB() {
        let color = ralDatabase.first!
        XCTAssertFalse(color.code.isEmpty)
        XCTAssertFalse(color.name.isEmpty)
    }
}
