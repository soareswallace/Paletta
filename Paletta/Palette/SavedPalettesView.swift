import SwiftUI
import Combine

private let appBackground = Color(red: 0.08, green: 0.08, blue: 0.08)
private let cardBackground = Color(white: 1, opacity: 0.06)

struct SavedPalettesView: View {

    @ObservedObject var store: PaletteStoreViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var exportImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Saved Palettes")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Divider()
                    .background(Color.white.opacity(0.08))

                if store.palettes.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "swatchpalette")
                            .font(.system(size: 52, weight: .light))
                            .foregroundStyle(.white.opacity(0.2))
                        Text("No Saved Palettes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.4))
                        Text("Save a palette from the camera view.")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.25))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(store.palettes) { palette in
                                PaletteCard(
                                    palette: palette,
                                    onDelete: { store.delete(palette) },
                                    onExport: { image in
                                        exportImage = image
                                        showShareSheet = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = exportImage {
                ShareSheet(items: [img])
            }
        }
    }
}

private struct PaletteCard: View {

    let palette: SavedPalette
    let onDelete: () -> Void
    let onExport: (UIImage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name + actions
            HStack {
                Text(palette.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                HStack(spacing: 16) {
                    Button {
                        let colors = palette.hexCodes.compactMap { UIColor(hexString: $0) }
                        let image = PaletteExporter.image(from: colors, format: .hex)
                        onExport(image)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .accessibilityLabel("Export \(palette.name)")

                    Button(role: .destructive) {
                        withAnimation { onDelete() }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .accessibilityLabel("Delete \(palette.name)")
                }
            }

            // Swatches
            HStack(spacing: 8) {
                ForEach(palette.hexCodes, id: \.self) { hex in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: hex) ?? .gray)
                        .frame(height: 48)
                        .shadow(color: (Color(hex: hex) ?? .clear).opacity(0.4), radius: 6, y: 3)
                }
            }

            // Hex codes
            HStack(spacing: 0) {
                ForEach(palette.hexCodes, id: \.self) { hex in
                    Text(hex)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.3))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}

// MARK: - ViewModel

@MainActor
final class PaletteStoreViewModel: ObservableObject {
    @Published private(set) var palettes: [SavedPalette] = []
    private let store: PaletteStoring

    init(store: PaletteStoring) {
        self.store = store
        palettes = store.load().sorted { $0.createdAt > $1.createdAt }
    }

    func save(name: String, hexCodes: [String]) {
        let palette = SavedPalette(name: name, hexCodes: hexCodes)
        store.save(palette)
        palettes.insert(palette, at: 0)
    }

    func delete(_ palette: SavedPalette) {
        store.delete(palette)
        palettes.removeAll { $0.id == palette.id }
    }
}

// MARK: - Color from hex helper

private extension Color {
    init?(hex: String) {
        let h = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        guard h.count == 6, let value = UInt64(h, radix: 16) else { return nil }
        self.init(
            red:   Double((value >> 16) & 0xFF) / 255,
            green: Double((value >>  8) & 0xFF) / 255,
            blue:  Double( value        & 0xFF) / 255
        )
    }
}
