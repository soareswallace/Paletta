# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test

This project is developed on a Mac via git sync from Linux. All building and testing must be done on the Mac side. There are no local build scripts — use Xcode or `xcodebuild`.

Run the PalettaCore unit tests (pure Swift, runnable without a device):
```bash
swift test --package-path PalettaCore
```

Run a single test:
```bash
swift test --package-path PalettaCore --filter KMeansTests/testConvergence
```

The main Xcode target requires a physical device (AVCaptureSession).

## Architecture

**MVVM + SwiftUI** with a Swift Package (`PalettaCore`) isolating the pure algorithms.

### PalettaCore (Swift Package)
Pure Swift, no dependencies, testable on Linux. Contains:
- `KMeans.swift` — k-means color clustering on RGB pixels
- `RALMatcher.swift` + `RALDatabase.swift` — nearest-neighbor matching against 240+ RAL Classic colors
- `ColorExtractor.swift` — samples ~2000 pixels from a camera frame (stride sampling) and calls KMeans

### ViewModels (`@MainActor`)
- `CameraViewModel` — owns AVCaptureSession, throttles frame processing (0.4s), blends colors frame-to-frame (70% new / 30% previous), cycles color count (3/5/7)
- `PaletteStoreViewModel` — wraps `PaletteStoring`, publishes sorted palette list

### Storage (Protocol-Based)
Three protocols with `InMemory*` (tests) and `UserDefaults*` (production) implementations:
- `PaletteStoring` — saves/loads `SavedPalette` as JSON in UserDefaults
- `ColorCountStoring` — persists the 3/5/7 color count preference
- `OnboardingStoring` — tracks whether onboarding has been seen

### App Flow
`PalettaApp` → `SplashView` → `OnboardingView` (first launch) → `ContentView` (camera + `PaletteView`) → `SavedPalettesView` (modal sheet)

### Threading
Camera frame capture runs on `com.paletta.processing` DispatchQueue. All state mutations go through `@MainActor` ViewModels.

## Testing Approach

Before every commit and push, run the full test suite to confirm correctness:
```bash
swift test --package-path PalettaCore
```

New logic added to `PalettaCore` should follow TDD: write a failing test first, then implement. The `InMemory*` storage implementations exist specifically to enable test-driven development of storage-dependent behavior without touching UserDefaults.

Tests live in `PalettaCore/Tests/PalettaCoreTests/` and cover: KMeans convergence and hue sorting, RAL matching, palette Codable serialization, onboarding state, and color count cycling.

## Key Conventions

- **Dark theme:** background `Color(white: 0.08)`, glassmorphism via `.ultraThinMaterial`
- **Haptics:** `UIImpactFeedbackGenerator(.light)` on swatch tap and color count cycle
- **Exports:** `PaletteExporter` renders a `UIImage` with swatches + labels; shared via `UIActivityViewController` presented through a `UIViewController` (not directly from SwiftUI sheet)
- **Color format toggle:** `ColorFormat` enum (`.hex` / `.ral`) passed as `@Binding` between `ContentView` and `PaletteView`

## App Store Submission

### Screenshot Requirements
- Screenshots must show the app **actively in use** — onboarding, splash, and login screens will be rejected (Guideline 2.3.3)
- Good screenshots for Paletta: camera view with HEX palette, camera view with RAL palette, Save Palette dialog, Saved Palettes list
- Avoid screenshots of the iOS share sheet (exposes user's installed apps, looks unprofessional)
- All screenshots must be **PNG without alpha channel** or **JPEG** — App Store Connect rejects images with transparency
- To strip alpha on Mac: `sips -s format jpeg -s formatOptions 100 screenshot.png --out screenshot.jpg`
- Use vibrant, colorful subjects for camera screenshots — they make the palette feature more compelling
