import XCTest
@testable import PalettaCore

final class ColorCountTests: XCTestCase {

    func testDefaultCountIsFive() {
        let store = InMemoryColorCountStore()
        XCTAssertEqual(store.colorCount, 5)
    }

    func testSetCountToThree() {
        let store = InMemoryColorCountStore()
        store.set(count: 3)
        XCTAssertEqual(store.colorCount, 3)
    }

    func testSetCountToSeven() {
        let store = InMemoryColorCountStore()
        store.set(count: 7)
        XCTAssertEqual(store.colorCount, 7)
    }

    func testCycleThreeFiveSeven() {
        let store = InMemoryColorCountStore()
        let counts = [3, 5, 7]
        XCTAssertEqual(store.colorCount, 5)

        store.set(count: counts[(counts.firstIndex(of: store.colorCount)! + 1) % counts.count])
        XCTAssertEqual(store.colorCount, 7)

        store.set(count: counts[(counts.firstIndex(of: store.colorCount)! + 1) % counts.count])
        XCTAssertEqual(store.colorCount, 3)

        store.set(count: counts[(counts.firstIndex(of: store.colorCount)! + 1) % counts.count])
        XCTAssertEqual(store.colorCount, 5)
    }

    func testSetIsIdempotent() {
        let store = InMemoryColorCountStore()
        store.set(count: 7)
        store.set(count: 7)
        XCTAssertEqual(store.colorCount, 7)
    }
}
