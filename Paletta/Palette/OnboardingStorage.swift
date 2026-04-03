import Foundation

protocol OnboardingStoring {
    var shouldShowOnboarding: Bool { get }
    func markComplete()
    func reset()
}

final class InMemoryOnboardingStorage: OnboardingStoring {
    private var completed = false

    var shouldShowOnboarding: Bool { !completed }

    func markComplete() { completed = true }
    func reset() { completed = false }
}

struct UserDefaultsOnboardingStorage: OnboardingStoring {
    private let key = "onboarding_complete"

    var shouldShowOnboarding: Bool {
        !UserDefaults.standard.bool(forKey: key)
    }

    func markComplete() {
        UserDefaults.standard.set(true, forKey: key)
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
