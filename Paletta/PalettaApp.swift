import SwiftUI

@main
struct PalettaApp: App {

    @State private var splashDone = false
    @State private var onboardingDone = false
    private let onboardingStorage = UserDefaultsOnboardingStorage()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .overlay {
                    if !splashDone {
                        SplashView {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                splashDone = true
                            }
                        }
                        .ignoresSafeArea()
                    } else if !onboardingDone && onboardingStorage.shouldShowOnboarding {
                        OnboardingView {
                            onboardingStorage.markComplete()
                            withAnimation(.easeInOut(duration: 0.4)) {
                                onboardingDone = true
                            }
                        }
                        .ignoresSafeArea()
                        .transition(.opacity)
                    }
                }
        }
    }
}
