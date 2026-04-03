import SwiftUI

struct OnboardingSlide {
    let icon: String
    let title: String
    let description: String
}

private let slides: [OnboardingSlide] = [
    OnboardingSlide(
        icon: "camera.viewfinder",
        title: "Point & Extract",
        description: "Aim the camera at anything around you. Paletta instantly extracts the dominant colors in real time."
    ),
    OnboardingSlide(
        icon: "doc.on.doc",
        title: "Tap to Copy",
        description: "Tap any color swatch to copy its HEX or RAL code straight to your clipboard. Switch formats with the toggle."
    ),
    OnboardingSlide(
        icon: "square.and.arrow.down",
        title: "Save & Export",
        description: "Save your favourite palettes with a name, or export them as an image to use in Figma, Canva, or anywhere else."
    ),
]

struct OnboardingView: View {

    let onDismiss: () -> Void
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.08)
                .ignoresSafeArea()

            // Skip button
            if currentPage < slides.count - 1 {
                VStack {
                    HStack {
                        Spacer()
                        Button("Skip", action: onDismiss)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.45))
                            .padding(.top, 60)
                            .padding(.trailing, 24)
                    }
                    Spacer()
                }
            }

            VStack(spacing: 0) {
                Spacer()

                // Slide content
                TabView(selection: $currentPage) {
                    ForEach(slides.indices, id: \.self) { i in
                        SlideView(slide: slides[i])
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 360)

                // Page dots
                HStack(spacing: 8) {
                    ForEach(slides.indices, id: \.self) { i in
                        Circle()
                            .fill(i == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 7, height: 7)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.top, 32)

                Spacer()

                // Action button
                Button {
                    if currentPage < slides.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        onDismiss()
                    }
                } label: {
                    Text(currentPage < slides.count - 1 ? "Next" : "Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
                .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }
}

private struct SlideView: View {

    let slide: OnboardingSlide

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: slide.icon)
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                Text(slide.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)

                Text(slide.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 8)
    }
}
