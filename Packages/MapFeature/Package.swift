// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "MapFeature",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "MapFeature",
            targets: ["MapFeature"]
        )
    ],
    dependencies: [
        .package(path: "../WIMBCore"),
        .package(path: "../TransportEngine"),
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "MapFeature",
            dependencies: ["WIMBCore", "TransportEngine", "DesignSystem"]
        )
    ]
)
