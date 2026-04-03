import Foundation

struct SavedPalette: Codable, Identifiable {
    let id: UUID
    let name: String
    let hexCodes: [String]
    let createdAt: Date

    init(name: String, hexCodes: [String]) {
        self.id = UUID()
        self.name = name
        self.hexCodes = hexCodes
        self.createdAt = Date()
    }
}
