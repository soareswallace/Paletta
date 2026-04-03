import SwiftUI

@main
struct PalettaApp: App {

    @State private var splashDone = false

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
                    }
                }
        }
    }
}
