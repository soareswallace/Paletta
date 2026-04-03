import SwiftUI

struct CameraPermissionDeniedView: View {

    private let swatches: [(Color, Double)] = [
        (Color(red: 0.87, green: 0.10, blue: 0.08), -32),
        (Color(red: 0.93, green: 0.47, blue: 0.05), -16),
        (Color(red: 0.96, green: 0.82, blue: 0.00),   0),
        (Color(red: 0.18, green: 0.70, blue: 0.18),  16),
        (Color(red: 0.04, green: 0.40, blue: 0.88),  32),
    ]

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.08).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Dimmed fan with lock overlay
                ZStack {
                    ZStack {
                        ForEach(swatches.indices.reversed(), id: \.self) { i in
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(swatches[i].0)
                                .frame(width: 72, height: 168)
                                .rotationEffect(
                                    .degrees(swatches[i].1),
                                    anchor: .init(x: 0.5, y: 1.0)
                                )
                        }
                    }
                    .saturation(0)
                    .opacity(0.25)

                    Image(systemName: "camera.slash.fill")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .offset(y: -30)
                }
                .frame(height: 200)

                Spacer().frame(height: 40)

                // Message
                VStack(spacing: 12) {
                    Text("Camera Access Needed")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Paletta needs your camera to extract\ncolor palettes. Enable it in Settings.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 40)

                Spacer().frame(height: 40)

                // Settings button
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "gear")
                        Text("Open Settings")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(.white, in: Capsule())
                }

                Spacer()
            }
        }
    }
}
