// swift-tools-version: 6.2
import PackageDescription

// Contracts shared by Dev A and Dev B. Changes need the other dev's review (docs/interfaces.md).
let package = Package(
    name: "SharedKit",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "SharedKit", targets: ["SharedKit"]),
    ],
    targets: [
        .target(
            name: "SharedKit",
            resources: [.process("Resources")]
        ),
        .testTarget(name: "SharedKitTests", dependencies: ["SharedKit"]),
    ]
)
