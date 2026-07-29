// swift-tools-version: 5.10
// NutristackDomain · Logique métier pure du produit.
// Aucune dépendance UI : les tests s’exécutent sur macOS (`swift test`) comme en CI.
// Référence : PRD v1.0.1 (§6 normalisation, §7 vérification, §9 comparateur, §13 données).
import PackageDescription

let package = Package(
    name: "NutristackDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "NutristackDomain", targets: ["NutristackDomain"])
    ],
    targets: [
        .target(name: "NutristackDomain"),
        .testTarget(name: "NutristackDomainTests", dependencies: ["NutristackDomain"])
    ]
)
