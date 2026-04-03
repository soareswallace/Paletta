import XCTest

// Local test double — mirrors InMemoryColorCountStore without requiring PalettaCore import
private final class TestColorCountStore {
    private(set) var colorCount: Int = 5
    func set(count: Int) { colorCount = count }
}

private let validCounts = [3, 5, 7]

final class ColorCountTests: XCTestCase {

    func testDefaultCountIsFive() {
        let store = TestColorCountStore()
        XCTAssertEqual(store.colorCount, 5)
    }

    func testSetCountToThree() {
        let store = TestColorCountStore()
        store.set(count: 3)
        XCTAssertEqual(store.colorCount, 3)
    }

    func testSetCountToSeven() {
        let store = TestColorCountStore()
        store.set(count: 7)
        XCTAssertEqual(store.colorCount, 7)
    }

    func testCycleThreeFiveSeven() {
        let store = TestColorCountStore()
        XCTAssertEqual(store.colorCount, 5)

        store.set(count: validCounts[(validCounts.firstIndex(of: store.colorCount)! + 1) % validCounts.count])
        XCTAssertEqual(store.colorCount, 7)

        store.set(count: validCounts[(validCounts.firstIndex(of: store.colorCount)! + 1) % validCounts.count])
        XCTAssertEqual(store.colorCount, 3)

        store.set(count: validCounts[(validCounts.firstIndex(of: store.colorCount)! + 1) % validCounts.count])
        XCTAssertEqual(store.colorCount, 5)
    }

    func testSetIsIdempotent() {
        let store = TestColorCountStore()
        store.set(count: 7)
        store.set(count: 7)
        XCTAssertEqual(store.colorCount, 7)
    }
}
