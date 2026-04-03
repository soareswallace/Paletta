import XCTest
@testable import PalettaCore

final class SavedPaletteTests: XCTestCase {

    // MARK: - SavedPalette model

    func testEncodeDecodeRoundtrip() throws {
        let palette = SavedPalette(name: "Sunset", hexCodes: ["#FF5733", "#C70039", "#900C3F"])
        let data = try JSONEncoder().encode(palette)
        let decoded = try JSONDecoder().decode(SavedPalette.self, from: data)
        XCTAssertEqual(decoded.id, palette.id)
        XCTAssertEqual(decoded.name, palette.name)
        XCTAssertEqual(decoded.hexCodes, palette.hexCodes)
    }

    func testIDIsUniquePerInstance() {
        let a = SavedPalette(name: "A", hexCodes: ["#FF0000"])
        let b = SavedPalette(name: "B", hexCodes: ["#FF0000"])
        XCTAssertNotEqual(a.id, b.id)
    }

    func testHexCodesPreservedAfterRoundtrip() throws {
        let codes = ["#1A2B3C", "#FFFFFF", "#000000", "#AABBCC", "#DDEEFF"]
        let palette = SavedPalette(name: "Test", hexCodes: codes)
        let data = try JSONEncoder().encode(palette)
        let decoded = try JSONDecoder().decode(SavedPalette.self, from: data)
        XCTAssertEqual(decoded.hexCodes, codes)
    }

    // MARK: - InMemoryPaletteStore

    func testStoreStartsEmpty() {
        let store = InMemoryPaletteStore()
        XCTAssertTrue(store.load().isEmpty)
    }

    func testSaveAndLoad() {
        let store = InMemoryPaletteStore()
        let palette = SavedPalette(name: "Ocean", hexCodes: ["#0077BE", "#00B4D8"])
        store.save(palette)
        let loaded = store.load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.name, "Ocean")
    }

    func testDeleteRemovesPalette() {
        let store = InMemoryPaletteStore()
        let a = SavedPalette(name: "A", hexCodes: ["#FF0000"])
        let b = SavedPalette(name: "B", hexCodes: ["#00FF00"])
        store.save(a)
        store.save(b)
        store.delete(a)
        let remaining = store.load()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.name, "B")
    }

    func testDeleteNonExistentIsNoOp() {
        let store = InMemoryPaletteStore()
        let a = SavedPalette(name: "A", hexCodes: ["#FF0000"])
        let b = SavedPalette(name: "B", hexCodes: ["#00FF00"])
        store.save(a)
        store.delete(b) // b was never saved
        XCTAssertEqual(store.load().count, 1)
    }

    func testSaveMultiplePalettes() {
        let store = InMemoryPaletteStore()
        for i in 1...5 {
            store.save(SavedPalette(name: "Palette \(i)", hexCodes: ["#000000"]))
        }
        XCTAssertEqual(store.load().count, 5)
    }

    func testLoadPreservesOrder() {
        let store = InMemoryPaletteStore()
        let names = ["First", "Second", "Third"]
        names.forEach { store.save(SavedPalette(name: $0, hexCodes: [])) }
        XCTAssertEqual(store.load().map(\.name), names)
    }
}
