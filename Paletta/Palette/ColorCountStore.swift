import Foundation

let validColorCounts = [3, 5, 7]

protocol ColorCountStoring {
    var colorCount: Int { get }
    func set(count: Int)
}

final class InMemoryColorCountStore: ColorCountStoring {
    private(set) var colorCount: Int = 5

    func set(count: Int) {
        colorCount = count
    }
}

struct UserDefaultsColorCountStore: ColorCountStoring {
    private let key = "color_count"

    var colorCount: Int {
        let stored = UserDefaults.standard.integer(forKey: key)
        return validColorCounts.contains(stored) ? stored : 5
    }

    func set(count: Int) {
        UserDefaults.standard.set(count, forKey: key)
    }
}
