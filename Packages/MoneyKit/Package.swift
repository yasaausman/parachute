// swift-tools-version: 6.2
import PackageDescription

// Dev A: money deadlines, escalation + alarm, Decide, entitlements (RevenueCat).
let package = Package(
    name: "MoneyKit",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "MoneyKit", targets: ["MoneyKit"]),
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
                .product(name: "RevenueCat", package: "purchases-ios-spm"),
                .product(name: "RevenueCatUI", package: "purchases-ios-spm"),
            ]
        ),
        .testTarget(name: "MoneyKitTests", dependencies: ["MoneyKit"]),
    ]
)
