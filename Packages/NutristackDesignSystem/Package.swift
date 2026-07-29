// swift-tools-version: 5.10
// NutristackDesignSystem · Package du système de design Nutristack
// Référence : Design System v2.0.1, sections 3 à 8 et 12.
import PackageDescription

let package = Package(
    name: "NutristackDesignSystem",
    defaultLocalization: "fr",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "NutristackDesignSystem", targets: ["NutristackDesignSystem"])
    ],
    targets: [
        .target(
            name: "NutristackDesignSystem",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "NutristackDesignSystemTests",
            dependencies: ["NutristackDesignSystem"]
        )
    ]
)
