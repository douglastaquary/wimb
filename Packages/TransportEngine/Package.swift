// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "TransportEngine",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "TransportEngine",
            targets: ["TransportEngine"]
        )
    ],
    dependencies: [
        .package(path: "../WIMBCore"),
        .package(path: "../NetworkClient")
    ],
    targets: [
        .target(
            name: "TransportEngine",
            dependencies: ["WIMBCore", "NetworkClient"]
        ),
        .testTarget(
            name: "TransportEngineTests",
            dependencies: ["TransportEngine"]
        )
    ]
)
