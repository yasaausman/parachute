// swift-tools-version: 6.2
import PackageDescription

// Dev B: Unfreeze engine + player, atomizer, task path, audio, scoreboard.
let package = Package(
    name: "ParachuteKit",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "ParachuteKit", targets: ["ParachuteKit"]),
    ],
    dependencies: [
        .package(path: "../SharedKit"),
    ],
    targets: [
        .target(name: "ParachuteKit", dependencies: ["SharedKit"]),
        .testTarget(name: "ParachuteKitTests", dependencies: ["ParachuteKit"]),
    ]
)
