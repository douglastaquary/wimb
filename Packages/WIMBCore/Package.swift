// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "WIMBCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "WIMBCore",
            targets: ["WIMBCore"]
        )
    ],
    targets: [
        .target(
            name: "WIMBCore"
        ),
        .testTarget(
            name: "WIMBCoreTests",
            dependencies: ["WIMBCore"]
        )
    ]
)
