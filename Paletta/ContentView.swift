import SwiftUI

struct ContentView: View {

    @StateObject private var camera = CameraViewModel(countStore: UserDefaultsColorCountStore())
    @StateObject private var paletteStore = PaletteStoreViewModel(store: UserDefaultsPaletteStore())
    @Environment(\.scenePhase) private var scenePhase
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

                        // Color count cycle button
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            camera.cycleColorCount()
                        } label: {
                            Text("\(camera.colorCount)")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .accessibilityLabel("Color count: \(camera.colorCount). Tap to change.")

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
            } else if camera.cameraUnavailable {
                CameraUnavailableView()
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
                paletteStore.save(
                    name: paletteName.trimmingCharacters(in: .whitespaces),
                    hexCodes: camera.palette.map(\.hexString)
                )
            }
            .disabled(paletteName.trimmingCharacters(in: .whitespaces).isEmpty)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Give this palette a name.")
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { camera.start() }
            else { camera.stop() }
        }
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
