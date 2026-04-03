import SwiftUI

struct PaletteView: View {

    let colors: [UIColor]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(colors.indices, id: \.self) { i in
                SwatchView(color: colors[i])
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }
}

private struct SwatchView: View {

    let color: UIColor

    var body: some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(color))
                .frame(height: 56)
                .shadow(color: Color(color).opacity(0.4), radius: 6, y: 3)

            Text(color.hexString)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.primary)
                .onTapGesture { UIPasteboard.general.string = color.hexString }
        }
        .frame(maxWidth: .infinity)
    }
}
