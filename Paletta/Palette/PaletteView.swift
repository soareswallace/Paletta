import SwiftUI

enum ColorFormat { case hex, ral }

struct PaletteView: View {

    let colors: [UIColor]
    @ObservedObject var paletteStore: PaletteStoreViewModel
    @State private var format: ColorFormat = .hex
    @State private var showSaveAlert = false
    @State private var paletteName = ""
    @State private var showShareSheet = false
    @State private var exportImage: UIImage?

    var body: some View {
        VStack(spacing: 12) {
            // Format toggle + action buttons
            HStack {
                Picker("Format", selection: $format) {
                    Text("HEX").tag(ColorFormat.hex)
                    Text("RAL").tag(ColorFormat.ral)
                }
                .pickerStyle(.segmented)

                Spacer(minLength: 12)

                Button {
                    paletteName = ""
                    showSaveAlert = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                }
                .accessibilityLabel("Save palette")

                Button {
                    exportImage = PaletteExporter.image(from: colors, format: format)
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                }
                .accessibilityLabel("Export palette")
            }
            .padding(.horizontal, 4)

            // Swatches
            HStack(spacing: 12) {
                ForEach(colors.indices, id: \.self) { i in
                    SwatchView(color: colors[i], format: format)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
        .alert("Save Palette", isPresented: $showSaveAlert) {
            TextField("Name", text: $paletteName)
            Button("Save") {
                let name = paletteName.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { return }
                paletteStore.save(name: name, hexCodes: colors.map(\.hexString))
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Give this palette a name.")
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = exportImage {
                ShareSheet(items: [img])
            }
        }
    }
}

private struct SwatchView: View {

    let color: UIColor
    let format: ColorFormat
    @State private var copied = false

    private var label: String {
        switch format {
        case .hex: return color.hexString
        case .ral:
            let match = nearestRAL(to: color)
            return match.code
        }
    }

    private var accessibilityDescription: String {
        switch format {
        case .hex:
            return "Color \(color.hexString)"
        case .ral:
            let match = nearestRAL(to: color)
            return "\(match.code), \(match.name)"
        }
    }

    private var sublabel: String? {
        guard format == .ral else { return nil }
        return nearestRAL(to: color).name
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(color))
                    .shadow(color: Color(color).opacity(0.4), radius: 6, y: 3)

                if copied {
                    Text("Copied!")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 2)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .frame(height: 56)

            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if let sub = sublabel {
                Text(sub)
                    .font(.system(size: 8, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            UIPasteboard.general.string = label
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeOut(duration: 0.15)) { copied = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeIn(duration: 0.2)) { copied = false }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Double tap to copy")
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
