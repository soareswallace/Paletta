import SwiftUI

struct SplashView: View {

    var onComplete: () -> Void

    @State private var fanOpen    = false
    @State private var textVisible = false

    // Colors and angles matching the icon
    private let swatches: [(Color, Double)] = [
        (Color(red: 0.87, green: 0.10, blue: 0.08), -32),
        (Color(red: 0.93, green: 0.47, blue: 0.05), -16),
        (Color(red: 0.96, green: 0.82, blue: 0.00),   0),
        (Color(red: 0.18, green: 0.70, blue: 0.18),  16),
        (Color(red: 0.04, green: 0.40, blue: 0.88),  32),
    ]

    var body: some View {
        ZStack {
            // Same dark background as the icon
            Color(red: 0.08, green: 0.08, blue: 0.08).ignoresSafeArea()

            VStack(spacing: 36) {
                // Animated color fan
                ZStack {
                    ForEach(swatches.indices.reversed(), id: \.self) { i in
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(swatches[i].0)
                            .frame(width: 72, height: 168)
                            .shadow(color: swatches[i].0.opacity(0.45), radius: 10, y: 6)
                            .rotationEffect(
                                .degrees(fanOpen ? swatches[i].1 : 0),
                                anchor: .init(x: 0.5, y: 1.0)
                            )
                    }
                }
                .frame(height: 200)

                // App name
                Text("Paletta")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(textVisible ? 1 : 0)
                    .offset(y: textVisible ? 0 : 12)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.65).delay(0.15)) {
                fanOpen = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.55)) {
                textVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onComplete()
            }
        }
    }
}
