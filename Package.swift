// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PalettaCore",
    targets: [
        .target(
            name: "PalettaCore",
            path: "Paletta/Palette",
            sources: ["KMeans.swift", "RALMatcher.swift", "SavedPalette.swift", "PaletteStore.swift", "OnboardingStorage.swift"]
        ),
        .testTarget(
            name: "PalettaCoreTests",
            dependencies: ["PalettaCore"],
            path: "Tests/PalettaCoreTests"
        ),
    ]
)
