import SwiftUI

struct ContentView: View {

    @StateObject private var camera = CameraViewModel()

    var body: some View {
        ZStack {
            if camera.permissionDenied {
                CameraPermissionDeniedView()
            } else {
                ZStack(alignment: .bottom) {
                    CameraPreviewView(session: camera.session)
                        .ignoresSafeArea()

                    if !camera.palette.isEmpty {
                        PaletteView(colors: camera.palette)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
    }
}

#Preview {
    ContentView()
}
