import SwiftUI

struct ContentView: View {

    @StateObject private var camera = CameraViewModel()
    @StateObject private var paletteStore = PaletteStoreViewModel(store: UserDefaultsPaletteStore())
    @State private var showSaved = false

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()

            if !camera.palette.isEmpty {
                PaletteView(colors: camera.palette, paletteStore: paletteStore)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Saved palettes button — top right
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showSaved = true
                    } label: {
                        Image(systemName: "swatchpalette")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .accessibilityLabel("View saved palettes")
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .overlay {
            if camera.permissionDenied {
                CameraPermissionDeniedView()
                    .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showSaved) {
            SavedPalettesView(store: paletteStore)
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
    }
}

#Preview {
    ContentView()
}
