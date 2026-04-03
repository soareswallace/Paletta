import SwiftUI
import Combine

struct SavedPalettesView: View {

    @ObservedObject var store: PaletteStoreViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.palettes.isEmpty {
                    ContentUnavailableView(
                        "No Saved Palettes",
                        systemImage: "swatchpalette",
                        description: Text("Save a palette from the camera view.")
                    )
                } else {
                    List {
                        ForEach(store.palettes) { palette in
                            SavedPaletteRow(palette: palette)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { store.delete(store.palettes[$0]) }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Saved Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct SavedPaletteRow: View {

    let palette: SavedPalette
    @State private var showShareSheet = false
    @State private var exportImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(palette.name)
                .font(.headline)
            HStack(spacing: 6) {
                ForEach(palette.hexCodes, id: \.self) { hex in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: hex) ?? .gray)
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
                }
            }
        }
        .padding(.vertical, 6)
        .swipeActions(edge: .leading) {
            Button {
                let colors = palette.hexCodes.compactMap { UIColor(hexString: $0) }
                exportImage = PaletteExporter.image(from: colors, format: .hex)
                showShareSheet = true
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .tint(.blue)
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = exportImage {
                ShareSheet(items: [img])
            }
        }
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
