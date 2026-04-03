import SwiftUI

@main
struct PalettaApp: App {

    @State private var splashDone = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(splashDone ? 1 : 0)

                if !splashDone {
                    SplashView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            splashDone = true
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}
