// swift-tools-version: 6.2
import PackageDescription

// Dev A: money deadlines, escalation + alarm, Decide, capture, entitlements (RevenueCat).
let package = Package(
    name: "MoneyKit",
    // macOS only so `swift run TrialCaptureEval` can score the extractor on this Mac (A7).
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "MoneyKit", targets: ["MoneyKit"]),
        .library(name: "TrialCapture", targets: ["TrialCapture"]),
    ],
    dependencies: [
        .package(path: "../SharedKit"),
        // Pinned (CLAUDE.md rule 5). Test Store needs >= 5.43.0.
        .package(url: "https://github.com/RevenueCat/purchases-ios-spm.git", exact: "5.91.0"),
    ],
    targets: [
        .target(
            name: "MoneyKit",
            dependencies: [
                "SharedKit",
                "TrialCapture",
                .product(name: "RevenueCat", package: "purchases-ios-spm"),
            ]
        ),
        // Screenshot/text → trial fields. Vision + Foundation Models, no SharedKit, no UI.
        .target(name: "TrialCapture"),
        .executableTarget(name: "TrialCaptureEval", dependencies: ["TrialCapture"]),
        .testTarget(name: "MoneyKitTests", dependencies: ["MoneyKit"]),
        .testTarget(name: "TrialCaptureTests", dependencies: ["TrialCapture"]),
    ]
)
