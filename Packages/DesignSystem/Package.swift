// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]
        )
    ],
    dependencies: [
        .package(path: "../WIMBCore")
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: ["WIMBCore"]
        )
    ]
)
