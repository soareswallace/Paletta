import XCTest
@testable import PalettaCore

final class OnboardingTests: XCTestCase {

    func testFreshStorageNeedsOnboarding() {
        let storage = InMemoryOnboardingStorage()
        XCTAssertTrue(storage.shouldShowOnboarding)
    }

    func testMarkingCompleteHidesOnboarding() {
        let storage = InMemoryOnboardingStorage()
        storage.markComplete()
        XCTAssertFalse(storage.shouldShowOnboarding)
    }

    func testResetRestoresOnboarding() {
        let storage = InMemoryOnboardingStorage()
        storage.markComplete()
        storage.reset()
        XCTAssertTrue(storage.shouldShowOnboarding)
    }

    func testMarkCompleteIsIdempotent() {
        let storage = InMemoryOnboardingStorage()
        storage.markComplete()
        storage.markComplete()
        XCTAssertFalse(storage.shouldShowOnboarding)
    }
}
