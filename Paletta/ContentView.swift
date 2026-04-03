import SwiftUI

struct ContentView: View {

    @StateObject private var camera = CameraViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            // Fullscreen camera feed
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()

            // Live palette overlay
            if !camera.palette.isEmpty {
                PaletteView(colors: camera.palette)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
    }
}

#Preview {
    ContentView()
}
