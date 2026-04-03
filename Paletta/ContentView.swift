import SwiftUI

struct ContentView: View {

    @StateObject private var camera = CameraViewModel()
    @StateObject private var paletteStore = PaletteStoreViewModel(store: UserDefaultsPaletteStore())
    @State private var format: ColorFormat = .hex
    @State private var showSaved = false
    @State private var showSaveAlert = false
    @State private var paletteName = ""
    @State private var showShareSheet = false
    @State private var exportImage: UIImage?

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()

            if !camera.palette.isEmpty {
                PaletteView(colors: camera.palette, format: $format)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Floating buttons — top right
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        floatingButton(icon: "swatchpalette") { showSaved = true }
                            .accessibilityLabel("View saved palettes")

                        if !camera.palette.isEmpty {
                            floatingButton(icon: "square.and.arrow.down") {
                                paletteName = ""
                                showSaveAlert = true
                            }
                            .accessibilityLabel("Save palette")

                            floatingButton(icon: "square.and.arrow.up") {
                                exportImage = PaletteExporter.image(from: camera.palette, format: format)
                                showShareSheet = true
                            }
                            .accessibilityLabel("Export palette")
                        }
                    }
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
        .sheet(isPresented: $showShareSheet) {
            if let img = exportImage {
                ShareSheet(items: [img])
            }
        }
        .alert("Save Palette", isPresented: $showSaveAlert) {
            TextField("Name", text: $paletteName)
            Button("Save") {
                let name = paletteName.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { return }
                paletteStore.save(name: name, hexCodes: camera.palette.map(\.hexString))
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Give this palette a name.")
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
    }

    private func floatingButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white)
                .padding(12)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}

// MARK: - Share sheet bridge

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}
