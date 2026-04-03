import Foundation

protocol PaletteStoring {
    func save(_ palette: SavedPalette)
    func load() -> [SavedPalette]
    func delete(_ palette: SavedPalette)
}

final class InMemoryPaletteStore: PaletteStoring {
    private var palettes: [SavedPalette] = []

    func save(_ palette: SavedPalette) {
        palettes.append(palette)
    }

    func load() -> [SavedPalette] {
        palettes
    }

    func delete(_ palette: SavedPalette) {
        palettes.removeAll { $0.id == palette.id }
    }
}

final class UserDefaultsPaletteStore: PaletteStoring {
    private let key = "saved_palettes"

    func save(_ palette: SavedPalette) {
        var current = load()
        current.append(palette)
        persist(current)
    }

    func load() -> [SavedPalette] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SavedPalette].self, from: data)
        else { return [] }
        return decoded
    }

    func delete(_ palette: SavedPalette) {
        persist(load().filter { $0.id != palette.id })
    }

    private func persist(_ palettes: [SavedPalette]) {
        if let data = try? JSONEncoder().encode(palettes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
